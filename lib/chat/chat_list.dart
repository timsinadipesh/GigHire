import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gighire/base_user/globals.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  Future<List<ChatPreview>> _fetchChats() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('participants', arrayContains: globalUserId)
          .get();

      List<ChatPreview> chats = [];
      for (var doc in querySnapshot.docs) {
        // Fetch the last message from the 'chats' sub-collection
        final lastMessageSnapshot = await doc.reference
            .collection('chats')
            .orderBy('timestamp', descending: true)
            .limit(1)
            .get();

        final lastMessage = lastMessageSnapshot.docs.isNotEmpty
            ? lastMessageSnapshot.docs.first.data()
            : null;

        chats.add(ChatPreview.fromFirestore(doc.id, doc.data(), lastMessage));
      }

      return chats;
    } catch (e) {
      debugPrint("Error fetching chats: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Chats"),
        backgroundColor: const Color(0xFF1A1A1A),
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      body: FutureBuilder<List<ChatPreview>>(
        future: _fetchChats(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(
              child: Text(
                "Failed to load chats.",
                style: TextStyle(color: Colors.white),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                "No chats found.",
                style: TextStyle(color: Colors.white),
              ),
            );
          } else {
            final chats = snapshot.data!;
            return ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                final chat = chats[index];
                return _buildChatTile(context, chat);
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildChatTile(BuildContext context, ChatPreview chat) {
    // Exclude the current user ID to find the other participant
    final otherUserId = chat.participants.firstWhere((id) => id != globalUserId);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      tileColor: const Color(0xFF2A2A2A),
      title: Text(
        chat.participants.join(', '),
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        chat.lastMessage ?? "No messages yet.",
        style: const TextStyle(color: Colors.grey),
      ),
      trailing: Text(
        chat.lastMessageTime ?? "",
        style: const TextStyle(color: Colors.grey, fontSize: 12),
      ),
      onTap: () {
        Navigator.pushNamed(
          context,
          '/message',
          arguments: {
            'chatId': chat.chatId,
            'otherUserId': otherUserId,
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

  ChatPreview({
    required this.chatId,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory ChatPreview.fromFirestore(
      String chatId, Map<String, dynamic> chatData, Map<String, dynamic>? lastMessage) {
    return ChatPreview(
      chatId: chatId,
      participants: List<String>.from(chatData['participants'] ?? []),
      lastMessage: lastMessage?['message'] as String?,
      lastMessageTime: lastMessage?['timestamp']?.toDate().toString(),
    );
  }
}
