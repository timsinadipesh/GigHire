import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gighire/services/img_service.dart';

class WorkerSignupScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String phoneNumber;
  final String address;
  final String password;
  final String? uploadedImageUrl;

  const WorkerSignupScreen({
    Key? key,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.address,
    required this.password,
    this.uploadedImageUrl
  }) : super(key: key);

  @override
  State<WorkerSignupScreen> createState() => _WorkerSignupScreenState();
}

class _WorkerSignupScreenState extends State<WorkerSignupScreen> {
  final ImagePicker _picker = ImagePicker();
  List<File?> _certificationImages = [];
  List<TextEditingController> skillControllers = [TextEditingController()];

  final TextEditingController _aboutController = TextEditingController();
  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _workExperienceController = TextEditingController();
  final TextEditingController _hourlyRateController = TextEditingController();

  // Max limits
  final int maxSkills = 3;
  final int maxCertifications = 3;

  final ImageUploadService _imageUploadService = ImageUploadService();
  List<String?> _certificationImageUrls = [];

  Future<void> _pickImage() async {
    if (_certificationImages.length < maxCertifications) {
      final pickedFile = await _picker.pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        File certImage = File(pickedFile.path);

        // Validate file exists
        if (!certImage.existsSync()) {
          throw Exception("Certification image file does not exist at path: ${pickedFile.path}");
        }

        // Upload the image and store the URL
        try {
          String? uploadedUrl = await _imageUploadService.uploadImageToImgur(certImage);

          if (uploadedUrl != null) {
            setState(() {
              _certificationImages.add(certImage);
              _certificationImageUrls.add(uploadedUrl);
            });
          }
        } catch (e) {
          print("Error uploading certification image: $e");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload certification image: $e')),
          );
        }
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum number of certifications reached')),
      );
    }
  }

  void _addSkillField() {
    if (skillControllers.length < maxSkills) {
      setState(() {
        skillControllers.add(TextEditingController());
      });
    }
  }

  Future<void> _completeSignUp() async {
    // Validate job title is not empty
    if (_jobTitleController.text.trim().isEmpty || _hourlyRateController.text.trim().isEmpty || //
    _workExperienceController.text.trim().isEmpty || _aboutController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all required fields.')),
      );
      return;
    }

    try {
      // Sign up user with Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: widget.email, password: widget.password);

      // Get the user's UID
      String userId = userCredential.user?.uid ?? '';

      // Collect skills
      List<String> skills = [
        // Primary skill (first TextField)
        skillControllers.isNotEmpty ? skillControllers[0].text : '',
        // Additional skills
        ...skillControllers.skip(1).map((controller) => controller.text).toList()
      ].where((skill) => skill.isNotEmpty).toList();

      List<String> certificationUrls = [];

      // Create worker document data
      final workerData = {
        'fullName': widget.fullName,
        'email': widget.email,
        'phoneNumber': widget.phoneNumber,
        'address': widget.address,
        'password': widget.password,
        'jobTitle': _jobTitleController.text.trim(),
        'workExperience': _workExperienceController.text,
        'hourlyRate': double.tryParse(_hourlyRateController.text) ?? 0.0,
        'skills': skills,
        'certifications': _certificationImageUrls.whereType<String>().toList(),
        'about': _aboutController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Add uploaded profile image URL to worker data if available
      if (widget.uploadedImageUrl != null) {
        workerData['profileImage'] = widget.uploadedImageUrl!;
      }

      // Save worker data to Firestore
      await FirebaseFirestore.instance
          .collection('workers')
          .doc(userId)
          .set(workerData);

      // Navigate to home screen
      Navigator.pushReplacementNamed(context, '/worker_home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing up: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Dispose of all controllers
    _jobTitleController.dispose();
    _workExperienceController.dispose();
    _hourlyRateController.dispose();
    _aboutController.dispose();
    for (var controller in skillControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4CAF50),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text('Worker Sign Up', style: TextStyle(color: Colors.white)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // New Job Title TextField
                TextField(
                  controller: _jobTitleController,
                  decoration: InputDecoration(
                    hintText: 'Job Title *',
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

                // Work Experience TextField
                TextField(
                  controller: _workExperienceController,
                  decoration: InputDecoration(
                    hintText: 'Work Experience (years) *',
                    hintStyle: const TextStyle(color: Color(0xFF666666)),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),

                // About TextField
                TextField(
                  controller: _aboutController,
                  decoration: InputDecoration(
                    hintText: 'About *',
                    hintStyle: const TextStyle(color: Color(0xFF666666)),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  maxLines: 4, // Allows multi-line input
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Hourly Rate TextField
                TextField(
                  controller: _hourlyRateController,
                  decoration: InputDecoration(
                    hintText: 'Hourly Rate *',
                    hintStyle: const TextStyle(color: Color(0xFF666666)),
                    filled: true,
                    fillColor: const Color(0xFF2A2A2A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixText: 'Rs. ',
                    prefixStyle: const TextStyle(color: Colors.white),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),

                // Primary Skill (with + sign to add two more skills)
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: skillControllers[0],
                        decoration: InputDecoration(
                          hintText: 'Primary Skill',
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
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _addSkillField,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Optional Additional Skills (maximum 2)
                for (int i = 1; i < skillControllers.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20.0),
                    child: TextField(
                      controller: skillControllers[i],
                      decoration: InputDecoration(
                        hintText: 'Optional additional skill',
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
                  ),

                // Upload Certifications (with dynamic text updates)
                Column(
                  children: [
                    for (int i = 0; i < _certificationImages.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            i == 0
                                ? 'Primary certificate uploaded'
                                : 'Optional certificate uploaded',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    if (_certificationImages.length < maxCertifications)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 20.0),
                        child: GestureDetector(
                          onTap: () => _pickImage(),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2A2A2A),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              _certificationImages.isEmpty
                                  ? 'Upload primary certificate'
                                  : 'Upload optional certificate',
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                // Sign Up Button
                const SizedBox(height: 5),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _completeSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4CAF50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Complete Sign Up',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}