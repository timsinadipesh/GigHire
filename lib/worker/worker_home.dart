import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gighire/base_user/globals.dart';

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
            _selectedIndex = 0;  // Reset to Home after returning from search page
          });
        });
        break;
      case 2:
      // Navigate to profile screen
        Navigator.pushNamed(context, '/worker_profile').then((_) {
          setState(() {
            _selectedIndex = 0;  // Reset to Home after returning from profile page
          });
        });
        break;
    }
  }

  @override
  void initState() {
    super.initState();
    _fetchUserJobTitle(); // Fetch job title when screen loads
  }

  void _fetchUserJobTitle() async {
    final userDoc = FirebaseFirestore.instance.collection('workers').doc(globalUserId);
    DocumentSnapshot snapshot = await userDoc.get();

    if (snapshot.exists) {
      print('User Document Data: ${snapshot.data()}');
      setState(() {
        jobTitle = snapshot.get('jobTitle'); // Check field name here
      });
      print('Job Title fetched EXACTLY: $jobTitle');
      if (mounted) _fetchRecentJobs(); // Ensure _fetchRecentJobs is called
    }
  }

  void _fetchRecentJobs() async {
    print('Starting to fetch recent jobs...');
    if (jobTitle == null) {
      print('jobTitle is null. Exiting _fetchRecentJobs.');
      return;
    }
    try {
      print('Fetching jobs for jobTitle: $jobTitle');

      // Fetch jobs filtered by jobTitle and sorted by timestamp
      final jobTitleQuery = FirebaseFirestore.instance
          .collection('jobs')
          .where('jobTitle', isEqualTo: jobTitle) // Case-sensitive check
          .orderBy('timestamp', descending: true)
          .limit(5);

      QuerySnapshot titleSnapshot = await jobTitleQuery.get();

      print('jobTitleQuery returned ${titleSnapshot.docs.length} results.');
      for (var doc in titleSnapshot.docs) {
        print('Document ID: ${doc.id}');
        print('Data: ${doc.data()}');
      }

      // Check if jobs exist for the given title
      if (titleSnapshot.docs.isNotEmpty) {
        List<Job> jobsList = titleSnapshot.docs.map((doc) {
          print('Matched Job Data: ${doc.data()}');
          return Job.fromFirestore(doc);
        }).toList();

        if (mounted) {
          setState(() {
            recentJobs = jobsList;
            print('Updated recentJobs: ${recentJobs.length}');
          });
        }
      } else {
        print('No jobs found for job title: $jobTitle');
        if (mounted) {
          setState(() {
            recentJobs = []; // Clear previous jobs
          });
        }
      }
    } catch (e) {
      print("Error in _fetchRecentJobs: $e");
      if (mounted) {
        setState(() {
          recentJobs = []; // Clear on error
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
    // Debug print to check job title and recent jobs
    print('Job Title: $jobTitle');
    print('Recent Jobs Count: ${recentJobs.length}');

    if (jobTitle == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent $jobTitle Jobs',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        // Change the condition to explicitly check recentJobs
        if (recentJobs.isEmpty)
          const Text(
            'No recent jobs found for your job title.',
            style: TextStyle(color: Colors.white),
          )
        else
        // Wrap job cards in a Column to ensure they are displayed vertically
          Column(
            children: recentJobs.map((job) =>
                Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: _buildJobCard(job)
                )
            ).toList(),
          ),
      ],
    );
  }

  Widget _buildJobCard(Job job) {
    return Container(
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
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.title, // Job title
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  job.location ?? 'Location: Remote', // Job location
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
    );
  }
}

// Model to represent a Job
class Job {
  final String title;
  final String location;
  final String? description;
  final int timestamp;

  Job({
    required this.title,
    required this.location,
    this.description,
    required this.timestamp,
  });

  // Factory constructor to create a Job object from Firestore DocumentSnapshot
  factory Job.fromFirestore(DocumentSnapshot doc) {
    try {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      print('Parsing job document: ${doc.id}, Data: $data');

      return Job(
        title: data['jobTitle'] ?? 'Unknown',
        location: data['location'] ?? 'Remote',
        description: data['description'],
        // Convert Firestore Timestamp to milliseconds since epoch
        timestamp: (data['timestamp'] is Timestamp)
            ? (data['timestamp'] as Timestamp).millisecondsSinceEpoch
            : data['timestamp'] ?? 0,
      );
    } catch (e) {
      print('Error parsing job document ${doc.id}: $e');
      rethrow;
    }
  }
}
