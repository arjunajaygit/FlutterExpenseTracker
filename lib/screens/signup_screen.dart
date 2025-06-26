// lib/screens/signup_screen.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final AuthController authController = AuthController.instance;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? phoneNumber;
  bool isLoading = false;

  void _signup() {
    if (_formKey.currentState!.validate()) {
      if (phoneNumber == null || phoneNumber!.isEmpty) {
        Get.snackbar('Error', 'Please enter and validate your phone number.', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      authController.signUpAndInitiatePhoneVerification(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        phoneNumber: phoneNumber!,
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign Up')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text('Create an Account', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text('Start tracking your expenses today!', style: Theme.of(context).textTheme.titleMedium, textAlign: TextAlign.center),
              const SizedBox(height: 32),
              TextFormField(controller: nameController, decoration: const InputDecoration(labelText: 'Name'), keyboardType: TextInputType.name, textCapitalization: TextCapitalization.words, validator: (val) => val!.trim().isEmpty ? 'Please enter your name' : null),
              const SizedBox(height: 16),
              TextFormField(controller: emailController, decoration: const InputDecoration(labelText: 'Email'), keyboardType: TextInputType.emailAddress, validator: (val) => GetUtils.isEmail(val!) ? null : 'Enter a valid email'),
              const SizedBox(height: 16),
              TextFormField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true, validator: (val) => val!.length >= 6 ? null : 'Password must be at least 6 characters'),
              const SizedBox(height: 16),
              IntlPhoneField(
                decoration: const InputDecoration(labelText: 'Phone Number'),
                initialCountryCode: 'IN',
                onChanged: (phone) => phoneNumber = phone.completeNumber,
                validator: (phone) => (phone?.number ?? '').isEmpty ? 'Please enter your phone number' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _signup, child: const Text('Sign Up & Verify Phone')),
              TextButton(onPressed: () => Get.back(), child: const Text('Already have an account? Login')),
            ],
          ),
        ),
      ),
    );
  }
}