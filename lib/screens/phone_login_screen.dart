import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import '../controllers/phone_auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class PhoneLoginScreen extends StatefulWidget {
  @override
  State<PhoneLoginScreen> createState() => _PhoneLoginScreenState();
}

class _PhoneLoginScreenState extends State<PhoneLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String? phoneNumber;
  bool isLoading = false;

  Future<bool> _isPhoneNumberRegistered(String phone) async {
    final query = await FirebaseFirestore.instance
        .collection('users')
        .where('phone', isEqualTo: phone)
        .get();
    return query.docs.isNotEmpty;
  }

  void _sendOTP() async {
    if (_formKey.currentState!.validate()) {
      setState(() => isLoading = true);
      final exists = await _isPhoneNumberRegistered(phoneNumber!);
      setState(() => isLoading = false);
      if (!exists) {
        Get.snackbar('Error', 'This phone number is not registered.', snackPosition: SnackPosition.BOTTOM);
        return;
      }
      Provider.of<PhoneAuthController>(context, listen: false)
          .sendOTP(phoneNumber!, context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login with Phone')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
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
              SizedBox(height: 24),
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
            ],
          ),
        ),
      ),
    );
  }
} 