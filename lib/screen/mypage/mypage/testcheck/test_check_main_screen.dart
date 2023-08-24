import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../components/dialog/showAlertDialog.dart';
import '../../../../components/footer/footer.dart';
import '../../../../components/tile/main_tile.dart';
import '../../../../firebase/firebase_answer.dart';
import '../../../../provider/user_state.dart';
import '../../../../util/behavior.dart';
import '../../../../util/colors.dart';
import '../../../../util/font/font.dart';
import '../../../../util/loading.dart';
import '../../../../util/refresh_manager.dart';
import '../../../login/login_main_screen.dart';
import '../../../main/main_screen.dart';
import 'test_check_detail_screen.dart';

class TestCheckMainScreen extends StatefulWidget {
  static final String id = '/test_check_main';

  const TestCheckMainScreen({Key? key}) : super(key: key);

  @override
  State<TestCheckMainScreen> createState() => _TestCheckMainScreenState();
}

class _TestCheckMainScreenState extends State<TestCheckMainScreen> {
  @override
  Widget build(BuildContext context) {
    final us = Get.put(UserState());

    return Scaffold(
      appBar: AppBar(
        // leading: null,
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
                width:
                    (GetPlatform.isWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
                height:
                    (GetPlatform.isWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
              ),
            ),
            SizedBox(
              width: 8,
            ),
            GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                ? Container()
                : Text('테스트 체크')
          ],
        ),
        // leadingWidth: 100,
        actions: [
          Center(
              child: Text(
            '${us.userList[0].nickName}',
            style: (GetPlatform.isWeb && (Get.width * 0.2 <= 171))
                ? f12Whitew700
                : f21Whitew700,
          )),
          const SizedBox(
            width: 20,
          ),
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
                width: GetPlatform.isWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                height: GetPlatform.isWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
              ),
            )),
          ),
        ],
        elevation: 0,
        backgroundColor: nowColor,
      ),
      body: ScrollConfiguration(
        behavior: MyBehavior(),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            width: Get.width,
            // height: Get.height,
            padding: GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                ? EdgeInsets.only(right: 20, left: 20, top: 60)
                : EdgeInsets.only(right: 120, left: 120, top: 60),
            child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('answer')
                    .where('teacher', isEqualTo: us.userList[0].id)
                    // .where('state', isNotEqualTo: '삭제')
                    .orderBy('createDate', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Container(
                        height: Get.height, child: LoadingBodyScreen());
                  }
                  return Column(
                    children: [
                      Text(
                        '선생님',
                        style: f24w500,
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      //조건 비어있으면 Text or 카드 있으면 카드 ListView 부르기
                      // false ?
                      // Text('선생님 이름 혹은\n코드를 검색해주세요', style: TextStyle(fontSize: 20),):
                      ListView.builder(
                        itemCount: snapshot.data!.docs.length,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return snapshot.data!.docs[index]['state'] != '삭제'
                              ? Column(
                                  children: [
                                    MainTile(
                                      isOpened: snapshot.data!.docs[index]
                                                  ['state'] ==
                                              '대기'
                                          ? true
                                          : false,
                                      isStudent: false,
                                      onTap: () async {
                                        Get.toNamed(TestCheckDetailScreen.id,
                                            arguments: TestCheckDetailScreen(
                                              isInd:'${snapshot.data!.docs[index]['isIndividual']}' ,
                                                docId:
                                                    '${snapshot.data!.docs[index]['docId']}',
                                                answer: snapshot.data!
                                                    .docs[index]['answer']));
                                      },
                                      tName: us.userList[0].nickName,
                                      tCreateDate:
                                          '${DateFormat('y-MM-dd HH:mm').format(DateTime.parse('${snapshot.data!.docs[index]['createDate']}'))}',
                                      title:
                                          '${snapshot.data!.docs[index]['pdfCategory']}',
                                      switchOnTap: () {},
                                      subject:
                                          '테스트 인원 : ${snapshot.data!.docs[index]['student'].length}명',
                                      isSwitched: false,
                                    ),
                                    SizedBox(
                                      height: 16,
                                    ),
                                  ],
                                )
                              : Container();
                        },
                      ),
                      Footer(),
                      SizedBox(
                        height: 20,
                      ),
                    ],
                  );
                }),
          ),
        ),
      ),
    );
  }
}
