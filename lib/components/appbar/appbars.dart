import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../provider/user_state.dart';
import '../../screen/login/login_main_screen.dart';
import '../../screen/mypage/mypage/mypage_screen.dart';
import '../../util/colors.dart';
import '../../util/font/font.dart';
import '../../util/refresh_manager.dart';
import '../dialog/showAlertDialog.dart';

AppBar Appbars({required UserState us, required BuildContext context}) {
  return us.userList.length == 0
      ? AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
        )
      : AppBar(
          // leading: null,
          automaticallyImplyLeading: false,
          title: Container(
            padding: EdgeInsets.symmetric(horizontal: Get.width * 0.1),
            child: Row(
              children: [
                SvgPicture.asset(
                  'assets/logo.svg',
                  width: 20,
                  height: 20,
                ),
                Spacer(),
                Center(
                  child: Container(
                    width: us.userList[0].userType == '학생' ? Get.width * 0.34 : Get.width * 0.35,
                    height: 55,
                    child: us.userList[0].userType == '학생'
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    us.bottomidx.value = 0;
                                    Get.toNamed(BottomNavigator.id);
                                  },
                                  child: Text('시험보기', style: f14Whitew700)),
                              Spacer(),
                              GestureDetector(
                                  onTap: () {
                                    us.bottomidx.value = 1;
                                    Get.toNamed(BottomNavigator.id);
                                  },
                                  child: Text('SAT 보기', style: f14Whitew700)),
                              Spacer(),
                              GestureDetector(
                                  onTap: () {
                                    us.bottomidx.value = 2;
                                    Get.toNamed(BottomNavigator.id);
                                  },
                                  child: Text('강의보기', style: f14Whitew700)),
                              Spacer(),
                              GestureDetector(
                                  onTap: () {
                                    us.bottomidx.value = 3;
                                    Get.toNamed(BottomNavigator.id);
                                  },
                                  child: Text('이야기', style: f14Whitew700)),
                            ],
                          )
                        : Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                  onTap: () {
                                    us.bottomidx.value = 0;
                                    Get.toNamed(BottomNavigator.id);
                                  },
                                  child: Text('시험등록', style: f14Whitew700)),
                              Spacer(),
                              GestureDetector(
                                  onTap: () {
                                    us.bottomidx.value = 1;
                                    Get.toNamed(BottomNavigator.id);
                                  },
                                  child: Text('SAT 등록', style: f14Whitew700)),
                              Spacer(),
                              GestureDetector(
                                  onTap: () {
                                    us.bottomidx.value = 2;
                                    Get.toNamed(BottomNavigator.id);
                                  },
                                  child: Text('강의등록', style: f14Whitew700)),
                              Spacer(),
                              GestureDetector(
                                  onTap: () {
                                    us.bottomidx.value = 3;
                                    Get.toNamed(BottomNavigator.id);
                                  },
                                  child: Text('이야기', style: f14Whitew700)),
                              Spacer(),
                              GestureDetector(
                                  onTap: () {
                                    us.bottomidx.value = 4;
                                    Get.toNamed(BottomNavigator.id);
                                  },
                                  child: Text('구인구직', style: f14Whitew700)),
                            ],
                          ),
                  ),
                ),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    Get.toNamed(MyPageScreen.id,
                        arguments: MyPageScreen(
                          whichPage: 'main',
                        ));
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.asset(
                      'assets/icon/user.png',
                      color: Colors.white,
                      width: 24,
                      height: 24,
                    ),
                  ),
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
                        width: 24,
                        height: 24,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // leadingWidth: 100,
          actions: [],

          centerTitle: true,
          elevation: 0,
          backgroundColor: nowColor,
        );
}
