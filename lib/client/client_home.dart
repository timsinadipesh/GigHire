import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({Key? key}) : super(key: key);

  @override
  _ClientHomeScreenState createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  int _selectedIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  late Future<List<Map<String, dynamic>>> _workers;

  @override
  void initState() {
    super.initState();
    _workers = _fetchWorkers(); // Fetch workers from Firestore on initial load
  }

  Future<List<Map<String, dynamic>>> _fetchWorkers() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection('workers').get();
    return querySnapshot.docs.map((doc) {
      // Include the documentId in the data
      var workerData = doc.data() as Map<String, dynamic>;
      workerData['documentId'] = doc.id; // Add documentId to the worker data
      return workerData;
    }).toList();
  }

  void _onBottomNavItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      //post job
      case 1:
        Navigator.pushNamed(context, '/post_job').then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      // chat
      case 2:
        Navigator.pushNamed(context, '/chat_list').then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      //client profile
      case 3:
        Navigator.pushNamed(context, '/client_profile').then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      // case 4:
      //   Navigator.pushNamed(context, '/esewa_screen').then((_) {
      //     setState(() {
      //       _selectedIndex = 0;
      //     });
      //   });
      //   break;
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
                      _buildPopularWorkersSection(),
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
          _buildNavBarItem(Icons.post_add, 'Post Job', _selectedIndex == 1, 1),
          _buildNavBarItem(Icons.chat, 'chat', _selectedIndex == 2, 2),
          _buildNavBarItem(Icons.person, 'Profile', _selectedIndex == 3, 3),
          // _buildNavBarItem(Icons.payment, 'payment', _selectedIndex == 4, 4),
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
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search service Provider',
                hintStyle: TextStyle(color: Colors.grey[600]),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularWorkersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Workers',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        FutureBuilder<List<Map<String, dynamic>>>(
          // Fetching workers
          future: _workers,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return const Center(child: Text('Error loading workers'));
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No workers found'));
            }

            final workers = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: workers.length,
              itemBuilder: (context, index) {
                final worker = workers[index];
                return Padding(
                  padding: const EdgeInsets.only(
                      bottom: 16.0), // Space between profiles
                  child: _buildWorkerCard(
                    context: context,
                    name: worker['fullName'] ?? 'Unknown',
                    profession: worker['jobTitle'] ?? 'N/A',
                    rating: worker['rating']?.toString() ?? '0.0',
                    reviews: worker['reviews']?.toString() ?? '0',
                    address: worker['address'] ?? 'N/A',
                    hourlyRate:
                        worker['hourlyRate']?.toStringAsFixed(0) ?? 'N/A',
                    workExperience: worker['workExperience'] ?? 'N/A',
                    jobsCompleted: worker['jobsCompleted']?.toString() ?? '0',
                    profileImageUrl:
                        worker['profileImage'], // Get profile image URL
                    userId: worker['documentId'], // Pass the userId
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildWorkerCard({
    required BuildContext context,
    required String name,
    required String profession,
    required String rating,
    required String reviews,
    required String address,
    required String hourlyRate,
    required String workExperience,
    required String jobsCompleted,
    required String? profileImageUrl,
    required String userId, // Add userId as a parameter
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/worker_profile', // Ensure this route exists in your app
          arguments: {
            'userId': userId, // Pass the userId to the profile page
          },
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
            // Worker profile image
            ClipOval(
              child: profileImageUrl != null && profileImageUrl.isNotEmpty
                  ? Image.network(
                      profileImageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    )
                  : const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 50,
                    ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        address,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text(
                            profession,
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '($workExperience yr)', // Display work experience next to job title
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Rs. $hourlyRate/hr', // Display hourly rate at the far right
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            color: Color(0xFF4CAF50),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$rating ($reviews reviews)',
                            style: const TextStyle(
                              color: Color(0xFF4CAF50),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '$jobsCompleted jobs done',
                        style: TextStyle(
                          color:
                              Colors.white.withOpacity(0.8), // Brighter color
                          fontSize: 14,
                        ),
                      ),
                    ],
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
