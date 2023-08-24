// import 'dart:math';

// import 'package:academy/util/loading.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';
// import 'package:qr_flutter/qr_flutter.dart';

// import '../../../../components/dialog/showAlertDialog.dart';
// import '../../../../components/footer/footer.dart';
// import '../../../../firebase/firebase_check.dart';
// import '../../../../provider/check_state.dart';
// import '../../../../provider/user_state.dart';
// import '../../../../util/colors.dart';
// import '../../../../util/font/font.dart';
// import '../../../../util/refresh_manager.dart';
// import '../../../login/login_main_screen.dart';

// class TeacherQrCreateScreen extends StatefulWidget {
//   static final String id = '/t_qr_create';

//   final String? edit;

//   const TeacherQrCreateScreen({Key? key, this.edit}) : super(key: key);

//   @override
//   State<TeacherQrCreateScreen> createState() => _TeacherQrCreateScreenState();
// }

// class _TeacherQrCreateScreenState extends State<TeacherQrCreateScreen> {
//   var random = new Random();
//   int randomCode = 0;
//   bool _nothing = false;
//   bool _isLoading = true;

//   @override
//   void initState() {
//     randomCode = random.nextInt(900000) + 100000;
//     Future.delayed(Duration.zero, () async {
//       _nothing = await checkRandomCode(randomCode);
//       while (_nothing == true) {
//         randomCode = random.nextInt(900000) + 100000;
//         _nothing = await checkRandomCode(randomCode);
//         if (_nothing == false) {
//           setState(() {
//             _isLoading = false;
//           });
//           break;
//         }
//       }
//       setState(() {
//         _isLoading = false;
//       });
//     });

//     super.initState();
//   }


//   @override
//   Widget build(BuildContext context) {
//     final args =
//         ModalRoute.of(context)!.settings.arguments as TeacherQrCreateScreen;
//     final us = Get.put(UserState());
//     final cs = Get.put(CheckState());
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: nowColor,
//         elevation: 0,
//         automaticallyImplyLeading: false,
//         centerTitle: false,
//         actions: [
//           GestureDetector(
//             onTap: () {
//               showComponentDialog(context, '로그아웃을 하시겠습니까?', () {
//                 Get.offAllNamed(LoginMainScreen.id);
//                 RefreshManager.addToCookie('id', '');
//                 RefreshManager.addToCookie('pw', '');
//                 us.isLogin.value = '';
//               });
//             },
//             child: Center(
//                 child: Padding(
//               padding: const EdgeInsets.only(right: 8.0),
//               child: Image.asset(
//                 'assets/icon/logout.png',
//                 color: Colors.white,
//                 width: GetPlatform.isWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
//                 height: GetPlatform.isWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
//               ),
//             )),
//           ),
//         ],
//         title: Row(
//           children: [
//             SvgPicture.asset(
//               'assets/logo.svg',
//               width: (GetPlatform.isWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
//               height: (GetPlatform.isWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
//             ),
//             SizedBox(
//               width: 8,
//             ),
//             GetPlatform.isWeb && (Get.width * 0.2 <= 171)
//                 ? Container()
//                 : Text('출석관리')
//           ],
//         ),
//       ),
//       backgroundColor: Colors.white,
//       body: _isLoading
//           ? LoadingBodyScreen()
//           : Column(
//               children: [
//                 Expanded(
//                   child: Padding(
//                     padding: const EdgeInsets.all(8.0),
//                     child: SingleChildScrollView(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             children: [
//                               Text(
//                                 '출석 번호 : ',
//                                 style: f20w500,
//                               ),
//                               const SizedBox(
//                                 width: 8,
//                               ),
//                               Text(
//                                 args.edit == 'true' ? '123456' : '$randomCode',
//                                 style: f20w700primary,
//                               )
//                             ],
//                           ),
//                           const SizedBox(
//                             height: 12,
//                           ),
//                           Text(
//                             args.edit == 'true'
//                                 ? '2022년'
//                                 : '날짜 : ${DateFormat("yyyy년 MM월 dd일 HH시 mm분").format(DateTime.now())}',
//                             style: f20w500,
//                           ),
//                           const SizedBox(
//                             height: 12,
//                           ),
//                           Text(
//                            'QR 코드',
//                             style: f20w500,
//                           ),
//                           QrImage(
//                             data: '$randomCode',
//                             version: 3,
//                             size: 200,
//                           ),
//                           const SizedBox(
//                             height: 12,
//                           ),
//                           args.edit == 'true'
//                               ? Text(
//                                   '출석 인원 (20명)',
//                                   style: f20w500,
//                                 )
//                               : Container(),
//                           args.edit == 'true'
//                               ? ListView.builder(
//                                   physics: const ClampingScrollPhysics(),
//                                   shrinkWrap: true,
//                                   itemCount: 20,
//                                   itemBuilder: (_, idx) {
//                                     return Padding(
//                                       padding: const EdgeInsets.all(5.0),
//                                       child: Text(
//                                         '- 김아무개',
//                                         style: f18w500,
//                                       ),
//                                     );
//                                   })
//                               : Container(),
//                         ],
//                       ),
//                     ),
//                   ),
//                 ),
//                 Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 12),
//                     child: Footer())
//               ],
//             ),
//     );
//   }
// }
