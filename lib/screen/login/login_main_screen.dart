import 'package:academy/components/tile/textform_field.dart';
import 'package:academy/screen/community/community_main_screen.dart';
import 'package:academy/screen/login/findPassword.dart';

// import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../api/pdf/pdf_api.dart';
import '../../components/button/main_button.dart';
import '../../components/controllers/firebase_cloud_messaging.dart';
import '../../components/controllers/local_notification_setting.dart';
import '../../components/controllers/notification_controller.dart';
import '../../components/dialog/showAlertDialog.dart';
import '../../components/footer/footer.dart';
import '../../firebase/firebase_user.dart';
import '../../model/user.dart';
import '../../provider/user_state.dart';
import '../../util/colors.dart';
import '../../util/font.dart';
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
  String userInfo = "";
  String userpw = '';
  String usertype = '';

  // final userData = GetStorage('user');
  static final storage = new FlutterSecureStorage();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  List _userList = [];
  int type = 0;

  void initialization() async {
    await Future.delayed(Duration(seconds: 3));
    FlutterNativeSplash.remove();
  }

  @override
  void initState() {
    _nestedTabController = TabController(length: 2, vsync: this);

    initialization();
    LocalNotifyCation().initializeNotification();
    _requestPermissions();
    print('init 에 몇 번 들어오니????');

    ///Fcm
    FCM().setNotifications();
    _asyncMethod();

    // userData.writeIfNull('isLogged', true);
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

  _asyncMethod() async {
    userInfo = (await storage.read(key: "isLogged"))!;
    userpw = (await storage.read(key: "pw"))!;
    print(userInfo);

    if (userInfo != null) {
      // 로그인
      await userGet(userInfo, userpw);
      Get.toNamed(BottomNavigator.id);
    }
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
          // title: Text(GetPlatform.isWeb ? "ACADEMY WEB" : "ACADEMY"),
          title: GetPlatform.isWeb
              ? Row(
                  children: [
                    SvgPicture.asset('assets/logo.svg'),
                    SizedBox(
                      width: 8,
                    ),
                    Text('Web')
                  ],
                )
              : SvgPicture.asset('assets/logo.svg'),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(44),
            child: Padding(
              padding: GetPlatform.isWeb
                  ? EdgeInsets.zero
                  : EdgeInsets.fromLTRB(0, 0, 205, 0),
              child: TabBar(
                controller: _nestedTabController,
                unselectedLabelColor: nowColor,
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
                indicatorColor: Colors.transparent,
                indicator: UnderlineTabIndicator(
                    borderSide: BorderSide(color: Colors.white, width: 5),
                    insets: GetPlatform.isWeb
                        ? EdgeInsets.zero
                        : EdgeInsets.symmetric(horizontal: 60)),
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
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Pretendard',
                          color: Colors.white),
                    ),
                  ),
                  Tab(
                    child: Text(
                      '선생님',
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'Pretendard',
                          color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          backgroundColor: GetPlatform.isWeb ? nowColor : primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 0),
          child: GetPlatform.isWeb
              ? Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        type == 0
                            ? '학생으로 아카데미를 로그인하시겠습니까?'
                            : '선생님으로 아카데미를 로그인하시겠습니까?',
                        style: f18w700,
                      ),
                      const SizedBox(
                        height: 28,
                      ),
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
                          controller: type == 0
                              ? _studentIdController
                              : _teacherIdController,
                          obscureText: true,
                          hintText: '아이디를 입력해주세요',
                          surffixIcon: "0"),
                      SizedBox(
                        height: 16,
                      ),
                      TextFormFields(
                          controller: type == 0
                              ? _studentPwController
                              : _teacherPwController,
                          obscureText: _obscureText,
                          hintText: '비밀번호를 입력해 주세요',
                          surffixIcon: "1",
                          onTap: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          }),
                      const SizedBox(
                        height: 40,
                      ),
                      MainButton(
                        onPressed: () async {
                          print('1');
                          switch (_nestedTabController.index) {
                            case 0:
                              print('2');
                              if (_studentIdController.text == '' ||
                                  _studentPwController.text == '') {
                                showOnlyLoginCheckDialog(
                                    context, '아이디 또는 비밀번호를 입력해주세요', () {
                                  Navigator.pop(context);
                                });
                              } else {
                                await userGet(_studentIdController.text,
                                    _studentPwController.text);
                                setState(() {});
                                if (us.userList.isEmpty) {
                                  showOnlyLoginCheckDialog(
                                      context, '아이디 또는 비밀번호가 올바르지 않습니다', () {
                                    Navigator.pop(context);
                                  });
                                  return;
                                } else if (us.userList[0].userType == '학생') {
                                  if(GetPlatform.isWeb){
                                    print('is web');
                                  }else{
                                    await storage.write(
                                        key: "isLogged",
                                        value: _studentIdController.text);
                                    await storage.write(
                                        key: "pw",
                                        value: _studentPwController.text);
                                    Get.toNamed(BottomNavigator.id);
                                  }
                                } else {
                                  showOnlyConfirmDialog(
                                      context, "아이디 또는 비밀번호가 올바르지 않습니다");
                                }
                              }
                              break;
                            case 1:
                              print('3');
                              print('선생님 로그인');
                              if (_teacherIdController.text == '' ||
                                  _teacherPwController.text == '') {
                                showOnlyLoginCheckDialog(
                                    context, '아이디 또는 비밀번호를 입력해주세요', () {
                                  Navigator.pop(context);
                                });
                              } else {
                                await userGet(_teacherIdController.text,
                                    _teacherPwController.text);
                                if (us.userList.isEmpty) {
                                  showOnlyLoginCheckDialog(
                                      context, '아이디 또는 비밀번호가 올바르지 않습니다', () {
                                    Navigator.pop(context);
                                  });
                                  return;
                                } else if (us.userList[0].userType == '선생님') {
                                  print('${us.userList[0].id}');
                                  if(GetPlatform.isWeb){
                                    print('is web');
                                  }else{
                                    await storage.write(
                                        key: "isLogged",
                                        value: _teacherIdController.text);
                                    await storage.write(
                                        key: "pw",
                                        value: _teacherPwController.text);
                                  }
                                  // userData.write('id', _teacherIdController.text);
                                  // userData.write('pw', _teacherPwController.text);
                                  // userData.write('userType', '선생님');
                                  // userData.write('isLogged',true);
                                  // print(userData.read('isLogged'));
                                  print('유저타입: ${us.userList[0].userType}');
                                  Get.toNamed(BottomNavigator.id);
                                } else {
                                  showOnlyConfirmDialog(context, "아이디 또는 비밀번호가 올바르지 않습니다");
                                }
                              }
                              break;
                          }
                        },
                        text: '로그인하기',
                      ),
                      const SizedBox(
                        height: 40,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                              onTap: (){
                                Get.toNamed(RegisterMainScreen.id);
                              },child: Text('회원가입',style: f16w700greyA,)),
                          GestureDetector(
                              onTap: (){
                                Get.toNamed(FindPassword.id);
                              },
                              child: Text('비밀번호 찾기',style: f16w700greyA,)),
                        ],
                      ),

                     GetPlatform.isWeb ? Spacer() : Container(),
                      GetPlatform.isWeb ?  Row(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Footer(),
                        ],
                      ) : Container()
                    ],
                  ),
                )
              : Column(
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
                        controller: type == 0
                            ? _studentIdController
                            : _teacherIdController,
                        obscureText: true,
                        hintText: '아이디를 입력해주세요',
                        surffixIcon: "0"),
                    SizedBox(
                      height: 16,
                    ),
                    TextFormFields(
                        controller: type == 0
                            ? _studentPwController
                            : _teacherPwController,
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
                              showOnlyLoginCheckDialog(
                                  context, '아이디 또는 비밀번호를 입력해주세요', () {
                                Navigator.pop(context);
                              });
                            } else {
                              await userGet(_studentIdController.text,
                                  _studentPwController.text);
                              setState(() {});
                              if (us.userList.isEmpty) {
                                showOnlyLoginCheckDialog(
                                    context, '아이디 또는 비밀번호가 올바르지 않습니다', () {
                                  Navigator.pop(context);
                                });
                                return;
                              } else if (us.userList[0].userType == '학생') {
                                if(GetPlatform.isWeb){
                                  print('web in------');
                                  Get.toNamed(MainScreen.id);
                                }else{
                                  await storage.write(
                                      key: "isLogged",
                                      value: _studentIdController.text);
                                  await storage.write(
                                      key: "pw",
                                      value: _studentPwController.text);
                                  Get.toNamed(BottomNavigator.id);
                                }
                              } else {
                                showOnlyConfirmDialog(
                                    context, "아이디 또는 비밀번호가 올바르지 않습니다");
                              }
                            }
                            break;
                          case 1:
                            print('선생님 로그인');
                            if (_teacherIdController.text == '' ||
                                _teacherPwController.text == '') {
                              showOnlyLoginCheckDialog(
                                  context, '아이디 또는 비밀번호를 입력해주세요', () {
                                Navigator.pop(context);
                              });
                            } else {
                              await userGet(_teacherIdController.text,
                                  _teacherPwController.text);
                              if (us.userList[0].userType == '선생님') {
                                if(GetPlatform.isWeb){
                                  print('web in------');
                                  Get.toNamed(MainScreen.id);
                                }else{
                                  await storage.write(
                                      key: "isLogged",
                                      value: _studentIdController.text);
                                  await storage.write(
                                      key: "pw",
                                      value: _studentPwController.text);
                                  Get.toNamed(BottomNavigator.id);
                                }
                              } else {
                                showOnlyConfirmDialog(context, "아이디 또는 비밀번호가 올바르지 않습니다");
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
        bottomNavigationBar: GetPlatform.isWeb
            ? Padding(
                padding: const EdgeInsets.only(bottom: 26),
                child: Row(
                  children: [],
                ),
              )
            : Padding(
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
                                top: BorderSide(
                                    width: 2, color: Color(0xffDADADA)))),
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
                        Get.to(() => FindPassword());
                      },
                      child: Container(
                        height: 69,
                        width: MediaQuery.of(context).size.width * 0.5,
                        decoration: BoxDecoration(
                            border: Border(
                                top: BorderSide(
                                    width: 2, color: Color(0xffDADADA)))),
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

class _BottomNavigatorState extends State<BottomNavigator>
    with TickerProviderStateMixin {
  List<Widget> _widgetOptions = [];
  late TabController _bottomTabController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _widgetOptions = [MainScreen(), CommunityMainScreen(), MyPageScreen()];
    _bottomTabController = TabController(length: 3, vsync: this);
    // _bottomTabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final us = Get.put(UserState());

    return Scaffold(
      // appBar: AppBar(),
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
                      width: Get.width * 0.3,
                      height: Get.height * 0.05,
                    )
                  : SvgPicture.asset(
                      'assets/bottom/home_not_click.svg',
                      width: Get.width * 0.3,
                      height: Get.height * 0.05,
                    ),
              // text: '홈',
            ),
            Tab(
              icon: _currentIndex == 1
                  ? SvgPicture.asset(
                      'assets/bottom/community_click.svg',
                      width: Get.width * 0.3,
                      height: Get.height * 0.05,
                    )
                  : SvgPicture.asset(
                      'assets/bottom/community_not_click.svg',
                      width: Get.width * 0.3,
                      height: Get.height * 0.05,
                    ),
              // text: '커뮤니티',
            ),
            Tab(
              icon: _currentIndex == 2
                  ? SvgPicture.asset(
                      'assets/bottom/my_profile_click.svg',
                      width: Get.width * 0.3,
                      height: Get.height * 0.05,
                    )
                  : SvgPicture.asset(
                      'assets/bottom/my_profile_not_click.svg',
                      width: Get.width * 0.3,
                      height: Get.height * 0.05,
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
