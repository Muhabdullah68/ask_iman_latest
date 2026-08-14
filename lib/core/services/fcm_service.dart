import 'dart:async';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/family/group_detail_screen.dart' as family;

class FcmService {
  FcmService._();
  static final FcmService instance = FcmService._();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? _currentUid;
  bool _initialized = false;
  FlutterLocalNotificationsPlugin? _localNotif;
  GlobalKey<NavigatorState>? _navigatorKey;
  final List<StreamSubscription> _subscriptions = [];
  DateTime _listenerStart = DateTime.now();

  Future<void> initialize({String? uid}) async {
    if (_initialized) return;
    // Web push notifications require a VAPID key + service worker setup that
    // is configured separately — skip here so the site runs without FCM.
    if (kIsWeb) return;
    _currentUid = uid;

    FirebaseMessaging.onBackgroundMessage(_backgroundHandler);

    if (_localNotif != null) {
      await _localNotif!
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.createNotificationChannel(
            const AndroidNotificationChannel(
              'fcm_channel',
              'Group Notifications',
              description:
                  'Notifications from your family and community groups',
              importance: Importance.high,
              playSound: true,
            ),
          );
    }

    // Only request FCM push permission on first launch
    final prefs = await SharedPreferences.getInstance();
    final fcmAsked = prefs.getBool('_fcm_permission_asked') ?? false;
    if (!fcmAsked) {
      NotificationSettings settings = await _fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      await prefs.setBool('_fcm_permission_asked', true);
      if (settings.authorizationStatus == AuthorizationStatus.denied) {
        return;
      }
    }

    await _fcm.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    String? token = await _fcm.getToken();
    if (token != null) {
      await _storeToken(token);
    }

    await _resubscribeToGroups();
    await _startWatchingGroups();

    _fcm.onTokenRefresh.listen((t) async {
      await _storeToken(t);
      await _resubscribeToGroups();
    });

    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    RemoteMessage? initialMessage = await _fcm.getInitialMessage();
    if (initialMessage != null) {
      // Defer navigation to ensure runApp has completed
      Future.delayed(const Duration(milliseconds: 500), () {
        _handleNotificationTap(initialMessage);
      });
    }

    _initialized = true;
  }

  Future<void> setUid(String uid) async {
    if (kIsWeb) return;
    _currentUid = uid;
    String? token = await _fcm.getToken();
    if (token != null) {
      await _storeToken(token);
    }
    await _resubscribeToGroups();
    await _startWatchingGroups();
  }

  void dispose() {
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();
  }

  // ── FCM Token Storage ──────────────────────────────────────────────────

  Future<void> _storeToken(String token) async {
    if (_currentUid == null) return;
    await _db
        .collection('users')
        .doc(_currentUid)
        .collection('fcmTokens')
        .doc(token)
        .set({'token': token, 'createdAt': FieldValue.serverTimestamp()});
  }

  // ── FCM Topic Management (for future Blaze upgrade) ────────────────────

  Future<void> _resubscribeToGroups() async {
    if (_currentUid == null) return;
    try {
      final groups = await _db
          .collection('family_groups')
          .where('memberIds', arrayContains: _currentUid)
          .get();
      for (final g in groups.docs) {
        await _fcm.subscribeToTopic('group_${g.id}');
      }
    } catch (e) {
      debugPrint('Resubscribe error: $e');
    }
  }

  Future<void> subscribeToGroup(String groupId) async {
    if (kIsWeb) return;
    await _fcm.subscribeToTopic('group_$groupId');
  }

  Future<void> unsubscribeFromGroup(String groupId) async {
    if (kIsWeb) return;
    await _fcm.unsubscribeFromTopic('group_$groupId');
  }

  // ── Client-Side Group Watching (works on Spark plan) ───────────────────

  Future<void> _startWatchingGroups() async {
    _listenerStart = DateTime.now();
    for (final sub in _subscriptions) {
      sub.cancel();
    }
    _subscriptions.clear();

    if (_currentUid == null) return;
    try {
      final groups = await _db
          .collection('family_groups')
          .where('memberIds', arrayContains: _currentUid)
          .get();
      for (final g in groups.docs) {
        _watchGroupReminders(g.id);
        _watchGroupMessages(g.id);
      }
    } catch (e) {
      debugPrint('Watch error: $e');
    }
  }

  void _watchGroupReminders(String groupId) {
    final sub = _db
        .collection('family_reminders')
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
          for (final change in snapshot.docChanges) {
            if (change.type != DocumentChangeType.added) continue;
            final data = change.doc.data();
            if (data == null) continue;
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
            if (createdAt != null &&
                createdAt.isAfter(_listenerStart) &&
                data['creatorId'] != _currentUid) {
              _showNotification(
                title:
                    '${data['creatorName'] ?? 'Someone'} added: ${data['title'] ?? 'Reminder'}',
                body: data['description'] ?? '',
                groupId: groupId,
              );
            }
          }
        });
    _subscriptions.add(sub);
  }

  void _watchGroupMessages(String groupId) {
    final sub = _db
        .collection('family_group_messages')
        .where('groupId', isEqualTo: groupId)
        .orderBy('createdAt', descending: true)
        .limit(20)
        .snapshots()
        .listen((snapshot) {
          for (final change in snapshot.docChanges) {
            if (change.type != DocumentChangeType.added) continue;
            final data = change.doc.data();
            if (data == null) continue;
            final createdAt = (data['createdAt'] as Timestamp?)?.toDate();
            if (createdAt != null &&
                createdAt.isAfter(_listenerStart) &&
                data['senderId'] != _currentUid) {
              _showNotification(
                title: '${data['senderName'] ?? 'Someone'} in your group',
                body: data['text'] ?? '',
                groupId: groupId,
              );
            }
          }
        });
    _subscriptions.add(sub);
  }

  void _showNotification({
    required String title,
    required String body,
    required String groupId,
  }) {
    if (_localNotif == null) return;
    _notifCounter++;
    _localNotif!.show(
      _notifCounter,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'fcm_channel',
          'Group Notifications',
          channelDescription:
              'Notifications from your family and community groups',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
      payload: groupId,
    );
  }

  // ── Setters ────────────────────────────────────────────────────────────

  int _notifCounter = 0;

  void setLocalNotificationPlugin(FlutterLocalNotificationsPlugin plugin) {
    _localNotif = plugin;
  }

  void setNavigatorKey(GlobalKey<NavigatorState> key) {
    _navigatorKey = key;
  }

  // ── Foreground FCM Message Handling ────────────────────────────────────

  void _handleForegroundMessage(RemoteMessage message) {
    RemoteNotification? notification = message.notification;
    if (notification != null && _localNotif != null) {
      _notifCounter++;
      _localNotif!.show(
        _notifCounter,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'fcm_channel',
            'Group Notifications',
            channelDescription:
                'Notifications from your family and community groups',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        ),
        payload: message.data['groupId'],
      );
    }
  }

  void _handleNotificationTap(RemoteMessage? message) {
    if (message == null) return;
    final groupId = message.data['groupId'];
    if (groupId != null && _navigatorKey?.currentContext != null) {
      Navigator.of(_navigatorKey!.currentContext!).push(
        MaterialPageRoute(
          builder: (_) =>
              family.GroupDetailScreen(groupId: groupId, groupName: ''),
        ),
      );
    }
  }

  @pragma('vm:entry-point')
  static Future<void> _backgroundHandler(RemoteMessage message) async {}
}
