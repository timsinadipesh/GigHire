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
  String otherUserName = ""; // To store the name of the other participant

  // 1. Declare the ScrollController
  final ScrollController _scrollController = ScrollController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    otherUserId = args?['otherUserId'] ?? '';
    _fetchOtherUserName(); // Fetch the full name of the other participant
  }

  Future<void> _fetchOtherUserName() async {
    try {
      // Check clients collection first
      DocumentSnapshot clientDoc = await _firestore.collection('clients').doc(otherUserId).get();
      if (clientDoc.exists) {
        setState(() {
          otherUserName = clientDoc['fullName'];
        });
        return;
      }

      // Check workers collection
      DocumentSnapshot workerDoc = await _firestore.collection('workers').doc(otherUserId).get();
      if (workerDoc.exists) {
        setState(() {
          otherUserName = workerDoc['fullName'];
        });
        return;
      }

      // Default to user ID if no name is found
      setState(() {
        otherUserName = otherUserId;
      });
    } catch (e) {
      setState(() {
        otherUserName = "Unknown User";
      });
    }
  }

  bool get _canSendMessage {
    return globalUserId != null &&
        _messageController.text.trim().isNotEmpty &&
        !_isSendingMessage;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          otherUserName, // Display the full name of the other participant
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
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
                DateTime? previousDate;

                // 2. Scroll to the bottom when the messages are loaded
                WidgetsBinding.instance.addPostFrameCallback((_) {
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
                  }
                });

                return ListView.builder(
                  controller: _scrollController,  // 3. Attach the ScrollController
                  reverse: false,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    final timestamp = message['timestamp'] as Timestamp?;
                    final messageDate = timestamp?.toDate();

                    bool showDateHeader = false;
                    if (messageDate != null) {
                      if (previousDate == null ||
                          messageDate.day != previousDate!.day ||
                          messageDate.month != previousDate!.month ||
                          messageDate.year != previousDate!.year) {
                        showDateHeader = true;
                        previousDate = messageDate;
                      }
                    }

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (showDateHeader)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Center(
                              child: Text(
                                "${messageDate!.day} ${_getMonthName(messageDate.month)} ${messageDate.year}",
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        _buildMessageBubble(message, message['senderId'] == globalUserId),
                      ],
                    );
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
    if (globalUserId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('messages')
        .doc(_getChatId(globalUserId!, otherUserId))
        .collection('chats')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  Widget _buildMessageBubble(DocumentSnapshot message, bool isSentByUser) {
    final timestamp = message['timestamp'] as Timestamp?;
    final formattedTime = timestamp != null
        ? TimeOfDay.fromDateTime(timestamp.toDate()).format(context)
        : '...';

    return Row(
      mainAxisAlignment:
      isSentByUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        if (isSentByUser)
          Padding(
            padding: const EdgeInsets.only(left: 8.0, right: 10.0),
            child: Text(
              formattedTime,
              style: const TextStyle(color: Colors.white60, fontSize: 10),
            ),
          ),
        Container(
          padding: const EdgeInsets.all(10.0),
          margin: const EdgeInsets.symmetric(vertical: 5.0),
          decoration: BoxDecoration(
            color: isSentByUser ? Colors.green : Colors.grey[800],
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Text(
            message['message'],
            style: const TextStyle(color: Colors.white),
          ),
        ),
        if (!isSentByUser)
          Padding(
            padding: const EdgeInsets.only(right: 8.0, left: 10.0),
            child: Text(
              formattedTime,
              style: const TextStyle(color: Colors.white60, fontSize: 10),
            ),
          ),
      ],
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
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: TextStyle(color: Colors.white60),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(width: 8.0),
          CircleAvatar(
            backgroundColor: _canSendMessage ? Colors.green : Colors.grey,
            radius: 24,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _canSendMessage ? _sendMessage : null,
            ),
          ),
        ],
      ),
    );
  }

  String _getChatId(String userId1, String userId2) {
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}-${sortedIds[1]}';
  }

  Future<void> _sendMessage() async {
    if (!_canSendMessage) return;

    setState(() {
      _isSendingMessage = true;
    });

    try {
      final message = _messageController.text.trim();
      final chatId = _getChatId(globalUserId!, otherUserId);

      await _firestore.collection('messages').doc(chatId).collection('chats').add({
        'message': message,
        'senderId': globalUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      await _firestore.collection('messages').doc(chatId).set({
        'participants': [globalUserId, otherUserId],
        'lastMessage': message,
        'lastMessageTime': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      _messageController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send message: $e')),

      );
    } finally {
      setState(() {
        _isSendingMessage = false;
      });
    }
  }

  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
}
