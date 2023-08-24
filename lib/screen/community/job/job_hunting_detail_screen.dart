import 'dart:convert';

import 'package:academy/util/padding.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../components/appbar/appbars.dart';
import '../../../components/community/community_detail.dart';
import '../../../components/dialog/showAlertDialog.dart';
import '../../../components/footer/footer.dart';
import '../../../components/tile/textform_field.dart';
import '../../../firebase/firebase_community.dart';
import '../../../firebase/firebase_job.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/job_state.dart';
import '../../../provider/user_state.dart';
import '../../../util/click_full_image.dart';
import '../../../util/colors.dart';
import '../../../util/font/font.dart';
import '../../../util/loading.dart';
import '../../../util/refresh_manager.dart';
import '../../login/login_main_screen.dart';
import '../../mypage/mypage/mypage_screen.dart';
import '../story/story_write_screen.dart';
import 'job_hunting_screen.dart';
import 'package:universal_html/html.dart' as html;

class JobHuntingDetailScreen extends StatefulWidget {
  final String? docId;
  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;
  static final String id = '/job_detail';

  const JobHuntingDetailScreen({Key? key, this.docId, this.refreshIndicatorKey})
      : super(key: key);

  @override
  State<JobHuntingDetailScreen> createState() => _JobHuntingDetailScreenState();
}

class _JobHuntingDetailScreenState extends State<JobHuntingDetailScreen> {
  CarouselController carouselController = CarouselController();
  TextEditingController commentController = TextEditingController();
  TextEditingController editController = TextEditingController();
  TextEditingController reportController = TextEditingController();
  List _commentsBlockList = [];
  List _jobList = [];
  List<bool> _isAnn = [];
  int _numLines = 0;
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  double? _lineHeight;
  int currentIdx = 0;

