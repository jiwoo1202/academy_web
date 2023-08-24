import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/provider/sat_state.dart';
import 'package:academy/util/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../components/footer/footer.dart';
import '../../../components/tile/main_tile.dart';
import '../../../firebase/firebase_sat.dart';
import '../../../provider/user_state.dart';
import '../../../util/behavior.dart';
import '../../../util/font/font.dart';
import '../sat/sat_upload_screen.dart';

class TeacherSatScreen extends StatefulWidget {
  const
  TeacherSatScreen({Key? key}) : super(key: key);

  @override
  State<TeacherSatScreen> createState() => _TeacherSatScreenState();
}

class _TeacherSatScreenState extends State<TeacherSatScreen> {
  List<String> data = [];
  String initial = '';

  @override
  void initState() {
    data = ['시험올리기', '이야기', '구인구직', '공지사항'];
    initial = data.first.toString();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final us = Get.put(UserState());

    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        body: ScrollConfiguration(
          behavior: MyBehavior(), //마우스
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Center(
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: Get.width * 0.15),
                    width: Get.width * 0.4,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('sat')
                            .where('id', isEqualTo: us.userList[0].id)
                            .orderBy('createDate', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                                height: Get.height, child: LoadingBodyScreen());
                          }
                          return Column(
                            children: [
                              const SizedBox(
                                height: 52,
                              ),
                              Text(
                                '선생님',
                                style: f24w500,
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Get.toNamed(SatUploadScreen.id);
                                },
                                child: Container(
                                  width: Get.width,
                                  height: 42,
                                  decoration: BoxDecoration(
                                      color: Colors.black,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Center(
                                      child: Text(
                                        '문제추가',
                                        style: f16Whitew700,
                                      )),
                                ),
                              ),
                              SizedBox(
                                height: 24,
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return snapshot.data!.docs[index]['status'] != '2'
                                      ? GestureDetector(
                                    onLongPress: () {
                                      showComponentDialog(
                                          context, '삭제하시겠습니까?', () {
                                        Get.back();
                                        deleteSat(snapshot
                                            .data!.docs[index]['docId']);
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        MainTile(
                                          isOpened:
                                          snapshot.data!.docs[index]['visual'] == 'false'
                                              ? false
                                              : true,
                                          isStudent: false,
                                          onTap: () async {
                                            final st = Get.put(SatState());
                                            st.satTeacherDocId.value = snapshot.data!.docs[index]['docId'];
                                            Get.toNamed(SatUploadScreen.id, arguments: SatUploadScreen(edit: 'true',));
                                          },
                                          tName: us.userList[0].nickName,
                                          tCreateDate:
                                          '${DateFormat('y-MM-dd HH:mm').format(DateTime.parse('${snapshot.data!.docs[index]['createDate']}'))}',
                                          title: '${snapshot.data!.docs[index]['mainTitle']}',
                                          switchOnTap: () {
                                            if (snapshot.data!.docs[index]['visual'] == 'false') {
                                              openSat(snapshot.data!.docs[index]['docId'], 'true');
                                            } else {
                                              openSat(snapshot.data!.docs[index]['docId'], 'false');
                                            }
                                          },
                                          isSwitched:snapshot.data!.docs[index]['status'] == '0'&&snapshot.data!.docs[index]['visual'] == 'false'
                                              ? false
                                              : true,
                                          storage: '${snapshot.data!.docs[index]['status'] == '0' ? '임시' : '완료'}',
                                        ),
                                        SizedBox(
                                          height: 16,
                                        ),
                                      ],
                                    ),
                                  )
                                      : Container();
                                },
                              ),
                              SizedBox(
                                height: 20,
                              ),
                            ],
                          );
                        }),
                  ),
                  Footer()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  /// sat문제 공개 비공개 버튼
  Future<void> openSat(String docId, String value) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('sat');
    QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();
    snapshot.docs[0].reference.update({'visual': '${value}'});

  }
}
