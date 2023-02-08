import 'package:academy/screen/community/story/story_write_screen.dart';
import 'package:academy/util/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/community/community_body.dart';
import '../../../provider/community_state.dart';
import '../../../provider/user_state.dart';
import '../../../util/colors.dart';
import '../../../../util/font.dart';

import '../../../util/padding.dart';
import 'story_detail_screen.dart';

class StoryMainScreen extends StatefulWidget {
  static final String id = '/story_main';

  const StoryMainScreen({Key? key}) : super(key: key);

  @override
  State<StoryMainScreen> createState() => _StoryMainScreenState();
}

class _StoryMainScreenState extends State<StoryMainScreen> {
  List _communityList = [];
  List blockList = [];
  bool _isLoading = true;
  bool _scrollLoading = true;
  var qsStoryList = null;
  late ScrollController scrollController;
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
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
      // await _refresh();
      await communityStoryGet();
      // await storyBlockExceptGet();
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Get.put(CommunityState());
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: () async {
          await _refresh();
        },
        child: _isLoading ? LoadingBodyScreen() : Container()
        // : CommunityBody(
        //     paddingSize: 0,
        //     body: Transform.translate(
        //       offset: Offset(0, 0),
        //       child: ListView.builder(
        //           controller: scrollController,
        //           physics: const ClampingScrollPhysics(),
        //           itemCount: _communityList.length,
        //           shrinkWrap: true,
        //           itemBuilder: (context, idx) {
        //             return blockList.contains(_communityList[idx]['docId'])
        //                 ? Container()
        //                 : GestureDetector(
        //                     behavior: HitTestBehavior.opaque,
        //                     onTap: () async {
        //                       Get.to(() => StoryDetailScreen(
        //                             docId: _communityList[idx]['docId'],
        //                             id1: _communityList[idx]['id'],
        //                             refreshIndicatorKey: _refreshIndicatorKey,
        //                             name: _communityList[idx]['name'],
        //                           ))!.then((value) => {
        //                           _refreshIndicatorKey.currentState?.show()
        //                       });
        //                     },
        //                     child: Column(
        //                       crossAxisAlignment: CrossAxisAlignment.start,
        //                       children: [
        //                         Padding(
        //                           padding: ph24,
        //                           child: Text(
        //                             '${_communityList[idx]['title']}',
        //                             style: f18w400el,
        //                           ),
        //                         ),
        //                         const SizedBox(
        //                           height: 8,
        //                         ),
        //                         Padding(
        //                           padding: ph24,
        //                           child: Text(
        //                             '${_communityList[idx]['body']}',
        //                             style: f16w400greyAel,
        //                           ),
        //                         ),
        //                         const SizedBox(
        //                           height: 12,
        //                         ),
        //                         Padding(
        //                           padding: ph24,
        //                           child: Text(
        //                             int.parse(DateTime.now()
        //                                         .difference(DateTime.parse(
        //                                           '${_communityList[idx]['createDate']}',
        //                                         ))
        //                                         .inMinutes
        //                                         .toString()) <
        //                                     5
        //                                 ? '방금 전'
        //                                 : int.parse(DateTime.now()
        //                                             .difference(
        //                                                 DateTime.parse(
        //                                               '${_communityList[idx]['createDate']}',
        //                                             ))
        //                                             .inMinutes
        //                                             .toString()) <
        //                                         60
        //                                     ? '${int.parse(DateTime.now().difference(DateTime.parse(
        //                                           '${_communityList[idx]['createDate']}',
        //                                         )).inMinutes.toString())}분 전'
        //                                     : int.parse(DateTime.now()
        //                                                 .difference(
        //                                                     DateTime.parse(
        //                                                   '${_communityList[idx]['createDate']}',
        //                                                 ))
        //                                                 .inHours
        //                                                 .toString()) <
        //                                             24
        //                                         ? '${int.parse(DateTime.now().difference(DateTime.parse(
        //                                               '${_communityList[idx]['createDate']}',
        //                                             )).inHours.toString())}시간 전'
        //                                         : '${int.parse(DateTime.now().difference(DateTime.parse(
        //                                               '${_communityList[idx]['createDate']}',
        //                                             )).inDays.toString())}일 전',
        //                             style: f16w400greyA,
        //                           ),
        //                         ),
        //                         const SizedBox(
        //                           height: 16,
        //                         ),
        //                         Divider(
        //                           color: cameraBackColor,
        //                           height: 1,
        //                         ),
        //                         const SizedBox(
        //                           height: 16,
        //                         ),
        //                       ],
        //                     ),
        //                   );
        //           }),
        //     ),
        //     floatingIcon: const Icon(Icons.edit),
        //     floatingTap: () {
        //       Get.toNamed(StoryWriteScreen.id);
        //     },
        //   ),
        );
  }

  Future<void> _refresh() async {
    Future.delayed(Duration.zero, () async {
      print('refresh------');
      qsStoryList = null;
      // _communityList = [];
      // await storyBlockExceptGet();
      await communityStoryGet();
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
                '${us.userList[0].phoneNumber}') //us.userList[0].phoneNumber
        .where('collectionName', isEqualTo: 'story')
        .where('commentField', isEqualTo: 'false')
        .get();
    final allData = snapshot2.docs.map((doc) => doc.data()).toList();
    print('55555 : ${allData.length}');
    List ls = allData;
    blockList = [];
    for (int i = 0; i < ls.length; i++) {
      blockList.add(ls[i]['blockDocId']);
    }

    CollectionReference _hosRef =
        FirebaseFirestore.instance.collection('story');
    if (qsStoryList != null) {
      qsStoryList = await _hosRef
          .orderBy('createDate', descending: true)
          .startAfter([_communityList.last['createDate']])
          .where('status', isEqualTo: '게시중')
          .limit(7)
          .get();
      final allData = qsStoryList.docs.map((doc) => doc.data()).toList();
      _communityList.addAll(allData);
    } else {
      qsStoryList = await _hosRef
          .orderBy('createDate', descending: true)
          .where('status', isEqualTo: '게시중')
          .limit(7)
          .get();
      final allData = qsStoryList.docs.map((doc) => doc.data()).toList();
      _communityList = allData;
      print('_communityList: ${_communityList}');
    }

    setState(() {});
  }

//차단한거 제외
// Future<void> storyBlockExceptGet() async {
//   final us = Get.put(UserState());
//   final cs = Get.put(CommunityState());
//   CollectionReference ref2 = FirebaseFirestore.instance.collection('block');
//   QuerySnapshot snapshot2 =
//   await ref2.where('blockId', isEqualTo: us.userList[0].phoneNumber)
//       .where('collectionName', isEqualTo: 'story').where('commentField', isEqualTo: 'true').get();
//   final allData = snapshot2.docs.map((doc) => doc.data()).toList();
//   print('55555 : ${allData.length}');
//   List ls = allData;
//
//   CollectionReference ref = FirebaseFirestore.instance.collection('story');
//   QuerySnapshot snapshot = await ref.get();
//   final allData2 = snapshot.docs.map((doc) => doc.data()).toList();
//   print('how 777 : ${allData2.length}');
//   // _commentsList = allData2;
//   List ls2 = allData2;
//   List ls3 = [];
//   int count = 0;
//   for(int i=0; i<ls2.length; i++) {
//     count = 0;
//     for(int j=0; j<ls.length; j++) {
//       if(ls2[i]['docId'] == ls[j]['blockDocId']){
//         count ++;
//       }
//     }
//     if(count == 0) {
//       ls3.add(ls2[i]);
//     }
//   }
//   _communityList = ls3;
//   print('_commentsBlockList: ${_communityList.length} ');
//
// }
}
