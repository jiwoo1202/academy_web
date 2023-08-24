import 'dart:io';

import 'package:academy/screen/community/story/story_write_screen.dart';
import 'package:academy/screen/main/main_screen.dart';
import 'package:academy/util/refresh_manager.dart';
import 'package:academy/util/loading.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../components/community/community_body.dart';
import '../../../components/dialog/showAlertDialog.dart';
import '../../../components/footer/footer.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/community_state.dart';
import '../../../provider/user_state.dart';
import '../../../util/colors.dart';
import '../../../util/font/font.dart';
import '../../../util/padding.dart';
import '../../login/login_main_screen.dart';
import '../../mypage/mypage/mypage_screen.dart';
import '../job/job_hunting_screen.dart';
import '../notice/notice_main_screen.dart';
import 'story_detail_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StoryMainScreen extends StatefulWidget {
  static final String id = '/story_main';

  const StoryMainScreen({Key? key}) : super(key: key);

  @override
  State<StoryMainScreen> createState() => _StoryMainScreenState();
}

class _StoryMainScreenState extends State<StoryMainScreen> {
  CarouselController carouselController = CarouselController();
  List _communityList = [];
  List blockList = [];
  bool _isLoading = true;
  bool _scrollLoading = true;
  List _listforWeb = [];
  var qsStoryList = null;
  late ScrollController scrollController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  List<String> data = [];
  String initial = '';

  @override
  void initState() {
    final us = Get.put(UserState());
    scrollController = ScrollController();
    scrollController.addListener(() async {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        await communityStoryGet();
        _isLoading = false;
        setState(() {});
      }
    });

