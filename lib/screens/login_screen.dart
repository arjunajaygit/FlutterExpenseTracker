import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../controllers/phone_auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum LoginMethod { email, phone }

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController authController = Get.find();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController otpController = TextEditingController();
  String? phoneNumber;
  bool otpSent = false;
  bool isLoading = false;
  LoginMethod _loginMethod = LoginMethod.email;

  Future<bool> _isPhoneNumberRegistered(String phone) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .get();
    return query.docs.isNotEmpty;
  }

  Future<void> _loginWithEmail() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => isLoading = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      Navigator.of(context).pushReplacementNamed('/home');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Failed', e.message ?? 'Login failed', snackPosition: SnackPosition.BOTTOM);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _sendOTP() async {
    if (phoneNumber == null || phoneNumber!.isEmpty) {
      Get.snackbar('Error', 'Enter a valid phone number', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    setState(() => isLoading = true);
    final exists = await _isPhoneNumberRegistered(phoneNumber!);
    if (!exists) {
      setState(() => isLoading = false);
      Get.snackbar('Error', 'This phone number is not registered.', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    await Provider.of<PhoneAuthController>(context, listen: false)
        .sendOTP(phoneNumber!, context);
    setState(() {
      otpSent = true;
      isLoading = false;
    });
  }

  Future<void> _verifyOTP() async {
    if (otpController.text.length != 6) {
      Get.snackbar('Error', 'Enter a valid 6-digit OTP', snackPosition: SnackPosition.BOTTOM);
      return;
    }
    setState(() => isLoading = true);
    await Provider.of<PhoneAuthController>(context, listen: false)
        .verifyOTP(otpController.text, context);
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 40),
            Text(
              'Welcome Back!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            Text(
              'Log in to your account',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            // Toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Radio<LoginMethod>(
                  value: LoginMethod.email,
                  groupValue: _loginMethod,
                  onChanged: (val) {
                    setState(() {
                      _loginMethod = val!;
                      otpSent = false;
                    });
                  },
                ),
                const Text('Email'),
                const SizedBox(width: 24),
                Radio<LoginMethod>(
                  value: LoginMethod.phone,
                  groupValue: _loginMethod,
                  onChanged: (val) {
                    setState(() {
                      _loginMethod = val!;
                      otpSent = false;
                    });
                  },
                ),
                const Text('Phone Number'),
              ],
            ),
            const SizedBox(height: 16),
            if (_loginMethod == LoginMethod.email)
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                      keyboardType: TextInputType.emailAddress,
                      validator: (val) => val != null && val.contains('@') ? null : 'Enter a valid email',
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: passwordController,
                      decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                      obscureText: true,
                      validator: (val) => val != null && val.length >= 6 ? null : 'Password must be at least 6 characters',
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _loginWithEmail,
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
                            : const Text('Login'),
                      ),
                    ),
                  ],
                ),
              ),
            if (_loginMethod == LoginMethod.phone)
              Column(
                children: [
                  IntlPhoneField(
                    decoration: const InputDecoration(labelText: 'Phone Number'),
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
                  if (!otpSent)
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _sendOTP,
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
                            : const Text('Send OTP'),
                      ),
                    ),
                  if (otpSent) ...[
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: otpController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Enter 6-digit OTP', border: OutlineInputBorder()),
                      maxLength: 6,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : _verifyOTP,
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
                            : const Text('Verify OTP'),
                      ),
                    ),
                  ],
                ],
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => Get.toNamed('/signup'),
              child: const Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}