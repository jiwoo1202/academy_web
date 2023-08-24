import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../util/colors.dart';
import '../../util/font/font.dart';

showComponentUploadDialog(BuildContext context, String title,
    VoidCallback confirmTap, VoidCallback confirmTap2) {
  // show the dialog
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          // actionsPadding: const EdgeInsets.symmetric(vertical: 20),
          contentPadding: const EdgeInsets.only(top: 35, bottom: 35),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Text('${title}',
                    textAlign: TextAlign.center,
                    style: (kIsWeb && (Get.width * 0.2 <= 171))
                        ? f12w700
                        : f16w700),
              ),
            ],
          ),
          actions: [
            Divider(
              height: 0,
            ),
            SizedBox(
              height: GetPlatform.isWeb ? 8 : 0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Text("한번에 등록",
                        style: (kIsWeb && (Get.width * 0.2 <= 171))
                            ? f12w700primary
                            : f16w700primary),
                    onPressed: confirmTap,
                  ),
                ),
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Text("한개씩 등록",
                        style: (kIsWeb && (Get.width * 0.2 <= 171))
                            ? f12w700primary
                            : f16w700primary),
                    onPressed: confirmTap2,
                  ),
                ),
              ],
            )
          ],
        );
      });
}

showOnlyConfirmDialog(BuildContext context, String title) {
  // show the dialog
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.only(top: 35, bottom: 35),
          content: Container(
            width: GetPlatform.isWeb ? Get.width * 0.3 : Get.width * 0.9,
            child: Text('${title}',
                textAlign: TextAlign.center,
                style:
                    (kIsWeb && (Get.width * 0.2 <= 171)) ? f12w700 : f16w700),
          ),
          actions: [
            Divider(
              height: 1,
            ),
            SizedBox(
              height: GetPlatform.isWeb ? 8 : 0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Text("확인",
                        style: (kIsWeb && (Get.width * 0.2 <= 171))
                            ? f12w700primary
                            : f16w700primary),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
              ],
            )
          ],
        );
      });
}

showOnlyLoginCheckDialog(
    BuildContext context, String title, VoidCallback onTap) {
  // show the dialog
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future(() => false);
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            content: Builder(
              builder: (context) {
                return Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${title}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 15,
                              fontFamily: 'NotoSansKr',
                              color: Colors.black)),
                    ],
                  ),
                );
              },
            ),
            actions: [
              Divider(
                color: Colors.grey,
              ),
              GestureDetector(
                onTap: onTap,
                behavior: HitTestBehavior.opaque,
                child: Center(
                  child: Container(
                    child: Text('확인',
                        style: TextStyle(
                            fontSize: 16,
                            fontFamily: 'NotoSansKr',
                            color: Colors.black)),
                  ),
                ),
              ),
              SizedBox(
                height: 12,
              ),
            ],
          ),
        );
      });
}

showConfirmTapDialog(BuildContext context, String title, VoidCallback onTap) {
  // show the dialog
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
          onWillPop: () {
            return Future(() => false);
          },
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
            contentPadding: const EdgeInsets.only(top: 45, bottom: 37),
            actionsPadding: const EdgeInsets.only(bottom: 21),
            content: Builder(
              builder: (context) {
                return Container(
                  width: GetPlatform.isWeb ? Get.width * 0.5 : Get.width * 0.9,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${title}',
                          textAlign: TextAlign.center,
                          style: (kIsWeb && (Get.width * 0.2 <= 171))
                              ? f12w700
                              : f16w700),
                    ],
                  ),
                );
              },
            ),
            actions: [
              Center(
                child: SizedBox(
                  width: 151,
                  height: 46,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '확인',
                          textAlign: TextAlign.center,
                          style: (kIsWeb && (Get.width * 0.2 <= 171))
                              ? f12w700primary
                              : f16w700primary,
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      });
}

