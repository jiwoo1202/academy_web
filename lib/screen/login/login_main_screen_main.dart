import 'package:academy/components/tile/textform_field.dart';
import 'package:academy/screen/community/job/job_hunting_screen.dart';
import 'package:academy/screen/landing_page_app.dart';
import 'package:academy/screen/login/findPassword.dart';
import 'package:academy/screen/login/login_main_screen_app.dart';
import 'package:academy/util/refresh_manager.dart';
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
import '../community/story/story_main_screen_web.dart';
import '../leadingPage.dart';
import '../main/main_screen.dart';
import '../mypage/mypage/mypage_screen.dart';
import '../register/register_main_screen.dart';
import 'login_main_screen.dart';

class LoginMainScreenMain extends StatefulWidget {
  static final String id = '/login_main_main';

  const LoginMainScreenMain({Key? key}) : super(key: key);

  @override
  State<LoginMainScreenMain> createState() => _LoginMainScreenMainState();
}

class _LoginMainScreenMainState extends State<LoginMainScreenMain> {
 @override
 void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Get.width<850?LoginMainScreenApp():LoginMainScreen();
    // return GestureDetector(
    //   onTap: () {
    //     FocusScope.of(context).requestFocus(new FocusNode());
    //   },
    //   child: Scaffold(
    //     appBar: AppBar(
    //       automaticallyImplyLeading: false,
    //       title: Padding(
    //         padding: Get.width < 1024 ?const EdgeInsets.only(left: 100) :const EdgeInsets.only(left: 370),
    //         child: Row(
    //                 children: [
    //                   GestureDetector(
    //                       onTap: () {
    //                         Get.back();
    //                       },
    //                       child: SvgPicture.asset('assets/logo.svg')),
    //                 ],
    //               ),
    //       ),
    //       backgroundColor: GetPlatform.isWeb ? nowColor : primaryColor,
    //     ),
    //     body: SingleChildScrollView(
    //       child: Center(
    //         child: Column(
    //           children: [
    //             Container(
    //               width: Get.width*0.4,
    //               child: Padding(
    //                   padding: const EdgeInsets.fromLTRB(30, 36, 30, 0),
    //                   child: _isLoading
    //                       ? Container()//LoadingBodyScreen()
    //                       : Column(
    //                         crossAxisAlignment: CrossAxisAlignment.start,
    //                         children: [
    //                           Container(
    //                             width: 159,
    //                             height: 59,
    //                             child: TabBar(
    //                               controller: _nestedTabController,
    //                               unselectedLabelColor: nowColor,
    //                               unselectedLabelStyle:
    //                                   TextStyle(fontWeight: FontWeight.w400),
    //                               indicatorColor: Colors.transparent,
    //                               indicator: UnderlineTabIndicator(
    //                                   borderSide:
    //                                       BorderSide(color: nowColor, width: 5),
    //                                   insets: GetPlatform.isWeb
    //                                       ? EdgeInsets.zero
    //                                       : EdgeInsets.symmetric(horizontal: 60)),
    //                               labelColor: Colors.black,
    //                               onTap: (int) {
    //                                 setState(() {
    //                                   type = _nestedTabController.index;
    //                                 });
    //                               },
    //                               tabs: <Widget>[
    //                                 Tab(
    //                                   child: Text('학생',
    //                                       textAlign: TextAlign.center,
    //                                       style: f18w700),
    //                                 ),
    //                                 Tab(
    //                                   child: Text('선생님', style: f18w700),
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                           SizedBox(
    //                             height: 41,
    //                           ),
    //                           Text(
    //                             type == 0
    //                                 ? '학생으로 아카데미를\n로그인하시겠습니까?'
    //                                 : '선생님으로 아카데미를\n로그인하시겠습니까?',
    //                             style: f28w500,
    //                           ),
    //                           const SizedBox(
    //                             height: 10,
    //                           ),
    //                           type == 0
    //                               ? Text('학생 로그인', style: f16w400grey8)
    //                               : Text('선생님 로그인', style: f16w400grey8),
    //                           SizedBox(
    //                             height: 19,
    //                           ),
    //                           TextFormFields(
    //                               controller: type == 0
    //                                   ? _studentIdController
    //                                   : _teacherIdController,
    //                               obscureText: true,
    //                               hintText: '아이디를 입력해주세요',
    //                               surffixIcon: "0"),
    //                           SizedBox(
    //                             height: 16,
    //                           ),
    //                           TextFormFields(
    //                               controller: type == 0
    //                                   ? _studentPwController
    //                                   : _teacherPwController,
    //                               obscureText: _obscureText,
    //                               hintText: '비밀번호를 입력해 주세요',
    //                               surffixIcon: "1",
    //                               onTap: () {
    //                                 setState(() {
    //                                   _obscureText = !_obscureText;
    //                                 });
    //                               }),
    //                           const SizedBox(
    //                             height: 19,
    //                           ),
    //                           GestureDetector(
    //                             onTap: () {
    //                               _idSave = !_idSave;
    //                               setState(() {});
    //                             },
    //                             child: Row(
    //                               mainAxisAlignment: MainAxisAlignment.start,
    //                               children: [
    //                                  GestureDetector(
    //                                         behavior: HitTestBehavior.opaque,
    //                                         onTap: () {
    //                                           _idSave = !_idSave;
    //                                           setState(() {
    //                                           });
    //                                         },
    //                                         child: _idSave?SvgPicture.asset(
    //                                             'assets/checkBox.svg'):SvgPicture.asset(
    //                                             'assets/notcheckBox.svg'),
    //                                       ),
    //                                 SizedBox(
    //                                   width: 8,
    //                                 ),
    //                                 Text(
    //                                   '아이디 저장하기',
    //                                   style: f16w400,
    //                                 ),
    //                                 SizedBox(
    //                                   width: 10,
    //                                 ),
    //                               ],
    //                             ),
    //                           ),
    //                           const SizedBox(
    //                             height: 29,
    //                           ),
    //                           MainButton(
    //                             onPressed: () async {
    //                               ///WEb
    //                               switch (_nestedTabController.index) {
    //                                 case 0:
    //                                   if (_studentIdController.text == '' || _studentPwController.text == '') {
    //                                     showOnlyConfirmDialog(context, '아이디 또는 비밀번호를 입력해주세요');
    //                                   }
    //                                   else {
    //                                     await userGet(_studentIdController.text, _studentPwController.text);
    //
    //                                     if (us.userList.isEmpty) {
    //                                       showOnlyConfirmDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다');
    //                                     }
    //                                     else if (us.userList[0].userType == '학생') {
    //                                       await RefreshManager.addToCookie('id', _studentIdController.text);
    //                                       await RefreshManager.addToCookie('pw', _studentPwController.text);
    //                                       await RefreshManager.addToCookie('type', '학생');
    //
    //                                       if (_idSave) {
    //                                         final prefs = await SharedPreferences.getInstance();
    //                                         await prefs.setString('idS', _studentIdController.text);
    //                                         await prefs.remove('idT');
    //                                       } else if (!_idSave) {
    //                                         final prefs = await SharedPreferences.getInstance();
    //                                         await prefs.remove('idS');
    //                                       }
    //                                       us.isLogin.value = '학생';
    //
    //                                       await loginLogCheck('${us.userList[0].id}', '${us.userList[0].nickName}');
    //                                       Get.toNamed(BottomNavigator.id);
    //                                     } else {
    //                                       showOnlyConfirmDialog(context, "아이디 또는 비밀번호가 올바르지 않습니다");
    //                                     }
    //                                   }
    //                                   break;
    //                                 case 1:
    //                                   if (_teacherIdController.text == '' || _teacherPwController.text == '') {
    //                                     showOnlyConfirmDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다');
    //                                   }
    //                                   else {
    //                                     await userGet(_teacherIdController.text, _teacherPwController.text);
    //
    //                                     if (us.userList.isEmpty) {
    //                                       showOnlyConfirmDialog(context, '아이디 또는 비밀번호가 올바르지 않습니다');
    //                                     }
    //                                     else if (us.userList[0].userType == '선생님') {
    //                                       await RefreshManager.addToCookie('id', _teacherIdController.text);
    //                                       await RefreshManager.addToCookie('pw', _teacherPwController.text);
    //                                       await RefreshManager.addToCookie('type', '선생님');
    //
    //                                       if (_idSave) {
    //                                         final prefs = await SharedPreferences.getInstance();
    //                                         await prefs.setString('idT', _teacherIdController.text);
    //                                         await prefs.remove('idS');
    //                                       } else if (!_idSave) {
    //                                         final prefs = await SharedPreferences.getInstance();
    //                                         await prefs.remove('idT');
    //                                       }
    //                                       us.isLogin.value = '선생님';
    //
    //                                       await loginLogCheck('${us.userList[0].id}', '${us.userList[0].nickName}');
    //                                       Get.toNamed(BottomNavigator.id);
    //                                     } else {
    //                                       showOnlyConfirmDialog(context, "아이디 또는 비밀번호가 올바르지 않습니다");
    //                                     }
    //                                   }
    //                                   break;
    //                               }
    //                             },
    //                             text: '로그인하기',
    //                           ),
    //                           const SizedBox(
    //                             height: 40,
    //                           ),
    //                           Row(
    //                             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
    //                             children: [
    //                               GestureDetector(
    //                                   onTap: () {
    //                                     Get.toNamed(RegisterMainScreen.id);
    //                                   },
    //                                   child: Text(
    //                                     '회원가입',
    //                                     style: f16w700greyA,
    //                                   )),
    //                               Spacer(),
    //                               GestureDetector(
    //                                   onTap: () {
    //                                     Get.toNamed(FindPassword.id);
    //                                   },
    //                                   child: Text(
    //                                     '비밀번호 찾기',
    //                                     style: f16w700greyA,
    //                                   )),
    //                             ],
    //                           ),
    //                           SizedBox(
    //                             height: 100,
    //                           ),
    //                         ],
    //                       )),
    //             ),
    //             Footer(),
    //           ],
    //         ),
    //       ),
    //     ),
    //     bottomNavigationBar: GetPlatform.isWeb
    //         ? Padding(
    //             padding: const EdgeInsets.only(bottom: 26),
    //             child: Row(
    //               children: [],
    //             ),
    //           )
    //         : Padding(
    //             padding: const EdgeInsets.only(bottom: 26),
    //             child: Row(
    //               children: [
    //                 GestureDetector(
    //                   behavior: HitTestBehavior.opaque,
    //                   onTap: () {
    //                     Get.toNamed(RegisterMainScreen.id);
    //                   },
    //                   child: Container(
    //                     height: 69,
    //                     width: MediaQuery.of(context).size.width * 0.5,
    //                     decoration: BoxDecoration(
    //                         border: Border(
    //                             top: BorderSide(
    //                                 width: 2, color: Color(0xffDADADA)))),
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       crossAxisAlignment: CrossAxisAlignment.center,
    //                       children: [
    //                         Text(
    //                           '회원가입',
    //                           style: TextStyle(
    //                               fontFamily: 'Pretendard',
    //                               fontSize: 16,
    //                               color: Color(0xff535353)),
    //                           textAlign: TextAlign.center,
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 ),
    //                 GestureDetector(
    //                   behavior: HitTestBehavior.opaque,
    //                   onTap: () {
    //                     print('비밀번호 찾기');
    //                     Get.to(() => FindPassword());
    //                   },
    //                   child: Container(
    //                     height: 69,
    //                     width: MediaQuery.of(context).size.width * 0.5,
    //                     decoration: BoxDecoration(
    //                         border: Border(
    //                             top: BorderSide(
    //                                 width: 2, color: Color(0xffDADADA)))),
    //                     child: Row(
    //                       mainAxisAlignment: MainAxisAlignment.center,
    //                       crossAxisAlignment: CrossAxisAlignment.center,
    //                       children: [
    //                         Text(
    //                           '비밀번호 찾기',
    //                           style: TextStyle(
    //                               fontFamily: 'Pretendard',
    //                               fontSize: 16,
    //                               color: Color(0xff535353)),
    //                           textAlign: TextAlign.center,
    //                         ),
    //                       ],
    //                     ),
    //                   ),
    //                 )
    //               ],
    //             ),
    //           ),
    //   ),
    // );
  }
}

