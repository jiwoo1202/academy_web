import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/components/footer/footer.dart';
import 'package:academy/provider/answer_state.dart';
import 'package:academy/provider/test_state.dart';
import 'package:academy/provider/user_state.dart';

import 'package:academy/util/loading.dart';
import 'package:academy/util/refresh_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../components/tile/main_tile.dart';
import '../../../util/behavior.dart';
import '../../../util/font/font.dart';
import 'test/individual/sat/test_individual_screen_sat.dart';
class StudentSatScreen extends StatefulWidget {
  const StudentSatScreen({Key? key}) : super(key: key);

  @override
  State<StudentSatScreen> createState() => _StudentSatScreenState();
}

class _StudentSatScreenState extends State<StudentSatScreen> with TickerProviderStateMixin{
  TextEditingController _pwcontroller = TextEditingController();
  TextEditingController _teacherCon = TextEditingController();
  late TabController _nestedTabController;
  bool isLoading = true;
  List<String> data = [];
  String initial = '';
  int type = 0;
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
                        stream: FirebaseFirestore.instance
                            .collection('sat')
                            .where('status', isEqualTo: '1')
                            .where('visual', isEqualTo: 'true')
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
                              // Container(
                              //   width: Get.width*0.4,
                              //   child: DecoratedBox(
                              //     decoration: BoxDecoration(
                              //         borderRadius: BorderRadius.circular(8),
                              //         color: Color(0xffebebeb)),
                              //     child: Padding(
                              //       padding: ph20v14,
                              //       child: DropdownButton<String>(
                              //         focusColor: Colors.white,
                              //         isDense: true,
                              //         isExpanded: true,
                              //         underline: Container(),
                              //         icon: Icon(
                              //           Icons.keyboard_arrow_down,
                              //           color: Color(0xff535353),
                              //         ),
                              //         value: _dropdown,
                              //         //elevation: 5,
                              //         style: TextStyle(color: Colors.white),
                              //         iconEnabledColor: Colors.black,
                              //         items: _dropdownList.map((value){
                              //           return DropdownMenuItem(
                              //               value: value,
                              //               child: Text(value,style: f18w400,));
                              //         }).toList(),
                              //         onChanged: (v) {
                              //           setState(() {
                              //             _dropdown = v;
                              //           });
                              //         },
                              //       ),
                              //     ),
                              //   ),
                              // ),
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
                                        subject: snapshot.data!.docs[index]['mainTitle'],
                                        tName: snapshot.data!.docs[index]['nickName'],
                                        tCreateDate:
                                        '${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(snapshot.data!.docs[index]['createDate']))}',
                                        onTap: () async {
                                          showPasswordDialog(context, '비밀번호', () async {
                                            if (_pwcontroller.text == snapshot.data!.docs[index]['pw']) {
                                              Get.back();
                                              RefreshManager.addToCookie('satTeacherDocId', '${snapshot.data!.docs[index]['docId']}');
                                              RefreshManager.addToCookie('satmyPage', 'false');
                                              RefreshManager.addToCookie('satpart', '1');
                                              RefreshManager.addToCookie('satUpdateDocId', '');
                                              RefreshManager.addToCookie('studentList', '');
                                              Get.toNamed(TestIndividualSat.id);
                                              _pwcontroller.text = '';
                                            } else {
                                              Get.back();
                                              showOnlyConfirmDialog(context, '비밀번호가 맞지 않습니다');
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