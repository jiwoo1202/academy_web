
import 'package:academy/screen/login/login_main_screen.dart';
import 'package:academy/screen/main/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../components/dialog/showAlertDialog.dart';
import '../model/user.dart';
import 'package:get/get.dart';

import '../provider/user_state.dart';

Future<void> userGet(String id,String pw)async{
  final controller = Get.put(UserState());
  CollectionReference ref = FirebaseFirestore.instance.collection('user');
  try {
    QuerySnapshot snapshot = await ref.where('id', isEqualTo: id).where('pw', isEqualTo: pw).get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();

    controller.userList.value = snapshot.docs.map<User>((doc) {
           return User.fromDocument(doc);
    }).toList();

  } catch (e) {
    print(e);
  }
}

Future<void> firebaseUserDelete(String docId) async {
  CollectionReference ref = FirebaseFirestore.instance.collection('user');
  QuerySnapshot snapshot = await ref.where('docId', isEqualTo: '${docId}').get();
  snapshot.docs[0].reference.delete();
}

Future<void> firebaseUserUpdate(String docId, String changeKey, String changeValue) async {
  try {

    CollectionReference ref = FirebaseFirestore.instance.collection('user');
    QuerySnapshot snapshot = await ref
        .where('docId', isEqualTo: docId).get();
    snapshot.docs[0].reference.update({'${changeKey}' : changeValue});
  } catch (e) {
    print(e);
  }
}

Future<void> firebaseUserCreate() async {
  final us = Get.put(UserState());
  try {
    final CollectionReference ref = FirebaseFirestore.instance.collection('user');
    User users = User(
      createDate: '${DateTime.now()}',
      day: '',
      docId: '',
      email : '',
      group : 'group',
      id : '1234',
      month : 'month',
      name: 'name',
      phoneNumber : 'phoneNumber',
      pw: '1234',
      temp1: 'temp1',
      temp2: 'temp2',
      token: '',
      userType: '선생님',
      year: 'year',
    );
    await ref.add(users.toMap()).then((doc) async {
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('user').doc(doc.id);
      await userDocRef.update({'docId': '${doc.id}'});
    });
  } catch (e) {
    print(e);
  }
}
// 비밀번호 찾기
Future<void> findPassWord(String phoneNumber)async{
  final us = Get.put(UserState());
  try{
    CollectionReference ref = FirebaseFirestore.instance.collection('user');
    QuerySnapshot snapshot = await ref.where('phoneNumber', isEqualTo: phoneNumber).get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    List a = allData;
    us.findPassWord.value = a[0]['pw'];
  }catch(e){
    print(e);
  }
}