// class BottomNavigator extends StatefulWidget {
//   static final String id = '/bottom';
//
//   const BottomNavigator({Key? key}) : super(key: key);
//
//   @override
//   State<BottomNavigator> createState() => _BottomNavigatorState();
// }
//
// class _BottomNavigatorState extends State<BottomNavigator>
//     with TickerProviderStateMixin {
//   List<Widget> _widgetOptions = [];
//   List<Widget> _widgetOptions2 = [];
//   late TabController _bottomTabController;
//   late TabController _bottomTabController2;
//   int _currentIndex = 0;
//
//   @override
//   void initState() {
//   final us = Get.put(UserState());
//     // print('유저타입은? ${us.userList[0].userType}');
//     super.initState();
//     _widgetOptions = [MainScreen(), StoryMainScreenWeb()];
//     _widgetOptions2 = [MainScreen(),StoryMainScreenWeb(),JobHuntingScreen()];
//     _bottomTabController = TabController(length: 2, vsync: this,initialIndex: us.bottomidx.value > 1 ? 1 : us.bottomidx.value);
//     _bottomTabController2 = TabController(length: 3, vsync: this,initialIndex: us.bottomidx.value);
//
//     Future.delayed(Duration.zero,()async{
//       await userGet(
//           RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
//       us.isLogin.value = RefreshManager.getCookie('type');
//     });
//     // _bottomTabController.animateTo(0);
//   }
//   @override
//   Widget build(BuildContext context) {
//     final us = Get.put(UserState());
//     return WillPopScope(
//       onWillPop: (){
//         return Future(() => false);
//       },
//       child: Scaffold(
//         appBar: AppBar(
//           // leading: null,
//           automaticallyImplyLeading: false,
//           title: Container(
//             padding: EdgeInsets.symmetric(horizontal: Get.width*0.1),
//             child: Row(
//               children: [
//                 SvgPicture.asset(
//                   'assets/logo.svg',
//                   width: 20,
//                   height: 20,
//                 ),
//                 Spacer(),
//                 Center(
//                   child: Container(
//                     width: Get.width*0.38,
//                     height: 55,
//                     child: TabBar(
//                       controller: us.userList[0].userType=='학생'?_bottomTabController:_bottomTabController2,
//                       unselectedLabelColor: nowColor,
//                       unselectedLabelStyle:
//                       TextStyle(fontWeight: FontWeight.w400),
//                       indicatorColor: Colors.transparent,
//                       indicator: UnderlineTabIndicator(
//                           borderSide:
//                           BorderSide(color: Colors.white, width: 2),
//                           insets:  EdgeInsets.zero
//                               ),
//                       labelColor: Colors.black,
//                       onTap: (index) {
//                         setState(() {
//                           _currentIndex = index;
//                         });
//                       },
//                       tabs: us.userList[0].userType=='학생'?<Widget>[
//                         Tab(
//                           child: Text('시험보기', style: f14Whitew700),
//                         ),
//                         Tab(
//                           child: Text('이야기', style: f14Whitew700),
//                         ),
//
//                       ]:<Widget>[
//                         Tab(
//                           child: Text('시험보기', style: f14Whitew700),
//                         ),
//                         Tab(
//                           child: Text('이야기', style: f14Whitew700),
//                         ),
//                         Tab(
//                           child: Text('구인구직',style: f14Whitew700),
//                         ),
//
//                       ],
//                     ),
//                   ),
//                 ),
//                 Spacer(),
//                 GestureDetector(
//                   onTap: () {
//                     Get.toNamed(MyPageScreen.id,
//                         arguments: MyPageScreen(
//                           whichPage: 'main',
//                         ));
//                     print('22222');
//                   },
//                   child: Center(
//                       child: Padding(
//                         padding: const EdgeInsets.only(right: 8.0),
//                         child: Image.asset(
//                           'assets/icon/user.png',
//                           color: Colors.white,
//                           width: 24,
//                           height:  24,
//                         ),
//                       )),
//                 ),
//                 const SizedBox(
//                   width: 20,
//                 ),
//                 GestureDetector(
//                   onTap: () {
//                     showComponentDialog(context, '로그아웃을 하시겠습니까?', () {
//                       Get.offAllNamed(LoginMainScreenMain.id);
//                       RefreshManager.addToCookie('id', '');
//                       RefreshManager.addToCookie('pw', '');
//                       us.isLogin.value = '';
//                     });
//                   },
//                   child: Center(
//                       child: Padding(
//                         padding: const EdgeInsets.only(right: 8.0),
//                         child: Image.asset(
//                           'assets/icon/logout.png',
//                           color: Colors.white,
//                           width:24,
//                           height: 24,
//                         ),
//                       )),
//                 ),
//               ],
//             ),
//           ),
//           centerTitle: true,
//           // leadingWidth: 100,
//           elevation: 0,
//           backgroundColor: nowColor,
//         ),
//         body: TabBarView(
//           physics: const NeverScrollableScrollPhysics(),
//           children: us.userList[0].userType=='학생'?_widgetOptions:_widgetOptions2,
//           controller: us.userList[0].userType=='학생'?_bottomTabController:_bottomTabController2,
//         ),
//       ),
//     );
//   }
// }
