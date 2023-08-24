import 'package:academy/components/tile/textform_field.dart';
import 'package:academy/screen/community/job/job_hunting_screen.dart';
import 'package:academy/screen/login/findPassword.dart';
import 'package:academy/screen/main/main_screen_main.dart';
import 'package:academy/util/refresh_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../firebase/firebase_log.dart';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import '../../util/font/font.dart';
import '../../util/loading.dart';
import '../community/story/story_main_screen_web.dart';
import '../leadingPage.dart';
import '../main/main_sat_screen_main.dart';
import '../main/main_screen.dart';
import '../main/student/video/student_video_main.dart';
import '../main/teacher/video/video_screen_main.dart';
import '../mypage/mypage/mypage_screen.dart';
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

  bool _isLoading = false;
  bool _obscureText = false;
  bool _obscureText2 = false;
  bool _idSave = false;
  String? _saveIdStr = '';
  String? _saveIdT = '';
  String userInfo = "";
  String userpw = '';
  String usertype = '';
  bool _imageLoading = false;
  // final userData = GetStorage('user');
  final _storage = const FlutterSecureStorage();
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  List _userList = [];
  int? type;

  void initialization() async {
    await Future.delayed(Duration(seconds: 3));
    FlutterNativeSplash.remove();
  }

  @override
  void initState() {
    _nestedTabController =
        TabController(length: 2, vsync: this, initialIndex: 0);
    initialization();
    LocalNotifyCation().initializeNotification();
    _requestPermissions();
    // print('init 에 몇 번 들어오니????');

    ///Fcm
    FCM().setNotifications();
    if (GetPlatform.isMobile) {
      _asyncMethod();
    }

    type = 0;

    Future.delayed(Duration.zero, () async {
      final prefsR = await SharedPreferences.getInstance();
      final us = Get.put(UserState());
      _saveIdStr = prefsR.getString('idS');
      _saveIdT = prefsR.getString('idT');

      if (_saveIdStr != null) {
        _studentIdController.text = _saveIdStr!;
        _idSave = true;
        type = 0;
        _nestedTabController.index = 0;
        _nestedTabController.animateTo(0);
        // us.userList[0].userType ='학생'; //아이디 패스워드 없어
      } else if (_saveIdT != null) {

        _teacherIdController.text = _saveIdT!;
        _idSave = true;
        type = 1;
        _nestedTabController.index = 1;
        _nestedTabController.animateTo(1);
        // us.userList[0].userType ='선생님'; //아이디 패스워드 없어
      }

      setState(() {
        // _isLoading = false;
      });
    });
    super.initState();
  }

  _asyncMethod() async {
    final us = Get.put(UserState());
    userInfo = (await _storage.read(key: "isLogged"))!;
    userpw = (await _storage.read(key: "pw"))!;

    if (userInfo != null) {
      // 로그인
      await userGet(userInfo, userpw);
      loginLogCheck('${us.userList[0].id}', '${us.userList[0].nickName}');
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
          automaticallyImplyLeading: false,
          title: Padding(
            padding: Get.width < 1024
                ? const EdgeInsets.only(left: 100)
                : const EdgeInsets.only(left: 370),
            child: Row(
              children: [
                GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: SvgPicture.asset('assets/logo.svg')),
              ],
            ),
          ),
          backgroundColor: GetPlatform.isWeb ? nowColor : primaryColor,
        ),
        body: SingleChildScrollView(
          child: Center(
            child: Column(
              children: [
                Container(
                  width: Get.width * 0.4,
                  child: Padding(
                      padding: const EdgeInsets.fromLTRB(30, 36, 30, 0),
                      child: _isLoading
                          ? Container() //LoadingBodyScreen()
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 159,
                                  height: 59,
                                  child: TabBar(
                                    controller: _nestedTabController,
                                    unselectedLabelColor: nowColor,
                                    unselectedLabelStyle:
                                        TextStyle(fontWeight: FontWeight.w400),
                                    indicatorColor: Colors.transparent,
                                    indicator: UnderlineTabIndicator(
                                        borderSide: BorderSide(
                                            color: nowColor, width: 5),
                                        insets: GetPlatform.isWeb
                                            ? EdgeInsets.zero
                                            : EdgeInsets.symmetric(
                                                horizontal: 60)),
                                    labelColor: Colors.black,
                                    onTap: (int) {
                                      setState(() {
                                        type = _nestedTabController.index;
                                      });
                                    },
                                    tabs: <Widget>[
                                      Tab(
                                        child: Text('학생',
                                            textAlign: TextAlign.center,
                                            style: f18w700),
                                      ),
                                      Tab(
                                        child: Text('선생님', style: f18w700),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 41,
                                ),
                                Text(
                                  type == 0
                                      ? '학생으로 아카데미를\n로그인하시겠습니까?'
                                      : '선생님으로 아카데미를\n로그인하시겠습니까?',
                                  style: f28w500,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                type == 0
                                    ? Text('학생 로그인', style: f16w400grey8)
                                    : Text('선생님 로그인', style: f16w400grey8),
                                SizedBox(
                                  height: 19,
                                ),
                                TextFormFields(
                                    controller: type == 0
                                        ? _studentIdController
                                        : _teacherIdController,
                                    obscureText: true,
                                    onFieldSubmitted: (v)async {
                                      ///WEb
                                      switch (_nestedTabController.index) {
                                        case 0: if (_studentIdController.text == '' || _studentPwController.text == '') {
                                          showOnlyConfirmDialog(context, '아이디 또는 비밀번호를 입력해주세요');
                                        }
                                        else {
                                          setState(() {
                                            _imageLoading = true;
                                          });
                                          _imageLoading == true
                                              ? showDialog(
                                            barrierDismissible: false,
                                            builder: (ctx) {
                                              return Center(
                                                  child:
                                                  LoadingBodyScreen());
                                            },
                                            context: context,
                                          )
                                              : Container();
                                          await userGet(_studentIdController.text, _studentPwController.text);
                                          if (us.userList.isEmpty) {
                                            showConfirmTapDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다',(){
                                              setState(() {
                                                _imageLoading = false;
                                                Navigator.pop(context);
                                                Get.back();
                                              });
                                            });
                                          }
                                          else if(us.userList[0].userType=='선생님'){
                                            showConfirmTapDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다',(){
                                              setState(() {
                                                _imageLoading = false;
                                                Navigator.pop(context);
                                                Get.back();
                                              });
                                            });
                                          }
                                          else if (us.userList[0].userType == '학생') {
                                            await RefreshManager.addToCookie('id', _studentIdController.text);
                                            await RefreshManager.addToCookie('pw', _studentPwController.text);
                                            await RefreshManager.addToCookie('type', '학생');
                                            if (_idSave) {
                                              final prefs = await SharedPreferences.getInstance();
                                              await prefs.setString('idS', _studentIdController.text);
                                              await prefs.remove('idT');
                                            } else if (!_idSave) {
                                              final prefs = await SharedPreferences.getInstance();
                                              await prefs.remove('idS');
                                            }
                                            us.isLogin.value = '학생';
                                            await loginLogCheck('${us.userList[0].id}', '${us.userList[0].nickName}').then((value) {
                                              setState(() {
                                                _imageLoading = false;
                                                Navigator.pop(context);
                                              });
                                              Get.toNamed(BottomNavigator.id);
                                            });
                                          }
                                        }
                                        break;
                                        case 1:
                                          if (_teacherIdController.text == '' ||
                                              _teacherPwController.text == '') {
                                            showOnlyConfirmDialog(context,
                                                '아이디 또는 비밀번호가 올바르지 않습니다');
                                          } else {
                                            setState(() {
                                              _imageLoading = true;
                                            });
                                            _imageLoading == true
                                                ? showDialog(
                                              barrierDismissible: false,
                                              builder: (ctx) {
                                                return Center(
                                                    child:
                                                    LoadingBodyScreen());
                                              },
                                              context: context,
                                            )
                                                : Container();
                                            await userGet(
                                                _teacherIdController.text,
                                                _teacherPwController.text);
                                            if (us.userList.isEmpty) {
                                              showConfirmTapDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다',(){
                                                setState(() {
                                                  _imageLoading = false;
                                                  Navigator.pop(context);
                                                  Get.back();
                                                });
                                              });
                                            }
                                            else if(us.userList[0].userType=='학생'){
                                              showConfirmTapDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다',(){
                                                setState(() {
                                                  _imageLoading = false;
                                                  Navigator.pop(context);
                                                  Get.back();
                                                });
                                              });
                                            }
                                            else if (us.userList[0].userType == '선생님') {
                                              await RefreshManager.addToCookie(
                                                  'id',
                                                  _teacherIdController.text);
                                              await RefreshManager.addToCookie(
                                                  'pw',
                                                  _teacherPwController.text);
                                              await RefreshManager.addToCookie(
                                                  'type', '선생님');
                                              if (_idSave) {
                                                final prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                                await prefs.setString('idT',
                                                    _teacherIdController.text);
                                                await prefs.remove('idS');
                                              } else if (!_idSave) {
                                                final prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                                await prefs.remove('idT');
                                              }
                                              us.isLogin.value = '선생님';
                                              await loginLogCheck(
                                                  '${us.userList[0].id}',
                                                  '${us.userList[0].nickName}')
                                                  .then((value) {
                                                setState(() {
                                                  _imageLoading = false;
                                                  Navigator.pop(context);
                                                });
                                                Get.toNamed(BottomNavigator.id);
                                              });
                                            }
                                          }
                                          break;
                                      }
                                    },
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
                                    onFieldSubmitted: (v)async {
                                      ///WEb
                                      switch (_nestedTabController.index) {
                                        case 0: if (_studentIdController.text == '' || _studentPwController.text == '') {
                                          showOnlyConfirmDialog(context, '아이디 또는 비밀번호를 입력해주세요');
                                        }
                                        else {
                                          setState(() {
                                            _imageLoading = true;
                                          });
                                          _imageLoading == true
                                              ? showDialog(
                                            barrierDismissible: false,
                                            builder: (ctx) {
                                              return Center(
                                                  child:
                                                  LoadingBodyScreen());
                                            },
                                            context: context,
                                          )
                                              : Container();
                                          await userGet(_studentIdController.text, _studentPwController.text);
                                          if (us.userList.isEmpty) {
                                            showConfirmTapDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다',(){
                                              setState(() {
                                                _imageLoading = false;
                                                Navigator.pop(context);
                                                Get.back();
                                              });
                                            });
                                          }
                                          else if(us.userList[0].userType=='선생님'){
                                            showConfirmTapDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다',(){
                                              setState(() {
                                                _imageLoading = false;
                                                Navigator.pop(context);
                                                Get.back();
                                              });
                                            });
                                          }
                                          else if (us.userList[0].userType == '학생') {
                                            await RefreshManager.addToCookie('id', _studentIdController.text);
                                            await RefreshManager.addToCookie('pw', _studentPwController.text);
                                            await RefreshManager.addToCookie('type', '학생');
                                            if (_idSave) {
                                              final prefs = await SharedPreferences.getInstance();
                                              await prefs.setString('idS', _studentIdController.text);
                                              await prefs.remove('idT');
                                            } else if (!_idSave) {
                                              final prefs = await SharedPreferences.getInstance();
                                              await prefs.remove('idS');
                                            }
                                            us.isLogin.value = '학생';
                                            await loginLogCheck('${us.userList[0].id}', '${us.userList[0].nickName}').then((value) {
                                              setState(() {
                                                _imageLoading = false;
                                                Navigator.pop(context);
                                              });
                                              Get.toNamed(BottomNavigator.id);
                                            });
                                          }
                                        }
                                        break;
                                        case 1:
                                          if (_teacherIdController.text == '' ||
                                              _teacherPwController.text == '') {
                                            showOnlyConfirmDialog(context,
                                                '아이디 또는 비밀번호가 올바르지 않습니다');
                                          } else {
                                            setState(() {
                                              _imageLoading = true;
                                            });
                                            _imageLoading == true
                                                ? showDialog(
                                              barrierDismissible: false,
                                              builder: (ctx) {
                                                return Center(
                                                    child:
                                                    LoadingBodyScreen());
                                              },
                                              context: context,
                                            )
                                                : Container();
                                            await userGet(
                                                _teacherIdController.text,
                                                _teacherPwController.text);
                                            if (us.userList.isEmpty) {
                                              showConfirmTapDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다',(){
                                                setState(() {
                                                  _imageLoading = false;
                                                  Navigator.pop(context);
                                                  Get.back();
                                                });
                                              });
                                            }
                                            else if(us.userList[0].userType=='학생'){
                                              showConfirmTapDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다',(){
                                                setState(() {
                                                  _imageLoading = false;
                                                  Navigator.pop(context);
                                                  Get.back();
                                                });
                                              });
                                            }
                                            else if (us.userList[0].userType == '선생님') {
                                              await RefreshManager.addToCookie(
                                                  'id',
                                                  _teacherIdController.text);
                                              await RefreshManager.addToCookie(
                                                  'pw',
                                                  _teacherPwController.text);
                                              await RefreshManager.addToCookie(
                                                  'type', '선생님');
                                              if (_idSave) {
                                                final prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                                await prefs.setString('idT',
                                                    _teacherIdController.text);
                                                await prefs.remove('idS');
                                              } else if (!_idSave) {
                                                final prefs =
                                                await SharedPreferences
                                                    .getInstance();
                                                await prefs.remove('idT');
                                              }
                                              us.isLogin.value = '선생님';
                                              await loginLogCheck(
                                                  '${us.userList[0].id}',
                                                  '${us.userList[0].nickName}')
                                                  .then((value) {
                                                setState(() {
                                                  _imageLoading = false;
                                                  Navigator.pop(context);
                                                });
                                                Get.toNamed(BottomNavigator.id);
                                              });
                                            }
                                          }
                                          break;
                                      }
                                    },
                                    surffixIcon: "1",
                                    onTap: () {
                                      setState(() {
                                        _obscureText = !_obscureText;
                                      });
                                    }),
                                const SizedBox(
                                  height: 19,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    _idSave = !_idSave;
                                    setState(() {});
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        behavior: HitTestBehavior.opaque,
                                        onTap: () {
                                          _idSave = !_idSave;
                                          setState(() {});
                                        },
                                        child: _idSave
                                            ? SvgPicture.asset(
                                                'assets/checkBox.svg')
                                            : SvgPicture.asset(
                                                'assets/notcheckBox.svg'),
                                      ),
                                      SizedBox(
                                        width: 8,
                                      ),
                                      Text(
                                        '아이디 저장하기',
                                        style: f16w400,
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 29,
                                ),
                                MainButton(
                                  onPressed: () async {
                                    ///WEb
                                    switch (_nestedTabController.index) {
                                      case 0: if (_studentIdController.text == '' || _studentPwController.text == '') {
                                          showOnlyConfirmDialog(context, '아이디 또는 비밀번호를 입력해주세요');
                                        }
                                        else {
                                          setState(() {
                                            _imageLoading = true;
                                          });
                                          _imageLoading == true
                                              ? showDialog(
                                                  barrierDismissible: false,
                                                  builder: (ctx) {
                                                    return Center(
                                                        child:
                                                            LoadingBodyScreen());
                                                  },
                                                  context: context,
                                                )
                                              : Container();
                                          await userGet(_studentIdController.text, _studentPwController.text);
                                          if (us.userList.isEmpty) {
                                            showConfirmTapDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다',(){
                                              setState(() {
                                                _imageLoading = false;
                                                Navigator.pop(context);
                                                Get.back();
                                              });
                                            });
                                          }
                                          else if(us.userList[0].userType=='선생님'){
                                            showConfirmTapDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다',(){
                                              setState(() {
                                                _imageLoading = false;
                                                Navigator.pop(context);
                                                Get.back();
                                              });
                                            });
                                          }
                                          else if (us.userList[0].userType == '학생') {
                                            await RefreshManager.addToCookie('id', _studentIdController.text);
                                            await RefreshManager.addToCookie('pw', _studentPwController.text);
                                            await RefreshManager.addToCookie('type', '학생');
                                            if (_idSave) {
                                              final prefs = await SharedPreferences.getInstance();
                                              await prefs.setString('idS', _studentIdController.text);
                                              await prefs.remove('idT');
                                            } else if (!_idSave) {
                                              final prefs = await SharedPreferences.getInstance();
                                              await prefs.remove('idS');
                                            }
                                            us.isLogin.value = '학생';
                                            await loginLogCheck('${us.userList[0].id}', '${us.userList[0].nickName}').then((value) {
                                              setState(() {
                                                _imageLoading = false;
                                                Navigator.pop(context);
                                              });
                                              Get.toNamed(BottomNavigator.id);
                                            });
                                          }
                                        }
                                        break;
                                      case 1:
                                        if (_teacherIdController.text == '' ||
                                            _teacherPwController.text == '') {
                                          showOnlyConfirmDialog(context,
                                              '아이디 또는 비밀번호가 올바르지 않습니다');
                                        } else {
                                          setState(() {
                                            _imageLoading = true;
                                          });
                                          _imageLoading == true
                                              ? showDialog(
                                                  barrierDismissible: false,
                                                  builder: (ctx) {
                                                    return Center(
                                                        child:
                                                            LoadingBodyScreen());
                                                  },
                                                  context: context,
                                                )
                                              : Container();
                                          await userGet(
                                              _teacherIdController.text,
                                              _teacherPwController.text);
                                          if (us.userList.isEmpty) {
                                            showConfirmTapDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다',(){
                                              setState(() {
                                                _imageLoading = false;
                                                Navigator.pop(context);
                                                Get.back();
                                              });
                                            });
                                          }
                                          else if(us.userList[0].userType=='학생'){
                                            showConfirmTapDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다',(){
                                              setState(() {
                                                _imageLoading = false;
                                                Navigator.pop(context);
                                                Get.back();
                                              });
                                            });
                                          }
                                          else if (us.userList[0].userType == '선생님') {
                                            await RefreshManager.addToCookie(
                                                'id',
                                                _teacherIdController.text);
                                            await RefreshManager.addToCookie(
                                                'pw',
                                                _teacherPwController.text);
                                            await RefreshManager.addToCookie(
                                                'type', '선생님');
                                            if (_idSave) {
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              await prefs.setString('idT',
                                                  _teacherIdController.text);
                                              await prefs.remove('idS');
                                            } else if (!_idSave) {
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              await prefs.remove('idT');
                                            }
                                            us.isLogin.value = '선생님';
                                            await loginLogCheck(
                                                    '${us.userList[0].id}',
                                                    '${us.userList[0].nickName}')
                                                .then((value) {
                                              setState(() {
                                                _imageLoading = false;
                                                Navigator.pop(context);
                                              });
                                              Get.toNamed(BottomNavigator.id);
                                            });
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    GestureDetector(
                                        onTap: () {
                                          Get.toNamed(RegisterMainScreen.id);
                                        },
                                        child: Text(
                                          '회원가입',
                                          style: f16w700greyA,
                                        )),
                                    Spacer(),
                                    GestureDetector(
                                        onTap: () async {
                                          Get.toNamed(FindPassword.id);
                                        },
                                        child: Text(
                                          '비밀번호 찾기',
                                          style: f16w700greyA,
                                        )),
                                  ],
                                ),
                                SizedBox(
                                  height: 100,
                                ),
                              ],
                            )),
                ),
                Footer(),
              ],
            ),
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
  List<Widget> _widgetOptions2 = [];
  late TabController _bottomTabController;
  late TabController _bottomTabController2;
  int _currentIndex = 0;

  @override
  void initState() {
    final us = Get.put(UserState());
    // print('유저타입은? ${us.userList[0].userType}');

    super.initState();
    _widgetOptions = [
      MainScreenMain(),
      MainSatScreenMain(),
      StudentVideoMain(),
      StoryMainScreenWeb()
    ];
    _widgetOptions2 = [
      MainScreenMain(),
      MainSatScreenMain(),
      VideoMainScreen(),
      StoryMainScreenWeb(),
      JobHuntingScreen()
    ];
    _bottomTabController = TabController(
        length: 4,
        vsync: this,
        initialIndex: us.bottomidx.value > 1 ? 1 : us.bottomidx.value);
    _bottomTabController2 =
        TabController(length: 5, vsync: this, initialIndex: us.bottomidx.value);

    Future.delayed(Duration.zero, () async {
      await userGet(
          RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
      us.isLogin.value = RefreshManager.getCookie('type');
      setState(() {

      });
    });
    // _bottomTabController.animateTo(0);
  }

  @override
  Widget build(BuildContext context) {
    final us = Get.put(UserState());
    return us.userList.length == 0  ? Scaffold() : WillPopScope(
      onWillPop: () {
        return Future(() => false);
      },
      child: Scaffold(
        appBar: AppBar(
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
                    width: Get.width * 0.38,
                    height: 55,
                    child: TabBar(
                      controller: us.userList[0].userType == '학생'
                          ? _bottomTabController
                          : _bottomTabController2,
                      unselectedLabelColor: nowColor,
                      unselectedLabelStyle:
                          TextStyle(fontWeight: FontWeight.w400),
                      indicatorColor: Colors.transparent,
                      indicator: UnderlineTabIndicator(
                          borderSide: BorderSide(color: Colors.white, width: 2),
                          insets: EdgeInsets.zero),
                      labelColor: Colors.black,
                      onTap: (index) {
                        setState(() {
                          _currentIndex = index;
                        });
                      },
                      tabs: us.userList[0].userType == '학생'
                          ? <Widget>[
                              Tab(
                                child: Text('시험보기', style: f14Whitew700),
                              ),
                              Tab(
                                child: Text('SAT 보기', style: f14Whitew700),
                              ),
                              Tab(
                                child: Text('강의보기', style: f14Whitew700),
                              ),
                              Tab(
                                child: Text('이야기', style: f14Whitew700),
                              ),
                            ]
                          : <Widget>[
                              Tab(
                                child: Text('시험등록', style: f14Whitew700),
                              ),
                              Tab(
                                child: Text('SAT 등록', style: f14Whitew700),
                              ),
                              Tab(
                                child: Text('강의등록', style: f14Whitew700),
                              ),
                              Tab(
                                child: Text('이야기', style: f14Whitew700),
                              ),
                              Tab(
                                child: Text('구인구직', style: f14Whitew700),
                              ),
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
                  child: Center(
                      child: Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Image.asset(
                      'assets/icon/user.png',
                      color: Colors.white,
                      width: 24,
                      height: 24,
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
                      width: 24,
                      height: 24,
                    ),
                  )),
                ),
              ],
            ),
          ),
          centerTitle: true,
          // leadingWidth: 100,
          elevation: 0,
          backgroundColor: nowColor,
        ),
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: us.userList[0].userType == '학생'
              ? _widgetOptions
              : _widgetOptions2,
          controller: us.userList[0].userType == '학생'
              ? _bottomTabController
              : _bottomTabController2,
        ),
      ),
    );
  }
}
