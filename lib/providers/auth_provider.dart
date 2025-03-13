import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user.dart' as app_user;

class AuthProvider with ChangeNotifier {
  final firebase.FirebaseAuth _auth = firebase.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  app_user.User? user;
  String? user_role;
  String? name;
  String? email;
  String? role;
  String? photoUrl;

  Future<void> register(String email, String password, String name) async {
    final firebase.UserCredential result = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);

    user = app_user.User(
      id: result.user!.uid,
      name: name,
      email: email,
      role: 'user',
      photoUrl: '',
    );

    await _firestore.collection('users').doc(result.user!.uid).set({
      'name': name,
      'email': email,
      'role': 'user',
    });

    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    try {
      final firebase.UserCredential result = await _auth
          .signInWithEmailAndPassword(email: email, password: password);

      final userDoc =
          await _firestore.collection('users').doc(result.user!.uid).get();
      String userRole = 'user';
      String userName = result.user!.displayName ?? 'User';

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        userRole = userData['role'] ?? 'user';
        userName = userData['name'] ?? userName;
      }

      user = app_user.User(
        id: result.user!.uid,
        name: userName,
        email: email,
        role: userRole,
        photoUrl: '',
      );

      notifyListeners();
    } catch (e) {
      print("Login error: $e");
    }
  }

  Future<void> googleLogin() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print("User canceled the sign-in.");
        return; // User canceled the sign-in
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebase.UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      // Check if user already exists in Firestore
      final userDoc =
          await _firestore.collection('users').doc(result.user!.uid).get();
      String userRole = 'user'; // Default role

      if (!userDoc.exists) {
        print("User does not exist in Firestore. Creating new user...");
        // Save user to Firestore if not exists
        await _firestore.collection('users').doc(result.user!.uid).set({
          'name': result.user!.displayName ?? 'User',
          'email': result.user!.email,
          'role': userRole, // Default role is 'user'
        });
        print("User created successfully in Firestore.");
      } else {
        print("User already exists in Firestore.");
        // Fetch existing user details
        userRole =
            userDoc.data()!['role'] ??
            'user'; // Get role from Firestore if exists
      }

      // Store user details including role
      user = app_user.User(
        id: result.user!.uid,
        name: result.user!.displayName ?? 'User',
        email: result.user!.email!,
        role: userRole,
        photoUrl: result.user!.photoURL!,
        // Use the fetched role
      );

      print("User login successful: ${user!.email}, Role: ${user!.role}");
      notifyListeners();
    } catch (e) {
      print("Google Sign-In error: $e");
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
    user = null;
    notifyListeners();
  }
}
