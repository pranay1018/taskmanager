abstract class BaseFireStoreService{
  Future addDataToFireStore(Map<String,dynamic> data,String collectionName,String docName);

  Future updateDataInFireStore(Map<String,dynamic> data,String collectionName,String docName);

  Future getCollectionData(String collectionName);

}