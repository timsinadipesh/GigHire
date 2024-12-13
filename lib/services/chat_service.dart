// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:gighire/chat/Models/message.dart';

// //contains backend service logic, possibly for authentication or message routing.
// class ChatService {
//   //get instance of firestore and auth
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final FirebaseAuth _auth = FirebaseAuth.instance;
//   final Timestamp timestamp = Timestamp.now();
//   //get user stream

//   /*

//     List<Map<String,dynamic> =

//     [
//     {
//     'email': admin@hgmail.com,
//     'id': ..
//     },
//     {
//     'email': admin2@hgmail.com,
//     'id': ..
//     },
//     ]

//   */

//   Stream<List<Map<String, dynamic>>> getWorkersStream() {
//     return _firestore.collection("workers").snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         //go through each individual user
//         final user = doc.data();

//         //return user
//         return user;
//       }).toList();
//     });
//   }

//   Stream<List<Map<String, dynamic>>> getClientsStream() {
//     return _firestore.collection("clients").snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         //go through each individual user
//         final user = doc.data();

//         //return user
//         return user;
//       }).toList();
//     });
//   }

//   //send message
//   Future<void> sendMessage(String receiverID, message) async {
//     //get current user info
//     final String currentUserID = _auth.currentUser!.uid;
//     final String currentUserEmail = _auth.currentUser!.email!;
//     final Timestamp timestamp = Timestamp.now();

//     //create a new message
//     Message newMessage = Message(
//       senderID: currentUserID,
//       senderEmail: currentUserEmail,
//       receiverID: receiverID,
//       message: message,
//       timestamp: timestamp,
//     );

//     //construct chat room ID for the two users (shorted to ensure uniqueness)
//     List<String> ids = [currentUserID, receiverID];
//     ids.sort(); //sort the ids (this insures the ChatroomID is the same for 2 people)
//     String ChatroomID = ids.join('_');

//     //add new message to database
//     await _firestore
//         .collection("chat_rooms")
//         .doc(ChatroomID)
//         .collection("messages")
//         .add(newMessage.toMap());
//   }

//   //get message
//   Stream<QuerySnapshot> getMessages(String userID, otherUserID) {
//     // Construct a chat room ID for the two users
//     List<String> ids = [userID, otherUserID];
//     ids.sort();
//     String chatRoomID = ids.join('_');

//     return _firestore
//         .collection("chat_rooms")
//         .doc(chatRoomID)
//         .collection("messages")
//         .orderBy("timestamp", descending: false)
//         .snapshots();
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to send a message
  Future<void> sendMessage(String receiverID, String message,
      {required String senderID}) async {
    try {
      final chatID = _getChatID(senderID, receiverID);

      // Add the message to the Firestore collection
      await _firestore
          .collection('chats')
          .doc(chatID)
          .collection('messages')
          .add({
        'senderID': senderID,
        'receiverID': receiverID,
        'message': message,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error sending message: $e");
    }
  }

  // Method to get the chat messages stream
  Stream<QuerySnapshot> getMessages(String receiverID, String senderID) {
    final chatID = _getChatID(senderID, receiverID);

    return _firestore
        .collection('chats')
        .doc(chatID)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }

  // Method to generate a consistent chat ID
  String _getChatID(String senderID, String receiverID) {
    List<String> ids = [senderID, receiverID];
    ids.sort(); // Ensure consistent ordering
    return ids.join('_');
  }

  // Method to get a stream of clients (example)
  Stream<List<Map<String, dynamic>>> getClientsStream() async* {
    final querySnapshot = await _firestore.collection('clients').get();
    yield querySnapshot.docs
        .map((doc) => {'email': doc['email'], 'documentId': doc.id})
        .toList();
  }

  // Method to get a stream of workers (example)
  Stream<List<Map<String, dynamic>>> getWorkersStream() async* {
    final querySnapshot = await _firestore.collection('workers').get();
    yield querySnapshot.docs
        .map((doc) => {'email': doc['email'], 'documentId': doc.id})
        .toList();
  }
}
