import 'package:academy/components/tile/textform_field.dart';
import 'package:academy/provider/community_state.dart';
import 'package:academy/util/loading.dart';
import 'package:academy/util/padding.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../components/appbar/appbars.dart';
import '../../../components/community/community_detail.dart';
import '../../../components/dialog/showAlertDialog.dart';
import '../../../components/footer/footer.dart';
import '../../../firebase/firebase_community.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/user_state.dart';
import '../../../util/click_full_image.dart';
import '../../../util/colors.dart';
import '../../../util/font/font.dart';
import '../../../util/refresh_manager.dart';
import '../../login/login_main_screen.dart';
import '../../mypage/mypage/mypage_screen.dart';
import 'story_main_screen.dart';
import 'story_main_screen_web.dart';
import 'story_write_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:universal_html/html.dart' as html;

class StoryDetailScreen extends StatefulWidget {
  final String? docId;
  final String? id1;

  // final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;
  static final String id = '/story_detail';

  const StoryDetailScreen({
    Key? key,
    this.docId,
    this.id1,
    // this.refreshIndicatorKey
  }) : super(key: key);

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  CarouselController carouselController = CarouselController();
  TextEditingController commentController = TextEditingController();
  TextEditingController editController = TextEditingController();
  TextEditingController reportController = TextEditingController();
  List<bool> _isAnn = [];
  int _numLines = 0;
  int _count = 0;
  List _communityList = [];
  int currentIdx = 0;

