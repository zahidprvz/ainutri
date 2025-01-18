import 'package:ainutri/resources/auth_methods.dart';
import 'package:ainutri/screens/login/login_screen.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  void signUpUser() async {
    setState(() {
      _isLoading = true;
    });

    String res = await AuthMethods().signUpUser(
      email: _emailController.text,
      password: _passwordController.text,
      username: _usernameController.text,
    );

    setState(() {
      _isLoading = false;
    });

    if (res == "success") {
      // Navigate to the onboarding screen or home screen
      Navigator.of(context).pushReplacementNamed('/onboarding');
    } else {
      showSnackBar(res, context);
    }
  }

  void showSnackBar(String message, BuildContext context) {
    final snackBar = SnackBar(content: Text(message));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  void navigateToLogin() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 64.0),
                // Rounded Logo
                ClipRRect(
                  borderRadius: BorderRadius.circular(
                      20.0), // Adjust radius for desired roundness
                  child: Image.asset(
                    'assets/logo.png', // Replace with your logo asset
                    height: 100.0,
                  ),
                ),
                const SizedBox(height: 64.0),
                // Username textfield
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(
                    hintText: 'Entrez votre nom d\'utilisateur',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 24.0),
                // Email textfield
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    hintText: 'Entrez votre email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 24.0),
                // Password textfield
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    hintText: 'Entrez votre mot de passe',
                    border: OutlineInputBorder(),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(height: 24.0),
                // Signup button
                ElevatedButton(
                  onPressed: signUpUser,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 12.0),
                    minimumSize: const Size(double.infinity, 50), // Full width
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text(
                          'S\'inscrire',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
                const SizedBox(height: 24.0),
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Vous avez déjà un compte?"),
                    TextButton(
                      onPressed: navigateToLogin,
                      child: Text(
                        " Se connecter",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 64.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
