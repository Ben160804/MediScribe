import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersRef => _firestore.collection('users');

  /// Register user with email & password and store user data in Firestore
  Future<User> registerWithEmail({
    required String name,
    required String email,
    required String phone,
    required int age,
    required String password,
  }) async {
    try {
      // Step 1: Create Firebase Auth account
      final UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final User user = cred.user!;
      final String uid = user.uid;

      // Step 2: Create Firestore UserModel
      final UserModel newUser = UserModel(
        id: uid,
        name: name,
        email: email,
        phone: phone,
        age: age,
        labHistory: {}, // Empty map by default
      );

      // Step 3: Store in Firestore at users/{uid}
      await _usersRef.doc(uid).set(newUser.toMap());

      return user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  /// Login user using email & password
  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user!;
    } on FirebaseAuthException catch (e) {
      throw FirebaseAuthException(code: e.code, message: e.message);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  /// Sign out the currently authenticated user
  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Check if a user is already signed in
  User? getCurrentUser() {
    return _auth.currentUser;
  }


 /* /// Fetch user data from Firestore
  Future<UserModel?> fetchUserData(String uid) async {
    final doc = await _usersRef.doc(uid).get();
    if (doc.exists) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic>);
    }
    return null;
  }*/
}
