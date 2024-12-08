import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gighire/worker/worker_signup.dart';
import 'package:image_picker/image_picker.dart';
import 'package:gighire/services/img_service.dart';
import 'package:gighire/base_user/globals.dart';

enum UserRole { serviceProvider, serviceSeeker }

class SignupScreen extends StatefulWidget {
  const SignupScreen({Key? key}) : super(key: key);

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  UserRole? selectedRole;
  File? _profileImage; // Placeholder for the image state
  final ImagePicker _picker = ImagePicker();

  // TextControllers for form fields
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _passwordController = TextEditingController();

  // Create an instance of ImageUploadService
  final ImageUploadService _imageUploadService = ImageUploadService();
  String? _uploadedImageUrl; // To store the uploaded image URL

  Future<void> pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      _profileImage = File(pickedFile.path);
      print("Image picked. Path: ${_profileImage!.path}");

      if (!_profileImage!.existsSync()) {
        throw Exception("Image file does not exist at path: ${pickedFile.path}");
      }

      // Upload the image and store the URL
      try {
        _uploadedImageUrl = await _imageUploadService.uploadImageToImgur(_profileImage);
        setState(() {}); // Trigger rebuild to update UI
      } catch (e) {
        print("Error uploading image: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to upload image: $e')),
        );
      }
    } else {
      print("No image selected.");
    }
  }

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
                const SizedBox(height: 0),
                const Text(
                  'GigHire',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 0),
                const Text(
                  'Create your account',
                  style: TextStyle(color: Color(0xFF888888), fontSize: 16),
                ),

                // Input Fields
                const SizedBox(height: 20),
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    hintText: 'Full Name *',
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
                  controller: _emailController,
                  decoration: InputDecoration(
                    hintText: 'Email *',
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
                  controller: _phoneController,
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
                  controller: _addressController,
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
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    hintText: 'Password *',
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

                GestureDetector(
                  onTap: pickImage,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: _uploadedImageUrl == null ? const Color(0xFF2A2A2A) : const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: _uploadedImageUrl == null
                        ? const Text(
                      'Upload Profile Photo',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    )
                        : const Text(
                      'Profile Photo Uploaded',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Role Selection
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
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Collect form data
                      String fullName = _fullNameController.text;
                      String email = _emailController.text;
                      String phoneNumber = _phoneController.text;
                      String address = _addressController.text;
                      String password = _passwordController.text;

                      // Validation (you can add more comprehensive checks)
                      if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Please fill in all required fields.')),
                        );
                        return;
                      }

                      if (selectedRole == UserRole.serviceProvider) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WorkerSignupScreen(
                                fullName: fullName,
                                email: email,
                                phoneNumber: phoneNumber,
                                address: address,
                                password: password,
                                uploadedImageUrl: _uploadedImageUrl
                            ),
                          ),
                        );
                        return;
                      }
                      else if (selectedRole == UserRole.serviceSeeker) {
                        try {
                          // Sign up user with Firebase Authentication
                          UserCredential userCredential = await FirebaseAuth.instance
                              .createUserWithEmailAndPassword(email: email, password: password);

                          // Get the user's UID
                          String userId = userCredential.user?.uid ?? '';

                          // Create Firestore document data
                          final clientData = {
                            'fullName': fullName,
                            'email': email,
                            'phoneNumber': phoneNumber,
                            'address': address,
                            'password': password,
                            'createdAt': FieldValue.serverTimestamp(),
                          };

                          // Add uploaded image URL to client data if available
                          if (_uploadedImageUrl != null) {
                            clientData['profileImage'] = _uploadedImageUrl!;
                          }

                          // Save client data to Firestore
                          await FirebaseFirestore.instance
                              .collection('clients')
                              .doc(userId)
                              .set(clientData);

                          globalUserId = userId;
                          // Navigate to home screen
                          Navigator.pushReplacementNamed(context, '/client_home');
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Error signing up: $e')),
                          );
                        }
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
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Already have an account? ',
                      style: TextStyle(color: Color(0xFF888888), fontSize: 14),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      child: const Text(
                        'Log in',
                        style: TextStyle(color: Color(0xFF4CAF50), fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