  // List _commentsList = [];
  List _commentsBlockList = [];
  List commentId = ['123', '456'];
  List commentBody = ['fsdafdasfadsf', 'asdgdsagadsg'];
  double? _lineHeight;
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      final us = Get.put(UserState());
      await userGet(
          RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
      us.isLogin.value = RefreshManager.getCookie('type');
      if (us.isLogin == '' || us.userList.length == 0) {

        showConfirmTapDialog(context, '로그인 후에 이용할 수 있습니다', () {
          Get.offAllNamed(LoginMainScreen.id);
        });
      }
      try {
        final args = ModalRoute.of(context)!.settings.arguments as StoryDetailScreen;
        RefreshManager.addToCookie('story_docId', args.docId!);
        RefreshManager.addToCookie('story_id1', args.id1!);
        // await _refresh(args.docId, args.id1);
        await communityStoryGet(args.docId!, args.id1!);
        await commentsBlockExceptGet(args.docId!); //commentsGet();
      } catch (e) {
        await communityStoryGet(RefreshManager.getCookie('story_docId'), RefreshManager.getCookie('story_id1'));
        await commentsBlockExceptGet(RefreshManager.getCookie('story_docId'));
      }
      _isAnn.clear();
      for (int i = 0; i < _commentsBlockList.length; i++) {
        _isAnn.add(_commentsBlockList[i]['id'] == us.userList[0].phoneNumber);
      }

      setState(() {
        _isLoading = false;
      });
    });
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
    final us = Get.put(UserState());
    final cs = Get.put(CommunityState());
    return WillPopScope(
      onWillPop: () {
        return GetPlatform.isWeb
            ? Future(() {
                // Get.offAllNamed(StoryMainScreenWeb.id);
                return true;
              })
            : onTerminated(context);
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
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
                : Column(
                children: [
                  Expanded(
                    child: Container(margin: EdgeInsets.symmetric(horizontal: Get.width * 0.15),
                      width: Get.width * 0.8,
                      child: ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                        child: SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
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
                                    us.userList[0].phoneNumber == RefreshManager.getCookie('story_id1') ?
                                    GestureDetector(
                                      onTap: () {
                                        Future.delayed(Duration.zero, () {
                                          showComponentDialog(context, '삭제하시겠습니까?', () async {
                                            if (us.userList[0].phoneNumber == RefreshManager.getCookie('story_id1')) {
                                              await _communityDelete(RefreshManager.getCookie('story_docId'));
                                            }
                                            Get.back();
                                            await showConfirmTapDialog(
                                                context, '삭제되었습니다', () {
                                              Get.back();
                                              Get.back();
                                            });
                                            _refreshIndicatorKey.currentState
                                                ?.show();
                                          });
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
                                    us.userList[0].phoneNumber == RefreshManager.getCookie('story_id1') ?
                                    GestureDetector(
                                      onTap: () {
                                        Get.toNamed(StoryWriteScreen.id,arguments: StoryWriteScreen(
                                          state: 'edit',
                                          whichScreen: '',
                                        ));
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

                              // CommunityDetail(
                              //   who: _communityList[0]['name'],
                              //   dateTime: DateTime.now(),
                              //   docId: _communityList[0]['docId'],
                              //   hasImage: _communityList[0]['hasImage'],
                              //   createDate: _communityList[0]['createDate'],
                              //   image: _communityList[0]['images'],
                              //   id: _communityList[0]['id'],
                              //   carouselCon: carouselController,
                              //   title: _communityList[0]['title'],
                              //   body: _communityList[0]['body'],
                              //   commentCount: _count,
                              //   anonymous: false,
                              //   isMine: _communityList[0]['id'] ==
                              //       us.userList[0].phoneNumber,
                              //   //수정
                              //   anonymousCount: 0,
                              //   refreshIndicatorKey: _refreshIndicatorKey,
                              //   onTap4: () {},
                              // ),
                              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Container(
                                  width: Get.width * 0.32,
                                  child: _communityList[0]['hasImage'] == 'true'
                                      ? Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Container(
                                        width: Get.width * 0.5,
                                        padding: ph24,
                                        child: CarouselSlider(
                                          items: [
                                            for (int i = 0; i < _communityList[0]['images'].length; i++)
                                              'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/picture'
                                                  '%2F${_communityList[0]['id']}%2F${_communityList[0]['docId']}%2F${_communityList[0]['images'][i]}?alt=media'
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
                                                                    for (int i = 0; i < _communityList[0]['images'].length; i++)
                                                                      'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/picture'
                                                                          '%2F${_communityList[0]['id']}%2F${_communityList[0]['docId']}%2F${_communityList[0]['images'][i]}?alt=media'
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
                                          count: _communityList[0]['images'].length,
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
                                      Text('${_communityList[0]['name']}', style: f16w400,),
                                      SizedBox(width: 10,),
                                      Text(
                                        int.parse(DateTime.now()
                                            .difference(DateTime.parse('${_communityList[0]['createDate']}'))
                                            .inMinutes
                                            .toString()) <
                                            60
                                            ? '${int.parse(DateTime.now().difference(DateTime.parse('${_communityList[0]['createDate']}')).inMinutes.toString())}분 전'
                                            : int.parse(DateTime.now()
                                            .difference(
                                            DateTime.parse('${_communityList[0]['createDate']}')).inHours.toString()) < 24
                                            ? '${int.parse(DateTime.now().difference(DateTime.parse('${_communityList[0]['createDate']}')).inHours.toString())}시간 전'
                                            : '${int.parse(DateTime.now().difference(DateTime.parse('${_communityList[0]['createDate']}')).inDays.toString())}일 전',
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
                                        Text('${_communityList[0]['title']}', style: f21w700,),
                                        SizedBox(height: 20,),
                                        Text('${_communityList[0]['body']}', style: f16w400,)
                                      ],),
                                    ),
                                    const SizedBox(height: 16,),

                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                                      child: Text('댓글 (${_count})', style: f16w400,),
                                    ),
                                    Container( width: Get.width,
                                      child: TextFormFields(
                                          controller: commentController,
                                          obscureText: true,
                                          textOnTap: () async {
                                            if (commentController.text.trim().isEmpty ==
                                                true) {
                                              showOnlyConfirmDialog(
                                                  context, '댓글을 입력해 주세요');
                                            } else {
                                              await _communityCommentWrite(
                                                  commentController.text,
                                                  RefreshManager.getCookie(
                                                      'story_docId'));
                                              showConfirmTapDialog(
                                                  context, '댓글이 입력되었습니다', () {
                                                _refreshIndicatorKey.currentState
                                                    ?.show();
                                                commentController.text = '';
                                                Get.back();
                                              });
                                            }
                                          },
                                          hintText: '댓글을 입력해주세요',
                                          surffixIcon: '2'),
                                    ),
                                    SizedBox(height: 16,),

                                    ListView.builder(
                                        physics: const ClampingScrollPhysics(),
                                        itemCount: _commentsBlockList.length,
                                        shrinkWrap: true,
                                        itemBuilder: (_, idx) {
                                          return us.userList[0].isBanned!.contains(_commentsBlockList[idx]['id']) ? Container()
                                              : Column(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 16, top: 8),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                                  border: Border.all(
                                                    width: 1,
                                                    color: cameraBackColor,
                                                  ),
                                                ),
                                                child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        Text(
                                                          '${_commentsBlockList[idx]['name']}',
                                                          style: f14w700greyA,
                                                        ),
                                                        Spacer(),
                                                        Theme(
                                                          data: Theme.of(context)
                                                              .copyWith(
                                                            highlightColor:
                                                            Colors.transparent,
                                                            splashColor:
                                                            Colors.transparent,
                                                          ),
                                                          child: PopupMenuButton(
                                                              shape:
                                                              RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(8)),
                                                              offset:
                                                              const Offset(-20, 40),
                                                              icon: Container(
                                                                height: 15,
                                                                width: 20,
                                                                alignment: Alignment
                                                                    .centerRight,
                                                                child: SvgPicture.asset(
                                                                  'assets/icon/more_button.svg',
                                                                  width: 20,
                                                                  height: 20,
                                                                ),
                                                              ),
                                                              itemBuilder:
                                                                  (context) => [
                                                                PopupMenuItem(
                                                                    padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                    child:
                                                                    Column(
                                                                      children: [
                                                                        Center(
                                                                          child: _isAnn[idx] == true
                                                                              ? const Text(
                                                                            '수정하기',
                                                                            style: f14w500,
                                                                          )
                                                                              : const Text(
                                                                            '신고하기',
                                                                            style: f14w500,
                                                                          ),
                                                                        ),
                                                                        _isAnn[idx] ==
                                                                            true
                                                                            ? const Divider()
                                                                            : Container(),
                                                                      ],
                                                                    ),
                                                                    value: 1,
                                                                    onTap: () {
                                                                      if (_isAnn[
                                                                      idx] ==
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
                                                                                    showConfirmTapDialog(context,
                                                                                        '신고했습니다',
                                                                                            () async {
                                                                                          await firebaseBlockCreate(
                                                                                            '${us.userList[0].phoneNumber}',
                                                                                            _commentsBlockList[idx]['id'],
                                                                                            'story',
                                                                                            'true',
                                                                                            _commentsBlockList[idx]['docId'],
                                                                                          );
                                                                                          await _blockUpdate('${us.userList[0].id}', _commentsBlockList[idx]['id']);
                                                                                          GetPlatform.isWeb ? html.window.location.reload() : _refreshIndicatorKey.currentState?.show();
                                                                                          commentController.text = '';
                                                                                          Get.back();
                                                                                        });
                                                                                  }, reportController);
                                                                            });
                                                                      } else {
                                                                        ///comment 수정
                                                                        Future.delayed(
                                                                            Duration.zero,
                                                                                () async {
                                                                              setState(
                                                                                      () {
                                                                                    editController.text =
                                                                                    _commentsBlockList[idx]['body'];
                                                                                  });
                                                                              showEditDialog(
                                                                                  context,
                                                                                  '댓글 수정하기',
                                                                                      () async {
                                                                                    if (editController.text.trim().isEmpty ==
                                                                                        true) {
                                                                                      showOnlyConfirmDialog(context, '수정할 댓글을 입력해 주세요');
                                                                                    } else {
                                                                                      await _communityCommentUpdate(_commentsBlockList[idx]['docId'], editController.text, RefreshManager.getCookie('story_docId'));
                                                                                      Get.back();
                                                                                      await showOnlyConfirmDialog(context, '댓글이 입력되었습니다');
                                                                                      _refreshIndicatorKey.currentState?.show();
                                                                                      commentController.text = '';
                                                                                      editController.text = '';
                                                                                    }
                                                                                  }, editController);
                                                                            });
                                                                      }
                                                                    }),
                                                                PopupMenuItem(
                                                                    height: 0,
                                                                    padding:
                                                                    EdgeInsets
                                                                        .zero,
                                                                    child: _isAnn[idx] ==
                                                                        true
                                                                        ? Column(
                                                                      children: [
                                                                        Center(
                                                                            child: const Text(
                                                                              '삭제하기',
                                                                              style: f14w500,
                                                                            )),
                                                                        SizedBox(
                                                                          height: 8,
                                                                        ),
                                                                      ],
                                                                    )
                                                                        : Container(),
                                                                    value: 2,
                                                                    onTap: () {
                                                                      ///comment delete
                                                                      Future.delayed(
                                                                          Duration
                                                                              .zero,
                                                                              () async {
                                                                            showComponentDialog(
                                                                                context,
                                                                                '삭제 하시겠습니까?',
                                                                                    () async {
                                                                                  _communityCommentDelete(
                                                                                      _commentsBlockList[idx]['docId'],
                                                                                      RefreshManager.getCookie('story_docId'));
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
                                                    Text('${_commentsBlockList[idx]['body']}', style: f16w400,),
                                                  ],
                                                ),
                                              ),
                                              SizedBox(height: 20,)
                                            ],
                                          );
                                        }),
                                  ],),
                                )
                              ],),

                            ],
                          ),
                        ),
                      ),
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

  Future<void> _refresh() async {
    Future.delayed(Duration.zero, () async {
      final us = Get.put(UserState());
      await commentsBlockExceptGet(RefreshManager.getCookie('story_docId'));
      await communityStoryGet(RefreshManager.getCookie('story_docId'),
          RefreshManager.getCookie('story_id1'));
      reportController.text = '';
      // _communityList = [];
      _isAnn.clear();
      for (int i = 0; i < _commentsBlockList.length; i++) {
        _isAnn.add(_commentsBlockList[i]['id'] == us.userList[0].phoneNumber);
      }
      setState(() {});
    });
  }

  Future<void> communityStoryGet(String widgetDocId, String widgetId1) async {
    final cs = Get.put(CommunityState());

    CollectionReference ref = FirebaseFirestore.instance.collection('story');
    QuerySnapshot snapshot =
        await ref.where('docId', isEqualTo: widgetDocId).get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    _communityList = allData;
    cs.communityList.value = _communityList;
    cs.communDocId.value = widgetDocId;
    cs.storyId.value = widgetId1;
  }

  Future<void> _blockUpdate(String id, String bannedId) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('user');
    QuerySnapshot snapshot = await ref.where('id', isEqualTo: id).get();
    snapshot.docs[0].reference.update({
      'isBanned': FieldValue.arrayUnion([bannedId])
    });
  }

  Future<void> commentsBlockExceptGet(String widgetDocId) async {
    final us = Get.put(UserState());
    final cs = Get.put(CommunityState());

    CollectionReference ref = FirebaseFirestore.instance
        .collection('story')
        .doc(widgetDocId)
        .collection('comments');
    QuerySnapshot snapshot = await ref.get();
    final allData2 = snapshot.docs.map((doc) => doc.data()).toList();
    List ls2 = allData2;
    List ls3 = [];
    _count = allData2.length;
    for (int i = 0; i < ls2.length; i++) {
      if (us.userList[0].isBanned!.contains(ls2[i]['id'])) {
        _count--;
      }
    }
    _commentsBlockList = ls2;
  }

  Future<void> _communityCommentWrite(String body, String widgetDocId) async {
    final us = Get.put(UserState());
    CollectionReference ref = FirebaseFirestore.instance
        .collection('story')
        .doc(widgetDocId)
        .collection('comments');
    ref.add({
      'id': '${us.userList[0].phoneNumber}',
      'docId': '',
      'body': body,
      'status': '게시중',
      'type': '${us.userList[0].userType}',
      'name': '${us.userList[0].name}',
      'createDate': '${DateTime.now()}',
    }).then((doc) async {
      DocumentReference userDocRef = FirebaseFirestore.instance
          .collection('story')
          .doc(widgetDocId)
          .collection('comments')
          .doc(doc.id);
      await userDocRef.update({'docId': '${doc.id}'});
    });
  }

  Future<void> _communityCommentUpdate(
      String docId, String changeValue, String widgetDocId) async {
    try {
      CollectionReference ref = FirebaseFirestore.instance
          .collection('story')
          .doc(widgetDocId)
          .collection('comments');
      QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();
      snapshot.docs[0].reference.update({'body': changeValue});
    } catch (e) {
      // print(e);
    }
  }

  Future<void> _communityDelete(String widgetDocId) async {
    try {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      CollectionReference ref = _firestore.collection('story');
      QuerySnapshot snapshot =
          await ref.where('docId', isEqualTo: widgetDocId).get();
      snapshot.docs[0].reference.delete();
    } catch (e) {
      // print(e);
    }
  }

  Future<void> _communityCommentDelete(String docId, String widgetDocId) async {
    try {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      CollectionReference ref = _firestore
          .collection('story')
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
