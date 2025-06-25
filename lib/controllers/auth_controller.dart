// lib/controllers/auth_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:expense_tracker/screens/auth_wrapper.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rxn<User> _firebaseUser = Rxn<User>();
  final Rxn<Map<String, dynamic>> _firestoreUser = Rxn<Map<String, dynamic>>();
  
  // This flag will control the initial loading screen
  final RxBool isInitialized = false.obs;

  User? get user => _firebaseUser.value;
  Map<String, dynamic>? get firestoreUser => _firestoreUser.value;

  @override
  void onReady() {
    super.onReady();
    // Bind the user stream
    _firebaseUser.bindStream(_auth.authStateChanges());
    // Listen for changes to the user to fetch/clear data
    ever(_firebaseUser, _onUserChanged);
  }

  void _onUserChanged(User? firebaseUser) {
    print('AuthController: _onUserChanged called. User: \\${firebaseUser?.uid}');
    if (firebaseUser == null) {
      _firestoreUser.value = null;
      print('AuthController: No user logged in.');
    } else {
      // Fetch user data from Firestore when they log in
      _firestore.collection('users').doc(firebaseUser.uid).get().then((doc) async {
        try {
          final data = doc.data();
          if (doc.exists && data != null && data is Map<String, dynamic>) {
            _firestoreUser.value = data;
            print('AuthController: Firestore user loaded: \\${data}');
          } else {
            print('AuthController: Firestore user doc does not exist or is not a Map. Logging out.');
            _firestoreUser.value = null;
            await _auth.signOut();
            Get.snackbar('Error', 'User data is corrupted. Please sign up again.', snackPosition: SnackPosition.BOTTOM);
          }
        } catch (e) {
          print('AuthController: Firestore fetch/cast error: $e');
          _firestoreUser.value = null;
          await _auth.signOut();
          Get.snackbar('Error', 'Failed to load user data. Please sign in again.', snackPosition: SnackPosition.BOTTOM);
        }
      }).catchError((e) async {
        print('AuthController: Firestore fetch error: $e');
        _firestoreUser.value = null;
        await _auth.signOut();
        Get.snackbar('Error', 'Failed to load user data. Please sign in again.', snackPosition: SnackPosition.BOTTOM);
      });
    }
    // Mark initialization as complete after the first check
    isInitialized.value = true;
  }

  Future<void> signUp(String name, String email, String password) async {
    if (name.trim().isEmpty) {
      Get.snackbar('Sign-up Failed', 'Please enter your name.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        try {
          await _firestore.collection('users').doc(userCredential.user!.uid).set({
            'name': name,
            'email': email,
            'createdAt': Timestamp.now(),
          });
        } catch (e) {
          await userCredential.user!.delete();
          Get.back();
          Get.snackbar('Sign-up Failed', 'Could not save user data. Please try again.', snackPosition: SnackPosition.BOTTOM);
          print('Firestore write failed: $e');
          await _auth.signOut();
          await Future.delayed(const Duration(milliseconds: 700));
          Get.offAll(() => const AuthWrapper(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 400));
          return;
        }
      }
      await _auth.signOut();
      Get.back();
      Get.snackbar('Success', 'Account created successfully. Please log in.', snackPosition: SnackPosition.BOTTOM);
      await Future.delayed(const Duration(milliseconds: 700));
      Get.offAll(() => const AuthWrapper(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 400));
    } on FirebaseAuthException catch (e) {
      Get.back();
      Get.snackbar('Sign-up Failed', e.message ?? 'An auth error occurred.', snackPosition: SnackPosition.BOTTOM);
      print('SIGN UP ERROR: $e');
      await _auth.signOut();
      await Future.delayed(const Duration(milliseconds: 700));
      Get.offAll(() => const AuthWrapper(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 400));
    } catch (e) {
      Get.back();
      Get.snackbar('Sign-up Failed', 'An unexpected error occurred.', snackPosition: SnackPosition.BOTTOM);
      print("SIGN UP ERROR: $e");
      await _auth.signOut();
      await Future.delayed(const Duration(milliseconds: 700));
      Get.offAll(() => const AuthWrapper(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 400));
    }
  }

  Future<void> login(String email, String password) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      await Future.delayed(const Duration(milliseconds: 400));
      Get.back(); // dismiss loading
    } on FirebaseAuthException catch (e) {
      Get.back();
      Get.snackbar('Login Failed', e.message ?? 'An unknown error occurred.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async {
    Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
    await _auth.signOut();
    await Future.delayed(const Duration(milliseconds: 400));
    Get.back(); // dismiss loading
    Get.offAll(() => const AuthWrapper(), transition: Transition.fadeIn, duration: const Duration(milliseconds: 400));
  }
}