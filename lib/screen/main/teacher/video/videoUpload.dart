import 'dart:core';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:simple_timer/simple_timer.dart';
import 'package:video_player/video_player.dart';

import 'dart:html' as html;

import '../../../../components/dialog/showAlertDialog.dart';
import '../../../../components/footer/footer.dart';
import '../../../../components/tile/textform_field.dart';
import '../../../../provider/answer_state.dart';
import '../../../../provider/user_state.dart';
import '../../../../util/colors.dart';
import '../../../../util/font/font.dart';
import '../../../../util/loading.dart';
import 'package:http/http.dart' as http;

class VideoUpload extends StatefulWidget {
  static final String id = '/videoUpload';
  final String? edit;
  final String? title;
  final String? pw;
  final String? videoName;
  final String? docId;
  const VideoUpload(
      {Key? key, this.edit, this.title, this.pw, this.videoName, this.docId})
      : super(key: key);

  @override
  State<VideoUpload> createState() => _VideoUploadState();
}

class _VideoUploadState extends State<VideoUpload>
    with SingleTickerProviderStateMixin {
  late TimerController _timerController;
  TimerProgressIndicatorDirection _progressIndicatorDirection = TimerProgressIndicatorDirection.clockwise;
  TimerProgressTextCountDirection _progressTextCountDirection = TimerProgressTextCountDirection.count_down;
  TextEditingController _videoTitleController = TextEditingController();
  TextEditingController _testPwController = TextEditingController();
  ChewieController? _chewieController;
  VideoPlayerController? videoPlayerController;

  PlatformFile? pickedFile;
  String? pickedFile2;
  late Uint8List uploadfile;
  String isfilePath = '';
  final _obscureText = false.obs;
  bool _imageLoading = false;
  // int count = 0;
  // late Duration videoPosition;
  // bool isVisiual = true;
  int? bufferDelay;
  Duration _currentPosition = Duration.zero;
  bool _isPlaying = false;
  int a = 0;
  String? videoName;
  bool isLoading = true;
  @override
  void initState() {
    final us = Get.put(UserState());
    Future.delayed(Duration.zero, () async {
      final args = ModalRoute.of(context)!.settings.arguments as VideoUpload;
      if (args.edit == 'true') {
        final videoBytes = await http.readBytes(Uri.parse(
            'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/video%2F${us.userList[0].docId}%2F${args.videoName}.mp4?alt=media'));
        uploadfile = await http.readBytes(Uri.parse(
            'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/video%2F${us.userList[0].docId}%2F${args.videoName}.mp4?alt=media'));
        _videoTitleController.text = '${args.title}';
        _testPwController.text = '${args.pw}';
        videoName = '${args.videoName}';
        _initializeVideoPlayer(videoBytes);
      }
      setState(() {
        isLoading = false;
      });
    });
    // _timerController = TimerController(this);
    // count = 0;
    // Future.delayed(Duration.zero, () async {
    //   // await videoPlayerController?.initialize();
    //   // _initializeVideoPlayerFuture = videoPlayerController!.initialize();
    // });

    super.initState();
  }

  @override
  void dispose() {
    videoPlayerController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());
    final args = ModalRoute.of(context)!.settings.arguments as VideoUpload;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async {
          return Future(() {
            showComponentDialog(context, '문제추가를 종료하시겠습니까?', () {
              Get.back();
              Get.back();
            });
            return true;
          });
        },
        child: isLoading?LoadingBodyScreen():Scaffold(
          backgroundColor: backColor,
          appBar: AppBar(
            backgroundColor: nowColor,
            elevation: 0,
            // leading: IconButton(
            //   icon: Icon(
            //     Icons.arrow_back_ios_new,
            //     color: Color(0xff6f7072),
            //   ),
            //   onPressed: () {
            //     showComponentDialog(context, '작성을 취소하시겠습니까?', () {
            //       Get.offAllNamed(MainScreen.id);
            //     });
            //   },
            // ),
            centerTitle: false,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                SvgPicture.asset(
                  'assets/logo.svg',
                  width: (kIsWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
                  height: (kIsWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
                ),
                SizedBox(
                  width: 8,
                ),
                kIsWeb && (Get.width * 0.2 <= 171) ? Container() : Text('강의등록')
              ],
            ),
          ),
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: Get.width * 0.8,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context)
                          .copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                              height: 40,
                            ),
                            Row(
                              children: [
                                Text(
                                  '강의등록',
                                  style: f32w700,
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    showComponentDialog(
                                        context, '작성을 취소하시겠습니까?', () {
                                      Get.back();
                                      Get.back();
                                      // Get.offAllNamed(BottomNavigator.id);
                                      // Navigator.pushNamedAndRemoveUntil(context, LoginMainScreen.id, (route) => false);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                        child: Text(
                                      '나가기',
                                      style: f16w700,
                                    )),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xff535353),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    if (args.edit == 'true') {
                                      showComponentDialog(context, '수정하시겠습니까?',
                                          () async {
                                        await videoUpdate().then((value) {
                                          showOnlyLoginCheckDialog(
                                              context, '수정이 완료되었습니다.', () {
                                            Get.back();
                                            Get.back();
                                            Get.back();
                                          });
                                        });
                                      });
                                    } else {
                                      await _updateTestSave().then((value) {
                                        showOnlyLoginCheckDialog(
                                            context, '등록이 완료되었습니다.', () {
                                          Get.back();
                                          Get.back();
                                        });
                                      });
                                    }
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                        child: Text(
                                      '저장',
                                      style: f16Whitew700,
                                    )),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff070707),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                              width: Get.width,
                              child: TextFormFields(
                                controller: _videoTitleController,
                                hintText: '강의명을 입력해주세요',
                                surffixIcon: '0',
                                obscureText: true,
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            SizedBox(
                              width: Get.width,
                              height: 1,
                              child: Divider(
                                thickness: 1,
                                color: const Color(0xffDADADA),
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: Get.width * 0.3,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '강의 파일',
                                        style: f18w400,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        width: Get.width * 0.2,
                                        height: 50,
                                        child: ElevatedButton(
                                            onPressed: () async {
                                              FilePickerResult? result =
                                                  await FilePicker.platform
                                                      .pickFiles(
                                                type: FileType.video,
                                              );
                                              if (result == null) return;
                                              pickedFile = result.files.first;
                                              uploadfile =
                                                  result.files.single.bytes!;
                                              if (pickedFile != null) {
                                                isfilePath = '11';
                                                videoName = '${DateTime.now()}';
                                                _initializeVideoPlayer(
                                                    uploadfile);
                                                a = 1;
                                              }
                                              setState(() {});
                                            },
                                            style: ButtonStyle(
                                              shape: MaterialStateProperty.all<
                                                      RoundedRectangleBorder>(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(8.0),
                                              )),
                                              padding: MaterialStateProperty
                                                  .all<EdgeInsets>(
                                                      EdgeInsets.symmetric(
                                                          vertical: 18.5,
                                                          horizontal: 100)),
                                              backgroundColor:
                                                  MaterialStateProperty.all<
                                                      Color>(textFormColor),
                                              splashFactory:
                                                  NoSplash.splashFactory,
                                              elevation: MaterialStateProperty
                                                  .all<double>(0.0),
                                            ),
                                            child: Text('찾아보기',
                                                style: f16w700primary)),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Text(
                                        '비밀번호',
                                        style: f18w400,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        width: Get.width * 0.2,
                                        child: TextFormFields(
                                          controller: _testPwController,
                                          hintText: '비밀번호를 입력해 주세요',
                                          surffixIcon: '1',
                                          obscureText: _obscureText.isTrue,
                                          onTap: () {
                                            setState(() {
                                              _obscureText.value =
                                                  !_obscureText.value;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '강의',
                                      style: f24w700,
                                    ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    args.edit == 'true'
                                        ? Container(
                                            width: Get.width * 0.4,
                                            height: Get.height * 0.5,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 40, vertical: 40),
                                            child: Chewie(
                                                controller: _chewieController!))
                                        : Container(
                                            width: Get.width * 0.4,
                                            height: Get.height * 0.5,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 40, vertical: 40),
                                            child: a == 1
                                                ? Chewie(
                                                    controller:
                                                        _chewieController!)
                                                : null,
                                          ),
                                  ],
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Footer()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _initializeVideoPlayer(Uint8List videoBytes) async {
    final blob = html.Blob([videoBytes]);
    final videoUrl = html.Url.createObjectUrlFromBlob(blob);
    videoPlayerController = VideoPlayerController.network(videoUrl)
      ..initialize().then((value) {
        videoPlayerController!.seekTo(_currentPosition);
        setState(() {});
      });
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      // autoPlay: true,
      looping: false,
      progressIndicatorDelay:
          bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,
      hideControlsTimer: const Duration(seconds: 1),
    )..addListener(_reInitListener);
    if (_isPlaying) {
      _chewieController!.play();
    }
    // else{
    //   print('22');
    //   _chewieController!.pause();
    // }
    // // await videoPlayerController!.initialize();
    // _initializeVideoPlayerFuture = videoPlayerController!.initialize();
    // videoPlayerController!.setLooping(true);
    // _createChewieController();
    // // videoPlayerController!.play();
    setState(() {});
  }

  /// 저장하기 버튼
  Future<void> _updateTestSave() async {
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());

    setState(() {
      _imageLoading = true;
    });
    _imageLoading == true
        ? showDialog(
            barrierDismissible: false,
            builder: (ctx) {
              return Center(child: LoadingBodyScreen());
            },
            context: context,
          )
        : Container();
    final CollectionReference ref =
        FirebaseFirestore.instance.collection('video');
    ref.add({
      'title': '${_videoTitleController.text}',
      'teacherName': '${us.userList[0].nickName}',
      'pw': '${_testPwController.text}',
      'videoName': '${videoName}',
      'docId': '',
      'createDate': '${DateTime.now()}',
      'teacherDocId': '${us.userList[0].docId}',
      'state': '대기'
    }).then((doc) async {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('video').doc(doc.id);
      await userDocRef.update({'docId': '${doc.id}'});
    });
    if (isfilePath == '11') {
      final ref = FirebaseStorage.instance
          .ref()
          .child('video')
          .child('${us.userList[0].docId}')
          .child('${videoName}.mp4');
      UploadTask uploadTask = ref.putData(
        uploadfile,
        SettableMetadata(contentType: 'video/mp4'),
      );
      final snapshot = await uploadTask.whenComplete(() => null);
    }
    setState(() {
      _imageLoading = false;
      Navigator.pop(context);
    });
  }

  /// 수정하기 버튼
  Future<void> videoUpdate() async {
    final args = ModalRoute.of(context)!.settings.arguments as VideoUpload;
    final us = Get.put(UserState());
    int a = 0;
    setState(() {
      _imageLoading = true;
    });
    _imageLoading == true
        ? showDialog(
            barrierDismissible: false,
            builder: (ctx) {
              return Center(child: LoadingBodyScreen());
            },
            context: context,
          )
        : Container();
    DocumentReference doRef =
        FirebaseFirestore.instance.collection('video').doc('${args.docId}');
    doRef.update({
      'title': '${_videoTitleController.text}',
      'pw': '${_testPwController.text}',
      'videoName': '${videoName}',
    });
    if (isfilePath == '11') {
      final ref = FirebaseStorage.instance
          .ref()
          .child('video')
          .child('${us.userList[0].docId}')
          .child('${videoName}.mp4');
      UploadTask uploadTask = ref.putData(
        uploadfile,
        SettableMetadata(contentType: 'video/mp4'),
      );
      final snapshot = await uploadTask.whenComplete(() => null);
    }
    setState(() {
      _imageLoading = false;
      Navigator.pop(context);
    });
  }

  void _reInitControllers() {
    _chewieController?.removeListener(_reInitListener);
    _currentPosition = videoPlayerController!.value.position;
    _isPlaying = _chewieController!.isPlaying;
    _initializeVideoPlayer(uploadfile);
  }

  void _reInitListener() {
    if (!_chewieController!.isFullScreen) {
      _reInitControllers();
    }
  }
}
