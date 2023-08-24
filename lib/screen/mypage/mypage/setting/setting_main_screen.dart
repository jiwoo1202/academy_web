import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/components/switch/switch_button.dart';
import 'package:academy/provider/user_state.dart';
import 'package:academy/screen/login/login_main_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../components/footer/footer.dart';
import '../../../../util/colors.dart';
import '../../../../util/font/font.dart';
import '../blockPage.dart';
import '../job_setting_screen.dart';

class SettingMainScreen extends StatefulWidget {
  static final String id = '/setting_main';

  const SettingMainScreen({Key? key}) : super(key: key);

  @override
  State<SettingMainScreen> createState() => _SettingMainScreenState();
}

class _SettingMainScreenState extends State<SettingMainScreen> {
  bool _alarm = false;
  static final storage = FlutterSecureStorage();
  @override
  Widget build(BuildContext context) {
    final us = Get.put(UserState());
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xff6f7072),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        elevation: 0,
        title: Text(
          '설정',
          style: f24w500,
        ),
        centerTitle: true,
        backgroundColor: backColor,
      ),
      body: Container(
        color: backColor,
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: kIsWeb? (Get.width * 0.2 <= 171) ? 20 : 108 : 0),
              decoration: BoxDecoration(
                  color: buttonTextColor,
                  borderRadius: BorderRadius.circular(8.0)),
              child: ListTile(
                leading: SvgPicture.asset(
                  'assets/icon/set.svg',
                  width: 24,
                  height: 24,
                ),
                title: Text(
                  '차단 설정',
                  style: f18w400,
                ),
                onTap: () {
                  Get.toNamed(BlockPage.id);
                },
                trailing: SvgPicture.asset(
                  'assets/icon/arrowFront.svg',
                  width: 7,
                  height: 14,
                ),
              ),
            ),
            us.userList[0].userType == '학생'
                ? Container()
                : const SizedBox(
                    height: 16,
                  ),
            us.userList[0].userType == '학생'
                ? Container()
                : Container(
                    padding: EdgeInsets.symmetric(horizontal: kIsWeb? (Get.width * 0.2 <= 171) ? 20 : 108 : 0),
                    decoration: BoxDecoration(
                        color: buttonTextColor,
                        borderRadius: BorderRadius.circular(8.0)),
                    child: ListTile(
                      leading: SvgPicture.asset(
                        'assets/icon/set.svg',
                        width: 24,
                        height: 24,
                      ),
                      title: Text(
                        '구인구직 설정',
                        style: f18w400,
                      ),
                      onTap: () {
                        Get.toNamed(JobSettingScreen.id);
                      },
                      trailing: SvgPicture.asset(
                        'assets/icon/arrowFront.svg',
                        width: 7,
                        height: 14,
                      ),
                    ),
                  ),

            const SizedBox(
              height: 16,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: kIsWeb? (Get.width * 0.2 <= 171) ? 20 : 108 : 0),
              decoration: BoxDecoration(
                  color: buttonTextColor,
                  borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: SvgPicture.asset(
                  'assets/icon/bell.svg',
                  width: 24,
                  height: 24,
                ),
                title: Text(
                  '알림',
                  style: f18w400,
                ),
                onTap: () {

                },
                trailing: SwitchButton(
                  onTap: () {
                    setState(() {
                      _alarm = !_alarm;
                    });
                  },
                  value: _alarm,
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: kIsWeb? (Get.width * 0.2 <= 171) ? 20 : 108 : 0),
              decoration: BoxDecoration(
                  color: buttonTextColor,
                  borderRadius: BorderRadius.circular(8.0),
                  ),
              child: ListTile(
                leading: SvgPicture.asset(
                  'assets/icon/set.svg',
                  width: 24,
                  height: 24,
                ),
                title: Text(
                  '버전',
                  style: f18w400,
                ),
                onTap: () {

                },
                trailing: Text(
                  'ver 1.0.0',
                  style: f18w400,
                ),
              ),
            ),

            const SizedBox(
              height: 16,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: kIsWeb? (Get.width * 0.2 <= 171) ? 20 : 108 : 0),
              decoration: BoxDecoration(
                  color: buttonTextColor,
                  borderRadius: BorderRadius.circular(8.0),
              ),
              child: ListTile(
                leading: SvgPicture.asset(
                  'assets/icon/set.svg',
                  width: 24,
                  height: 24,
                ),
                title: Text(
                  '로그아웃',
                  style: f18w400,
                ),
                onTap: () {
                  showComponentDialog(context, '로그아웃 하시겠습니까?', () {
                    storage.delete(key: "isLogged");
                    storage.delete(key: 'pw');
                    Get.offAll(() => LoginMainScreen());
                  });
                },
              ),
            ),

            kIsWeb? const SizedBox(height: 100,) : Container(),
            kIsWeb? Container(padding: const EdgeInsets.symmetric(horizontal: 12),child: Footer()) : Container(),
          ],
        ),
      ),
    );
  }
}
