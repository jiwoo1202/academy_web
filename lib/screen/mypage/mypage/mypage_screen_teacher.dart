import 'package:academy/provider/test_state.dart';
import 'package:academy/provider/user_state.dart';
import 'package:academy/screen/main/main_screen.dart';
import 'package:academy/screen/main/student/test/test_main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/src/painting/box_border.dart' as boxBorder;
import '../../../components/dialog/showAlertDialog.dart';
import '../../../components/footer/footer.dart';
import '../../../firebase/firebase_answer.dart';
import '../../../firebase/firebase_test.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/answer_state.dart';
import '../../../util/colors.dart';
import '../../../util/font/font.dart';
import '../../../util/refresh_manager.dart';
import '../../login/login_main_screen.dart';
import '../../main/student/test/individual/test_individual_screen.dart';


class MyPageScreenTeacher extends StatefulWidget {
  static final String id = '/mypage_screen_teacher';
  final String? docId;

  const MyPageScreenTeacher({Key? key, this.docId}) : super(key: key);

  @override
  State<MyPageScreenTeacher> createState() => _MyPageScreenTeacherState();
}

class _MyPageScreenTeacherState extends State<MyPageScreenTeacher> {
  bool _isLoading = true;
  bool _isMyBoolean = true;
  int _currentSortColumn = 0;
  bool _isAscending = true;

