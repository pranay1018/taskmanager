abstract class BaseFireStoreService{
  Future addDataToFireStore(Map<String,dynamic> data,String collectionName,String docName);

  Future updateDataToFireStore(Map<String,dynamic> data,String collectionName,String docName);

  Future getCollectionData(String collectionName,String docName);

}