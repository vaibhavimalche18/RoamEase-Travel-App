import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'home_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final auth = AuthService();

  // void handleSignup() async {
  //   String? res = await auth.signUp(
  //     nameController.text.trim(),
  //     emailController.text.trim(),
  //     passwordController.text.trim(),
  //   );
  //
  //   if (res == null) {
  //     Navigator.pushReplacement(
  //       context,
  //       MaterialPageRoute(builder: (_) => const HomeScreen()),
  //     );
  //   } else {
  //     ScaffoldMessenger.of(context)
  //         .showSnackBar(SnackBar(content: Text(res)));
  //   }
  // }
  void handleSignup() async {
    String? res = await auth.signUp(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    if (res == null) {
      // Auto redirect to home after signup
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(res)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [

          /// 🌄 SAME BACKGROUND
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/travel.jpg"),
                fit: BoxFit.cover,
              ),
            ),
          ),

          /// 🌫 BLUR
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: Container(color: Colors.black.withOpacity(0.2)),
          ),

          /// 📦 CONTENT
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [

                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.white.withOpacity(0.2),
                    child: Column(
                      children: [

                        const Text(
                          "Create Account",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// NAME
                        TextField(
                          controller: nameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Name"),
                        ),

                        const SizedBox(height: 15),

                        /// EMAIL
                        TextField(
                          controller: emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Email"),
                        ),

                        const SizedBox(height: 15),

                        /// PASSWORD
                        TextField(
                          controller: passwordController,
                          obscureText: true,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecoration("Password"),
                        ),

                        const SizedBox(height: 20),

                        /// SIGNUP BUTTON
                        GestureDetector(
                          onTap: handleSignup,
                          child: Container(
                            height: 55,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF54BDD6), Color(0xFF588DC6)],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: const Center(
                              child: Text(
                                "Sign Up",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        /// BACK TO LOGIN
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text(
                            "Already have an account? Login",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// ✨ Reusable input style
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.white.withOpacity(0.2),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}