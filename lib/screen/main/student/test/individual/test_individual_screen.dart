import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/provider/test_state.dart';
import 'package:academy/util/colors.dart';
import 'package:academy/util/loading.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../../firebase/firebase_answer.dart';
import '../../../../../firebase/firebase_test.dart';
import '../../../../../provider/user_state.dart';
import '../../../../../util/font.dart';
import '../../../../login/login_main_screen.dart';

class TestIndividual extends StatefulWidget {
  final String docId;
  final String isChecked;

  const TestIndividual({Key? key, required this.docId, this.isChecked: ''})
      : super(key: key);

  @override
  State<TestIndividual> createState() => _TestIndividualState();
}

class _TestIndividualState extends State<TestIndividual> {
  final controller = PageController();
  int _pageIndex = 0;
  int correct = 0;
  List<String> number = ['1', '2', '3', '4', '5'];
  List<String> _answer = [];
  List _finalAnswer = [];
  bool _isLoading = true;
  List<TextEditingController> _controller = [];

  @override
  void initState() {
    final ts = Get.put(TestState());
    Future.delayed(Duration.zero, () async {
      await firebaseIndividualGet(widget.docId);
      _answer = List.generate(
          ts.individualTestGet[0]['answer'].length, (index) => '');
      _controller = List.generate(ts.individualTestGet[0]['answer'].length,
          (i) => TextEditingController());
      print('answer : ${_answer}');

      if(widget.isChecked == 'true'){
        _score();
      }else{

        ts.individualAnswer.value = List.generate(
            ts.individualTestGet[0]['answer'].length, (index) => '');
      }
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  @override
  Widget build(BuildContext context) {
    final ts = Get.put(TestState());
    final us = Get.put(UserState());
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: _isLoading
          ? LoadingBodyScreen()
          : Scaffold(
              appBar: AppBar(
                leading: Container(),
                backgroundColor: Colors.white,
                title: Column(
                  children: [
                    Text(
                      widget.isChecked == 'true' ? '${ts.individualTestGet[0]['teacher']} 선생님(총점 : ${((correct/ts.individualTestGet[0]['answer'].length)* 100).ceil()}점)' : '${ts.individualTestGet[0]['teacher']} 선생님',
                      style: f16w700,
                    ),
                    Text(
                      '${DateFormat('y-MM-dd').format(DateTime.now())}',
                      style: f16w400greyA,
                    ),
                  ],
                ),
                centerTitle: true,
                elevation: 0,
                actions: [
                  TextButton(
                      onPressed: () {
                        Get.back();
                      },
                      child: Text(
                        '나가기',
                        style: f16w700primary,
                      ))
                ],
              ),
              backgroundColor: Colors.white,
              body: PageView.builder(
                controller: controller,
                onPageChanged: (value) {
                  setState(() {
                    _pageIndex = value;
                  });
                },
                itemCount: ts.individualTestGet[0]['answer'].length,
                itemBuilder: (context, index) {
                  return SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(top: 32, right: 24, left: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                              '문제\t${index + 1}/${ts.individualTestGet[0]['answer'].length}',
                              style: f16w700greyA,
                            ),
                          ),
                          SizedBox(
                            height: 8,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: LinearPercentIndicator(
                                  lineHeight: 10,
                                  percent: ((index + 1) /
                                      ts.individualTestGet[0]['answer'].length),
                                  animation: true,
                                  barRadius: Radius.circular(10),
                                  backgroundColor: cameraBackColor,
                                  progressColor: nowColor,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            '문제 ${index + 1}번. ${ts.individualTestGet[0]['individualTitle'][index]}',
                            style: f20w500,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          ts.individualTestGet[0]['images'].length == 0 ? Container(): !ts.individualTestGet[0]['images'][index]
                                  .contains('no')
                              ? ExtendedImage.network(
                                  // 'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/teacher%2F1234%2F6EhFcIYaHuOmpsH9H87N%2F2023-02-08%2013%3A32%3A44.647799?alt=media&token=947e3a38-3426-4605-85df-ad874a4c0b9a',
                                  'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/teacher%2F${ts.individualTestGet[0]['teacher']}%2F${ts.individualTestGet[0]['docId']}%2F${ts.individualTestGet[0]['images'][index]}?alt=media',
                                  fit: BoxFit.fill,
                                  width: Get.width,
                                  cache: true,
                                  enableLoadState: false,
                                )
                              : Container(),
                          ts.individualTestGet[0]['images'].length == 0 ? Container(): ts.individualTestGet[0]['images'][index] != ''
                              ? SizedBox(
                                  height: 20,
                                )
                              : Container(),
                          Text(
                            '${ts.individualTestGet[0]['individualBody'][index]}',
                            style: f20w500,
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            widget.isChecked == 'true'
                                ? '내가 입력한 답 : ${ts.individualAnswer[index]}'
                                : '정답',
                            style: f16w700,
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          !isNumeric(ts.individualTestGet[0]['answer'][index])
                              ? TextField(
                                  enabled:
                                      widget.isChecked == 'true' ? false : true,
                                  controller: _controller[index],
                                  onChanged: (v) {
                                    _answer[index] = _controller[index].text;
                                  },
                                  style: f16w700,
                                  minLines: 5,
                                  maxLines: null,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    filled: true,
                                    fillColor: Color(0xffEBEBEB),
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 14),
                                    border: OutlineInputBorder(
                                        borderSide: BorderSide.none,
                                        borderRadius: BorderRadius.circular(8)),
                                    hintText: widget.isChecked == 'true'
                                        ? '정답 : ${ts.individualTestGet[0]['answer'][index]}'
                                        : '내용을 입력해주세요',
                                    hintStyle: widget.isChecked == 'true'
                                        ? f24w500
                                        : f16w400grey8,
                                  ),
                                )
                              : Container(
                                  height: 60,
                                  child: ListView(
                                    scrollDirection: Axis.horizontal,
                                    children: List.generate(
                                        number.length,
                                        (i) => Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    TextButton(
                                                        onPressed: widget.isChecked ==
                                                                'true'
                                                            ? null
                                                            : () {
                                                                // as.choiceList
                                                                //     .value[widget.idx] =
                                                                // '${i + 1}';
                                                                _answer[index] =
                                                                    '${i + 1}';
                                                                setState(() {});
                                                              },
                                                        style: TextButton
                                                            .styleFrom(
                                                          shape: RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          20)),
                                                          side: BorderSide(
                                                              width: 1,
                                                              color:
                                                                  Colors.grey),
                                                          minimumSize:
                                                              Size(52, 52),
                                                          foregroundColor:
                                                              Colors.black,
                                                          backgroundColor: _answer[index] ==
                                                                      number[
                                                                          i] ||
                                                                  (ts.individualAnswer[index] == ts.individualTestGet[0]['answer'][index]) &&
                                                                      (ts.individualAnswer[index] ==
                                                                          number[
                                                                              i]) &&
                                                                      widget.isChecked ==
                                                                          'true'
                                                              ? nowColor
                                                              : (ts.individualAnswer[index] !=
                                                                          ts.individualTestGet[0]['answer']
                                                                              [
                                                                              index]) &&
                                                                      (ts.individualTestGet[0]['answer']
                                                                              [index] ==
                                                                          number[i]) &&
                                                                      widget.isChecked == 'true'
                                                                  ? Colors.red
                                                                  : Colors.white,
                                                          padding:
                                                              EdgeInsets.only(
                                                                  right: 12,
                                                                  left: 12),
                                                          tapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                        ),
                                                        child: Text('${i + 1}',
                                                            style: _answer[index] ==
                                                                        number[
                                                                            i] ||
                                                                    (ts.individualAnswer[index] == ts.individualTestGet[0]['answer'][index]) &&
                                                                        (ts.individualAnswer[index] ==
                                                                            number[
                                                                                i]) &&
                                                                        widget.isChecked ==
                                                                            'true' ||
                                                                    (ts.individualAnswer[index] != ts.individualTestGet[0]['answer'][index]) &&
                                                                        (ts.individualTestGet[0]['answer'][index] ==
                                                                            number[i]) &&
                                                                        widget.isChecked == 'true'
                                                                ? f16Whitew700
                                                                : f16w700)),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )),
                                  )),
                        ],
                      ),
                    ),
                  );
                },
              ),
              bottomNavigationBar: Padding(
                padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                          onTap: () {
                            controller.previousPage(
                              duration: Duration(milliseconds: 200),
                              curve: Curves.linear,
                            );
                          },
                          child: _pageIndex != 0
                              ? Text(
                                  '이전',
                                  style: f18w700greyA,
                                )
                              : Text('')),
                      GestureDetector(
                          onTap: () {
                            if (widget.isChecked != 'true') {
                              if (_pageIndex ==
                                  ts.individualTestGet[0]['answer'].length -
                                      1) {
                                showComponentDialog(context, '제출하시겠습니까?', () async {
                                  ts.answer.value = _answer;
                                  await firebaseIndividualTestUpload();
                                  Get.back();
                                  showConfirmTapDialog(context,
                                      '수고하셨습니다\n\n작성하신 답안이 정상적으로 제출 되었습니다', () {
                                    Get.offAll(() => BottomNavigator());
                                  });
                                });
                              } else {
                                controller.animateToPage(
                                    controller.page!.toInt() + 1,
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.linear);
                              }
                            } else {
                              if (_pageIndex ==
                                  ts.individualTestGet[0]['answer'].length -
                                      1) {
                                Get.back();
                              } else {
                                controller.animateToPage(
                                    controller.page!.toInt() + 1,
                                    duration: Duration(milliseconds: 200),
                                    curve: Curves.linear);
                              }
                            }
                          },
                          child: _pageIndex ==
                                  ts.individualTestGet[0]['answer'].length - 1
                              ? widget.isChecked != 'true'
                                  ? Text(
                                      '제출',
                                      style: f18w700primary,
                                    )
                                  : Text(
                                      '완료',
                                      style: f18w700primary,
                                    )
                              : Text(
                                  '다음',
                                  style: f18w700primary,
                                ))
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  void _score() {
    final ts = Get.put(TestState());

    for (int i = 0; i < ts.individualTestGet[0]['answer'].length; i++) {
      if (ts.individualAnswer[i] == ts.individualTestGet[0]['answer'][i]) {
        print('yes');
        correct++;
      }
    }
  }
}