// showDoubleComponentDialog(BuildContext context,String alertTitle ,String title, String firstComponent, String secondComponent,
//     VoidCallback firstTap, VoidCallback secondTap) {
//   // show the dialog
//   showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(5),
//           ),
//           contentPadding: const EdgeInsets.only(top: 45, bottom: 37, left: 16, right: 16),
//           actionsPadding: const EdgeInsets.only(bottom: 21, left: 20, right: 20),
//           title: alertTitle == '' ? null : Center(child: Text(alertTitle,style: f14w500,)),
//           content: Text('${title}',
//               textAlign: TextAlign.center,
//               style:
//                   TextStyle(fontSize: 14, fontWeight: FontWeight.w500, fontFamily: 'NotoSansKr', color: Colors.black)),
//           actions: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.33,
//                   height: 46,
//                   child: ElevatedButton(
//                     onPressed: firstTap,
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.white,
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(5.0), side: BorderSide(color: Color(0xffE9E9E9)))),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           '${firstComponent}',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontFamily: 'NotoSansKr',
//                             color: Colors.black,
//                             fontWeight: FontWeight.w400,
//                             fontSize: 14,
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(
//                   width: 12,
//                 ),
//                 SizedBox(
//                   width: MediaQuery.of(context).size.width * 0.33,
//                   height: 46,
//                   child: ElevatedButton(
//                     onPressed: secondTap,
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: Color(0xff558E99),
//                         padding: const EdgeInsets.symmetric(vertical: 12),
//                         elevation: 0,
//                         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5.0))),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           '${secondComponent}',
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             fontFamily: 'NotoSansKr',
//                             color: Colors.white,
//                             fontWeight: FontWeight.w400,
//                             fontSize: 14,
//                           ),
//                         )
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             )
//           ],
//         );
//         // return AlertDialog(
//         //   shape: RoundedRectangleBorder(
//         //     borderRadius: BorderRadius.circular(10),
//         //   ),
//         //   content: Builder(
//         //     builder: (context) {
//         //       return Container(
//         //         width: MediaQuery.of(context).size.width * 0.9,
//         //         child: Column(
//         //           mainAxisSize: MainAxisSize.min,
//         //           children: [
//         //             Text('${title}',
//         //                 textAlign: TextAlign.center,
//         //                 style: TextStyle(fontSize: 15, fontFamily: 'NotoSansKr', color: Colors.black)),
//         //           ],
//         //         ),
//         //       );
//         //     },
//         //   ),
//         //   actions: [
//         //     Divider(
//         //       color: Colors.grey,
//         //     ),
//         //     Row(
//         //       mainAxisAlignment: MainAxisAlignment.spaceAround,
//         //       children: [
//         //         TextButton(
//         //           child: Text("${firstComponent}",
//         //               style: TextStyle(fontSize: 16, fontFamily: 'NotoSansKr', color: Colors.black)),
//         //           onPressed: firstTap,
//         //         ),
//         //         TextButton(
//         //           child: Text("${secondComponent}",
//         //               style: TextStyle(fontSize: 16, fontFamily: 'NotoSansKr', color: Colors.black)),
//         //           onPressed: secondTap,
//         //         ),
//         //       ],
//         //     ),
//         //   ],
//         // );
//       });
// }

showEditDialog(
    BuildContext context, String title, VoidCallback confirmTap,TextEditingController Controller) {
  // show the dialog
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Builder(
            builder: (context) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${title}',
                        textAlign: TextAlign.center, style: f16w700),
                    SizedBox(
                      height: 29,
                    ),
                    TextField(
                      controller: Controller,
                      decoration: InputDecoration(
                        hintText: '${Controller.text}',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: textFormColor,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                          BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide:
                          BorderSide(color: Colors.transparent),
                        ),
                      ),
                      // obscureText: true,
                      keyboardType: TextInputType.text,
                      minLines: 1,
                    )
                  ],
                ),
              );
            },
          ),
          actions: [
            Divider(
              color: Colors.grey,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor:
                      MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Text("취소", style: TextStyle(fontFamily: "Pretendard",fontSize: 16,fontWeight: FontWeight.w700,color: Colors.grey)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor:
                      MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Text("확인", style: TextStyle(fontFamily: "Pretendard",fontSize: 16,fontWeight: FontWeight.w700,color: Color(0xff270BD3))),
                    onPressed: confirmTap,
                  ),
                ),
              ],
            ),
          ],
        );
      });
}

