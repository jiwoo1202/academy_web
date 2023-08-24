import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/firebase/firebase_answer.dart';
import 'package:academy/screen/main/teacher/video/videoUpload.dart';
import 'package:academy/util/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../components/footer/footer.dart';
import '../../../../components/tile/main_tile.dart';
import '../../../../provider/user_state.dart';
import '../../../../util/behavior.dart';
import '../../../../util/font/font.dart';

class VideoMainScreen extends StatefulWidget {
  const VideoMainScreen({Key? key}) : super(key: key);

  @override
  State<VideoMainScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<VideoMainScreen> {
  List<String> data = [];
  String initial = '';

  @override
  void initState() {
    final us = Get.put(UserState());
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
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: Get.width * 0.15),
                    width: Get.width * 0.4,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: GestureDetector(
                      onTap: () {
                        Get.width < 1024
                            ? () {
                              }

                            /// 태블릿일때
                            : Get.toNamed(VideoUpload.id,
                                arguments: VideoUpload(
                                  edit: 'false',
                                ));
                      },
                      child: Container(
                        width: Get.width,
                        height: 42,
                        decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(8)),
                        child: Center(
                            child: Text(
                          '강의등록',
                          style: f16Whitew700,
                        )),
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: Get.width * 0.15),
                    width: Get.width * 0.4,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('video')
                            .where('teacherDocId',
                                isEqualTo: us.userList[0].docId)
                            .orderBy('createDate', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Container(
                                height: Get.height, child: LoadingBodyScreen());
                          }
                          if (!snapshot.hasData ||
                              snapshot.data!.docs.isEmpty) {
                            return Container(
                              height: Get.height,
                              child: Center(child: Text("데이터가 없습니다.")),
                            );
                          }
                          return Column(
                            children: [
                              SizedBox(
                                height: 24,
                              ),
                              SizedBox(
                                height: 30,
                              ),
                              //조건 비어있으면 Text or 카드 있으면 카드 ListView 부르기
                              // false ?
                              // Text('선생님 이름 혹은\n코드를 검색해주세요', style: TextStyle(fontSize: 20),):
                              ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onLongPress: () {
                                      showComponentDialog(context, '삭제하시겠습니까?',
                                          () {
                                        Get.back();
                                        deleteAnswer(snapshot.data!.docs[index]
                                            ['docId']);
                                      });
                                    },
                                    child: Column(
                                      children: [
                                        MainTile(
                                            isOpened: snapshot.data!.docs[index]
                                                        ['state'] ==
                                                    '완료'
                                                ? true
                                                : false,
                                            isStudent: false,
                                            onTap: () async {
                                              Get.toNamed(VideoUpload.id,
                                                  arguments: VideoUpload(
                                                    edit: 'true',
                                                    title:
                                                        '${snapshot.data!.docs[index]['title']}',
                                                    pw: '${snapshot.data!.docs[index]['pw']}',
                                                    videoName:
                                                        '${snapshot.data!.docs[index]['videoName']}',
                                                    docId:
                                                        '${snapshot.data!.docs[index]['docId']}',
                                                  ));
                                            },
                                            tName: us.userList[0].nickName,
                                            tCreateDate:
                                                '${DateFormat('y-MM-dd HH:mm').format(DateTime.parse('${snapshot.data!.docs[index]['createDate']}'))}',
                                            title:
                                                '${snapshot.data!.docs[index]['title']}',
                                            switchOnTap: () {
                                              if (snapshot.data!.docs[index]
                                                      ['state'] ==
                                                  '완료') {
                                                updateData(
                                                    snapshot.data!.docs[index]
                                                        ['docId'],
                                                    '대기');
                                              } else {
                                                updateData(
                                                    snapshot.data!.docs[index]
                                                        ['docId'],
                                                    '완료');
                                              }
                                            }),
                                        SizedBox(
                                          height: 16,
                                        ),
                                      ],
                                    ),
                                  );
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

  Future<void> updateData(String docId, String value) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('video');
    QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();
    snapshot.docs[0].reference.update({'state': '${value}'});
    // final allData = snapshot.docs.map((doc) => doc.data()).toList();
    // _allData = allData;
    // print('all : ${_allData.length}');
  }
}
