import 'package:academy/screen/community/job/job_hunting_detail_screen.dart';
import 'package:academy/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../components/dialog/showAlertDialog.dart';
import '../../../components/footer/footer.dart';
import '../../../firebase/firebase_job.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/job_state.dart';
import '../../../provider/user_state.dart';
import '../../../util/font/font.dart';
import '../../../util/loading.dart';
import '../../../util/refresh_manager.dart';
import '../../login/login_main_screen.dart';
import '../../main/main_screen.dart';
import '../../main/student/student_screen.dart';
import '../../main/teacher/teacher_screen.dart';
import '../../mypage/mypage/mypage_screen.dart';
import '../notice/notice_main_screen.dart';
import '../story/story_main_screen.dart';
import '../story/story_write_screen.dart';

class JobHuntingScreen extends StatefulWidget {
  static final String id = '/job_hunting_screen_web';

  const JobHuntingScreen({Key? key}) : super(key: key);

  @override
  State<JobHuntingScreen> createState() => _JobHuntingScreenState();
}

class _JobHuntingScreenState extends State<JobHuntingScreen> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  List<String> data = [];
  String initial = '';
  bool _isLoading = true;
  late ScrollController scrollController;
  List _job = [];
  List _firebaseJobAll = [];

  @override
  void initState() {
    super.initState();
    //클릭한 타일의 정보 가져오기
    Future.delayed(Duration.zero, () async {
      final us = Get.put(UserState());
      await userGet(RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
      us.isLogin.value = RefreshManager.getCookie('type');
      if (us.isLogin == '' || us.userList.length == 0) {
        showConfirmTapDialog(context, '로그인 후에 이용할 수 있습니다', () {
          Get.offAllNamed(LoginMainScreen.id);
        });
      }

      await _jobAllGet();

      scrollController = ScrollController();
      scrollController.addListener(() async {
        if (scrollController.position.pixels ==
            scrollController.position.maxScrollExtent) {
          // _job = await jobFull();
          _isLoading = false;
          setState(() {});
        }
      });

      if (GetPlatform.isWeb) {
        data = ['구인구직', '시험올리기', '이야기', '공지사항'];
        initial = data.first.toString();
      }

      setState(() {
        _isLoading = false;
      });
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
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
                Get.offAllNamed(MainScreen.id);
                return true;
              })
            : onTerminated(context);
      },
      child: Scaffold(
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
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: Get.width * 0.8,
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 40,
                              ),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    '구인구직',
                                    style: f32w700G,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Get.toNamed(StoryWriteScreen.id,arguments: StoryWriteScreen(
                                        state: '',
                                        whichScreen: 'job',
                                      ))!
                                          .then((value) => {
                                        _refreshIndicatorKey
                                            .currentState
                                            ?.show()
                                      });
                                    },
                                    child: Container(
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
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 45,
                              ),
                              GridView.builder(
                                controller: scrollController,
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount:
                                      Get.width < 1024 ? 2 : 4,
                                  childAspectRatio: (1 / 0.8),
                                  mainAxisSpacing: 20,
                                  crossAxisSpacing: 40,
                                ),
                                // itemCount: 10,
                                itemCount: _firebaseJobAll.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: (){
                                      Get.toNamed(JobHuntingDetailScreen.id,
                                          arguments: JobHuntingDetailScreen(
                                           docId: _firebaseJobAll[index]['docId'],
                                          ))!.then((value) => {
                                        _refreshIndicatorKey.currentState?.show()});
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 22, vertical: 18),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        color: Colors.white,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.grey.withOpacity(.03),
                                            spreadRadius: 3,
                                            blurRadius: 8,
                                            // offset: Offset(0, 0),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${_firebaseJobAll[index]['title']}',
                                            style: f16w700,
                                          ),
                                          const SizedBox(
                                            height: 4,
                                          ),
                                          Text(
                                            '지역 : ${_firebaseJobAll[index]['sido']}',
                                            style: f16w400greyA,
                                          ),
                                          Spacer(),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                '${_firebaseJobAll[index]['jobIs'] == 'true' ? '구직중' : '구직완료'}',
                                                style: _firebaseJobAll[index]
                                                            ['jobIs'] ==
                                                        'true'
                                                    ? f16w700primary
                                                    : f16w400grey8,
                                              ),
                                              Text(
                                                '공고보기 ＞',
                                                style: f16w700,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                                  // return Container(
                                  //   padding: const EdgeInsets.symmetric(
                                  //       horizontal: 22, vertical: 18),
                                  //   decoration: BoxDecoration(
                                  //     borderRadius: BorderRadius.circular(8),
                                  //     color: Colors.white,
                                  //     boxShadow: [
                                  //       BoxShadow(
                                  //         color: Colors.grey.withOpacity(.03),
                                  //         spreadRadius: 3,
                                  //         blurRadius: 8,
                                  //         // offset: Offset(0, 0),
                                  //       ),
                                  //     ],
                                  //   ),
                                  //   child: Column(
                                  //     crossAxisAlignment:
                                  //         CrossAxisAlignment.start,
                                  //     children: [
                                  //       Text(
                                  //         '1234',
                                  //         style: f16w700,
                                  //       ),
                                  //       const SizedBox(
                                  //         height: 4,
                                  //       ),
                                  //       Text(
                                  //         'ddd',
                                  //         style: f16w400greyA,
                                  //       ),
                                  //       Spacer(),
                                  //       Row(
                                  //         mainAxisAlignment:
                                  //             MainAxisAlignment.spaceBetween,
                                  //         children: [
                                  //           Text(
                                  //             '구직중',
                                  //             style: f16w700primary,
                                  //           ),
                                  //           Text(
                                  //             '공고보기 ＞',
                                  //             style: f16w700,
                                  //           ),
                                  //         ],
                                  //       )
                                  //     ],
                                  //   ),
                                  // );
                                },
                              ),
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

  Future<void> _jobAllGet() async {
    final CollectionReference ref =
        FirebaseFirestore.instance.collection('jobHunting');
    QuerySnapshot snapshot = await ref.orderBy('createDate', descending: true).get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    _firebaseJobAll = allData;
  }

  Future<void> _refresh() async {
    Future.delayed(Duration.zero, () async {
      final us = Get.put(UserState());
      await jobFullGet('${us.userList[0].phoneNumber}'); //userL
      await notjobFullGet('${us.userList[0].phoneNumber}');
      await _jobAllGet();
      setState(() {});
    });
  }

  Future<bool> onTerminated(BuildContext context) async {
    return showComponentDialog(context, '앱을 종료하시겠습니까?', () {
      SystemNavigator.pop();
    });
  }
}
