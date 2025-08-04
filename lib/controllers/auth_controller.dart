// lib/controllers/auth_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/screens/auth_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/controllers/navigation_controller.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rxn<User> firebaseUser = Rxn<User>();
  final Rxn<Map<String, dynamic>> firestoreUser = Rxn<Map<String, dynamic>>();
  final RxBool isInitialized = false.obs;

  @override
  void onInit() {
    super.onInit();
    firebaseUser.bindStream(_auth.authStateChanges());
    ever(firebaseUser, _onUserChanged);
  }

  void _onUserChanged(User? user) {
    if (user == null) {
      firestoreUser.value = null;
      isInitialized.value = true;
    } else {
      Future.delayed(const Duration(milliseconds: 300), () {
        _fetchFirestoreUserData(user);
      });
    }
  }

  Future<void> _fetchFirestoreUserData(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        firestoreUser.value = doc.data()!;
      } else {
        await user.delete();
        Get.snackbar('Error', 'User data is corrupted. Account has been cleaned up.', snackPosition: SnackPosition.BOTTOM);
      }
    } on FirebaseException catch (e) {
      if (e.code == 'permission-denied') {
        Get.snackbar('Error', 'Session error. Please log in again.', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Error', 'Failed to load user data: ${e.message}', snackPosition: SnackPosition.BOTTOM);
      }
      await logout();
    } finally {
      isInitialized.value = true;
    }
  }

  Future<void> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final emailQuery = await _firestore.collection('users').where('email', isEqualTo: email).limit(1).get();
      if (emailQuery.docs.isNotEmpty) {
        throw 'This email address is already registered.';
      }
      final phoneQuery = await _firestore.collection('users').where('phone', isEqualTo: phoneNumber).limit(1).get();
      if (phoneQuery.docs.isNotEmpty) {
        throw 'This phone number is already registered.';
      }
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? newUser = userCredential.user;
      if (newUser == null) throw 'Account creation failed unexpectedly.';
      await _firestore.collection('users').doc(newUser.uid).set({
        'name': name,
        'email': email,
        'phone': phoneNumber,
        'createdAt': Timestamp.now(),
      });
      Get.offAll(() => const AuthWrapper());
      Future.delayed(const Duration(milliseconds: 400), () {
        Get.snackbar('Success', 'Account created successfully!', snackPosition: SnackPosition.BOTTOM);
      });
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      String errorMessage = e is FirebaseException ? e.message ?? e.toString() : e.toString();
      Get.snackbar('Sign-up Failed', errorMessage, snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAll(() => const AuthWrapper());
    } on FirebaseException catch (e) {
      Get.back();
      Get.snackbar('Login Failed', e.message ?? 'An unknown error occurred.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  // --- NEW METHOD TO CHECK IF PHONE NUMBER IS REGISTERED ---
  Future<bool> checkIfPhoneIsRegistered(String phoneNumber) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final querySnapshot = await _firestore.collection('users').where('phone', isEqualTo: phoneNumber).limit(1).get();
      if (Get.isDialogOpen ?? false) Get.back(); // Close the dialog

      if (querySnapshot.docs.isNotEmpty) {
        return true; // Phone number exists
      } else {
        // Show error message and return false
        Get.snackbar('Error', 'This phone number is not registered.', snackPosition: SnackPosition.BOTTOM);
        return false;
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      Get.snackbar('Error', 'An unexpected error occurred.', snackPosition: SnackPosition.BOTTOM);
      return false;
    }
  }

  Future<void> loginWithPhoneAndPassword(String phoneNumber, String password) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final querySnapshot = await _firestore.collection('users').where('phone', isEqualTo: phoneNumber).limit(1).get();
      if (querySnapshot.docs.isEmpty) {
        Get.back();
        Get.snackbar('Login Failed', 'This phone number is not registered.', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      final userData = querySnapshot.docs.first.data();
      final String email = userData['email'];
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAll(() => const AuthWrapper());
    } on FirebaseException catch (e) {
      Get.back();
      if (e.code == 'wrong-password' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
        Get.snackbar('Login Failed', 'Incorrect password. Please try again.', snackPosition: SnackPosition.BOTTOM);
      } else {
        Get.snackbar('Login Failed', e.message ?? 'An unknown error occurred.', snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.back();
      Get.snackbar('Login Failed', 'An unexpected error occurred.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async {
    if (Get.isRegistered<NavigationController>()) {
      final navController = Get.find<NavigationController>();
      navController.changePage(0);
    }
    await _auth.signOut();
  }
}