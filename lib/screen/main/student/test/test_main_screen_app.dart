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

import '../../../../firebase/firebase_test.dart';
import '../../../../util/colors.dart';
import '../../../../util/count_down.dart';
import '../../../../util/font/font.dart';
import '../../../login/login_main_screen.dart';
import '../../main_screen.dart';

class TestMainScreen extends StatefulWidget {
  static final String id = '/test_main_screen_app';
  final String? teacher;
  final String? docId;
  final String? hasAudio;
  final FutureOr<Uint8List>? content;

  const TestMainScreen(
      {Key? key, this.content, this.teacher, this.docId, this.hasAudio})
      : super(key: key);

  @override
  State<TestMainScreen> createState() => _TestMainScreenState();
}

class _TestMainScreenState extends State<TestMainScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  final as = Get.put(AnswerState());
  late PDFViewController controller;
  int pages = 0;
  int indexPage = 0;
  bool _isPlaying = false;
  String _hasA = '';
  String _docId = '';
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollController = ScrollController();
  List<String> number = ['1', '2', '3', '4', '5'];
  List<String> _answer = [];
  AudioPlayer _player = AudioPlayer();
  late AnimationController _controller;

  void addNumber() async {
    for (int i = 0; i < as.answerlength.length; i++) {
      _answer.add('');
    }
  }

  // late PdfControllerPinch pdfController;
  late PdfController _pdfController;
  @override
  void initState() {
    final ts = Get.put(TestState());

    // pdfController =
    //     PdfControllerPinch(document: PdfDocument.openData(widget.content));
    // _pdfController = PdfController(document: PdfDocument.openData(null));
    // String hey = '';
    // FutureOr<Uint8List>? godjob;
    // godjob = hey as FutureOr<Uint8List>?;

    if (RefreshManager.getCookie('test') != '') {
      _pdfController = PdfController(
        document: PdfDocument.openData(
            RefreshManager.getCookie('test') as FutureOr<Uint8List>),
      );
    } else {
      Future.delayed(Duration.zero, () async {
        final args =
            ModalRoute.of(context)!.settings.arguments as TestMainScreen;
        await _player.setSourceUrl(
            'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/teacher%2Faudio%2F${args.teacher}%2F${args.docId}%2F${args.docId}?alt=media');
        _docId = '${args.docId}';
        _pdfController = PdfController(
          document: PdfDocument.openData(args.content!),
        );
        _hasA = args.hasAudio == 'yes' ? 'true' : 'false';
        addNumber();
        setState(() {
          isLoading = false;
        });
      });
    }

    _controller = AnimationController(
        vsync: this,
        duration: Duration(
            seconds: as.temp2.value != '' ? int.parse(as.temp2.value) : 0));
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: (as.temp2.value == '' || as.temp2.value == '0')
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
                      ).animate(_controller),
                    ),
            ),
            SizedBox(
              width: 8,
            ),
            IconButton(
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
            PdfPageNumber(
              controller: _pdfController,
              builder: (_, loadingState, page, pagesCount) => Container(
                alignment: Alignment.center,
                child: Text(
                  '$page/${pagesCount ?? 0}',
                  style: kIsWeb && (Get.width * 0.2 <= 171) ? f14w500 : f20w500,
                ),
              ),
            ),
            IconButton(
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
          ],
        ),
        elevation: 0,
        automaticallyImplyLeading: false,
        flexibleSpace: GestureDetector(
          onTap: () {
            controller.setPage(0);
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: modelSheetClick,
                    child: Text(
                      '정답 입력',
                      style: kIsWeb && (Get.width * 0.2 <= 171)
                          ? f14w700primary
                          : f16w700primary,
                    ),
                  ),
                ),
              ),
            ),
          )
        ],
        backgroundColor: backColor,
      ),
      body: Stack(
        children: [
          PdfView(
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
        ],
      ),
      floatingActionButton: _hasA == 'true'
          ? FloatingActionButton(
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

  void modelSheetClick() {
    final ts = Get.put(TestState());
    showModalBottomSheet(
        backgroundColor: Colors.white24,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        )),
        context: context,
        isScrollControlled: true,
        builder: (builder) {
          return StatefulBuilder(builder: (context, setState) {
            return ScrollConfiguration(
              behavior: MyBehavior(),
              child: DraggableScrollableSheet(
                  initialChildSize: 0.5,
                  maxChildSize: 0.5,
                  minChildSize: 0.3,
                  expand: false,
                  builder: (BuildContext context,
                      ScrollController scrollController) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 25, 25, 0),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  showComponentDialog(context, '제출하시겠습니까?',
                                      () async {
                                    // answerListAdd('SIg3OP2qqovlBZROIaRr');
                                    ts.answer.value = _answer;
                                    Get.back();
                                    await firebaseTestUpload(_docId, context);
                                  });
                                },
                                child: Text(
                                  '제출',
                                  style: f18w700primary,
                                ),
                              ),
                            ],
                            mainAxisAlignment: MainAxisAlignment.end,
                          ),
                          Expanded(
                            child: ListView.builder(
                              physics: const ClampingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: as.answerlength.length,
                              controller: scrollController,
                              itemBuilder: (_, index) {
                                return Padding(
                                  padding: const EdgeInsets.all(20),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('${index + 1}번 문제', style: f18w500),
                                      isLoading
                                          ? LoadingBodyScreen()
                                          : Container(
                                              height: 60,
                                              child: ListView(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                children: number.map((number) {
                                                  return Row(
                                                    children: [
                                                      TextButton(
                                                          onPressed: () {
                                                            _answer[index] =
                                                                number;
                                                            setState(() {});
                                                          },
                                                          style: TextButton.styleFrom(
                                                              minimumSize:
                                                                  Size(52, 52),
                                                              foregroundColor: Colors
                                                                  .transparent,
                                                              backgroundColor:
                                                                  _answer[index] ==
                                                                          number
                                                                      ? nowColor
                                                                      : Colors
                                                                          .white,
                                                              padding:
                                                                  EdgeInsets.only(
                                                                      right: 12,
                                                                      left: 12),
                                                              tapTargetSize:
                                                                  MaterialTapTargetSize
                                                                      .shrinkWrap,
                                                              shape: RoundedRectangleBorder(
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          20),
                                                                  side: BorderSide(
                                                                      width: 1,
                                                                      color: Colors.grey))),
                                                          child: Text(
                                                            '$number',
                                                            style: _answer[
                                                                        index] ==
                                                                    number
                                                                ? f16Whitew700
                                                                : f16w700,
                                                          )),
                                                      SizedBox(
                                                        width: 10,
                                                      )
                                                    ],
                                                  );
                                                }).toList(),
                                              )),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            );
          });
        });
  }
}