    Future.delayed(Duration.zero, () async {
      await userGet(RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
      us.isLogin.value = RefreshManager.getCookie('type');
      if (us.isLogin == '' || us.userList.length == 0) {

        showConfirmTapDialog(context, '로그인 후에 이용할 수 있습니다', () {
          Get.offAllNamed(LoginMainScreen.id);
        });
      }
      // await _refresh();
      await communityStoryGet();
      // await storyBlockExceptGet();
      if (kIsWeb) {
        _listforWeb = [];
        for (int ii = 0; ii < _communityList.length; ii++) {
          if (us.userList[0].isBanned!.contains(_communityList[ii]['id'])) {
          } else {
            _listforWeb.add(_communityList[ii]);
          }
        }
        data = us.userList[0].userType == '학생'
            ? ['이야기', '시험보기', '공지사항']
            : ['이야기', '시험올리기', '구인구직', '공지사항'];
        initial = data.first.toString();
      }

      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Get.put(CommunityState());
    final us = Get.put(UserState());
    return WillPopScope(
      onWillPop: () {
        return GetPlatform.isWeb ? Future(() {
          Get.offAllNamed(MainScreen.id);
          return true;
        }) : onTerminated(context);
      },
      child: Scaffold(
        body: us.isLogin == ''
            ? Container()
            : RefreshIndicator(
                key: _refreshIndicatorKey,
                triggerMode: RefreshIndicatorTriggerMode.anywhere,
                onRefresh: () async {
                  await _refresh();
                },
                child: _isLoading
                    ? LoadingBodyScreen()
                    : CommunityBody(
                        paddingSize: 0,
                        body: Transform.translate(
                          offset: Offset(0, 0),
                          child: ScrollConfiguration(
                                  behavior: ScrollConfiguration.of(context)
                                      .copyWith(scrollbars: false),
                                  child: SingleChildScrollView(
                                    physics: const ClampingScrollPhysics(),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          height: 20,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  (Get.width * 0.2 <= 171)
                                                      ? 20
                                                      : 40),
                                          child: GridView.builder(
                                              controller: scrollController,
                                              shrinkWrap: true,
                                              gridDelegate:
                                                  SliverGridDelegateWithFixedCrossAxisCount(
                                                crossAxisCount:
                                                    !context.isLargeTablet
                                                        ? 2
                                                        : 3,
                                                childAspectRatio: (1 / 1),
                                                mainAxisSpacing: 8,
                                                crossAxisSpacing: 8,
                                              ),
                                              itemCount: _listforWeb.length,
                                              itemBuilder: (context, idx) =>
                                                  // us.userList[0].isBanned!.contains(_communityList[idx]['id'])
                                                  //     ? Padding(padding: EdgeInsets.zero) :
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                      border: Border.all(
                                                        color: const Color(
                                                            0xffE9E9E9),
                                                      ),
                                                      color: Colors.white,
                                                    ),
                                                    child: GestureDetector(
                                                      behavior: HitTestBehavior
                                                          .opaque,
                                                      onTap: () async {
                                                        Get.toNamed(StoryDetailScreen.id,
                                                            arguments: StoryDetailScreen(
                                                              docId: _listforWeb[idx]['docId'],
                                                              id1: _listforWeb[idx]['id'],
                                                              ))!.then((value) => {
                                                          _refreshIndicatorKey.currentState?.show()});
                                                      },
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const SizedBox(
                                                            height: 8,
                                                          ),
                                                          _listforWeb[idx][
                                                                      'hasImage'] ==
                                                                  'false'
                                                              ? Container(
                                                                  width:
                                                                      Get.width *
                                                                          0.3,
                                                                  height:
                                                                      Get.width *
                                                                          0.2,
                                                                  padding: ph24,
                                                                  child: Image
                                                                      .asset(
                                                                    'assets/icon/noImg.png',
                                                                    fit: kIsWeb
                                                                        ? BoxFit
                                                                            .contain
                                                                        : BoxFit
                                                                            .cover,
                                                                  ))
                                                              : Container(
                                                                  width:
                                                                      Get.width *
                                                                          0.3,
                                                                  height:
                                                                      Get.width *
                                                                          0.2,
                                                                  padding: ph24,
                                                                  child:
                                                                      CarouselSlider(
                                                                    items: [
                                                                      'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/'
                                                                          'o/picture%2F${_listforWeb[idx]['id']}%2F${_listforWeb[idx]['docId']}'
                                                                          '%2F${_listforWeb[idx]['images'][0]}?alt=media'
                                                                    ]
                                                                        .map((item) =>
                                                                            ClipRRect(
                                                                              borderRadius: BorderRadius.all(Radius.circular(0.0)),
                                                                              child: InkWell(
                                                                                  onTap: () async {
                                                                                    Get.toNamed(StoryDetailScreen.id,
                                                                                        arguments: StoryDetailScreen(
                                                                                          docId: _listforWeb[idx]['docId'],
                                                                                          id1: _listforWeb[idx]['id'],
                                                                                          ))!.then((value) => {
                                                                                      _refreshIndicatorKey.currentState?.show()});
                                                                                  },
                                                                                  child: ExtendedImage.network(
                                                                                    item,
                                                                                    fit: kIsWeb ? BoxFit.contain : BoxFit.cover,
                                                                                    cache: true,
                                                                                    enableLoadState: false,
                                                                                  )),
                                                                            ))
                                                                        .toList(),
                                                                    carouselController:
                                                                        carouselController,
                                                                    options:
                                                                        CarouselOptions(
                                                                      enableInfiniteScroll:
                                                                          false,
                                                                      autoPlay:
                                                                          false,
                                                                      padEnds:
                                                                          false,
                                                                      enlargeCenterPage:
                                                                          false,
                                                                      disableCenter:
                                                                          true,
                                                                      // height: Get.height * 0.3,
                                                                      viewportFraction:
                                                                          1,
                                                                    ),
                                                                  ),
                                                                ),
                                                          _listforWeb[idx][
                                                                      'hasImage'] ==
                                                                  'false'
                                                              ? Container()
                                                              : SizedBox(
                                                                  height: 8,
                                                                ),
                                                          Padding(
                                                            padding: ph24,
                                                            child: Text(
                                                              '${_listforWeb[idx]['title']}',
                                                              style: Get.width *
                                                                          0.2 >=
                                                                      218
                                                                  ? f18w400el
                                                                  : (Get.width * 0.2 <=
                                                                              204 &&
                                                                          Get.width * 0.2 >
                                                                              171)
                                                                      ? f12w400el
                                                                      : (Get.width * 0.2 <= 171 &&
                                                                              Get.width * 0.2 >= 144)
                                                                          ? f10w400el
                                                                          : f16w400el, //: f14w400el,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: (Get.width *
                                                                            0.2 <=
                                                                        171 &&
                                                                    Get.width *
                                                                            0.2 >=
                                                                        144)
                                                                ? 0
                                                                : 8,
                                                          ),
                                                          Padding(
                                                            padding: ph24,
                                                            child: Text(
                                                              '${_listforWeb[idx]['body']}',
                                                              style: Get.width *
                                                                          0.2 >=
                                                                      218
                                                                  ? f16w400greyAel
                                                                  : (Get.width * 0.2 <=
                                                                              204 &&
                                                                          Get.width * 0.2 >
                                                                              171)
                                                                      ? f10w400greyAel
                                                                      : (Get.width * 0.2 <= 171 &&
                                                                              Get.width * 0.2 >= 144)
                                                                          ? f8w400greyAel
                                                                          : f14w400greyAel, //: f12w400greyAel,
                                                            ),
                                                          ),
                                                          SizedBox(
                                                            height: (Get.width *
                                                                            0.2 <=
                                                                        171 &&
                                                                    Get.width *
                                                                            0.2 >=
                                                                        144)
                                                                ? 0
                                                                : 8,
                                                          ),
                                                          Padding(
                                                            padding: ph24,
                                                            child: Text(
                                                              int.parse(DateTime
                                                                              .now()
                                                                          .difference(
                                                                              DateTime.parse(
                                                                            '${_listforWeb[idx]['createDate']}',
                                                                          ))
                                                                          .inMinutes
                                                                          .toString()) <
                                                                      5
                                                                  ? '방금 전'
                                                                  : int.parse(DateTime.now()
                                                                              .difference(DateTime.parse(
                                                                                '${_listforWeb[idx]['createDate']}',
                                                                              ))
                                                                              .inMinutes
                                                                              .toString()) <
                                                                          60
                                                                      ? '${int.parse(DateTime.now().difference(DateTime.parse(
                                                                            '${_listforWeb[idx]['createDate']}',
                                                                          )).inMinutes.toString())}분 전'
                                                                      : int.parse(DateTime.now()
                                                                                  .difference(DateTime.parse(
                                                                                    '${_listforWeb[idx]['createDate']}',
                                                                                  ))
                                                                                  .inHours
                                                                                  .toString()) <
                                                                              24
                                                                          ? '${int.parse(DateTime.now().difference(DateTime.parse(
                                                                                '${_listforWeb[idx]['createDate']}',
                                                                              )).inHours.toString())}시간 전'
                                                                          : '${int.parse(DateTime.now().difference(DateTime.parse(
                                                                                '${_listforWeb[idx]['createDate']}',
                                                                              )).inDays.toString())}일 전',
                                                              style: Get.width *
                                                                          0.2 >=
                                                                      218
                                                                  ? f16w400greyA
                                                                  : (Get.width * 0.2 <=
                                                                              204 &&
                                                                          Get.width * 0.2 >
                                                                              171)
                                                                      ? f10w400greyA
                                                                      : (Get.width * 0.2 <= 171 &&
                                                                              Get.width * 0.2 >= 144)
                                                                          ? f8w400greyA
                                                                          : f14w400greyA, //: f12w400greyA,
                                                            ),
                                                          ),
                                                          // const SizedBox(
                                                          //   height: 16,
                                                          // ),
                                                          // SizedBox(
                                                          //   width: Get.width,
                                                          //   height: 1,
                                                          //   child: Divider(
                                                          //     color: Colors.black,
                                                          //     thickness: 1,
                                                          //   ),
                                                          // ),
                                                          // const SizedBox(
                                                          //   height: 16,
                                                          // ),
                                                        ],
                                                      ),
                                                    ),
                                                  )),
                                        ),
                                        SizedBox(
                                          height: 100,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 24),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Footer(),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  ),
                                )

                        ),
                        floatingIcon: const Icon(Icons.edit),
                        floatingTap: () {
                          Get.toNamed(StoryWriteScreen.id)!.then((value) =>
                              {_refreshIndicatorKey.currentState?.show()});
                        },
                      ),
              ),
      ),
    );
  }

  Future<void> _refresh() async {
    Future.delayed(Duration.zero, () async {
      final us = Get.put(UserState());
      qsStoryList = null;
      // _communityList = [];
      // await storyBlockExceptGet();
      await communityStoryGet();

      _listforWeb = [];
      for (int ii = 0; ii < _communityList.length; ii++) {
        if (us.userList[0].isBanned!.contains(_communityList[ii]['id'])) {
        } else {
          _listforWeb.add(_communityList[ii]);
        }
      }

      await userGet(us.userList[0].id!, us.userList[0].pw!);
      _isLoading = false;
      setState(() {});
    });
  }

  Future<void> communityStoryGet() async {
    final us = Get.put(UserState());
    CollectionReference ref2 = FirebaseFirestore.instance.collection('block');
    QuerySnapshot snapshot2 = await ref2
        .where('blockId',
            isEqualTo:
                '${us.userList[0].phoneNumber}')
        .where('collectionName', isEqualTo: 'story')
        .where('commentField', isEqualTo: 'false')
        .get();
    final allData = snapshot2.docs.map((doc) => doc.data()).toList();
    List ls = allData;
    blockList = [];
    for (int i = 0; i < ls.length; i++) {
      blockList.add(ls[i]['blockDocId']);
    }

    CollectionReference _hosRef =
        FirebaseFirestore.instance.collection('story');
    if (qsStoryList != null) {
      qsStoryList = kIsWeb
          ? await _hosRef
              .orderBy('createDate', descending: true)
              .startAfter([_communityList.last['createDate']])
              .where('status', isEqualTo: '게시중')
              .get()
          : await _hosRef
              .orderBy('createDate', descending: true)
              .startAfter([_communityList.last['createDate']])
              .where('status', isEqualTo: '게시중')
              .limit(7)
              .get();
      final allData = qsStoryList.docs.map((doc) => doc.data()).toList();
      _communityList.addAll(allData);
    } else {
      qsStoryList = kIsWeb
          ? await _hosRef
              .orderBy('createDate', descending: true)
              .where('status', isEqualTo: '게시중')
              .get()
          : await _hosRef
              .orderBy('createDate', descending: true)
              .where('status', isEqualTo: '게시중')
              .limit(7)
              .get();
      final allData = qsStoryList.docs.map((doc) => doc.data()).toList();
      _communityList = allData;
    }
    setState(() {});
  }

  Future<bool> onTerminated(BuildContext context) async {
    return showComponentDialog(context, '앱을 종료하시겠습니까?', () {
      SystemNavigator.pop();
    });
  }
}
