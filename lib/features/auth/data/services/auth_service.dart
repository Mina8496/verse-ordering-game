import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _googleSignIn = googleSignIn ?? GoogleSignIn();

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  User? get currentUser => _auth.currentUser;

  Future<User?> signInWithGoogle({bool ensureProfile = true}) async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final User? user = (await _auth.signInWithCredential(credential)).user;

      if (user != null && ensureProfile) await ensureUserProfile(user);
      return user;
    } catch (error) {
      print('Google Sign-In Error: $error');
      return null;
    }
  }

  Future<User?> registerWithEmail(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = credential.user;

      if (user != null) {
        await _firestore.collection('users').doc(user.uid).set({
          'email': user.email,
          'role': 'User',
          'status': 'pending',
        });
      }
      return user;
    } on FirebaseAuthException {
      rethrow;
    }
  }

  Future<User?> createUserWithProfile({
    required String email,
    required String password,
    required Map<String, dynamic> profile,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user != null) {
      await _firestore.collection('users').doc(user.uid).set(profile);
    }
    return user;
  }

  Future<User?> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return credential.user;
  }

  Future<Map<String, dynamic>?> getUserProfile(User user) async {
    final document = await _firestore.collection('users').doc(user.uid).get();
    return document.data();
  }

  Future<void> ensureUserProfile(User user) async {
    final reference = _firestore.collection('users').doc(user.uid);
    final document = await reference.get();
    if (document.exists) return;

    await reference.set({
      'email': user.email,
      'name': user.displayName ?? '',
      'role': 'User',
      'status': 'pending',
    });
  }

  Future<void> createBasicUserProfile(User user) async {
    await _firestore.collection('users').doc(user.uid).set({
      'email': user.email,
      'name': user.displayName ?? '',
      'role': 'User',
    });
  }

  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }

  Future<String?> getUserRole(User user) async {
    final userDoc = await _firestore.collection('users').doc(user.uid).get();
    return userDoc.exists ? userDoc['role'] as String? : null;
  }
}
