import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/firebase/firebase_answer.dart';
import 'package:academy/screen/main/teacher/all/pdf_upload_screen_tablet.dart';
import 'package:academy/screen/main/teacher/individual/pdf_individual_main_screen_tablet.dart';
import 'package:academy/util/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../components/footer/footer.dart';
import '../../../components/tile/main_tile.dart';
import '../../../provider/user_state.dart';
import '../../../util/behavior.dart';
import '../../../util/font/font.dart';
import 'all/pdf_upload_screen.dart';
import 'individual/pdf_individual_main_screen.dart';
class TeacherScreen extends StatefulWidget {
  const
  TeacherScreen({Key? key}) : super(key: key);

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
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
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: Get.width * 0.15),
                    width: Get.width * 0.4,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('answer')
                            .where('teacher', isEqualTo: us.userList[0].id)
                            // .where('state', isNotEqualTo: '삭제')
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
                                  showComponentUploadDialog(
                                      context,
                                      '문제를 추가하시겠습니까?',
                                      Get.width < 1024
                                          ? () {
                                              Get.back();
                                              Get.toNamed(PdfUploadScreenTablet.id);
                                              // Get.to(() => PdfUploadScreen());
                                            }
                                          /// 태블릿일때
                                          : () {
                                              Get.back();
                                              Get.toNamed(PdfUploadScreen.id);
                                              // Get.to(() => PdfUploadScreen());
                                            },
                                      /// 웹일때
                                      Get.width < 1024
                                          ? () {
                                              Get.back();
                                              Get.toNamed(
                                                  PdfIndMainScreenTablet.id);
                                              // Get.to(() => PdfIndMainScreen());
                                            }
                                          : () {
                                              Get.back();
                                              Get.toNamed(PdfIndMainScreen.id);
                                              // Get.to(() => PdfIndMainScreen());
                                            }

                                      /// 웹일때
                                      );
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
                              //검색
                              // GestureDetector(
                              //   behavior: HitTestBehavior.opaque,
                              //   onTap: () async {
                              //     // var drugName = Navigator.push(
                              //     //   context,
                              //     //   MaterialPageRoute(
                              //     //     builder: (context) => MainSearchScreen(),
                              //     //   ),
                              //     // );
                              //     // Get.to(() => MainSearchScreen.id);
                              //     // setState(() {
                              //     //   if (drugName != null && drugName != '') createDrugItem(drugName);
                              //     // });
                              //   },
                              //   child: Container(
                              //     alignment: Alignment.topCenter,
                              //     padding: EdgeInsets.symmetric(
                              //         horizontal: 20, vertical: 18.5),
                              //     decoration: BoxDecoration(
                              //       color: textFormColor,
                              //       borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              //     ),
                              //     child: Align(
                              //       alignment: Alignment.topLeft,
                              //       child: Text(
                              //         '검색',
                              //         style: f16w400,
                              //       ),
                              //     ),
                              //   ),
                              // ),
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
                                  return snapshot.data!.docs[index]['state'] !=
                                          '삭제'
                                      ? GestureDetector(
                                          onLongPress: () {
                                            showComponentDialog(
                                                context, '삭제하시겠습니까?', () {
                                              Get.back();
                                              deleteAnswer(snapshot
                                                  .data!.docs[index]['docId']);
                                            });
                                          },
                                          child: Column(
                                            children: [
                                              MainTile(
                                                isOpened:
                                                    snapshot.data!.docs[index]['state'] == '대기'
                                                        ? true
                                                        : false,
                                                isStudent: false,
                                                onTap: () async {
                                                  /// 개별문제 업로드
                                                  if (snapshot.data!.docs[index]
                                                          ['isIndividual'] == 'true') {
                                                    Get.toNamed(PdfIndMainScreen.id,
                                                        arguments: PdfIndMainScreen(
                                                            edit: 'true',
                                                            category: snapshot.data!.docs[index]['pdfCategory'],
                                                            docId: snapshot.data!.docs[index]['docId'],
                                                            password: snapshot.data!.docs[index]['password'],
                                                            answer: snapshot.data!.docs[index]['answer'],
                                                            scoreVisual: snapshot.data!.docs[index]['scoreVisual'],
                                                            title: snapshot.data!.docs[index]['individualTitle'],
                                                            body: snapshot.data!.docs[index]['individualBody'],
                                                            image: snapshot.data!.docs[index]['images'],
                                                            essayAnswer: snapshot.data!.docs[index]['temp1'],
                                                            countdown: snapshot.data!.docs[index]['temp2'],
                                                            file: snapshot.data!.docs[index]['individualFile'],
                                                            audio: snapshot.data!.docs[index]['audio'],
                                                            state: snapshot.data!.docs[index]['state'],
                                                            pdfUploadName: snapshot.data!.docs[index]['pdfUploadName'],
                                                            pdfUploadName2: snapshot.data!.docs[index]['pdfUploadName2'],
                                                            teacher: snapshot.data!.docs[index]['teacher'],
                                                            subject: snapshot.data!.docs[index]['category'],
                                                            temp1: snapshot.data!.docs[index]['temp1']));
                                                  }
                                                  /// 전체문제 업로드
                                                  else {
                                                    Get.toNamed(
                                                        PdfUploadScreen.id,
                                                        arguments: PdfUploadScreen(
                                                            category: snapshot.data!.docs[index]['pdfCategory'],
                                                            pdfUploadName: snapshot.data!.docs[index]['pdfUploadName'],
                                                            scoreVisual: snapshot.data!.docs[index]['scoreVisual'],
                                                            pdfUploadName2: snapshot.data!.docs[index]['pdfUploadName2'],
                                                            password: snapshot.data!.docs[index]['password'],
                                                            answerlength: snapshot.data!.docs[index]['answer'],
                                                            docId: snapshot.data!.docs[index]['docId'],
                                                            teacherName: snapshot.data!.docs[index]['teacher'],
                                                            countdown: snapshot.data!.docs[index]['temp2'],
                                                            state: snapshot.data!.docs[index]['state'],
                                                            subject: snapshot.data!.docs[index]['category'],
                                                            edit: true));
                                                  }
                                                },
                                                tName: us.userList[0].nickName,
                                                tCreateDate:
                                                    '${DateFormat('y-MM-dd HH:mm').format(DateTime.parse('${snapshot.data!.docs[index]['createDate']}'))}',
                                                title:
                                                    '${snapshot.data!.docs[index]['pdfCategory']}',
                                                switchOnTap: () {
                                                  if (snapshot.data!.docs[index]
                                                          ['state'] ==
                                                      '대기') {
                                                    updateData(
                                                        snapshot.data!
                                                                .docs[index]
                                                            ['docId'],
                                                        '완료');
                                                  } else {
                                                    updateData(snapshot.data!.docs[index]
                                                            ['docId'],
                                                        '대기');
                                                  }
                                                },
                                                storage:
                                                    '${snapshot.data!.docs[index]['state']}',
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
        // floatingActionButton: kIsWeb && (Get.width * 0.2 <= 171)
        //     ? FloatingActionButton.small(
        //         child: Icon(
        //           Icons.add,
        //           size: 16,
        //         ),
        //         backgroundColor: nowColor,
        //         onPressed: () {
        //           showComponentUploadDialog(context, '문제를 추가하시겠습니까?', () {
        //             Get.back();
        //             Get.toNamed(PdfUploadScreen.id);
        //           }, () {
        //             Get.back();
        //             Get.toNamed(PdfIndMainScreen.id);
        //           });
        //         },
        //       )
        //     : Container(),
        // : FloatingActionButton.extended(
        //     icon: Icon(Icons.check),
        //     label: Text(
        //       '출석관리',
        //       style: f16Whitew500,
        //     ),
        //     backgroundColor: nowColor,
        //     onPressed: () {
        //       Get.toNamed(QrTeacherMain.id);
        //       // showEditDialog(context, '출석 번호를 적어주세요', () {}, _checkCon);
        //     },
        //   ),
      ),
    );
  }

  Future<void> updateData(String docId, String value) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('answer');
    QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();
    snapshot.docs[0].reference.update({'state': '${value}'});
    // final allData = snapshot.docs.map((doc) => doc.data()).toList();
    // _allData = allData;
    // print('all : ${_allData.length}');
  }
}
