import 'package:academy/components/footer/footer.dart';
import 'package:academy/provider/user_state.dart';
import 'package:academy/screen/mypage/qna/qnaWrite.dart';
import 'package:academy/util/colors.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../components/community/community_detail.dart';
import '../../../components/dialog/showAlertDialog.dart';
import '../../../util/font/font.dart';

class QnaDetail extends StatefulWidget {
  static final String id = '/qna_detail';
  final String? title;
  final String? body;
  final String? docId;
  final List? image;
  final String? hasImage;
  final String? admin;
  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;

  const QnaDetail(
      {Key? key,
      this.title,
      this.body,
      this.docId,
      this.image,
      this.hasImage,
      this.refreshIndicatorKey,
      this.admin})
      : super(key: key);

  @override
  State<QnaDetail> createState() => _QnaDetailState();
}

class _QnaDetailState extends State<QnaDetail> {
  CarouselController carouselController = CarouselController();

  @override
  Widget build(BuildContext context) {
    final us = Get.put(UserState());
    final args = ModalRoute.of(context)!.settings.arguments as QnaDetail;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: nowColor,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Get.back();
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
                : Text('QnA')
          ],
        ),
        elevation: 0,
        actions: [
          args.admin != ''
              ? Container()
              : Theme(
                  data: Theme.of(context).copyWith(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                  ),
                  child: PopupMenuButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      offset: const Offset(-20, 40),
                      icon: Container(
                        height: 15,
                        width: 20,
                        alignment: Alignment.centerRight,
                        child: SvgPicture.asset(
                          'assets/icon/more_button.svg',
                          width: 20,
                          height: 20,
                        ),
                      ),
                      itemBuilder: (context) => [
                            PopupMenuItem(
                              padding: EdgeInsets.zero,
                              child: Column(
                                children: [
                                  Center(
                                    child: const Text(
                                      '수정하기',
                                      style: f14w500,
                                    ),
                                  ),
                                ],
                              ),
                              value: 1,
                              onTap: () {
                                //수정하기
                                Future.delayed(Duration.zero, () {
                                  Get.to(() => QnaWrite(
                                        state: 'edit',
                                        title: args.title,
                                        body: args.body,
                                        docId: args.docId,
                                      ));
                                });
                                args.refreshIndicatorKey?.currentState
                                    ?.show();
                              },
                            ),
                            PopupMenuItem(
                                height: 0,
                                padding: EdgeInsets.zero,
                                child: Column(
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
                                ),
                                value: 2,
                                onTap: () async {
                                  Future.delayed(Duration.zero,(){
                                    showComponentDialog(context, '삭제하시겠습니까?', () async {
                                      Get.back();
                                      await _qnaDelete();
                                      Get.back();
                                      await showOnlyConfirmDialog(
                                          context, '삭제 되었습니다');
                                      args.refreshIndicatorKey?.currentState
                                          ?.show();
                                    });
                                  });
                                }),
                          ]),
                )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: GetPlatform.isWeb
                    ? (Get.width * 0.2 <= 171)
                        ? 20
                        : Get.width * 0.24
                    : 0,
                vertical: 10),
            child: CommunityDetail(
              who: us.userList[0].nickName!,
              dateTime: DateTime.now(),
              docId: args.docId,
              hasImage: '${args.hasImage}',
              createDate: us.getmyQna[0]['createDate'],
              image: args.image!,
              id: '${us.userList[0].phoneNumber}',
              carouselCon: carouselController,
              title: '${args.title}',
              body: '${args.body}',
              commentCount: 0,
              anonymous: false,
              qna: true,
              admin: args.admin,
              anonymousCount: 0,
              onTap4: () {},
            ),
          ),
          Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Footer(),
          ),
        ],
      ),
    );
  }

  //qna 삭제
  Future<void> _qnaDelete() async {
    final args = ModalRoute.of(context)!.settings.arguments as QnaDetail;

    try {
      FirebaseFirestore _firestore = FirebaseFirestore.instance;
      CollectionReference ref = _firestore.collection('qna');
      QuerySnapshot snapshot =
          await ref.where('docId', isEqualTo: '${args.docId}').get();
      snapshot.docs[0].reference.delete();
    } catch (e) {
      print(e);
    }
  }
}
