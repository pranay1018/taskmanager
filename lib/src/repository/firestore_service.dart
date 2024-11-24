import 'dart:js_interop';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


// Create a provider for FireStoreService
final firestoreServiceProvider = Provider<FireStoreService>((ref) {
  return FireStoreService();  // Returning the FireStoreService instance
});

class FireStoreService {
  final FirebaseFirestore _fireStoreService = FirebaseFirestore.instance;

  // Add new data to Firestore
  Future<void> addDataToFireStore(Map<String, dynamic> data, String collectionName, String docName) async {
    try {
      await _fireStoreService.collection(collectionName).doc(docName).set(data);
    } catch (e) {
      print('Error adding document: $e');
      throw Exception(e.toString());
    }
  }

  // Update existing data in Firestore
  Future<void> updateDataToFireStore(Map<String, dynamic> data, String collectionName, String docName) async {
    try {
      await _fireStoreService.collection(collectionName).doc(docName).update(data);
    } catch (e) {
      print('Error updating document: $e');
      throw Exception(e.toString());
    }
  }

  // Get all documents from a Firestore collection
  Future<List<Map<String, dynamic>>> getCollectionData(String collectionPath) async {
    try {
      final querySnapshot = await _fireStoreService.collection(collectionPath).get();
      return querySnapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print('Error fetching collection data: $e');
      throw Exception(e.toString());
    }
  }

  // Delete a document from Firestore
  Future<void> deleteDocument(String collectionPath, String docId) async {
    try {
      await _fireStoreService.collection(collectionPath).doc(docId).delete();
    } catch (e) {
      print('Error deleting document: $e');
      throw Exception('Failed to delete document');
    }
  }

  // Real-time stream for collection data
  Stream<List<Map<String, dynamic>>> getCollectionStream(String collectionPath) {
    try {
      return _fireStoreService
          .collection(collectionPath)
          .snapshots()  // Listen for real-time updates
          .map((querySnapshot) =>
          querySnapshot.docs.map((doc) => doc.data()).toList());
    } catch (e) {
      print('Error fetching collection stream: $e');
      throw Exception(e.toString());
    }
  }

}
