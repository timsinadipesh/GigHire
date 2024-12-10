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
        SnackBar(content: Text('User ID not found')),
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
          SnackBar(content: Text('Client not found')),
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
      return Scaffold(
        backgroundColor: Color(0xFF1a1a1a),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (clientData.isEmpty) {
      return Scaffold(
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
                      backgroundImage: clientData['profileImage'] != null
                          ? NetworkImage(clientData['profileImage'])
                          : null,
                      backgroundColor: Color(0xFF333333),
                      child: clientData['profileImage'] == null
                          ? Icon(Icons.person, color: Colors.white, size: 50)
                          : null,
                    ),
                    SizedBox(height: 16),
                    Text(
                      clientData['fullName'] ?? 'Unknown',
                      style: TextStyle(
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

              // Logout Button at the bottom of the screen
              if (_isOwnProfile)
                const SizedBox(height: 40),
                Center(
                  child: SizedBox(
                    width: 250,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _logout,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFB71C1C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
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
