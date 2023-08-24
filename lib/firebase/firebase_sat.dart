import 'package:academy/provider/sat_state.dart';
import 'package:academy/provider/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

import '../util/refresh_manager.dart';
///satAnswer Collection
/// 학생이 처음 만들때
Future<void> firebaseSatCreate(String answerDocId, List answer, String teacher, String testTitle) async {
  try {
    final us = Get.put(UserState());
    final st = Get.put(SatState());
    String docId = '';
    final CollectionReference ref = FirebaseFirestore.instance.collection('satAnswer');
    await ref.add({
      'answer':answer,
      'answerDocId':'${answerDocId}',
      'createDate':'${DateTime.now()}',
      'id':'${us.userList[0].id}',
      'nickName':'${us.userList[0].nickName}',
      'score':0,
      'status':'',
      'time':'',
      'minute':'',
      'second':'',
      'name':'${us.userList[0].name}',
      'teacher':teacher,
      'testTitle':testTitle,
    }).then((doc) async {
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('satAnswer').doc(doc.id);
      await userDocRef.update({'docId': '${doc.id}'});
      docId = '${doc.id}';
    });
    RefreshManager.addToCookie('satUpdateDocId', '${docId}'); /// 업데이트할 docID저장
    st.satUpdateDocId.value = docId;
    // CollectionReference ref2 = FirebaseFirestore.instance.collection('satAnswer');
    // QuerySnapshot snapshot2 = await ref2.where('docId', isEqualTo: '${docId}').get();
    // final allData = snapshot2.docs.map((doc) => doc.data()).toList();
    // List a = allData;
    // RefreshManager.addToCookie('studentList', '${a}'); /// 업데이트할 docId가져옴
  } catch (e) {
    print(e);
  }
}
/// 학생이 문제 입력할때마다 업데이트
Future<void> firebaseSatAnswerUpdate(List answer) async {
  final st = Get.put(SatState());
  DocumentReference doRef = FirebaseFirestore.instance.collection('satAnswer').doc('${st.satUpdateDocId}');
  doRef.update({
    'answer': answer,
  });
}
/// 학생이 문제 입력할때마다 업데이트
Future<void> firebaseSatTimeUpdate(int minute,int second) async {
  final st = Get.put(SatState());
  DocumentReference doRef = FirebaseFirestore.instance.collection('satAnswer').doc('${st.satUpdateDocId}');

  doRef.update({
    'minute':'${minute}',
    'second':'${second}',
  });
}
  /// sat Collection
  /// 선생님 시험정보 가져오기
  Future<void> firebaseSatGet() async {
    final st = Get.put(SatState());
    final us = Get.put(UserState());

    CollectionReference ref = FirebaseFirestore.instance.collection('sat');
    QuerySnapshot snapshot = await ref.where('docId', isEqualTo: '${st.satTeacherDocId.value}').get();

    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    st.individualSatGet.value = allData;
  }


Future<void> deleteSat(String docId) async {
  DocumentReference ref =
  FirebaseFirestore.instance.collection('sat').doc(docId);
  ref.update({'status': '삭제'});
}

Future<void> satStatusChange(String docId, String index) async { //2 나가기(Exit, 뒤로가기), 3 브레이크 들림, 4 시험 종료
  final st = Get.put(SatState());
  final us = Get.put(UserState());
  DocumentReference ref = FirebaseFirestore.instance.collection('satAnswer').doc(docId);
  CollectionReference ref2 = FirebaseFirestore.instance.collection('sat');

  if(index == '4') {
    int eng = 0;
    int math = 0;
    String s = '';
    if(st.satpart == '2') { //영어
      for(int i=0; i<54; i++) { //내답
        if(st.individualSatGet[0]['answer'][i]== st.totalAnswer[i]) {
          eng++;
        }
      }
      await ref.update({'englishScore': eng,
        'status': index,
        'mathScore': 0,
        'score':int.parse(st.individualSatGet[0]['englishScore'][eng])});

      if(us.userList[0].userType == '학생') {
        ref2.doc(st.satTeacherDocId.value).update({
          'studentList' : FieldValue.arrayUnion([us.userList[0].id])
        });
      }
    }
    else { //영어 + 수학
      for(int i=0; i<st.totalAnswer.length; i++) { //내답
        s = st.individualSatGet[0]['answer'][i].toString().replaceAll(" ", "");
        if((st.individualSatGet[0]['answer'][i] == st.totalAnswer[i]) && i<54) {
          eng++;
        }
        else if(s.contains('/')) {
          if(s.split('/').contains(st.totalAnswer[i])) {
            math++;
          }
        }
        else if(st.individualSatGet[0]['answer'][i] == st.totalAnswer[i]) {
          math++;
        }
      }
      await ref.update({'mathScore': math,
        'status': index,
        'englishScore': eng,
        'score':'${int.parse(st.individualSatGet[0]['englishScore'][eng])+int.parse(st.individualSatGet[0]['mathScore'][math])}'});

      if(us.userList[0].userType == '학생') {
        ref2.doc(st.satTeacherDocId.value).update({
          'studentList' : FieldValue.arrayUnion([us.userList[0].id])
        });
      }
    }
  }
  else {
    await ref.update({'status': index});
  }
}