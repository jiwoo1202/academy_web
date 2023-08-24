import 'dart:io';
import 'dart:typed_data';

import 'package:academy/model/answer.dart';
import 'package:academy/provider/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../provider/answer_state.dart';
import '../provider/test_state.dart';

Future<void> firebaseAnswerUpload(
    Uint8List uploadfile, Uint8List? audioFile, String timer, bool scoreVisual,String category) async {
  final as = Get.put(AnswerState());
  final us = Get.put(UserState());

  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  Answer ass = Answer(
    isIndividual: 'false',
    audio: [],
    individualBody: [],
    individualTitle: [],
    individualFile: [],
    student: [],
    createDate: '${DateTime.now()}',
    answer: as.answer.toList(),
    nickName: us.userList[0].nickName,
    answerCount: '',
    docId: '',
    group: '',
    category:category,
    scoreVisual: '${scoreVisual}',
    password: '${as.password}',
    pdfCategory: '${as.pdfCategory}',
    pdfName: '${as.pdfName}',
    pdfUploadName: as.pdfUploadName,
    pdfUploadName2: as.pdfUploadName2,
    state: '완료',
    teacher: '${as.teacher}',
    temp1: [],
    temp2: timer,
    images: [],
  );
  ref.add(ass.toMap()).then((doc) async {
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('answer').doc(doc.id);
    as.docId.value = doc.id;
    final ref = FirebaseStorage.instance
        .ref()
        .child('12345')
        .child('${as.teacher}')
        .child('${as.docId}.pdf');
    UploadTask uploadTask = ref.putData(
      uploadfile,
      SettableMetadata(contentType: 'application/pdf'),
    );
    final snapshot = await uploadTask.whenComplete(() => null);

    if (audioFile != null) {
      final firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('teacher')
          .child('audio')
          .child('${as.teacher}')
          .child('${as.docId}')
          .child('${as.docId}');
      final uploadTask2 = firebaseStorageRef.putData(
          audioFile, SettableMetadata(contentType: 'audio/mpeg'));
      await uploadTask2.then((p0) => null);
      await userDocRef.update({
        "audio": 'yes',
        "pdfUploadName2":as.pdfUploadName2});
    } else {
      await userDocRef.update({"audio": 'no'});
    }
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

}

Future<void> _uploadFile(
    String teacher, AnswerState as, UploadTask? uploadTask) async {
  final file = File(as.path.value);

  final ref = FirebaseStorage.instance
      .ref()
      .child('12345')
      .child('${teacher}')
      .child('${as.docId.value}.pdf');

  uploadTask = kIsWeb
      ? ref.putFile(
          file,
          SettableMetadata(contentType: 'application/pdf'),
        )
      : ref.putFile(file);
  final snapshot = await uploadTask.whenComplete(() => null);
}

Future<void> firebaseAnswerGet() async {
  final as = Get.put(AnswerState());
  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref.where('question', isEqualTo: 'q1').get();

  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  as.answer.value = allData;

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

  as.answerlength.value = a[0]['answer'];
  as.scoreVisual.value = a[0]['scoreVisual'];
}

// teacher 이름과 날짜 가져오는 함수(추가)
Future<void> getNameAndDate(String docId) async {
  final as = Get.put(AnswerState());

  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();

  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  List a = allData;
  as.getTeacherName.value = a[0]['teacher'];
  as.getDate.value = a[0]['createDate'];
}

Future<void> deleteAnswer(String docId) async {
  DocumentReference ref =
      FirebaseFirestore.instance.collection('answer').doc(docId);
  ref.update({'state': '삭제'});
}

class FirebaseStorageApi {
  static Future<void> deleteFolder({required String path}) async {
    List<String> paths = [];
    paths = await _deleteFolder(path, paths);
    for (String path in paths) {
      await FirebaseStorage.instance.ref().child(path).delete();
    }
  }

  //deleterfile


  static Future<List<String>> _deleteFolder(
      String folder, List<String> paths) async {
    ListResult list =
        await FirebaseStorage.instance.ref().child(folder).listAll();
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

// individual test 수정
Future<void> deleteIndividualTest(String docId) async {
  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();
  snapshot.docs[0].reference.delete();
}

// 선생님 시험 문제 답 한 것들 가져오기
Future<void> studentAnswerGet(String answerDoc) async{
  final as = Get.put(AnswerState());

  CollectionReference ref = FirebaseFirestore.instance.collection('test');

  QuerySnapshot snapshot = await ref.where('answerDocid', isEqualTo: answerDoc).get();
  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  as.testAnswerList.value = allData;
  //선생님 정답 가저오기
  CollectionReference ref2 = FirebaseFirestore.instance.collection('answer');

  QuerySnapshot snapshot2 = await ref2.where('docId', isEqualTo: answerDoc).get();
  final allData2 = snapshot2.docs.map((doc) => doc.data()).toList();
  List a = allData2;
  as.settingGetAnswer.value = a;
}

// 전체문제 임시저장 업로드
Future<void> firebaseAnswerUploadSave(
    Uint8List uploadfile, Uint8List? audioFile, String timer,bool scoreVisual) async {
  final as = Get.put(AnswerState());
  final us = Get.put(UserState());

  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  Answer ass = Answer(
    isIndividual: 'false',
    audio: [],
    individualBody: [],
    individualTitle: [],
    individualFile: [],
    student: [],
    createDate: '${DateTime.now()}',
    answer: as.answer.toList(),
    nickName: us.userList[0].nickName,
    answerCount: '',
    docId: '',
    group: '',
    scoreVisual:'${scoreVisual}',
    password: '${as.password}',
    pdfCategory: '${as.pdfCategory}',
    pdfName: '${as.pdfName}',
    pdfUploadName: as.pdfUploadName,
    pdfUploadName2: as.pdfUploadName2,
    state: '임시',
    teacher: '${as.teacher}',
    temp1: [],
    temp2: timer,
    images: [],
  );
  ref.add(ass.toMap()).then((doc) async {
    DocumentReference userDocRef =
    FirebaseFirestore.instance.collection('answer').doc(doc.id);
    as.docId.value = doc.id;
    final ref = FirebaseStorage.instance
        .ref()
        .child('12345')
        .child('${as.teacher}')
        .child('${as.docId}.pdf');
    UploadTask uploadTask = ref.putData(
      uploadfile,
      SettableMetadata(contentType: 'application/pdf'),
    );
    final snapshot = await uploadTask.whenComplete(() => null);
    if (audioFile != null) {
      final firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('teacher')
          .child('audio')
          .child('${as.teacher}')
          .child('${as.docId}')
          .child('${as.docId}');
      final uploadTask2 = firebaseStorageRef.putData(
          audioFile, SettableMetadata(contentType: 'audio/mpeg'));
      await uploadTask2.then((p0) => null);
      await userDocRef.update({
        "audio": 'yes',
        });
    } else {
      await userDocRef.update({"audio": 'no'});
    }
    await userDocRef.update({'docId': '${doc.id}'});
  });
}