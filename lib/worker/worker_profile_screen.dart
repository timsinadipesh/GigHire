import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gighire/base_user/globals.dart';

class WorkerProfileScreen extends StatefulWidget {
  final String? userId; // Make userId optional, defaulting to global user ID

  const WorkerProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
}

class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
  Map<String, dynamic> userData = {};
  bool _isLoading = true;
  bool _isOwnProfile = false;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    // Determine the user ID to fetch
    var userId = widget.userId ?? globalUserId;

    // Check if this is the current user's own profile
    _isOwnProfile = (userId == globalUserId);

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User ID not found')),
      );
      return;
    }

    try {
      // Fetch user data from Firestore using the passed or global user ID
      final docSnapshot = await FirebaseFirestore.instance
          .collection('workers')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          userData = docSnapshot.data() ?? {};
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Worker not found')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching worker data: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Color(0xFF1a1a1a),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData.isEmpty) {
      return Scaffold(
        backgroundColor: Color(0xFF1a1a1a),
        body: Center(
          child: Text(
            'No user data available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Color(0xFF1a1a1a),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Header (remains the same)
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: userData['profileImage'] != null
                          ? NetworkImage(userData['profileImage'])
                          : null,
                      backgroundColor: Color(0xFF333333),
                      child: userData['profileImage'] == null
                          ? Icon(Icons.person, color: Colors.white, size: 50)
                          : null,
                    ),
                    SizedBox(height: 16),
                    Text(
                      userData['fullName'] ?? 'Unknown',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userData['jobTitle'] ?? 'No Title',
                      style: TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),


              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Row(
                  children: [
                    // Rating Box
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0), // Reduced padding
                        decoration: BoxDecoration(
                          color: Color(0xFF2a2a2a),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Rating:  ${(userData['rating'] ?? 0.0).toStringAsFixed(1)}/5',
                              style: TextStyle(
                                fontSize: 14.0, // Reduced font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 8.0), // Space between the two boxes

                    // Job Count Box
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0), // Reduced padding
                        decoration: BoxDecoration(
                          color: Color(0xFF2a2a2a),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Job count:  ${userData['job_count'] ?? 0}',
                              style: TextStyle(
                                fontSize: 14.0, // Reduced font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // About Section
              _buildSectionHeader('About'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Color(0xFF2a2a2a),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    userData['about'] ?? 'No description',
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
              ),

              // Skills Section
              _buildSectionHeader('Skills'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: (userData['skills'] as List? ?? [])
                      .map((skill) => Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Color(0xFF2a2a2a),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      skill,
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ))
                      .toList(),
                ),
              ),

              // Modify the Action Buttons section
              if (!_isOwnProfile)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Hire Now action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF4CAF50),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Hire Now',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                      SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            // Message action
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF2a2a2a),
                            padding: EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text(
                            'Message',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStatCard({required String value, required String label}) {
    return Container(
      width: 100,
      height: 60,
      decoration: BoxDecoration(
        color: Color(0xFF2a2a2a),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          Text(
            label,
            style: TextStyle(color: Color(0xFF888888), fontSize: 12),
          ),
        ],
      ),
    );
  }
}