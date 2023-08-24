import 'package:academy/provider/user_state.dart';
import 'package:academy/screen/main/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../components/dialog/showAlertDialog.dart';
import '../provider/answer_state.dart';
import '../provider/test_state.dart';
import '../screen/login/login_main_screen.dart';
import '../screen/main/student/test/test_check_screen.dart';

Future<void> firebaseTestUpload(String docId, BuildContext context) async {
  final ts = Get.put(TestState());
  final us = Get.put(UserState());
  final as = Get.put(AnswerState());
  int a = 0;
  CollectionReference ref = FirebaseFirestore.instance.collection('test');

  DocumentReference doRef =
      FirebaseFirestore.instance.collection('answer').doc(docId);
  doRef.update({
    'student': FieldValue.arrayUnion(['${us.userList[0].id}'])
  });

  CollectionReference ref2 = FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref2.where('docId', isEqualTo: docId).get();
  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  List b = allData;

  for (int i = 0; i < b[0]['answer'].length; i++) {
    if (ts.answer[i] == b[0]['answer'][i]) {
      a++;
    }
  }
  ref.add({
    'answer': ts.answer,
    // 'id' : us.number.value,
    'id': '${us.userList[0].id}',
    'answerDocid': ts.answerDocId.value,
    'teacher': as.getTeacherName.value,
    'createDate': '${DateTime.now()}',
    'nickName': '${b[0]['nickName']}',
    'score': ((a / b[0]['answer'].length) * 100).ceil(),
    'status': '완료',
    'scoreVisual': '${as.scoreVisual.value}',
    'testTitle': '${b[0]['pdfCategory']}',
  }).then((doc) async {
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('test').doc(doc.id);
    await userDocRef.update({'docId': '${doc.id}'});
    ts.testDocId.value = doc.id;
    showConfirmTapDialog(context, '수고하셨습니다\n\n작성하신 답안이 정상적으로 제출 되었습니다', () {
      Get.offNamedUntil(BottomNavigator.id, (route) => true);
      // Get.offAll(() => TestCheckScreen(
      //       teacherName: as.getTeacherName.value,
      //       docId: ts.answerDocId.value,
      //       myPage: false,
      //     ));
    });
  });
}

Future<void> firebaseAnswerGet(String docId) async {
  final ts = Get.put(TestState());

  CollectionReference ref = FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();

  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  List a = allData;
  ts.realAnswer.value = allData;
  // print('real answer : ${ts.realAnswer.length}');
}

Future<void> firebaseAllQuestionGet(String id) async {
  final ts = Get.put(TestState());
  List result = [];
  CollectionReference ref = FirebaseFirestore.instance.collection('test');
  CollectionReference ref2 = FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref
      .where('id', isEqualTo: id)
      .orderBy('createDate', descending: true)
      .get();
  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  ts.myAnswer.value = allData;
  List a = allData;

  // result.clear();
  // ts.answerScore.clear();
  // ts.answerDate.clear();
  //
  // for (int i = 0; i < ts.myAnswer.length; i++) {
  //   result.add('');
  //   ts.answerScore.add(a[i]['score']);
  //   ts.answerDate.add(a[i]['createDate']);
  //
  //   QuerySnapshot snapshot2 = await ref2
  //       .where('docId', isEqualTo: ts.myAnswer[i]['answerDocid'])
  //       .orderBy('createDate', descending: true)
  //       .get();
  //   final allData2 = snapshot2.docs.map((doc) => doc.data()).toList();
  //   List b = allData2;
  //   result[i] = '${b[0]['scoreVisual']}';
  // }
  // ts.answerVisiual.value = result;
  // ts.answerVisiual2.value = result;
}

Future<void> firebaseSingleQuestionGet(String docId) async {
  final ts = Get.put(TestState());

  CollectionReference ref = FirebaseFirestore.instance.collection('test');
  QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();

  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  ts.mySingleAnswer.value = allData;
  // print('real answer1241224124 : ${ts.mySingleAnswer.length}');
}

Future<void> firebaseIndividualTestUpload(String docId) async {
  final ts = Get.put(TestState());
  final us = Get.put(UserState());
  final as = Get.put(AnswerState());
  int a = 0;
  CollectionReference ref = FirebaseFirestore.instance.collection('test');
  DocumentReference doRef = FirebaseFirestore.instance.collection('answer').doc(docId);
  doRef.update({
    'student': FieldValue.arrayUnion(['${us.userList[0].id}'])
  });

  CollectionReference ref2 = FirebaseFirestore.instance.collection('answer');
  QuerySnapshot snapshot = await ref2.where('docId', isEqualTo: docId).get();
  final allData = snapshot.docs.map((doc) => doc.data()).toList();
  List b = allData;

  for (int i = 0; i < b[0]['answer'].length; i++) {
    if (b[0]['answer'][i] != '') {
      if (ts.answer[i] == b[0]['answer'][i]) {
        a++;
      }
    } else {
      if (ts.answer[i] == b[0]['temp1'][i]) {
        a++;
      }
    }
  }
  ref.add({
    'answer': ts.answer,
    // 'id' : us.number.value,
    'id': '${us.userList[0].id}',
    'createDate': '${DateTime.now()}',
    'status': '완료',
    'category':'${b[0]['category']}',
    'isIndividual': 'true',
    'scoreVisual':'${b[0]['scoreVisual']}',
    'nickName': '${b[0]['nickName']}',
    'answerDocid': ts.answerDocId.value,
    'teacher': as.getTeacherName.value,
    'score': ((a / b[0]['answer'].length) * 100).ceil(),
    'testTitle': '${b[0]['pdfCategory']}',
  }).then((doc) async {
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('test').doc(doc.id);
    await userDocRef.update({'docId': '${doc.id}'});
    ts.testDocId.value = doc.id;
    // Get.to(() => TestCheckScreen(
    // ));
    // print('1111${as.docId.value}');
    // print('ts value test : ${ts.testDocId.value}');
  });
}
