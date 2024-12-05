import 'package:flutter/material.dart';

import '../client/client_signup.dart';
import '../worker/worker_signup.dart';

enum UserRole { serviceProvider, serviceSeeker }

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  UserRole? selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                // Logo and Tagline
                const SizedBox(height: 30),
                const Text(
                  'GigHire',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 36, // Reduced size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5), // Reduced spacing
                const Text(
                  'Create your account',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 16),
                ),

                // Input Fields
                const SizedBox(height: 30),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Full Name',
                    hintStyle: const TextStyle(color: Color(0xFF666666)),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Email',
                    hintStyle: const TextStyle(color: Color(0xFF666666)),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
                    hintStyle: const TextStyle(color: Color(0xFF666666)),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  decoration: InputDecoration(
                    hintText: 'Address',
                    hintStyle: const TextStyle(color: Color(0xFF666666)),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password',
                    hintStyle: const TextStyle(color: Color(0xFF666666)),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),

                // Role Selection
                const SizedBox(height: 30),
                Row(
                  children: [
                    const Text(
                      'Sign up as:',
                      style: TextStyle(color: Color(0xFF888888), fontSize: 16),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRole = UserRole.serviceProvider;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedRole == UserRole.serviceProvider
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Worker',
                          style: TextStyle(
                            color: selectedRole == UserRole.serviceProvider
                                ? Colors.white
                                : const Color(0xFF888888),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedRole = UserRole.serviceSeeker;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: selectedRole == UserRole.serviceSeeker
                              ? const Color(0xFF4CAF50)
                              : const Color(0xFF2A2A2A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          'Client',
                          style: TextStyle(
                            color: selectedRole == UserRole.serviceSeeker
                                ? Colors.white
                                : const Color(0xFF888888),
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                // Sign Up Button
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedRole == UserRole.serviceProvider) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const WorkerSignupScreen()),
                        );
                      } else if (selectedRole == UserRole.serviceSeeker) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const ClientSignupScreen()),
                        );
                      }
                    },

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Login Link
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Color(0xFF888888), fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFF4CAF50),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
