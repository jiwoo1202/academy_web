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
import 'package:academy/screen/main/student/test/individual/test_individual_screen_tablet.dart';
import 'package:academy/screen/main/student/test/test_main_screen_tablet.dart';
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
import '../../../util/behavior.dart';
import '../../../util/colors.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:http/http.dart' as http;
import '../../../util/font/font.dart';
import '../../../util/padding.dart';
import '../../community/community_main_screen.dart';
import '../../community/job/job_hunting_screen.dart';
import '../../community/notice/notice_main_screen.dart';
import '../../community/story/story_main_screen.dart';
import '../teacher/teacher_screen.dart';
import 'test/individual/sat/test_individual_screen_sat.dart';
import 'test/test_main_screen.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> with TickerProviderStateMixin{
  TextEditingController _pwcontroller = TextEditingController();
  TextEditingController _teacherCon = TextEditingController();
  late TabController _nestedTabController;
  bool isLoading = true;
  List<String> data = [];
  String initial = '';
  String? _dropdown = '전체';
  List<String> _dropdownList= ['전체','국어','수학','영어','과학','사회','한국사','sat','기타'];
  @override
  void initState() {
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());
    as.getDocid.value = [];
    as.teacherList.value = [];
    as.createList.value = [];
    _nestedTabController = TabController(length: 3, vsync: this);
    data = us.userList[0].userType == '학생'
        ? ['시험보기', '이야기', '공지사항']
        : ['시험올리기', '이야기', '구인구직', '공지사항'];
    initial = data.first.toString();
    super.initState();
  }

  @override
  void dispose() {
    _pwcontroller.dispose();
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
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: ScrollConfiguration(
            behavior: MyBehavior(), //마우스
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: Column(
                  children: [
                    Container(margin: EdgeInsets.symmetric(horizontal: Get.width * 0.15),
                      width: Get.width * 0.4,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _dropdown=='전체'
                            ? _teacherCon.text.trim().isNotEmpty
                              ? FirebaseFirestore.instance
                                .collection('answer')
                                .orderBy('nickName').where('state',isEqualTo: '대기')
                                .startAt([_teacherCon.text]).endAt(
                                [_teacherCon.text + '\uf8ff']).snapshots()
                              : FirebaseFirestore.instance
                                .collection('answer')
                                .where('state', isEqualTo: '대기')
                                .orderBy('createDate', descending: true)
                                .snapshots()
                        /// 드롭박스 선택시
                            : _teacherCon.text.trim().isNotEmpty
                              ? FirebaseFirestore.instance
                                .collection('answer')
                                .orderBy('nickName')
                                .where('state',isEqualTo: '대기')
                                .where('category',isEqualTo: _dropdown)
                                .startAt([_teacherCon.text]).endAt(
                                [_teacherCon.text + '\uf8ff']).snapshots()
                              : FirebaseFirestore.instance
                                .collection('answer')
                                .where('state', isEqualTo: '대기')
                                .where('category',isEqualTo: _dropdown)
                                .orderBy('createDate', descending: true)
                                .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: LoadingBodyScreen());
                          }
                          return Column(
                            children: [
                              const SizedBox(height: 52,),
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
                                  contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
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
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
                                width: Get.width*0.4,
                                child: DecoratedBox(
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Color(0xffebebeb)),
                                  child: Padding(
                                    padding: ph20v14,
                                    child: DropdownButton<String>(
                                      focusColor: Colors.white,
                                      isDense: true,
                                      isExpanded: true,
                                      underline: Container(),
                                      icon: Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Color(0xff535353),
                                      ),
                                      value: _dropdown,
                                      //elevation: 5,
                                      style: TextStyle(color: Colors.white),
                                      iconEnabledColor: Colors.black,
                                      items: _dropdownList.map((value){
                                        return DropdownMenuItem(
                                            value: value,
                                            child: Text(value,style: f18w400,));
                                      }).toList(),
                                      onChanged: (v) {
                                        setState(() {
                                          _dropdown = v;
                                        });
                                      },
                                    ),
                                  ),
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
                                          getAnswerLength(snapshot.data!.docs[index]['docId']);
                                          ts.answerDocId.value = '${snapshot.data!.docs[index]['docId']}';
                                          as.getTeacherName.value = '${snapshot.data!.docs[index]['teacher']}';
                                          as.temp2.value = '${snapshot.data!.docs[index]['temp2']}';
                                          showPasswordDialog(context, '비밀번호', () async {
                                            // if (snapshot.data!.docs[index]['student']
                                            //     .contains('${us.userList[0].id}')) {
                                            //   showOnlyConfirmDialog(
                                            //       context, '중복 테스트는 불가능 합니다.');
                                            // } else
                                              if (_pwcontroller.text == snapshot.data!.docs[index]['password']) {
                                              if (snapshot.data!.docs[index]['isIndividual'] == 'true') {
                                                Get.back();
                                                _pwcontroller.text = '';
                                                /// sat용 개별
                                                if(snapshot.data!.docs[index]['category']=='sat'){
                                                  Get.toNamed(TestIndividualSat.id,
                                                      arguments: TestIndividualSat(
                                                        docId: snapshot.data!.docs[index]['docId'],
                                                        myPage: false,
                                                      ));
                                                }
                                                /// 기본
                                                else{
                                                  Get.toNamed(TestIndividual.id,
                                                      arguments: TestIndividual(
                                                        docId: snapshot.data!.docs[index]['docId'],
                                                        myPage: false,
                                                      ));
                                                }
                                                // Get.toNamed(TestIndividualTablet.id,
                                                //     arguments: TestIndividualTablet(
                                                //       docId: snapshot.data!.docs[index]
                                                //           ['docId'],
                                                //       myPage: false,
                                                //     ));
                                              } else {
                                                Get.back();
                                                var url =
                                                    'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/12345%2F${snapshot.data!.docs[index]['teacher']}%2F${snapshot.data!.docs[index]['docId']}.pdf?alt=media';
                                                final file =
                                                    await http.get(Uri.parse(url));
                                                final content = file.bodyBytes;
                                                if(Get.width * 0.2 <=
                                                    204){
                                                  Get.toNamed(TestMainScreenTablet.id,
                                                      arguments: TestMainScreenTablet(
                                                        content: content,
                                                        hasAudio: snapshot
                                                            .data!.docs[index]['audio'],
                                                        teacher: snapshot
                                                            .data!.docs[index]['teacher'],
                                                        docId: snapshot.data!.docs[index]
                                                        ['docId'],
                                                      ));
                                                }
                                                else{
                                                  Get.toNamed(TestMainScreen.id,
                                                      arguments: TestMainScreen(
                                                        content: content,
                                                        hasAudio: snapshot.data!.docs[index]['audio'],
                                                        teacher: snapshot.data!.docs[index]['teacher'],
                                                        docId: snapshot.data!.docs[index]['docId'],
                                                      ));
                                                }

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
                            ],
                          );
                        },
                      ),
                    ),
                    Footer()
                  ],
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
      ),
    );
  }

  Future<bool> onTerminated(BuildContext context) async {
    return showComponentDialog(context, '앱을 종료하시겠습니까?', () {
      SystemNavigator.pop();
    });
  }

}