import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ── Models ────────────────────────────────────────────────────────────────────

class CharityCause {
  final String id;
  final String title;
  final String description;
  final String category;
  final double goal;
  final double raised;
  final String status;
  final bool verified;
  final String createdBy;
  final String? imageUrl;
  final String? orgName;
  final String? bankDetails;
  final DateTime createdAt;

  const CharityCause({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.goal,
    required this.raised,
    required this.status,
    required this.verified,
    required this.createdBy,
    this.imageUrl,
    this.orgName,
    this.bankDetails,
    required this.createdAt,
  });

  factory CharityCause.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CharityCause(
      id: doc.id,
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      category: d['category'] ?? 'General',
      goal: (d['goal'] ?? 0).toDouble(),
      raised: (d['raised'] ?? 0).toDouble(),
      status: d['status'] ?? 'pending',
      verified: d['verified'] ?? false,
      createdBy: d['createdBy'] ?? '',
      imageUrl: d['imageUrl'],
      orgName: d['orgName'],
      bankDetails: d['bankDetails'],
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'title': title,
    'description': description,
    'category': category,
    'goal': goal,
    'raised': raised,
    'status': status,
    'verified': verified,
    'createdBy': createdBy,
    'imageUrl': imageUrl,
    'orgName': orgName,
    'bankDetails': bankDetails,
    'createdAt': FieldValue.serverTimestamp(),
  };

  double get progress => goal > 0 ? (raised / goal).clamp(0.0, 1.0) : 0.0;
  int get progressPct => (progress * 100).round();
}

class CharityDonation {
  final String id;
  final String causeId;
  final String userId;
  final String userName;
  final double amount;
  final bool anonymous;
  final String? message;
  final String? screenshotUrl;
  final String status;
  final DateTime createdAt;

  const CharityDonation({
    required this.id,
    required this.causeId,
    required this.userId,
    required this.userName,
    required this.amount,
    required this.anonymous,
    this.message,
    this.screenshotUrl,
    this.status = 'pending',
    required this.createdAt,
  });

