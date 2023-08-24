import 'package:academy/screen/login/login_main_screen.dart';
import 'package:academy/screen/main/main_screen_app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../provider/user_state.dart';
import '../../components/dialog/showAlertDialog.dart';
import '../../firebase/firebase_user.dart';
import '../../util/refresh_manager.dart';
import '../main_sat_screen.dart';

class MainSatScreenMain extends StatefulWidget {
  static final String id = '/main__sat_screen_main';

  const MainSatScreenMain({Key? key}) : super(key: key);

  @override
  State<MainSatScreenMain> createState() => _MainSatScreenMainState();
}

class _MainSatScreenMainState extends State<MainSatScreenMain> {
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
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Get.width*0.2 <171?MainScreenApp():MainSatScreen();
  }
}
