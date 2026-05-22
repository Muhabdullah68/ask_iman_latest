// lib/core/services/community_service.dart
// ─────────────────────────────────────────────────────────────────────────────
// COMMUNITY SERVICE — Firestore data layer
//
// Collections:
//   users          — uid, name, email, role, bio, photoUrl, isBlocked, streakData
//   classes        — id, title, teacherId, studentIds, status(pending/active),
//                    description, category, meetingUrl
//   messages       — classId/dmId subcollection → senderId, text, timestamp
//   charities      — id, title, goal, raised, category, status(pending/active)
//   friendships    — id, fromUid, toUid, status(pending/accepted)
//   meetings       — classId, scheduledAt, duration, purpose, meetUrl
//   approvals      — id, type(teacher/class/charity), refId, status, createdAt
//   streaks        — userId subcollection → date, prayers, quran, classes, tasks
// ─────────────────────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';

// ── Role enum ─────────────────────────────────────────────────────────────────

enum UserRole { student, teacher, admin, unknown }

// ── Models ────────────────────────────────────────────────────────────────────

class AppUser {
  final String uid;
  final String name;
  final String email;
  final UserRole role;
  final String bio;
  final String? photoUrl;
  final bool isBlocked;
  final bool isApproved; // teachers only — set by admin
  final String qualification;
  final String specialization;
  final List<String> friends;
  final List<String> groups;
  final int reportCount;
  final int streakCount;

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
    this.bio = '',
    this.photoUrl,
    this.isBlocked = false,
    this.isApproved = false,
    this.qualification = '',
    this.specialization = '',
    this.friends = const [],
    this.groups = const [],
    this.reportCount = 0,
    this.streakCount = 0,
  });

  factory AppUser.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return AppUser(
      uid:            doc.id,
      name:           d['name']           ?? '',
      email:          d['email']          ?? '',
      role:           _roleFrom(d['role']),
      bio:            d['bio']            ?? '',
      photoUrl:       d['photoUrl'],
      isBlocked:      d['isBlocked']      ?? false,
      isApproved:     d['isApproved']     ?? false,
      qualification:  d['qualification']  ?? '',
      specialization: d['specialization'] ?? '',
      friends:        List<String>.from(d['friends'] ?? []),
      groups:         List<String>.from(d['groups']  ?? []),
      reportCount:    d['reportCount']    ?? 0,
      streakCount:    d['streakCount']    ?? 0,
    );
  }

  static UserRole _roleFrom(String? r) {
    switch (r) {
      case 'teacher': return UserRole.teacher;
      case 'admin':   return UserRole.admin;
      default:        return UserRole.student;
    }
  }

  Map<String, dynamic> toMap() => {
    'name':           name,
    'email':          email,
    'role':           role.name,
    'bio':            bio,
    'photoUrl':       photoUrl,
    'isBlocked':      isBlocked,
    'isApproved':     isApproved,
    'qualification':  qualification,
    'specialization': specialization,
    'friends':        friends,
    'groups':         groups,
    'reportCount':    reportCount,
    'streakCount':    streakCount,
  };
}

class ClassModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String teacherId;
  final String teacherName;
  final List<String> studentIds;
  final String status; // pending | active | rejected
  final int enrolled;
  final String? videoUrl;
  final int durationMinutes;
  final String? exceededDurationReason;
  final List<Map<String, dynamic>> materials;
  final double rating;

  const ClassModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.teacherId,
    required this.teacherName,
    required this.studentIds,
    required this.status,
    required this.enrolled,
    this.videoUrl,
    this.durationMinutes = 60,
    this.exceededDurationReason,
    this.materials = const [],
    this.rating = 0.0,
  });

  factory ClassModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ClassModel(
      id:                     doc.id,
      title:                  d['title']                  ?? '',
      description:            d['description']            ?? '',
      category:               d['category']               ?? 'General',
      teacherId:              d['teacherId']              ?? '',
      teacherName:            d['teacherName']            ?? '',
      studentIds:             List<String>.from(d['studentIds'] ?? []),
      status:                 d['status']                 ?? 'pending',
      enrolled:               d['enrolled']               ?? 0,
      videoUrl:               d['videoUrl'],
      durationMinutes:        d['durationMinutes']        ?? 60,
      exceededDurationReason: d['exceededDurationReason'],
      materials:              List<Map<String, dynamic>>.from(d['materials'] ?? []),
      rating:                 (d['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title':                  title,
    'description':            description,
    'category':               category,
    'teacherId':              teacherId,
    'teacherName':            teacherName,
    'studentIds':             studentIds,
    'status':                 status,
    'enrolled':               enrolled,
    'videoUrl':               videoUrl,
    'durationMinutes':        durationMinutes,
    'exceededDurationReason': exceededDurationReason,
    'materials':              materials,
    'rating':                 rating,
  };
}

class GroupModel {
  final String id;
  final String name;
  final String creatorId;
  final List<String> members;
  final Map<String, bool> notifConfig;
  final DateTime createdAt;

  const GroupModel({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.members,
    required this.notifConfig,
    required this.createdAt,
  });

  factory GroupModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return GroupModel(
      id:          doc.id,
      name:        d['name']      ?? '',
      creatorId:   d['creatorId'] ?? '',
      members:     List<String>.from(d['members'] ?? []),
      notifConfig: Map<String, bool>.from(d['notifConfig'] ?? {}),
      createdAt:   (d['createdAt'] as Timestamp).toDate(),
    );
  }
}

class ReportModel {
  final String id;
  final String reporterId;
  final String targetId;
  final String reason;
  final DateTime timestamp;
  final String status; // pending | resolved

  const ReportModel({
    required this.id,
    required this.reporterId,
    required this.targetId,
    required this.reason,
    required this.timestamp,
    required this.status,
  });

  factory ReportModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return ReportModel(
      id:         doc.id,
      reporterId: d['reporterId'] ?? '',
      targetId:   d['targetId']   ?? '',
      reason:     d['reason']     ?? '',
      timestamp:  (d['timestamp'] as Timestamp).toDate(),
      status:     d['status']     ?? 'pending',
    );
  }
}

class CharityModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final double goal;
  final double raised;
  final String status; // pending | active | rejected
  final bool verified;

  const CharityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.goal,
    required this.raised,
    required this.status,
    required this.verified,
  });

  factory CharityModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CharityModel(
      id:          doc.id,
      title:       d['title']       ?? '',
      description: d['description'] ?? '',
      category:    d['category']    ?? 'General',
      goal:        (d['goal']   ?? 0).toDouble(),
      raised:      (d['raised'] ?? 0).toDouble(),
      status:      d['status']      ?? 'pending',
      verified:    d['verified']    ?? false,
    );
  }

  double get progress => goal > 0 ? (raised / goal).clamp(0.0, 1.0) : 0.0;
  int get progressPct => (progress * 100).round();
}

class FriendshipModel {
  final String id;
  final String fromUid;
  final String toUid;
  final String status; // pending | accepted
  final String otherName;
  final String? otherPhotoUrl;

  const FriendshipModel({
    required this.id,
    required this.fromUid,
    required this.toUid,
    required this.status,
    required this.otherName,
    this.otherPhotoUrl,
  });

  factory FriendshipModel.fromDoc(DocumentSnapshot doc, String myUid) {
    final d = doc.data() as Map<String, dynamic>;
    final isFrom = d['fromUid'] == myUid;
    return FriendshipModel(
      id:            doc.id,
      fromUid:       d['fromUid'] ?? '',
      toUid:         d['toUid']   ?? '',
      status:        d['status']  ?? 'pending',
      otherName:     isFrom ? (d['toName'] ?? '') : (d['fromName'] ?? ''),
      otherPhotoUrl: isFrom ? d['toPhoto'] : d['fromPhoto'],
    );
  }
}

class MeetingModel {
  final String id;
  final String classId;
  final String purpose;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String? meetUrl;

  const MeetingModel({
    required this.id,
    required this.classId,
    required this.purpose,
    required this.scheduledAt,
    required this.durationMinutes,
    this.meetUrl,
  });

