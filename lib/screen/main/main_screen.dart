import 'package:academy/screen/login/login_main_screen.dart';
import 'package:academy/util/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../firebase/firebase_log.dart';
import '../../../provider/user_state.dart';
import '../../components/dialog/showAlertDialog.dart';
import '../../firebase/firebase_user.dart';
import '../../util/font/font.dart';
import '../../util/refresh_manager.dart';
import 'student/student_screen.dart';
import 'teacher/individual/pdf_individual_main_screen.dart';
import 'teacher/all/pdf_upload_screen.dart';
import 'teacher/teacher_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:html' as html;

class MainScreen extends StatefulWidget {
  static final String id = '/main_screen';

  const MainScreen({Key? key}) : super(key: key);

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool _isLoading = true;

  @override
  void initState() {
    final us = Get.put(UserState());

    // html.window.onUnload.listen((event) async {
    // });
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
                            ? StudentScreen()
                            : TeacherScreen()),
                    // us.userList[0].userType == '선생님'
                    //     ? kIsWeb && (Get.width * 0.2 <= 171)
                    //         ? Container()
                    //         : Positioned(
                    //             top: 60,
                    //             right: 28,
                    //             child: GestureDetector(
                    //                 behavior: HitTestBehavior.opaque,
                    //                 onTap: () {
                    //                   showComponentUploadDialog(
                    //                       context, '문제를 추가하시겠습니까?', () {
                    //                     Get.back();
                    //                     Get.toNamed(PdfUploadScreen.id);
                    //                     // Get.to(() => PdfUploadScreen());
                    //                   }, () {
                    //                     Get.back();
                    //                     Get.toNamed(PdfIndMainScreen.id);
                    //
                    //                     // Get.to(() => PdfIndMainScreen());
                    //                   });
                    //
                    //                   // showDialog(
                    //                   //     context: context,
                    //                   //     builder:(BuildContext context)=>AlertDialog(
                    //                   //       content: Text('등록 방식을 선택해주세요'),
                    //                   //       actions: [
                    //                   //         ElevatedButton(
                    //                   //             onPressed:(){
                    //                   //               Get.to(() => PdfUploadScreen());
                    //                   //             } , child: Text('한번에 등록')),
                    //                   //         ElevatedButton(
                    //                   //             onPressed:(){
                    //                   //               Get.to(() => PdfUploadScreen());
                    //                   //             } , child: Text('한개씩 등록'))
                    //                   //       ],
                    //                   //     ));
                    //                 },
                    //                 child: Container(
                    //                   child: const Center(
                    //                       child: Text(
                    //                     '문제추가',
                    //                     style: f16w700primary,
                    //                   )),
                    //                 )))
                    //     : Container()
                  ])
        // Container( width: Get.width,
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.center,
        //     crossAxisAlignment: CrossAxisAlignment.center,
        //     children: [
        //       //선생님인지 학생인지 호출
        //       Obx(() => Text(
        //         '${us.userList[0].userType}',
        //         style: TextStyle(color: Colors.black),
        //       )),
        //       SizedBox(height: 12,),
        //
        //       // Obx(() => Text(
        //       //       '${us.count}',
        //       //       style: TextStyle(color: Colors.black),
        //       //     )),
        //       // Obx(() => Text(
        //       //       '${us.name}',
        //       //       style: TextStyle(color: Colors.black),
        //       //     )),
        //       // TextButton(
        //       //   onPressed: () {
        //       //     us.decrease();
        //       //     print('123123123: ${us.userList[0].id}');
        //       //     setState(() {});
        //       //   },
        //       //   child: Text(
        //       //     'hello',
        //       //     style: TextStyle(color: Colors.black, fontSize: 24),
        //       //   ),
        //       // ),
        //     ],
        //   ),
        // ),
        // , floatingActionButton: us.userList[0].userType == '선생님'
        //     ? FloatingActionButton(
        //         onPressed: () {
        //           Get.to(() => PdfUploadScreen());
        //         },
        //         tooltip: '시험 등록',
        //         backgroundColor: Colors.lightGreen,
        //         child: const Icon(Icons.add, color: Colors.white,),
        //       )
        //     : null);
        );
  }
}