  factory CharityDonation.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CharityDonation(
      id: doc.id,
      causeId: d['causeId'] ?? '',
      userId: d['userId'] ?? '',
      userName: d['userName'] ?? '',
      amount: (d['amount'] ?? 0).toDouble(),
      anonymous: d['anonymous'] ?? false,
      message: d['message'],
      screenshotUrl: d['screenshotUrl'],
      status: d['status'] ?? 'pending',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

class CharityRequest {
  final String id;
  final String userId;
  final String userName;
  final String firstName;
  final String lastName;
  final String fatherName;
  final String address;
  final String title;
  final String description;
  final double amountNeeded;
  final double amountReceived;
  final String category;
  final String customCategory;
  final String status;
  final String? contactInfo;
  final String? email;
  final String? accountDetails;
  final String? cnicFrontUrl;
  final String? cnicBackUrl;
  final List<String> proofImages;
  final List<String> documents;
  final DateTime createdAt;

  const CharityRequest({
    required this.id,
    required this.userId,
    required this.userName,
    this.firstName = '',
    this.lastName = '',
    this.fatherName = '',
    this.address = '',
    required this.title,
    required this.description,
    required this.amountNeeded,
    required this.amountReceived,
    required this.category,
    this.customCategory = '',
    required this.status,
    this.contactInfo,
    this.email,
    this.accountDetails,
    this.cnicFrontUrl,
    this.cnicBackUrl,
    this.proofImages = const [],
    this.documents = const [],
    required this.createdAt,
  });

  factory CharityRequest.fromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CharityRequest(
      id: doc.id,
      userId: d['userId'] ?? '',
      userName: d['userName'] ?? '',
      firstName: d['firstName'] ?? '',
      lastName: d['lastName'] ?? '',
      fatherName: d['fatherName'] ?? '',
      address: d['address'] ?? '',
      title: d['title'] ?? '',
      description: d['description'] ?? '',
      amountNeeded: (d['amountNeeded'] ?? 0).toDouble(),
      amountReceived: (d['amountReceived'] ?? 0).toDouble(),
      category: d['category'] ?? 'General',
      customCategory: d['customCategory'] ?? '',
      status: d['status'] ?? 'pending',
      contactInfo: d['contactInfo'],
      email: d['email'],
      accountDetails: d['accountDetails'],
      cnicFrontUrl: d['cnicFrontUrl'],
      cnicBackUrl: d['cnicBackUrl'],
      proofImages: List<String>.from(d['proofImages'] ?? []),
      documents: List<String>.from(d['documents'] ?? []),
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  double get progress =>
      amountNeeded > 0 ? (amountReceived / amountNeeded).clamp(0.0, 1.0) : 0.0;
}

// ── Service ───────────────────────────────────────────────────────────────────

class CharityService {
  CharityService._();
  static final CharityService instance = CharityService._();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? '';

  // ── Causes ────────────────────────────────────────────────────────────────

  Stream<List<CharityCause>> watchActiveCauses({String? category}) {
    Query q = _db
        .collection('charity_causes')
        .where('status', isEqualTo: 'active');
    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }
    return q
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(CharityCause.fromDoc).toList());
  }

  Stream<List<CharityCause>> watchMyCauses() {
    if (_uid.isEmpty) return Stream.value([]);
    return _db
        .collection('charity_causes')
        .where('createdBy', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(CharityCause.fromDoc).toList());
  }

  Stream<CharityCause?> watchCause(String causeId) {
    return _db
        .collection('charity_causes')
        .doc(causeId)
        .snapshots()
        .map((d) => d.exists ? CharityCause.fromDoc(d) : null);
  }

  Future<String> createCause({
    required String title,
    required String description,
    required String category,
    required double goal,
    String? imageUrl,
    String? orgName,
    String? bankDetails,
  }) async {
    final ref = _db.collection('charity_causes').doc();
    await ref.set({
      'title': title,
      'description': description,
      'category': category,
      'goal': goal,
      'raised': 0.0,
      'status': 'active',
      'verified': false,
      'createdBy': _uid,
      'imageUrl': imageUrl,
      'orgName': orgName,
      'bankDetails': bankDetails,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  // ── Donations ────────────────────────────────────────────────────────────

  Future<void> donate({
    required String causeId,
    required double amount,
    bool anonymous = false,
    String? message,
    String? screenshotUrl,
  }) async {
    final user = await _db.collection('users').doc(_uid).get();
    final userName = (user.data()?['name'] ?? 'Anonymous') as String;

    await _db.collection('charity_donations').add({
      'causeId': causeId,
      'userId': _uid,
      'userName': userName,
      'amount': amount,
      'anonymous': anonymous,
      'message': message,
      'screenshotUrl': screenshotUrl,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Stream<List<CharityDonation>> watchDonations(String causeId) {
    return _db
        .collection('charity_donations')
        .where('causeId', isEqualTo: causeId)
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(CharityDonation.fromDoc).toList());
  }

  Stream<List<CharityDonation>> watchMyDonations() {
    if (_uid.isEmpty) return Stream.value([]);
    return _db
        .collection('charity_donations')
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(CharityDonation.fromDoc).toList());
  }

  // ── Requests ─────────────────────────────────────────────────────────────

  Stream<List<CharityRequest>> watchRequests({String? category}) {
    Query q = _db
        .collection('charity_requests')
        .where('status', isEqualTo: 'active');
    if (category != null && category != 'All') {
      q = q.where('category', isEqualTo: category);
    }
    return q
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(CharityRequest.fromDoc).toList());
  }

  Stream<List<CharityRequest>> watchMyRequests() {
    if (_uid.isEmpty) return Stream.value([]);
    return _db
        .collection('charity_requests')
        .where('userId', isEqualTo: _uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((s) => s.docs.map(CharityRequest.fromDoc).toList());
  }

  Future<String> createRequest({
    required String title,
    required String description,
    required double amountNeeded,
    required String category,
    String customCategory = '',
    String? contactInfo,
    String? email,
    String? accountDetails,
    String firstName = '',
    String lastName = '',
    String fatherName = '',
    String address = '',
    String? cnicFrontUrl,
    String? cnicBackUrl,
    List<String> proofImages = const [],
    List<String> documents = const [],
  }) async {
    final user = await _db.collection('users').doc(_uid).get();
    final userName = (user.data()?['name'] ?? 'Anonymous') as String;

    final ref = _db.collection('charity_requests').doc();
    await ref.set({
      'userId': _uid,
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'fatherName': fatherName,
      'address': address,
      'title': title,
      'description': description,
      'amountNeeded': amountNeeded,
      'amountReceived': 0.0,
      'category': category,
      'customCategory': customCategory,
      'status': 'active',
      'contactInfo': contactInfo,
      'email': email,
      'accountDetails': accountDetails,
      'cnicFrontUrl': cnicFrontUrl,
      'cnicBackUrl': cnicBackUrl,
      'proofImages': proofImages,
      'documents': documents,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  Future<void> contributeToRequest(String requestId, double amount) async {
    final ref = _db.collection('charity_requests').doc(requestId);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) return;
      final current = (snap.data()?['amountReceived'] ?? 0.0).toDouble();
      tx.update(ref, {'amountReceived': current + amount});
    });
  }

  Future<void> closeRequest(String requestId) async {
    await _db.collection('charity_requests').doc(requestId).update({
      'status': 'closed',
    });
  }

  Future<void> approveRequest(String requestId) async {
    final snap = await _db.collection('charity_requests').doc(requestId).get();
    if (!snap.exists) return;
    final d = snap.data()!;
    await _db.collection('charity_causes').add({
      'title': d['title'] ?? '',
      'description': d['description'] ?? '',
      'category': d['category'] ?? 'General',
      'goal': (d['amountNeeded'] ?? 0).toDouble(),
      'raised': (d['amountReceived'] ?? 0).toDouble(),
      'status': 'active',
      'verified': true,
      'createdBy': d['userId'] ?? '',
      'imageUrl': null,
      'orgName': null,
      'bankDetails': d['accountDetails'],
      'createdAt': FieldValue.serverTimestamp(),
    });
    await _db.collection('charity_requests').doc(requestId).update({
      'status': 'approved',
    });
  }

  Future<void> rejectRequest(String requestId) async {
    await _db.collection('charity_requests').doc(requestId).update({
      'status': 'rejected',
    });
  }

  // ── Stats ────────────────────────────────────────────────────────────────

  Future<Map<String, double>> getStats() async {
    final causesSnap = await _db
        .collection('charity_causes')
        .where('status', isEqualTo: 'active')
        .get();
    final totalRaised = causesSnap.docs.fold<double>(
      0,
      (total, d) => total + ((d.data()['raised'] ?? 0).toDouble()),
    );
    return {
      'totalCauses': causesSnap.docs.length.toDouble(),
      'totalRaised': totalRaised,
    };
  }

  // ── Admin: Watch All ─────────────────────────────────────────────────────

  Stream<QuerySnapshot> watchAllDonations() {
    return _db
        .collection('charity_donations')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> watchAllCauses() {
    return _db
        .collection('charity_causes')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  Stream<QuerySnapshot> watchAllRequests() {
    return _db
        .collection('charity_requests')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

}
