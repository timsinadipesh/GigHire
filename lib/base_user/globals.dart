library my_app.globals;
import 'package:cloud_firestore/cloud_firestore.dart';

String? globalUserId;


Future<bool> globalIsWorker(String userId) async {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Check if the user exists in the workers collection
  final workerDoc = await _firestore.collection('workers').doc(userId).get();
  if (workerDoc.exists) {
    return true;
  }
  return false;
}

