import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:gighire/base_user/globals.dart';

class WorkerJobsListScreen extends StatefulWidget {
  final String statusFilter;

  const WorkerJobsListScreen({Key? key, required this.statusFilter}) : super(key: key);

  @override
  _WorkerJobsListScreenState createState() => _WorkerJobsListScreenState();
}

class _WorkerJobsListScreenState extends State<WorkerJobsListScreen> {
  late Future<List<Map<String, dynamic>>> _jobs;

  @override
  void initState() {
    super.initState();
    _jobs = _fetchJobs();
  }

  Future<List<Map<String, dynamic>>> _fetchJobs() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('jobs')
        .where('applicants', arrayContains: globalUserId) // Check if the user is an applicant
        .where('status', isEqualTo: widget.statusFilter) // Filter by status
        .orderBy('postedAt', descending: true) // Order by most recent
        .get();

    return querySnapshot.docs.map((doc) {
      var jobData = doc.data() as Map<String, dynamic>;
      jobData['documentId'] = doc.id; // Add documentId to the job data
      return jobData;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: Text(
          _getPageTitle(),
          style: const TextStyle(fontSize: 20),
        ),
        backgroundColor: const Color(0xFF4CAF50),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _jobs,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return const Center(child: Text('Error loading jobs'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No jobs available'));
          }

          final jobs = snapshot.data!;
          return ListView.builder(
            itemCount: jobs.length,
            itemBuilder: (context, index) {
              final job = jobs[index];
              return _buildJobCard(job);
            },
          );
        },
      ),
    );
  }

  String _getPageTitle() {
    switch (widget.statusFilter) {
      case 'postings':
        return 'Applied Jobs';
      case 'in_progress':
        return 'Jobs In Progress';
      case 'complete':
        return 'Completed Jobs';
      default:
        return 'Jobs';
    }
  }

  Widget _buildJobCard(Map<String, dynamic> job) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job title and location
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                job['jobTitle'] ?? 'No Title',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                job['location'] ?? 'No Location',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Problem description
          Text(
            job['problemDescription'] ?? 'No Description',
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),

          // Hourly pay and deadline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '\$${job['hourlyPay'] ?? '0'}/hr',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              Text(
                'Deadline: ${job['deadline'] ?? 'N/A'}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // PostedAt timestamp
          Text(
            'Posted At: ${job['postedAt'] != null ? DateFormat('hh:mm a, dd-MM-yyyy').format((job['postedAt'] as Timestamp).toDate()) : 'N/A'}',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
