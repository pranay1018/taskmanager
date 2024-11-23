import 'package:cloud_firestore/cloud_firestore.dart';

import '../network/abstract/base_firestore_service.dart';

class FireStoreService extends BaseFireStoreService {
  final _fireStoreService = FirebaseFirestore.instance;

  @override
  Future addDataToFireStore(
      Map<String, dynamic> data, String collectionName, String docName) async {
    try {
      await _fireStoreService.collection(collectionName).doc(docName).set(data);
    } catch (e) {
      print(e);
      throw Exception(e.toString());
    }
  }

  @override
  Future updateDataToFireStore(
      Map<String, dynamic> data, String collectionName, String docName) async {
    try {
      final userData = await _fireStoreService
          .collection(collectionName)
          .doc(docName)
          .update(data)
          .then(
            (value) => print("user updated"),
          )
          .catchError((error) => print("failed to update the user  $error"));
    } catch (e) {
      print(e);
      throw Exception(e.toString());
    }
  }

  @override
  Future getUserDataFromFireStore(
      Map<String, dynamic> data, String collectionName, String docName) async {
    try {
      final userData = await _fireStoreService.collection(collectionName).doc(docName).get();
    } catch (e) {
      print(e);
      throw Exception(e.toString());
    }
  }
}
