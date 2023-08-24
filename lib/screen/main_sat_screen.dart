import 'package:academy/screen/login/login_main_screen.dart';
import 'package:academy/screen/main/student/student_sat_screen.dart';
import 'package:academy/screen/main/teacher/teacher_sat_screen.dart';
import 'package:academy/util/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../provider/user_state.dart';
import '../../components/dialog/showAlertDialog.dart';
import '../../firebase/firebase_user.dart';
import '../../util/refresh_manager.dart';
import 'main/sat/sat_upload_screen.dart';

class MainSatScreen extends StatefulWidget {
  static final String id = '/main_sat_screen';

  const MainSatScreen({Key? key}) : super(key: key);

  @override
  State<MainSatScreen> createState() => _MainSatScreenState();
}

class _MainSatScreenState extends State<MainSatScreen> {
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
    final us = Get.put(UserState());
    return Scaffold(
        body: _isLoading
            ? LoadingBodyScreen()
            : us.isLogin == '' || us.userList.length == 0
            ? Container()
            : Stack(children: [
          Container(
              color: Color(0xffF7F7F7),
              child: us.userList[0].userType == '학생'
                  ? StudentSatScreen()
                  : TeacherSatScreen()),//TeacherSatScreen()),
        ])
    );
  }
}
