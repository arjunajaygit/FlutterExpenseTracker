import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PhoneAuthController with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  String? _phoneNumber;

  Future<void> sendOTP(String phone, BuildContext context) async {
    _phoneNumber = phone;
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _auth.signInWithCredential(credential);
        await _savePhoneToFirestore();
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
      },
      verificationFailed: (FirebaseAuthException e) {
        Get.snackbar('Error', 'Verification failed: ${e.message}', snackPosition: SnackPosition.BOTTOM);
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        notifyListeners();
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
      },
    );
  }

  Future<void> verifyOTP(String otp, BuildContext context) async {
    if (_verificationId == null) return;
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      await _auth.signInWithCredential(credential);
      await _savePhoneToFirestore();
      Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _savePhoneToFirestore() async {
    final user = _auth.currentUser;
    if (user != null && _phoneNumber != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(
        {'phone': _phoneNumber},
        SetOptions(merge: true),
      );
    }
  }
} 