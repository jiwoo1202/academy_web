import 'package:academy/components/appbar/appbars.dart';
import 'package:academy/components/footer/footer.dart';
import 'package:academy/provider/sat_state.dart';
import 'package:academy/provider/test_state.dart';
import 'package:academy/provider/user_state.dart';
import 'package:academy/screen/community/story/story_write_screen.dart';
import 'package:academy/screen/mypage/mypage/score/score_check_screen.dart';
import 'package:academy/screen/mypage/qna/qnaWrite.dart';
import 'package:academy/util/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../components/button/choose_mypage.dart';
import '../../../components/dialog/showAlertDialog.dart';
import '../../../firebase/firebase_test.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/answer_state.dart';
import '../../../util/colors.dart';
import '../../../util/font/font.dart';
import '../../../util/refresh_manager.dart';
import '../../login/login_main_screen.dart';
import '../../main/sat/result_pdf_screen.dart';
import '../../main/student/test/individual/sat/test_individual_screen_sat.dart';
import '../../main/student/test/individual/test_individual_screen.dart';
import '../../main/student/test/test_check_screen.dart';

import '../qna/qnaDetail_screen.dart';
import 'mypage_screen_student.dart';
import 'mypage_screen_teacher.dart';

class MyPageScreen extends StatefulWidget {
  static final String id = '/mypage_screen';
  final String? whichPage;

  const MyPageScreen({Key? key, this.whichPage: 'main'}) : super(key: key);

  @override
  State<MyPageScreen> createState() => _MyPageScreenState();
}

class _MyPageScreenState extends State<MyPageScreen> {
  bool _isLoading = true;
  bool _isMyBoolean = true;
  final _idxBool = [false, false, false];
  int _currentSortColumn = 0;
  int _currentSatColumn = 2;
  bool _isAscending = false;
  bool _isSATAscending = false;
  List _teacherAnswer = [];
  List _firstScoreVisual = []; // 날짜
  List _allList = [];
  List testScore = [];

  List _secondList = [];
  List _qnaL = [];
  List _satL = [];
  List _satAL = [];
  List<Map<String, dynamic>> pairs = [];
  int index = 0;
  bool scoreAsc = false;

