import 'package:academy/provider/test_state.dart';
import 'package:academy/provider/user_state.dart';
import 'package:academy/screen/community/job/job_hunting_screen.dart';
import 'package:academy/screen/community/story/story_main_screen.dart';
import 'package:academy/screen/main/main_screen.dart';
import 'package:academy/screen/main/student/test/test_main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../../../api/pdf/pdf_api.dart';
import '../../../components/button/choose_mypage.dart';
import '../../../components/dialog/showAlertDialog.dart';
import '../../../components/footer/footer.dart';
import '../../../firebase/firebase_test.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/answer_state.dart';
import '../../../util/colors.dart';
import '../../../util/font/font.dart';
import '../../../util/refresh_manager.dart';
import '../../login/login_main_screen.dart';
import '../../main/student/test/individual/test_individual_screen.dart';
import '../../main/student/test/test_check_screen.dart';
import 'dart:html' as html;

import '../../main/student/test/test_file.dart';

class MyPageScreenStudent extends StatefulWidget {
  static final String id = '/mypage_screen_sudent';
  final String? teacherName;
  final String? docId;
  final bool? myPage;

  const MyPageScreenStudent({Key? key, this.docId, this.teacherName, this.myPage}) : super(key: key);

  @override
  State<MyPageScreenStudent> createState() => _MyPageScreenStudentState();
}

class _MyPageScreenStudentState extends State<MyPageScreenStudent> {
  bool _isLoading = true;
  int correct = 0;
  List<String> number = ['1', '2', '3', '4', '5'];

