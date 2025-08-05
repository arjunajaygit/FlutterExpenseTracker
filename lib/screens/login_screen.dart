// lib/screens/login_screen.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:expense_tracker/main.dart'; // Import for AppColors
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = AuthController.instance;

  final _emailFormKey = GlobalKey<FormState>();
  final _phoneFormKey = GlobalKey<FormState>();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  String? phoneNumber;

  bool _showPasswordForPhone = false;

  void _loginWithEmail() {
    if (_emailFormKey.currentState!.validate()) {
      authController.loginWithEmail(
          emailController.text.trim(), passwordController.text.trim());
    }
  }

  void _handlePhoneNextOrLogin() async {
    if (!_showPasswordForPhone) {
      if (_phoneFormKey.currentState!.validate()) {
        if (phoneNumber == null || phoneNumber!.isEmpty) return;
        final bool isRegistered =
            await authController.checkIfPhoneIsRegistered(phoneNumber!);
        if (isRegistered) {
          setState(() {
            _showPasswordForPhone = true;
          });
        }
      }
    } else {
      if (_phoneFormKey.currentState!.validate()) {
        if (phoneNumber == null || phoneNumber!.isEmpty) return;
        authController.loginWithPhoneAndPassword(
            phoneNumber!, passwordController.text.trim());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Welcome Back!',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.inter(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Log in to continue your expense journey.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
                  ),
                  const SizedBox(height: 40),
                  DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          indicatorColor: Theme.of(context).primaryColor,
                          labelColor: Theme.of(context).primaryColor,
                          unselectedLabelColor: Theme.of(context).colorScheme.secondary,
                          tabs: const [
                            Tab(text: 'Email'),
                            Tab(text: 'Phone'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // --- THIS IS THE FIX ---
                        // Wrap the TabBarView in a SizedBox to give it a specific height.
                        SizedBox(
                          height: 250, // Adjust this height as needed for your content
                          child: TabBarView(
                            children: [
                              _buildEmailForm(),
                              _buildPhoneForm(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Don't have an account?",
                          style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
                      TextButton(
                        onPressed: () => Get.toNamed('/signup'),
                        child: Text(
                          'Sign Up',
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
      ),
    );
  }

  Widget _buildEmailForm() {
    return Form(
      key: _emailFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
              validator: (val) =>
                  val!.length >= 6 ? null : 'Password is too short'),
          const Spacer(), // Use Spacer to push the button to the bottom
          _buildGradientButton('Login', _loginWithEmail),
        ],
      ),
    );
  }

  Widget _buildPhoneForm() {
    return Form(
      key: _phoneFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntlPhoneField(
            decoration: const InputDecoration(hintText: 'Phone Number'),
            initialCountryCode: 'IN',
            onChanged: (phone) => phoneNumber = phone.completeNumber,
            validator: (phone) =>
                (phone?.number ?? '').isEmpty ? 'Please enter a number' : null,
          ),
          if (_showPasswordForPhone) ...[
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              decoration: const InputDecoration(hintText: 'Password'),
              obscureText: true,
              validator: (val) =>
                  (val?.length ?? 0) < 6 ? 'Password is too short' : null,
            ),
          ],
          const Spacer(), // Use Spacer to push the button to the bottom
          _buildGradientButton(
              _showPasswordForPhone ? 'Login' : 'Next', _handlePhoneNextOrLogin),
        ],
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
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
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}