  /// sat 마이페이지에서 시험명 클릭했을때 다음페이지로 넘기는 변수
  int nextPage = 0;
  /// 시험본 학생들 가져오는 리스트
  List _testStudentList = [];
  /// 선생님 닥아아디
  String teacherDocId = '';

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    final us = Get.put(UserState());
    final ts = Get.put(TestState());
    _idxBool[0] = true;
    Future.delayed(Duration.zero, () async {
      scoreAsc = false;
      await userGet(RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
      await _getQnA('${RefreshManager.getCookie('id')}');

      // await userGet('stu', '1234');
      // await _getQnA('stu');
      /// sat정보 가져오기
      await _firebaseSATGet();

      await _firebaseSatAnswerGet();

      ///

      us.isLogin.value = RefreshManager.getCookie('type');
      if (us.isLogin == '' || us.userList.length == 0) {
        showConfirmTapDialog(context, '로그인 후에 이용할 수 있습니다', () {
          Get.offAllNamed(LoginMainScreen.id);
        });
      }

      if(us.userList[0].userType == '학생'){
        await firebaseAllQuestionGet('${us.userList[0].id}');
      }


      _teacherAnswer = await getAnsTeacher(us);

      // firstScoreVisual = ts.answerVisiual2.value;
      _allList = ts.answerVisiual.value;

      testScore = ts.answerScore.value;

      pairs = testScore
          .asMap()
          .entries.map((entry) => {'value': entry.value, 'flag': _allList[entry.key], 'createDate': ts.answerDate[entry.key]})
          .toList();

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
    final ss = Get.put(SatState());
    final args = ModalRoute.of(context)!.settings.arguments as MyPageScreen?;
    return WillPopScope(
      onWillPop: () {
        return Future(() {
          Get.back();
          return true;
        });
      },
      child: Scaffold(
        backgroundColor: backColor,
        appBar: Appbars(us: us, context: context),
        body: _isLoading
            ? LoadingBodyScreen()
            : GetPlatform.isWeb && (Get.width < 1024)
                ? Container(
                    width: Get.width,
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xffffffff),
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              width: Get.width * 0.22,
                              padding: const EdgeInsets.all(20.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                                      width: Get.width,
                                      decoration: BoxDecoration(
                                        color: const Color(0xffffffff),
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Color(0xffDADADA),
                                            width: 1.0,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        '마이페이지',
                                        style: f18w700,
                                      )),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  ChooseMypage(
                                    title: us.userList[0].userType == '학생' ? '내 점수 확인' : '테스트 확인',
                                    isTrue: _isMyBoolean,
                                    onTap: () {
                                      setState(() {
                                        _isMyBoolean = true;
                                      });
                                    },
                                  ),
                                  SizedBox(
                                    height: 8,
                                  ),
                                  ChooseMypage(
                                    title: 'Q&A',
                                    isTrue: !_isMyBoolean,
                                    onTap: () {
                                      setState(() {
                                        _isMyBoolean = false;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              width: 40,
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      us.userList[0].userType == '학생'
                                          ? '${_isMyBoolean == true ? '내 점수 확인' : 'Q&A'}'
                                          : '${_isMyBoolean == true ? '테스트 확인' : 'Q&A'}',
                                      style: f32w700,
                                    ),
                                    _isMyBoolean == false
                                        ? SizedBox(
                                            width: 12,
                                          )
                                        : SizedBox(
                                            height: 0,
                                          ),
                                    _isMyBoolean == false
                                        ? Container(
                                            padding: const EdgeInsets.all(12.0),
                                            child: Center(
                                                child: Text(
                                              '글쓰기',
                                              style: f16Whitew700,
                                            )),
                                            decoration: BoxDecoration(
                                              color: const Color(0xff070707),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          )
                                        : SizedBox(
                                            height: 0,
                                          ),
                                  ],
                                ),
                                SizedBox(
                                  height: 40,
                                ),
                                Container(
                                  height: Get.height * 0.6,
                                  decoration: BoxDecoration(
                                    color: const Color(0xffffffff),
                                    borderRadius: BorderRadius.circular(20.0),
                                  ),
                                  width: Get.width * 0.6,
                                  padding: const EdgeInsets.all(40.0),
                                  child: _isMyBoolean
                                      ? Container(
                                          child: Column(
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
                                                          '점수',
                                                          style: f14w700,
                                                        ),
                                                        onSort: (columnIndex, _) {
                                                          setState(() {
                                                            _currentSortColumn = columnIndex;
                                                            if (_isAscending == true) {
                                                              _isAscending = false;
                                                              ts.myAnswer
                                                                  .sort((productA, productB) => productB['score'].compareTo(productA['score']));
                                                            } else {
                                                              _isAscending = true;
                                                              ts.myAnswer
                                                                  .sort((productA, productB) => productA['score'].compareTo(productB['score']));
                                                            }
                                                          });
                                                        }),
                                                    DataColumn(
                                                      label: Text(
                                                        '시험명',
                                                        style: f14w700,
                                                      ),
                                                    ),
                                                    // DataColumn(
                                                    //     label: Text(
                                                    //       '유형',
                                                    //       style:
                                                    //       f14w700,
                                                    //     ), ),
                                                    DataColumn(
                                                        label: Text(
                                                          '날짜',
                                                          style: f14w700,
                                                        ),
                                                        onSort: (columnIndex, _) {
                                                          setState(() {
                                                            _currentSortColumn = columnIndex;
                                                            if (_isAscending == true) {
                                                              _isAscending = false;
                                                              ts.myAnswer.sort(
                                                                  (productA, productB) => productB['createDate'].compareTo(productA['createDate']));
                                                            } else {
                                                              _isAscending = true;
                                                              ts.myAnswer.sort(
                                                                  (productA, productB) => productA['createDate'].compareTo(productB['createDate']));
                                                            }
                                                          });
                                                        }),
                                                  ],
                                                  rows: ts.myAnswer.map((item) {
                                                    return DataRow(cells: [
                                                      DataCell(ConstrainedBox(
                                                        constraints: BoxConstraints(
                                                          maxWidth: 70,
                                                          minWidth: 70,
                                                        ),
                                                        child: GestureDetector(
                                                            onTap: () {
                                                              if (item['isIndividual'] == 'true') {
                                                                ts.individualAnswer.value = item['answer'];
                                                                Get.toNamed(TestIndividual.id,
                                                                    arguments: TestIndividual(
                                                                      isChecked: 'true',
                                                                      docId: item['answerDocid'],
                                                                      myPage: true,
                                                                    ));
                                                              } else {
                                                                getAnsDocId(item, ts, us);
                                                              }
                                                            },
                                                            child: Text('${item['score']}점', style: f14w700)),
                                                      )),
                                                      DataCell(GestureDetector(
                                                        onTap: () {
                                                          if (item['isIndividual'] == 'true') {
                                                            ts.individualAnswer.value = item['answer'];
                                                            Get.toNamed(TestIndividual.id,
                                                                arguments: TestIndividual(
                                                                  isChecked: 'true',
                                                                  docId: item['answerDocid'],
                                                                  myPage: true,
                                                                ));
                                                          } else {
                                                            getAnsDocId(item, ts, us);
                                                          }
                                                        },
                                                        child: Text('${item['testTitle']}', style: f14w400),
                                                      )),
                                                      // DataCell(
                                                      //     ConstrainedBox(
                                                      //       constraints:
                                                      //       BoxConstraints(
                                                      //         maxWidth:
                                                      //         70,
                                                      //         minWidth:
                                                      //         70,
                                                      //       ),
                                                      //       child: GestureDetector(
                                                      //         onTap:(){
                                                      //           if (item['isIndividual'] == 'true') {
                                                      //             ts.individualAnswer.value = item['answer'];
                                                      //             Get.toNamed(TestIndividual.id,
                                                      //                 arguments: TestIndividual(
                                                      //                   isChecked: 'true',
                                                      //                   docId: item['answerDocid'],
                                                      //                   myPage: true,
                                                      //                 ));
                                                      //           } else {
                                                      //             getAnsDocId(item, ts, us);
                                                      //           }
                                                      //         },
                                                      //         child: Text(
                                                      //             '${item['isIndividual'] == 'true' ? '개별' : '전체'}',
                                                      //             style:
                                                      //             f14w700),
                                                      //       ),
                                                      //     )),
                                                      DataCell(ConstrainedBox(
                                                          constraints: BoxConstraints(
                                                            maxWidth: 200,
                                                            minWidth: 200,
                                                          ),
                                                          child: GestureDetector(
                                                              onTap: () {
                                                                if (item['isIndividual'] == 'true') {
                                                                  ts.individualAnswer.value = item['answer'];
                                                                  Get.toNamed(TestIndividual.id,
                                                                      arguments: TestIndividual(
                                                                        isChecked: 'true',
                                                                        docId: item['answerDocid'],
                                                                        myPage: true,
                                                                      ));
                                                                } else {
                                                                  getAnsDocId(item, ts, us);
                                                                }
                                                              },
                                                              child: Text(
                                                                  '${DateFormat('y-MM-dd HH:mm').format(DateTime.parse('${item['createDate']}'))}',
                                                                  style: f14w400greyA)))),
                                                      // DataCell(Text(item['price'].toString()))
                                                    ]);
                                                  }).toList(),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ))
                                      : ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _qnaL.length,
                                          physics: const ClampingScrollPhysics(),
                                          itemBuilder: (_, idx) {
                                            return Column(
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      '${_qnaL[idx]['title']}',
                                                      style: f14w700,
                                                    ),
                                                    const SizedBox(
                                                      width: 12,
                                                    ),
                                                    Text(
                                                      '${_qnaL[idx]['state']}',
                                                      style: f14w400greyA,
                                                    ),
                                                    Spacer(),
                                                    Text(
                                                      '${DateFormat('y-MM-dd HH:mm').format(DateTime.parse('${_qnaL[idx]['createDate']}'))}',
                                                      style: f14w400greyA,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 12,
                                                ),
                                                Divider(
                                                  color: Color(0xffdadada),
                                                ),
                                                const SizedBox(
                                                  height: 12,
                                                ),
                                              ],
                                            );
                                          }),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      children: [
                        Center(
                          child: Container(
                            width: Get.width * 0.8,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 70),
                            child: Column(
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: const Color(0xffffffff),
                                        borderRadius: BorderRadius.circular(20.0),
                                      ),
                                      width: Get.width * 0.18,
                                      padding: const EdgeInsets.all(20.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                                              width: Get.width,
                                              decoration: BoxDecoration(
                                                color: const Color(0xffffffff),
                                                border: Border(
                                                  bottom: BorderSide(
                                                    color: Color(0xffDADADA),
                                                    width: 1.0,
                                                  ),
                                                ),
                                              ),
                                              child: Text(
                                                '마이페이지',
                                                style: f18w700,
                                              )),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          ChooseMypage(
                                            title: us.userList[0].userType == '학생' ? '내 점수 확인' : '테스트 확인',
                                            isTrue: _idxBool[0],
                                            onTap: () {
                                              nextPage =0;
                                              _idxBool[0] = true;
                                              _idxBool[2] = false;
                                              _idxBool[1] = false;
                                              setState(() {});
                                            },
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          ChooseMypage(
                                            title: 'SAT',
                                            isTrue: _idxBool[1],
                                            onTap: () {
                                              nextPage =0;
                                              _idxBool[0] = false;
                                              _idxBool[2] = false;
                                              _idxBool[1] = true;
                                              setState(() {});
                                            },
                                          ),
                                          SizedBox(
                                            height: 8,
                                          ),
                                          ChooseMypage(
                                            title: 'Q&A',
                                            isTrue: _idxBool[2],
                                            onTap: () {
                                              nextPage =0;
                                              _idxBool[0] = false;
                                              _idxBool[1] = false;

                                              _idxBool[2] = true;
                                              setState(() {});
                                            },
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: 50,
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              us.userList[0].userType == '학생'
                                                  ? '${_idxBool[0] == true ? '내 점수 확인' : _idxBool[2] ? 'Q&A' : 'SAT'}'
                                                  : '${_idxBool[0] == true ? '테스트 확인' : _idxBool[2] ? 'Q&A' : 'SAT'}',
                                              style: f32w700,
                                            ),
                                            _idxBool[2] == true
                                                ? SizedBox(
                                                    width: 12,
                                                  )
                                                : SizedBox(
                                                    height: 0,
                                                  ),
                                            _idxBool[2] == true
                                                ? Container(
                                                    padding: const EdgeInsets.all(12.0),
                                                    child: Center(
                                                        child: GestureDetector(
                                                      onTap: () {
                                                        Get.toNamed(StoryWriteScreen.id,
                                                                arguments: StoryWriteScreen(
                                                                  whichScreen: 'qna',
                                                                  refreshIndicatorKey: _refreshIndicatorKey,
                                                                ))!
                                                            .then(onGoBack);
                                                      },
                                                      child: Text(
                                                        '글쓰기',
                                                        style: f16Whitew700,
                                                      ),
                                                    )),
                                                    decoration: BoxDecoration(
                                                      color: const Color(0xff070707),
                                                      borderRadius: BorderRadius.circular(8),
                                                    ),
                                                  )
                                                : SizedBox(
                                                    height: 0,
                                                  ),
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
                                          width: Get.width * 0.5,
                                          padding: const EdgeInsets.all(20.0),
                                          child: _idxBool[0]
                                              ? Container(
                                                  child: us.userList[0].userType == '학생'
                                                      ? Column(
                                                          children: [
                                                            Expanded(
                                                              child: SingleChildScrollView(
                                                                physics: const ClampingScrollPhysics(),
                                                                child: DataTable(
                                                                  showCheckboxColumn: false,
                                                                  sortColumnIndex: _currentSortColumn,
                                                                  sortAscending: _isAscending,
                                                                  headingRowColor: MaterialStateProperty.all(Colors.white),
                                                                  columns: [
                                                                    DataColumn(
                                                                        label: Text(
                                                                          '점수',
                                                                          style: f16w700,
                                                                        ),
                                                                        onSort: (columnIndex, _) {
                                                                          _currentSortColumn = columnIndex;
                                                                          scoreAsc = true;
                                                                          /// 내림차순 정렬
                                                                          if (_isAscending == true) {
                                                                            _isAscending = false;
                                                                            // reorderFlags(_allList, pairs);
                                                                            ts.myAnswer.sort((productA, productB) => productB['score'].compareTo(productA['score']));
                                                                            // ts.answerVisiual.value = _allList;
                                                                          } /// 오름차순 정렬
                                                                          else {
                                                                            _isAscending = true;
                                                                            // sortLists(_allList, pairs);
                                                                            ts.myAnswer.sort((productA, productB) => productA['score'].compareTo(productB['score']));
                                                                            // ts.answerVisiual.value = _allList;
                                                                          }
                                                                          setState(() {});
                                                                        }),
                                                                    DataColumn(
                                                                      label: Text(
                                                                        '시험명',
                                                                        style: f16w700,
                                                                      ),
                                                                    ),
                                                                    DataColumn(
                                                                      label: Text(
                                                                        '유형',
                                                                        style: f16w700,
                                                                      ),
                                                                    ),
                                                                    DataColumn(
                                                                        label: Text(
                                                                          '날짜',
                                                                          style: f16w700,
                                                                        ),
                                                                        onSort: (columnIndex, _) {
                                                                          _currentSortColumn = columnIndex;
                                                                          /// 내림차순 정렬
                                                                          if (_isAscending == true) {
                                                                            _isAscending = false;
                                                                            // createDateSortAsc(_allList, pairs);
                                                                            ts.myAnswer.sort((productA, productB) => productA['createDate'].compareTo(productB['createDate']));
                                                                            // ts.answerVisiual.value = _allList;
                                                                          }
                                                                          /// 오름차순 정렬
                                                                          else {
                                                                            _isAscending = true;
                                                                            //createDateSortAsc(ts.answerDate, _allList);
                                                                            // createDateSortDsc(_allList, pairs);
                                                                            ts.myAnswer.sort((productA, productB) => productB['createDate'].compareTo(productA['createDate']));
                                                                            // ts.answerVisiual.value = _allList;
                                                                          }
                                                                          setState(() {});
                                                                        }),
                                                                  ],
                                                                  ///
                                                                  rows: ts.myAnswer.map((item) {
                                                                    var index = ts.myAnswer.indexOf(item);
                                                                    return DataRow(cells: [
                                                                      DataCell(ConstrainedBox(
                                                                        constraints: BoxConstraints(
                                                                          maxWidth: 70,
                                                                          minWidth: 70,
                                                                        ),
                                                                        child: GestureDetector(
                                                                            onTap: () {
                                                                              if (item['scoreVisual'] == 'false') {
                                                                                showOnlyConfirmDialog(context, '답을 공개하지 않는 문제입니다.');
                                                                              } else {
                                                                                if (item['isIndividual'] == 'true') {
                                                                                  ts.individualAnswer.value = item['answer'];
                                                                                  if (item['category'] == 'sat') {
                                                                                    Get.toNamed(TestIndividualSat.id,
                                                                                        arguments: TestIndividualSat(
                                                                                          isChecked: 'true',
                                                                                          docId: item['answerDocid'],
                                                                                          myPage: true,
                                                                                        ));
                                                                                  } else {
                                                                                    Get.toNamed(TestIndividual.id,
                                                                                        arguments: TestIndividual(
                                                                                          isChecked: 'true',
                                                                                          docId: item['answerDocid'],
                                                                                          myPage: true,
                                                                                        ));
                                                                                  }
                                                                                } else {
                                                                                  ts.testDocId.value = item['docId'];
                                                                                  ts.answerDocId.value = '${item['answerDocid']}';
                                                                                  Get.toNamed(MyPageScreenStudent.id,
                                                                                      arguments: MyPageScreenStudent(
                                                                                        docId: item['answerDocid'],
                                                                                        teacherName: item['teacher'],
                                                                                        myPage: true,
                                                                                      ));
                                                                                }
                                                                              }
                                                                            },
                                                                            behavior: HitTestBehavior.opaque,
                                                                            child: Text('${item['score']}점', style: f16w700)),
                                                                      )),
                                                                      DataCell(GestureDetector(
                                                                        onTap: () {
                                                                          if (item['scoreVisual'] == 'false') {
                                                                            showOnlyConfirmDialog(context, '답을 공개하지 않는 문제입니다.');
                                                                          } else {
                                                                            if (item['isIndividual'] == 'true') {
                                                                              ts.individualAnswer.value = item['answer'];
                                                                              Get.toNamed(TestIndividual.id,
                                                                                  arguments: TestIndividual(
                                                                                    isChecked: 'true',
                                                                                    docId: item['answerDocid'],
                                                                                    myPage: true,
                                                                                  ));
                                                                            } else {
                                                                              ts.testDocId.value = item['docId'];
                                                                              ts.answerDocId.value = '${item['answerDocid']}';
                                                                              Get.toNamed(MyPageScreenStudent.id,
                                                                                  arguments: MyPageScreenStudent(
                                                                                    docId: item['answerDocid'],
                                                                                    teacherName: item['teacher'],
                                                                                    myPage: true,
                                                                                  ));
                                                                            }
                                                                          }
                                                                        },
                                                                        child: Text('${item['testTitle']}', style: f16w400),
                                                                      )),
                                                                      DataCell(ConstrainedBox(
                                                                        constraints: BoxConstraints(
                                                                          maxWidth: 70,
                                                                          minWidth: 70,
                                                                        ),
                                                                        child: GestureDetector(
                                                                          onTap: () {
                                                                            if (item['scoreVisual'] == 'false') {
                                                                              showOnlyConfirmDialog(context, '답을 공개하지 않는 문제입니다.');
                                                                            } else {
                                                                              if (item['isIndividual'] == 'true') {
                                                                                ts.individualAnswer.value = item['answer'];
                                                                                Get.toNamed(TestIndividual.id,
                                                                                    arguments: TestIndividual(
                                                                                      isChecked: 'true',
                                                                                      docId: item['answerDocid'],
                                                                                      myPage: true,
                                                                                    ));
                                                                              } else {
                                                                                ts.testDocId.value = item['docId'];
                                                                                ts.answerDocId.value = '${item['answerDocid']}';
                                                                                Get.toNamed(MyPageScreenStudent.id,
                                                                                    arguments: MyPageScreenStudent(
                                                                                      docId: item['answerDocid'],
                                                                                      teacherName: item['teacher'],
                                                                                      myPage: true,
                                                                                    ));
                                                                              }
                                                                            }
                                                                          },
                                                                          child:
                                                                              Text('${item['isIndividual'] == 'true' ? '개별' : '전체'}', style: f16w700),
                                                                        ),
                                                                      )),
                                                                      DataCell(ConstrainedBox(
                                                                          constraints: BoxConstraints(
                                                                            maxWidth: 200,
                                                                            minWidth: 200,
                                                                          ),
                                                                          child: GestureDetector(
                                                                            onTap: () {
                                                                              if (item['scoreVisual'] == 'false') {
                                                                                showOnlyConfirmDialog(context, '답을 공개하지 않는 문제입니다.');
                                                                              } else {
                                                                                if (item['isIndividual'] == 'true') {
                                                                                  ts.individualAnswer.value = item['answer'];
                                                                                  Get.toNamed(TestIndividual.id,
                                                                                      arguments: TestIndividual(
                                                                                        isChecked: 'true',
                                                                                        docId: item['answerDocid'],
                                                                                        myPage: true,
                                                                                      ));
                                                                                } else {
                                                                                  ts.testDocId.value = item['docId'];
                                                                                  ts.answerDocId.value = '${item['answerDocid']}';
                                                                                  Get.toNamed(MyPageScreenStudent.id,
                                                                                      arguments: MyPageScreenStudent(
                                                                                        docId: item['answerDocid'],
                                                                                        teacherName: item['teacher'],
                                                                                        myPage: true,
                                                                                      ));
                                                                                }
                                                                              }
                                                                            },
                                                                            behavior: HitTestBehavior.opaque,
                                                                            child: Text(
                                                                                '${DateFormat('y-MM-dd HH:mm').format(DateTime.parse('${item['createDate']}'))}',
                                                                                style: f14w400greyA),
                                                                          ))),
                                                                      // DataCell(Text(item['price'].toString()))
                                                                    ]);
                                                                  }).toList(),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
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
                                                                          '상태',
                                                                          style: f16w700,
                                                                        ),
                                                                        onSort: (columnIndex, _) {
                                                                          setState(() {
                                                                            _currentSortColumn = columnIndex;
                                                                            if (_isAscending == true) {
                                                                              _isAscending = false;
                                                                              _teacherAnswer.sort((productA, productB) =>
                                                                                  productB['state'].compareTo(productA['state']));
                                                                            } else {
                                                                              _isAscending = true;
                                                                              _teacherAnswer.sort((productA, productB) =>
                                                                                  productA['state'].compareTo(productB['state']));
                                                                            }
                                                                          });
                                                                        }),
                                                                    DataColumn(
                                                                      label: Text(
                                                                        '시험명',
                                                                        style: f16w700,
                                                                      ),
                                                                    ),
                                                                    DataColumn(
                                                                        label: Text('날짜', style: f16w700),
                                                                        onSort: (columnIndex, _) {
                                                                          setState(() {
                                                                            _currentSortColumn = columnIndex;
                                                                            if (_isAscending == true) {
                                                                              _isAscending = false;
                                                                              _teacherAnswer.sort((productA, productB) =>
                                                                                  productB['createDate'].compareTo(productA['createDate']));
                                                                            } else {
                                                                              _isAscending = true;
                                                                              _teacherAnswer.sort((productA, productB) =>
                                                                                  productA['createDate'].compareTo(productB['createDate']));
                                                                            }
                                                                          });
                                                                        }),
                                                                  ],
                                                                  rows: _teacherAnswer.map((item) {
                                                                    return DataRow(cells: [
                                                                      DataCell(ConstrainedBox(
                                                                        constraints: BoxConstraints(
                                                                          maxWidth: 70,
                                                                          minWidth: 70,
                                                                        ),
                                                                        child: GestureDetector(
                                                                          onTap: () async {
                                                                            Get.toNamed(MyPageScreenTeacher.id,
                                                                                arguments: MyPageScreenTeacher(
                                                                                  docId: '${item['docId']}',
                                                                                ));
                                                                          },
                                                                          behavior: HitTestBehavior.opaque,
                                                                          child: Text(
                                                                            '${item['state']}',
                                                                            style: f16w700,
                                                                          ),
                                                                        ),
                                                                      )),
                                                                      DataCell(ConstrainedBox(
                                                                        constraints: BoxConstraints(
                                                                          maxWidth: 150,
                                                                          minWidth: 150,
                                                                        ),
                                                                        child: GestureDetector(
                                                                            onTap: () {
                                                                              Get.toNamed(MyPageScreenTeacher.id,
                                                                                  arguments: MyPageScreenTeacher(
                                                                                    docId: '${item['docId']}',
                                                                                  ));
                                                                            },
                                                                            behavior: HitTestBehavior.opaque,
                                                                            child: Text('${item['pdfCategory']}', style: f16w700)),
                                                                      )),
                                                                      DataCell(ConstrainedBox(
                                                                          constraints: BoxConstraints(
                                                                            maxWidth: 200,
                                                                            minWidth: 200,
                                                                          ),
                                                                          child: GestureDetector(
                                                                            onTap: () async {
                                                                              Get.toNamed(MyPageScreenTeacher.id,
                                                                                  arguments: MyPageScreenTeacher(
                                                                                    docId: '${item['docId']}',
                                                                                  ));
                                                                            },
                                                                            behavior: HitTestBehavior.opaque,
                                                                            child: Text(
                                                                                '${DateFormat('y-MM-dd HH:mm').format(DateTime.parse('${item['createDate']}'))}',
                                                                                style: f16w700),
                                                                          ))),
                                                                    ]);
                                                                  }).toList(),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                )
                                              : _idxBool[1]
                                                  ?  Container(
                                            child: Column(
                                              mainAxisAlignment:  _satAL.length == 0 ? MainAxisAlignment.center : MainAxisAlignment.start,
                                              children: [
                                                us.userList[0].userType=='학생'?
                                                /// 학생 sat페이지
                                                _satAL.length == 0 ?
                                                Center(
                                                  child: Text('조회 결과가 없습니다',style: f24w700,),
                                                )
                                                    : Expanded(
                                                  child: SingleChildScrollView(
                                                    physics: const ClampingScrollPhysics(),
                                                    child: DataTable(
                                                      showCheckboxColumn: false,
                                                      sortColumnIndex: _currentSatColumn,
                                                      sortAscending: _isSATAscending,
                                                      headingRowColor: MaterialStateProperty.all(Colors.white),
                                                      columns: [
                                                        DataColumn(
                                                          label: Text(
                                                            '상태',
                                                            style: f16w700,
                                                          ),
                                                        ),
                                                        // DataColumn(
                                                        //   label: Text(
                                                        //     '수학',
                                                        //     style: f16w700,
                                                        //   ),
                                                        // ),
                                                        DataColumn(
                                                          label: Text(
                                                            'SAT 시험명',
                                                            style: f16w700,
                                                          ),
                                                        ),
                                                        DataColumn(label: Text('날짜', style: f16w700), onSort: (columnIndex, _) {
                                                          _isSATAscending = !_isSATAscending;
                                                          if(_isSATAscending) {
                                                            _satAL.sort((a, b) => (a['createDate']).compareTo(b['createDate']));
                                                          }else{
                                                            _satAL.sort((a, b) => (b['createDate']).compareTo(a['createDate']));
                                                          }
                                                          setState(() {

                                                          });
                                                        }),
                                                      ],
                                                      rows: _satAL.map((item) {
                                                        return DataRow(cells: [
                                                          DataCell(ConstrainedBox(
                                                            constraints: BoxConstraints(
                                                              maxWidth: 70,
                                                              minWidth: 70,
                                                            ),
                                                            child: GestureDetector(
                                                              onTap: () async {
                                                                ss.satAnswerDocId.value = item['docId'];
                                                                Get.toNamed(ResultPdfScreen.id);
                                                              },
                                                              behavior: HitTestBehavior.opaque,
                                                              child: Text(
                                                                '${item['status'] == '삭제' ? '삭제' : '완료'}',
                                                                style: f16w700,
                                                              ),
                                                            ),
                                                          )),
                                                          // DataCell(ConstrainedBox(
                                                          //   constraints: BoxConstraints(
                                                          //     maxWidth: 70,
                                                          //     minWidth: 70,
                                                          //   ),
                                                          //   child: GestureDetector(
                                                          //     onTap: () async {
                                                          //       ss.satAnswerDocId.value = item['docId'];
                                                          //       Get.toNamed(ResultPdfScreen.id);
                                                          //     },
                                                          //     behavior: HitTestBehavior.opaque,
                                                          //     child: Text(
                                                          //       '${item['nickName']}',
                                                          //       style: f16w700,
                                                          //     ),
                                                          //   ),
                                                          // )),
                                                          DataCell(ConstrainedBox(
                                                            constraints: BoxConstraints(
                                                              maxWidth: 150,
                                                              minWidth: 150,
                                                            ),
                                                            child: GestureDetector(
                                                                onTap: () {
                                                                  ss.satAnswerDocId.value = item['docId'];
                                                                  Get.toNamed(ResultPdfScreen.id);
                                                                },
                                                                behavior: HitTestBehavior.opaque,
                                                                child: Text('${item['mainTitle']}', style: f16w700)),
                                                          )),
                                                          DataCell(ConstrainedBox(
                                                              constraints: BoxConstraints(
                                                                maxWidth: 200,
                                                                minWidth: 200,
                                                              ),
                                                              child: GestureDetector(
                                                                onTap: () async {
                                                                  ss.satAnswerDocId.value = item['docId'];
                                                                  Get.toNamed(ResultPdfScreen.id);
                                                                },
                                                                behavior: HitTestBehavior.opaque,
                                                                child: Text(
                                                                    '${DateFormat('y-MM-dd HH:mm').format(DateTime.parse('${item['createDate']}'))}',
                                                                    style: f16w700),
                                                              ))),
                                                        ]);
                                                      }).toList(),
                                                    ),
                                                  ),
                                                )
                                                /// 선생 sat페이지
                                                    : nextPage==1
                                                    ? Expanded(
                                                  child: SingleChildScrollView(
                                                    physics: const ClampingScrollPhysics(),
                                                    child:  Container(
                                                      width: Get.width * 0.8,
                                                      padding: const EdgeInsets.symmetric(horizontal: 30),
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              GestureDetector(
                                                                  onTap: (){
                                                                    nextPage=0;
                                                                    setState(() {
                                                                    });
                                                                  },
                                                                  child: Icon(Icons.arrow_back_ios_new)),
                                                              Spacer(),
                                                              Center(
                                                                child: Text(
                                                                  '테스트 확인',
                                                                  style: f32w700,
                                                                ),
                                                              ),
                                                              Spacer(),
                                                              SizedBox(width: 50),
                                                            ],
                                                          ),
                                                          Container(
                                                            decoration: BoxDecoration(
                                                              color: const Color(0xffffffff),
                                                              borderRadius: BorderRadius.circular(20.0),
                                                            ),
                                                            width: Get.width * 0.44,
                                                            padding: const EdgeInsets.all(20.0),
                                                            child: Container(
                                                              child: Column(
                                                                children: [
                                                                  SingleChildScrollView(
                                                                    physics: const ClampingScrollPhysics(),
                                                                    child: DataTable(
                                                                      sortColumnIndex: _currentSortColumn,
                                                                      sortAscending: _isAscending,
                                                                      headingRowColor: MaterialStateProperty.all(Colors.white),
                                                                      columns: [
                                                                        DataColumn(
                                                                            label: Text(
                                                                              '점수',
                                                                              style: f16w700,
                                                                            ),
                                                                            onSort: (columnIndex, _) {
                                                                              setState(() {
                                                                                _currentSortColumn = columnIndex;
                                                                                if (_isAscending == true) {
                                                                                  _isAscending = false;
                                                                                  _testStudentList.sort((productA, productB)
                                                                                  => productB['score'].compareTo(productA['score']));
                                                                                } else {
                                                                                  _isAscending = true;
                                                                                  _testStudentList.sort((productA,
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
                                                                        ),
                                                                        DataColumn(
                                                                            label: Text('날짜',
                                                                                style: f16w700),
                                                                            onSort: (columnIndex, _) {
                                                                              setState(() {
                                                                                _currentSortColumn = columnIndex;
                                                                                if (_isAscending == true) {
                                                                                  _isAscending = false;
                                                                                  _testStudentList.sort((productA, productB) => productB['createDate'].compareTo(productA['createDate']));
                                                                                } else {
                                                                                  _isAscending = true;
                                                                                  _testStudentList.sort((productA, productB) => productA['createDate'].compareTo(productB['createDate']));
                                                                                }
                                                                              });
                                                                            }),
                                                                      ],
                                                                      rows:
                                                                      _testStudentList.map((item) {
                                                                        return DataRow(cells: [
                                                                          DataCell(ConstrainedBox(
                                                                            constraints: BoxConstraints(
                                                                              maxWidth: 70,
                                                                              minWidth: 70,
                                                                            ),
                                                                            child: GestureDetector(
                                                                                onTap: () {
                                                                                  ss.satAnswerDocId.value = teacherDocId;
                                                                                  // ss.satAnswerDocId.value = _testStudentList[index]['docId'];
                                                                                  // print('teacher docId :${ss.satAnswerDocId.value}');
                                                                                  ss.teacherSatAnswerDocId.value = item['docId'];
                                                                                  ss.isTeacher.value = 'true';
                                                                                  Get.toNamed(ResultPdfScreen.id);
                                                                                  setState(() {});
                                                                                },
                                                                                behavior: HitTestBehavior.opaque,
                                                                                child: Text(
                                                                                    '${item['score']}점',
                                                                                    style: (GetPlatform.isWeb && (Get.width * 0.2 <= 171))
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
                                                                                ss.satAnswerDocId.value = teacherDocId;
                                                                                // ss.satAnswerDocId.value = _testStudentList[index]['docId'];
                                                                                // print('teacher docId :${ss.satAnswerDocId.value}');
                                                                                ss.teacherSatAnswerDocId.value = item['docId'];
                                                                                ss.isTeacher.value = 'true';
                                                                                Get.toNamed(ResultPdfScreen.id);
                                                                                setState(() {});
                                                                              },
                                                                              behavior: HitTestBehavior.opaque,
                                                                              child: Text(
                                                                                '${item['id']}',
                                                                                style: (GetPlatform.isWeb &&
                                                                                    (Get.width * 0.2 <= 171))
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
                                                                                  ss.satAnswerDocId.value = teacherDocId;
                                                                                  // ss.satAnswerDocId.value = _testStudentList[index]['docId'];
                                                                                  // print('teacher docId :${ss.satAnswerDocId.value}');
                                                                                  ss.teacherSatAnswerDocId.value = item['docId'];
                                                                                  ss.isTeacher.value = 'true';
                                                                                  Get.toNamed(ResultPdfScreen.id);
                                                                                  setState(() {});
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
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                    :_satL.length == 0 ?
                                                Center(
                                                  child: Text('조회 결과가 없습니다',style: f24w700,),
                                                )
                                                    : Expanded(
                                                  child: SingleChildScrollView(
                                                    physics: const ClampingScrollPhysics(),
                                                    child: DataTable(
                                                      showCheckboxColumn: false,
                                                      sortColumnIndex: _currentSatColumn,
                                                      sortAscending: _isSATAscending,
                                                      headingRowColor: MaterialStateProperty.all(Colors.white),
                                                      columns: [
                                                        DataColumn(
                                                          label: Text(
                                                            '상태',
                                                            style: f16w700,
                                                          ),
                                                        ),
                                                        DataColumn(
                                                          label: Text(
                                                            'SAT 시험명',
                                                            style: f16w700,
                                                          ),
                                                        ),
                                                        DataColumn(label: Text('날짜', style: f16w700), onSort: (columnIndex, _) {
                                                          _isSATAscending = !_isSATAscending;
                                                          if(_isSATAscending) {
                                                            _satL.sort((a, b) => (a['createDate']).compareTo(b['createDate']));
                                                          }else{
                                                            _satL.sort((a, b) => (b['createDate']).compareTo(a['createDate']));
                                                          }
                                                          setState(() {

                                                          });
                                                        }),
                                                      ],
                                                      rows: _satL.map((item) {
                                                        return DataRow(cells: [
                                                          DataCell(ConstrainedBox(
                                                            constraints: BoxConstraints(
                                                              maxWidth: 70,
                                                              minWidth: 70,
                                                            ),
                                                            child: GestureDetector(
                                                              onTap: () async {
                                                                teacherDocId = item['docId'];
                                                                await _firebaseSatTestStudentGet();
                                                                nextPage =1;
                                                                setState(() {});
                                                              },
                                                              behavior: HitTestBehavior.opaque,
                                                              child: Text(
                                                                '${item['status'] == '0' ? '임시' : '완료'}',
                                                                style: f16w700,
                                                              ),
                                                            ),
                                                          )),
                                                          DataCell(ConstrainedBox(
                                                            constraints: BoxConstraints(
                                                              maxWidth: 150,
                                                              minWidth: 150,
                                                            ),
                                                            child: GestureDetector(
                                                                onTap: () async{
                                                                  teacherDocId = item['docId'];
                                                                  await _firebaseSatTestStudentGet();
                                                                  nextPage =1;
                                                                  setState(() {});
                                                                },
                                                                behavior: HitTestBehavior.opaque,
                                                                child: Text('${item['mainTitle']}', style: f16w700)),
                                                          )),
                                                          DataCell(ConstrainedBox(
                                                              constraints: BoxConstraints(
                                                                maxWidth: 200,
                                                                minWidth: 200,
                                                              ),
                                                              child: GestureDetector(
                                                                onTap: () async {
                                                                  teacherDocId = item['docId'];
                                                                  await _firebaseSatTestStudentGet();
                                                                  nextPage =1;
                                                                  setState(() {});
                                                                },
                                                                behavior: HitTestBehavior.opaque,
                                                                child: Text(
                                                                    '${DateFormat('y-MM-dd HH:mm').format(DateTime.parse('${item['createDate']}'))}',
                                                                    style: f16w700),
                                                              ))),
                                                        ]);
                                                      }).toList(),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                                  : RefreshIndicator(
                                            key: _refreshIndicatorKey,
                                            triggerMode: RefreshIndicatorTriggerMode.anywhere,
                                            onRefresh: () async {
                                              await _refresh();
                                            },
                                            child: ListView.builder(
                                                shrinkWrap: true,
                                                itemCount: _qnaL.length,
                                                physics: const ClampingScrollPhysics(),
                                                itemBuilder: (_, idx) {
                                                  return Padding(
                                                    padding: const EdgeInsets.all(8.0),
                                                    child: Column(
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            // Get.toNamed(StoryWriteScreen.id,
                                                            //     arguments: StoryWriteScreen(
                                                            //       whichScreen: 'qna',
                                                            //       state: 'edit',
                                                            //     ));
                                                            // print(
                                                            //     'aaaaa :: ${_qnaL[idx]['docId']}');
                                                            us.qnaDocId.value = '${_qnaL[idx]['docId']}';
                                                            setState(() {});
                                                            Get.toNamed(QnaDetailScreen.id,
                                                                arguments: QnaDetailScreen(
                                                                  docId: '${_qnaL[idx]['docId']}',
                                                                  idx: idx,
                                                                ))!
                                                                .then((value) {
                                                              _refreshIndicatorKey.currentState?.show();
                                                            });
                                                          },
                                                          child: Row(
                                                            mainAxisAlignment: MainAxisAlignment.start,
                                                            children: [
                                                              Text(
                                                                '${_qnaL[idx]['title']}',
                                                                style: f16w700,
                                                              ),
                                                              const SizedBox(
                                                                width: 12,
                                                              ),
                                                              Text(
                                                                '${_qnaL[idx]['state']}',
                                                                style: f16w400greyA,
                                                              ),
                                                              Spacer(),
                                                              Text(
                                                                '${DateFormat('y-MM-dd HH:mm').format(DateTime.parse('${_qnaL[idx]['createDate']}'))}',
                                                                style: f16w400greyA,
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                        Divider(
                                                          color: Color(0xffdadada),
                                                        ),
                                                        const SizedBox(
                                                          height: 12,
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        Footer(),
                      ],
                    ),
                  ),
      ),
    );
  }

  onGoBack(dynamic value) async {
    setState(() {
      _isLoading = true;
    });
    _getQnA(RefreshManager.getCookie('id'));

    setState(() {
      _isLoading = false;
      // Navigator.pop(context);
    });
  }

  Future<void> getAnsDocId(item, TestState ts, UserState us) async {
    CollectionReference likeRef = FirebaseFirestore.instance.collection('answer');
    QuerySnapshot snapshot =
        await likeRef.where('teacher', isEqualTo: item['teacher']).where('pdfCategory', isNotEqualTo: '${item['testTitle']}').get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    List a = allData;

    ts.testDocId.value = item['docId'];
    ts.answerDocId.value = '${a[0]['docId']}';
    Get.to(() => TestCheckScreen(teacherName: '${us.userList[0].id}', docId: '${ts.answerDocId.value}', myPage: true));
  }

  Future<List> getAnsTeacher(UserState us) async {
    final ts = Get.put(TestState());
    CollectionReference likeRef = FirebaseFirestore.instance.collection('answer');
    QuerySnapshot snapshot = await likeRef.orderBy('createDate', descending: true).where('teacher', isEqualTo: '${us.userList[0].id}').get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    List a = allData;
    return a;
  }

  Future<void> _getQnA(String userId) async {
    final us = Get.put(UserState());
    CollectionReference ref = FirebaseFirestore.instance.collection('qna');
    QuerySnapshot snapshot = await ref.orderBy('createDate', descending: true).where('id', isEqualTo: userId).get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    _qnaL = allData;
  }

  Future<void> _refresh() async {
    Future.delayed(Duration.zero, () async {
      final us = Get.put(UserState());
      await _getQnA('${RefreshManager.getCookie('id')}');
      setState(() {});
    });
  }

  void sortLists(List flags, List pairs) {
    // 값과 위치를 함께 묶어서 리스트로 만듦
    final ts = Get.put(TestState());
    // List<Map<String, dynamic>> pairs = values.asMap().entries.map((entry) => {'value': entry.value, 'flag': flags[entry.key]}).toList();

    // 값에 따라 오름차순으로 정렬
    pairs.sort((a, b) => a['value'].compareTo(b['value']));

    // 정렬된 값의 리스트와 위치 정보를 담은 리스트를 만듦
    List sortedValues = pairs.map((pair) => pair['value']).toList();
    List sortedFlags = pairs.map((pair) => pair['flag']).toList();

    // 입력값을 수정
    // values.clear();
    flags.clear();

    // values.addAll(sortedValues);
    flags.addAll(sortedFlags);
    setState(() {});
  }

  void reorderFlags(List flags, List pairs) {
    // 값과 위치를 함께 묶어서 리스트로 만듦
    final ts = Get.put(TestState());

    // 값에 따라 내림차순으로 정렬
    pairs.sort((a, b) => b['value'].compareTo(a['value']));
    // 정렬된 값의 리스트와 위치 정보를 담은 리스트를 만듦
    List sortedValues = pairs.map((pair) => pair['value']).toList();
    List sortedFlags = pairs.map((pair) => pair['flag']).toList();

    // 재정렬된 위치 정보로 입력값을 수정
    // values.clear();
    flags.clear();

    // values.addAll(sortedValues);
    flags.addAll(sortedFlags);

    setState(() {});
  }

  // 오름차순
  void createDateSortAsc(List flags, List pairs) {
    final ts = Get.put(TestState());
    // 값과 위치를 함께 묶어서 리스트로 만듦
    // List<Map<String, dynamic>> pairs = values.asMap().entries.map((entry) => {'createDate': entry.value, 'flag': flags[entry.key]}).toList();
    // 값에 따라 오름차순으로 정렬
    pairs.sort((a, b) => a['createDate'].compareTo(b['createDate']));
    // 정렬된 값의 리스트와 위치 정보를 담은 리스트를 만듦
    List sortedValues = pairs.map((pair) => pair['createDate']).toList();
    List sortedFlags = pairs.map((pair) => pair['flag']).toList();

    // 재정렬된 위치 정보로 입력값을 수정
    // values.clear();
    flags.clear();
    // values.addAll(sortedValues);
    flags.addAll(sortedFlags);

    setState(() {});
  }

  // 내림차순
  void createDateSortDsc(List flags, List pairs) {
    // 값과 위치를 함께 묶어서 리스트로 만듦
    final ts = Get.put(TestState());
    // List<Map<String, dynamic>> pairs = values.asMap().entries.map((entry) => {'createDate': entry.value, 'flag': flags[entry.key]}).toList();
    // print('dsdad ${pairs}');
    // 값에 따라 내림차순으로 정렬
    pairs.sort((a, b) => b['createDate'].compareTo(a['createDate']));

    // 정렬된 값의 리스트와 위치 정보를 담은 리스트를 만듦
    List sortedFlags = pairs.map((pair) => pair['flag']).toList();

    // 재정렬된 위치 정보로 입력값을 수정
    flags.clear();

    flags.addAll(sortedFlags);
    setState(() {});
  }

  ///선생님 sat
  Future<void> _firebaseSATGet() async{
    final us = Get.put(UserState());
    CollectionReference ref = FirebaseFirestore.instance.collection('sat');
    QuerySnapshot snapshot = await ref.orderBy('createDate', descending: true).where('id', isEqualTo: '${us.userList[0].id}').get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    _satL = allData;
  }

  ///학생 sat
  Future<void> _firebaseSatAnswerGet() async{
    final us = Get.put(UserState());
    CollectionReference ref = FirebaseFirestore.instance.collection('sat');
    QuerySnapshot snapshot = await ref.orderBy('createDate', descending: true).where('studentList', arrayContains: '${us.userList[0].id}').get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    _satAL = allData;
  }

  ///선생이 마이페이지에서 sat문제 클릭시 시험을 본 학생들 가져오는 함수
  Future<void> _firebaseSatTestStudentGet() async{
    final us = Get.put(UserState());
      CollectionReference ref = FirebaseFirestore.instance.collection('satAnswer');
      QuerySnapshot snapshot = await ref
          .orderBy('createDate', descending: true)
          .where('answerDocId', isEqualTo: '${teacherDocId}').where('status',isEqualTo: '4').get();
      final allData = snapshot.docs.map((doc) => doc.data()).toList();
      _testStudentList = allData;
  }
}
