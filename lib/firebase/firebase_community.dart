// import 'package:cloud_firestore/cloud_firestore.dart';
//
// Future<void> communityStoryGet (String id) async{
//   CollectionReference ref = FirebaseFirestore.instance.collection('story');
//   QuerySnapshot snapshot = await ref.where('id', isEqualTo: id).get();
//   final allData = snapshot.docs.map((doc) => doc.data()).toList();
// }