showEditDialogSat(
    BuildContext context, String title, VoidCallback confirmTap,TextEditingController Controller,ValueChanged<String> onSubmitted) {
  // show the dialog
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Builder(
            builder: (context) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${title}',
                        textAlign: TextAlign.center, style: f16w700),
                    SizedBox(
                      height: 29,
                    ),
                    TextField(
                      controller: Controller,
                      onSubmitted: onSubmitted,
                      decoration: InputDecoration(
                        hintText: '${Controller.text}',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: textFormColor,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                          BorderSide(color: Colors.transparent),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide:
                          BorderSide(color: Colors.transparent),
                        ),
                      ),
                      // obscureText: true,
                      keyboardType: TextInputType.text,
                      minLines: 1,
                    )
                  ],
                ),
              );
            },
          ),
          actions: [
            Divider(
              color: Colors.grey,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor:
                      MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Text("취소", style: TextStyle(fontFamily: "Pretendard",fontSize: 16,fontWeight: FontWeight.w700,color: Colors.grey)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor:
                      MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Text("확인", style: TextStyle(fontFamily: "Pretendard",fontSize: 16,fontWeight: FontWeight.w700,color: Color(0xff270BD3))),
                    onPressed: confirmTap,
                  ),
                ),
              ],
            ),
          ],
        );
      });
}

showPasswordDialog(BuildContext context, String title, VoidCallback confirmTap,
    TextEditingController pwController) {
  // show the dialog
  showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Container(
            width: Get.width * 0.3,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('${title}', textAlign: TextAlign.center, style: f16w700),
                SizedBox(
                  height: 29,
                ),
                TextField(
                  controller: pwController,
                  decoration: InputDecoration(
                    hintText: '비밀번호를 입력해주세요',
                    hintStyle: TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor: textFormColor,
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(12.0)),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      borderSide: BorderSide(color: Colors.transparent),
                    ),
                  ),
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  minLines: 1,
                )
              ],
            ),
          ),
          actions: [
            Divider(
              color: Colors.grey,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Text("취소",
                        style: TextStyle(
                            fontFamily: "Pretendard",
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey)),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Text("확인",
                        style: TextStyle(
                            fontFamily: "Pretendard",
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xff270BD3))),
                    onPressed: confirmTap,
                  ),
                ),
              ],
            ),
          ],
        );
      });
}

showTwoComponentDialog(BuildContext context, String title,
    VoidCallback cancelTap, VoidCallback confirmTap) {
  // show the dialog
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Builder(
            builder: (context) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('${title}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'NotoSansKr',
                            color: Colors.black)),
                  ],
                ),
              );
            },
          ),
          actions: [
            Divider(
              color: Colors.grey,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text("나중에 하기",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSansKr',
                          color: Colors.black)),
                  onPressed: cancelTap,
                ),
                TextButton(
                  child: Text("확인",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSansKr',
                          color: Colors.black)),
                  onPressed: confirmTap,
                ),
              ],
            ),
          ],
        );
      });
}

