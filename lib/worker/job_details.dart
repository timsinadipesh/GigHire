import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gighire/client/client_profile.dart';

class JobDetailsScreen extends StatefulWidget {
  final String? jobId;

  const JobDetailsScreen({Key? key, this.jobId}) : super(key: key);

  @override
  _JobDetailsScreenState createState() => _JobDetailsScreenState();
}

class _JobDetailsScreenState extends State<JobDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _jobDetails;
  Map<String, dynamic>? _posterDetails;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchJobDetails();
  }

  Future<void> _fetchJobDetails() async {
    try {
      DocumentSnapshot jobDoc = await _firestore.collection('jobs').doc(widget.jobId).get();

      if (jobDoc.exists) {
        _jobDetails = jobDoc.data() as Map<String, dynamic>?;
        await _fetchPosterDetails(_jobDetails?['userId']);
        setState(() {
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Job not found';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load job details: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchPosterDetails(String? userId) async {
    if (userId == null) return;

    try {
      DocumentSnapshot userDoc = await _firestore.collection('clients').doc(userId).get();

      if (userDoc.exists) {
        _posterDetails = userDoc.data() as Map<String, dynamic>?;
      } else {
        _posterDetails = {'fullName': 'Unknown'};
      }
    } catch (e) {
      _posterDetails = {'fullName': 'Error fetching user'};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Job Details',
          style: TextStyle(color: Color(0xFF4CAF50)),
        ),
        iconTheme: const IconThemeData(color: Color(0xFF4CAF50)),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF4CAF50),
        ),
      )
          : _errorMessage.isNotEmpty
          ? Center(
        child: Text(
          _errorMessage,
          style: const TextStyle(color: Colors.white),
        ),
      )
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildJobTitle(),
              const SizedBox(height: 16.0),
              _buildJobDetailsGrid(),
              const SizedBox(height: 16.0),
              _buildPostedAt(),
              const SizedBox(height: 16.0),
              _buildPosterDetails(),
              const SizedBox(height: 16.0),
              _buildProblemDescription(),
              const SizedBox(height: 16.0),
              _buildImagesSection(),
              const SizedBox(height: 24.0),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildJobTitle() {
    return Text(
      _jobDetails?['jobTitle'] ?? 'No Title',
      style: const TextStyle(
        color: Color(0xFF4CAF50),
        fontSize: 24.0,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildJobDetailsGrid() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          _buildDetailRow('Location', _jobDetails?['location'] ?? 'Not specified'),
          _buildDetailRow('Hourly Pay', 'Rs. ${_jobDetails?['hourlyPay'] ?? 'N/A'}'),
          _buildDetailRow('Deadline', _jobDetails?['deadline'] ?? 'Not set'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16.0,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPostedAt() {
    final postedAt = _jobDetails?['postedAt']?.toDate()?.toString() ?? 'Unknown';
    return Text(
      'Posted At: $postedAt',
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 16.0,
      ),
    );
  }

  Widget _buildPosterDetails() {
    final posterName = _posterDetails?['fullName'] ?? 'Unknown';
    final posterUserId = _jobDetails?['userId']; // Retrieve the poster's userId

    return Row(
      children: [
        // Static "Posted By:" text
        const Text(
          'Posted By: ',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 16.0,
          ),
        ),
        // Poster name as a button
        ElevatedButton(
          onPressed: () {
            if (posterUserId != null) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ClientProfileScreen(userId: posterUserId),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('User profile not available.')),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50), // Match existing button color
            foregroundColor: Colors.white, // White text color
            padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 12.0), // Smaller padding
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0), // Rounded shape
            ),
          ),
          child: Text(
            posterName, // Only the name inside the button
            style: const TextStyle(fontSize: 14.0), // Slightly smaller font size
          ),
        ),
      ],
    );
  }

  Widget _buildProblemDescription() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Problem Description',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Text(
          _jobDetails?['problemDescription'] ?? 'No description available',
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 16.0,
          ),
        ),
      ],
    );
  }

  Widget _buildImagesSection() {
    List<dynamic> images = _jobDetails?['images'] ?? [];

    if (images.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Problem Images',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: images.map((imageUrl) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Center(
      child: Column(
        children: [
          ElevatedButton(
            onPressed: _applyForJob,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text(
              'Apply for Job',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            onPressed: _messagePoster,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
            ),
            child: const Text(
              'Message Poster',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  void _applyForJob() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Job application feature coming soon!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  void _messagePoster() {
    final String? posterUserId = _jobDetails?['userId'];

    if (posterUserId != null) {
      Navigator.pushNamed(
        context,
        '/message',
        arguments: {'otherUserId': posterUserId},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to message the job poster.')),
      );
    }
  }
}
