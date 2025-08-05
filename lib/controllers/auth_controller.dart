// lib/controllers/auth_controller.dart
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expense_tracker/screens/auth_wrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:expense_tracker/controllers/navigation_controller.dart';
import 'package:image_picker/image_picker.dart';

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

  void _showSnackbar(String title, String message) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      duration: const Duration(milliseconds: 2000),
      margin: const EdgeInsets.all(12),
      borderRadius: 10,
    );
  }

  void _onUserChanged(User? user) {
    if (user == null) {
      firestoreUser.value = null;
      isInitialized.value = true;
    } else {
      _fetchFirestoreUserData(user);
    }
  }

  Future<void> _fetchFirestoreUserData(User user) async {
    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data() != null) {
        firestoreUser.value = doc.data()!;
      } else {
        await user.delete();
        _showSnackbar('Error', 'User data is corrupted. Account cleaned up.');
      }
    } on FirebaseException catch (e) {
      _showSnackbar('Error', 'Failed to load user data: ${e.message}');
      await logout();
    } finally {
      isInitialized.value = true;
    }
  }

  // --- ACCOUNT MANAGEMENT ---

  void showImageSourceActionSheet() {
    Get.bottomSheet(
      SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
      backgroundColor: Get.theme.cardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: source, imageQuality: 50);

    if (image != null) {
      await _uploadProfilePicture(image);
    }
  }

  Future<void> _uploadProfilePicture(XFile imageFile) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      final storageRef = FirebaseStorage.instance.ref();
      final imageRef = storageRef.child('profile_pictures/${user.uid}');

      final uploadTask = await imageRef.putFile(File(imageFile.path));
      final downloadUrl = await uploadTask.ref.getDownloadURL();

      await _firestore.collection('users').doc(user.uid).update({
        'profilePictureUrl': downloadUrl,
      });

      // Manually refresh the local user data to update the UI instantly
      firestoreUser.value?['profilePictureUrl'] = downloadUrl;
      firestoreUser.refresh();

      if (Get.isDialogOpen ?? false) Get.back();
      _showSnackbar('Success', 'Profile picture updated!');
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      _showSnackbar('Error', 'Failed to upload picture: $e');
    }
  }

  Future<void> updateUserName(String newName) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final user = _auth.currentUser;
      if (user == null) throw 'No user logged in';

      await _firestore.collection('users').doc(user.uid).update({'name': newName});

      // Manually refresh local data
      firestoreUser.value?['name'] = newName;
      firestoreUser.refresh();

      if (Get.isDialogOpen ?? false) Get.back();
      _showSnackbar('Success', 'Name updated successfully!');
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      _showSnackbar('Error', 'Failed to update name: $e');
    }
  }

  Future<void> updateUserPassword(String currentPassword, String newPassword) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final user = _auth.currentUser;
      if (user == null || user.email == null) throw 'No user logged in';

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);
      await user.updatePassword(newPassword);

      if (Get.isDialogOpen ?? false) Get.back();
      Get.back(); 
      _showSnackbar('Success', 'Password updated successfully!');

    } on FirebaseAuthException catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      if (e.code == 'wrong-password' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
        _showSnackbar('Error', 'Incorrect current password provided.');
      } else if (e.code == 'weak-password') {
        _showSnackbar('Error', 'The new password is too weak.');
      } else {
        _showSnackbar('Error', 'An error occurred: ${e.message}');
      }
    }
  }

  // --- AUTHENTICATION ---
  
  Future<void> signUpWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phoneNumber,
  }) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final emailQuery = await _firestore.collection('users').where('email', isEqualTo: email).limit(1).get();
      if (emailQuery.docs.isNotEmpty) throw 'This email address is already registered.';
      
      final phoneQuery = await _firestore.collection('users').where('phone', isEqualTo: phoneNumber).limit(1).get();
      if (phoneQuery.docs.isNotEmpty) throw 'This phone number is already registered.';
      
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? newUser = userCredential.user;
      if (newUser == null) throw 'Account creation failed unexpectedly.';

      await _firestore.collection('users').doc(newUser.uid).set({
        'name': name, 'email': email, 'phone': phoneNumber, 'createdAt': Timestamp.now(),
        'profilePictureUrl': null, // Initialize profile picture field
      });
      Get.offAll(() => const AuthWrapper());
      Future.delayed(const Duration(milliseconds: 400), () {
        _showSnackbar('Success', 'Account created successfully!');
      });
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      String errorMessage = e is FirebaseException ? e.message ?? e.toString() : e.toString();
      _showSnackbar('Sign-up Failed', errorMessage);
    }
  }

  Future<void> loginWithEmail(String email, String password) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAll(() => const AuthWrapper());
    } on FirebaseException catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      _showSnackbar('Login Failed', e.message ?? 'An unknown error occurred.');
    }
  }

  Future<bool> checkIfPhoneIsRegistered(String phoneNumber) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final querySnapshot = await _firestore.collection('users').where('phone', isEqualTo: phoneNumber).limit(1).get();
      if (Get.isDialogOpen ?? false) Get.back();
      if (querySnapshot.docs.isNotEmpty) return true;
      else {
        _showSnackbar('Error', 'This phone number is not registered.');
        return false;
      }
    } catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      _showSnackbar('Error', 'An unexpected error occurred.');
      return false;
    }
  }

  Future<void> loginWithPhoneAndPassword(String phoneNumber, String password) async {
    try {
      Get.dialog(const Center(child: CircularProgressIndicator()), barrierDismissible: false);
      final querySnapshot = await _firestore.collection('users').where('phone', isEqualTo: phoneNumber).limit(1).get();
      if (querySnapshot.docs.isEmpty) throw FirebaseAuthException(code: 'user-not-found');
      
      final String email = querySnapshot.docs.first.data()['email'];
      
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAll(() => const AuthWrapper());
    } on FirebaseException catch (e) {
      if (Get.isDialogOpen ?? false) Get.back();
      if (e.code == 'user-not-found') {
        _showSnackbar('Login Failed', 'This phone number is not registered.');
      } else if (e.code == 'wrong-password' || e.code == 'INVALID_LOGIN_CREDENTIALS') {
        _showSnackbar('Login Failed', 'Incorrect password. Please try again.');
      } else {
        _showSnackbar('Login Failed', e.message ?? 'An unknown error occurred.');
      }
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