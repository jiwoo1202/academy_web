import 'package:academy/components/footer/footer.dart';
import 'package:academy/screen/community/story/story_write_screen.dart';
import 'package:academy/util/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../util/colors.dart';
import '../../../util/font/font.dart';
import 'story_detail_screen.dart';

class StoryMainScreenWeb extends StatefulWidget {
  static final String id = '/story_main_screen_web';

  const StoryMainScreenWeb({Key? key}) : super(key: key);

  @override
  State<StoryMainScreenWeb> createState() => _StoryMainScreenWebState();
}

class _StoryMainScreenWebState extends State<StoryMainScreenWeb> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();
  late ScrollController scrollController;
  bool _isLoading = true;
  List _firebaseStoryAll = [];

  @override
  void initState() {
    scrollController = ScrollController();
    Future.delayed(Duration.zero, () async {
      await _getAllStory();

      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(backgroundColor: backColor,
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: () async {
          await _refresh();
        },
        child: _isLoading
            ? LoadingBodyScreen()
            : ScrollConfiguration(
                behavior:
                    ScrollConfiguration.of(context).copyWith(scrollbars: false),
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: Get.width * 0.8,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 20),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 22, vertical: 18),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        '이야기',
                                        style: f32w700G,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.toNamed(StoryWriteScreen.id,
                                              arguments: StoryWriteScreen(
                                               whichScreen: '',
                                                state: '',
                                              ));
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
                                    crossAxisCount: Get.width < 1024 ? 2 : 4,
                                    childAspectRatio: (1 / 1.5),
                                    mainAxisSpacing: 40,
                                    crossAxisSpacing: 20,
                                  ),
                                  itemCount: _firebaseStoryAll.length,
                                  // itemCount: 0,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                        onTap: () {
                                          Get.toNamed(StoryDetailScreen.id,
                                              arguments: StoryDetailScreen(
                                                docId: _firebaseStoryAll[index]['docId'],
                                                id1: _firebaseStoryAll[index]['id'],
                                              ));
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 22, vertical: 18),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                child: _firebaseStoryAll[index]
                                                                ['images']
                                                            .length !=
                                                        0
                                                    ? ExtendedImage.network(
                                                        'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/picture%2F${_firebaseStoryAll[index]['id']}%2F${_firebaseStoryAll[index]['docId']}%2F${_firebaseStoryAll[index]['images'][0]}?alt=media',
                                                        fit: BoxFit.fill,
                                                        width: 250,
                                                        height: 250,
                                                      )
                                                    : Image.asset(
                                                        'assets/landing/landing3.jpg',
                                                        width: 250,
                                                        height: 250,
                                                        fit: BoxFit.fill,
                                                      ),
                                              ),
                                              const SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                '${_firebaseStoryAll[index]['title']}',
                                                style: f18w700,
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Flexible(
                                                child: Text(
                                                  '${_firebaseStoryAll[index]['body']}',
                                                  style: f14w400greyA,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                int.parse(DateTime.now()
                                                            .difference(DateTime.parse(
                                                                '${_firebaseStoryAll[index]['createDate']}'))
                                                            .inMinutes
                                                            .toString()) <
                                                        60
                                                    ? '${int.parse(DateTime.now().difference(DateTime.parse('${_firebaseStoryAll[index]['createDate']}')).inMinutes.toString())}분 전'
                                                    : int.parse(DateTime.now()
                                                                .difference(
                                                                    DateTime.parse(
                                                                        '${_firebaseStoryAll[index]['createDate']}'))
                                                                .inHours
                                                                .toString()) <
                                                            24
                                                        ? '${int.parse(DateTime.now().difference(DateTime.parse('${_firebaseStoryAll[index]['createDate']}')).inHours.toString())}시간 전'
                                                        : '${int.parse(DateTime.now().difference(DateTime.parse('${_firebaseStoryAll[index]['createDate']}')).inDays.toString())}일 전',
                                                style: f12w400greyA,
                                              ),
                                            ],
                                          ),
                                        ));
                                  },
                                ),
                              ],
                            ),
                          ),
                          Footer()
                        ],
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Future<void> _getAllStory() async {
    final CollectionReference ref =
        FirebaseFirestore.instance.collection('story');
    QuerySnapshot snapshot = await ref
        .where('status', isEqualTo: '게시중')
        .orderBy('createDate', descending: true)
        .get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    _firebaseStoryAll = allData;
  }

  Future<void> _refresh() async {
    Future.delayed(Duration.zero, () async {
      await _getAllStory();
      setState(() {});
    });
  }
}
