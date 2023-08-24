import 'package:academy/screen/login/login_main_screen.dart';
import 'package:academy/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_utils/src/platform/platform.dart';

import '../components/footer/footer.dart';
import '../util/font/font.dart';

class LeadingPage extends StatefulWidget {
  static final String id = '/leading';
  const LeadingPage({Key? key}) : super(key: key);

  @override
  State<LeadingPage> createState() => _LeadingPageState();
}

class _LeadingPageState extends State<LeadingPage> {

  final listItem = ['assets/graph.svg','assets/book.svg','assets/browser.svg','assets/browser.svg'];
  final listTitle = ['성적관리','빠른 테스트','커뮤니티 정보공유','구인정보'];
  final listContent = ['빠른 성적확인이 가능!','쪽지시험 보면서 성적을 올려봐요!',
    '모르는 문제 있으면 친구들과 공유!','선생님들에게는 구인정보를!'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: GetPlatform.isWeb
              ? Row(
            children: [
              SvgPicture.asset('assets/logo.svg'),
            ],
          )
              : SvgPicture.asset('assets/logo.svg'),
          automaticallyImplyLeading: false,
          backgroundColor: nowColor,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                  child: GestureDetector(
                    onTap: (){
                      Get.toNamed(LoginMainScreen.id);
                    },
                      child: Text('로그인',style: f21Whitew700,)
                  )
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
               width: MediaQuery.of(context).size.width,
                height:  GetPlatform.isWeb
                    ? MediaQuery.of(context).size.height*0.4
                    : MediaQuery.of(context).size.width*0.3,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/leading1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Stack(
                  children: [
                  ],
                ),
              ),
              SizedBox(
                height: 50,
              ),
              Padding(
                  padding: GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                      ? EdgeInsets.only(right: 20, left: 20, top: 60)
                      : EdgeInsets.only(right: 100, left: 100, top: 60),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('아카데미의 장점은요?',style: f21w700,),
                    SizedBox(
                      height: 100,
                    ),
                    GridView.builder(
                      itemCount: listItem.length,
                      shrinkWrap: true,
                      itemBuilder: (context, idx){
                        return Column(
                          children: [
                            SvgPicture.asset(listItem[idx],
                              color: Colors.black,
                              height: 100,
                            ),
                            Text(listTitle[idx],style: f21w700,),
                            SizedBox(
                              height: 10,
                            ),
                            Text(listContent[idx],style: f20w500,),
                          ],
                        );
                      }, gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                      GetPlatform.isWeb && (Get.width * 0.2 <= 171)?2: 4,
                      childAspectRatio: GetPlatform.isWeb && (Get.width * 0.2 <= 171)?(1 / 1.2):context.isLargeTablet?(1/1):(1/1.3),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    GestureDetector(
                      onTap: (){
                        // print('${Get.width}');
                      },
                        child: Text('아카데미는 이렇게 학습해요!',style: f21w700,)),
                    SizedBox(
                      height: 50,
                    ),
                    GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                        ?   Container(
                        width: Get.width,
                        height: 400,
                        child:Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/leading3.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                    )
                        :Container(),
                    Padding(
                      padding: GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                          ? EdgeInsets.only(right: 20, left: 20, top: 60)
                          : EdgeInsets.only(right: 0, left: 0, top: 30),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('컴퓨터로 문제 풀고 정답을 맞출 수 있어요',style: GetPlatform.isWeb && (Get.width * 0.2 <= 171)?f16w500:f20w500,),
                              SizedBox(
                                height: 30,
                              ),
                              Text('선생님들이 올린 문제를 온라인으로 풀수 있어요',style: GetPlatform.isWeb && (Get.width * 0.2 <= 171)?f16w500:f20w500),
                              SizedBox(
                                height: 30,
                              ),
                              Text('듣기 파일도 넣어저 있어 듣기평가도 가능해요',style: GetPlatform.isWeb && (Get.width * 0.2 <= 171)?f16w500:f20w500),
                              SizedBox(
                                height: 30,
                              ),
                              Text('언제 어디서든 편리하게 시험을 볼 수 있어요',style: GetPlatform.isWeb && (Get.width * 0.2 <= 171)?f16w500:f20w500,)
                            ],
                          ),
                          Spacer(),
                          GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                              ?Container()
                              : Container(
                              width: Get.width*0.3,
                              height: 400,
                              child:Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: AssetImage('assets/leading3.png'),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              )
                          )
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 50,
                    ),
                    Text('핸드폰, 테블릿, 컴퓨터까지 다양한 기기를 지원해요!',style: f21w700,),
                    SizedBox(
                      height: 30,
                    ),
                    GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                        ?   Container(
                        width: Get.width,
                        height: 400,
                        child:Container(
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage('assets/leading2.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                    )
                        :Container(),
                    Padding(
                      padding: GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                          ? EdgeInsets.only(right: 0, left: 0, top: 60)
                          : EdgeInsets.only(right: 0, left: 0, top: 60),
                      child: Row(
                        children: [
                          Container(
                              width: Get.width*0.4,
                              height: GetPlatform.isWeb && (Get.width * 0.2 <= 171)?0:500,
                              child:
                              GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                                  ?Container()
                                  :Center(
                                    child: Container(
                                width: Get.width*0.3,
                                 height: 500,
                                decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: AssetImage('assets/leading2.png'),
                                      fit: BoxFit.cover,
                                    ),
                                ),
                              ),
                                  )
                          ),
                          Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                GetPlatform.isWeb && (Get.width * 0.2 <= 171)?Container():
                                Text('아카데미를 통해 성적 향상을 해보세요',style: f20w500,),
                                SizedBox(
                                  height: 30,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                        ? Text('아카데미를 통해 성적 향상을 해보세요',style: f20w500,)
                        : Container(),
                    const SizedBox(height: 100,),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Footer(),
                    ),
                    const SizedBox(height: 20,),
                  ],
                ),
              ),
            ],
          ),
        ),
    );
  }
}
