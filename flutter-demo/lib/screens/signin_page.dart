import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class SignIn extends StatefulWidget {
  const SignIn({super.key});

  @override
  State<SignIn> createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final formKey = GlobalKey<FormState>(); 
  final TextEditingController _email = TextEditingController(); // Controller for email input
  final TextEditingController _password = TextEditingController(); // Controller for password input

  String? errorMessage; // Holds error messages for display

  // Validates email format using regex
  String? emailValidator(String? value) {
    if (value == null || value.isEmpty) return 'Enter your email.';
    final regex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return regex.hasMatch(value) ? null : 'Invalid email format';
  }

  // Validates password strength
  String? passwordValidator(String? value) {
    if (value == null || value.isEmpty) return 'Enter your password.';
    final regex = RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[\W_]).{6,}$');
    if (!regex.hasMatch(value)) {
      return 'Wrong password!';
    }
    return null;
  }

  @override
  void dispose() {
    // Dispose controllers when widget is destroyed
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  // Handles login logic
  Future<void> handleSignIn() async {
    if (formKey.currentState!.validate()) {
      final error = await context.read<UserAuthProvider>().signIn(
            email: _email.text.trim(),
            password: _password.text.trim(),
          );

      // Handle errors or success
      if (error != null) {
        setState(() {
          errorMessage = "This account doesn't exist. \nEnter a different account or sign-up first.";
        });
      } else {
        setState(() {
          errorMessage = null; // Clear error message if login is successful
        });
      }
    }
  }  
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(
          "Log In",
          style: TextStyle(
            color: Colors.white,       
            fontWeight: FontWeight.bold, 
          ),
        ), backgroundColor: Colors.purple,),
      body: Form(
        key: formKey,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Show error message if exists
              if (errorMessage != null) ...[
                Text(
                  errorMessage!,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
              ],
              // Email input field
              _buildTextField(_email, "Email", emailValidator),
              // Password input field (obscured)
              _buildTextField(_password, "Password", passwordValidator, obscure: true),
              const SizedBox(height: 20),
              // Login button
              ElevatedButton(
                onPressed: handleSignIn,
                child: const Text("LOGIN"),
              ),
              // Navigate to Sign Up screen
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signUp'),
                child: const Text("SIGN UP"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Reusable method to create text input fields
  Widget _buildTextField(
    TextEditingController controller,
    String label,
    String? Function(String?) validator, {
    bool obscure = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        obscureText: obscure,
        validator: validator,
      ),
    );
  }
}


