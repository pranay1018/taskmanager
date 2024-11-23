abstract class BaseFireStoreService{
  Future addDataToFireStore(Map<String,dynamic> data,String collectionName,String docName);

  Future updateDataToFireStore(Map<String,dynamic> data,String collectionName,String docName);

  Future getUserDataFromFireStore(Map<String,dynamic> data,String collectionName,String docName);

}