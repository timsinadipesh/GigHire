import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gighire/base_user/globals.dart';
import 'package:gighire/service_management/worker_applied.dart';
import 'package:gighire/service_management/worker_complete.dart';
import 'package:gighire/service_management/worker_in_progress.dart';
import 'package:gighire/worker/job_details.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({Key? key}) : super(key: key);

  @override
  _WorkerHomeScreenState createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  int _selectedIndex = 0;
  String? jobTitle;
  List<Job> recentJobs = [];

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1: // Chat button
        Navigator.pushNamed(
          context,
          '/chat_list',
        ).then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      case 2: // Profile button
        debugPrint('Navigating to worker profile with userId: $globalUserId');
        Navigator.pushNamed(
          context,
          '/worker_profile',
          arguments: {"userId": globalUserId},
        ).then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _fetchUserJobTitle();
    }
  }

  void _fetchUserJobTitle() async {
    final userDoc = FirebaseFirestore.instance.collection('workers').doc(globalUserId);
    DocumentSnapshot snapshot = await userDoc.get();

    if (snapshot.exists) {
      debugPrint('User Document Data: ${snapshot.data()}');
      setState(() {
        jobTitle = snapshot.get('jobTitle');
      });
      if (mounted) _fetchRecentJobs();
    }
  }

  void _fetchRecentJobs() async {
    try {
      debugPrint('Fetching all recent jobs');

      final jobsQuery = FirebaseFirestore.instance.collection('jobs').limit(10);
      QuerySnapshot jobsSnapshot = await jobsQuery.get();

      debugPrint('Jobs query returned ${jobsSnapshot.docs.length} results.');

      if (jobsSnapshot.docs.isNotEmpty) {
        List<Job> jobsList = [];
        for (var doc in jobsSnapshot.docs) {
          try {
            debugPrint('Job Data: ${doc.data()}');
            jobsList.add(Job.fromFirestore(doc));
          } catch (e) {
            debugPrint('Error parsing job document ${doc.id}: $e');
          }
        }
        setState(() {
          recentJobs = jobsList;
        });
      } else {
        debugPrint('No jobs found');
        if (mounted) {
          setState(() {
            recentJobs = [];
          });
        }
      }
    } catch (e) {
      debugPrint("Error in _fetchRecentJobs: $e");
      if (mounted) {
        setState(() {
          recentJobs = [];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Column(
          children: [
            _buildTitle(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildServiceManagementSection(),
                      const SizedBox(height: 16),
                      _buildRecentJobsSection(),
                    ],
                  ),
                ),
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      color: const Color(0xFF2A2A2A),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavBarItem(Icons.home, 'Home', _selectedIndex == 0, 0),
          _buildNavBarItem(Icons.chat, 'Chat', _selectedIndex == 1, 1), // Updated to Chat
          _buildNavBarItem(Icons.person, 'Profile', _selectedIndex == 2, 2),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(IconData icon, String label, bool isSelected, int index) {
    return GestureDetector(
      onTap: () => _onBottomNavItemTapped(index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? const Color(0xFF4CAF50) : Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: const Text(
        'GigHire',
        style: TextStyle(
          color: Color(0xFF4CAF50),
          fontSize: 20,
          fontWeight: FontWeight.bold,
          fontFamily: 'Arial',
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildServiceManagementSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Service Management',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 16,
          runSpacing: 16,
          children: [
            // _buildServiceButton('Applied Jobs', Icons.assignment, 'postings'),
            _buildServiceButton('Applied Jobs', Icons.assignment, 'applied_jobs'),
            _buildServiceButton('Jobs in-progress', Icons.work, 'in_progress'),
            _buildServiceButton('Completed Jobs', Icons.check_circle, 'complete'),
          ],
        ),
      ],
    );
  }

  Widget _buildServiceButton(String label, IconData icon, String destination) {
    return SizedBox(
      width: (MediaQuery.of(context).size.width - 64) / 2, // Ensures two buttons per row
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2A2A2A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        onPressed: () {
          if (destination == 'applied_jobs') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WorkerAppliedScreen(),
              ),
            );
          } else if (destination == 'in_progress') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WorkerInProgressScreen(),
              ),
            );
          } else if (destination == 'complete') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const WorkerCompleteScreen(),
              ),
            );
          }
        },
        child: Column(
          children: [
            Icon(icon, color: const Color(0xFF4CAF50)),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentJobsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Jobs',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        if (recentJobs.isEmpty)
          const Text(
            'No recent jobs found.',
            style: TextStyle(color: Colors.white),
          )
        else
          Column(
            children: recentJobs.map((job) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: _buildJobCard(job),
            )).toList(),
          ),
      ],
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
        width: double.infinity, // Ensures it takes the full available width
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
