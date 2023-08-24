import 'dart:math';

import 'package:academy/components/footer/footer.dart';
import 'package:academy/provider/answer_state.dart';
import 'package:academy/provider/test_state.dart';
import 'package:academy/util/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../components/dialog/showAlertDialog.dart';
import '../../../../firebase/firebase_answer.dart';
import '../../../../provider/user_state.dart';
import '../../../../util/colors.dart';
import '../../../../util/font/font.dart';
import '../../../../util/refresh_manager.dart';
import '../../../login/login_main_screen.dart';
import '../../../main/main_screen.dart';
import '../../../main/student/test/individual/test_individual_screen.dart';
import '../../../main/student/test/test_check_screen.dart';

class TestCheckDetailScreen extends StatefulWidget {
  static final String id = '/test_check_detail';
  final String? docId;
  final String? isInd;
  final List? answer;

  const TestCheckDetailScreen({Key? key, this.docId, this.answer, this.isInd})
      : super(key: key);

  @override
  State<TestCheckDetailScreen> createState() => _TestCheckDetailScreenState();
}

class _TestCheckDetailScreenState extends State<TestCheckDetailScreen> {
  int _currentSortColumn = 0;
  bool _isAscending = true;
  bool _isLoading = true;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      // final as = Get.put(AnswerState());
      final args =
          ModalRoute.of(context)!.settings.arguments as TestCheckDetailScreen;
      await studentAnswerGet('${args.docId}');
      // _score = List.generate(as.testAnswerList.length, (index) => 0);

      // print('answer is : ${args.answer}');
      // for (int i = 0; i < as.testAnswerList.length; i++) {
      //   // _score[i] = ();
      //   print('doc id : ${as.testAnswerList[i]['docId']}');
      //   for (int j = 0; j < args.answer!.length; j++) {
      //     if (args.answer![j] == as.testAnswerList[i]['answer'][j]) {
      //       _score[i]++;
      //     }
      //   }
      //   // print('how many??? : ${args.answer!.where((e) => as.testAnswerList[i]['answer'].contains(e)).length}');
      // }
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final us = Get.put(UserState());
    final as = Get.put(AnswerState());
    final ts = Get.put(TestState());
    final args =
        ModalRoute.of(context)!.settings.arguments as TestCheckDetailScreen;

