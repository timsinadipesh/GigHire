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
