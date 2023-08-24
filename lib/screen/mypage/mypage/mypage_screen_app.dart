import 'package:academy/provider/test_state.dart';
import 'package:academy/provider/user_state.dart';
import 'package:academy/screen/community/job/job_hunting_screen.dart';
import 'package:academy/screen/community/story/story_main_screen.dart';
import 'package:academy/screen/main/main_screen.dart';
import 'package:academy/screen/mypage/mypage/testcheck/test_check_main_screen.dart';
import 'package:academy/screen/register/policy.dart';
import 'package:academy/screen/register/privatePolicy.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../components/dialog/showAlertDialog.dart';
import '../../../components/footer/footer.dart';
import '../../../firebase/firebase_user.dart';
import '../../../util/colors.dart';
import '../../../util/font/font.dart';
import '../../../util/refresh_manager.dart';
import '../../login/login_main_screen.dart';
import '../qna/qna.dart';
import 'blockPage.dart';
import 'score/score_check_screen.dart';
import 'dart:html' as html;

import 'setting/setting_main_screen.dart';

class MyPageScreenApp extends StatefulWidget {
  static final String id = '/mypage_screen_app';
  final String? whichPage;

  const MyPageScreenApp({Key? key, this.whichPage: 'main'}) : super(key: key);

  @override
  State<MyPageScreenApp> createState() => _MyPageScreenAppState();
}

class _MyPageScreenAppState extends State<MyPageScreenApp> {
  bool _isLoading = true;

  @override
  void initState() {
    final us = Get.put(UserState());

    Future.delayed(Duration.zero, () async {
      await userGet(
          RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
      us.isLogin.value = RefreshManager.getCookie('type');
      // print('type check : ${us.isLogin}');
      if (us.isLogin == '' || us.userList.length == 0) {

        showConfirmTapDialog(context, '로그인 후에 이용할 수 있습니다', () {
          Get.offAllNamed(LoginMainScreen.id);
        });
      }

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
    final args = ModalRoute.of(context)!.settings.arguments as MyPageScreenApp?;

    return Container(
      color: backColor,
      child: Column(
        children: [
          Padding(
            padding: kIsWeb && (Get.width * 0.2 <= 171)
                ? EdgeInsets.only(right: 20, left: 20, top: 60)
                : EdgeInsets.only(right: 120, left: 120, top: 60),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: kIsWeb
                      ? (Get.width * 0.2 <= 171)
                      ? 20
                      : 108
                      : 0),
              decoration: BoxDecoration(
                  color: buttonTextColor,
                  borderRadius: BorderRadius.circular(8.0)),
              child: us.userList[0].userType == '선생님'
                  ? Container()
                  : ListTile(
                leading: SvgPicture.asset(
                  'assets/icon/check.svg',
                  width: 24,
                  height: 24,
                ),
                title: Text(
                  '내 점수 확인',
                  style: f18w400,
                ),
                onTap: () {
                  ts.teacherNameList.value = [];
                  Get.toNamed(ScoreCheckScreen.id);
                },
                trailing: SvgPicture.asset(
                  'assets/icon/arrowFront.svg',
                  width: 7,
                  height: 14,
                ),
              ),
            ),
          ),
          SizedBox(
            height: us.userList[0].userType == '선생님' ? 16 : 0,
          ),
          us.userList[0].userType == '선생님'
              ? Padding(
            padding: kIsWeb && (Get.width * 0.2 <= 171)
                ? EdgeInsets.only(right: 20, left: 20)
                : EdgeInsets.only(right: 120, left: 120),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: kIsWeb
                      ? (Get.width * 0.2 <= 171)
                      ? 20
                      : 108
                      : 0),
              decoration: BoxDecoration(
                  color: buttonTextColor,
                  borderRadius: BorderRadius.circular(8.0)),
              child: ListTile(
                leading: SvgPicture.asset(
                  'assets/icon/check.svg',
                  width: 24,
                  height: 24,
                ),
                title: Text(
                  '테스트 확인',
                  style: f18w400,
                ),
                onTap: () {
                  Get.toNamed(TestCheckMainScreen.id);
                },
                trailing: SvgPicture.asset(
                  'assets/icon/arrowFront.svg',
                  width: 7,
                  height: 14,
                ),
              ),
            ),
          )
              : SizedBox(
            height: 0,
          ),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: kIsWeb && (Get.width * 0.2 <= 171)
                ? EdgeInsets.only(
              right: 20,
              left: 20,
            )
                : EdgeInsets.only(right: 120, left: 120),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: kIsWeb
                      ? (Get.width * 0.2 <= 171)
                      ? 20
                      : 108
                      : 0),
              decoration: BoxDecoration(
                  color: buttonTextColor,
                  borderRadius: BorderRadius.circular(8.0)),
              child: ListTile(
                leading: SvgPicture.asset(
                  'assets/icon/qna.svg',
                  width: 24,
                  height: 24,
                ),
                title: Text(
                  'Q&A',
                  style: f18w400,
                ),
                onTap: () {
                  Get.toNamed(QnaPage.id);
                },
                trailing: SvgPicture.asset(
                  'assets/icon/arrowFront.svg',
                  width: 7,
                  height: 14,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: kIsWeb && (Get.width * 0.2 <= 171)
                ? EdgeInsets.only(right: 20, left: 20)
                : EdgeInsets.only(right: 120, left: 120),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: kIsWeb
                      ? (Get.width * 0.2 <= 171)
                      ? 20
                      : 108
                      : 0),
              decoration: BoxDecoration(
                  color: buttonTextColor,
                  borderRadius: BorderRadius.circular(8.0)),
              child: ListTile(
                leading: SvgPicture.asset(
                  'assets/icon/qna.svg',
                  width: 24,
                  height: 24,
                ),
                title: Text(
                  '이용약관',
                  style: f18w400,
                ),
                onTap: () {
                  GetPlatform.isWeb
                      ? html.window.open(
                      'http://misnetwork.iptime.org:8880/useService',
                      'naver')
                      : Get.toNamed(PolicyPage.id);
                },
                trailing: SvgPicture.asset(
                  'assets/icon/arrowFront.svg',
                  width: 7,
                  height: 14,
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          Padding(
            padding: kIsWeb && (Get.width * 0.2 <= 171)
                ? EdgeInsets.only(
              right: 20,
              left: 20,
            )
                : EdgeInsets.only(right: 120, left: 120),
            child: Container(
              padding: EdgeInsets.symmetric(
                  horizontal: kIsWeb
                      ? (Get.width * 0.2 <= 171)
                      ? 20
                      : 108
                      : 0),
              decoration: BoxDecoration(
                  color: buttonTextColor,
                  borderRadius: BorderRadius.circular(8.0)),
              child: ListTile(
                leading: SvgPicture.asset(
                  'assets/icon/qna.svg',
                  width: 24,
                  height: 24,
                ),
                title: Text(
                  '개인정보취급방침',
                  style: f18w400,
                ),
                onTap: () {
                  GetPlatform.isWeb
                      ? html.window.open(
                      'http://misnetwork.iptime.org:8880/policy',
                      'naver')
                      : //https://www.naver.com
                  Get.toNamed(PrivatePolicy.id);
                },
                trailing: SvgPicture.asset(
                  'assets/icon/arrowFront.svg',
                  width: 7,
                  height: 14,
                ),
              ),
            ),
          ),
          Spacer(),
          Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 12, vertical: 12),
              child: Footer())
        ],
      ),
    );
  }
}
