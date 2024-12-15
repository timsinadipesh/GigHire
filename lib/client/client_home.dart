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
    final querySnapshot = await FirebaseFirestore.instance.collection('workers').get();
    return querySnapshot.docs.map((doc) {
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
        break; // Home
      case 1:
        Navigator.pushNamed(context, '/post_job').then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      case 2:
        Navigator.pushNamed(context, '/chat_list').then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
      case 3:
        Navigator.pushNamed(context, '/client_profile').then((_) {
          setState(() {
            _selectedIndex = 0;
          });
        });
        break;
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildServiceManagementSection(),
                    _buildPopularWorkersSection(),
                  ],
                ),
              ),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceManagementSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildServiceButton('Postings'),
              _buildServiceButton('In Progress'),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildServiceButton('History'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceButton(String label) {
    return ElevatedButton(
      onPressed: () {}, // Placeholder for functionality
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4CAF50), // Green color
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

  Widget _buildPopularWorkersSection() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
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
            future: _workers,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const Center(child: Text('Error loading workers')),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: const Center(child: Text('No workers found')),
                );
              }

              final workers = snapshot.data!;
              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: workers.length,
                itemBuilder: (context, index) {
                  final worker = workers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: _buildWorkerCard(
                      context: context,
                      name: worker['fullName'] ?? 'Unknown',
                      profession: worker['jobTitle'] ?? 'N/A',
                      rating: worker['rating']?.toString() ?? '0.0',
                      reviews: worker['reviews']?.toString() ?? '0',
                      address: worker['address'] ?? 'N/A',
                      hourlyRate: worker['hourlyRate']?.toStringAsFixed(0) ?? 'N/A',
                      workExperience: worker['workExperience'] ?? 'N/A',
                      jobsCompleted: worker['jobsCompleted']?.toString() ?? '0',
                      profileImageUrl: worker['profileImage'],
                      userId: worker['documentId'],
                    ),
                  );
                },
              );
            },
          ),
        ],
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
          _buildNavBarItem(Icons.chat, 'Chat', _selectedIndex == 2, 2),
          _buildNavBarItem(Icons.person, 'Profile', _selectedIndex == 3, 3),
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
    required String userId,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(
          context,
          '/worker_profile',
          arguments: {'userId': userId},
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
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        profession,
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
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
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$workExperience yr experience',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'Rs. $hourlyRate/hr',
                        style: const TextStyle(
                          color: Colors.white,
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
