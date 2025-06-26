// lib/controllers/auth_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/screens/auth_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart'; // <<<--- THIS IS THE CORRECTED IMPORT
import 'package:expense_tracker/screens/otp_screen.dart';

class AuthController extends GetxController {
  static AuthController get instance => Get.find();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final Rxn<User> firebaseUser = Rxn<User>();
  final Rxn<Map<String, dynamic>> firestoreUser = Rxn<Map<String, dynamic>>();
  final RxBool isInitialized = false.obs;
  final Rxn<String> verificationId = Rxn<String>();

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

  Future<void> signUpAndInitiatePhoneVerification({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    User? newUser;
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);

      final phoneQuery = await _firestore.collection('users').where('phone', isEqualTo: phoneNumber).limit(1).get();
      if (phoneQuery.docs.isNotEmpty) {
        throw 'This phone number is already registered.';
      }
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      newUser = userCredential.user;
      if (newUser == null) throw 'Account creation failed unexpectedly.';

      await _firestore.collection('users').doc(newUser.uid).set({
        'name': name, 'email': email, 'phone': phoneNumber, 'createdAt': Timestamp.now(),
      });
      
      await _auth.signOut(); 
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _auth.signInWithEmailAndPassword(email: email, password: password);
          await _auth.currentUser!.linkWithCredential(credential);
          Get.offAll(() => const AuthWrapper());
        },
        verificationFailed: (e) {
          throw FirebaseAuthException(code: 'phone-verification-failed', message: e.message);
        },
        codeSent: (verId, token) {
          verificationId.value = verId;
          Get.back();
          Get.to(() => OTPScreen(), arguments: {'isLinking': true, 'email': email, 'password': password});
        },
        codeAutoRetrievalTimeout: (verId) {
          verificationId.value = verId;
        },
      );
    } catch (e) {
      if (newUser != null) {
        await newUser.delete().catchError((error) {
          print("Failed to delete orphaned user: $error");
        });
      }
      Get.back();
      String errorMessage = e is FirebaseException ? e.message ?? e.toString() : e.toString();
      Get.snackbar('Sign-up Failed', errorMessage, snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  Future<void> verifyOtpAndLink({required String otp, required String email, required String password}) async {
    if (verificationId.value == null) { Get.snackbar('Error', 'Verification expired.', snackPosition: SnackPosition.BOTTOM); return; }
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId.value!, smsCode: otp);
      await _auth.currentUser!.linkWithCredential(credential);
      Get.offAll(() => const AuthWrapper());
      Future.delayed(const Duration(milliseconds: 400), () {
        Get.snackbar('Success', 'Account created successfully!', snackPosition: SnackPosition.BOTTOM);
      });
    } on FirebaseException catch (e) {
      Get.back();
      await _auth.signOut();
      Get.snackbar('Error', e.message ?? 'Invalid OTP or linking failed.', snackPosition: SnackPosition.BOTTOM);
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

  Future<void> sendOtpForLogin(String phoneNumber) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final phoneQuery = await _firestore.collection('users').where('phone', isEqualTo: phoneNumber).limit(1).get();
      if (phoneQuery.docs.isEmpty) {
        Get.back();
        Get.snackbar('Error', 'This phone number is not registered.', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async { 
          await _auth.signInWithCredential(credential); 
          Get.offAll(() => const AuthWrapper());
        },
        verificationFailed: (e) { Get.back(); Get.snackbar('Error', 'Phone verification failed: ${e.message}', snackPosition: SnackPosition.BOTTOM); },
        codeSent: (verId, token) { verificationId.value = verId; Get.back(); Get.to(() => OTPScreen(), arguments: {'isLinking': false}); },
        codeAutoRetrievalTimeout: (verId) { verificationId.value = verId; },
      );
    } catch (e) {
      Get.back();
      Get.snackbar('Error', 'An unexpected error occurred.', snackPosition: SnackPosition.BOTTOM);
    }
  }
  
  Future<void> verifyOtpAndLogin(String otp) async {
    if (verificationId.value == null) { Get.snackbar('Error', 'Verification expired.', snackPosition: SnackPosition.BOTTOM); return; }
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      PhoneAuthCredential credential = PhoneAuthProvider.credential(verificationId: verificationId.value!, smsCode: otp);
      await _auth.signInWithCredential(credential);
      Get.offAll(() => const AuthWrapper()); 
      Future.delayed(const Duration(milliseconds: 400), () {
        Get.snackbar('Success', 'Logged in successfully!', snackPosition: SnackPosition.BOTTOM);
      });
    } on FirebaseException catch (e) {
      Get.back(); 
      Get.snackbar('Error', e.message ?? 'Invalid OTP or login failed.', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async => await _auth.signOut();
}