showComponentDialog(
    BuildContext context, String title, VoidCallback confirmTap) {
  // show the dialog
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          // actionsPadding: const EdgeInsets.symmetric(vertical: 20),
          contentPadding: const EdgeInsets.only(top: 35, bottom: 35),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: GetPlatform.isWeb
                    ? MediaQuery.of(context).size.width * 0.3
                    : MediaQuery.of(context).size.width * 0.9,
                child: Text('${title}',
                    textAlign: TextAlign.center,
                    style: (kIsWeb && (Get.width * 0.2 <= 171))
                        ? f12w700
                        : f16w700),
              ),
            ],
          ),
          actions: [
            Divider(
              height: 0,
            ),
            SizedBox(
              height: GetPlatform.isWeb ? 8 : 0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Text("취소",
                        style: (kIsWeb && (Get.width * 0.2 <= 171))
                            ? f12w700greyA
                            : f16w700greyA),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor:
                          MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Text("확인",
                        style: (kIsWeb && (Get.width * 0.2 <= 171))
                            ? f12w700primary
                            : f16w700primary),
                    onPressed: confirmTap,
                  ),
                ),
              ],
            )
          ],
        );
      });
}

showTextComponentDialog(BuildContext context, TextEditingController controller,
    VoidCallback confirmTap) {
  // show the dialog
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Builder(
            builder: (context) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        hintText: '수정할 내용을 입력해 주세요.',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white70,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.4)),
                        ),
                      ),
                      controller: controller,
                      keyboardType: TextInputType.multiline,
                      maxLines: 3,
                      minLines: 1,
                    )
                  ],
                ),
              );
            },
          ),
          actions: [
            Divider(
              color: Colors.grey,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text("취소",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSansKr',
                          color: Colors.black)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text("확인",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSansKr',
                          color: Colors.black)),
                  onPressed: confirmTap,
                ),
              ],
            ),
          ],
        );
      });
}

showTextFieldDialog(BuildContext context, TextEditingController controller,
    String title, VoidCallback confirmTap) {
  // show the dialog
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Builder(
            builder: (context) {
              return Container(
                width: MediaQuery.of(context).size.width * 0.9,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text('${title}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'NotoSansKr',
                            color: Colors.black)),
                    SizedBox(
                      height: 8,
                    ),
                    TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: '상세사유를 입력해 주세요.',
                        hintStyle: TextStyle(color: Colors.grey),
                        filled: true,
                        fillColor: Colors.white70,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)),
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.4)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          borderSide:
                              BorderSide(color: Colors.grey.withOpacity(0.4)),
                        ),
                      ),
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                    )
                  ],
                ),
              );
            },
          ),
          actions: [
            Divider(
              color: Colors.grey,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton(
                  child: Text("취소",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSansKr',
                          color: Colors.black)),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: Text("확인",
                      style: TextStyle(
                          fontSize: 16,
                          fontFamily: 'NotoSansKr',
                          color: Colors.black)),
                  onPressed: confirmTap,
                ),
              ],
            ),
          ],
        );
      });
}

showOnlyConfirmDialogChanged(BuildContext context, String title) {
  // show the dialog
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          actionsPadding: const EdgeInsets.only(bottom: 21),
          content: Builder(
            builder: (context) {
              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                width: MediaQuery.of(context).size.width * 0.9,
                child: Text(
                  title,
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: 'NotoSansKr',
                      color: Colors.black,
                      fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                ),
              );
            },
          ),
          actions: [
            Center(
              child: SizedBox(
                width: 151,
                height: 46,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xff558E99),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5.0))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '확인',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'NotoSansKr',
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      });
}

