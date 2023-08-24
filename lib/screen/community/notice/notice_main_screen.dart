import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../components/dialog/showAlertDialog.dart';
import '../../../components/footer/footer.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/user_state.dart';
import '../../../util/colors.dart';
import '../../../util/font/font.dart';
import '../../../util/loading.dart';
import '../../../util/refresh_manager.dart';
import '../../login/login_main_screen.dart';
import '../../main/student/student_screen.dart';
import '../../main/teacher/teacher_screen.dart';
import '../../mypage/mypage/mypage_screen.dart';
import '../job/job_hunting_screen.dart';
import '../story/story_main_screen.dart';

class NoticeMainScreen extends StatefulWidget {
  static final String id = '/notice_screen';
  const NoticeMainScreen({Key? key}) : super(key: key);

  @override
  State<NoticeMainScreen> createState() => _NoticeMainScreenState();
}

class _NoticeMainScreenState extends State<NoticeMainScreen> {
  List<String> data = [];
  String initial = '';
  bool _isLoading = true;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      final us = Get.put(UserState());
      await userGet(RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
      us.isLogin.value = RefreshManager.getCookie('type');
      if (us.isLogin == '' || us.userList.length == 0) {

        showConfirmTapDialog(context, '로그인 후에 이용할 수 있습니다', () {
          Get.offAllNamed(LoginMainScreen.id);
        });
      }

      data = us.userList[0].userType == '학생'
          ? ['공지사항', '시험보기', '이야기']
          : ['공지사항 ', '시험올리기', '이야기', '구인구직'];
      initial = data.first.toString();

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
      appBar: GetPlatform.isWeb
          ? AppBar(
              automaticallyImplyLeading: false,
              title: Row(
                children: [
                  SvgPicture.asset(
                    'assets/logo.svg',
                    width: (kIsWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
                    height: (kIsWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  Text((kIsWeb && (Get.width * 0.2 <= 171)) ? '' : 'Web')
                ],
              ),
              // leadingWidth: 100,
              actions: [
                Container(
                  alignment: AlignmentDirectional.center,
                  child: DropdownButton<String>(
                    underline: Container(),
                    value: initial,
                    icon: Icon(
                      Icons.keyboard_arrow_down,
                      color: const Color(0xffffffff),
                    ),
                    dropdownColor: nowColor,
                    alignment: AlignmentDirectional.center,
                    items: data.map((String items) {
                      return DropdownMenuItem(
                        value: items,
                        child: Text('${items}',
                            style: kIsWeb && (Get.width * 0.2 <= 171)
                                ? f12Whitew500
                                : f16Whitew500,
                            textAlign: TextAlign.center),
                      );
                    }).toList(),
                    onChanged: (String? newvalue) {
                      if (newvalue == '공지사항') {
                      } else if (newvalue == '시험보기') {
                        Get.to(() => StudentScreen());
                      } else if (newvalue == '시험올리기') {
                        Get.to(() => TeacherScreen());
                      } else if (newvalue == '구인구직') {
                        Get.to(() => JobHuntingScreen());
                      } else {
                        Get.to(() => StoryMainScreen());
                      }
                    },
                  ),
                ),
                const SizedBox(
                  width: 20,
                ),
                GestureDetector(
                  onTap: () {
                    Get.to(() => MyPageScreen());
                  },
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.asset(
                      'assets/icon/user.png',
                      color: Colors.white,
                      width: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                      height: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                    ),
                  )),
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
                      width: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                      height: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                    ),
                  )),
                ),
              ],
              elevation: 0,
              backgroundColor: nowColor,
            )
          : null,
      body: _isLoading
          ? LoadingBodyScreen()
          : Column(
            children: [
              Container(
                    padding: EdgeInsets.symmetric(vertical: Get.height * 0.3),
                    child: Center(child: Text('준비중입니다\n빠른 시일내 돌아올게요 ^^'))),
              const SizedBox(height: 100,),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Footer(),
              ),
              const SizedBox(height: 20,),
              ],
          ),
    );
  }
}
