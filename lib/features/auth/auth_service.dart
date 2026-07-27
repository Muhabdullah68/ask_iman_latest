import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/community_service.dart' show UserRole;

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> get authState => _auth.authStateChanges();

  Future<UserCredential> signIn({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signUp({
    required String email,
    required String password,
    required String name,
    UserRole role = UserRole.student,
    Map<String, dynamic>? profileData,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final uid = cred.user!.uid;
    final baseDoc = <String, dynamic>{
      'name': name,
      'email': email,
      'role': role.name,
      'bio': '',
      'photoUrl': null,
      'isBlocked': false,
      'isApproved': false,
      'friends': [],
      'reportCount': 0,
      'streakCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    };
    if (profileData != null) baseDoc.addAll(profileData);
    await _firestore.collection('users').doc(uid).set(baseDoc);
    await _firestore.collection('approvals').doc(uid).set({
      'type': role.name,
      'refId': uid,
      'title': name,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cached_guest_user_${_auth.currentUser?.uid}', '');
    return cred;
  }

  Future<Map<String, dynamic>?> getUserDoc(String uid) async {
    final snap = await _firestore.collection('users').doc(uid).get();
    return snap.data();
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
