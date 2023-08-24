import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/provider/test_state.dart';
import 'package:academy/screen/main/main_screen.dart';
import 'package:academy/screen/main/student/test/test_check_screen.dart';
import 'package:academy/util/colors.dart';
import 'package:academy/util/loading.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../../firebase/firebase_answer.dart';
import '../../../../../firebase/firebase_test.dart';
import '../../../../../provider/answer_state.dart';
import '../../../../../provider/user_state.dart';
import '../../../../../util/count_down.dart';
import '../../../../../util/font/font.dart';
import '../../../../login/login_main_screen.dart';

class TestIndividual extends StatefulWidget {
  static final String id = '/test_ind';
  final String? docId;
  final String? isChecked;
  final bool? myPage;

  const TestIndividual({Key? key, this.docId, this.isChecked: '', this.myPage})
      : super(key: key);

  @override
  State<TestIndividual> createState() => _TestIndividualState();
}

class _TestIndividualState extends State<TestIndividual>
    with TickerProviderStateMixin {
  final controller = PageController();
  int _pageIndex = 0;
  int correct = 0;
  List<String> number = ['1', '2', '3', '4', '5'];
  List<String> _answer = [];
  String _docId = '';
  List _finalAnswer = [];
  bool _isLoading = true;
  bool _isPlaying = false;
  AudioPlayer _player = AudioPlayer();
  Animation? _animation;
  Function() animationListener = () {};

  List<TextEditingController> _controller = [];
  TextEditingController _numberCon = TextEditingController();
  late AnimationController _timeController;
  @override
  void initState() {
    final ts = Get.put(TestState());
    final as = Get.put(AnswerState());

    Future.delayed(Duration.zero, () async {
      final args = ModalRoute.of(context)!.settings.arguments as TestIndividual;
      await firebaseIndividualGet(args.docId!);
      _answer = List.generate(
          ts.individualTestGet[0]['answer'].length, (index) => '');
      _controller = List.generate(ts.individualTestGet[0]['answer'].length,
          (i) => TextEditingController());

      if (args.isChecked == 'true') {
        _score();
      } else {
        ts.individualAnswer.value = List.generate(
            ts.individualTestGet[0]['answer'].length, (index) => '');
      }

      _timeController = AnimationController(
          vsync: this,
          duration: Duration(
              seconds: as.temp2.value != '' ? int.parse(as.temp2.value) : 0));

      _docId = '${args.docId}';

      _timeController.addListener(() async {
        if (as.temp2.value != '') {
          if (1 == _timeController.value) {
            ts.answer.value = _answer;
            await firebaseIndividualTestUpload(_docId);
            showConfirmTapDialog(context, '수고하셨습니다\n\n작성하신 답안이 정상적으로 제출 되었습니다',
                () {
              Get.offAllNamed(MainScreen.id);
            });
          }
        }
      });

      (as.temp2.value == '' || as.temp2.value == '0')
          ? _timeController.stop()
          : _timeController.forward();
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
  void dispose() {
    _numberCon.dispose();
    _player.dispose();
    _timeController.stop();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as TestIndividual;
    AnimationController _animationController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    final ts = Get.put(TestState());
    // final us = Get.put(UserState());
    final as = Get.put(AnswerState());

    return WillPopScope(
      onWillPop: () {
        return Future(() {
          if (args.myPage!) {
            Get.back();
          } else {
            Get.offAllNamed(MainScreen.id);
          }
          return true;
        });
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: _isLoading
            ? LoadingBodyScreen()
            : Scaffold(
                appBar: AppBar(
                  leading: Container(),
                  backgroundColor: Colors.white,
                  title: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          args.myPage == false
                              ? Center(
                                  child: (as.temp2.value == '' ||
                                          as.temp2.value == '')
                                      ? Text(
                                          '시간제한 없음',
                                          style: f20w500,
                                        )
                                      : Countdown(
                                          animation: StepTween(
                                            begin: as.temp2.value != ''
                                                ? int.parse(as.temp2.value)
                                                : 0,
                                            end: 0,
                                          ).animate(_timeController),
                                        ),
                                )
                              : SizedBox(
                                  width: 0,
                                ),
                          SizedBox(
                            width: args.myPage == false ? 8 : 0,
                          ),
                          Text(
                            args.isChecked == 'true'
                                ? '${ts.individualTestGet[0]['nickName']} 선생님(총점 : ${((correct / ts.individualTestGet[0]['answer'].length) * 100).ceil()}점)'
                                : '${ts.individualTestGet[0]['nickName']} 선생님',
                            style: f16w700,
                          ),
                        ],
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
                          showComponentDialog(
                              context,
                              args.myPage == true
                                  ? "종료하시겠습니까?"
                                  : '시험을 종료하시겠습니까?', () {
                            Get.back();
                            if (args.myPage == true) {
                              Get.back();
                            } else {
                              // Get.offAll(BottomNavigator());
                              Get.offAllNamed(MainScreen.id);
                            }
                          });
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
                  physics: const NeverScrollableScrollPhysics(),
                  onPageChanged: (value) {
                    setState(() {
                      _pageIndex = value;
                    });
                  },
                  itemCount: ts.individualTestGet[0]['answer'].length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: (kIsWeb && (Get.width * 0.2 <= 171))
                          ? EdgeInsets.only(right: 24, left: 24)
                          : const EdgeInsets.only(right: 120, left: 120),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 32, right: 24, left: 24),
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
                                          ts.individualTestGet[0]['answer']
                                              .length),
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
                              GestureDetector(
                                onTap: () {
                                  _numberCon.text = '';
                                  showEditDialog(context, '몇 번으로 이동하시겠습니까', () {
                                    Get.back();
                                    controller.animateToPage(
                                      int.parse('${_numberCon.text}') - 1,
                                      duration: Duration(milliseconds: 200),
                                      curve: Curves.linear,
                                    );
                                  }, _numberCon);
                                },
                                child: Text(
                                  '문제 ${index + 1}번. ${ts.individualTestGet[0]['individualTitle'][index]} ${ts.individualTestGet[0]['audio'][index].contains('no') ? '' : '(듣기)'}',
                                  style: f20w500,
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              ts.individualTestGet[0]['images'].length == 0
                                  ? Container()
                                  : !ts.individualTestGet[0]['images'][index]
                                          .contains('no')
                                      ? (kIsWeb && (Get.width * 0.2 <= 171))
                                          ? ExtendedImage.network(
                                              // 'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/teacher%2F1234%2F6EhFcIYaHuOmpsH9H87N%2F2023-02-08%2013%3A32%3A44.647799?alt=media&token=947e3a38-3426-4605-85df-ad874a4c0b9a',
                                              'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/teacher%2F${ts.individualTestGet[0]['teacher']}%2F${ts.individualTestGet[0]['docId']}%2F${ts.individualTestGet[0]['images'][index]}?alt=media',
                                              fit: BoxFit.contain,
                                              mode: ExtendedImageMode.gesture,
                                              width: (kIsWeb &&
                                                      (Get.width * 0.2 <= 171))
                                                  ? Get.width
                                                  : Get.width * 0.6,
                                              height: (kIsWeb &&
                                                      (Get.width * 0.2 <= 171))
                                                  ? Get.width
                                                  : Get.width * 0.4,
                                              cache: true,
                                              enableLoadState: false,
                                              onDoubleTap:
                                                  (ExtendedImageGestureState
                                                      state) {
                                                ///you can use define pointerDownPosition as you can,
                                                ///default value is double tap pointer down postion.
                                                var pointerDownPosition =
                                                    state.pointerDownPosition;
                                                double begin = state
                                                    .gestureDetails!
                                                    .totalScale!;
                                                double end;

                                                _animation?.removeListener(
                                                    animationListener);
                                                _animationController.stop();
                                                _animationController.reset();

                                                if (begin == 1) {
                                                  end = 1.5;
                                                } else {
                                                  end = 1;
                                                }
                                                animationListener = () {
                                                  //print(_animation.value);
                                                  state.handleDoubleTap(
                                                      scale: _animation!.value,
                                                      doubleTapPosition:
                                                          pointerDownPosition);
                                                };
                                                _animation =
                                                    _animationController.drive(
                                                        Tween<double>(
                                                            begin: begin,
                                                            end: end));

                                                _animation!.addListener(
                                                    animationListener);

                                                _animationController.forward();
                                              },
                                            )
                                          : ExtendedImage.network(
                                              // 'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/teacher%2F1234%2F6EhFcIYaHuOmpsH9H87N%2F2023-02-08%2013%3A32%3A44.647799?alt=media&token=947e3a38-3426-4605-85df-ad874a4c0b9a',
                                              'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/teacher%2F${ts.individualTestGet[0]['teacher']}%2F${ts.individualTestGet[0]['docId']}%2F${ts.individualTestGet[0]['images'][index]}?alt=media',
                                              fit: BoxFit.contain,
                                              // mode: ExtendedImageMode.gesture,
                                              width: (kIsWeb &&
                                                      (Get.width * 0.2 <= 171))
                                                  ? Get.width
                                                  : Get.width * 0.6,
                                              height: (kIsWeb &&
                                                      (Get.width * 0.2 <= 171))
                                                  ? Get.width
                                                  : Get.width * 0.4,
                                              cache: true,
                                              enableLoadState: false,
                                            )
                                      : Container(),
                              ts.individualTestGet[0]['images'].length == 0
                                  ? Container()
                                  : ts.individualTestGet[0]['images'][index] !=
                                          ''
                                      ? SizedBox(
                                          height: 20,
                                        )
                                      : Container(),
                              ts.individualTestGet[0]['audio'][index]
                                      .contains('no')
                                  ? Container()
                                  : GestureDetector(
                                      onTap: () async {
                                        await _player.setSourceUrl(
                                            'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/teacher%2Faudio%2F${ts.individualTestGet[0]['teacher']}%2F${ts.individualTestGet[0]['docId']}%2F${ts.individualTestGet[0]['audio'][index]}?alt=media');
                                        if (!_isPlaying) {
                                          _isPlaying = true;
                                          _player.resume();
                                        } else {
                                          _isPlaying = false;
                                          _player.pause();
                                        }
                                        setState(() {});
                                      },
                                      child: Image.asset(
                                        _isPlaying
                                            ? 'assets/icon/pause.png'
                                            : 'assets/icon/play.png',
                                        color: Colors.black,
                                        width: 32,
                                        height: 32,
                                      )),
                              Text(
                                '${ts.individualTestGet[0]['individualBody'][index]}',
                                style: f20w500,
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                args.isChecked == 'true'
                                    ? '내가 입력한 답 : ${ts.individualAnswer[index]}'
                                    : '정답',
                                style: f16w700,
                              ),
                              SizedBox(
                                height: 10,
                              ),
                              //
                              ts.individualTestGet[0]['answer'][index] == ''
                                  ? TextField(
                                      enabled: args.isChecked == 'true'
                                          ? false
                                          : true,
                                      controller: _controller[index],
                                      onChanged: (v) {
                                        _answer[index] =
                                            _controller[index].text;
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
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                        hintText: args.isChecked == 'true'
                                            ? '정답 : ${ts.individualTestGet[0]['temp1'][index]}'
                                            : '내용을 입력해주세요',
                                        hintStyle: args.isChecked == 'true'
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
                                                            onPressed:
                                                                args.isChecked ==
                                                                        'true'
                                                                    ? null
                                                                    : () {
                                                                        _answer[index] =
                                                                            '${i + 1}';
                                                                        if (_pageIndex !=
                                                                            ts.individualTestGet[0]['answer'].length -
                                                                                1) {
                                                                          controller.animateToPage(
                                                                              controller.page!.toInt() + 1,
                                                                              duration: Duration(milliseconds: 200),
                                                                              curve: Curves.linear);
                                                                        }
                                                                        _isPlaying =
                                                                            false;
                                                                        _player
                                                                            .stop();
                                                                        setState(
                                                                            () {});
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
                                                                  color: Colors
                                                                      .grey),
                                                              minimumSize: (kIsWeb &&
                                                                      (Get.width *
                                                                              0.2 <=
                                                                          171))
                                                                  ? Size(32, 32)
                                                                  : Size(
                                                                      52, 52),
                                                              foregroundColor:
                                                                  Colors.black,
                                                              backgroundColor: _answer[index] ==
                                                                          number[
                                                                              i] ||
                                                                      (ts.individualAnswer[index] == ts.individualTestGet[0]['answer'][index]) &&
                                                                          (ts.individualAnswer[index] ==
                                                                              number[
                                                                                  i]) &&
                                                                          args.isChecked ==
                                                                              'true'
                                                                  ? nowColor
                                                                  : (ts.individualAnswer[index] != ts.individualTestGet[0]['answer'][index]) &&
                                                                          (ts.individualTestGet[0]['answer'][index] ==
                                                                              number[
                                                                                  i]) &&
                                                                          args.isChecked ==
                                                                              'true'
                                                                      ? Colors
                                                                          .red
                                                                      : Colors.white,
                                                              padding: EdgeInsets
                                                                  .only(
                                                                      right: 12,
                                                                      left: 12),
                                                              tapTargetSize:
                                                                  MaterialTapTargetSize
                                                                      .shrinkWrap,
                                                            ),
                                                            child: Text(
                                                                '${i + 1}',
                                                                style: _answer[index] ==
                                                                            number[
                                                                                i] ||
                                                                        (ts.individualAnswer[index] == ts.individualTestGet[0]['answer'][index]) &&
                                                                            (ts.individualAnswer[index] ==
                                                                                number[
                                                                                    i]) &&
                                                                            args.isChecked ==
                                                                                'true' ||
                                                                        (ts.individualAnswer[index] != ts.individualTestGet[0]['answer'][index]) &&
                                                                            (ts.individualTestGet[0]['answer'][index] ==
                                                                                number[i]) &&
                                                                            args.isChecked == 'true'
                                                                    ? (kIsWeb && (Get.width * 0.2 <= 171))
                                                                        ? f10Whitew500
                                                                        : f16Whitew700
                                                                    : (kIsWeb && (Get.width * 0.2 <= 171))
                                                                        ? f10w700
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
                      ),
                    );
                  },
                ),
                bottomNavigationBar: Padding(
                  padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).viewInsets.bottom),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 32, horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                            onTap: () {
                              _isPlaying = false;
                              _player.stop();
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
                              _isPlaying = false;
                              _player.stop();
                              if (args.isChecked != 'true') {
                                if (_pageIndex ==
                                    ts.individualTestGet[0]['answer'].length -
                                        1) {
                                  showComponentDialog(context, '제출하시겠습니까?',
                                      () async {
                                    ts.answer.value = _answer;
                                    await firebaseIndividualTestUpload(_docId);
                                    Get.back();
                                    showConfirmTapDialog(context,
                                        '수고하셨습니다\n\n작성하신 답안이 정상적으로 제출 되었습니다',
                                        () {
                                      // Get.offAll(() => BottomNavigator());
                                      Get.offAllNamed(MainScreen.id);
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
                                ? args.isChecked != 'true'
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
      ),
    );
  }

  void _score() {
    final ts = Get.put(TestState());

    for (int i = 0; i < ts.individualTestGet[0]['answer'].length; i++) {
      if (ts.individualAnswer[i] == ts.individualTestGet[0]['answer'][i] ||
          ts.individualAnswer[i] == ts.individualTestGet[0]['temp1'][i]) {
        correct++;
      }
    }
  }
}