  @override
  void initState() {
    //comment 가져오기
    Future.delayed(Duration.zero, () async {
      final us = Get.put(UserState());
      final js = Get.put(JobState());
      await userGet(
          RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
      us.isLogin.value = RefreshManager.getCookie('type');
      if (us.isLogin == '' || us.userList.length == 0) {

        showConfirmTapDialog(context, '로그인 후에 이용할 수 있습니다', () {
          Get.offAllNamed(LoginMainScreen.id);
        });
      }
      try {
        final args = ModalRoute.of(context)!.settings.arguments
            as JobHuntingDetailScreen;
        RefreshManager.addToCookie('job_docId', args.docId!);
        js.selectJobTile.value = await jobGet(args.docId!);
        js.jobDocId.value = args.docId!;
        js.jobbody.value = js.selectJobTile[0]['body'];
        js.jobHasImage.value = js.selectJobTile[0]['hasImage'];
        js.jobTitle.value = js.selectJobTile[0]['title'];
        js.jobList.value = js.selectJobTile[0]['images'];
        js.jobTeacher.value = js.selectJobTile[0]['teacher'];
        js.jobCreateDate.value = js.selectJobTile[0]['createDate'];
      } catch (e) {
        // js.selectJobTile.add();

        js.selectJobTile.value = await jobGet(RefreshManager.getCookie('job_docId'));
        js.jobDocId.value = RefreshManager.getCookie('job_docId');
        js.jobbody.value = js.selectJobTile[0]['body'];
        js.jobHasImage.value = js.selectJobTile[0]['hasImage'];
        js.jobTitle.value = js.selectJobTile[0]['title'];
        js.jobList.value = js.selectJobTile[0]['images'];
        js.jobTeacher.value = js.selectJobTile[0]['teacher'];
        js.jobCreateDate.value = js.selectJobTile[0]['createDate'];
      }
      // await commentOrderBy('${widget.docId}', 'date');
      _commentsBlockList =
          await jobBlockExceptGet(RefreshManager.getCookie('job_docId'));
      if (_commentsBlockList.isNotEmpty) {

        for (int i = 0; i < _commentsBlockList.length; i++) {
          _isAnn.add(
              _commentsBlockList[i]['id'] == '${us.userList[0].phoneNumber}');
        }
      }
      setState(() {
        _isLoading = false;
      });
    });
    // List commentId = ['123','456'];
    // List commentBody = ['fsdafdasfadsf','asdgdsagadsg'];
    super.initState();
  }

  @override
  void dispose() {
    commentController.dispose();
    editController.dispose();
    reportController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final js = Get.put(JobState());
    final us = Get.put(UserState());
    return WillPopScope(
      onWillPop: () {
        return GetPlatform.isWeb
            ? Future(() {
                // Get.offAllNamed(JobHuntingScreen.id);
                return true;
              })
            : onTerminated(context);
      },
      child: Scaffold(
        backgroundColor: backColor,
        appBar: Appbars(us: us, context: context),
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          triggerMode: RefreshIndicatorTriggerMode.anywhere,
          onRefresh: () async {
            await _refresh();
          },
          child: _isLoading
              ? LoadingBodyScreen()
              : ScrollConfiguration(
            behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
            child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
                    children: [
                      Container(margin: EdgeInsets.symmetric(horizontal: Get.width * 0.15),
                        width: Get.width * 0.8,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40,),
                            Container(
                              child: Row(mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      Get.back();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Center(child: Text('목록으로', style: f16w700,)),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffffffff),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          width: 1,
                                          color: const Color(0xff535353),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12,),
                                  us.userList[0].phoneNumber == js.jobTeacher.value ?
                                  GestureDetector(
                                    onTap:() async {
                                      showComponentDialog(context, '삭제하시겠습니까?', () async{
                                        if (us.userList[0].phoneNumber ==
                                            js.jobTeacher.value) {
                                          await _jobDelete(RefreshManager.getCookie(
                                              'job_docId'));
                                          Get.back();
                                          Get.back();
                                          await showOnlyConfirmDialog(
                                              context, '삭제 되었습니다');
                                          _refreshIndicatorKey.currentState?.show();
                                        }
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Center(child: Text('삭제', style: f16w700,)),
                                      decoration: BoxDecoration(
                                        color: const Color(0xffffffff),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          width: 1,
                                          color: const Color(0xff535353),
                                        ),
                                      ),
                                    ),
                                  ) : Container(),
                                  const SizedBox(width: 12,),
                                  us.userList[0].phoneNumber == js.jobTeacher.value ?
                                  GestureDetector(
                                    onTap: () {
                                      Future.delayed(Duration.zero, () {
                                        Get.toNamed(StoryWriteScreen.id,arguments: StoryWriteScreen(
                                          state: 'edit',
                                          whichScreen: 'job',
                                        ));
                                      });
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.all(12.0),
                                      child: Center(child: Text('수정', style: f16Whitew700,)),
                                      decoration: BoxDecoration(
                                        color: const Color(0xff070707),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ) : Container(),
                                ],
                              ),
                            ),
                            const SizedBox(height: 54,),

                            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Container(
                                width: Get.width * 0.32,
                                child: '${js.jobHasImage}' == 'true'
                                    ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Container(
                                      width: Get.width * 0.5,
                                      padding: ph24,
                                      child: CarouselSlider(
                                        items: [
                                          for (int i = 0; i < js.jobList.length; i++)
                                            'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/picture'
                                                '%2F${js.jobTeacher.value}%2F${js.jobDocId.value}%2F${js.jobList[i]}?alt=media'
                                          //   'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/asd.png?alt=media&token=d3708419-809b-4c8e-bd69-bd6bdfa002a6'
                                        ]
                                            .map((item) => ClipRRect(
                                          borderRadius:
                                          BorderRadius.all(Radius.circular(8.0)),
                                          child: InkWell(
                                              onTap: () {
                                                Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            clickFullImages(
                                                                listImagesModel: [
                                                                  for (int i = 0; i < js.jobList.length; i++)
                                                                    'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/picture'
                                                                        '%2F${js.jobTeacher.value}%2F${js.jobDocId.value}%2F${js.jobList[i]}?alt=media'
                                                                ],
                                                                current:
                                                                currentIdx)));
                                              },
                                              child: ExtendedImage.network(
                                                item,
                                                fit: kIsWeb
                                                    ? BoxFit.contain
                                                    : BoxFit.cover,
                                                cache: true,
                                                enableLoadState: false,
                                              )),
                                        ))
                                            .toList(),
                                        carouselController: carouselController,
                                        options: CarouselOptions(
                                          autoPlay: false,
                                          padEnds: false,
                                          enlargeCenterPage: false,
                                          disableCenter: true,
                                          height: Get.height * 0.3,
                                          viewportFraction: 1,
                                          onPageChanged: (index, reason) {
                                            setState(() {
                                              currentIdx = index;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      bottom: 20,
                                      child: AnimatedSmoothIndicator(
                                        activeIndex: currentIdx,
                                        count: js.jobList.length,
                                        effect: CustomizableEffect(
                                          activeDotDecoration: DotDecoration(
                                            width: 12,
                                            height: 8,
                                            color: nowColor,
                                            rotationAngle: 180,
                                            verticalOffset: -5,
                                            borderRadius: BorderRadius.circular(16),
                                          ),
                                          dotDecoration: DotDecoration(
                                            width: 12,
                                            height: 8,
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(16),
                                            verticalOffset: 0,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                )
                                    : Container(),
                              ),

                              const SizedBox(width: 20,),

                              Container( width: Get.width * 0.32,
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                                    Text('${js.jobTeacher}', style: f16w400,),
                                    SizedBox(width: 10,),
                                    Text(
                                      int.parse(DateTime.now()
                                          .difference(DateTime.parse('${js.selectJobTile[0]['createDate']}'))
                                          .inMinutes
                                          .toString()) <
                                          60
                                          ? '${int.parse(DateTime.now().difference(DateTime.parse('${js.selectJobTile[0]['createDate']}')).inMinutes.toString())}분 전'
                                          : int.parse(DateTime.now()
                                          .difference(
                                          DateTime.parse('${js.selectJobTile[0]['createDate']}')).inHours.toString()) < 24
                                          ? '${int.parse(DateTime.now().difference(DateTime.parse('${js.selectJobTile[0]['createDate']}')).inHours.toString())}시간 전'
                                          : '${int.parse(DateTime.now().difference(DateTime.parse('${js.selectJobTile[0]['createDate']}')).inDays.toString())}일 전',
                                      style: f14w400greyA,),
                                  ],
                                  ),
                                  const SizedBox(height: 16,),

                                  Container(width: Get.width,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                      border: Border.all(
                                        width: 1,
                                        color: cameraBackColor,
                                      ),
                                    ),
                                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                      Text('${js.jobTitle.value}', style: f21w700,),
                                      const SizedBox(height: 20,),
                                      Text('${js.jobbody.value}', style: f16w400,),
                                      const SizedBox(height: 20,),
                                      Text(
                                        '성별 : ${js.selectJobTile[0]['gender']}',
                                        style: f14w400,
                                      ),
                                      const SizedBox(height: 20,),
                                      Text(
                                        '나이 : ${js.selectJobTile[0]['age']}살 ${js.selectJobTile[0]['ageValue']}',
                                        style: f14w400,
                                      ),
                                      const SizedBox(height: 20,),
                                      Text(
                                            '급여 : ${js.selectJobTile[0]['payValue']} ${js.selectJobTile[0]['pay']} '
                                                '${js.selectJobTile[0]['pay'] == '협의' ? '' : '만원'}',
                                            style: f14w400,
                                          ),
                                      const SizedBox(height: 20,),
                                      Text(
                                        '시간 : ${js.selectJobTile[0]['openH'].toString().padLeft(2, '0')} : '
                                            '${js.selectJobTile[0]['openM'].toString().padLeft(2, '0')} ~ '
                                            '${js.selectJobTile[0]['closeH'].toString().padLeft(2, '0')} : '
                                            '${js.selectJobTile[0]['closeM'].toString().padLeft(2, '0')}',
                                        style: f14w400,
                                      ),
                                    ],),
                                  ),
                                  const SizedBox(height: 16,),

                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                    child: Text('댓글 (${_commentsBlockList.length})', style: f16w400,),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                                    child: TextFormFields(
                                        controller: commentController,
                                        obscureText: true,
                                        textOnTap: () async {
                                          if (commentController.text.trim().isEmpty == true) {
                                            showOnlyConfirmDialog(context, '댓글을 입력해 주세요');
                                          } else {
                                            await communityCommentWrite(
                                                commentController.text, '${js.jobDocId.value}');
                                            showConfirmTapDialog(context, '댓글이 입력되었습니다', () {
                                              _refreshIndicatorKey.currentState?.show();
                                              commentController.text = '';
                                              Get.back();
                                            });
                                          }
                                        },
                                        hintText: '댓글을 입력해주세요',
                                        surffixIcon: '2'),
                                  ),
                                  const SizedBox(height: 16,),
                                  ListView.builder(
                                      physics: const ClampingScrollPhysics(),
                                      itemCount: _commentsBlockList.length,
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
                                                    '익명 ${idx + 1}',
                                                    //commentId[idx] ${js.commentL.value == [] ? '' : js.commentL[0]['id'] }
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
                                                                      ? const Text(
                                                                    '수정하기',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                        14,
                                                                        height:
                                                                        1,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight: FontWeight
                                                                            .bold,
                                                                        fontFamily:
                                                                        'NotoSansKr'),
                                                                  )
                                                                      : const Text(
                                                                    '신고하기',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                        14,
                                                                        height:
                                                                        1,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight: FontWeight
                                                                            .bold,
                                                                        fontFamily:
                                                                        'NotoSansKr'),
                                                                  ),
                                                                ),
                                                                _isAnn[idx]
                                                                    ? Divider(
                                                                  thickness:
                                                                  1,
                                                                )
                                                                    : Container(),
                                                              ],
                                                            ),
                                                            value: 1,
                                                            onTap: () {
                                                              if (_isAnn[idx] ==
                                                                  false) {
                                                                ///comment 차단
                                                                Future.delayed(
                                                                    Duration.zero,
                                                                        () async {
                                                                      showEditDialog(
                                                                          context,
                                                                          '신고 사유를 입력해주세요',
                                                                              () {
                                                                            Get.back();
                                                                            showConfirmTapDialog(
                                                                                context,
                                                                                '신고했습니다',
                                                                                () async {
                                                                                  await firebaseBlockCreate(
                                                                                    '${us.userList[0].phoneNumber}',
                                                                                    '${_commentsBlockList[idx]['id']}',
                                                                                    'jobHunting',
                                                                                    'true',
                                                                                    '${_commentsBlockList[idx]['docId']}',
                                                                                  );
                                                                                });
                                                                            GetPlatform.isWeb ? html.window.location.reload()
                                                                                : _refreshIndicatorKey.currentState?.show();
                                                                            commentController.text = '';
                                                                            Get.back();
                                                                          }, reportController);
                                                                    });
                                                              } else {
                                                                ///comment 수정
                                                                Future.delayed(
                                                                    Duration.zero,
                                                                        () async {
                                                                      setState(() {
                                                                        editController.text = _commentsBlockList[idx]['body'];
                                                                      });
                                                                      showEditDialog(context, '댓글 수정하기', () async {
                                                                            if (editController.text.trim().isEmpty == true) {
                                                                              showOnlyConfirmDialog(
                                                                                  context,
                                                                                  '수정할 댓글을 입력해 주세요');
                                                                            }
                                                                            else {
                                                                              await _jobCommentUpdate(
                                                                                  '${_commentsBlockList[idx]['docId']}',
                                                                                  editController
                                                                                      .text,
                                                                                  RefreshManager
                                                                                      .getCookie(
                                                                                      'job_docId'));
                                                                              Get.back();
                                                                              await showOnlyConfirmDialog(
                                                                                  context,
                                                                                  '댓글이 입력되었습니다');
                                                                              _refreshIndicatorKey
                                                                                  .currentState
                                                                                  ?.show();
                                                                              commentController
                                                                                  .text = '';
                                                                              editController
                                                                                  .text = '';
                                                                            }
                                                                          }, editController);
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
                                                                    showComponentDialog(
                                                                        context,
                                                                        '삭제 하시겠습니까?',
                                                                            () async {
                                                                          _jobCommentDelete(
                                                                              _commentsBlockList[
                                                                              idx]
                                                                              ['docId'],
                                                                              RefreshManager
                                                                                  .getCookie(
                                                                                  'job_docId'));
                                                                          Get.back();
                                                                          await showOnlyConfirmDialog(
                                                                              context,
                                                                              '댓글이 삭제 되었습니다');
                                                                          _refreshIndicatorKey
                                                                              .currentState
                                                                              ?.show();
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
                                                '${_commentsBlockList[idx]['body']}',
                                                //commentBody[idx]
                                                style: f16w400,
                                              ),
                                            ),
                                          ],
                                        );
                                      }),
                                ],),
                              )
                            ],),
                          ],
                        ),
                      ),
                      const SizedBox(height: 40,),
                      Footer()
                    ],
                  ),
                ),
              ),
        ),
      ),
    );
  }

  Future<void> _refresh() async {
    Future.delayed(Duration.zero, () async {
      // await commentOrderBy('${widget.docId}', 'date');
      reportController.text = '';
      _commentsBlockList =
          await jobBlockExceptGet(RefreshManager.getCookie('job_docId'));
      final js = Get.put(JobState());
      for (int i = 0; i < _commentsBlockList.length; i++) {
        _isAnn.add(_commentsBlockList[i]['id'] == js.jobTeacher.value);
      }
      setState(() {});
    });
  }

  Future<void> _jobCommentUpdate(String docId, String changeValue, String widgetDocId) async {
    try {
      CollectionReference ref = FirebaseFirestore.instance
          .collection('jobHunting')
          .doc(widgetDocId)
          .collection('comments');
      QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();
      snapshot.docs[0].reference.update({'body': changeValue});
    } catch (e) {
      // print(e);
    }
  }

  Future<void> _jobDelete(String widgetDocId) async {
    try {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      CollectionReference ref = _firestore.collection('jobHunting');
      QuerySnapshot snapshot =
          await ref.where('docId', isEqualTo: widgetDocId).get();
      snapshot.docs[0].reference.delete();
    } catch (e) {
      // print(e);
    }
  }

  Future<void> _jobCommentDelete(String docId, String widgetDocId) async {
    try {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      CollectionReference ref = _firestore
          .collection('jobHunting')
          .doc(widgetDocId)
          .collection('comments');
      QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();
      snapshot.docs[0].reference.delete();
    } catch (e) {
      // print(e);
    }
  }

  Future<bool> onTerminated(BuildContext context) async {
    Get.back();
    return true;
  }
}