  factory MeetingModel.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return MeetingModel(
      id:              doc.id,
      classId:         d['classId']  ?? '',
      purpose:         d['purpose']  ?? '',
      scheduledAt:     (d['scheduledAt'] as Timestamp).toDate(),
      durationMinutes: d['duration'] ?? 60,
      meetUrl:         d['meetUrl'],
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// COMMUNITY SERVICE
// ══════════════════════════════════════════════════════════════════════════════

class CommunityService {
  CommunityService._();
  static final CommunityService instance = CommunityService._();

  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _storage = FirebaseStorage.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  // ── Storage ────────────────────────────────────────────────────────────────

  Future<String?> uploadImage(File file, String path) async {
    try {
      final ref = _storage.ref().child(path).child('${DateTime.now().millisecondsSinceEpoch}.jpg');
      final uploadTask = await ref.putFile(file);
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('Error uploading image: $e');
      return null;
    }
  }

  // ── Current user ───────────────────────────────────────────────────────────

  Future<AppUser?> getCurrentUser() async {
    if (_uid.isEmpty) return null;
    final doc = await _db.collection('users').doc(_uid).get();
    return doc.exists ? AppUser.fromDoc(doc) : null;
  }

  Stream<AppUser?> watchCurrentUser() {
    if (_uid.isEmpty) return Stream.value(null);
    return _db.collection('users').doc(_uid).snapshots()
        .map((d) => d.exists ? AppUser.fromDoc(d) : null);
  }

  // ── Registration ───────────────────────────────────────────────────────────

  Future<void> createUserProfile({
    required String name,
    required String email,
    required UserRole role,
    String bio = '',
    // Teacher-only fields
    String? qualification,
    String? specialization,
  }) async {
    final batch = _db.batch();
    final userRef = _db.collection('users').doc(_uid);

    batch.set(userRef, {
      'name':           name,
      'email':          email,
      'role':           role.name,
      'bio':            bio,
      'isBlocked':      false,
      'isApproved':     role == UserRole.student || role == UserRole.admin,
      'qualification':  qualification ?? '',
      'specialization': specialization ?? '',
      'friends':        [],
      'groups':         [],
      'reportCount':    0,
      'createdAt':      FieldValue.serverTimestamp(),
    });

    // Teachers go into approval queue
    if (role == UserRole.teacher) {
      final approvalRef = _db.collection('approvals').doc();
      batch.set(approvalRef, {
        'type':           'teacher',
        'refId':          _uid,
        'applicantName':  name,
        'qualification':  qualification ?? '',
        'specialization': specialization ?? '',
        'status':         'pending',
        'createdAt':      FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // ── Friends ────────────────────────────────────────────────────────────────

  Stream<List<FriendshipModel>> watchFriends() {
    return _db.collection('friendships')
        .where(Filter.or(
      Filter('fromUid', isEqualTo: _uid),
      Filter('toUid',   isEqualTo: _uid),
    ))
        .snapshots()
        .map((s) => s.docs.map((d) => FriendshipModel.fromDoc(d, _uid)).toList());
  }

  List<FriendshipModel> filterAccepted(List<FriendshipModel> list) =>
      list.where((f) => f.status == 'accepted').toList();

  List<FriendshipModel> filterPending(List<FriendshipModel> list) =>
      list.where((f) => f.status == 'pending' && f.toUid == _uid).toList();

  Future<void> sendFriendRequest(AppUser target) async {
    await _db.collection('friendships').add({
      'fromUid':   _uid,
      'toUid':     target.uid,
      'fromName':  (await getCurrentUser())?.name ?? '',
      'toName':    target.name,
      'fromPhoto': null,
      'toPhoto':   target.photoUrl,
      'status':    'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> acceptFriendRequest(String friendshipId) async {
    await _db.collection('friendships').doc(friendshipId)
        .update({'status': 'accepted'});
  }

  Future<void> declineFriendRequest(String friendshipId) async {
    await _db.collection('friendships').doc(friendshipId).delete();
  }

  Stream<List<AppUser>> searchUsers(String query) {
    if (query.isEmpty) return Stream.value([]);
    return _db.collection('users')
        .where('name', isGreaterThanOrEqualTo: query)
        .where('name', isLessThan: '${query}z')
        .where('isBlocked', isEqualTo: false)
        .limit(20)
        .snapshots()
        .map((s) => s.docs
        .map(AppUser.fromDoc)
        .where((u) => u.uid != _uid)
        .toList());
  }

  Stream<List<AppUser>> watchSuggestedFriends() {
    return _db.collection('users')
        .where('isBlocked', isEqualTo: false)
        .limit(20)
        .snapshots()
        .map((s) => s.docs
        .map(AppUser.fromDoc)
        .where((u) => u.uid != _uid)
        .toList());
  }

  // ── Groups ─────────────────────────────────────────────────────────────────

  Future<void> createGroup(String name, Map<String, bool> notifConfig) async {
    final groupRef = _db.collection('groups').doc();
    await groupRef.set({
      'name':        name,
      'creatorId':   _uid,
      'members':     [_uid],
      'notifConfig': notifConfig,
      'createdAt':   FieldValue.serverTimestamp(),
    });
    // Add group to user's list
    await _db.collection('users').doc(_uid).update({
      'groups': FieldValue.arrayUnion([groupRef.id])
    });
  }

  Stream<List<GroupModel>> watchMyGroups() {
    return _db.collection('groups')
        .where('members', arrayContains: _uid)
        .snapshots()
        .map((s) => s.docs.map(GroupModel.fromDoc).toList());
  }

  // ── Reports ────────────────────────────────────────────────────────────────

  Future<void> reportUser(String targetId, String reason) async {
    final reportRef = _db.collection('reports').doc();
    await reportRef.set({
      'reporterId': _uid,
      'targetId':   targetId,
      'reason':     reason,
      'timestamp':  FieldValue.serverTimestamp(),
      'status':     'pending',
    });
    // Increment report count on target user
    await _db.collection('users').doc(targetId).update({
      'reportCount': FieldValue.increment(1)
    });
  }

  // ── Streaks ────────────────────────────────────────────────────────────────

  Future<void> logStreakActivity({
    required bool prayers,
    required bool quran,
    required bool classAttended,
  }) async {
    final today = DateTime.now();
    final dateKey = '${today.year}-${today.month.toString().padLeft(2,'0')}-${today.day.toString().padLeft(2,'0')}';
    await _db
        .collection('streaks')
        .doc(_uid)
        .collection('logs')
        .doc(dateKey)
        .set({
      'prayers':       prayers,
      'quran':         quran,
      'classAttended': classAttended,
      'date':          Timestamp.fromDate(today),
      'loginCount':    FieldValue.increment(1),
    }, SetOptions(merge: true));

    // Update streak counter on user doc
    final newStreak = await getStreakForUser(_uid);
    await _db.collection('users').doc(_uid).update({
      'lastActive': FieldValue.serverTimestamp(),
      'streakCount': newStreak,
    });
  }

  Future<int> getCurrentStreak() async {
    return getStreakForUser(_uid);
  }

  Future<Map<String, double>> getSoulProgress() async {
    if (_uid.isEmpty) return {'namaz': 0, 'quran': 0, 'zikr': 0};
    
    try {
      final now = DateTime.now();
      final sevenDaysAgo = now.subtract(const Duration(days: 7));
      
      final snapshot = await _db
          .collection('streaks')
          .doc(_uid)
          .collection('logs')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(sevenDaysAgo))
          .get();

      if (snapshot.docs.isEmpty) return {'namaz': 0, 'quran': 0, 'zikr': 0};

      int namazCount = 0;
      int quranCount = 0;
      int zikrCount = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        if (data['prayers'] == true) namazCount++;
        if (data['quran'] == true) quranCount++;
        
        // Zikr: check if any custom task is done or if "zikr" specifically is done
        final custom = data['customTasks'];
        if (custom is Map) {
          bool done = false;
          custom.forEach((key, value) {
            if (key.toString().toLowerCase().contains('zikr') && value == true) done = true;
            if (value == true) done = true; // any custom task counts for demo
          });
          if (done) zikrCount++;
        }
      }

      return {
        'namaz': namazCount / 7,
        'quran': quranCount / 7,
        'zikr': zikrCount / 7,
      };
    } catch (e) {
      debugPrint('Error getting soul progress: $e');
      return {'namaz': 0, 'quran': 0, 'zikr': 0};
    }
  }

  Future<int> getStreakForUser(String userId) async {
    if (userId.isEmpty) return 0;
    
    try {
      final now = DateTime.now();
      final oneYearAgo = now.subtract(const Duration(days: 365));
      
      final snapshot = await _db
          .collection('streaks')
          .doc(userId)
          .collection('logs')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(oneYearAgo))
          .orderBy('date', descending: true)
          .limit(400) // Optimized: Limit to approx 1 year of docs
          .get();

      if (snapshot.docs.isEmpty) return 0;

      int streak = 0;
      DateTime checkDate = DateTime(now.year, now.month, now.day);
      
      // If today isn't logged yet, check if yesterday was logged to continue streak
      final latestDocDate = (snapshot.docs.first.data()['date'] as Timestamp).toDate();
      final latestDate = DateTime(latestDocDate.year, latestDocDate.month, latestDocDate.day);
      
      if (latestDate.isBefore(checkDate.subtract(const Duration(days: 1)))) {
        // Streak broken (more than 1 day since last log)
        return 0;
      }
      
      if (latestDate.isBefore(checkDate)) {
        // Today hasn't been logged yet, but yesterday was. 
        // We start counting from yesterday.
        checkDate = latestDate;
      }

      for (var doc in snapshot.docs) {
        final docDateRaw = (doc.data()['date'] as Timestamp).toDate();
        final docDate = DateTime(docDateRaw.year, docDateRaw.month, docDateRaw.day);
        
        if (docDate.isAtSameMomentAs(checkDate)) {
          streak++;
          checkDate = checkDate.subtract(const Duration(days: 1));
        } else if (docDate.isBefore(checkDate)) {
          // Gap found, streak ends here
          break;
        }
      }
      
      return streak;
    } catch (e) {
      debugPrint('Error calculating streak: $e');
      return 0;
    }
  }

  // ── Classes ────────────────────────────────────────────────────────────────

  Stream<List<ClassModel>> watchActiveClasses() {
    return _db.collection('classes')
        .where('status', isEqualTo: 'active')
        .snapshots()
        .map((s) => s.docs.map(ClassModel.fromDoc).toList());
  }

  Stream<List<ClassModel>> watchMyClasses() {
    if (_uid.isEmpty) return Stream.value([]);
    return _db.collection('classes')
        .where('teacherId', isEqualTo: _uid)
        .snapshots()
        .map((s) => s.docs.map(ClassModel.fromDoc).toList());
  }

  Stream<List<ClassModel>> watchEnrolledClasses() {
    if (_uid.isEmpty) return Stream.value([]);
    return _db.collection('classes')
        .where('studentIds', arrayContains: _uid)
        .snapshots()
        .map((s) => s.docs.map(ClassModel.fromDoc).toList());
  }

  Future<void> joinClass(String classId) async {
    if (_uid.isEmpty) return;
    await _db.collection('classes').doc(classId).update({
      'studentIds': FieldValue.arrayUnion([_uid]),
      'enrolled':   FieldValue.increment(1),
    });
  }

  Future<void> leaveClass(String classId) async {
    await _db.collection('classes').doc(classId).update({
      'studentIds': FieldValue.arrayRemove([_uid]),
      'enrolled':   FieldValue.increment(-1),
    });
  }

  Future<void> submitNewClass({
    required String title,
    required String description,
    required String category,
    required String teacherName,
    String? videoUrl,
    int durationMinutes = 60,
  }) async {
    final classRef = _db.collection('classes').doc();
    final batch    = _db.batch();

    batch.set(classRef, {
      'title':           title,
      'description':     description,
      'category':        category,
      'teacherId':       _uid,
      'teacherName':     teacherName,
      'studentIds':      [],
      'enrolled':        0,
      'status':          'pending',
      'videoUrl':        videoUrl,
      'durationMinutes': durationMinutes,
      'materials':       [],
      'rating':          0.0,
      'createdAt':       FieldValue.serverTimestamp(),
    });

    final approvalRef = _db.collection('approvals').doc();
    batch.set(approvalRef, {
      'type':      'class',
      'refId':     classRef.id,
      'title':     title,
      'teacherId': _uid,
      'status':    'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> rateClass(String classId, double rating, String comment) async {
    final classRef = _db.collection('classes').doc(classId);
    
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(classRef);
      if (!snapshot.exists) return;

      final data = snapshot.data() as Map<String, dynamic>;
      final currentRating = (data['rating'] ?? 0.0).toDouble();
      final enrolledCount = (data['enrolled'] ?? 1).toInt();
      
      // Simple moving average for demonstration
      final newRating = ((currentRating * (enrolledCount - 1)) + rating) / enrolledCount;
      
      transaction.update(classRef, {'rating': newRating});
    });
  }

  // ── Meetings ───────────────────────────────────────────────────────────────

  Future<void> scheduleMeeting({
    required String classId,
    required String className,
    required String purpose,
    required DateTime scheduledAt,
    required int durationMinutes,
    String? meetUrl,
  }) async {
    await _db.collection('meetings').add({
      'classId':         classId,
      'className':       className,
      'purpose':         purpose,
      'scheduledAt':     Timestamp.fromDate(scheduledAt),
      'duration':        durationMinutes,
      'meetUrl':         meetUrl,
      'teacherId':       _uid,
      'createdAt':       FieldValue.serverTimestamp(),
    });
  }

  Stream<List<MeetingModel>> watchUpcomingMeetings(String classId) {
    return _db.collection('meetings')
        .where('classId', isEqualTo: classId)
        .where('scheduledAt', isGreaterThan: Timestamp.now())
        .orderBy('scheduledAt')
        .limit(5)
        .snapshots()
        .map((s) => s.docs.map(MeetingModel.fromDoc).toList());
  }

  // ── Messages ───────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> watchClassMessages(String classId) {
    return _db
        .collection('messages')
        .doc('class_$classId')
        .collection('msgs')
        .orderBy('createdAt', descending: false)
        .limitToLast(60)
        .snapshots();
  }

  Future<void> sendClassMessage(String classId, String text, {Map<String, dynamic>? material}) async {
    final user = await getCurrentUser();
    await _db
        .collection('messages')
        .doc('class_$classId')
        .collection('msgs')
        .add({
      'senderId':   _uid,
      'senderName': user?.name ?? 'Unknown',
      'text':       text,
      'material':   material,
      'createdAt':  FieldValue.serverTimestamp(),
    });
  }

  Stream<QuerySnapshot> watchDmMessages(String otherUid, {String? explicitDmId}) {
    if (explicitDmId != null) {
      return _db
          .collection('messages')
          .doc('dm_$explicitDmId')
          .collection('msgs')
          .orderBy('createdAt', descending: false)
          .limitToLast(60)
          .snapshots();
    }
    final ids = [_uid, otherUid]..sort();
    final dmId = ids.join('_');
    return _db
        .collection('messages')
        .doc('dm_$dmId')
        .collection('msgs')
        .orderBy('createdAt', descending: false)
        .limitToLast(60)
        .snapshots();
  }

  Future<void> sendDm(String otherUid, String text) async {
    final ids = [_uid, otherUid]..sort();
    final dmId = ids.join('_');
    final user = await getCurrentUser();
    await _db
        .collection('messages')
        .doc('dm_$dmId')
        .collection('msgs')
        .add({
      'senderId':   _uid,
      'senderName': user?.name ?? 'Unknown',
      'text':       text,
      'createdAt':  FieldValue.serverTimestamp(),
    });
  }

  // ── Charity ────────────────────────────────────────────────────────────────

  Stream<List<CharityModel>> watchActiveCharities({String? category}) {
    Query q = _db.collection('charities').where('status', isEqualTo: 'active');
    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }
    return q.snapshots().map((s) => s.docs.map(CharityModel.fromDoc).toList());
  }

  Future<void> submitCharity({
    required String title,
    required String description,
    required String category,
    required double goal,
  }) async {
    final charityRef = _db.collection('charities').doc();
    final batch      = _db.batch();

    batch.set(charityRef, {
      'title':       title,
      'description': description,
      'category':    category,
      'goal':        goal,
      'raised':      0.0,
      'status':      'pending',
      'verified':    false,
      'createdBy':   _uid,
      'createdAt':   FieldValue.serverTimestamp(),
    });

    final approvalRef = _db.collection('approvals').doc();
    batch.set(approvalRef, {
      'type':    'charity',
      'refId':   charityRef.id,
      'title':   title,
      'goal':    goal,
      'status':  'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> contributeToCharity(String charityId, double amount) async {
    final docRef = _db.collection('charities').doc(charityId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(docRef);
      if (!snap.exists) return;
      final currentRaised = (snap.data()?['raised'] ?? 0.0).toDouble();
      tx.update(docRef, {'raised': currentRaised + amount});
    });
  }

  // ── Admin ──────────────────────────────────────────────────────────────────

  Stream<QuerySnapshot> watchPendingApprovals() {
    // No orderBy — avoids composite index requirement. Sort client-side.
    return _db.collection('approvals')
        .where('status', isEqualTo: 'pending')
        .snapshots();
  }

  Future<void> approveItem(String approvalId, String type, String refId) async {
    final batch = _db.batch();
    batch.update(_db.collection('approvals').doc(approvalId),
        {'status': 'approved'});

    if (type == 'teacher') {
      batch.update(_db.collection('users').doc(refId), {'isApproved': true});
    } else if (type == 'class') {
      batch.update(_db.collection('classes').doc(refId), {'status': 'active'});
    } else if (type == 'charity') {
      batch.update(_db.collection('charities').doc(refId),
          {'status': 'active', 'verified': true});
    }
    await batch.commit();
  }

  Future<void> rejectItem(String approvalId, String type, String refId) async {
    final batch = _db.batch();
    batch.update(_db.collection('approvals').doc(approvalId),
        {'status': 'rejected'});
    if (type == 'class') {
      batch.update(_db.collection('classes').doc(refId), {'status': 'rejected'});
    } else if (type == 'charity') {
      batch.update(_db.collection('charities').doc(refId),
          {'status': 'rejected'});
    }
    await batch.commit();
  }

  Future<void> blockUser(String uid) async {
    await _db.collection('users').doc(uid).update({'isBlocked': true});
  }

  Future<void> unblockUser(String uid) async {
    await _db.collection('users').doc(uid).update({'isBlocked': false});
  }

  Future<void> deleteUser(String uid) async {
    await _db.collection('users').doc(uid).delete();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> updateUserProfile({
    required String name,
    required String bio,
    String? photoUrl,
  }) async {
    if (_uid.isEmpty) return;
    await _db.collection('users').doc(_uid).update({
      'name': name,
      'bio': bio,
      if (photoUrl != null) 'photoUrl': photoUrl,
    });
  }

  // Live list of approved teachers (for student Featured Teachers section)
  Stream<List<AppUser>> watchApprovedTeachers() {
    return _db.collection('users')
        .where('role', isEqualTo: 'teacher')
        .where('isApproved', isEqualTo: true)
        .where('isBlocked', isEqualTo: false)
        .snapshots()
        .map((s) => s.docs.map(AppUser.fromDoc).toList());
  }

  Stream<QuerySnapshot> watchAllUsers() {
    // No orderBy — some seed docs lack createdAt. Sort client-side.
    return _db.collection('users').snapshots();
  }

  Stream<QuerySnapshot> watchAllConversations() {
    return _db.collection('messages').snapshots();
  }

  Future<void> sendAdminMessage(String conversationId, String text) async {
    final user = await getCurrentUser();
    await _db
        .collection('messages')
        .doc(conversationId)
        .collection('msgs')
        .add({
      'senderId':   _uid,
      'senderName': '(Admin) ${user?.name ?? 'Admin'}',
      'text':       text,
      'createdAt':  FieldValue.serverTimestamp(),
      'isAdminMsg': true,
    });
  }
}
