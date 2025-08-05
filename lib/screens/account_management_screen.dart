// lib/screens/account_management_screen.dart
import 'package:expense_tracker/controllers/auth_controller.dart';
import 'package:expense_tracker/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AccountManagementScreen extends StatefulWidget {
  const AccountManagementScreen({super.key});

  @override
  State<AccountManagementScreen> createState() => _AccountManagementScreenState();
}

class _AccountManagementScreenState extends State<AccountManagementScreen> {
  final AuthController authController = Get.find();
  
  // For changing name
  final _nameFormKey = GlobalKey<FormState>();
  late final TextEditingController nameController;

  // For changing password
  final _passwordFormKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: authController.firestoreUser.value?['name'] ?? '');
  }

  @override
  void dispose() {
    nameController.dispose();
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  void _updateName() {
    if (_nameFormKey.currentState!.validate()) {
      authController.updateUserName(nameController.text.trim());
    }
  }

  void _updatePassword() {
    if (_passwordFormKey.currentState!.validate()) {
      authController.updateUserPassword(
        currentPasswordController.text.trim(),
        newPasswordController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- Change Name Section ---
            Text('Change Your Name', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Form(
              key: _nameFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(hintText: 'Full Name'),
                    validator: (value) => value!.trim().isEmpty ? 'Name cannot be empty' : null,
                  ),
                  const SizedBox(height: 16),
                  _buildGradientButton('Save Name', _updateName),
                ],
              ),
            ),

            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),

            // --- Change Password Section ---
            Text('Change Your Password', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Form(
              key: _passwordFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: currentPasswordController,
                    decoration: const InputDecoration(hintText: 'Current Password'),
                    obscureText: true,
                    validator: (value) => value!.isEmpty ? 'Please enter your current password' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: newPasswordController,
                    decoration: const InputDecoration(hintText: 'New Password'),
                    obscureText: true,
                    validator: (value) => (value?.length ?? 0) < 6 ? 'Password must be at least 6 characters' : null,
                  ),
                  const SizedBox(height: 16),
                   TextFormField(
                    controller: confirmPasswordController,
                    decoration: const InputDecoration(hintText: 'Confirm New Password'),
                    obscureText: true,
                    validator: (value) {
                      if (value != newPasswordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  _buildGradientButton('Update Password', _updatePassword),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.transparent,
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