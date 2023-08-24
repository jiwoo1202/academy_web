import 'package:academy/screen/login/login_main_screen.dart';
import 'package:academy/util/font/font.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../util/colors.dart';
import '../components/dialog/showAlertDialog.dart';
import '../components/footer/footer.dart';

class LandingPageApp extends StatefulWidget {
  static final String id = '/landing_page_app';

  const LandingPageApp({Key? key}) : super(key: key);

  @override
  State<LandingPageApp> createState() => _LandingPageAppState();
}

class _LandingPageAppState extends State<LandingPageApp> {
  bool _isVisible = true;
  CarouselController carouselController = CarouselController();
  final _controller = PageController(keepPage: false,initialPage: 0);
  final _controller2 = PageController(keepPage: false,initialPage: 0);
  List _imageL = [
    'assets/landing/landing5.png',
    'assets/landing/landing_pageview.png',
    'assets/landing/landing_community.png',
    'assets/landing/landing_last.png',
  ];

  List _titleL = [
    '아카데미는 이렇게 사용할 수 있습니다!',
    '여러 가지 테스트를 통한 자기 개발',
    '커뮤니티를 통한 정보 공유',
    '그 외에 다양한 기능',
  ];

  List _bodyL = [
    '아카데미는 다양한 주제에 대한 학습 자료를 제공하며, '
        '수험생들이 각자의 속도와 수준에 맞게 학습할 수 있도록 구성되어 있습니다.\n\n'
        '이를 통해 학생들은 학교에서 배우지 못한 내용을 자기주도적으로 학습하고 '
        '이를 바탕으로 학습 능력을 향상시킬 수 있습니다.',
    '아카데미에서 제공하는 테스트는 다양한 난이도와 과목을 통해, 공부한 내용을 평가하고 '
        '본인이 이해하지 못한 부분을 파악할 수 있도록 도와줍니다.\n\n'
        '이를 통해 수험생들은 자신이 어느 부분에서 약한지 파악하고, '
        '이를 보완할 수 있는 방법을 찾을 수 있습니다.',
    '아카데미 커뮤니티는 학생들이 자신의 경험과 지식을 공유할 수 있으며, '
        '이를 통해 학생들은 서로의 문제해결 능력과 아이디어를 공유하고, 피드백을 받을 수 있습니다.\n\n'
        '아카데미 커뮤니티는 학생들이 서로 도움을 주고받을 수 있는 기회를 제공합니다. '
        '이는 학생들이 서로에게 도움을 주면서 자신의 지식과 능력을 고루 발전시킬 수 있도록 도와줍니다.',
    '구인구직, 테스트 이력 확인, 간편 문제 올리기 등. 다양한 기능들을 아카데미에서 만나보세요!',
  ];

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      _isVisible = false;
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
                onTap: () {}, child: SvgPicture.asset('assets/logo.svg')),
          ],
        ),
        backgroundColor: GetPlatform.isWeb ? nowColor : primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Container(
              width: Get.width,
              height: Get.height * 0.5,
              color: pastelBlue6,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    top: 10,
                    left: Get.width * 0.2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '실시간 체크',
                          style: f12w500,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        SvgPicture.asset(
                          'assets/landing/landing4.svg',
                          width: 100,
                          height: 50,
                        ),
                      ],
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: _isVisible ? 0 : 1,
                    duration: Duration(milliseconds: 2000),
                    child: Center(
                      child: SvgPicture.asset(
                        'assets/landing/landing1.svg',
                        width: 280,
                        height: 150,
                      ),
                    ),
                  ),
                  Positioned(
                      right: Get.width * 0.03,
                      top: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            '간편하게 업로드',
                            style: f12w500,
                          ),
                          Image.asset(
                            'assets/landing/landing2.png',
                            width: 100,
                            height: 70,
                          ),
                        ],
                      )),
                  Positioned(
                    right: Get.width * 0.05,
                    bottom: -10,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '언제 어디서든 편리하게',
                          style: f12w500,
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Image.asset(
                          'assets/landing/landing3.jpg',
                          width: 100,
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    left: Get.width * 0.05,
                    bottom: -30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '다양한 문제',
                          style: f12w500,
                        ),
                        Image.asset(
                          'assets/landing/landing5.png',
                          width: 100,
                          height: 100,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: Get.height * 1.25,
              width: Get.width,
              color: Colors.white,
              child: Column(
                children: [
                  const SizedBox(
                    height: 100,
                  ),
                  Center(
                    child: const Text(
                      '아카데미 장점',
                      style: f28w700G,
                    ),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                'assets/landing/aplus.svg',
                                width: 130,
                                height: 130,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                '점수 비교',
                                style: f18w700,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                '학습 내용에 대한 정확한 평가를 제공하여\n자신의 학습 상황을\n 정확히 파악할 수 있도록 합니다.',
                                style: f10w400G87,
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 10),
                          child: Column(
                            children: [
                              Image.asset(
                                'assets/landing/test.png',
                                width: 130,
                                height: 130,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                '다양한 테스트',
                                style: f18w700,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                '다양한 테스트를 통해 학습자들은\n 자신의 학습 수준을 확인하고\n부족한 부분을 파악하여 보완할 수 있습니다.',
                                style: f10w400G87,
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Column(
                            children: [
                              SvgPicture.asset(
                                'assets/landing/tip.svg',
                                width: 130,
                                height: 130,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                '커뮤니티 공유',
                                style: f18w700,
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Text(
                                '커뮤니티를 통해 서로 정보를 교환하고\n다양한 이야기를 나눌 수 있습니다.',
                                style: f10w400G87,
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ),
                        Column(
                          children: [
                            Image.asset(
                              'assets/landing/people.png',
                              width: 130,
                              height: 130,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              '구인구직',
                              style: f18w700,
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Text(
                              '구인 구직 정보를 통해\n 자신의 경력을 쌓을 수 있으며 보다 나은\n교육 환경에서 일할 수 있는 기회를 얻을 수 있습니다.',
                              style: f10w400G87,
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 50,
                  ),
                  Divider(color: Color(0xffd9d9d9)),
                ],
              ),
            ),
            Container(
              height: 400,
              width: 300,
              child: PageView.builder(
                itemBuilder: (_, idx) {
                  return Image.asset(
                    _imageL[idx],
                  );
                },
                itemCount: _imageL.length,
                controller: _controller2,
                onPageChanged: (idx) {
                  _controller.animateToPage(idx,
                    duration: Duration(milliseconds: 800),
                    curve: Curves.linear,);
                },
              ),
            ),
            Container(
              height: Get.height * 0.5,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                            maxHeight: 240,
                            minHeight: 100
                        ),
                        width: 360,
                        child: PageView.builder(
                          itemBuilder: (_, idx) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _titleL[idx],
                                  style: f24w700G,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  _bodyL[idx],
                                  style: f14w400G87,
                                ),
                              ],
                            );
                          },
                          itemCount: _imageL.length,
                          controller: _controller,
                          onPageChanged: (idx) {
                            _controller2.animateToPage(idx,
                              duration: Duration(milliseconds: 800),
                              curve: Curves.linear,);
                          },
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      SmoothPageIndicator(
                        controller: _controller,
                        count: _imageL.length,
                        effect: ExpandingDotsEffect(
                            dotColor: Color(0xffe6e6e6),
                            activeDotColor: nowColor,
                            radius: 0),
                        // onDotClicked: (index){
                        // }
                      ),
                      const SizedBox(height: 20,),
                      // Container(
                      //   padding: const EdgeInsets.symmetric(horizontal: 43,vertical: 10),
                      //   decoration: BoxDecoration(
                      //     borderRadius: BorderRadius.circular(40),
                      //     border: Border.all(
                      //         color: nowColor
                      //     ),
                      //   ),
                      //   child: GestureDetector(
                      //       onTap: (){
                      //         Get.toNamed(LoginMainScreen.id);
                      //       },
                      //       child: Text('시작하기',style: f16w400primary,)),
                      // )
                    ],
                  ),

                  // Container(
                  //   child: CarouselSlider(
                  //     items: [
                  //     ],
                  //     carouselController: carouselController,
                  //     options: CarouselOptions(
                  //       enableInfiniteScroll: true,
                  //       autoPlay: false,
                  //       padEnds: false,
                  //       enlargeCenterPage: false,
                  //       disableCenter: false,
                  //       viewportFraction: 1,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
            Container(
              height: Get.height*0.9,
              width: Get.width,
              color: Color(0xfff4f4f5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 80,),
                  Text('핸드폰, 테블릿, 컴퓨터까지 다양한 기기를 지원합니다!',style: f28w700G,),
                  const SizedBox(height: 40,),
                  Text('아카데미를 통해 성적 향상을 해보세요',style: f18w400G87,),
                  const SizedBox(height: 20,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap:(){
                          showOnlyConfirmDialog(context,
                              '현재 준비 중 입니다!');
                        },
                        child: SvgPicture.asset(
                          'assets/landing/android.svg',
                          width: 130,
                          height: 50,
                        ),
                      ),
                      const SizedBox(
                        width: 12,
                      ),
                      GestureDetector(
                        onTap: (){
                          showOnlyConfirmDialog(context,
                              '현재 준비 중 입니다!');
                        },
                        child: SvgPicture.asset(
                          'assets/landing/apple.svg',
                          width: 130,
                          height: 35,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Image.asset('assets/landing/pst.png',width: 400,height: 280,)
                ],
              ),
            ),
            Footer()
          ],
        ),
      ),
    );
  }
}
