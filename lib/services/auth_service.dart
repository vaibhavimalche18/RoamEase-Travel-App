import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// SIGNUP
  Future<String?> signUp(
      String name, String email, String password, String username) async {
    try {
      // Check if username is already taken
      final existing = await FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: username.toLowerCase())
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        return 'Username "${username}" is already taken. Try another.';
      }

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      /// 🔥 SAVE USER DATA
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({
        'name': name,
        'email': email,
        'username': username.toLowerCase(), // always stored lowercase
      });

      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }

  /// LOGIN
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    }
  }
}