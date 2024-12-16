import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gighire/base_user/globals.dart';
import 'package:gighire/worker/job_details.dart';

class WorkerAppliedScreen extends StatefulWidget {
  const WorkerAppliedScreen({Key? key}) : super(key: key);

  @override
  _WorkerAppliedScreenState createState() => _WorkerAppliedScreenState();
}

class _WorkerAppliedScreenState extends State<WorkerAppliedScreen> {
  List<Job> appliedJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchAppliedJobs();
  }

  void _fetchAppliedJobs() async {
    try {
      debugPrint('Fetching jobs the worker has applied for');

      final jobsQuery = FirebaseFirestore.instance.collection('jobs');
      QuerySnapshot jobsSnapshot = await jobsQuery.get();

      debugPrint('Jobs query returned ${jobsSnapshot.docs.length} results.');

      List<Job> jobsList = [];
      for (var doc in jobsSnapshot.docs) {
        try {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          if ((data['applicants'] as List<dynamic>?)?.contains(globalUserId) ?? false) {
            jobsList.add(Job.fromFirestore(doc));
          }
        } catch (e) {
          debugPrint('Error parsing job document ${doc.id}: $e');
        }
      }

      setState(() {
        appliedJobs = jobsList;
      });
    } catch (e) {
      debugPrint("Error in _fetchAppliedJobs: $e");
      setState(() {
        appliedJobs = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Applied Jobs'),
        backgroundColor: const Color(0xFF2A2A2A),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: appliedJobs.isEmpty
              ? const Center(
            child: Text(
              'You haven\'t applied for any jobs yet.',
              style: TextStyle(color: Colors.white),
            ),
          )
              : ListView.builder(
            itemCount: appliedJobs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildJobCard(appliedJobs[index]),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(jobId: job.documentId),
          ),
        );
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Location: ${job.location}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Hourly Pay: \$${job.hourlyPay}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              'Deadline: ${job.deadline}',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 4),
            Text(
              job.description ?? 'No description provided.',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class Job {
  final String title;
  final String location;
  final String? description;
  final String hourlyPay;
  final String deadline;
  final String documentId;

  Job({
    required this.title,
    required this.location,
    this.description,
    required this.hourlyPay,
    required this.deadline,
    required this.documentId,
  });

  factory Job.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Job(
      title: data['jobTitle'] ?? 'Unknown',
      location: data['location'] ?? 'Not specified',
      description: data['problemDescription'] ?? 'No description provided',
      hourlyPay: data['hourlyPay']?.toString() ?? '0',
      deadline: data['deadline'] ?? 'No deadline specified',
      documentId: doc.id,
    );
  }
}