  @override
  void initState() {
    final us = Get.put(UserState());

    Future.delayed(Duration.zero, () async {
      await userGet(
          RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
      us.isLogin.value = RefreshManager.getCookie('type');
      if (us.isLogin == '' || us.userList.length == 0) {
        showConfirmTapDialog(context, '로그인 후에 이용할 수 있습니다', () {
          Get.offAllNamed(LoginMainScreen.id);
        });
      }
      final args =
      ModalRoute.of(context)!.settings.arguments as MyPageScreenTeacher;
      await studentAnswerGet('${args.docId}');

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

    return WillPopScope(
      onWillPop: () {
        return Future(() {
          return true;
        });
      },
      child: Scaffold(
        backgroundColor: backColor,
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
                  : Text('MyPage')
            ],
          ),
          // leadingWidth: 100,
          actions: [
            Center(
                child: Text(
                  '${us.userList[0].nickName}',
                  style: (GetPlatform.isWeb && (Get.width * 0.2 <= 171))
                      ? f12Whitew700
                      : f21Whitew700,
                )),
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
                      width:
                      GetPlatform.isWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                      height:
                      GetPlatform.isWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                    ),
                  )),
            ),
          ],
          elevation: 0,
          backgroundColor: nowColor,
        ),
        body: _isLoading
            ? Container()
            : GetPlatform.isWeb && (Get.width * 0.2 <= 171)
            ? Container() //MyPageScreenApp()
            : Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                Container(
                  width: Get.width * 0.8,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 70),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '테스트 확인',
                            style: f32w700,
                          ),
                          SizedBox(width: 18),
                        ],
                      ),
                      SizedBox(
                        height: 39,
                      ),
                      Container(
                        height: Get.height * 0.6,
                        decoration: BoxDecoration(
                          color: const Color(0xffffffff),
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        width: Get.width * 0.44,
                        padding: const EdgeInsets.all(40.0),
                        child: Container(
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  openExcel();
                                },
                                child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                                    decoration: BoxDecoration(
                                      border: boxBorder.Border.all(
                                          width: 1,
                                          color:nowColor
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          'assets/excel.svg',
                                          width: 16,
                                        ),
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        Text('엑셀',style: f18w700,),
                                      ],
                                    )),
                              ),
                              Expanded(
                                child: SingleChildScrollView(
                                  physics:
                                  const ClampingScrollPhysics(),
                                  child: DataTable(
                                    sortColumnIndex:
                                    _currentSortColumn,
                                    sortAscending: _isAscending,
                                    headingRowColor:
                                    MaterialStateProperty.all(
                                        Colors.white),
                                    columns: [
                                      DataColumn(
                                          label: Text(
                                            '점수',
                                            style: f16w700,
                                          ),
                                          onSort: (columnIndex, _) {
                                            setState(() {
                                              _currentSortColumn =
                                                  columnIndex;
                                              if (_isAscending ==
                                                  true) {
                                                _isAscending = false;
                                                as.testAnswerList.sort((productA,
                                                    productB) =>
                                                    productB['score']
                                                        .compareTo(
                                                        productA[
                                                        'score']));
                                              } else {
                                                _isAscending = true;
                                                as.testAnswerList.sort((productA,
                                                    productB) =>
                                                    productA['score']
                                                        .compareTo(
                                                        productB[
                                                        'score']));
                                              }
                                            });
                                          }),
                                      DataColumn(
                                          label: Text(
                                            '아이디',
                                            style: f16w700,
                                          ),
                                          onSort: (columnIndex, _) {
                                            setState(() {
                                              _currentSortColumn =
                                                  columnIndex;
                                              if (_isAscending ==
                                                  true) {
                                                _isAscending = false;
                                                as.testAnswerList
                                                    .sort((productA,
                                                    productB) =>
                                                    productB['id']
                                                        .compareTo(
                                                        productA[
                                                        'id']));
                                              } else {
                                                _isAscending = true;
                                                as.testAnswerList
                                                    .sort((productA,
                                                    productB) =>
                                                    productA['id']
                                                        .compareTo(
                                                        productB[
                                                        'id']));
                                              }
                                            });
                                          }),
                                      DataColumn(
                                          label: Text('날짜',
                                              style: f16w700),
                                          onSort: (columnIndex, _) {
                                            setState(() {
                                              _currentSortColumn =
                                                  columnIndex;
                                              if (_isAscending ==
                                                  true) {
                                                _isAscending = false;
                                                as.testAnswerList.sort((productA,
                                                    productB) =>
                                                    productB[
                                                    'createDate']
                                                        .compareTo(
                                                        productA[
                                                        'createDate']));
                                              } else {
                                                _isAscending = true;
                                                as.testAnswerList.sort((productA,
                                                    productB) =>
                                                    productA[
                                                    'createDate']
                                                        .compareTo(
                                                        productB[
                                                        'createDate']));
                                              }
                                            });
                                          }),
                                    ],
                                    rows:
                                    as.testAnswerList.map((item) {
                                      return DataRow(cells: [
                                        DataCell(ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: 70,
                                            minWidth: 70,
                                          ),
                                          child: GestureDetector(
                                              onTap: () {
                                                if (item[
                                                'isIndividual'] ==
                                                    'true') {
                                                  ts.individualAnswer
                                                      .value =
                                                  item['answer'];
                                                  Get.toNamed(
                                                      TestIndividual
                                                          .id,
                                                      arguments:
                                                      TestIndividual(
                                                        isChecked:
                                                        'true',
                                                        docId: item[
                                                        'answerDocid'],
                                                        myPage: true,
                                                      ));
                                                } else {
                                                  getAnsDocId(
                                                      item, ts, us);
                                                }
                                              },
                                              behavior:
                                              HitTestBehavior
                                                  .opaque,
                                              child: Text(
                                                  '${item['score']}점',
                                                  style: (GetPlatform
                                                      .isWeb &&
                                                      (Get.width *
                                                          0.2 <=
                                                          171))
                                                      ? f12w500
                                                      : f16w500)),
                                        )),
                                        DataCell(ConstrainedBox(
                                          constraints: BoxConstraints(
                                            maxWidth: 70,
                                            minWidth: 70,
                                          ),
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (item[
                                              'isIndividual'] ==
                                                  'true') {
                                                ts.individualAnswer
                                                    .value =
                                                item['answer'];
                                                Get.toNamed(
                                                    TestIndividual.id,
                                                    arguments:
                                                    TestIndividual(
                                                      isChecked:
                                                      'true',
                                                      docId: item[
                                                      'answerDocid'],
                                                      myPage: true,
                                                    ));
                                              } else {
                                                await getAnsDocId(
                                                    item, ts, us);
                                              }
                                            },
                                            behavior: HitTestBehavior
                                                .opaque,
                                            child: Text(
                                              '${item['id']}',
                                              style: (GetPlatform
                                                  .isWeb &&
                                                  (Get.width *
                                                      0.2 <=
                                                      171))
                                                  ? f12w500
                                                  : f16w500,
                                            ),
                                          ),
                                        )),
                                        DataCell(ConstrainedBox(
                                            constraints:
                                            BoxConstraints(
                                              maxWidth: 200,
                                              minWidth: 200,
                                            ),
                                            child: GestureDetector(
                                              onTap: () async {
                                                if (item[
                                                'isIndividual'] ==
                                                    'true') {
                                                  ts.individualAnswer
                                                      .value =
                                                  item['answer'];
                                                  Get.toNamed(
                                                      TestIndividual
                                                          .id,
                                                      arguments:
                                                      TestIndividual(
                                                        isChecked:
                                                        'true',
                                                        docId: item[
                                                        'answerDocid'],
                                                        myPage: true,
                                                      ));
                                                } else {
                                                  await getAnsDocId(
                                                      item, ts, us);
                                                }
                                              },
                                              behavior:
                                              HitTestBehavior
                                                  .opaque,
                                              child: Text(
                                                  '${DateFormat('y-MM-dd HH:mm').format(DateTime.parse('${item['createDate']}'))}',
                                                  style: (GetPlatform
                                                      .isWeb &&
                                                      (Get.width *
                                                          0.2 <=
                                                          171))
                                                      ? f12w500
                                                      : f16w500),
                                            ))),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Footer()
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> getAnsDocId(item, TestState ts, UserState us) async {
    final args =
    ModalRoute.of(context)!.settings.arguments as MyPageScreenTeacher;
    CollectionReference likeRef =
    FirebaseFirestore.instance.collection('answer');
    QuerySnapshot snapshot = await likeRef
        .where('teacher', isEqualTo: item['teacher'])
        .where('pdfCategory', isEqualTo: '${item['testTitle']}')
        .get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    List a = allData;
    ts.realAnswer.value = a[0]['answer'];
    ts.testDocId.value = item['docId'];
    ts.answerDocId.value = '${a[0]['docId']}';
    await firebaseSingleQuestionGet(ts.testDocId.value);
    var url =
        'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/12345%2F${us.userList[0].id}%2F${args.docId}.pdf?alt=media';
    final file = await http.get(Uri.parse(url));
    final content = file.bodyBytes;
    Get.toNamed(TestMainScreen.id,
        arguments: TestMainScreen(
          content: content,
          hasAudio: '${a[0]['audio']}',
          teacher: '${us.userList[0].id}',
          docId: '${a[0]['docId']}',
          myPageb: true, // answer에 docId
        ));
  }

  Future<void> openExcel() async {
    final as = Get.put(AnswerState());
    final excel = Excel.createExcel();
    final sheet = excel.sheets[excel.getDefaultSheet() as String];
    int num = 1;
    CellStyle cellStyle = CellStyle(
        horizontalAlign: HorizontalAlign.Center,
        verticalAlign: VerticalAlign.Center);

    var cell =
    sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1));
    cell?.cellStyle = cellStyle;
    cell?.value = '넘버';

    var cell2 =
    sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 2));
    cell2?.cellStyle = cellStyle;
    cell2?.value = '이름';

    var cell3 =
    sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 3));
    cell3?.cellStyle = cellStyle;
    cell3?.value = '날짜';

    var cell4 = sheet?.cell(CellIndex.indexByColumnRow(
        columnIndex: 1, rowIndex: as.testAnswerList[0]['answer'].length + 4));
    cell4?.cellStyle = cellStyle;
    cell4?.value = '총점';

    for (int i = 0; i < as.testAnswerList.length; i++) {
      sheet?.cell(CellIndex.indexByColumnRow(columnIndex: i + 2, rowIndex: 1)).value = num;
      sheet?.cell(CellIndex.indexByColumnRow(columnIndex: i + 2, rowIndex: 1)).cellStyle = cellStyle;
      num += 1;

      sheet?.cell(CellIndex.indexByColumnRow(columnIndex: i + 2, rowIndex:2)).value = '${as.testAnswerList[i]['id']}';
      sheet?.cell(CellIndex.indexByColumnRow(columnIndex: i + 2, rowIndex: 2)).cellStyle = cellStyle;

      sheet?.cell(CellIndex.indexByColumnRow(columnIndex: i + 2, rowIndex: 3)).value = '${DateFormat('yy-MM-dd HH:mm').format(DateTime.parse('${as.testAnswerList[i]['createDate']}'))}';
      sheet?.cell(CellIndex.indexByColumnRow(columnIndex: i + 2, rowIndex: 3)).cellStyle = cellStyle;

      sheet?.cell(CellIndex.indexByColumnRow(columnIndex:i + 2,rowIndex:as.testAnswerList[0]['answer'].length + 4)).value = '${as.testAnswerList[i]['score']}점';
      sheet?.cell(CellIndex.indexByColumnRow(columnIndex:i + 2,rowIndex:as.testAnswerList[0]['answer'].length + 4)).cellStyle = cellStyle;

      for (int j = 0; j < as.settingGetAnswer[0]['answer'].length; j++) {
        if (as.settingGetAnswer[0]['answer'][j] == as.testAnswerList[i]['answer'][j] || (as.settingGetAnswer[0]['temp1'][j] == as.testAnswerList[i]['answer'][j] && as.settingGetAnswer[0]['temp1'][j] != '')) {
          sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: j + 4)).value = '${j + 1}번';
          sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: j + 4)).cellStyle = cellStyle;

          sheet?.cell(CellIndex.indexByColumnRow(columnIndex: i + 2, rowIndex: j + 4)).value = 'O';
          sheet?.cell(CellIndex.indexByColumnRow(columnIndex: i + 2, rowIndex: j + 4)).cellStyle = cellStyle;
        } else {
          sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: j + 4)).value = '${j + 1}번';
          sheet?.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: j + 4)).cellStyle = cellStyle;
          sheet?.cell(CellIndex.indexByColumnRow(columnIndex: i + 2, rowIndex: j + 4)).value = 'X';
          sheet?.cell(CellIndex.indexByColumnRow(columnIndex: i + 2, rowIndex: j + 4)).cellStyle = cellStyle;
        }
      }
    }
    // for(int i=0;i<as.testAnswerList.length;i++){
    //
    //
    // }
    excel.save(fileName: '${as.settingGetAnswer[0]['pdfCategory']}.xlsx');
  }
}
