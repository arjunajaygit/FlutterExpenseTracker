// lib/screens/otp_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';

class OTPScreen extends StatefulWidget {
  const OTPScreen({super.key});

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthController authController = AuthController.instance;

  // Get the entire arguments map once.
  final Map<String, dynamic> args = Get.arguments;

  @override
  Widget build(BuildContext context) {
    // Determine the mode (linking or logging in) from the arguments.
    final bool isLinking = args['isLinking'] ?? false;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isLinking ? 'Link Your Phone' : 'Enter OTP'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'An OTP has been sent to your phone number.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter 6-digit OTP',
                ),
                maxLength: 6,
                validator: (val) {
                  if (val == null || val.length != 6) return 'Enter a valid 6-digit OTP';
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    final otp = otpController.text.trim();
                    if (isLinking) {
                      // *** THE FIX IS HERE ***
                      // We now pass all the required named arguments.
                      authController.verifyOtpAndLink(
                        otp: otp,
                        email: args['email'],     // Get email from arguments
                        password: args['password'], // Get password from arguments
                      );
                    } else {
                      // This call was already correct.
                      authController.verifyOtpAndLogin(otp);
                    }
                  }
                },
                child: const Text('Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}