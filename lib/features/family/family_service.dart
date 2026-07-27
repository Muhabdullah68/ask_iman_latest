import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as tz;
import '../../core/services/notification_service.dart';
import '../../core/services/fcm_service.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class FamilyGroup {
  final String id;
  final String name;
  final String? description;
  final String creatorId;
  final String creatorName;
  final List<String> memberIds;
  final List<String> memberNames;
  final String? inviteCode;
  final DateTime createdAt;

  const FamilyGroup({
    required this.id,
    required this.name,
    this.description,
    required this.creatorId,
    required this.creatorName,
    required this.memberIds,
    required this.memberNames,
    this.inviteCode,
    required this.createdAt,
  });

  factory FamilyGroup.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FamilyGroup(
      id: doc.id,
      name: d['name'] ?? '',
      description: d['description'],
      creatorId: d['creatorId'] ?? '',
      creatorName: d['creatorName'] ?? '',
      memberIds: List<String>.from(d['memberIds'] ?? []),
      memberNames: List<String>.from(d['memberNames'] ?? []),
      inviteCode: d['inviteCode'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  int get memberCount => memberIds.length;
}

class FamilyReminder {
  final String id;
  final String groupId;
  final String creatorId;
  final String creatorName;
  final String title;
  final String? description;
  final String type;
  final DateTime? scheduledAt;
  final bool recurring;
  final List<String>? recurringDays;
  final bool completed;
  final DateTime createdAt;
  final String? sound;
  final int? notificationId;
  final String? imageUrl;

  const FamilyReminder({
    required this.id,
    required this.groupId,
    required this.creatorId,
    required this.creatorName,
    required this.title,
    this.description,
    required this.type,
    this.scheduledAt,
    required this.recurring,
    this.recurringDays,
    required this.completed,
    required this.createdAt,
    this.sound,
    this.notificationId,
    this.imageUrl,
  });

  factory FamilyReminder.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FamilyReminder(
      id: doc.id,
      groupId: d['groupId'] ?? '',
      creatorId: d['creatorId'] ?? '',
      creatorName: d['creatorName'] ?? '',
      title: d['title'] ?? '',
      description: d['description'],
      type: d['type'] ?? 'general',
      scheduledAt: (d['scheduledAt'] as Timestamp?)?.toDate(),
      recurring: d['recurring'] ?? false,
      recurringDays: d['recurringDays'] != null
          ? List<String>.from(d['recurringDays'])
          : null,
      completed: d['completed'] ?? false,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      sound: d['sound'],
      notificationId: d['notificationId'],
      imageUrl: d['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'groupId': groupId,
      'imageUrl': imageUrl,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'title': title,
      'description': description,
      'type': type,
      'scheduledAt': scheduledAt != null
          ? Timestamp.fromDate(scheduledAt!)
          : null,
      'recurring': recurring,
      'recurringDays': recurringDays,
      'completed': completed,
      'createdAt': Timestamp.fromDate(createdAt),
      'sound': sound,
      'notificationId': notificationId,
    };
  }
}

class FamilyGroupMessage {
  final String id;
  final String groupId;
  final String senderId;
  final String senderName;
  final String text;
  final DateTime createdAt;

  const FamilyGroupMessage({
    required this.id,
    required this.groupId,
    required this.senderId,
    required this.senderName,
    required this.text,
    required this.createdAt,
  });

  factory FamilyGroupMessage.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return FamilyGroupMessage(
      id: doc.id,
      groupId: d['groupId'] ?? '',
      senderId: d['senderId'] ?? '',
      senderName: d['senderName'] ?? '',
      text: d['text'] ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// ── Service ───────────────────────────────────────────────────────────────────

class FamilyService {
  FamilyService._();
  static final FamilyService instance = FamilyService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  // ── Groups ────────────────────────────────────────────────────────────────

  Stream<List<FamilyGroup>> watchMyGroups() {
    if (_uid.isEmpty) return Stream.value([]);
    return _db
        .collection('family_groups')
        .where('memberIds', arrayContains: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(FamilyGroup.fromDoc).toList());
  }

  Stream<FamilyGroup?> watchGroup(String groupId) {
    return _db
        .collection('family_groups')
        .doc(groupId)
        .snapshots()
        .map((d) => d.exists ? FamilyGroup.fromDoc(d) : null);
  }

  Future<String> createGroup({
    required String name,
    String? description,
  }) async {
    final user = await _db.collection('users').doc(_uid).get();
    final userName = (user.data()?['name'] ?? 'User') as String;
    final inviteCode = _generateInviteCode();

    final ref = _db.collection('family_groups').doc();
    await ref.set({
      'name': name,
      'description': description,
      'creatorId': _uid,
      'creatorName': userName,
      'memberIds': [_uid],
      'memberNames': [userName],
      'inviteCode': inviteCode,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('users').doc(_uid).update({
      'familyGroups': FieldValue.arrayUnion([ref.id]),
    });

    FcmService.instance.subscribeToGroup(ref.id);

    return ref.id;
  }

  Future<bool> joinGroupByCode(String inviteCode) async {
    final snap = await _db
        .collection('family_groups')
        .where('inviteCode', isEqualTo: inviteCode.toUpperCase())
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return false;

    final group = snap.docs.first;
    final members = List<String>.from(group.data()['memberIds'] ?? []);
    if (members.contains(_uid)) return false;

    final user = await _db.collection('users').doc(_uid).get();
    final userName = (user.data()?['name'] ?? 'User') as String;

    await group.reference.update({
      'memberIds': FieldValue.arrayUnion([_uid]),
      'memberNames': FieldValue.arrayUnion([userName]),
    });

    await _db.collection('users').doc(_uid).update({
      'familyGroups': FieldValue.arrayUnion([group.id]),
    });

    FcmService.instance.subscribeToGroup(group.id);

    return true;
  }

  Future<void> removeMember(
    String groupId,
    String memberId,
    String memberName,
  ) async {
    await _db.collection('family_groups').doc(groupId).update({
      'memberIds': FieldValue.arrayRemove([memberId]),
      'memberNames': FieldValue.arrayRemove([memberName]),
    });
  }

  Future<void> leaveGroup(String groupId) async {
    final groupRef = _db.collection('family_groups').doc(groupId);
    final user = await _db.collection('users').doc(_uid).get();
    final userName = (user.data()?['name'] ?? 'User') as String;

    await groupRef.update({
      'memberIds': FieldValue.arrayRemove([_uid]),
      'memberNames': FieldValue.arrayRemove([userName]),
    });

    await _db.collection('users').doc(_uid).update({
      'familyGroups': FieldValue.arrayRemove([groupId]),
    });

    FcmService.instance.unsubscribeFromGroup(groupId);
  }

  // ── Reminders ────────────────────────────────────────────────────────────

  Stream<List<FamilyReminder>> watchReminders(String groupId) {
    return _db
        .collection('family_reminders')
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(FamilyReminder.fromDoc).toList());
  }

  Future<void> createReminder({
    required String groupId,
    required String title,
    String? description,
    required String type,
    DateTime? scheduledAt,
    bool recurring = false,
    List<String>? recurringDays,
    String? sound,
    String? imageUrl,
  }) async {
    final user = await _db.collection('users').doc(_uid).get();
    final userName = (user.data()?['name'] ?? 'User') as String;

    // Generate unique notification ID (32-bit safe for Android)
    final int notificationId =
        DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF;

    final data = <String, dynamic>{
      'groupId': groupId,
      'creatorId': _uid,
      'creatorName': userName,
      'title': title,
      'description': description,
      'type': type,
      'recurring': recurring,
      'completed': false,
      'createdAt': FieldValue.serverTimestamp(),
      'notificationId': notificationId,
      'sound': sound,
      'imageUrl': imageUrl,
    };
    if (scheduledAt != null) {
      data['scheduledAt'] = Timestamp.fromDate(scheduledAt);
    }
    if (recurringDays != null) data['recurringDays'] = recurringDays;

    // First add to Firestore
    await _db.collection('family_reminders').add(data);

    // If scheduled time set, schedule local notification
    if (scheduledAt != null) {
      final tzScheduledAt = tz.TZDateTime.from(scheduledAt, tz.local);

      // Convert day names (Mon, Tue...) to numbers (1-7)
      List<int>? dayNumbers;
      if (recurringDays != null && recurringDays.isNotEmpty) {
        const dayMap = {
          'Mon': 1,
          'Tue': 2,
          'Wed': 3,
          'Thu': 4,
          'Fri': 5,
          'Sat': 6,
          'Sun': 7,
        };
        dayNumbers = recurringDays.map((day) => dayMap[day] ?? 1).toList();
      }

      await NotificationService.scheduleReminder(
        id: notificationId,
        title: title,
        body: description ?? 'Reminder from your group!',
        scheduledDate: tzScheduledAt,
        soundName: sound,
        recurring: recurring,
        days: dayNumbers,
      );
    }
  }

  Future<void> updateReminder({
    required String reminderId,
    required String title,
    String? description,
    required String type,
    DateTime? scheduledAt,
    bool recurring = false,
    List<String>? recurringDays,
    String? sound,
    String? imageUrl,
  }) async {
    final data = <String, dynamic>{
      'title': title,
      'description': description,
      'type': type,
      'recurring': recurring,
      'sound': sound,
      'imageUrl': imageUrl,
    };
    if (scheduledAt != null) {
      data['scheduledAt'] = Timestamp.fromDate(scheduledAt);
    }
    if (recurringDays != null) data['recurringDays'] = recurringDays;

    await _db.collection('family_reminders').doc(reminderId).update(data);

    // Re-schedule notification if time is set
    if (scheduledAt != null) {
      final oldDoc = await _db
          .collection('family_reminders')
          .doc(reminderId)
          .get();
      if (oldDoc.exists) {
        final old = FamilyReminder.fromDoc(oldDoc);
        if (old.notificationId != null) {
          await NotificationService.cancelReminder(old.notificationId!);
        }
      }

      final newNotificationId =
          DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF;
      await _db.collection('family_reminders').doc(reminderId).update({
        'notificationId': newNotificationId,
      });

      final tzScheduledAt = tz.TZDateTime.from(scheduledAt, tz.local);
      List<int>? dayNumbers;
      if (recurringDays != null && recurringDays.isNotEmpty) {
        const dayMap = {
          'Mon': 1,
          'Tue': 2,
          'Wed': 3,
          'Thu': 4,
          'Fri': 5,
          'Sat': 6,
          'Sun': 7,
        };
        dayNumbers = recurringDays.map((day) => dayMap[day] ?? 1).toList();
      }

      await NotificationService.scheduleReminder(
        id: newNotificationId,
        title: title,
        body: description ?? 'Reminder from your group!',
        scheduledDate: tzScheduledAt,
        soundName: sound,
        recurring: recurring,
        days: dayNumbers,
      );
    }
  }

  Future<void> toggleReminder(String reminderId, bool completed) async {
    // Get the reminder first to get notificationId
    final doc = await _db.collection('family_reminders').doc(reminderId).get();
    if (doc.exists) {
      final reminder = FamilyReminder.fromDoc(doc);
      if (completed && reminder.notificationId != null) {
        await NotificationService.cancelReminder(reminder.notificationId!);
      }
    }
    await _db.collection('family_reminders').doc(reminderId).update({
      'completed': completed,
    });
  }

  Future<void> deleteReminder(String reminderId) async {
    // Get the reminder first to get notificationId
    final doc = await _db.collection('family_reminders').doc(reminderId).get();
    if (doc.exists) {
      final reminder = FamilyReminder.fromDoc(doc);
      if (reminder.notificationId != null) {
        await NotificationService.cancelReminder(reminder.notificationId!);
      }
    }
    await _db.collection('family_reminders').doc(reminderId).delete();
  }

  // ── Chat ──────────────────────────────────────────────────────────────────

  Stream<List<FamilyGroupMessage>> watchMessages(String groupId) {
    return _db
        .collection('family_group_messages')
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: false)
        .limitToLast(100)
        .snapshots()
        .map((s) => s.docs.map(FamilyGroupMessage.fromDoc).toList());
  }

  Future<void> sendMessage(String groupId, String text) async {
    final user = await _db.collection('users').doc(_uid).get();
    final userName = (user.data()?['name'] ?? 'User') as String;

    await _db.collection('family_group_messages').add({
      'groupId': groupId,
      'senderId': _uid,
      'senderName': userName,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendReminderNow(FamilyReminder reminder) async {
    await NotificationService.scheduleReminder(
      id: DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF,
      title: '📌 ${reminder.title}',
      body: reminder.description ?? 'Reminder from your group!',
      scheduledDate: tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(seconds: 2)),
      soundName: reminder.sound,
    );
  }

  Future<void> notifyAllMembers(
    String groupId,
    String title,
    String body,
  ) async {
    await _db.collection('family_group_messages').add({
      'groupId': groupId,
      'senderId': _uid,
      'senderName': 'System',
      'text': '📢 $title\n$body',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await NotificationService.scheduleReminder(
      id: DateTime.now().millisecondsSinceEpoch % 0x7FFFFFFF,
      title: '📢 $title',
      body: body,
      scheduledDate: tz.TZDateTime.now(
        tz.local,
      ).add(const Duration(seconds: 1)),
    );
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

  String _generateInviteCode() {
    final chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final code = List.generate(6, (_) => chars[_random(chars.length)]).join();
    return code;
  }

  int _random(int max) => DateTime.now().microsecondsSinceEpoch % max;
}
