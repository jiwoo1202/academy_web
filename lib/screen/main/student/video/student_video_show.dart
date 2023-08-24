import 'dart:async';
import 'dart:typed_data';

import 'package:academy/components/footer/footer.dart';
import 'package:academy/provider/user_state.dart';
import 'package:academy/util/loading.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:video_player/video_player.dart';
import 'dart:html' as html;
import 'package:http/http.dart' as http;

import '../../../../components/dialog/showAlertDialog.dart';
import '../../../../components/tile/textform_field.dart';
import '../../../../firebase/firebase_community.dart';
import '../../../../firebase/firebase_job.dart';
import '../../../../firebase/firebase_user.dart';
import '../../../../firebase/videoCommentWrite.dart';
import '../../../../util/font/font.dart';
import '../../../../util/padding.dart';
import '../../../../util/refresh_manager.dart';
class StudentVideoShow extends StatefulWidget {
  static final String id = '/student_video_show';
  final String? videoName;
  final String? docId;
  final String? teacherDocId;
  final String? title;
  const StudentVideoShow({Key? key, this.videoName, this.docId, this.teacherDocId, this.title}) : super(key: key);

  @override
  State<StudentVideoShow> createState() => _StudentVideoShowState();
}

class _StudentVideoShowState extends State<StudentVideoShow> {
   VideoPlayerController? videoPlayerController;
   ChewieController? _chewieController;
   TextEditingController commentController = TextEditingController();
   TextEditingController editController = TextEditingController();
   TextEditingController reportController = TextEditingController();
  Duration _currentPosition = Duration.zero;
  int? bufferDelay;
  bool _isPlaying = false;
   bool _isLoading = true;
  late Uint8List uploadfile;
   bool _showControls = false;
   List<bool> _isAnn = [];
   List commentList = [];
   final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = new GlobalKey<RefreshIndicatorState>();
  @override
  void initState() {
    final us = Get.put(UserState());
    Future.delayed(Duration.zero,()async{
      final args = ModalRoute.of(context)!.settings.arguments as StudentVideoShow;
      final videoBytes = await http.readBytes(Uri.parse('https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/video%2F${args.teacherDocId}%2F${args.videoName}.mp4?alt=media'));
      uploadfile = await http.readBytes(Uri.parse('https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/video%2F${args.teacherDocId}%2F${args.videoName}.mp4?alt=media'));
      _initializeVideoPlayer(videoBytes);
      await _refresh();

      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }
   void dispose() {
     videoPlayerController?.dispose();
     _chewieController?.dispose();
     super.dispose();
   }
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as StudentVideoShow;
    final us =Get.put(UserState());
    return WillPopScope(
      onWillPop: (){
        return onTerminated(context);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xff270BD3),
          title: Text(
            '${args.title}',
            style: f24w500,
          ),
          centerTitle: true,
        ),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          onRefresh: () async {
            await _refresh().then((value){
              setState(() {});
            });
          },
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: _isLoading
                ? LoadingBodyScreen():
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 320, left: 320,top: 100),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: Get.width * 0.8,
                        height: Get.height * 0.5,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Color(0xff3A8EFF))
                        ),
                          child: _chewieController!=null?Chewie(controller: _chewieController!):LoadingBodyScreen()
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Text('댓글 (${commentList.length})', style: f16w400,),
                      ),
                      SizedBox(
                        height: 16,
                      ),
                      Container(
                        width: Get.width,
                        child: TextFormFields(
                            controller: commentController,
                            obscureText: true,
                            textOnTap: () async {
                              if (commentController.text.trim().isEmpty == true) {
                                showOnlyConfirmDialog(context, '댓글을 입력해 주세요');
                              } else {
                                await videoCommentWrite(
                                    commentController.text, '${args.docId}');
                                showConfirmTapDialog(context, '댓글이 입력되었습니다', ()async {
                                  await _refreshIndicatorKey.currentState?.show();
                                  commentController.text = '';
                                  Get.back();
                                });
                              }
                            },
                            hintText: '댓글을 입력해주세요',
                            surffixIcon: '2'),
                      ),
                      const SizedBox(height: 10,),
                      ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          itemCount: commentList.length,
                          shrinkWrap: true,
                          itemBuilder: (_, idx) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                      padding: ph24,
                                      child: Text(
                                        '${commentList[idx]['nickName']}',
                                        style: f14w400,
                                      ),
                                    ),
                                    Spacer(),
                                    Theme(
                                      data: Theme.of(context).copyWith(
                                        highlightColor: Colors.transparent,
                                        splashColor: Colors.transparent,
                                      ),
                                      child: PopupMenuButton(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(8)),
                                          offset: const Offset(-20, 40),
                                          icon: Container(
                                            height: 15,
                                            width: 20,
                                            alignment:
                                            Alignment.centerRight,
                                            child: SvgPicture.asset(
                                              'assets/icon/more_button.svg',
                                              height: 15,
                                              width: 20,
                                            ),
                                          ),
                                          itemBuilder: (context) => [
                                            PopupMenuItem(
                                                padding:
                                                EdgeInsets.zero,
                                                child: Column(
                                                  children: [
                                                    Center(
                                                      child: _isAnn[idx]
                                                          ? const Text('수정하기', style: TextStyle(
                                                          fontSize: 14,
                                                            height: 1,
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.bold,
                                                            fontFamily: 'NotoSansKr'),
                                                      )
                                                          : const Text('신고하기',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            height: 1,
                                                            color: Colors.black,
                                                            fontWeight: FontWeight.bold,
                                                            fontFamily: 'NotoSansKr'),
                                                      ),
                                                    ),
                                                    _isAnn[idx] ? Divider(
                                                      thickness: 1,
                                                    )
                                                        : Container(),
                                                  ],
                                                ),
                                                value: 1,
                                                onTap: () {
                                                  if (_isAnn[idx] == false) {
                                                    ///comment 차단
                                                    Future.delayed(
                                                        Duration.zero, () async {
                                                          showEditDialog(context, '신고 사유를 입력해주세요', () async{
                                                            await videoCommentBlock('${us.userList[0].docId}', commentList[idx]['id']);
                                                            await userGet(RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
                                                            Get.back();
                                                            await showOnlyConfirmDialog(context, '신고가 접수되었습니다');
                                                            await _refreshIndicatorKey.currentState?.show();
                                                            reportController.text = '';
                                                                  }, reportController);
                                                        });
                                                  }
                                                  else {
                                                    ///comment 수정
                                                    setState(() {
                                                      editController.text = '${commentList[idx]['body']}';
                                                    });
                                                    Future.delayed(Duration.zero, () async {
                                                          setState(() {
                                                            editController.text = '${commentList[idx]['body']}';
                                                          });
                                                          showEditDialog(context, '댓글 수정하기',
                                                                  () async {
                                                                  await videoCommentUpdate(commentList[idx]['docId'], editController.text, '${args.docId}');
                                                                  Get.back();
                                                                  await showOnlyConfirmDialog(context, '댓글이 수정되었습니다');
                                                                  await _refreshIndicatorKey.currentState?.show();
                                                                  editController.text = '';
                                                              }, editController);
                                                          commentController.text = '';
                                                        });
                                                   }
                                                }),
                                            PopupMenuItem(
                                                height: 0,
                                                padding:
                                                EdgeInsets.zero,
                                                child: _isAnn[idx]
                                                    ? Column(
                                                  children: [
                                                    Center(
                                                        child:
                                                        const Text(
                                                          '삭제하기',
                                                          style:
                                                          f14w500,
                                                        )),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                  ],
                                                )
                                                    : Container(),
                                                value: 2,
                                                onTap: () {
                                                  Future.delayed(
                                                      Duration.zero,
                                                          () async {
                                                        showComponentDialog(context, '삭제 하시겠습니까?',
                                                                () async {
                                                                  await vidoeCommentDelete('${args.docId}','${commentList[idx]['docId']}');
                                                                  Get.back();
                                                                  await showOnlyConfirmDialog(context, '댓글이 삭제 되었습니다');
                                                                  await _refreshIndicatorKey.currentState?.show();
                                                                });
                                                      });
                                                }),
                                          ]),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: ph24,
                                  child: Text(
                                    '${commentList[idx]['body']}',
                                    //commentBody[idx]
                                    style: f16w400,
                                  ),
                                ),
                                SizedBox(
                                  height: 10,
                                )
                              ],
                            );
                          }),
                    ],
                  ),
                ),
                SizedBox(
                  height: 26,
                ),
                Footer()
              ],
            ),
          ),
        )
      ),
    );
  }
  Future<void> _initializeVideoPlayer(Uint8List videoBytes) async {
    final blob = html.Blob([videoBytes]);
    final videoUrl = html.Url.createObjectUrlFromBlob(blob);
    videoPlayerController = VideoPlayerController.network(videoUrl)
      ..initialize().then((value) {
        videoPlayerController!.seekTo(_currentPosition);
        _isPlaying = _chewieController!.videoPlayerController.value.isPlaying;
        setState(() {});
      });
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController!,
      // autoPlay: true,
      aspectRatio: 16/9,
      deviceOrientationsAfterFullScreen:[DeviceOrientation.portraitUp] ,
      looping: false,
      progressIndicatorDelay: bufferDelay != null ? Duration(milliseconds: bufferDelay!) : null,
      // hideControlsTimer: _isPlaying?Duration(seconds: 2):Duration(days: 1),
    )..addListener(_reInitListener);
    if (_isPlaying) {
      _chewieController!.play();
    }
    RawKeyboard.instance.addListener((event) {
      if (event is RawKeyDownEvent) {
        if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
          // 화살표 왼쪽 키를 눌렀을 때
          final currentPosition = _chewieController!.videoPlayerController.value.position;
          final newPosition = currentPosition - Duration(seconds: 10);
          _chewieController!.videoPlayerController.seekTo(newPosition);
        } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
          // 화살표 오른쪽 키를 눌렀을 때
          final currentPosition = _chewieController!.videoPlayerController.value.position;
          final newPosition = currentPosition + Duration(seconds: 10);
          _chewieController!.videoPlayerController.seekTo(newPosition);
        }
        else if (event.logicalKey == LogicalKeyboardKey.escape) {
          // ESC 키를 눌렀을 때
          if (_chewieController!.isFullScreen) {
            _chewieController!.exitFullScreen();
          }
        }
      }
    });
    setState(() {});
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
  
   Future<void> _refresh() async {
    final us =Get.put(UserState());
    final args = ModalRoute.of(context)!.settings.arguments as StudentVideoShow;
     List a = await videoBlockExceptGet('${args.docId}');

     commentList = [];
    _isAnn = [];
    for(int i=0;i<a.length;i++){
      if(!us.userList[0].isBanned!.contains('${a[i]['id']}')){
        commentList.add(a[i]);
        _isAnn.add(commentList[commentList.length -1]['id'] == '${us.userList[0].phoneNumber}');
      }
    }
   }

   Future<bool> onTerminated(BuildContext context) async {
     return showComponentDialog(context, '강의를 종료하겠습니까?', () {
       Get.back();
       Get.back();
     });
   }
}
