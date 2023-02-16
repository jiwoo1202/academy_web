
import 'package:academy/provider/test_state.dart';
import 'package:academy/provider/user_state.dart';
import 'package:academy/screen/mypage/blockPage.dart';
import 'package:academy/screen/mypage/setting/setting_main_screen.dart';
import 'package:academy/screen/register/policy.dart';
import 'package:academy/screen/register/privatePolicy.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../components/dialog/showAlertDialog.dart';
import '../../firebase/firebase_user.dart';
import '../../util/colors.dart';
import '../../util/font.dart';
import 'score/score_check_screen.dart';

class MyPageScreen extends StatefulWidget {
  static final String id = '/bottom';

  const MyPageScreen({Key? key}) : super(key: key);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  final ts = Get.put(TestState());
  final us = Get.put(UserState());
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return onTerminated(context);
      },
      child: Scaffold(
        appBar:  AppBar(
          leading: Container(),
          elevation: 0,
          title: Text('마이페이지', style: f24w500,),
          centerTitle: true,
          backgroundColor: backColor,
        ),
        body: Container(color: backColor,
          padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 20),
          child: Column(
           children: [
             Container(
              decoration: BoxDecoration(
                color: buttonTextColor,
                borderRadius: BorderRadius.circular(8.0)),
               child:
               us.userList[0].userType=='선생님'?
                   Container():
               ListTile(
                 leading: SvgPicture.asset(
                   'assets/icon/check.svg',
                   width: 24,
                   height: 24,
                 ),
                 title: Text('내 점수 확인',style: f18w400,),
                 onTap: () {
                   ts.teacherNameList.value = [];
                   Get.toNamed(ScoreCheckScreen.id);
                   print('점수');
                 },
                 trailing: SvgPicture.asset(
                   'assets/icon/arrowFront.svg',
                   width: 7,
                   height: 14,
                 ),
               ),
             ),
             const SizedBox(height: 16,),

             Container(
               decoration: BoxDecoration(
                   color: buttonTextColor,
                   borderRadius: BorderRadius.circular(8.0)),
               child: ListTile(
                 leading: SvgPicture.asset(
                   'assets/icon/qna.svg',
                   width: 24,
                   height: 24,
                 ),
                 title: Text('Q&A',style: f18w400,),
                 onTap: () {
                   // Get.toNamed(SettingMainScreen.id);
                   print('qna');
                 },
                 trailing: SvgPicture.asset(
                   'assets/icon/arrowFront.svg',
                   width: 7,
                   height: 14,
                 ),
               ),
             ),
             const SizedBox(height: 16,),
             Container(
               decoration: BoxDecoration(
                   color: buttonTextColor,
                   borderRadius: BorderRadius.circular(8.0)),
               child: ListTile(
                 leading: SvgPicture.asset(
                   'assets/icon/qna.svg',
                   width: 24,
                   height: 24,
                 ),
                 title: Text('이용약관',style: f18w400,),
                 onTap: () {
                   Get.toNamed(PolicyPage.id);
                   print('이용약관');
                 },
                 trailing: SvgPicture.asset(
                   'assets/icon/arrowFront.svg',
                   width: 7,
                   height: 14,
                 ),
               ),
             ),
             const SizedBox(height: 16,),
             Container(
               decoration: BoxDecoration(
                   color: buttonTextColor,
                   borderRadius: BorderRadius.circular(8.0)),
               child: ListTile(
                 leading: SvgPicture.asset(
                   'assets/icon/qna.svg',
                   width: 24,
                   height: 24,
                 ),
                 title: Text('개인정보취급방침',style: f18w400,),
                 onTap: () {
                   Get.toNamed(PrivatePolicy.id);
                   print('개인정보취급방침');
                 },
                 trailing: SvgPicture.asset(
                   'assets/icon/arrowFront.svg',
                   width: 7,
                   height: 14,
                 ),
               ),
             ),

             const SizedBox(height: 16,),
             Container(
               decoration: BoxDecoration(
                   color: buttonTextColor,
                   borderRadius: BorderRadius.circular(8.0)),
               child: ListTile(
                 leading: SvgPicture.asset(
                   'assets/icon/set.svg',
                   width: 24,
                   height: 24,
                 ),
                 title: Text('설정',style: f18w400,),
                 onTap: () {
                   Get.toNamed(SettingMainScreen.id);
                   print('설정');
                 },
                 trailing: SvgPicture.asset(
                   'assets/icon/arrowFront.svg',
                   width: 7,
                   height: 14,
                 ),
               ),
             ),
           ],
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
