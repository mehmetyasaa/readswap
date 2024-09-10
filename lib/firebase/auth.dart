import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get_core/src/get_main.dart';

class Auth {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final userCollection = FirebaseFirestore.instance.collection("Users");

  User? get currentUser => _firebaseAuth.currentUser;

  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  Future<void> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> createUserWithEmailAndPassword({
    required String email,
    required String password,
    String? username,
    required String phone,
  }) async {
    UserCredential userCredential = await _firebaseAuth
        .createUserWithEmailAndPassword(email: email, password: password);

    // Firestore'a kullanıcıyı ekleme
    await userCollection.doc(userCredential.user!.uid).set({
      'email': email,
      'username': username,
      'registrationDate': FieldValue.serverTimestamp(),
      "phone": phone
      // Diğer gerekli alanlar burada eklenebilir
    });
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  User? getCurrentUser() {
    return _firebaseAuth.currentUser;
  }

  Future<Map<String, dynamic>?> getUserData() async {
    User? user = getCurrentUser();
    if (user != null) {
      try {
        var doc = await userCollection.doc(user.uid).get();
        return doc.data();
      } catch (e) {
        print('Error fetching user data: $e');
      }
    }
    return null;
  }

  Future<void> updateUserData({
    required String username,
    required String phone,
    required String email,
  }) async {
    User? user = getCurrentUser();
    if (user != null) {
      await userCollection.doc(user.uid).update({
        'username': username,
        'phone': phone,
        'email': email,
      });
      await user.updateEmail(email);
    }
  }

  Future<String?> getUsername() async {
    User? user = getCurrentUser();
    if (user != null) {
      try {
        var querySnapshot =
            await userCollection.where('email', isEqualTo: user.email).get();
        if (querySnapshot.docs.isNotEmpty) {
          return querySnapshot.docs.first.data()['username'];
        }
      } catch (e) {
        print('Error fetching username: $e');
      }
    }
    return null;
  }

  Future<void> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    User? user = getCurrentUser();
    if (user != null) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      try {
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(newPassword);
      } catch (e) {
        throw Exception('Şifre güncelleme hatası: $e');
      }
    }
  }
}
