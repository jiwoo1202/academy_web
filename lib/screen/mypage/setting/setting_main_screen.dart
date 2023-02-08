import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/components/switch/switch_button.dart';
import 'package:academy/screen/login/login_main_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';


import '../../../util/colors.dart';
import '../../../util/font.dart';



class SettingMainScreen extends StatefulWidget {
  static final String id = '/setting_main';
  const SettingMainScreen({Key? key}) : super(key: key);

  @override
  State<SettingMainScreen> createState() => _SettingMainScreenState();
}

class _SettingMainScreenState extends State<SettingMainScreen> {
  bool _alarm = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:  AppBar(
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
        title: Text('설정', style: f21w700grey5,),
        centerTitle: true,
        backgroundColor: backColor,
      ),
      body: Container(color: backColor,
        padding: const EdgeInsets.fromLTRB(24, 50, 24, 0),
        child: Column(
          children: [
            Container(
              height: 64,
              decoration: BoxDecoration(
                  color: buttonTextColor,
                  borderRadius: BorderRadius.circular(8.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.25),
                    offset: Offset(0,1),
                  )
                ]
              ),
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: SvgPicture.asset(
                    'assets/icon/bell.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
                title: Text('알림',style: f20w500,),
                onTap: () {
                  print('알림');
                },
                trailing: SwitchButton(
                  onTap: (){
                    setState(() {
                      _alarm = !_alarm;
                    });
                  },
                  value: _alarm,
                ),
              ),
            ),
            const SizedBox(height: 16,),
            Container(
              height: 64,
              decoration: BoxDecoration(
                  color: buttonTextColor,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      offset: Offset(0,1),

                    )
                  ]),
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: SvgPicture.asset(
                    'assets/icon/set.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
                  title: Text('버전',style: f18w400,),
                onTap: () {
                  print('설정');
                },
                trailing: Text('ver 1.0.0',style: f18w400,),
              ),
            ),
            const SizedBox(height: 16,),
            Container(
              height: 64,
              decoration: BoxDecoration(
                  color: buttonTextColor,
                  borderRadius: BorderRadius.circular(8.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.25),
                      offset: Offset(0,1),

                    )
                  ]),
              child: ListTile(
                leading: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: SvgPicture.asset(
                    'assets/icon/set.svg',
                    width: 24,
                    height: 24,
                  ),
                ),
                title: Text('로그아웃',style: f18w400,),
                onTap: () {
                  showComponentDialog(context, '로그아웃 하시겠습니까?', () {
                    Get.offAll(()=>LoginMainScreen());
                  });
                },
              ),
            ),
            // ListTile(
            //   leading: Icon(
            //     Icons.question_answer,
            //     color: Colors.grey[850],
            //     size: 40,
            //   ),
            //   title: Text('Q&A',style: f20w500,),
            //   onTap: () {
            //     print('QNA');
            //   },
            //   trailing: Icon(Icons.add,  size: 40,),
            // ),
          ],
        ),
      ),
    );
  }
}
