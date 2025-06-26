// lib/screens/login_screen.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

enum LoginMethod { email, phone }

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = AuthController.instance;
  LoginMethod _loginMethod = LoginMethod.email;

  // Form keys
  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  // Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? phoneNumber;

  void _loginWithEmail() {
    if (_emailFormKey.currentState!.validate()) {
      authController.loginWithEmail(
          emailController.text.trim(), passwordController.text);
    }
  }

  void _sendOTP() {
    if (_phoneFormKey.currentState!.validate()) {
      if (phoneNumber == null || phoneNumber!.isEmpty) return;
      authController.sendOtpForLogin(phoneNumber!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Text('Welcome Back!', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            const SizedBox(height: 8),
            Text('Log in to your account', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SegmentedButton<LoginMethod>(
              segments: const <ButtonSegment<LoginMethod>>[
                ButtonSegment<LoginMethod>(value: LoginMethod.email, label: Text('Email'), icon: Icon(Icons.email)),
                ButtonSegment<LoginMethod>(value: LoginMethod.phone, label: Text('Phone'), icon: Icon(Icons.phone)),
              ],
              selected: {_loginMethod},
              onSelectionChanged: (Set<LoginMethod> newSelection) {
                setState(() => _loginMethod = newSelection.first);
              },
            ),
            const SizedBox(height: 24),

            // Show widgets based on selected login method
            if (_loginMethod == LoginMethod.email) _buildEmailForm(),
            if (_loginMethod == LoginMethod.phone) _buildPhoneForm(),
            
            const SizedBox(height: 16),
            TextButton(onPressed: () => Get.toNamed('/signup'), child: const Text("Don't have an account? Sign Up")),
          ],
        ),
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _emailFormKey,
      child: Column(
        children: [
          TextFormField(controller: emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (val) => GetUtils.isEmail(val!) ? null : 'Enter a valid email'),
          const SizedBox(height: 16),
          TextFormField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true, validator: (val) => val!.length >= 6 ? null : 'Password is too short'),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _loginWithEmail, child: const Text('Login')),
        ],
      ),
    );
  }

  Widget _buildPhoneForm() {
    return Form(
      key: _phoneFormKey,
      child: Column(
        children: [
          IntlPhoneField(
            decoration: const InputDecoration(labelText: 'Phone Number'),
            initialCountryCode: 'IN',
            onChanged: (phone) => phoneNumber = phone.completeNumber,
            validator: (phone) => (phone?.number ?? '').isEmpty ? 'Please enter your phone number' : null,
          ),
          const SizedBox(height: 24),
          ElevatedButton(onPressed: _sendOTP, child: const Text('Send OTP')),
        ],
      ),
    );
  }
}