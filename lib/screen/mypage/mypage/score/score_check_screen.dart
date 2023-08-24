import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/screen/main/main_screen.dart';
import 'package:academy/screen/mypage/mypage/mypage_screen.dart';
import 'package:academy/util/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../components/tile/main_tile.dart';
import '../../../../firebase/firebase_test.dart';
import '../../../../firebase/firebase_user.dart';
import '../../../../provider/test_state.dart';
import '../../../../provider/user_state.dart';
import '../../../../util/colors.dart';

import '../../../../util/font/font.dart';
import '../../../../util/refresh_manager.dart';
import '../../../login/login_main_screen.dart';
import '../../../main/student/test/individual/test_individual_screen.dart';
import '../../../main/student/test/test_check_screen.dart';
// mypageScreen app
class ScoreCheckScreen extends StatefulWidget {
  static final String id = '/score_check';

  const ScoreCheckScreen({Key? key}) : super(key: key);

  @override
  State<ScoreCheckScreen> createState() => _ScoreCheckScreenState();
}

class _ScoreCheckScreenState extends State<ScoreCheckScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      final us = Get.put(UserState());
      await userGet(
          RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
      us.isLogin.value = RefreshManager.getCookie('type');
      // print('type check : ${us.isLogin}');
      if (us.isLogin == '' || us.userList.length == 0) {

        showConfirmTapDialog(context, '로그인 후에 이용할 수 있습니다', () {
          Get.offAllNamed(LoginMainScreen.id);
        });
      }
      await firebaseAllQuestionGet('${us.userList[0].id}');
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ts = Get.put(TestState());
    final us = Get.put(UserState());
    return WillPopScope(
      onWillPop: () {
        return Future(() {
          Get.offAllNamed(MyPageScreen.id,
              arguments: MyPageScreen(
                whichPage: 'main',
              ));
          return true;
        });
      },
      child: Scaffold(
        appBar: AppBar(
          // leading: null,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              GestureDetector(
                onTap: () {
                  Get.offAllNamed(MainScreen.id);
                },
                child: SvgPicture.asset(
                  'assets/logo.svg',
                  width:
                      (GetPlatform.isWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
                  height:
                      (GetPlatform.isWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
                ),
              ),
              SizedBox(
                width: 8,
              ),
              GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                  ? Container()
                  : Text('Score')
            ],
          ),
          // leadingWidth: 100,
          actions: [
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
                  width:
                      GetPlatform.isWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                  height:
                      GetPlatform.isWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                ),
              )),
            ),
          ],
          elevation: 0,
          backgroundColor: nowColor,
        ),
        body: _isLoading
            ? LoadingBodyScreen()
            : SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                scrollDirection: Axis.vertical,
                child: Padding(
                  padding: GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                      ? EdgeInsets.only(right: 20, left: 20, top: 60)
                      : EdgeInsets.only(right: 120, left: 120, top: 60),
                  child: ListView.builder(
                    itemCount: ts.myAnswer.length,
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          MainTile(
                            isOpened: true,
                            isStudent: true,
                            title: '',
                            subject: '${ts.myAnswer[index]['testTitle']}',
                            arrowString: '${ts.myAnswer[index]['score']}점 확인하기',
                            tCreateDate: '채점일 : ${DateFormat('y-MM-dd hh:mm').format(DateTime.parse('${ts.myAnswer[index]['createDate']}'))}',
                            tName: '${ts.myAnswer[index]['nickName']}',
                            onTap: () async {
                              if (ts.myAnswer[index]['status'] == '채점중') {
                                showOnlyConfirmDialog(
                                    context, '아직 종료되지 않은 시험입니다');
                              } else {
                                if (ts.myAnswer[index]['isIndividual'] == 'true') {
                                  ts.individualAnswer.value = ts.myAnswer[index]['answer'];
                                  Get.toNamed(TestIndividual.id,
                                      arguments: TestIndividual(
                                        isChecked: 'true',
                                        docId: ts.myAnswer[index]['answerDocid'],
                                        myPage: true,
                                      ));
                                  // Get.to(()=>TestIndividual(
                                  //   isChecked: 'true',
                                  //   docId: ts.myAnswer[index]['answerDocid'],
                                  //   myPage: true,
                                  // ));
                                } else {
                                  ts.testDocId.value =
                                      ts.myAnswer[index]['docId'];
                                  ts.answerDocId.value =
                                      ts.myAnswer[index]['answerDocid'];
                                  Get.to(() => TestCheckScreen(
                                      teacherName: ts.myAnswer[index]
                                          ['teacher'],
                                      docId: ts.myAnswer[index]['answerDocid'],
                                      myPage: true));
                                }
                              }
                            },
                            switchOnTap: () {},
                          ),
                          SizedBox(
                            height: 30,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
