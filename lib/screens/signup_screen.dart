// lib/screens/signup_screen.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
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

  void _signup() {
    if (_formKey.currentState!.validate()) {
      if (phoneNumber == null || phoneNumber!.isEmpty) {
        Get.snackbar('Error', 'Please enter and validate your phone number.',
            snackPosition: SnackPosition.BOTTOM);
        return;
      }
      authController.signUpWithEmailAndPassword(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        phoneNumber: phoneNumber!,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Use theme-aware color for back button
        leading: BackButton(color: Theme.of(context).primaryColor),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Create Account',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    // THEME-AWARE COLOR
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Let\'s get you started!',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
                ),
                const SizedBox(height: 40),
                TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: 'Full Name'),
                    keyboardType: TextInputType.name,
                    textCapitalization: TextCapitalization.words,
                    validator: (val) =>
                        val!.trim().isEmpty ? 'Please enter your name' : null),
                const SizedBox(height: 16),
                TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(hintText: 'Email Address'),
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) =>
                        GetUtils.isEmail(val!) ? null : 'Enter a valid email'),
                const SizedBox(height: 16),
                TextFormField(
                    controller: passwordController,
                    decoration: const InputDecoration(hintText: 'Password'),
                    obscureText: true,
                    validator: (val) => val!.length >= 6
                        ? null
                        : 'Password must be at least 6 characters'),
                const SizedBox(height: 16),
                IntlPhoneField(
                  decoration: const InputDecoration(hintText: 'Phone Number'),
                  initialCountryCode: 'IN',
                  onChanged: (phone) => phoneNumber = phone.completeNumber,
                  validator: (phone) => (phone?.number ?? '').isEmpty
                      ? 'Please enter your phone number'
                      : null,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _signup,
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.zero,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: Ink(
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Container(
                      height: 55,
                      alignment: Alignment.center,
                      child: const Text(
                        'Sign Up',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Already have an account?",
                        style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                    TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Login',
                        style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}