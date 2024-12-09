import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gighire/base_user/globals.dart';

class JobPostingScreen extends StatefulWidget {
  const JobPostingScreen({Key? key}) : super(key: key);

  @override
  _JobPostingScreenState createState() => _JobPostingScreenState();
}

class _JobPostingScreenState extends State<JobPostingScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _jobTitleController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _minBudgetController = TextEditingController();
  final TextEditingController _maxBudgetController = TextEditingController();
  final TextEditingController _timelineController = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

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
                controller: _categoryController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Category',
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
                controller: _descriptionController,
                style: TextStyle(color: Colors.white),
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Description',
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minBudgetController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Min \$',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Color(0xFF2A2A2A),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.0),
                  Expanded(
                    child: TextField(
                      controller: _maxBudgetController,
                      style: TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Max \$',
                        hintStyle: TextStyle(color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        filled: true,
                        fillColor: Color(0xFF2A2A2A),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _timelineController,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Timeline',
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

  void _postJob() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    String jobTitle = _jobTitleController.text.trim();
    String category = _categoryController.text.trim();
    String description = _descriptionController.text.trim();
    String minBudget = _minBudgetController.text.trim();
    String maxBudget = _maxBudgetController.text.trim();
    String timeline = _timelineController.text.trim();

    if (jobTitle.isEmpty ||
        category.isEmpty ||
        description.isEmpty ||
        minBudget.isEmpty ||
        maxBudget.isEmpty ||
        timeline.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please fill in all the required fields.';
      });
      return;
    }

    try {
      // Create a new document in the "jobs" collection
      await _firestore.collection('jobs').add({
        'jobTitle': jobTitle,
        'category': category,
        'description': description,
        'minBudget': minBudget,
        'maxBudget': maxBudget,
        'timeline': timeline,
        'poster': globalUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Clear the form fields
      _jobTitleController.clear();
      _categoryController.clear();
      _descriptionController.clear();
      _minBudgetController.clear();
      _maxBudgetController.clear();
      _timelineController.clear();

      // Display a success message or navigate to a different screen
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Job posted successfully.'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'An error occurred while posting the job.';
      });
      print('Error posting job: $e');
    }
  }
}