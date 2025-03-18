import 'package:flutter/material.dart';
import 'package:my_finance/services/auth_service.dart';
import './sign_up_screen.dart';
import './home_screen.dart';
class SignInScreen extends StatefulWidget {
  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false; // Track loading state

  void _signIn() async {
    setState(() {
      _isLoading = true; // Show loading spinner
    });

    String email = emailController.text;
    String password = passwordController.text;
    final user = await _authService.signIn(email, password);

    setState(() {
      _isLoading = false; // Hide loading spinner
    });

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in successfully!')),
      );
      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => HomeScreen()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to sign in. Please check your credentials.')),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(controller: emailController, decoration: InputDecoration(labelText: 'Email')),
            TextField(controller: passwordController, decoration: InputDecoration(labelText: 'Password'), obscureText: true),
            SizedBox(height: 20),
            
            _isLoading
                ? CircularProgressIndicator() // Show loading spinner when signing in
                : ElevatedButton(onPressed: _signIn, child: Text('Sign In')),

            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => SignUpScreen()), // push instead of pushReplacement
              ),
              child: Text("Don't have an account? Sign Up"),
            ),
          ],
        ),
      ),
    );
  }
}
