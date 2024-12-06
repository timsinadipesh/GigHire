import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Saves client data to Firestore
  Future<void> saveClientData(Map<String, dynamic> clientData) async {
    try {
      await _firestore.collection('clients').add(clientData);
    } catch (e) {
      throw Exception('Error saving client data: $e');
    }
  }
}
