
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final formKey = GlobalKey<FormState>(); // Form key for validation

  // Controllers for input fields
  final TextEditingController _firstName = TextEditingController();
  final TextEditingController _lastName = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  // Regular expressions for email and password validation
  final RegExp emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
  final RegExp passwordRegex =
      RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{6,}$');

  // Clean up controllers when widget is disposed
  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Validates the password input
  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password';
    if (!passwordRegex.hasMatch(value)) {
      return 'Password must be 6+ characters, include upper/lowercase\nletters, number, and a special character.';
    }
    return null;
  }

  // Validates the email input
  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) return 'Enter your email';
    if (!emailRegex.hasMatch(value)) return 'Enter a valid email';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up")),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildField(_firstName, "First Name", (val) =>
                  val == null || val.isEmpty ? 'Required' : null),
              _buildField(_lastName, "Last Name", (val) =>
                  val == null || val.isEmpty ? 'Required' : null),
              _buildField(_email, "Email", validateEmail),
              _buildField(_password, "Password", validatePassword, obscure: true),
              const SizedBox(height: 20),
              // Sign up button
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState!.validate()) {
                    await context.read<UserAuthProvider>().signUp(
                      email: _email.text.trim(),
                      password: _password.text.trim(),
                      firstName: _firstName.text.trim(),
                      lastName: _lastName.text.trim(),
                    );
                    // Navigate back to login page after sign-up
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text("Create Account"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to build input fields
  Widget _buildField(
    TextEditingController controller,
    String label,
    String? Function(String?) validator, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        obscureText: obscure, // Hide text if it's a password field
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: validator, // Apply field-specific validation
      ),
    );
  }
}
