import 'dart:io';

import 'package:academy/model/answer.dart';
import 'package:academy/provider/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import '../provider/answer_state.dart';

Future<void> firebaseAnswerUpload(UploadTask? uploadTask) async {
  final as = Get.put(AnswerState());
  final us = Get.put(UserState());

  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  Answer ass = Answer(
      createDate: '${DateTime.now()}',
      answer: as.answer.toList(),
      answerCount: '',
      docId: '',
      group: '',
      password: '${as.password}',
      pdfCategory: '${as.pdfCategory}',
      pdfName: '${as.pdfName}',
      pdfUploadName: '${as.pdfUploadName}',
      state: '대기',
      teacher: '${as.teacher}',
      temp1: '',
      temp2: '');
  ref.add(ass.toMap()).then((doc) async {
    DocumentReference userDocRef = FirebaseFirestore.instance.collection('answer').doc(doc.id);
    as.docId.value = doc.id;
    print('1: ${as.docId}');
    _uploadFile(as.teacher.value, as, uploadTask);
    await userDocRef.update({'docId': '${doc.id}'});
  });
}

Future<void> _uploadFile(String teacher, AnswerState as, UploadTask? uploadTask) async {
  final file = File(as.path.value);
  print('2: ${as.docId.value}');
  final ref = FirebaseStorage.instance
      .ref()
      .child('12345')
      .child('${teacher}')
      .child('${as.docId.value}.pdf');
  print('3: ${as.docId.value}');
  uploadTask = ref.putFile(file);
  final snapshot = await uploadTask.whenComplete(() => null);
}

Future<void> firebaseAnswerGet() async {
  final as = Get.put(AnswerState());
  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref.where('question', isEqualTo: 'q1').get();

  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  as.answer.value = allData;
  print('real answer : ${as.answer}');
}

Future<void> answerGet(String docId) async {
  final controller = Get.put(AnswerState());
  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  try {
    QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();
    controller.answerList.value = snapshot.docs.map<Answer>((doc) {
      return Answer.fromDocument(doc);
    }).toList();
  } catch (e) {
    print(e);
  }
}

// state가 대기인 상태만 가져오는 함수(추가)
Future<void> getState(String state) async {
  final as = Get.put(AnswerState());
  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref.where('state', isEqualTo: state).get();

  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  List a = allData;
  as.state.value = state;
  as.stateList.value = allData;

  for(int i =0;i<a.length;i++) {
    as.getDocid.add(a[i]['docId']);
    as.teacherList.add(a[i]['teacher']);
    as.createList.add(a[i]['createDate']);
    print('-------------------');
    // print('${as.teacher.value}');
    // print('${as.createList.value}');
    print('겟 닥아이${as.getDocid.value}');
  }
}
// answer 정답 길이 가져오는 함수(추가)
Future<void> getAnswerLength(String docId) async{
  final as = Get.put(AnswerState());

  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();

  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  List a = allData;
  print('${a}');

  as.answerlength.value= a[0]['answer'];
  // print('11||${as.answerlength.value}');
}