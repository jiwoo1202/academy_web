import 'package:academy/components/footer/footer.dart';
import 'package:academy/firebase/firebase_community.dart';
import 'package:academy/model/user.dart';
import 'package:academy/provider/community_state.dart';
import 'package:academy/util/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../components/dialog/showAlertDialog.dart';

import '../../../firebase/firebase_user.dart';
import '../../../provider/user_state.dart';
import '../../../util/colors.dart';
import '../../../util/font/font.dart';

class BlockPage extends StatefulWidget {
  static final String id = '/Block_check';

  const BlockPage({Key? key}) : super(key: key);

  @override
  State<BlockPage> createState() => _BlockPageState();
}

class _BlockPageState extends State<BlockPage> {
  bool _isLoading = true;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      final us = Get.put(UserState());
      // await blockGet('${us.userList[0].phoneNumber}');
      await userGet('1234', '1234');
      setState(() {
        _isLoading = false;
      });
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final us = Get.put(UserState());

    return RefreshIndicator(
      key: _refreshIndicatorKey,
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () async {
        await _refresh();
      },
      child: Scaffold(
          appBar: AppBar(
            title: Row(
              children: [
                SvgPicture.asset(
                  'assets/logo.svg',
                  width:
                      (GetPlatform.isWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
                  height:
                      (GetPlatform.isWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
                ),
                SizedBox(
                  width: 8,
                ),
                GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                    ? Container()
                    : Text('차단설정')
              ],
            ),
            automaticallyImplyLeading: false,
            // leading: IconButton(
            //   icon: Icon(
            //     Icons.arrow_back_ios_new,
            //     color: Color(0xff6f7072),
            //   ),
            //   onPressed: () {
            //     Get.back();
            //   },
            // ),
            backgroundColor: nowColor,
            elevation: 0,
          ),
          body: _isLoading
              ? LoadingBodyScreen()
              : ListView(
                children: [
                  ListView.builder(
                      itemCount: 40,
                      shrinkWrap: true,
                      itemBuilder: (_, index) {
                        return Column(
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: GetPlatform.isWeb &&
                                          (Get.width * 0.2 <= 171)
                                      ? Get.width
                                      : Get.width * 0.3,
                                  height: (GetPlatform.isWeb &&
                                          (Get.width * 0.2 <= 171))
                                      ? 32
                                      : 40,
                                  padding: (GetPlatform.isWeb &&
                                          (Get.width * 0.2 <= 171))
                                      ? EdgeInsets.zero
                                      : const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 12),
                                  decoration: BoxDecoration(
                                      color: textFormColor,
                                      borderRadius: BorderRadius.circular(8)),
                                  child: Text(
                                    // '${us.userList[0].isBanned![index]}',
                                    '111',
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Container(
                                  height: (GetPlatform.isWeb &&
                                          (Get.width * 0.2 <= 171))
                                      ? 32
                                      : 40,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: ElevatedButton(
                                    child: Center(
                                      child: Text(
                                        '차단 해제',
                                        style: f16w700primary,
                                        textAlign: TextAlign.right,
                                      ),
                                    ),
                                    onPressed: () async {
                                      showComponentDialog(
                                        context,
                                        '해당 유저를 차단 해제하시겠습니까?',
                                        () async {
                                          Navigator.pop(context);
                                          _isLoading = true;
                                          await _removeBlock(
                                              '${us.userList[0].isBanned![index]}');
                                          _refreshIndicatorKey.currentState
                                              ?.show();
                                          // await _blockGet(rp.phoneNumber,rp);
                                          setState(() {
                                            _isLoading = false;
                                          });
                                        },
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: textFormColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        elevation: 0),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 12),
                    child: Footer(),
                  )
                ],
              )),
    );
  }

  //차단 해제
  Future<void> _removeBlock(String phoneNumber) async {
    final us = Get.put(UserState());

    CollectionReference likeRef = FirebaseFirestore.instance.collection('user');

    QuerySnapshot snapshot =
        await likeRef.where('id', isEqualTo: us.userList[0].id).get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();

    await snapshot.docs[0].reference.update({
      "isBanned": FieldValue.arrayRemove([phoneNumber])
    });
  }

  Future<void> _refresh() async {
    Future.delayed(Duration.zero, () async {
      final us = Get.put(UserState());
      await userGet('${us.userList[0].id}', '${us.userList[0].pw}');
      setState(() {});
    });
  }
}
