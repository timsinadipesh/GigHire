import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gighire/chat/chat_page.dart';
import 'package:gighire/services/chat_service.dart';

class ChatList extends StatelessWidget {
  ChatList({super.key});

  final ChatService _chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chat",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[900],
        foregroundColor: Colors.green,
        elevation: 2,
      ),
      body: Container(
        color: Colors.grey[900],
        child: _buildUserList(),
      ),
    );
  }

  Future<String> getUserType() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user == null) {
      throw Exception("No user signed in");
    }

    var workerSnapshot = await FirebaseFirestore.instance
        .collection('workers')
        .doc(user.uid)
        .get();

    if (workerSnapshot.exists) {
      return "worker";
    }

    var clientSnapshot = await FirebaseFirestore.instance
        .collection('clients')
        .doc(user.uid)
        .get();

    if (clientSnapshot.exists) {
      return "client";
    }

    throw Exception("User type not found");
  }

  Widget _buildUserList() {
    return FutureBuilder<String>(
      future: getUserType(),
      builder: (context, userTypeSnapshot) {
        if (userTypeSnapshot.hasError) {
          return _buildErrorMessage("Error determining user type");
        }

        if (userTypeSnapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (!userTypeSnapshot.hasData) {
          return _buildErrorMessage("User type not found");
        }

        String userType = userTypeSnapshot.data!;

        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: userType == 'worker'
              ? _chatService.getClientsStream()
              : _chatService.getWorkersStream(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _buildErrorMessage("Error loading user list");
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildLoadingIndicator();
            }

            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return _buildEmptyState();
            }

            return ListView(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              children: snapshot.data!
                  .map<Widget>(
                      (userData) => _buildUserListItem(userData, context))
                  .toList(),
            );
          },
        );
      },
    );
  }

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    return Card(
      color: Colors.grey[800],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey[600],
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          userData["email"],
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: userData["email"],
                receiverID: userData["documentId"],
              ),
            ),
          );
        },
        // trailing: Icon(Icons.chat, color: Colors.greenAccent),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.greenAccent,
        strokeWidth: 2.5,
      ),
    );
  }

  Widget _buildErrorMessage(String message) {
    return Center(
      child: Text(
        message,
        style: const TextStyle(color: Colors.redAccent, fontSize: 16),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off, size: 80, color: Colors.grey[700]),
          const SizedBox(height: 20),
          Text(
            "No users found",
            style: TextStyle(color: Colors.grey[600], fontSize: 16),
          ),
        ],
      ),
    );
  }
}
