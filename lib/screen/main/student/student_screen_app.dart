import 'dart:io';

import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/components/footer/footer.dart';
import 'package:academy/firebase/firebase_answer.dart';
import 'package:academy/provider/answer_state.dart';
import 'package:academy/provider/test_state.dart';
import 'package:academy/provider/user_state.dart';
import 'package:academy/screen/login/login_main_screen.dart';
import 'package:academy/screen/main/main_screen.dart';
import 'package:academy/screen/main/student/test/individual/test_individual_screen.dart';
import 'package:academy/screen/mypage/mypage/mypage_screen.dart';
import 'package:academy/util/loading.dart';
import 'package:academy/util/refresh_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../api/pdf/pdf_api.dart';
import '../../../components/tile/main_tile.dart';
import '../../../util/colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../../../util/font/font.dart';
import '../../community/community_main_screen.dart';
import '../../community/job/job_hunting_screen.dart';
import '../../community/notice/notice_main_screen.dart';
import '../../community/story/story_main_screen.dart';
import '../teacher/teacher_screen.dart';
import 'test/test_main_screen.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  TextEditingController _pwcontroller = TextEditingController();
  TextEditingController _teacherCon = TextEditingController();
  TextEditingController _checkCon = TextEditingController();
  bool isLoading = true;
  List<String> data = [];
  String initial = '';

  // final headers = {
  //   "Access-Control-Allow-Origin": "*",
  //   "Access-Control-Allow-Methods": "POST, GET, OPTIONS, DELETE",
  //   "Origin": "https://misnetwork.iptime.org:3333"
  // };

  // String allowCORSEndPoint = "https://api.allorigins.win/raw?url=";

  @override
  void initState() {
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());
    as.getDocid.value = [];
    as.teacherList.value = [];
    as.createList.value = [];
    data = us.userList[0].userType == '학생'
        ? ['시험보기', '이야기', '공지사항']
        : ['시험올리기', '이야기', '구인구직', '공지사항'];
    initial = data.first.toString();
    super.initState();
  }

  @override
  void dispose() {
    _pwcontroller.dispose();
    _checkCon.dispose();
    _teacherCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());
    final ts = Get.put(TestState());
    return WillPopScope(
      onWillPop: () {
        return Future(() => true);
      },
      child: Scaffold(
        appBar: GetPlatform.isWeb
            ? AppBar(
                // leading: null,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    SvgPicture.asset(
                      'assets/logo.svg',
                      width: (kIsWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
                      height: (kIsWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    kIsWeb && (Get.width * 0.2 <= 171)
                        ? Container()
                        : Text('Student')
                  ],
                ),
                // leadingWidth: 100,
                actions: [
                  // Container(
                  //   alignment: AlignmentDirectional.center,
                  //   child: DropdownButton<String>(
                  //     underline: Container(),
                  //     value: initial,
                  //     icon: Icon(
                  //       Icons.keyboard_arrow_down,
                  //       color: const Color(0xffffffff),
                  //     ),
                  //     dropdownColor: nowColor,
                  //     focusColor: nowColor,
                  //     alignment: AlignmentDirectional.center,
                  //     items: data.map((String items) {
                  //       return DropdownMenuItem(
                  //         value: items,
                  //         child: Text('${items}',
                  //             style: kIsWeb && (Get.width * 0.2 <= 171)
                  //                 ? f12Whitew500
                  //                 : f16Whitew500,
                  //             textAlign: TextAlign.center),
                  //       );
                  //     }).toList(),
                  //     onChanged: (String? newvalue) {
                  //       if (newvalue == '이야기') {
                  //         Get.toNamed(StoryMainScreen.id);
                  //         // Get.to(() => StoryMainScreen());
                  //       } else if (newvalue == '시험보기') {
                  //         // Get.to(() => StudentScreen());
                  //       } else {
                  //         Get.to(() => NoticeMainScreen());
                  //       }
                  //     },
                  //   ),
                  // ),
                  // const SizedBox(
                  //   width: 20,
                  // ),
                  GestureDetector(
                    onTap: () {
                      Get.toNamed(MyPageScreen.id,
                          arguments: MyPageScreen(
                            whichPage: 'main',
                          ));
                    },
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        'assets/icon/user.png',
                        color: Colors.white,
                        width: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                        height: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                      ),
                    )),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  GestureDetector(
                    onTap: () {
                      showComponentDialog(context, '로그아웃을 하시겠습니까?', () {
                        Get.offAllNamed(LoginMainScreen.id);
                        RefreshManager.addToCookie('id', '');
                        RefreshManager.addToCookie('pw', '');
                        us.isLogin.value = '';
                      });
                    },
                    child: Center(
                        child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Image.asset(
                        'assets/icon/logout.png',
                        color: Colors.white,
                        width: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                        height: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                      ),
                    )),
                  ),
                ],
                elevation: 0,
                backgroundColor: nowColor,
              )
            : null,
        body: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          child: SingleChildScrollView(
            physics: ClampingScrollPhysics(),
            child: Container(
              width: Get.width,
              padding: kIsWeb && (Get.width * 0.2 <= 171)
                  ? EdgeInsets.only(right: 20, left: 20, top: 60)
                  : EdgeInsets.only(right: 120, left: 120, top: 60),
              child: StreamBuilder<QuerySnapshot>(
                stream: _teacherCon.text.trim().isNotEmpty
                    ? FirebaseFirestore.instance
                        .collection('answer')
                        .orderBy('nickName').where('state',isEqualTo: '대기')
                        .startAt([_teacherCon.text]).endAt(
                            [_teacherCon.text + '\uf8ff']).snapshots()
                    : FirebaseFirestore.instance
                        .collection('answer')
                        .where('state', isEqualTo: '대기')
                        .orderBy('createDate', descending: true)
                        .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: LoadingBodyScreen());
                  }
                  return Column(
                    children: [
                      Text(
                        '학생',
                        style: f24w500,
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      //검색
                      TextFormField(
                        // enabled: !_pay,
                        controller: _teacherCon,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (v) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Color(0xffEBEBEB),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8)),
                          hintText: '선생님 검색',
                          suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {});
                              },
                              child: Icon(
                                Icons.search_outlined,
                                color: Colors.black,
                                size: 30,
                              )),
                          hintStyle: f16w400grey8,
                        ),
                      ),
                      SizedBox(
                        height: GetPlatform.isWeb ? 80 : 40,
                      ),
                      // snapshot.data?.docs==null?Text('22'):
                      ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return Column(
                            children: [
                              MainTile(
                                isOpened: true,
                                isStudent: true,
                                subject: snapshot.data!.docs[index]
                                    ['pdfCategory'],
                                tName: snapshot.data!.docs[index]['nickName'],
                                tCreateDate:
                                    '${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(snapshot.data!.docs[index]['createDate']))}',
                                onTap: () async {
                                  getAnswerLength(
                                      snapshot.data!.docs[index]['docId']);
                                  ts.answerDocId.value =
                                      '${snapshot.data!.docs[index]['docId']}';
                                  as.getTeacherName.value =
                                      '${snapshot.data!.docs[index]['teacher']}';
                                  as.temp2.value =
                                      '${snapshot.data!.docs[index]['temp2']}';
                                  showPasswordDialog(context, '비밀번호', () async {
                                    // if (snapshot.data!.docs[index]['student']
                                    //     .contains('${us.userList[0].id}')) {
                                    //   showOnlyConfirmDialog(
                                    //       context, '중복 테스트는 불가능 합니다.');
                                    // } else
                                      if (_pwcontroller.text ==
                                        snapshot.data!.docs[index]
                                            ['password']) {
                                      if (snapshot.data!.docs[index]
                                              ['isIndividual'] ==
                                          'true') {
                                        Get.back();
                                        _pwcontroller.text = '';
                                        // Get.to(() => TestIndividual(
                                        //       docId: snapshot.data!.docs[index]
                                        //           ['docId'],
                                        //     ));
                                        Get.toNamed(TestIndividual.id,
                                            arguments: TestIndividual(
                                              docId: snapshot.data!.docs[index]
                                                  ['docId'],
                                              myPage: false,
                                            ));
                                      } else {
                                        var url =
                                            'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/12345%2F${snapshot.data!.docs[index]['teacher']}%2F${snapshot.data!.docs[index]['docId']}.pdf?alt=media';
                                        final file =
                                            await http.get(Uri.parse(url));
                                        final content = file.bodyBytes;

                                        Get.back();
                                        Get.toNamed(TestMainScreen.id,
                                            arguments: TestMainScreen(
                                              content: content,
                                              hasAudio: snapshot
                                                  .data!.docs[index]['audio'],
                                              teacher: snapshot
                                                  .data!.docs[index]['teacher'],
                                              docId: snapshot.data!.docs[index]
                                                  ['docId'],
                                            ));
                                      }
                                      _pwcontroller.text = '';
                                    } else {
                                      Get.back();
                                      showOnlyConfirmDialog(
                                          context, '비밀번호가 맞지 않습니다');
                                      _pwcontroller.text = '';
                                    }
                                  }, _pwcontroller);
                                },
                                switchOnTap: () {},
                                title: '',
                              ),
                              SizedBox(
                                height: 16,
                              ),
                            ],
                          );
                        },
                      ),

                      Footer(),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
        // floatingActionButton: FloatingActionButton.extended(
        //   icon: Icon(Icons.edit_calendar_sharp),
        //   label: Text(
        //     '출석하기',
        //     style: f16Whitew500,
        //   ),
        //   backgroundColor: nowColor,
        //   onPressed: () {
        //     showEditDialog(context, '출석 번호를 적어주세요', () {}, _checkCon);
        //   },
        // ),
      ),
    );
  }

  Future<bool> onTerminated(BuildContext context) async {
    return showComponentDialog(context, '앱을 종료하시겠습니까?', () {
      SystemNavigator.pop();
    });
  }
}
