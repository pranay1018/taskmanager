import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taskmanager/src/network/abstract/base_firestore_service.dart';


// Create a provider for FireStoreService
final firestoreServiceProvider = Provider<FireStoreService>((ref) {
  return FireStoreService();  // Returning the FireStoreService instance
});

class FireStoreService  extends BaseFireStoreService{
  final FirebaseFirestore _fireStoreService = FirebaseFirestore.instance;

  // Add new data to Firestore
  @override
  Future<void> addDataToFireStore(Map<String, dynamic> data, String collectionName, String docName) async {
    try {
      await _fireStoreService.collection(collectionName).doc(docName).set(data);
    } catch (e) {
      print('Error adding document: $e');
      throw Exception(e.toString());
    }
  }

  // Update existing data in Firestore
  @override
  Future<void> updateDataInFireStore(Map<String, dynamic> data, String collectionName, String docName) async {
    try {
      // Update the document at the specified path with the given data
      await _fireStoreService.collection(collectionName).doc(docName).update(data);
    } catch (e) {
      throw Exception('Error updating data in Firestore: $e');
    }
  }

  // Get all documents from a Firestore collection
  @override
  Future<List<Map<String, dynamic>>> getCollectionData(String collectionName) async {
    try {
      final querySnapshot = await _fireStoreService.collection(collectionName).get();
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
