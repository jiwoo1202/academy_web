import 'package:academy/components/font/font.dart';
import 'package:academy/util/loading.dart';
import 'package:carousel_slider/carousel_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../components/community/community_body.dart';
import '../../../components/community/community_detail.dart';

class StoryDetailScreen extends StatefulWidget {
  final String docId;
  static final String id = '/story_detail';

  const StoryDetailScreen({Key? key, required this.docId}) : super(key: key);

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  CarouselController carouselController = CarouselController();
  TextEditingController commentController = TextEditingController();
  List<bool> _isAnn = [false, true];
  int _numLines = 0;
  List _communityList = [];
  List _commentsList = [];
  List commentId = ['123', '456'];
  List commentBody = ['fsdafdasfadsf', 'asdgdsagadsg'];
  double? _lineHeight;
  bool _isLoading = true;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await communityStoryGet();
      await commentsGet();
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('이야기'),
          backgroundColor: Colors.lightGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(30),
            ),
          ),
        ),
        body: _isLoading
            ? LoadingBodyScreen()
            : SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 26),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CommunityDetail(
                          who: _communityList[0]['name'],
                          dateTime: DateTime.now(),
                          docId: _communityList[0]['docId'],
                          hasImage: _communityList[0]['hasImage'],
                          createDate: _communityList[0]['createDate'],
                          image: _communityList[0]['images'],
                          id: _communityList[0]['id'],
                          carouselCon: carouselController,
                          title: _communityList[0]['title'],
                          body: _communityList[0]['body'],
                          commentCount: _commentsList.length,
                          anonymous: false,
                          anonymousCount: 0),
                      ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          itemCount: _commentsList.length,
                          shrinkWrap: true,
                          itemBuilder: (_, idx) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${_commentsList[idx]['name']}',
                                      style: f20w500,
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
                                            width: 3,
                                            alignment: Alignment.centerRight,
                                            child: Icon(
                                              Icons.more_vert,
                                              color: const Color(0xff272424),
                                              size: 20,
                                            ),
                                          ),
                                          itemBuilder: (context) => [
                                                PopupMenuItem(
                                                    padding: EdgeInsets.zero,
                                                    child: Column(
                                                      children: [
                                                        Center(
                                                          child: _isAnn[idx]
                                                              ? const Text(
                                                                  '수정하기',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      height: 1,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          'NotoSansKr'),
                                                                )
                                                              : const Text(
                                                                  '신고하기',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          14,
                                                                      height: 1,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold,
                                                                      fontFamily:
                                                                          'NotoSansKr'),
                                                                ),
                                                        ),
                                                        _isAnn[idx]
                                                            ? const Divider()
                                                            : Container(),
                                                      ],
                                                    ),
                                                    value: 1,
                                                    onTap: () {}),
                                                PopupMenuItem(
                                                    height: 0,
                                                    padding: EdgeInsets.zero,
                                                    child: _isAnn[idx]
                                                        ? Column(
                                                            children: [
                                                              Center(
                                                                  child:
                                                                      const Text(
                                                                '삭제하기',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        14,
                                                                    height: 1,
                                                                    color: Colors
                                                                        .black,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontFamily:
                                                                        'NotoSansKr'),
                                                              )),
                                                              SizedBox(
                                                                height: 8,
                                                              ),
                                                            ],
                                                          )
                                                        : Container(),
                                                    value: 2,
                                                    onTap: () {}),
                                              ]),
                                    ),
                                  ],
                                ),
                                Text(
                                  '${_commentsList[idx]['body']}',
                                  style: f20w500,
                                ),
                              ],
                            );
                          })
                    ],
                  ),
                ),
              ),
        bottomNavigationBar: Padding(
          padding:
              EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 8),
            child: TextField(
              controller: commentController,
              textAlignVertical: TextAlignVertical.center,
              onChanged: (String e) {
                setState(() {
                  _numLines = e.split('\n').length;
                  if (_numLines <= 1) {
                    _lineHeight = 36;
                  } else if (_numLines == 2) {
                    _lineHeight = 56;
                  } else if (_numLines >= 3) {
                    _lineHeight = 76;
                  }
                });
              },
              maxLines: 3,
              minLines: 1,
              keyboardType: TextInputType.multiline,
              decoration: InputDecoration(
                hintText: '댓글을 입력해 주세요',
                isDense: true,
                hintStyle: const TextStyle(
                    fontSize: 14,
                    height: 1,
                    color: Colors.grey,
                    fontFamily: 'NotoSansKr'),
                suffixIcon: GestureDetector(
                  onTap: () async {
                    await communityCommentWrite(commentController.text);
                  },
                  child: Container(
                      height: _lineHeight,
                      constraints: BoxConstraints(
                        maxHeight: double.infinity,
                      ),
                      padding:
                          EdgeInsets.symmetric(horizontal: 11, vertical: 11),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(5)),
                        //here
                        color: Color(0xff272424),
                      ),
                      child: SvgPicture.asset(
                        'assets/icon/comment_click_icon.svg',
                        height: 14,
                        width: 16,
                      )),
                ),
                suffixIconConstraints:
                    BoxConstraints(minHeight: 8, minWidth: 8),
                filled: true,
                fillColor: Colors.grey.withOpacity(0.2),
                enabledBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: Colors.transparent, width: 2),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: const BorderRadius.all(Radius.circular(8.0)),
                  borderSide: BorderSide(color: Colors.transparent, width: 2),
                ),
                contentPadding: const EdgeInsets.all(8),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> communityStoryGet() async {
    CollectionReference ref = FirebaseFirestore.instance.collection('story');
    QuerySnapshot snapshot =
        await ref.where('docId', isEqualTo: widget.docId).get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    print('how many222 : ${allData.length}');
    _communityList = allData;
  }

  Future<void> commentsGet() async {
    CollectionReference ref = FirebaseFirestore.instance.collection('story').doc(widget.docId).collection('comments');
    QuerySnapshot snapshot =
    await ref.get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    print('how 3333 : ${allData.length}');
    _commentsList = allData;
  }

  Future<void> communityCommentWrite (String body) async{
    CollectionReference ref = FirebaseFirestore.instance.collection('story').doc(widget.docId).collection('comments');
    ref.add({
      'id' : '01048544580',
      'docId' : '',
      'body' : body,
      'status' : '게시중',
      'type' : '학생',
      'name' : '김아무개',
      'createDate' : '${DateTime.now()}',
    }).then((doc) async {
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('story').doc(widget.docId).collection('comments').doc(doc.id);
      await userDocRef.update({'docId': '${doc.id}'});
    });
  }
}
