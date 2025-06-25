import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/phone_auth_controller.dart';

class OTPScreen extends StatefulWidget {
  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)!.settings.arguments as String;
    final phoneAuthController = Provider.of<PhoneAuthController>(context);

    return Scaffold(
      appBar: AppBar(title: Text('Enter OTP')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Text('OTP sent to $phone'),
              TextFormField(
                controller: otpController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Enter 6-digit OTP'),
                maxLength: 6,
                validator: (val) {
                  if (val == null || val.length != 6) return 'Enter 6-digit OTP';
                  if (!RegExp(r'^\d{6}$').hasMatch(val)) return 'OTP must be 6 digits';
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    phoneAuthController.verifyOTP(otpController.text, context);
                  }
                },
                child: Text('Verify'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 