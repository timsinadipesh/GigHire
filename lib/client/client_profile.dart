import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gighire/base_user/globals.dart';

class ClientProfileScreen extends StatefulWidget {
  final String? userId;

  const ClientProfileScreen({Key? key, this.userId}) : super(key: key);

  @override
  State<ClientProfileScreen> createState() => _ClientProfileScreenState();
}

class _ClientProfileScreenState extends State<ClientProfileScreen> {
  Map<String, dynamic> clientData = {};
  bool _isLoading = true;
  bool _isOwnProfile = false;

  @override
  void initState() {
    super.initState();
    _fetchClientData();
  }

  Future<void> _fetchClientData() async {
    var userId = widget.userId ?? globalUserId;
    _isOwnProfile = (userId == globalUserId);

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
      return;
    }

    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('clients')
          .doc(userId)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          clientData = docSnapshot.data() ?? {};
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Client not found')),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching client data: $e')),
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
      await FirebaseAuth.instance.signOut();
      setState(() {
        globalUserId = null;
      });
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error logging out: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1a1a1a),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (clientData.isEmpty) {
      return const Scaffold(
        backgroundColor: Color(0xFF1a1a1a),
        body: Center(
          child: Text(
            'No client data available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: clientData['profileImage'] != null
                          ? NetworkImage(clientData['profileImage'])
                          : null,
                      backgroundColor: const Color(0xFF333333),
                      child: clientData['profileImage'] == null
                          ? const Icon(Icons.person, color: Colors.white, size: 50)
                          : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      clientData['fullName'] ?? 'Unknown',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
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
                value: clientData['email'] ?? 'Not provided',
              ),
              _buildInfoCard(
                icon: Icons.phone,
                title: 'Phone Number',
                value: clientData['phoneNumber'] ?? 'Not provided',
              ),
              _buildInfoCard(
                icon: Icons.location_on,
                title: 'Address',
                value: clientData['address'] ?? 'Not provided',
              ),
              _buildInfoCard(
                icon: Icons.calendar_today,
                title: 'Joined',
                value: _formatDate(clientData['createdAt']),
              ),

              // Conditionally show Logout or Message Now button
              const SizedBox(height: 40),
              Center(
                child: SizedBox(
                  width: 250,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isOwnProfile
                        ? _logout // Logout for profile owner
                        : () {
                      if (widget.userId != null) {
                        Navigator.pushNamed(
                          context,
                          '/message', // Route for messaging
                          arguments: {'otherUserId': widget.userId}, // Pass profile userId
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Unable to message this user.')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isOwnProfile
                          ? const Color(0xFFB71C1C) // Red for logout
                          : const Color(0xFF4CAF50), // Green for "Message Now"
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      _isOwnProfile ? 'Logout' : 'Message Now',
                      style: const TextStyle(
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

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2a2a2a),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
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

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
