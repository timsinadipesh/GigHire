import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:badges/badges.dart' as badges; // For unread message badges
import 'package:lottie/lottie.dart'; // For animations
import 'package:gighire/base_user/globals.dart';
import 'package:intl/intl.dart'; // For Date Format

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  List<ChatPreview> _chats = [];
  bool _isLoading = false;
  String _searchQuery = "";

  Future<void> _fetchChats() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('participants', arrayContains: globalUserId)
          .get();

      List<ChatPreview> chats = [];
      for (var doc in querySnapshot.docs) {
        final lastMessageSnapshot = await doc.reference
            .collection('chats')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        final lastMessage = lastMessageSnapshot.docs.isNotEmpty
            ? lastMessageSnapshot.docs.first.data()
            : null;

        final participants = List<String>.from(doc.data()['participants'] ?? []);
        final otherUserId = participants.firstWhere((id) => id != globalUserId);

        // Fetch the other user's details (full name and profile URL)
        Map<String, String> otherUserDetails = await _getUserDetails(otherUserId);

        chats.add(ChatPreview.fromFirestore(
          doc.id,
          doc.data(),
          lastMessage,
          otherUserDetails['fullName'] ?? 'Unknown User',
          otherUserDetails['profileUrl'],
        ));
      }

      setState(() {
        _chats = chats;
      });
    } catch (e) {
      debugPrint("Error fetching chats: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Map<String, String>> _getUserDetails(String userId) async {
    try {
      // Check in the 'clients' collection
      final clientDoc = await FirebaseFirestore.instance
          .collection('clients')
          .doc(userId)
          .get();

      if (clientDoc.exists) {
        return {
          'fullName': clientDoc.data()?['fullName'] ?? 'Unknown User',
          'profileUrl': clientDoc.data()?['profileImage'] ?? '',
        };
      }

      // Check in the 'workers' collection if not found in 'clients'
      final workerDoc = await FirebaseFirestore.instance
          .collection('workers')
          .doc(userId)
          .get();

      if (workerDoc.exists) {
        return {
          'fullName': workerDoc.data()?['fullName'] ?? 'Unknown User',
          'profileUrl': workerDoc.data()?['profileImage'] ?? '',
        };
      }
    } catch (e) {
      debugPrint("Error fetching user details for $userId: $e");
    }

    // Default to unknown user and no profile URL if not found
    return {'fullName': 'Unknown User', 'profileUrl': ''};
  }

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (query) {
            setState(() {
              _searchQuery = query;
            });
          },
          decoration: const InputDecoration(
            hintText: "Search chats...",
            hintStyle: TextStyle(color: Colors.grey),
          ),
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: RefreshIndicator(
        onRefresh: _fetchChats,
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _chats.isEmpty
            ? Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/no_chats.json', width: 200),
              const SizedBox(height: 20),
              const Text(
                "No chats found.",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        )
            : ListView.builder(
          itemCount: _chats.length,
          itemBuilder: (context, index) {
            final chat = _chats[index];
            if (_searchQuery.isNotEmpty &&
                !chat.participants
                    .any((p) => p.toLowerCase().contains(_searchQuery.toLowerCase()))) {
              return const SizedBox.shrink();
            }
            return _buildChatTile(context, chat);
          },
        ),
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ChatPreview chat) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: Colors.grey.shade900,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade800,
        backgroundImage: chat.profileUrl != null && chat.profileUrl!.isNotEmpty
            ? NetworkImage(chat.profileUrl!)
            : null,
        child: chat.profileUrl == null || chat.profileUrl!.isEmpty
            ? Text(
          chat.otherUserFullName.substring(0, 2).toUpperCase(),
          style: const TextStyle(color: Colors.white),
        )
            : null,
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              chat.otherUserFullName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Text(
            chat.lastMessageTime ?? "",
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
      subtitle: Text(
        chat.lastMessage ?? "No messages yet.",
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: badges.Badge(
        badgeContent: Text(
          '${chat.unreadMessages}',
          style: const TextStyle(color: Colors.white, fontSize: 10),
        ),
        showBadge: chat.unreadMessages > 0,
        child: const Icon(Icons.chat_bubble, color: Colors.grey),
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/message',
          arguments: {
            'otherUserId': chat.participants.firstWhere((id) => id != globalUserId),
          },
        );
      },
    );
  }
}

class ChatPreview {
  final String chatId;
  final List<String> participants;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadMessages;
  final String otherUserFullName; // New field
  final String? profileUrl; // New field

  ChatPreview({
    required this.chatId,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadMessages = 0,
    required this.otherUserFullName,
    this.profileUrl,
  });

  factory ChatPreview.fromFirestore(
      String chatId,
      Map<String, dynamic> chatData,
      Map<String, dynamic>? lastMessage,
      String otherUserFullName,
      String? profileUrl) {
    String? formattedTime;
    if (lastMessage?['timestamp'] != null) {
      final timestamp = lastMessage!['timestamp'].toDate();
      formattedTime =
      '${DateFormat.Hm().format(timestamp)} • ${DateFormat('dd-MM-yyyy').format(timestamp)}';
    }

    return ChatPreview(
      chatId: chatId,
      participants: List<String>.from(chatData['participants'] ?? []),
      lastMessage: lastMessage?['message'] as String?,
      lastMessageTime: formattedTime,
      unreadMessages: chatData['unreadMessages'] ?? 0,
      otherUserFullName: otherUserFullName,
      profileUrl: profileUrl,
    );
  }
}
