import 'dart:io';

import 'package:academy/model/answer.dart';
import 'package:academy/provider/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';

import '../provider/answer_state.dart';
import '../provider/test_state.dart';

Future<void> firebaseAnswerUpload(UploadTask? uploadTask) async {
  final as = Get.put(AnswerState());
  final us = Get.put(UserState());

  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  Answer ass = Answer(
      isIndividual: 'false',
      individualBody: [],
      individualTitle: [],
      individualFile: [],
      images : [],
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
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('answer').doc(doc.id);
    as.docId.value = doc.id;
    // print('1: ${as.docId}');
    _uploadFile(as.teacher.value, as, uploadTask);
    await userDocRef.update({'docId': '${doc.id}'});
  });
}



// 선생님 비밀번호 가져오는 함수(추가)
Future<void> getTeacherPassword(String docId) async {
  final ts = Get.put(TestState());
  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();
  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  List a = allData;

  ts.teacherPassword.value = a[0]['password'];
  print('${ts.teacherPassword.value}');
}

Future<void> _uploadFile(
    String teacher, AnswerState as, UploadTask? uploadTask) async {
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

Future<void> firebaseIndividualGet(String docId) async {
  final ts = Get.put(TestState());

  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();

  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  ts.individualTestGet.value = allData;
}

// state가 대기인 상태만 가져오는 함수(추가)
Future<void> getState(String state) async {
  final as = Get.put(AnswerState());
  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref
      .where('state', isEqualTo: state)
      .orderBy('createDate', descending: true)
      .get();

  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  List a = allData;
  as.state.value = state;
  as.stateList.value = allData;

  for (int i = 0; i < a.length; i++) {
    as.getDocid.add(a[i]['docId']);
    as.teacherList.add(a[i]['teacher']);
    as.createList.add(a[i]['createDate']);
  }
}

// answer 정답 길이 가져오는 함수(추가)
Future<void> getAnswerLength(String docId) async {
  final as = Get.put(AnswerState());

  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();

  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  List a = allData;
  // print('${a}');

  as.answerlength.value = a[0]['answer'];
  // print('11||${as.answerlength.value}');
}

// teacher 이름과 날짜 가져오는 함수(추가)
Future<void> getNameAndDate(String docId) async {
  final as = Get.put(AnswerState());

  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();

  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  List a = allData;
  // print('${a}');

  as.getTeacherName.value = a[0]['teacher'];
  as.getDate.value = a[0]['createDate'];
  // print('11||${as.answerlength.value}');
}

// individual test 수정
Future<void> deleteIndividualTest(String docId) async {
  CollectionReference ref =
  FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref
      .where('docId', isEqualTo:docId)
      .get();
  snapshot.docs[0].reference.delete();
}

class FirebaseStorageApi {
  static Future<void> deleteFolder({required String path}) async {
    List<String> paths = [];
    paths = await _deleteFolder(path, paths);
    for (String path in paths) {
      await FirebaseStorage.instance.ref().child(path).delete();
    }
  }

  static Future<List<String>> _deleteFolder(String folder, List<String> paths) async {
    ListResult list = await FirebaseStorage.instance.ref().child(folder).listAll();
    List<Reference> items = list.items;
    List<Reference> prefixes = list.prefixes;
    for (Reference item in items) {
      paths.add(item.fullPath);
    }
    for (Reference subfolder in prefixes) {
      paths = await _deleteFolder(subfolder.fullPath, paths);
    }
    return paths;
  }
}
