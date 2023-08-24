import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:academy/provider/answer_state.dart';
import 'package:academy/provider/test_state.dart';
import 'package:academy/util/behavior.dart';
import 'package:academy/util/loading.dart';
import 'package:academy/util/refresh_manager.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../components/button/main_button.dart';
import '../../../../components/footer/footer.dart';
import '../../../../firebase/firebase_answer.dart';
import '../../../../firebase/firebase_test.dart';
import '../../../../util/colors.dart';
import '../../../../util/count_down.dart';
import '../../../../util/font/font.dart';
import '../../../login/login_main_screen.dart';
import '../../main_screen.dart';

class TestMainScreen extends StatefulWidget {
  static final String id = '/test_main_screen';
  final String? teacher;
  final String? docId;
  final String? hasAudio;
  final bool myPageb;
  final FutureOr<Uint8List>? content;

  const TestMainScreen(
      {Key? key, this.content, this.teacher, this.docId, this.hasAudio,this.myPageb = false})
      : super(key: key);

  @override
  State<TestMainScreen> createState() => _TestMainScreenState();
}

class _TestMainScreenState extends State<TestMainScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  final as = Get.put(AnswerState());
  late PDFViewController controller;
  bool _isPlaying = false;
  String _hasA = '';
  String _docId = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  List<String> number = ['1', '2', '3', '4', '5'];
  List<String> _answer = [];
  List<String> _successAnswer = []; // 마이페이지에서 -> 시험지로 확인 할때 옆에 정답넣어두는 리스트
  AudioPlayer _player = AudioPlayer();
  late AnimationController _controller;
  TextEditingController _numberCon = TextEditingController();

  void addNumber() {

    for (int i = 0; i < as.answerlength.length; i++) {
      _answer.add('');
      _successAnswer.add('');
    }
  }

  // late PdfControllerPinch pdfController;
  late PdfController _pdfController;
  @override
  void initState() {
    final ts = Get.put(TestState());
    if (RefreshManager.getCookie('test') != '') {
      _pdfController = PdfController(
        document: PdfDocument.openData(
            RefreshManager.getCookie('test') as FutureOr<Uint8List>),
      );
    } else {
      Future.delayed(Duration.zero, () async {

        final args = ModalRoute.of(context)!.settings.arguments as TestMainScreen;
        await _player.setSourceUrl(
            'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/teacher%2Faudio%2F${args.teacher}%2F${args.docId}%2F${args.docId}?alt=media');
        _docId = '${args.docId}';
        _pdfController = PdfController(
          document: PdfDocument.openData(args.content!),
        );
        _hasA = args.hasAudio == 'yes' ? 'true' : 'false';
        await getAnswerLength('${args.docId}');

        addNumber();
        setState(() {
          isLoading = false;
        });
        if(args.myPageb==true){
          for(int i =0;i<_answer.length;i++){
            _answer[i] = ts.mySingleAnswer[0]['answer'][i];
            _successAnswer[i] = as.answerlength[i];
          }
        }
        setState(() {
          isLoading = false;
        });
      });
    }

    _controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: as.temp2.value != '' ? int.parse(as.temp2.value) : 0));
    _controller.addListener(() async {
      ts.answer.value = _answer;
      if (as.temp2.value != '') {
        if (1 == _controller.value) {
          await firebaseTestUpload(_docId, context);
        }
      }
    });
    (as.temp2.value == '' || as.temp2.value == '0')
        ? _controller.stop()
        : _controller.forward();

    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _player.dispose();
    _pdfController.dispose();
    _controller.stop();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ts = Get.put(TestState());
    final as = Get.put(AnswerState());
    final args = ModalRoute.of(context)!.settings.arguments as TestMainScreen;
    return isLoading
        ?LoadingBodyScreen()
        :
      Scaffold(
       key: _scaffoldKey,
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(130),
            child: AppBar(
              toolbarHeight: 130,
              title: Padding(
                padding: const EdgeInsets.fromLTRB(340, 20, 340, 0),
                child: Container(
                  width: Get.width,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          _hasA == 'true'
                              ? FloatingActionButton.small(
                            backgroundColor: nowColor,
                            child: Icon(
                              _isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                            ),
                            onPressed: () async {
                              // await _player.setSourceUrl(
                              //     'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/teacher%2Faudio%2FmiTeacher%2FdgcMnBOVScaHJ9aMc3Yi%2FdgcMnBOVScaHJ9aMc3Yi?alt=media');

                              if (!_isPlaying) {
                                _isPlaying = true;
                                _player.resume();
                              } else {
                                _isPlaying = false;
                                _player.pause();
                              }
                              setState(() {});
                            },
                          )
                              : Container(),
                          Spacer(),
                          GestureDetector(
                            onTap: (){
                              showEditDialog(context, '몇 페이지로 이동하시겠습니까', () {
                                Get.back();
                                _pdfController.animateToPage(
                                  int.parse('${_numberCon.text}'),
                                  duration: Duration(milliseconds: 200),
                                  curve: Curves.linear,
                                );
                              }, _numberCon);
                            },
                            child: PdfPageNumber(
                              controller: _pdfController,
                              builder: (_, loadingState, page, pagesCount) => Container(
                                alignment: Alignment.center,
                                child: Text(
                                  '문제 $page/${pagesCount ?? 0}',
                                  style: f16w400grey8,
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          Container(
                            child: Center(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: (){
                                  args.myPageb==true
                                      ? Get.back()
                                      :showComponentDialog(context, '시험을 종료하시겠습니까?', () {
                                    Get.toNamed(BottomNavigator.id);
                                  });
                                },
                                child: Text(
                                  '나가기',
                                  style: kIsWeb && (Get.width * 0.2 <= 171)
                                      ? f14w700primary
                                      : f16w700primary,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      Row(
                        children: [
                          Spacer(),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xffDADADA),
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(8))
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.navigate_before,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                _pdfController.previousPage(
                                  curve: Curves.ease,
                                  duration: const Duration(milliseconds: 100),
                                );
                              },
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Center(
                            child:
                              args.myPageb==true?Container(
                              )
                                  : (as.temp2.value == '' || as.temp2.value == '0')
                                ? Text(
                              '시간제한 없음',
                              style: f42w700,
                            )
                                : Countdown(
                              animation: StepTween(
                                begin: as.temp2.value != ''
                                    ? int.parse(as.temp2.value)
                                    : 0,
                                end: 0,
                              ).animate(_controller),
                            ),
                          ),
                          SizedBox(
                            width: 20,
                          ),
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                                border: Border.all(
                                  color: Color(0xffDADADA),
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(8))
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.navigate_next,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                _pdfController.nextPage(
                                  curve: Curves.ease,
                                  duration: const Duration(milliseconds: 100),
                                );
                              },
                            ),
                          ),
                          Spacer()
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              elevation: 0,
              automaticallyImplyLeading: false,
              flexibleSpace: GestureDetector(
                onTap: () {
                  controller.setPage(0);
                },
              ),
              actions: [],
              backgroundColor: Colors.white,
            ),
          ),
       body: SingleChildScrollView(
         physics: const ClampingScrollPhysics(),
         child: Column(
           children: [
             Stack(
              children: [
                ///왼쪽
                Positioned(
                  left: -40, // 오버플로우
                  child: Container(
                    width: Get.width* 0.7,
                    height: Get.height,
                    child: PdfView(
                      builders: PdfViewBuilders<DefaultBuilderOptions>(
                        options: const DefaultBuilderOptions(),
                        documentLoaderBuilder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                        pageLoaderBuilder: (_) =>
                        const Center(child: CircularProgressIndicator()),
                        pageBuilder: _pageBuilder,
                      ),
                      controller: _pdfController,
                    ),
                  ),
                ),
                /// 오른쪽
                Positioned(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(right: Get.width * 0.2, top: 30, bottom: 102),
                        child: Wrap(children: [
                          Container(
                            width: 350,
                            height: 795,
                            child: Column(
                              children: [
                                args.myPageb==true
                                    ? Container(
                                    width: Get.width,
                                    height: Get.height * 0.8,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.25),
                                          blurRadius: 20.0,
                                          offset: Offset(
                                              2, 2), // changes position of shadow
                                        )
                                      ],
                                    ),
                                    child: StatefulBuilder(
                                      builder: (context, setState) {
                                        return ScrollConfiguration(
                                          behavior: MyBehavior(),
                                          child: DraggableScrollableSheet(
                                              initialChildSize: 1,
                                              maxChildSize: 1,
                                              minChildSize: 0.2,
                                              expand: false,
                                              builder: (BuildContext context,
                                                  ScrollController scrollController) {
                                                return Column(
                                                  children: [
                                                    Expanded(
                                                      child: ListView.builder(
                                                        physics:
                                                        const ClampingScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount:
                                                        as.answerlength.length,
                                                        controller: scrollController,
                                                        itemBuilder: (_, index) {
                                                          return Padding(
                                                            padding:
                                                            const EdgeInsets.only(
                                                                left: 40,
                                                                right: 40,
                                                                top: 23),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                    '${index + 1}번 문제',
                                                                    style: f18w500),
                                                                isLoading
                                                                    ? LoadingBodyScreen()
                                                                    : Container(
                                                                    height: 60,
                                                                    child:
                                                                    ListView(
                                                                      scrollDirection:
                                                                      Axis.horizontal,
                                                                      children:
                                                                      number.map(
                                                                              (number) {
                                                                            return Row(
                                                                              children: [
                                                                                TextButton(
                                                                                    onPressed: () {

                                                                                    },
                                                                                    style: TextButton.styleFrom(
                                                                                        minimumSize: Size(52, 52),
                                                                                        foregroundColor: Colors.transparent,
                                                                                        backgroundColor: _answer[index] == number && _answer[index] ==_successAnswer[index]
                                                                                            ? nowColor
                                                                                            :  _answer[index] == number && _answer[index] !=_successAnswer[index] || _answer[index] =='' && _successAnswer[index]==number
                                                                                            ? Colors.red
                                                                                            : Colors.white, padding: EdgeInsets.only(right: 12, left: 12), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(width: 1, color: Colors.grey))),
                                                                                    child: Text(
                                                                                      '$number',
                                                                                      style: _answer[index] ==_successAnswer[index]&&_answer[index]==number
                                                                                          ?f16Whitew700
                                                                                          :_answer[index] ==  number || (_answer[index] =='' && _successAnswer[index] ==  number)
                                                                                          ?f16Whitew700
                                                                                          : f16w700,
                                                                                    )),
                                                                                SizedBox(
                                                                                  width:
                                                                                  10,
                                                                                )
                                                                              ],
                                                                            );
                                                                          }).toList(),
                                                                    )),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }),
                                        );
                                      },
                                    ))
                                    : Container(
                                    width: Get.width,
                                    height: Get.height * 0.8,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.25),
                                          blurRadius: 20.0,
                                          offset: Offset(
                                              2, 2), // changes position of shadow
                                        )
                                      ],
                                    ),
                                    child: StatefulBuilder(
                                      builder: (context, setState) {
                                        return ScrollConfiguration(
                                          behavior: MyBehavior(),
                                          child: DraggableScrollableSheet(
                                              initialChildSize: 1,
                                              maxChildSize: 1,
                                              minChildSize: 0.2,
                                              expand: false,
                                              builder: (BuildContext context,
                                                  ScrollController scrollController) {
                                                return Column(
                                                  children: [
                                                    Expanded(
                                                      child: ListView.builder(
                                                        physics:
                                                        const ClampingScrollPhysics(),
                                                        shrinkWrap: true,
                                                        itemCount:
                                                        as.answerlength.length,
                                                        controller: scrollController,
                                                        itemBuilder: (_, index) {
                                                          return Padding(
                                                            padding:
                                                            const EdgeInsets.only(
                                                                left: 40,
                                                                right: 40,
                                                                top: 23),
                                                            child: Column(
                                                              crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                              children: [
                                                                Text(
                                                                    '${index + 1}번 문제',
                                                                    style: f18w500),
                                                                isLoading
                                                                    ? LoadingBodyScreen()
                                                                    : Container(
                                                                    height: 60,
                                                                    child:
                                                                    ListView(
                                                                      scrollDirection:
                                                                      Axis.horizontal,
                                                                      children:
                                                                      number.map(
                                                                              (number) {
                                                                            return Row(
                                                                              children: [
                                                                                TextButton(
                                                                                    onPressed: () {
                                                                                      _answer[index] = number;
                                                                                      setState(() {});
                                                                                    },
                                                                                    style: TextButton.styleFrom(minimumSize: Size(52, 52), foregroundColor: Colors.transparent, backgroundColor: _answer[index] == number ? nowColor : Colors.white, padding: EdgeInsets.only(right: 12, left: 12), tapTargetSize: MaterialTapTargetSize.shrinkWrap, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(width: 1, color: Colors.grey))),
                                                                                    child: Text(
                                                                                      '$number',
                                                                                      style: _answer[index] == number ? f16Whitew700 : f16w700,
                                                                                    )),
                                                                                SizedBox(
                                                                                  width:
                                                                                  10,
                                                                                )
                                                                              ],
                                                                            );
                                                                          }).toList(),
                                                                    )),
                                                              ],
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              }),
                                        );
                                      },
                                    )),
                                SizedBox(
                                  height: 16,
                                ),
                                args.myPageb!=true
                                    ? MainButton(
                                  onPressed: () {
                                    showComponentDialog(context, '제출하시겠습니까?',
                                            () async {
                                          // answerListAdd('SIg3OP2qqovlBZROIaRr');
                                          ts.answer.value = _answer;
                                          Get.back();
                                          await firebaseTestUpload(_docId, context);
                                        });
                                  },
                                  text: '제출하기',
                                  submit: '2',
                                )
                                    :Container(),
                              ],
                            ),
                          ),
                        ]),
                      ),
                    ],
                  ),
                )
              ],
      ),
             Footer()
           ],
         ),
       ),
    );
  }
  PhotoViewGalleryPageOptions _pageBuilder(
      BuildContext context,
      Future<PdfPageImage> pageImage,
      int index,
      PdfDocument document,
      ) {
    return PhotoViewGalleryPageOptions(
      imageProvider: PdfPageImageProvider(
        pageImage,
        index,
        document.id,
      ),
      minScale: PhotoViewComputedScale.contained * 1,
      maxScale: PhotoViewComputedScale.contained * 2,
      initialScale: PhotoViewComputedScale.contained * 1.0,
      heroAttributes: PhotoViewHeroAttributes(tag: '${document.id}-$index'),
    );
  }

  // void modelSheetClick() {
  //   final ts = Get.put(TestState());
  //   showModalBottomSheet(
  //       backgroundColor: Colors.white24,
  //       shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.only(
  //             topLeft: Radius.circular(20),
  //             topRight: Radius.circular(20),
  //           )),
  //       context: context,
  //       isScrollControlled: true,
  //       builder: (builder) {
  //         return StatefulBuilder(builder: (context, setState) {
  //           return ScrollConfiguration(
  //             behavior: MyBehavior(),
  //             child: DraggableScrollableSheet(
  //                 initialChildSize: 0.5,
  //                 maxChildSize: 0.5,
  //                 minChildSize: 0.3,
  //                 expand: false,
  //                 builder: (BuildContext context,
  //                     ScrollController scrollController) {
  //                   return Padding(
  //                     padding: const EdgeInsets.fromLTRB(0, 25, 25, 0),
  //                     child: Column(
  //                       children: [
  //                         Row(
  //                           children: [
  //                             TextButton(
  //                               onPressed: () {
  //                                 showComponentDialog(context, '제출하시겠습니까?',
  //                                         () async {
  //                                       // answerListAdd('SIg3OP2qqovlBZROIaRr');
  //                                       ts.answer.value = _answer;
  //                                       Get.back();
  //                                       await firebaseTestUpload(_docId, context);
  //                                     });
  //                               },
  //                               child: Text(
  //                                 '제출',
  //                                 style: f18w700primary,
  //                               ),
  //                             ),
  //                           ],
  //                           mainAxisAlignment: MainAxisAlignment.end,
  //                         ),
  //                         Expanded(
  //                           child: ListView.builder(
  //                             physics: const ClampingScrollPhysics(),
  //                             shrinkWrap: true,
  //                             itemCount: as.answerlength.length,
  //                             controller: scrollController,
  //                             itemBuilder: (_, index) {
  //                               return Padding(
  //                                 padding: const EdgeInsets.all(20),
  //                                 child: Column(
  //                                   crossAxisAlignment:
  //                                   CrossAxisAlignment.start,
  //                                   children: [
  //                                     Text('${index + 1}번 문제', style: f18w500),
  //                                     isLoading
  //                                         ? LoadingBodyScreen()
  //                                         : Container(
  //                                         height: 60,
  //                                         child: ListView(
  //                                           scrollDirection:
  //                                           Axis.horizontal,
  //                                           children: number.map((number) {
  //                                             return Row(
  //                                               children: [
  //                                                 TextButton(
  //                                                     onPressed: () {
  //                                                       _answer[index] =
  //                                                           number;
  //                                                       setState(() {});
  //                                                     },
  //                                                     style: TextButton.styleFrom(
  //                                                         minimumSize:
  //                                                         Size(52, 52),
  //                                                         foregroundColor: Colors
  //                                                             .transparent,
  //                                                         backgroundColor:
  //                                                         _answer[index] ==
  //                                                             number
  //                                                             ? nowColor
  //                                                             : Colors
  //                                                             .white,
  //                                                         padding:
  //                                                         EdgeInsets.only(
  //                                                             right: 12,
  //                                                             left: 12),
  //                                                         tapTargetSize:
  //                                                         MaterialTapTargetSize
  //                                                             .shrinkWrap,
  //                                                         shape: RoundedRectangleBorder(
  //                                                             borderRadius:
  //                                                             BorderRadius.circular(
  //                                                                 20),
  //                                                             side: BorderSide(
  //                                                                 width: 1,
  //                                                                 color: Colors.grey))),
  //                                                     child: Text(
  //                                                       '$number',
  //                                                       style: _answer[
  //                                                       index] ==
  //                                                           number
  //                                                           ? f16Whitew700
  //                                                           : f16w700,
  //                                                     )),
  //                                                 SizedBox(
  //                                                   width: 10,
  //                                                 )
  //                                               ],
  //                                             );
  //                                           }).toList(),
  //                                         )),
  //                                     const SizedBox(
  //                                       height: 10,
  //                                     ),
  //                                   ],
  //                                 ),
  //                               );
  //                             },
  //                           ),
  //                         ),
  //                       ],
  //                     ),
  //                   );
  //                 }),
  //           );
  //         });
  //       });
  // }
}