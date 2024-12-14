import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:gighire/base_user/globals.dart';

class MessagingScreen extends StatefulWidget {
  final String? otherUserId;

  const MessagingScreen({Key? key, this.otherUserId}) : super(key: key);

  @override
  _MessagingScreenState createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isSendingMessage = false;

  late String otherUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Retrieve `otherUserId` safely after the widget tree is built
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    otherUserId = args?['otherUserId'] ?? '';
    print('Initialized with otherUserId: $otherUserId');
  }

  // Ensure we have a valid current user before sending a message
  bool get _canSendMessage {
    return globalUserId != null &&
        _messageController.text.trim().isNotEmpty &&
        !_isSendingMessage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with $otherUserId'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _getMessagesStream(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final isSentByUser = message['senderId'] == globalUserId;

                    return _buildMessageBubble(message, isSentByUser);
                  },
                );
              },
            ),
          ),
          _buildMessageInputArea(),
        ],
      ),
    );
  }

  Stream<QuerySnapshot> _getMessagesStream() {
    // Ensure globalUserId is not null before creating stream
    if (globalUserId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('messages')
        .doc(_getChatId(globalUserId!, otherUserId))
        .collection('chats')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Widget _buildMessageBubble(DocumentSnapshot message, bool isSentByUser) {
    return Align(
      alignment: isSentByUser
          ? Alignment.centerRight
          : Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 8.0),
        decoration: BoxDecoration(
          color: isSentByUser ? Colors.blue : Colors.grey,
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          message['message'],
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildMessageInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}), // Update send button state
            ),
          ),
          const SizedBox(width: 8.0),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _canSendMessage ? _sendMessage : null,
            color: _canSendMessage ? Colors.blue : Colors.grey,
          ),
        ],
      ),
    );
  }

  String _getChatId(String userId1, String userId2) {
    // Ensure consistent chat ID creation
    // Sort user IDs to create a consistent chat room
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}-${sortedIds[1]}';
  }

  Future<void> _sendMessage() async {
    // Additional null and state checks
    if (!_canSendMessage) return;

    setState(() {
      _isSendingMessage = true;
    });

    try {
      final message = _messageController.text.trim();
      final chatId = _getChatId(globalUserId!, otherUserId);

      // Add the message
      await _firestore.collection('messages').doc(chatId).collection('chats').add({
        'message': message,
        'senderId': globalUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Update the chat metadata
      await _firestore.collection('messages').doc(chatId).set({
        'participants': [globalUserId, otherUserId],
        'lastMessage': message,
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Clear the message controller
      _messageController.clear();
    } catch (e) {
      // Show an error to the user
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),
      );
    } finally {
      setState(() {
        _isSendingMessage = false;
      });
    }
  }
}
