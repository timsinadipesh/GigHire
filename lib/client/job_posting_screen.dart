import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gighire/base_user/globals.dart';
import 'dart:io';
import 'package:gighire/services/img_service.dart';
import 'package:image_picker/image_picker.dart';

class JobPostingScreen extends StatefulWidget {
  const JobPostingScreen({Key? key}) : super(key: key);

  @override
  _JobPostingScreenState createState() => _JobPostingScreenState();
}

class _JobPostingScreenState extends State<JobPostingScreen> {
  final ImagePicker _picker = ImagePicker();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImageUploadService _imageUploadService = ImageUploadService();

  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _problemDescriptionController = TextEditingController();
  final TextEditingController _hourlyPayController = TextEditingController();
  final TextEditingController _deadlineController = TextEditingController();
  final List<File> _selectedImages = [];
  List<String?> _selectedImagesUrls = [];
  final int maxImages = 5;

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _pickImage() async {
    if (_selectedImages.length < maxImages) {
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
              _selectedImages.add(certImage);
              _selectedImagesUrls.add(uploadedUrl);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Post a Job',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _jobTitleController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Job Title',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Color(0xFF2A2A2A),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _problemDescriptionController,
                style: TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Problem Description',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Color(0xFF2A2A2A),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _hourlyPayController,
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  hintText: 'Proposed Hourly Pay (Rs.)',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Color(0xFF2A2A2A),
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _deadlineController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Deadline (Pick a Date)',
                  hintStyle: TextStyle(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  filled: true,
                  fillColor: Color(0xFF2A2A2A),
                ),
                onTap: _selectDate,
              ),
              SizedBox(height: 16.0),

              // Upload Pictures Section
              Column(
                children: [
                  // Display uploaded images
                  for (int i = 0; i < _selectedImages.length; i++)
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
                              ? 'First picture uploaded'
                              : 'Additional picture uploaded',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  if (_selectedImages.length < maxImages)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2A2A2A),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _selectedImages.isEmpty
                                ? 'Upload problem picture'
                                : 'Upload additional picture',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              SizedBox(height: 16.0),
              if (_errorMessage.isNotEmpty)
                Text(
                  _errorMessage,
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0,
                  ),
                ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _postJob,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: _isLoading
                    ? CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
                    : Text('Post Job'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // This function will allow the user to pick a future date
  Future<void> _selectDate() async {
    final DateTime currentDate = DateTime.now();
    final DateTime selectedDate = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: currentDate, // Allow future dates only
      lastDate: DateTime(2101),
    ) ?? currentDate;

    // Update the deadline field with the selected date
    _deadlineController.text = "${selectedDate.toLocal()}".split(' ')[0]; // Format as YYYY-MM-DD
  }

  Future<void> _postJob() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String jobTitle = _jobTitleController.text.trim();
    String problemDescription = _problemDescriptionController.text.trim();
    String hourlyPay = _hourlyPayController.text.trim();
    String deadline = _deadlineController.text.trim();

    if (jobTitle.isEmpty || problemDescription.isEmpty || hourlyPay.isEmpty || deadline.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please fill in all the required fields.';
      });
      return;
    }

    try {
      List<String> uploadedImageUrls = [];

      // Upload each selected image to Imgur and get the URL
      for (File image in _selectedImages) {
        String? imgurImageUrl = await _imageUploadService.uploadImageToImgur(image);
        if (imgurImageUrl != null) {
          uploadedImageUrls.add(imgurImageUrl);
        }
      }

      // Send the job data to Firestore
      await _firestore.collection('jobs').add({
        'jobTitle': jobTitle,
        'problemDescription': problemDescription,
        'hourlyPay': hourlyPay,
        'deadline': deadline,
        'images': uploadedImageUrls,  // Store the uploaded image URLs
        'postedAt': FieldValue.serverTimestamp(),  // Timestamp of when the job was posted
        'userId': globalUserId,
      });

      // Show a success message
      setState(() {
        _isLoading = false;
        _errorMessage = '';
      });

      // Show a success snack bar
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Job posted successfully!'),
        backgroundColor: Colors.green,
      ));

      // Clear the form after posting
      _jobTitleController.clear();
      _problemDescriptionController.clear();
      _hourlyPayController.clear();
      _deadlineController.clear();
      setState(() {
        _selectedImages.clear();  // Clear selected images
      });

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred while posting the job. Please try again.';
      });
    }
  }
}
