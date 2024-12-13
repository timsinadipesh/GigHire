import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gighire/Components/user_tile.dart';
import 'package:gighire/chat/chat_page.dart';
import 'package:gighire/services/chat_service.dart';

//manages the list of messages in a conversation.
class ChatList extends StatelessWidget {
  ChatList({super.key});

  // Chat and Auth services
  final ChatService _chatService = ChatService();
  // final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chat"),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: _buildUserList(),
    );
  }

  // Function to determine user type
  Future<String> getUserType() async {
    final FirebaseAuth auth = FirebaseAuth.instance;

    // Get the currently signed-in user
    User? user = auth.currentUser;

    if (user == null) {
      throw Exception("No user signed in");
    }

    // Check if user exists in the 'workers' collection
    var workerSnapshot = await FirebaseFirestore.instance
        .collection('workers')
        .doc(user.uid)
        .get();

    if (workerSnapshot.exists) {
      return "worker";
    }

    // Check if user exists in the 'clients' collection
    var clientSnapshot = await FirebaseFirestore.instance
        .collection('clients')
        .doc(user.uid)
        .get();

    if (clientSnapshot.exists) {
      return "client";
    }

    throw Exception("User type not found");
  }

  // Build a list of users based on user type
  Widget _buildUserList() {
    return FutureBuilder<String>(
      future: getUserType(), // Get the user type asynchronously
      builder: (context, userTypeSnapshot) {
        // Error handling for getUserType()
        if (userTypeSnapshot.hasError) {
          return const Center(
            child: Text("Error determining user type"),
          );
        }

        // Waiting for user type to resolve
        if (userTypeSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        // Check if userTypeSnapshot has data
        if (!userTypeSnapshot.hasData) {
          return const Center(
            child: Text("User type not found"),
          );
        }

        String userType = userTypeSnapshot.data!;

        // Build the StreamBuilder with the appropriate stream
        return StreamBuilder<List<Map<String, dynamic>>>(
          stream: userType == 'worker'
              ? _chatService.getClientsStream() // Show clients for workers
              : _chatService.getWorkersStream(), // Show workers for clients
          builder: (context, snapshot) {
            // Error handling for stream
            if (snapshot.hasError) {
              return const Center(
                child: Text("Error loading user list"),
              );
            }

            // Loading state for stream
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            // Check if snapshot has data
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No users found"),
              );
            }

            // Return list of users
            return ListView(
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

  // Build individual list tile for user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    return UserTile(
      text: userData["email"],
      onTap: () {
        // Tapped on a user -> go to chat page
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
    );
  }
}
