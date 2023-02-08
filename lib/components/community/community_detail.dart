import 'package:carousel_slider/carousel_slider.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../util/colors.dart';
import '../../util/font.dart';
import '../../util/padding.dart';

class CommunityDetail extends StatefulWidget {
  final String id;
  final String who;
  final String title;
  final String body;
  final String hasImage;
  final String createDate;
  final String? commentId;
  final String? commentBody;
  final String? docId;

  final int anonymousCount;
  final int commentCount;

  final bool anonymous;
  final bool? isMine;

  // final int current;
  final List<dynamic> image;
  final CarouselController carouselCon;
  final TextEditingController? commentCon;
  final DateTime dateTime;
  final VoidCallback? onTap2;
  final VoidCallback? onTap3;
  final VoidCallback? onTap4;
  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;

  const CommunityDetail(
      {Key? key,
      required this.who,
      required this.dateTime,
      required this.hasImage,
      required this.createDate,
      required this.image,
      required this.id,
      required this.carouselCon,
      required this.title,
      required this.body,
      required this.commentCount,
      required this.anonymous,
      required this.anonymousCount,
      this.commentId,
      this.commentBody,
      this.commentCon,
      this.isMine,
      this.onTap2,
      this.onTap3,
      this.docId,
      this.refreshIndicatorKey,
      this.onTap4})
      : super(key: key);

  @override
  State<CommunityDetail> createState() => _CommunityDetailState();
}

class _CommunityDetailState extends State<CommunityDetail> {
  final controller = PageController(viewportFraction: 0.8, keepPage: true);
  int currentIdx = 0;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  new GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: RefreshIndicator(
        key: _refreshIndicatorKey,
        triggerMode: RefreshIndicatorTriggerMode.anywhere,
        onRefresh: () async {},
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: ph24,
              child: Text(
                '${widget.who}',
                style: f18w400,
              ),
            ),
            const SizedBox(
              height: 4,
            ),
            Padding(
              padding: ph24,
              child: Text(
                int.parse(widget.dateTime
                            .difference(DateTime.parse('${widget.createDate}'))
                            .inMinutes
                            .toString()) <
                        60
                    ? '${int.parse(widget.dateTime.difference(DateTime.parse('${widget.createDate}')).inMinutes.toString())}분 전'
                    : int.parse(widget.dateTime
                                .difference(
                                    DateTime.parse('${widget.createDate}'))
                                .inHours
                                .toString()) <
                            24
                        ? '${int.parse(widget.dateTime.difference(DateTime.parse('${widget.createDate}')).inHours.toString())}시간 전'
                        : '${int.parse(widget.dateTime.difference(DateTime.parse('${widget.createDate}')).inDays.toString())}일 전',
                style: f16w400greyA,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            widget.hasImage == 'true'
                ? Stack(
                    alignment: Alignment.center,
                    children: [
                      CarouselSlider(
                        items: [
                          for (int i = 0; i < widget.image.length; i++)
                            'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/picture%2F${widget.id}%2F${widget.docId}%2F${widget.image[i]}?alt=media'
                          //   'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/asd.png?alt=media&token=d3708419-809b-4c8e-bd69-bd6bdfa002a6'
                        ]
                            .map((item) => ClipRRect(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(0.0)),
                                  child: InkWell(
                                      onTap: () {
                                        // Navigator.of(context).push(
                                        //     MaterialPageRoute(
                                        //         builder: (context) =>
                                        //             clickFullImages(
                                        //                 listImagesModel: [
                                        //                   for (int i = 0;
                                        //                       i <
                                        //                           _myStoryList[0]
                                        //                                   [
                                        //                                   'images']
                                        //                               .length;
                                        //                       i++)
                                        //                     'https://firebasestorage.googleapis.com/v0/b/clicksound-af0c0.appspot.com/o/picture%2F${_myStoryList[0]['createId']}%2F${_myStoryList[0]['id']}%2F${image[i]}?alt=media'
                                        //                 ],
                                        //                 current:
                                        //                     _current)));
                                      },
                                      child: ExtendedImage.network(
                                        item,
                                        fit: BoxFit.cover,
                                        cache: true,
                                        enableLoadState: false,
                                      )),
                                ))
                            .toList(),
                        carouselController: widget.carouselCon,
                        options: CarouselOptions(
                          autoPlay: false,
                          padEnds: false,
                          enlargeCenterPage: false,
                          disableCenter: true,
                          height: Get.height * 0.3,
                          viewportFraction: 1,
                          onPageChanged: (index, reason) {
                            setState(() {
                              print('hey');
                              print('22 : ${currentIdx}');
                              currentIdx = index;
                            });
                          },
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        child: AnimatedSmoothIndicator(
                          activeIndex: currentIdx,
                          count: widget.image.length,
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
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: ph24,
              child: Text(
                '${widget.title}',
                style: f18w700,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: ph24,
              child: Text(
                '${widget.body}',
                style: f16w400,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Divider(),
            Padding(
              padding: ph24,
              child: Text(
                '댓글(${widget.commentCount})',
                style: f16w400,
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
