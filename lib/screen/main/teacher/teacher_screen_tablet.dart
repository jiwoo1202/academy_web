import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/firebase/firebase_answer.dart';
import 'package:academy/screen/community/job/job_hunting_screen.dart';
import 'package:academy/util/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../components/footer/footer.dart';
import '../../../components/tile/main_tile.dart';
import '../../../firebase/firebase_log.dart';
import '../../../provider/user_state.dart';
import '../../../util/behavior.dart';
import '../../../util/colors.dart';
import '../../../util/font/font.dart';
import '../../../util/refresh_manager.dart';
import '../../community/notice/notice_main_screen.dart';
import '../../community/story/story_main_screen.dart';
import '../../login/login_main_screen.dart';
import '../../mypage/mypage/mypage_screen.dart';
import 'all/pdf_upload_screen.dart';
import 'individual/pdf_individual_main_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class TeacherScreen extends StatefulWidget {
  const TeacherScreen({Key? key}) : super(key: key);

  @override
  State<TeacherScreen> createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  // bool _isOpened = false;
  List _allData = [];
  List<bool> _isOpened = [];
  List<bool> _selection = List.generate(3, (_) => false);
  List<String> data = [];
  String initial = '';

  @override
  void initState() {
    final us = Get.put(UserState());
    data = ['시험올리기', '이야기', '구인구직', '공지사항'];


    initial = data.first.toString();
    // Future.delayed(Duration.zero, () async {
    //   // await teacherGet();
    //   // CollectionReference ref = FirebaseFirestore.instance.collection('answer');
    //   // QuerySnapshot snapshot = await ref
    //   //     .orderBy('createDate')
    //   //     .where('teacher', isEqualTo: '1234')
    //   //     .get();
    //   // final allData = snapshot.docs.map((doc) => doc.data()).toList();
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final us = Get.put(UserState());

    return Scaffold(
      // appBar: AppBar(
      //   automaticallyImplyLeading: false,
      //   title: Row(
      //     children: [
      //       SvgPicture.asset(
      //         'assets/logo.svg',
      //         width: (kIsWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
      //         height: (kIsWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
      //       ),
      //       const SizedBox(
      //         width: 8,
      //       ),
      //       kIsWeb && (Get.width * 0.2 <= 171) ? Container() : Text('Teacher')
      //     ],
      //   ),
      //   // leadingWidth: 100,
      //   actions: [
      //     // Container(
      //     //   alignment: AlignmentDirectional.center,
      //     //   child: DropdownButton<String>(
      //     //     underline: Container(),
      //     //     value: initial,
      //     //     icon: Icon(
      //     //       Icons.keyboard_arrow_down,
      //     //       color: const Color(0xffffffff),
      //     //     ),
      //     //     dropdownColor: nowColor,
      //     //     focusColor: nowColor,
      //     //     alignment: AlignmentDirectional.center,
      //     //     items: data.map((String items) {
      //     //       return DropdownMenuItem(
      //     //         value: items,
      //     //         child: Text('${items}',
      //     //             style: kIsWeb && (Get.width * 0.2 <= 171)
      //     //                 ? f12Whitew500
      //     //                 : f16Whitew500,
      //     //             textAlign: TextAlign.center),
      //     //       );
      //     //     }).toList(),
      //     //     onChanged: (String? newvalue) {
      //     //       if (newvalue == '이야기') {
      //     //         Get.toNamed(StoryMainScreen.id);
      //     //         // Get.to(() => StoryMainScreen());
      //     //       } else if (newvalue == '시험올리기') {
      //     //         // Get.to(() => StudentScreen());
      //     //       } else if (newvalue == '구인구직') {
      //     //         Get.toNamed(JobHuntingScreen.id);
      //     //         // Get.to(() => StudentScreen());
      //     //       } else {
      //     //         Get.to(() => NoticeMainScreen());
      //     //       }
      //     //     },
      //     //   ),
      //     // ),
      //     kIsWeb && (Get.width * 0.2 <= 171)
      //         ? SizedBox(
      //             height: 0,
      //           )
      //         : GestureDetector(
      //             onTap: () {
      //               showComponentUploadDialog(context, '문제를 추가하시겠습니까?', () {
      //                 Get.back();
      //                 Get.toNamed(PdfUploadScreen.id);
      //                 // Get.to(() => PdfUploadScreen());
      //               }, () {
      //                 Get.back();
      //                 Get.toNamed(PdfIndMainScreen.id);
      //                 // Get.to(() => PdfIndMainScreen());
      //               });
      //             },
      //             child: Center(
      //               child: Text(
      //                 '문제 추가',
      //                 style: kIsWeb && (Get.width * 0.2 <= 171)
      //                     ? f12Whitew700
      //                     : f16Whitew700,
      //               ),
      //             ),
      //           ),
      //     const SizedBox(
      //       width: 20,
      //     ),
      //     GestureDetector(
      //       onTap: () {
      //         Get.toNamed(MyPageScreen.id,
      //             arguments: MyPageScreen(
      //               whichPage: 'main',
      //             ));
      //       },
      //       child: Center(
      //           child: Padding(
      //         padding: const EdgeInsets.only(right: 8.0),
      //         child: Image.asset(
      //           'assets/icon/user.png',
      //           color: Colors.white,
      //           width: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
      //           height: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
      //         ),
      //       )),
      //     ),
      //     const SizedBox(
      //       width: 20,
      //     ),
      //     GestureDetector(
      //       onTap: () {
      //         showComponentDialog(context, '로그아웃을 하시겠습니까?', () {
      //           Get.offAllNamed(LoginMainScreen.id);
      //           RefreshManager.addToCookie('id', '');
      //           RefreshManager.addToCookie('pw', '');
      //           us.isLogin.value = '';
      //         });
      //       },
      //       child: Center(
      //           child: Padding(
      //         padding: const EdgeInsets.only(right: 8.0),
      //         child: Image.asset(
      //           'assets/icon/logout.png',
      //           color: Colors.white,
      //           width: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
      //           height: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
      //         ),
      //       )),
      //     ),
      //   ],
      //   elevation: 0,
      //   backgroundColor: nowColor,
      // ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            width: Get.width,
            // height: Get.height,
            padding: kIsWeb && (Get.width * 0.2 <= 171)
                ? EdgeInsets.only(right: 20, left: 20, top: 60)
                : EdgeInsets.only(right: 120, left: 120, top: 60),
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('answer')
                    .where('teacher', isEqualTo: us.userList[0].id)
                    // .where('state', isNotEqualTo: '삭제')
                    .orderBy('createDate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                        height: Get.height, child: LoadingBodyScreen());
                  }
                  return Column(
                    children: [
                      Text(
                        '선생님',
                        style: f24w500,
                      ),
                      SizedBox(
                        height: 30,
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
                          return snapshot.data!.docs[index]['state'] != '삭제'
                              ? GestureDetector(
                                  onLongPress: () {
                                    showComponentDialog(context, '삭제하시겠습니까?',
                                        () {
                                      Get.back();
                                      deleteAnswer(
                                          snapshot.data!.docs[index]['docId']);
                                    });
                                  },
                                  child: Column(
                                    children: [
                                      MainTile(
                                        isOpened: snapshot.data!.docs[index]
                                                    ['state'] ==
                                                '대기'
                                            ? true
                                            : false,
                                        isStudent: false,
                                        onTap: () async {
                                          if (snapshot.data!.docs[index]
                                                  ['isIndividual'] ==
                                              'true') {
                                            Get.toNamed(PdfIndMainScreen.id,
                                                arguments: PdfIndMainScreen(
                                                    edit: 'true',
                                                    category: snapshot.data!
                                                        .docs[index]['pdfCategory'],
                                                    docId: snapshot
                                                        .data!.docs[index]['docId'],
                                                    password: snapshot.data!
                                                        .docs[index]['password'],
                                                    answer: snapshot.data!
                                                        .docs[index]['answer'],
                                                    title:
                                                    snapshot.data!.docs[index]
                                                    ['individualTitle'],
                                                    body: snapshot.data!.docs[index]
                                                    ['individualBody'],
                                                    image: snapshot.data!
                                                        .docs[index]['images'],
                                                    essayAnswer: snapshot.data!.docs[index]['temp1'],
                                                    countdown: snapshot.data!.docs[index]
                                                    ['temp2'],
                                                    file: snapshot.data!.docs[index]
                                                    ['individualFile'],
                                                    audio: snapshot.data!.docs[index]['audio'],
                                                    state: snapshot.data!.docs[index]['state'],
                                                    pdfUploadName: snapshot.data!.docs[index]['pdfUploadName'],
                                                    pdfUploadName2: snapshot.data!.docs[index]['pdfUploadName2'],
                                                    teacher:snapshot.data!.docs[index]['teacher']
                                                ));
                                            // Get.to(() => PdfIndMainScreen(
                                            //     edit: 'true',
                                            //     category: snapshot.data!
                                            //         .docs[index]['pdfCategory'],
                                            //     docId: snapshot
                                            //         .data!.docs[index]['docId'],
                                            //     password: snapshot.data!
                                            //         .docs[index]['password'],
                                            //     answer: snapshot.data!
                                            //         .docs[index]['answer'],
                                            //     title:
                                            //     snapshot.data!.docs[index]
                                            //     ['individualTitle'],
                                            //     body: snapshot.data!.docs[index]
                                            //     ['individualBody'],
                                            //     image: snapshot.data!
                                            //         .docs[index]['images'],
                                            //     countdown: snapshot.data!.docs[index]
                                            //     ['temp2'],
                                            //     file: snapshot.data!.docs[index]
                                            //     ['individualFile'],
                                            //     audio: snapshot.data!.docs[index]['audio'],
                                            //     state: snapshot.data!.docs[index]['state'],
                                            //     pdfUploadName: snapshot.data!.docs[index]['pdfUploadName'],
                                            //     pdfUploadName2: snapshot.data!.docs[index]['pdfUploadName2'],
                                            //     teacher:snapshot.data!.docs[index]['teacher']
                                            //     ));
                                          } else {
                                            Get.toNamed(PdfUploadScreen.id,
                                                arguments: PdfUploadScreen(
                                                    category: snapshot.data!.docs[index]
                                                    ['pdfCategory'],
                                                    pdfUploadName:
                                                    snapshot.data!.docs[index]
                                                    ['pdfUploadName'],
                                                    password: snapshot.data!.docs[index]
                                                    ['password'],
                                                    answerlength: snapshot.data!
                                                        .docs[index]['answer'],
                                                    docId: snapshot.data!.docs[index]
                                                    ['docId'],
                                                    teacherName: snapshot.data!
                                                        .docs[index]['teacher'],
                                                    countdown: snapshot.data!.docs[index]
                                                    ['temp2'],
                                                    edit: true));
                                            // Get.to(() => PdfUploadScreen(
                                            //     category: snapshot.data!.docs[index]
                                            //         ['pdfCategory'],
                                            //     pdfUploadName:
                                            //         snapshot.data!.docs[index]
                                            //             ['pdfUploadName'],
                                            //     password: snapshot.data!.docs[index]
                                            //         ['password'],
                                            //     answerlength: snapshot.data!
                                            //         .docs[index]['answer'],
                                            //     docId: snapshot.data!.docs[index]
                                            //         ['docId'],
                                            //     teacherName: snapshot.data!
                                            //         .docs[index]['teacher'],
                                            //     countdown: snapshot.data!.docs[index]
                                            //         ['temp2'],
                                            //     edit: true));
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
                                                snapshot.data!.docs[index]
                                                    ['docId'],
                                                '완료');
                                          } else {
                                            updateData(
                                                snapshot.data!.docs[index]
                                                    ['docId'],
                                                '대기');
                                          }
                                        },
                                        storage: '${snapshot.data!.docs[index]['state']}',
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
                      Footer(),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  );
                }),
          ),
        ),
      ),
      floatingActionButton: kIsWeb && (Get.width * 0.2 <= 171)
          ? FloatingActionButton.small(
              child: Icon(
                Icons.add,
                size: 16,
              ),
              backgroundColor: nowColor,
              onPressed: () {
                showComponentUploadDialog(context, '문제를 추가하시겠습니까?', () {
                  Get.back();
                  Get.toNamed(PdfUploadScreen.id);
                }, () {
                  Get.back();
                  Get.toNamed(PdfIndMainScreen.id);
                });
              },
            )
          : Container(),
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