  @override
  void initState() {
    final us = Get.put(UserState());

    Future.delayed(Duration.zero, () async {
      final ts = Get.put(TestState());

      // final as = Get.put(AnswerState());
      // await answerGet('fNWPBW7v8VQJ1HzKeYu5');
      await firebaseAnswerGet(ts.answerDocId.value);
      await firebaseSingleQuestionGet(ts.testDocId.value);
      _score();
      setState(() {
        _isLoading = false;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ts = Get.put(TestState());
    final us = Get.put(UserState());
    final as = Get.put(AnswerState());
    final args = ModalRoute.of(context)!.settings.arguments as MyPageScreenStudent;

    return WillPopScope(
      onWillPop: () {
        return Future(() {
          Get.back();
          return true;
        });
      },
      child: Scaffold(
        backgroundColor: backColor,
        body: _isLoading
            ? Container()
            : GetPlatform.isWeb && (Get.width * 0.2 <= 171) ? Container()//MyPageScreenApp()
            : SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
              child: Column(
                children: [
                  Container(margin: EdgeInsets.symmetric(horizontal: Get.width * 0.15),
                    width: Get.width * 0.8,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('내 점수 확인', style: f32w700,),
                            const SizedBox(width: 18,),
                            Container(
                              padding: const EdgeInsets.all(12.0),
                              child: Center(child: Text('총점 : ${((correct / ts.realAnswer[0]['answer'].length) * 100).ceil()}'
                                , style: f16Whitew700,)),
                              decoration: BoxDecoration(
                                color: const Color(0xff535353),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            const SizedBox(width: 18,),
                            GestureDetector(
                              onTap: () async{
                                var url =
                                    'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/12345%2F${args.teacherName}%2F${args.docId}.pdf?alt=media';
                                final file =
                                await http.get(Uri.parse(url));
                                final content = file.bodyBytes;
                                Get.toNamed(TestMainScreen.id,
                                    arguments: TestMainScreen(
                                      content: content,
                                      hasAudio: '${ts.realAnswer[0]['audio']}',
                                      teacher: args.teacherName,
                                      docId: args.docId,
                                      myPageb: true,
                                    ));
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12.0),
                                child: Center(child: Text('시험지'
                                  , style: f16w700,)),
                                decoration: BoxDecoration(
                                  color: const Color(0xffffffff),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    width: 1,
                                    color: const Color(0xff535353),
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height: 39,),

                        Container(
                          height: Get.height * 0.6,
                          decoration: BoxDecoration(
                            color: const Color(0xffffffff),
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Container(height: Get.height,
                            padding: const EdgeInsets.all(40.0),
                            child: ScrollConfiguration(
                              behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                              child: ListView.builder(
                                itemCount: ts.realAnswer[0]['answer'].length,
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemBuilder: (_, index) {
                                  return Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Column(crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${index + 1}번 문제',
                                                style: f16w400grey8,
                                              ),
                                              const SizedBox(height: 10,),
                                              number.contains(ts.realAnswer[0]['answer'][index])
                                                  ? Text('정답 : ${ts.realAnswer[0]['answer'][index]}', style: f16w700,)
                                                  : Container()
                                            ],
                                          ),
                                          Spacer(),
                                          number.contains(ts.realAnswer[0]['answer'][index])
                                              ? Container(
                                              height: 52,
                                              child: ListView.builder(
                                                itemCount: 5,
                                                shrinkWrap: true,
                                                itemBuilder: (context, idx) {
                                                  return SizedBox(
                                                    child: Row(
                                                      children: [
                                                        SizedBox(
                                                          width: 52,
                                                          height: 52,
                                                          child: Container(
                                                            decoration: BoxDecoration(
                                                                color: ts.mySingleAnswer[0]['answer'][index] == number[idx] && ts.mySingleAnswer[0]['answer'][index] ==ts.realAnswer[0]['answer'][index]
                                                                    ? nowColor
                                                                    :  ts.mySingleAnswer[0]['answer'][index] == number[idx] && ts.mySingleAnswer[0]['answer'][index] !=ts.realAnswer[0]['answer'][index] || ts.mySingleAnswer[0]['answer'][index] =='' && ts.realAnswer[0]['answer'][index]==number[idx]
                                                                    ? Colors.red
                                                                    : Colors.white,
                                                                border: Border.all(
                                                                    width: 1,
                                                                    color:
                                                                    cameraBackColor),
                                                                borderRadius:
                                                                BorderRadius.all(
                                                                    Radius.circular(20))),
                                                            child: Row(
                                                              mainAxisAlignment: MainAxisAlignment.center,
                                                              crossAxisAlignment: CrossAxisAlignment.center,
                                                              children: [
                                                                Text(
                                                                  '${idx + 1}',
                                                                  textAlign:
                                                                  TextAlign.center,
                                                                  style: ts.mySingleAnswer[0]['answer'][index] ==ts.realAnswer[0]['answer'][index]&&ts.mySingleAnswer[0]['answer'][index]==number[idx]
                                                                      ?f16Whitew700
                                                                      :ts.mySingleAnswer[0]['answer'][index]==  number[idx] || (ts.mySingleAnswer[0]['answer'][index] ==''&& ts.realAnswer[0]['answer'][index] ==  number[idx])
                                                                      ?f16Whitew700
                                                                      : f16w700,
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                        SizedBox(
                                                          width: 10,
                                                        )
                                                      ],
                                                    ),
                                                  );
                                                },
                                                scrollDirection: Axis.horizontal,
                                              ))
                                              : Container(
                                            width: Get.width,
                                            decoration: BoxDecoration(
                                              color: textFormColor,
                                              border: Border.all(
                                                width: 1,
                                                color: blurColor,
                                              ),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              '${ts.mySingleAnswer[0]['answer'][index]}',
                                              style: f18w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 40,),
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  Footer()
                ],
              ),
            ),
      ),
    );
  }

  void _score() {
    final ts = Get.put(TestState());

    for (int i = 0; i < ts.realAnswer[0]['answer'].length; i++) {
      if (ts.realAnswer[0]['answer'][i] == ts.mySingleAnswer[0]['answer'][i]) {
        correct++;
      }
    }
  }
}
