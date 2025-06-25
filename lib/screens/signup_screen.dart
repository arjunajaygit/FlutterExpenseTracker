// lib/screens/signup_screen.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignupScreen extends StatefulWidget {
  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController authController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? phoneNumber;
  bool isLoading = false;

  Future<bool> _isPhoneNumberUsed(String phone) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> _signup() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      if (phoneNumber != null && phoneNumber!.isNotEmpty) {
        final exists = await _isPhoneNumberUsed(phoneNumber!);
        if (exists) {
          setState(() => isLoading = false);
          Get.snackbar('Error', 'This phone number is already registered.', snackPosition: SnackPosition.BOTTOM);
          return;
        }
      }
      final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      // Save phone to Firestore
      if (phoneNumber != null && phoneNumber!.isNotEmpty) {
        await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set(
          {
            'phone': phoneNumber,
            'name': nameController.text.trim(),
          },
          SetOptions(merge: true),
        );
      }
      setState(() => isLoading = false);
      Get.snackbar('Success', 'Signup successful! Please login.', snackPosition: SnackPosition.BOTTOM);
      await FirebaseAuth.instance.signOut();
      Navigator.of(context).pop(); // Go back to login
    } on FirebaseAuthException catch (e) {
      setState(() => isLoading = false);
      Get.snackbar('Signup Failed', e.message ?? 'Signup failed', snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        // This makes sure the back button goes to the previous screen (LoginScreen)
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Get.back(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 60),
              Text(
                'Create an Account',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              Text(
                'Start tracking your expenses today!',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              // Name Field
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                    labelText: 'Name', border: OutlineInputBorder()),
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
              ),
              const SizedBox(height: 16),
              // Email Field
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(
                    labelText: 'Email', border: OutlineInputBorder()),
                keyboardType: TextInputType.emailAddress,
                validator: (val) => val != null && val.contains('@') ? null : 'Enter a valid email',
              ),
              const SizedBox(height: 16),
              // Password Field
              TextFormField(
                controller: passwordController,
                decoration: const InputDecoration(
                    labelText: 'Password (min. 6 characters)',
                    border: OutlineInputBorder()),
                obscureText: true,
                validator: (val) => val != null && val.length >= 6 ? null : 'Password must be at least 6 characters',
              ),
              const SizedBox(height: 16),
              IntlPhoneField(
                decoration: InputDecoration(labelText: 'Phone Number'),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  phoneNumber = phone.completeNumber;
                },
                validator: (phone) {
                  if (phone == null || phone.number.isEmpty) return 'Enter phone number';
                  if (!RegExp(r'^\+\d{1,3}\s?\d{6,14}$').hasMatch(phone.completeNumber)) {
                    return 'Enter valid phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _signup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  child: isLoading
                      ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Sign Up'),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed('/login'),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}