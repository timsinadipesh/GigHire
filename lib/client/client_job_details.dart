import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gighire/worker/worker_profile.dart';

class ClientJobDetailsScreen extends StatefulWidget {
  final String jobId;

  const ClientJobDetailsScreen({Key? key, required this.jobId}) : super(key: key);

  @override
  _ClientJobDetailsScreenState createState() => _ClientJobDetailsScreenState();
}

class _ClientJobDetailsScreenState extends State<ClientJobDetailsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _jobDetails;
  List<Map<String, dynamic>> _applicants = [];
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
        // Initialize missing fields with default values if they don't exist
        final jobData = jobDoc.data() as Map<String, dynamic>?;

        if (jobData != null && !jobData.containsKey('clientRated')) {
          await _firestore.collection('jobs').doc(widget.jobId).update({
            'clientRated': false,
            'rating': 0.0,
            'review': '',
            'completionDate': null,
          });
          jobData['clientRated'] = false;
          jobData['rating'] = 0.0;
          jobData['review'] = '';
          jobData['completionDate'] = null;
        }

        setState(() {
          _jobDetails = jobData;
        });
        await _fetchApplicants();
      } else {
        setState(() {
          _errorMessage = 'Job not found';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load job details: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchApplicants() async {
    try {
      List<dynamic> applicantIds = _jobDetails?['applicants'] ?? [];
      if (applicantIds.isNotEmpty) {
        QuerySnapshot applicantDocs = await _firestore
            .collection('workers')
            .where(FieldPath.documentId, whereIn: applicantIds)
            .get();

        setState(() {
          _applicants = applicantDocs.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            data['documentId'] = doc.id;
            return data;
          }).toList();
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load applicants: $e';
      });
    }
  }

  Widget _buildApplicantsSection() {
    String jobStatus = _jobDetails?['status'] ?? '';

    if (jobStatus == 'completed') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This job has been completed.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildAssignedWorker(),
        ],
      );
    }

    if (jobStatus == 'in_progress') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'This job is in progress.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          _buildAssignedWorker(showCompleteButton: true),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Applicants', style: TextStyle(fontSize: 18, color: Colors.white)),
        ..._applicants.map((applicant) {
          return ListTile(
            title: Text(applicant['fullName'] ?? 'Unknown', style: const TextStyle(color: Colors.white)),
            subtitle: Text(applicant['jobTitle'] ?? 'No title', style: const TextStyle(color: Colors.grey)),
            onTap: () {
              // Navigate to the WorkerProfileScreen with the document ID as the userId
              print('Navigating to worker profile with ID: ${applicant['documentId']}');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WorkerProfileScreen(userId: applicant['documentId']),
                ),
              );
            },
            trailing: _jobDetails?['approvedApplicant'] == applicant['documentId']
                ? const Text('Approved', style: TextStyle(color: Colors.green))
                : ElevatedButton(
              onPressed: () => _approveApplicant(applicant['documentId']),
              child: const Text('Approve'),
            ),
          );
        }).toList(),
      ],
    );
  }


  Future<void> _approveApplicant(String applicantId) async {
    try {
      await _firestore.collection('jobs').doc(widget.jobId).update({
        'status': 'in_progress',
        'approvedApplicant': applicantId,
      });
      setState(() {
        _jobDetails?['status'] = 'in_progress';
        _jobDetails?['approvedApplicant'] = applicantId;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve applicant: $e'), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _submitReview(String workerId, double rating, String review) async {
    try {
      final jobRef = _firestore.collection('jobs').doc(widget.jobId);
      final workerRef = _firestore.collection('workers').doc(workerId);

      // Update the job with the review, rating, and clientRated status
      await jobRef.update({
        'review': review,
        'rating': rating,
        'clientRated': true, // Mark the job as rated
        'completionDate': FieldValue.serverTimestamp(), // Capture the completion date
      });

      // Retrieve existing worker data to update their jobCount and totalRating
      DocumentSnapshot workerSnapshot = await workerRef.get();
      Map<String, dynamic>? workerData = workerSnapshot.data() as Map<String, dynamic>?;

      int updatedJobCount = (workerData?['jobCount'] ?? 0) + 1;
      double updatedTotalRating = (workerData?['totalRating'] ?? 0) + rating;

      // Update the worker document
      await workerRef.update({
        'jobCount': updatedJobCount,
        'totalRating': updatedTotalRating,
      });

      // Also mark the job as completed
      await jobRef.update({'status': 'completed'});

      setState(() {
        _jobDetails?['status'] = 'completed';
        _jobDetails?['clientRated'] = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review submitted and job marked as completed'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit review: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _markAsComplete(String workerId) async {
    try {
      final jobRef = _firestore.collection('jobs').doc(widget.jobId);
      final workerRef = _firestore.collection('workers').doc(workerId);

      // Retrieve existing worker data
      DocumentSnapshot workerSnapshot = await workerRef.get();
      Map<String, dynamic>? workerData = workerSnapshot.data() as Map<String, dynamic>?;

      // Increment the worker's job count
      int updatedJobCount = (workerData?['jobCount'] ?? 0) + 1;

      // Update the worker document
      await workerRef.update({
        'jobCount': updatedJobCount,
      });

      // Update the job status to 'completed'
      await jobRef.update({
        'status': 'completed',
        'completionDate': FieldValue.serverTimestamp(), // Capture completion timestamp
      });

      setState(() {
        _jobDetails?['status'] = 'completed';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Job marked as completed!'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to mark job as complete: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Widget _buildAssignedWorker({bool showCompleteButton = false}) {
    String? approvedApplicantId = _jobDetails?['approvedApplicant'];

    if (approvedApplicantId == null) {
      return const Text(
        'No worker assigned yet.',
        style: TextStyle(color: Colors.white70),
      );
    }

    Map<String, dynamic>? assignedWorker = _applicants.firstWhere(
          (applicant) => applicant['documentId'] == approvedApplicantId,
      orElse: () => {},
    );

    if (assignedWorker.isEmpty) {
      return const Text(
        'Assigned worker details not found.',
        style: TextStyle(color: Colors.white70),
      );
    }

    bool canRate = _jobDetails?['status'] == 'completed' &&
        !_jobDetails?['clientRated'];
    bool showButton = canRate || showCompleteButton;

    return ListTile(
      leading: CircleAvatar(
        backgroundImage: NetworkImage(assignedWorker['profileImage'] ?? ''),
        child: assignedWorker['profileImage'] == null
            ? const Icon(Icons.person, color: Colors.white)
            : null,
      ),
      title: Text(
        assignedWorker['fullName'] ?? 'Unknown',
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        assignedWorker['jobTitle'] ?? 'No profession specified',
        style: const TextStyle(color: Colors.white70),
      ),
      trailing: showButton
          ? ElevatedButton(
        onPressed: () async {
          if (!canRate) {
            // Mark the job as complete without review
            await _markAsComplete(approvedApplicantId);
          } else {
            // Show the review dialog
            _showReviewDialog(approvedApplicantId);
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
        ),
        child: Text(canRate ? 'Rate & Review' : 'Complete'),
      )
          : null,
      onTap: () {
        // Navigate to worker profile when tapping the tile
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                WorkerProfileScreen(userId: approvedApplicantId),
          ),
        );
      },
    );
  }

  void _showReviewDialog(String workerId) {
    final TextEditingController reviewController = TextEditingController();
    double rating = 3.0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rate and Review Worker'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Provide a rating (1 to 5):'),
            Slider(
              value: rating,
              min: 1,
              max: 5,
              divisions: 4,
              label: rating.toString(),
              onChanged: (value) {
                setState(() {
                  rating = value;
                });
              },
            ),
            TextField(
              controller: reviewController,
              decoration: const InputDecoration(
                labelText: 'Write a review (optional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await _submitReview(workerId, rating, reviewController.text);
            },
            child: const Text('Submit'),
          ),
        ],
      ),
    );
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
              _buildProblemDescription(),
              const SizedBox(height: 16.0),
              _buildImagesSection(),
              const SizedBox(height: 16.0),
              _buildApplicantsSection(),
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
                padding: const EdgeInsets.all(8.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    height: 100.0,
                    width: 100.0,
                    fit: BoxFit.cover,
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
