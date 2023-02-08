import 'package:academy/components/tile/textform_field.dart';
import 'package:academy/screen/community/community_main_screen.dart';

// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../api/pdf/pdf_api.dart';
import '../../components/button/main_button.dart';
import '../../components/controllers/firebase_cloud_messaging.dart';
import '../../components/controllers/local_notification_setting.dart';
import '../../components/controllers/notification_controller.dart';
import '../../components/dialog/showAlertDialog.dart';
import '../../firebase/firebase_user.dart';
import '../../model/user.dart';
import '../../provider/user_state.dart';
import '../../../../util/font.dart';

import '../community/story/story_detail_screen.dart';
import '../community/story/story_main_screen.dart';
import '../main/main_screen.dart';
import '../mypage/mypage_screen.dart';
import '../mypage/setting/setting_main_screen.dart';
import '../register/register_main_screen.dart';

class LoginMainScreen extends StatefulWidget {
  static final String id = '/login_main';

  const LoginMainScreen({Key? key}) : super(key: key);

  @override
  State<LoginMainScreen> createState() => _LoginMainScreenState();
}

class _LoginMainScreenState extends State<LoginMainScreen>
    with TickerProviderStateMixin {
  late TabController _nestedTabController;
  TextEditingController _studentIdController = TextEditingController();
  TextEditingController _studentPwController = TextEditingController();
  TextEditingController _teacherIdController = TextEditingController();
  TextEditingController _teacherPwController = TextEditingController();
  bool _obscureText = false;
  bool _obscureText2 = false;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List _userList = [];
  int type = 0;

  @override
  void initState() {
    _nestedTabController = TabController(length: 2, vsync: this);

    LocalNotifyCation().initializeNotification();
    _requestPermissions();
    print('init 에 몇 번 들어오니????');

    ///Fcm
    FCM().setNotifications();

    // AwesomeNotifications().setListeners(
    //     onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
    //     onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
    //     onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
    //     onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
    // );
    //
    // AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    //   if(!isAllowed){
    //     AwesomeNotifications().requestPermissionToSendNotifications();
    //   }
    // });

    // userGet('YaEDhOV20pKDnAz69ixf');
    super.initState();
  }

  void _requestPermissions() {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  @override
  void dispose() {
    super.dispose();
    _nestedTabController.dispose();
    _studentIdController.dispose();
    _studentPwController.dispose();
    _teacherPwController.dispose();
    _teacherIdController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final us = Get.put(UserState());
    // final user = User().obs;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("ACADEMY"),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 218, 0),
              child: TabBar(
                controller: _nestedTabController,
                unselectedLabelColor: Color(0xffA0A4A6),
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
                indicatorColor: Colors.transparent,
                indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(color: Colors.white, width: 5),
                    insets: EdgeInsets.symmetric(horizontal: 60)),
                labelColor: Colors.black,
                onTap: (int) {
                  setState(() {
                    type = _nestedTabController.index;
                  });
                },
                tabs: <Widget>[
                  Tab(
                    child: Text(
                      '학생',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Pretendard',
                          color: Colors.white),
                    ),
                  ),
                  Tab(
                    child: Text(
                      '선생님',
                      style: TextStyle(
                          fontSize: 18,
                          fontFamily: 'Pretendard',
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              type == 0
                  ? Text(
                      '학생 로그인',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          fontSize: 24),
                    )
                  : Text(
                      '선생님 로그인',
                      style: TextStyle(
                          fontFamily: 'Pretendard',
                          fontWeight: FontWeight.w700,
                          fontSize: 24),
                    ),
              SizedBox(
                height: 25,
              ),
              TextFormFields(
                  controller:
                      type == 0 ? _studentIdController : _teacherIdController,
                  obscureText: true,
                  hintText: '아이디를 입력해주세요',
                  surffixIcon: "0"),
              SizedBox(
                height: 16,
              ),
              TextFormFields(
                  controller:
                      type == 0 ? _studentPwController : _teacherPwController,
                  obscureText: _obscureText,
                  hintText: '비밀번호를 입력해 주세요',
                  surffixIcon: "1",
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  }),
              SizedBox(
                height: 16,
              ),
              MainButton(
                onPressed: () async {
                  switch (_nestedTabController.index) {
                    case 0:
                      if (_studentIdController.text == '' ||
                          _studentPwController.text == '') {
                        showOnlyLoginCheckDialog(context, '아이디 또는 비밀번호를 입력해주세요',
                            () {
                          Navigator.pop(context);
                        });
                      } else {
                        await userGet(_studentIdController.text,
                            _studentPwController.text);
                        if (us.userList.isEmpty) {
                          showOnlyLoginCheckDialog(context, '유저정보가 없습니다', () {
                            Navigator.pop(context);
                          });
                          return;
                        } else if(us.userList[0].userType=='학생'){
                          Get.offAllNamed(BottomNavigator.id);
                        }
                      }
                      break;
                    case 1:
                      print('선생님 로그인');
                      if (_teacherIdController.text == '' ||
                          _teacherPwController.text == '') {
                        showOnlyLoginCheckDialog(context, '아이디 또는 비밀번호를 입력해주세요',
                            () {
                          Navigator.pop(context);
                        });
                      } else {
                        await userGet(_teacherIdController.text,
                            _teacherPwController.text);
                        if (us.userList.isEmpty) {
                          showOnlyLoginCheckDialog(context, '유저정보가 없습니다', () {
                            Navigator.pop(context);
                          });
                          return;
                        } else if(us.userList[0].userType=='선생님'){
                          Get.offAllNamed(BottomNavigator.id);
                        }
                      }
                      break;
                  }
                },
                text: '로그인하기',
              ),
            ],
          ),
        ),
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.only(bottom: 26),
          child: Row(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  Get.toNamed(RegisterMainScreen.id);
                },
                child: Container(
                  height: 69,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(width: 2, color: Color(0xffDADADA)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '회원가입',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            color: Color(0xff535353)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () {
                  print('비밀번호 찾기');
                  // Get.toNamed(RegisterMainScreen.id);
                },
                child: Container(
                  height: 69,
                  width: MediaQuery.of(context).size.width * 0.5,
                  decoration: BoxDecoration(
                      border: Border(
                          top: BorderSide(width: 2, color: Color(0xffDADADA)))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '비밀번호 찾기',
                        style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16,
                            color: Color(0xff535353)),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class BottomNavigator extends StatefulWidget {
  static final String id = '/bottom';

  const BottomNavigator({Key? key}) : super(key: key);

  @override
  State<BottomNavigator> createState() => _BottomNavigatorState();
}

class _BottomNavigatorState extends State<BottomNavigator> with TickerProviderStateMixin {
  List<Widget> _widgetOptions = [];
  late TabController _bottomTabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [MainScreen(), CommunityMainScreen(),MyPageScreen()];
    _bottomTabController = TabController(length: 3, vsync: this);
    // _bottomTabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final us = Get.put(UserState());

    return Scaffold(
      bottomNavigationBar: Container(
        padding: const EdgeInsets.only(top: 19, bottom: 41),
        child: TabBar(
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          indicatorColor: Colors.transparent,
          indicatorSize: TabBarIndicatorSize.label,
          controller: _bottomTabController,
          unselectedLabelStyle: f16w700greyA,
          labelStyle: f16w700,
          unselectedLabelColor: Colors.grey,
          labelColor: const Color(0xff3D6177),
          tabs: <Widget>[
            Tab(
              icon: _currentIndex == 0
                  ? SvgPicture.asset(
                'assets/bottom/home_click.svg',
                width: 132,
                height: 48,
              )
                  : SvgPicture.asset(
                'assets/bottom/home_not_click.svg',
                width: 132,
                height: 48,
              ),
              // text: '홈',
            ),
            Tab(
              icon: _currentIndex == 1
                  ? SvgPicture.asset(
                'assets/bottom/community_click.svg',
                width: 132,
                height: 48,
              )
                  : SvgPicture.asset(
                'assets/bottom/community_not_click.svg',
                width: 132,
                height: 48,
              ),
              // text: '커뮤니티',
            ),
            Tab(
              icon: _currentIndex == 2
                  ? SvgPicture.asset(
                'assets/bottom/my_profile_click.svg',
                width: 132,
                height: 48,
              )
                  : SvgPicture.asset(
                'assets/bottom/my_profile_not_click.svg',
                width: 132,
                height: 48,
              ),
              // text: '마이페이지',
            ),
          ],
        ),
      ),
      body: TabBarView(
        physics: const NeverScrollableScrollPhysics(),
        children: _widgetOptions,
        controller: _bottomTabController,
      ),
    );
  }
}
