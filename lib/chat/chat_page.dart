// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:gighire/Components/text_field.dart';
// import 'package:gighire/Components/chat_bubble.dart';
// import 'package:gighire/Services/auth_service.dart';
// import 'package:gighire/services/chat_service.dart';

// // Main chat page logic; this is where the chat interactions occur.
// class ChatPage extends StatefulWidget {
//   final String receiverEmail;
//   final String receiverID;

//   ChatPage({
//     super.key,
//     required this.receiverEmail,
//     required this.receiverID,
//   });

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> {
//   //text coltroller
//   final TextEditingController _messageController = TextEditingController();

//   //Chat and auth services
//   final ChatService _chatService = ChatService();
//   final AuthService _authService = AuthService();

//   //for textfield focus
//   FocusNode myFocusNode = FocusNode();

//   @override
//   void initState() {
//     super.initState();
//     //add listener to focus node
//     myFocusNode.addListener(() {
//       if (myFocusNode.hasFocus) {
//         //cause the delay so that the keyboard has time to show up
//         //then the amount of remaining space will be calculated
//         //then scroll down
//         Future.delayed(
//           const Duration(milliseconds: 500),
//           () => scrollDown(),
//         );
//       }
//     });
//     //wait a bit for listview to built, then scroll to button
//     Future.delayed(
//       const Duration(milliseconds: 500),
//       () => scrollDown(),
//     );
//   }

//   @override
//   void dispose() {
//     myFocusNode.dispose();
//     _messageController.dispose();
//     super.dispose();
//   }

//   //scroll controller
//   final ScrollController _scrollController = ScrollController();
//   void scrollDown() {
//     _scrollController.animateTo(
//       _scrollController.position.maxScrollExtent,
//       duration: const Duration(seconds: 1),
//       curve: Curves.fastOutSlowIn,
//     );
//   }

//   //send message
//   void sendMessage() async {
//     //if there is something inside the textfield
//     if (_messageController.text.isNotEmpty) {
//       //send the message
//       await _chatService.sendMessage(
//           widget.receiverID, _messageController.text);

//       //clear text controller
//       _messageController.clear();
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.receiverEmail),
//         backgroundColor: Colors.transparent,
//         foregroundColor: Colors.grey,
//         elevation: 0,
//       ),
//       body: Column(
//         children: [
//           //display all messages
//           Expanded(
//             child: _buildMessageList(),
//           ),

//           //user input
//           _buildUserInput(),
//         ],
//       ),
//     );
//   }

//   //build messsage list
//   Widget _buildMessageList() {
//     String senderID = _authService.getCurrentUser()!.uid;
//     return StreamBuilder(
//       stream: _chatService.getMessages(widget.receiverID, senderID),
//       builder: (context, snapshot) {
//         //errors
//         if (snapshot.hasError) {
//           return const Text("Error");
//         }

//         //loading
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Text("Loading");
//         }

//         //return list view
//         return ListView(
//           controller: _scrollController,
//           children:
//               snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
//         );
//       },
//     );
//   }

//   //build message item
//   Widget _buildMessageItem(DocumentSnapshot doc) {
//     Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

//     //is current user
//     bool isCurrentUser = data['senderID'] == _authService.getCurrentUser()!.uid;

//     //allign message
//     var alignment =
//         isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

//     return Container(
//       alignment: alignment,
//       child: Column(
//         crossAxisAlignment:
//             isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
//         children: [
//           ChatBubble(
//             message: data["message"],
//             isCurrentUser: isCurrentUser,
//           )
//         ],
//       ),
//     );
//   }

//   //build message input
//   Widget _buildUserInput() {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 50.0),
//       child: Row(
//         children: [
//           Expanded(
//             child: MyTextfield(
//               controller: _messageController,
//               hintText: "Type a message",
//               obscureText: false,
//               focusNode: myFocusNode,
//             ),
//           ),

//           //send button
//           Container(
//             decoration: BoxDecoration(
//               color: Colors.green,
//               shape: BoxShape.circle,
//             ),
//             margin: const EdgeInsets.only(right: 25),
//             child: IconButton(
//               onPressed: sendMessage,
//               icon: const Icon(
//                 Icons.arrow_upward,
//                 color: Colors.white,
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gighire/Components/text_field.dart';
import 'package:gighire/Components/chat_bubble.dart';
import 'package:gighire/services/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatPage extends StatefulWidget {
  final String receiverEmail;
  final String receiverID;

  const ChatPage({
    Key? key,
    required this.receiverEmail,
    required this.receiverID,
  }) : super(key: key);

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  FocusNode myFocusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  String? currentUserID;

  @override
  void initState() {
    super.initState();
    _initializeCurrentUser();
    myFocusNode.addListener(() {
      if (myFocusNode.hasFocus) {
        Future.delayed(
          const Duration(milliseconds: 500),
          () => scrollDown(),
        );
      }
    });
  }

  Future<void> _initializeCurrentUser() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        currentUserID = user.uid;
      });
    }
  }

  @override
  void dispose() {
    myFocusNode.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void scrollDown() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty && currentUserID != null) {
      await _chatService.sendMessage(
        widget.receiverID,
        _messageController.text,
        senderID: currentUserID!, // Use the initialized current user ID
      );
      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverEmail),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: currentUserID == null
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                Expanded(
                  child: _buildMessageList(),
                ),
                _buildUserInput(),
              ],
            ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessages(widget.receiverID, currentUserID!),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Text("Loading");
        }
        return ListView(
          controller: _scrollController,
          children:
              snapshot.data!.docs.map((doc) => _buildMessageItem(doc)).toList(),
        );
      },
    );
  }

  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    bool isCurrentUser = data['senderID'] == currentUserID;
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
      alignment: alignment,
      child: Column(
        crossAxisAlignment:
            isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          ChatBubble(
            message: data["message"],
            isCurrentUser: isCurrentUser,
          )
        ],
      ),
    );
  }

  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 50.0),
      child: Row(
        children: [
          Expanded(
            child: MyTextfield(
              controller: _messageController,
              hintText: "Type a message",
              obscureText: false,
              focusNode: myFocusNode,
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.green,
              shape: BoxShape.circle,
            ),
            margin: const EdgeInsets.only(right: 25),
            child: IconButton(
              onPressed: sendMessage,
              icon: const Icon(
                Icons.arrow_upward,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