    return Scaffold(
      appBar: AppBar(
        // leading: null,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.offNamedUntil(
                  MainScreen.id,
                  (route) => false,
                );
              },
              child: SvgPicture.asset(
                'assets/logo.svg',
                width:
                    (GetPlatform.isWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
                height:
                    (GetPlatform.isWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                ? Container()
                : Text('테스트 체크')
          ],
        ),
        actions: [
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
                width: GetPlatform.isWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                height: GetPlatform.isWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
              ),
            )),
          ),
        ],
        elevation: 0,
        backgroundColor: nowColor,
      ),
      body: _isLoading
          ? LoadingBodyScreen()
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: DataTable(
                      sortColumnIndex: _currentSortColumn,
                      sortAscending: _isAscending,
                      headingRowColor: MaterialStateProperty.all(Colors.white),
                      columns: [
                        DataColumn(
                            label: Text(
                          '아이디',
                          style: (GetPlatform.isWeb && (Get.width * 0.2 <= 171))
                              ? f12w700
                              : f16w700,
                        )),
                        DataColumn(
                            label: Text('날짜',
                                style: (GetPlatform.isWeb &&
                                        (Get.width * 0.2 <= 171))
                                    ? f12w700
                                    : f16w700),
                            onSort: (columnIndex, _) {
                              setState(() {
                                _currentSortColumn = columnIndex;
                                if (_isAscending == true) {
                                  _isAscending = false;
                                  as.testAnswerList.sort((productA, productB) =>
                                      productB['createDate']
                                          .compareTo(productA['createDate']));
                                } else {
                                  _isAscending = true;
                                  as.testAnswerList.sort((productA, productB) =>
                                      productA['createDate']
                                          .compareTo(productB['createDate']));
                                }
                              });
                            }),
                        DataColumn(
                            label: Text(
                              '점수',
                              style: (GetPlatform.isWeb &&
                                      (Get.width * 0.2 <= 171))
                                  ? f12w700
                                  : f16w700,
                            ),
                            onSort: (columnIndex, _) {
                              setState(() {
                                _currentSortColumn = columnIndex;
                                if (_isAscending == true) {
                                  _isAscending = false;
                                  as.testAnswerList.sort((productA, productB) =>
                                      productB['score']
                                          .compareTo(productA['score']));
                                } else {
                                  _isAscending = true;
                                  as.testAnswerList.sort((productA, productB) =>
                                      productA['score']
                                          .compareTo(productB['score']));
                                }
                              });
                            }),
                      ],
                      // rows: [
                      //   DataRow(cells: [
                      //     DataCell(Text('${as.testAnswerList}'))
                      //   ])
                      // ],
                      rows: as.testAnswerList.map((item) {
                        return DataRow(cells: [
                          DataCell(GestureDetector(
                            onTap: () {
                              if (args.isInd == 'true') {
                                ts.individualAnswer.value = item['answer'];
                                Get.toNamed(TestIndividual.id,
                                    arguments: TestIndividual(
                                      isChecked: 'true',
                                      docId: item['answerDocid'],
                                      myPage: true,
                                    ));
                              } else {
                                ts.testDocId.value = item['docId'];
                                ts.answerDocId.value = '${args.docId}';
                                Get.to(() => TestCheckScreen(
                                    teacherName: '${us.userList[0].id}',
                                    docId: '${args.docId}',
                                    myPage: true));
                              }
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Text(
                              item['id'].toString(),
                              style: (GetPlatform.isWeb &&
                                      (Get.width * 0.2 <= 171))
                                  ? f12w500
                                  : f16w500,
                            ),
                          )),
                          DataCell((GetPlatform.isWeb &&
                                  (Get.width * 0.2 <= 171))
                              ? GestureDetector(
                                  onTap: () {
                                    if (args.isInd == 'true') {
                                      ts.individualAnswer.value =
                                          item['answer'];
                                      Get.toNamed(TestIndividual.id,
                                          arguments: TestIndividual(
                                            isChecked: 'true',
                                            docId: item['answerDocid'],
                                            myPage: true,
                                          ));
                                    } else {
                                      ts.testDocId.value = item['docId'];
                                      ts.answerDocId.value = '${args.docId}';
                                      Get.to(() => TestCheckScreen(
                                          teacherName: '${us.userList[0].id}',
                                          docId: '${args.docId}',
                                          myPage: true));
                                    }
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Text(
                                      '${DateFormat('y-MM-dd HH:mm').format(DateTime.parse('${item['createDate']}'))}',
                                      style: (GetPlatform.isWeb &&
                                              (Get.width * 0.2 <= 171))
                                          ? f12w500
                                          : f16w500),
                                )
                              : ConstrainedBox(
                                  constraints: BoxConstraints(
                                    maxWidth: 500,
                                    minWidth: 500,
                                  ),
                                  child: GestureDetector(
                                    onTap: () {
                                      if (args.isInd == 'true') {
                                        ts.individualAnswer.value =
                                            item['answer'];
                                        Get.toNamed(TestIndividual.id,
                                            arguments: TestIndividual(
                                              isChecked: 'true',
                                              docId: item['answerDocid'],
                                              myPage: true,
                                            ));
                                      } else {
                                        ts.testDocId.value = item['docId'];
                                        ts.answerDocId.value = '${args.docId}';
                                        Get.to(() => TestCheckScreen(
                                            teacherName: '${us.userList[0].id}',
                                            docId: '${args.docId}',
                                            myPage: true));
                                      }
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Text(
                                        '${DateFormat('y-MM-dd HH:mm').format(DateTime.parse('${item['createDate']}'))}',
                                        style: (GetPlatform.isWeb &&
                                                (Get.width * 0.2 <= 171))
                                            ? f12w500
                                            : f16w500),
                                  ))),
                          DataCell(GestureDetector(
                              onTap: () {
                                if (args.isInd == 'true') {
                                  ts.individualAnswer.value = item['answer'];
                                  Get.toNamed(TestIndividual.id,
                                      arguments: TestIndividual(
                                        isChecked: 'true',
                                        docId: item['answerDocid'],
                                        myPage: true,
                                      ));
                                } else {
                                  ts.testDocId.value = item['docId'];
                                  ts.answerDocId.value = '${args.docId}';
                                  Get.to(() => TestCheckScreen(
                                      teacherName: '${us.userList[0].id}',
                                      docId: '${args.docId}',
                                      myPage: true));
                                }
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Text('${item['score']}점',
                                  style: (GetPlatform.isWeb &&
                                          (Get.width * 0.2 <= 171))
                                      ? f12w500
                                      : f16w500))),
                          // DataCell(Text(item['price'].toString()))
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Footer(),
                ),
              ],
            ),
    );
  }
}
