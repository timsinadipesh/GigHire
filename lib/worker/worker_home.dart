import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gighire/base_user/globals.dart';
import 'package:gighire/worker/job_details.dart';

class WorkerHomeScreen extends StatefulWidget {
  const WorkerHomeScreen({Key? key}) : super(key: key);

  @override
  _WorkerHomeScreenState createState() => _WorkerHomeScreenState();
}

class _WorkerHomeScreenState extends State<WorkerHomeScreen> {
  int _selectedIndex = 0;
  String? jobTitle; // The job title of the current logged-in user
  List<Job> recentJobs = []; // List to store recent jobs

  // Method to handle bottom navigation item taps
  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        // Already on home screen, do nothing
        break;
      case 1:
        // Navigate to search screen
        Navigator.pushNamed(context, '/search').then((_) {
          setState(() {
            _selectedIndex =
                0; // Reset to Home after returning from search page
          });
        });
        break;
      //chat
      case 2:
        // Navigate to search screen
        Navigator.pushNamed(context, '/chat_list').then((_) {
          setState(() {
            _selectedIndex =
                0; // Reset to Home after returning from search page
          });
        });
        break;
      //profile
      case 3:
        // Navigate to profile screen
        debugPrint('Navigating to worker profile with userId: $globalUserId');
        Navigator.pushNamed(context, '/worker_profile',
            arguments: {"userId": globalUserId}).then((_) {
          setState(() {
            _selectedIndex =
                0; // Reset to Home after returning from profile page
          });
        });
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    if (mounted) {
      _fetchUserJobTitle(); // Ensure widget is mounted before fetching
    }
  }

  void _fetchUserJobTitle() async {
    final userDoc =
        FirebaseFirestore.instance.collection('workers').doc(globalUserId);
    DocumentSnapshot snapshot = await userDoc.get();

    if (snapshot.exists) {
      debugPrint('User Document Data: ${snapshot.data()}');
      setState(() {
        jobTitle = snapshot.get('jobTitle'); // Check field name here
      });
      debugPrint('Job Title fetched EXACTLY: $jobTitle');
      if (mounted) _fetchRecentJobs(); // Ensure _fetchRecentJobs is called
    }
  }

  void _fetchRecentJobs() async {
    try {
      debugPrint('Fetching all recent jobs');

      final jobsQuery = FirebaseFirestore.instance
          .collection('jobs')
          // .orderBy('timestamp', descending: true)
          .limit(10); // Increased limit to show more jobs

      QuerySnapshot jobsSnapshot = await jobsQuery.get();

      debugPrint('Jobs query returned ${jobsSnapshot.docs.length} results.');

      if (jobsSnapshot.docs.isNotEmpty) {
        List<Job> jobsList = jobsSnapshot.docs.map((doc) {
          debugPrint('Job Data: ${doc.data()}');
          return Job.fromFirestore(doc);
        }).toList();

        if (mounted) {
          setState(() {
            recentJobs = jobsList;
            debugPrint('Updated recentJobs: ${recentJobs.length}');
          });
        }
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
                      _buildSearchBar(),
                      const SizedBox(height: 24),
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
          _buildNavBarItem(Icons.search, 'Search', _selectedIndex == 1, 1),
          _buildNavBarItem(Icons.chat, 'chat', _selectedIndex == 2, 2),
          _buildNavBarItem(Icons.person, 'Profile', _selectedIndex == 3, 3),
        ],
      ),
    );
  }

  Widget _buildNavBarItem(
      IconData icon, String label, bool isSelected, int index) {
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

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 50,
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.search, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              style: const TextStyle(color: Colors.grey),
              decoration: InputDecoration(
                hintText: 'Search for jobs...',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
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
            children: recentJobs
                .map((job) => Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildJobCard(job)))
                .toList(),
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: const BoxDecoration(
                // Added const here
                color: Color(0xFF333333),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title ?? 'Unknown Title', // Null check for job.title
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    job.location != null && job.location!.isNotEmpty
                        ? job.location!
                        : 'Location: Not specified', // Provide a default value
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
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
  final int timestamp;
  final String documentId; // Add this property

  Job({
    required this.title,
    required this.location,
    this.description,
    required this.timestamp,
    required this.documentId,
  });

  // Factory constructor to create a Job object from Firestore DocumentSnapshot
  factory Job.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      debugPrint('Parsing job document: ${doc.id}, Data: $data');

      return Job(
        title: data['jobTitle'] ?? 'Unknown',
        location: data['location'] ?? 'Remote',
        description: data['description'],
        timestamp: (data['timestamp'] is Timestamp)
            ? (data['timestamp'] as Timestamp).millisecondsSinceEpoch
            : data['timestamp'] ?? 0,
        documentId: doc.id, // Set documentId from the snapshot
      );
    } catch (e) {
      debugPrint('Error parsing job document ${doc.id}: $e');
      rethrow;
    }
  }
}
