import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gighire/client/client_job_details.dart';
import 'package:gighire/base_user/globals.dart'; // Import for global userId

class ClientPostsScreen extends StatefulWidget {
  const ClientPostsScreen({Key? key}) : super(key: key);

  @override
  _ClientPostsScreenState createState() => _ClientPostsScreenState();
}

class _ClientPostsScreenState extends State<ClientPostsScreen> {
  List<Job> postedJobs = [];

  @override
  void initState() {
    super.initState();
    _fetchPostedJobs();
  }

  void _fetchPostedJobs() async {
    try {
      final jobsQuery = FirebaseFirestore.instance
          .collection('jobs')
          .where('userId', isEqualTo: globalUserId) // Filter by client ID
          .where('status', isEqualTo: 'postings'); // Filter by status "postings"

      QuerySnapshot jobsSnapshot = await jobsQuery.get();
      List<Job> jobsList = jobsSnapshot.docs.map((doc) {
        return Job.fromFirestore(doc);
      }).toList();

      setState(() {
        postedJobs = jobsList;
      });
    } catch (e) {
      debugPrint('Error fetching posted jobs: $e');
      setState(() {
        postedJobs = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        title: const Text('Jobs Posted'),
        backgroundColor: const Color(0xFF2A2A2A),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: postedJobs.isEmpty
              ? const Center(
            child: Text(
              'You haven\'t posted any jobs yet.',
              style: TextStyle(color: Colors.white),
            ),
          )
              : ListView.builder(
            itemCount: postedJobs.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildJobCard(postedJobs[index]),
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
            builder: (context) => ClientJobDetailsScreen(jobId: job.documentId),
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
              'Hourly Pay: Rs.${job.hourlyPay}',
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
