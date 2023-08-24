import 'package:academy/components/footer/footer.dart';
import 'package:academy/provider/job_state.dart';
import 'package:academy/provider/user_state.dart';
import 'package:academy/screen/mypage/qna/qnaDetail.dart';
import 'package:academy/screen/mypage/qna/qnaWrite.dart';
import 'package:academy/util/colors.dart';
import 'package:academy/util/loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../components/community/community_body.dart';
import '../../../components/dialog/showAlertDialog.dart';
import '../../../components/tile/qna_tile.dart';
import '../../../firebase/firebase_qna.dart';
import '../../../firebase/firebase_user.dart';
import '../../../util/font/font.dart';
import '../../../util/refresh_manager.dart';
import '../../login/login_main_screen.dart';
import '../../main/main_screen.dart';

class QnaPage extends StatefulWidget {
  static final String id = '/qna';

  const QnaPage({Key? key}) : super(key: key);

  @override
  State<QnaPage> createState() => _QnaPageState();
}

class _QnaPageState extends State<QnaPage> {
  bool isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();
  final us = Get.put(UserState());

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      // 내가쓴 qna가져오기
      // await getmyQna('${us.userList[0].docId}');
      await userGet(
          RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
      us.isLogin.value = RefreshManager.getCookie('type');
      if (us.isLogin == '' && us.userList.length == 0) {
        showConfirmTapDialog(context, '로그인 후에 이용할 수 있습니다', () {
          Get.offAllNamed(LoginMainScreen.id);
        });
      }
      await getmyQna('${us.userList[0].docId}');
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      key: _refreshIndicatorKey,
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () async {
        await _refresh();
      },
      child: Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                GestureDetector(
                  onTap: () {
                    Get.offNamedUntil(
                      MainScreen.id,
                      (route) => false,
                    );
                  },
                  child: SvgPicture.asset(
                    'assets/logo.svg',
                    width: (GetPlatform.isWeb && (Get.width * 0.2 <= 171))
                        ? 16
                        : 20,
                    height: (GetPlatform.isWeb && (Get.width * 0.2 <= 171))
                        ? 16
                        : 20,
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                    ? Container()
                    : Text('QnA')
              ],
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  showComponentDialog(context, '로그아웃을 하시겠습니까?', () {
                    Get.offAllNamed(LoginMainScreen.id);
                    RefreshManager.addToCookie('id', '');
                    RefreshManager.addToCookie('pw', '');
                    us.isLogin.value = '';
                  });
                },
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(
                    'assets/icon/logout.png',
                    color: Colors.white,
                    width:
                        GetPlatform.isWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                    height:
                        GetPlatform.isWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                  ),
                )),
              ),
            ],
            backgroundColor: nowColor,
            elevation: 0,
          ),
          body: isLoading
              ? LoadingBodyScreen()
              : CommunityBody(
                  paddingSize: 24,
                  body: ListView(
                    children: [
                      SizedBox(
                        height: 20,
                      ),
                      // 내가 쓴 qna
                      Expanded(
                        child: ListView.builder(
                          itemCount: us.getmyQna.length,
                          // itemCount: count,
                          // itemCount: 10,
                          shrinkWrap: true,
                          physics: const ClampingScrollPhysics(),
                          itemBuilder: (context, index) {
                            return Padding(
                              padding:
                                  GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                                      ? EdgeInsets.only(right: 20, left: 20)
                                      : EdgeInsets.only(right: 120, left: 120),
                              child: Column(
                                children: [
                                  QnaTile(
                                    isOpened: true,
                                    isStudent: true,
                                    tCreateDate:
                                        '${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(us.getmyQna[index]['createDate']))}',
                                    body: us.getmyQna[index]['admin'] == ''
                                        ? '대기중'
                                        : '답변완료',
                                    title: '${us.getmyQna[index]['title']}',
                                    onTap: () async {
                                      Get.toNamed(QnaDetail.id,
                                          arguments: QnaDetail(
                                            title:
                                                '${us.getmyQna[index]['title']}',
                                            body:
                                                '${us.getmyQna[index]['body']}',
                                            docId:
                                                '${us.getmyQna[index]['docId']}',
                                            image: us.getmyQna[index]['images'],
                                            hasImage:
                                                '${us.getmyQna[index]['hasImage']}',
                                            admin:
                                                '${us.getmyQna[index]['admin']}',
                                            refreshIndicatorKey:
                                                _refreshIndicatorKey,
                                          ));
                                    },
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),

                      SizedBox(
                        height: Get.height *
                            ((10 - us.getmyQna.length).isNegative
                                ? 0 / 10
                                : (10 - us.getmyQna.length) / 10),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 12),
                        child: Footer(),
                      ),
                    ],
                  ),
                  floatingIcon: GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                      ? const Icon(
                          Icons.edit,
                          size: 16,
                        )
                      : const Icon(Icons.edit),
                  floatingTap: () {
                    Get.to(() => QnaWrite(
                          refreshIndicatorKey: _refreshIndicatorKey,
                        ));
                  },
                )),
    );
  }

  Future<void> _refresh() async {
    Future.delayed(Duration.zero, () async {
      final us = Get.put(UserState());
      await getmyQna('${us.userList[0].docId}');
      setState(() {});
    });
  }
}
