import 'package:academy/screen/login/login_main_screen.dart';
import 'package:academy/screen/main/main_screen_app.dart';
import 'package:academy/util/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../firebase/firebase_log.dart';
import '../../../provider/user_state.dart';
import '../../components/dialog/showAlertDialog.dart';
import '../../firebase/firebase_user.dart';
import '../../util/font/font.dart';
import '../../util/refresh_manager.dart';
import 'main_screen.dart';
import 'student/student_screen.dart';
import 'teacher/individual/pdf_individual_main_screen.dart';
import 'teacher/all/pdf_upload_screen.dart';
import 'teacher/teacher_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

class MainScreenMain extends StatefulWidget {
  static final String id = '/main_screen_main';

  const MainScreenMain({Key? key}) : super(key: key);

  @override
  State<MainScreenMain> createState() => _MainScreenMainState();
}

class _MainScreenMainState extends State<MainScreenMain> {
  bool _isLoading = true;

  @override
  void initState() {
    final us = Get.put(UserState());

    Future.delayed(Duration.zero, () async {
      await userGet(RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
      us.isLogin.value = RefreshManager.getCookie('type');
      if (us.isLogin == '' && us.userList.length == 0) {
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
    return Get.width*0.2 <171?MainScreenApp():MainScreen();
  }
}
