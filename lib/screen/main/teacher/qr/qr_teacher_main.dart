// import 'package:academy/provider/check_state.dart';
// import 'package:academy/util/loading.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'package:get/get.dart';
// import 'package:intl/intl.dart';

// import '../../../../components/dialog/showAlertDialog.dart';
// import '../../../../components/footer/footer.dart';
// import '../../../../components/switch/switch_button.dart';
// import '../../../../firebase/firebase_check.dart';
// import '../../../../provider/user_state.dart';
// import '../../../../util/colors.dart';
// import '../../../../util/font/font.dart';
// import '../../../../util/refresh_manager.dart';
// import '../../../login/login_main_screen.dart';
// import 'qr_create_screen.dart';

// class QrTeacherMain extends StatefulWidget {
//   static final String id = '/teacher_qr_main';

//   const QrTeacherMain({Key? key}) : super(key: key);

//   @override
//   State<QrTeacherMain> createState() => _QrTeacherMainState();
// }

// class _QrTeacherMainState extends State<QrTeacherMain> {
//   bool _isLoading = false;

//   @override
//   void initState() {
//     // final us = Get.put(UserState());

//     // Future.delayed(Duration.zero, () async {
//     //   setState(() {
//     //     _isLoading = true;
//     //   });
//     //
//     //   await getmyCheckUpload('${us.userList[0].id}');
//     //   setState(() {
//     //     _isLoading = false;
//     //   });
//     // });
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
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
//       body: StreamBuilder<QuerySnapshot>(
//           stream: FirebaseFirestore.instance
//               .collection('check')
//               .where('teacherId', isEqualTo: us.userList[0].id)
//               .orderBy('createDate', descending: true)
//               .snapshots(),
//           builder: (_, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Container(height: Get.height, child: LoadingBodyScreen());
//             }
//             return Column(
//               children: [
//                 Expanded(
//                   child: ListView.builder(
//                       physics: const ClampingScrollPhysics(),
//                       itemCount: snapshot.data!.docs.length,
//                       shrinkWrap: true,
//                       itemBuilder: (_, idx) {
//                         return Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: GestureDetector(
//                             onTap: () {
//                               Get.toNamed(TeacherQrCreateScreen.id,
//                                   arguments: TeacherQrCreateScreen(
//                                     edit: 'true',
//                                   ));
//                             },
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 12),
//                               decoration: BoxDecoration(
//                                 border:
//                                     Border.all(width: 1, color: Colors.grey),
//                                 borderRadius:
//                                     BorderRadius.all(Radius.circular(8.0)),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Row(
//                                     children: [
//                                       Text(
//                                         '출석 번호 : ',
//                                         style: f20w500,
//                                       ),
//                                       const SizedBox(
//                                         width: 8,
//                                       ),
//                                       Text(
//                                         '${snapshot.data!.docs[idx]['qrcode']}',
//                                         style: f20w700primary,
//                                       ),
//                                       Spacer(),
//                                       SwitchButton(
//                                         value: snapshot.data!.docs[idx]
//                                                     ['state'] ==
//                                                 '완료'
//                                             ? true
//                                             : false,
//                                         onTap: () {},
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(
//                                     height: 12,
//                                   ),
//                                   Row(
//                                     children: [
//                                       Text(
//                                         '날짜 : ',
//                                         style: f20w500,
//                                       ),
//                                       const SizedBox(
//                                         width: 8,
//                                       ),
//                                       Text(
//                                         '${snapshot.data!.docs[idx]['date']}',
//                                         style: f18w500,
//                                       )
//                                     ],
//                                   ),
//                                   const SizedBox(
//                                     height: 12,
//                                   ),
//                                   Row(
//                                     children: [
//                                       Text(
//                                         '출석 인원 : ',
//                                         style: f20w500,
//                                       ),
//                                       const SizedBox(
//                                         width: 8,
//                                       ),
//                                       Text(
//                                         '${snapshot.data!.docs[idx]['checkStudent'].length}',
//                                         style: f18w500,
//                                       ),
//                                       Spacer(),
//                                       Text(
//                                         '확인하기',
//                                         style: f18w500,
//                                       ),
//                                       Icon(
//                                         Icons.arrow_forward_ios,
//                                         size: 16,
//                                       )
//                                     ],
//                                   )
//                                 ],
//                               ),
//                             ),
//                           ),
//                         );
//                       }),
//                 ),
//                 Container(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 12, vertical: 12),
//                     child: Footer())
//               ],
//             );
//           }),
//       floatingActionButton: FloatingActionButton.extended(
//         icon: Icon(Icons.qr_code),
//         label: Text(
//           '추가',
//           style: f16Whitew500,
//         ),
//         backgroundColor: nowColor,
//         onPressed: () {
//           Get.toNamed(TeacherQrCreateScreen.id,
//               arguments: TeacherQrCreateScreen(
//                 edit: 'false',
//               ));
//           // showEditDialog(context, '출석 번호를 적어주세요', () {}, _checkCon);
//         },
//       ),
//     );
//   }
// }
