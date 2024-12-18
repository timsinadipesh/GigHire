import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gighire/base_user/globals.dart';
import 'package:gighire/worker/job_details.dart';

class WorkerInProgressScreen extends StatefulWidget {
  const WorkerInProgressScreen({Key? key}) : super(key: key);

  @override
  _WorkerInProgressScreenState createState() => _WorkerInProgressScreenState();
}

class _WorkerInProgressScreenState extends State<WorkerInProgressScreen> {
  List<Job> inProgressJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchInProgressJobs();
  }

  void _fetchInProgressJobs() async {
    try {
      debugPrint('Fetching jobs with status "in_progress" where the worker has applied');

      final jobsQuery = FirebaseFirestore.instance
          .collection('jobs')
          .where('status', isEqualTo: 'in_progress'); // Filter by status "in_progress"

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
        inProgressJobs = jobsList;
      });
    } catch (e) {
      debugPrint("Error in _fetchInProgressJobs: $e");
      setState(() {
        inProgressJobs = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('In-Progress Jobs'),
        backgroundColor: const Color(0xFF2A2A2A),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: inProgressJobs.isEmpty
              ? const Center(
            child: Text(
              'You don\'t have any in-progress jobs.',
              style: TextStyle(color: Colors.white),
            ),
          )
              : ListView.builder(
            itemCount: inProgressJobs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildJobCard(inProgressJobs[index]),
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