showSatScoreDialog(BuildContext context, List _sc, List _sc2, VoidCallback onTap) {
  // show the dialog
  showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding: const EdgeInsets.only(top: 35, bottom: 35, left: 20, right: 20),
          // titlePadding: EdgeInsets.only(left: 24,right: 24,top: 24,bottom: 0),
          // titlePadding: EdgeInsets.zero,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '점수입력',
                style: f24w700,
                textAlign: TextAlign.center,
              ),
              GestureDetector(
                onTap: () {
                  final _englishScore = [
                    '200',
                    '210',
                    '230',
                    '240',
                    '250',
                    '270',
                    '280',
                    '300',
                    '310',
                    '320',
                    '350',
                    '370',
                    '380',
                    '390',
                    '400',
                    '410',
                    '420',
                    '430',
                    '440',
                    '450',
                    '450',
                    '460',
                    '470',
                    '480',
                    '490',
                    '500',
                    '510',
                    '520',
                    '530',
                    '540',
                    '540',
                    '550',
                    '560',
                    '570',
                    '580',
                    '590',
                    '590',
                    '600',
                    '610',
                    '610',
                    '620',
                    '630',
                    '640',
                    '650',
                    '660',
                    '670',
                    '680',
                    '690',
                    '700',
                    '720',
                    '730',
                    '740',
                    '760',
                    '780',
                    '800'
                  ];
                  final _mathScore = [
                    '250',
                    '260',
                    '270',
                    '290',
                    '300',
                    '310',
                    '320',
                    '330',
                    '350',
                    '360',
                    '370',
                    '380',
                    '400',
                    '420',
                    '430',
                    '440',
                    '450',
                    '460',
                    '480',
                    '490',
                    '500',
                    '520',
                    '530',
                    '550',
                    '560',
                    '570',
                    '580',
                    '590',
                    '610',
                    '620',
                    '630',
                    '640',
                    '650',
                    '670',
                    '680',
                    '690',
                    '700',
                    '710',
                    '730',
                    '740',
                    '750',
                    '760',
                    '780',
                    '790',
                    '800',
                    '800',
                    '800',
                    '800',
                    '800',
                    '800',
                    '800',
                    '800',
                    '800',
                    '800',
                    '800'
                  ];
                  showComponentDialog(context, '기본값으로 변경하시겠습니까?\n\n입력하신 점수가 모두 초기화됩니다', () {
                    Get.back();
                    for (int i = 0; i < 55; i++) {
                      _sc[i].text = _englishScore[i];
                      _sc2[i].text = _mathScore[i];
                    }
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    color: testCountColor,
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(
                    '기본값',
                    style: f16w700primary,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
          content: Container(
            width: GetPlatform.isWeb ? Get.width * 0.6 : Get.width * 0.9,
            child: ListView.builder(
                itemCount: 55,
                reverse: true,
                itemBuilder: (_, index) {
                  return Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              child: Text(
                                '${index}',
                                style: f16w700,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                                // padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                child: TextField(
                                  onChanged: (v) {
                                    if (int.parse('${v}') > 800) {
                                      _sc[index].text = '';
                                    }
                                  },
                                  textAlign: TextAlign.center,
                                  controller: _sc[index],
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(3),
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                      isDense: true,
                                      filled: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                      hintText: '점수(영어)'),
                                )),
                          ),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                              child: Text(
                                '${index}',
                                style: f16w700,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                                decoration: BoxDecoration(border: Border.all(color: Colors.black)),
                                // padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                                child: TextField(
                                  textAlign: TextAlign.center,
                                  controller: _sc2[index],
                                  onChanged: (v) {
                                    if (int.parse('${v}') > 800) {
                                      _sc2[index].text = '';
                                    }
                                  },
                                  inputFormatters: [
                                    LengthLimitingTextInputFormatter(3),
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  decoration: InputDecoration(
                                      isDense: true,
                                      filled: true,
                                      border: InputBorder.none,
                                      contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                                      hintText: '점수(수학)'),
                                )),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      )
                    ],
                  );
                }),
          ),
          actions: [
            Divider(
              height: 1,
            ),
            SizedBox(
              height: GetPlatform.isWeb ? 8 : 0,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Text("취소", style: TextStyle(fontSize: 16, fontFamily: 'NotoSansKr', color: Colors.black)),
                    onPressed: () {
                      Get.back();
                    },
                  ),
                ),
                Expanded(
                  child: TextButton(
                    style: ButtonStyle(
                      overlayColor: MaterialStateProperty.all(Colors.transparent),
                    ),
                    child: Text("저장", style: (kIsWeb && (Get.width * 0.2 <= 171)) ? f12w700primary : f16w700primary),
                    onPressed: onTap,
                  ),
                ),
              ],
            )
          ],
        );
      });
}
