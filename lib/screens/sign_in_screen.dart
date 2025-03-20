import 'package:flutter/material.dart';
import 'package:my_finance/services/auth_service.dart';
import './sign_up_screen.dart';
import './home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});
  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLoading = false;

  void _signIn() async {
    setState(() => _isLoading = true);
    String email = emailController.text;
    String password = passwordController.text;
    final user = await _authService.signIn(email, password);
    setState(() => _isLoading = false);

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Signed in successfully!')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Invalid credentials. Try again!')),
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
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(Icons.person,
                      size: 60, color: theme.colorScheme.onPrimary),
                ),
                SizedBox(height: 20),
                _buildTextField(
                    emailController, 'Email', Icons.email, false, theme),
                SizedBox(height: 10),
                _buildTextField(
                    passwordController, 'Password', Icons.lock, true, theme),
                SizedBox(height: 20),
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 50, vertical: 12),
                        ),
                        child: Text('Sign In',
                            style: TextStyle(
                                fontSize: 18,
                                color: theme.colorScheme.onPrimary)),
                      ),
                SizedBox(height: 15),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => SignUpScreen()),
                  ),
                  child: Text("Don't have an account? Sign Up",
                      style: TextStyle(color: theme.colorScheme.secondary)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint,
      IconData icon, bool obscure, ThemeData theme) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: theme.colorScheme.primary),
        hintText: hint,
        filled: true,
        fillColor: theme.colorScheme.surfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
