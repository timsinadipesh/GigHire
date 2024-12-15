import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:gighire/base_user/globals.dart';

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
        _jobDetails = jobDoc.data() as Map<String, dynamic>?;
        await _fetchApplicants();
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

  Future<void> _fetchApplicants() async {
    try {
      List<dynamic> applicantIds = _jobDetails?['applicants'] ?? [];

      if (applicantIds.isNotEmpty) {
        QuerySnapshot applicantDocs = await _firestore
            .collection('workers')
            .where(FieldPath.documentId, whereIn: applicantIds)
            .get();

        _applicants = applicantDocs.docs.map((doc) {
          var data = doc.data() as Map<String, dynamic>;
          data['documentId'] = doc.id;
          return data;
        }).toList();
      }
    } catch (e) {
      _errorMessage = 'Failed to load applicants: ${e.toString()}';
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

  Widget _buildApplicantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Applicants',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        ..._applicants.map((applicant) {
          bool isApproved = applicant['status'] == 'approved'; // Check approval status

          return ListTile(
            onTap: () {
              global_from_client_jobs_posted_applicants = true;
              Navigator.pushNamed(
                context,
                '/worker_profile',
                arguments: {'userId': applicant['documentId']},
              );
            },
            leading: CircleAvatar(
              backgroundImage: NetworkImage(applicant['profileImage'] ?? ''),
              child: applicant['profileImage'] == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(
              applicant['fullName'] ?? 'Unknown',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              applicant['jobTitle'] ?? 'No profession specified',
              style: const TextStyle(color: Colors.white70),
            ),
            trailing: ElevatedButton(
              onPressed: isApproved
                  ? null // Disable button if already approved
                  : () async {
                try {
                  // Update the job status to "in_progress"
                  await _firestore.collection('jobs').doc(widget.jobId).update({
                    'status': 'in_progress',
                    'approvedApplicant': applicant['documentId'], // Example field
                  });

                  // Update local state to reflect the approval
                  setState(() {
                    applicant['status'] = 'approved';
                  });

                  // Show a success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${applicant['fullName']} approved'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  // Show an error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to approve applicant: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: isApproved ? Colors.grey : const Color(0xFF4CAF50),
              ),
              child: Text(isApproved ? 'Approved' : 'Approve'),
            ),
          );
        }).toList(),
      ],
    );
  }

}
