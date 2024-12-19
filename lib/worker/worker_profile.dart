  import 'package:cached_network_image/cached_network_image.dart';
  import 'package:flutter/material.dart';
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';

  class WorkerProfileScreen extends StatefulWidget {
    final String? userId;  // Keep it nullable

    const WorkerProfileScreen({Key? key, this.userId}) : super(key: key);

    @override
    State<WorkerProfileScreen> createState() => _WorkerProfileScreenState();
  }

  class _WorkerProfileScreenState extends State<WorkerProfileScreen> {
    Map<String, dynamic> userData = {};
    bool _isLoading = true;
    bool _isOwnProfile = false;
    List<Map<String, dynamic>> reviews = [];

    @override
    void initState() {
      super.initState();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // First try to use the directly passed userId
        String? userIdToUse = widget.userId;

        // If no direct userId, try to get it from route arguments
        if (userIdToUse == null) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
          userIdToUse = args?['userId'];
        }

        // If still no userId, use current user's ID
        // userIdToUse ??= FirebaseAuth.instance.currentUser?.uid;

        if (userIdToUse != null) {
          print('Fetching data for worker ID: $userIdToUse'); // Debug print
          _fetchUserData(userIdToUse);
        } else {
          print('No user ID available from any source'); // Debug print
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('User ID not found')),
          );
          setState(() {
            _isLoading = false;
          });
        }
      });
    }

    Future<int> _countReviews(String userId) async {
      try {
        final jobsSnapshot = await FirebaseFirestore.instance
            .collection('jobs')
            .where('approvedApplicant', isEqualTo: userId)
            .where('clientRated', isEqualTo: true)
            .get();

        return jobsSnapshot.docs.length;
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error counting reviews: $e')),
        );
        return 0;
      }
    }

    Future<void> _fetchUserData(String userId) async {
      _isOwnProfile = (userId == FirebaseAuth.instance.currentUser?.uid);

      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('workers')
            .doc(userId)
            .get();

        if (docSnapshot.exists) {
          final count = await _countReviews(userId);
          setState(() {
            userData = docSnapshot.data() ?? {};
            userData['reviewCount'] = count; // Add review count to userData
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

    // Helper method to format date
    String _formatDate(Timestamp? timestamp) {
      if (timestamp == null) return 'N/A';
      DateTime dateTime = timestamp.toDate();
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }

    // Handle Logout
    Future<void> _logout() async {
      try {
        // Sign out from Firebase Authentication
        await FirebaseAuth.instance.signOut();
        // Navigate to the login screen
        Navigator.pushReplacementNamed(context, '/login');
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error logging out: $e')),
        );
      }
    }

    Future<void> _fetchReviews(String userId) async {
      try {
        final jobsSnapshot = await FirebaseFirestore.instance
            .collection('jobs')
            .where('approvedApplicant', isEqualTo: userId)
            .where('clientRated', isEqualTo: true)
            .get();

        final fetchedReviews = jobsSnapshot.docs.map((doc) {
          return {
            'review': doc.data()['review'] ?? '',
            'rating': doc.data()['rating'] ?? 0,
          };
        }).toList();

        setState(() {
          reviews = fetchedReviews;
        });

        _showReviewsDialog();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching reviews: $e')),
        );
      }
    }

    void _showReviewsDialog() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Reviews'),
            content: reviews.isEmpty
                ? Text('No reviews available.')
                : Column(
              mainAxisSize: MainAxisSize.min,
              children: reviews.map((review) {
                return ListTile(
                  title: Text(review['review']),
                  subtitle: Text('Rating: ${review['rating']}'),
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
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

      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final userId = args != null ? args['userId'] : FirebaseAuth.instance.currentUser?.uid;

      return Scaffold(
        backgroundColor: Color(0xFF1a1a1a),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.only(top: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF2a2a2a),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Rating: ${(userData['totalRating'] != null ? (userData['totalRating'] / 5).toStringAsFixed(1) : '0.0')}/5',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),
                      // Job Count Box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF2a2a2a),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Job count:  ${userData['jobCount'] ?? 0}',
                                style: TextStyle(
                                  fontSize: 14.0,
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

                // rate and experience row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                  child: Row(
                    children: [
                      // Hourly Pricing Box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF2a2a2a),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Pricing/Hr:  ${(userData['hourlyRate']?.toInt() ?? 0)}',
                                style: TextStyle(
                                  fontSize: 14.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(width: 8.0),

                      // Experience box
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 8.0),
                          decoration: BoxDecoration(
                            color: Color(0xFF2a2a2a),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Experience: ${userData['workExperience'] ?? 0} yr',
                                style: TextStyle(
                                  fontSize: 14.0,
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

                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: ElevatedButton(
                      onPressed: () {
                        if (userId != null) {
                          _fetchReviews(userId);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('User ID is null')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4CAF50),
                        padding: EdgeInsets.symmetric(vertical: 12),
                        minimumSize: Size(200, 40),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        '${userData['reviewCount'] ?? 0} Reviews',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                ),

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
                              final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
                              var userId = args['userId'];
                              if (userId != null) {
                                Navigator.pushNamed(
                                  context,
                                  '/message',
                                  arguments: {'otherUserId': userId},
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Unable to message the job poster.')),
                                );
                              }
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

                // Contact Information Section
                _buildSectionHeader('Contact Information'),
                _buildInfoCard(
                  icon: Icons.email,
                  title: 'Email',
                  value: userData['email'] ?? 'Not provided',
                ),
                _buildInfoCard(
                  icon: Icons.phone,
                  title: 'Phone Number',
                  value: userData['phoneNumber'] ?? 'Not provided',
                ),
                _buildInfoCard(
                  icon: Icons.location_on,
                  title: 'Address',
                  value: userData['address'] ?? 'Not provided',
                ),
                _buildInfoCard(
                  icon: Icons.calendar_today,
                  title: 'Joined',
                  value: _formatDate(userData['createdAt']),
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

                // Certifications Section
                _buildSectionHeader('Certifications'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildCertificationGallery(
                    certifications: (userData['certifications'] as List?) ?? [],
                  ),
                ),

                const SizedBox(height: 40),
                if (_isOwnProfile)
                  Center(
                    child: SizedBox(
                      width: 250,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _logout,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFB71C1C),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          'Logout',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      );
    }

    // Helper method to create information cards
    Widget _buildInfoCard({
      required IconData icon,
      required String title,
      required String value,
    }) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Color(0xFF2a2a2a),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, color: Colors.white, size: 24),
              SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: Color(0xFF888888),
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    value,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // New helper method for certifications gallery
    Widget _buildCertificationGallery({required List certifications}) {
      if (certifications.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'No certifications',
            style: TextStyle(color: Colors.white),
          ),
        );
      }

      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: certifications.map<Widget>((certUrl) {
            return Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: GestureDetector(
                onTap: () {
                  // Optional: Implement full-screen image view
                  _showCertificationDialog(certUrl);
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Color(0xFF2a2a2a),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: certUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Center(
                      child: CircularProgressIndicator(),
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      );
    }

    // Optional: Method to show certification in full screen
    void _showCertificationDialog(String certUrl) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: CachedNetworkImage(
              imageUrl: certUrl,
              fit: BoxFit.contain,
              placeholder: (context, url) => Center(
                child: CircularProgressIndicator(),
              ),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          );
        },
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
  }
