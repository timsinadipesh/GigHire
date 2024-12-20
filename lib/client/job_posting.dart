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
  final TextEditingController _locationController = TextEditingController();
  final List<File> _selectedImages = [];
  List<String?> _selectedImagesUrls = [];
  final int maxImages = 5;

  bool _isLoading = false;
  String _errorMessage = '';
  String _locationOption = 'user_address';
  String _userAddress = '';

  @override
  void initState() {
    super.initState();
    _loadUserLocation();
  }

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

  Future<void> _loadUserLocation() async {
    try {
      // Fetch the user's location from the 'workers' collection
      DocumentSnapshot userDoc = await _firestore.collection('clients').doc(globalUserId).get();

      if (userDoc.exists) {
        String userAddress = userDoc['address'] ?? 'No address available';  // Use a default value if address is missing
        setState(() {
          _userAddress = userAddress;
          _locationController.text = userAddress;  // Prefill the location field with the user's address
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load user location: $e';
      });
    }
  }

  // Function to update location based on selection
  void _updateLocation() {
    switch (_locationOption) {
      case 'user_address':
        _locationController.text = _userAddress;
        break;
      case 'remote':
        _locationController.text = 'Remote';
        break;
      case 'custom':
        _locationController.clear(); // Clear the location field for custom input
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Post a Job',
                  style: TextStyle(
                    color: Color(0xFF4CAF50),
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
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

                // Location Selection Section
                SizedBox(height: 10.0),
                Row(
                  children: [
                    Text(
                      'Location:',
                      style: TextStyle(color: Colors.white, fontSize: 16.0),
                    ),
                    SizedBox(width: 10.0),
                    DropdownButton<String>(
                      value: _locationOption,
                      onChanged: (String? newValue) {
                        setState(() {
                          _locationOption = newValue!;
                          _updateLocation();
                        });
                      },
                      items: <String>['custom', 'user_address', 'remote']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value == 'custom' ? 'Custom Location' :
                            value == 'user_address' ? 'User Address' : 'Remote',
                            style: TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      dropdownColor: Color(0xFF2A2A2A),
                    ),
                  ],
                ),

                // Display location text field
                SizedBox(height: 16.0),
                TextField(
                  controller: _locationController,
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: _locationOption == 'user_address'
                        ? 'Location (Your address)'
                        : 'Location',
                    hintStyle: TextStyle(color: Colors.grey),
                    suffixText: _locationOption == 'user_address' ? '(Your address)' : null,
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
                  maxLines: 4,
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

                SizedBox(height: 5.0),
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
    String location = _locationController.text.trim();

    // Validate required fields
    if (jobTitle.isEmpty || hourlyPay.isEmpty || deadline.isEmpty || location.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please fill in all the required fields.';
      });
      return;
    }

    // Provide default values for optional fields
    if (problemDescription.isEmpty) {
      problemDescription = 'No description provided.';
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
        'location': location,
        'images': uploadedImageUrls.isNotEmpty ? uploadedImageUrls : [], // Default to empty list if no images
        'postedAt': FieldValue.serverTimestamp(),  // Timestamp of when the job was posted
        'userId': globalUserId,
        'status': 'postings', // Default job status
      });

      // Show success message
      setState(() {
        _isLoading = false;
        _errorMessage = '';
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Job posted successfully!'),
        backgroundColor: Colors.green,
      ));

      // Clear the form
      _jobTitleController.clear();
      _problemDescriptionController.clear();
      _hourlyPayController.clear();
      _deadlineController.clear();
      _locationController.clear();
      setState(() {
        _selectedImages.clear();
      });

      Navigator.pushReplacementNamed(context, '/client_home');
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred while posting the job. Please try again.';
      });
    }
  }
}

