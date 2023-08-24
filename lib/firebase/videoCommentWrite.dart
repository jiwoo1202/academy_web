import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../provider/user_state.dart';

Future<void> videoCommentWrite (String body, String docId) async{
  final us = Get.put(UserState());
  CollectionReference ref = FirebaseFirestore.instance.collection('video').doc(docId).collection('comments');
  ref.add({
    'id' : '${us.userList[0].phoneNumber}',
    'docId' : '',
    'body' : body,
    'status' : '게시중',
    'type' : '',
    'nickName':'${us.userList[0].nickName}',
    'name' : '',
    'createDate' : '${DateTime.now()}',
  }).then((doc) async {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('video').doc(docId).collection('comments').doc(doc.id);
    await userDocRef.update({'docId': '${doc.id}'});
  });
}
/// 댓글 가져오기
Future<List> videoBlockExceptGet(String docId) async {
  final us = Get.put(UserState());
  try {
    CollectionReference ref = FirebaseFirestore.instance
        .collection('video').doc(docId).collection('comments');
    QuerySnapshot snapshot = await ref.orderBy('createDate',descending: true).get();
    final allData2 = snapshot.docs.map((doc) => doc.data()).toList();
    List ls2 = allData2;
    return ls2; //ls3;
  } catch (e) {
    print(e);
  }
  return [];
}
/// 댓글 수정하기
Future<void> videoCommentUpdate(
    String docId, String changeValue, String widgetDocId) async {
  try {
    CollectionReference ref = FirebaseFirestore.instance
        .collection('video')
        .doc(widgetDocId)
        .collection('comments');
    QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();
    snapshot.docs[0].reference.update({'body': changeValue});
  } catch (e) {
    // print(e);
  }
}
/// 댓글 삭제
Future<void> vidoeCommentDelete(String widgetDocId,String docId) async {
  try {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;
    CollectionReference ref = _firestore.collection('video').doc(widgetDocId).collection('comments');
    QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();
    snapshot.docs[0].reference.delete();
  } catch (e) {
    // print(e);
  }
}
/// 신고 하기
Future<void> videoCommentBlock(String docId, String bannedId) async {
  try {
    CollectionReference ref = FirebaseFirestore.instance.collection('user');
    QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();
    snapshot.docs[0].reference.update({
      'isBanned' : FieldValue.arrayUnion([bannedId])
    });
  } catch (e) {
    print(e);
  }
}