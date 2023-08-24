import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/components/footer/footer.dart';
import 'package:academy/provider/sat_state.dart';
import 'package:academy/screen/main/student/test/individual/sat/test_individual_screen_sat.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:academy/util/loading.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../../../firebase/firebase_sat.dart';
import '../../../../../../firebase/firebase_user.dart';
import '../../../../../../util/count_down.dart';
import '../../../../../../util/font/font.dart';
import '../../../../../../util/refresh_manager.dart';
import '../../../../../login/login_main_screen.dart';
import 'test_individula_screen_satMath.dart';

class BreakTimeScreen extends StatefulWidget {
  static final String id = '/breakTimePage';
  final String? docId;
  final String? isChecked;
  final bool? myPage;
  final int? part;
  const BreakTimeScreen({Key? key, this.docId, this.isChecked= '', this.myPage, this.part})
      : super(key: key);

  @override
  State<BreakTimeScreen> createState() => _TestIndividualState();
}

class _TestIndividualState extends State<BreakTimeScreen>
    with TickerProviderStateMixin {
  bool _isLoading = true;
  Function() animationListener = () {};
  TextEditingController _numberCon = TextEditingController();
  late AnimationController _timeController;
  int a = 0;
  final st = Get.put(SatState());
  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      await userGet(RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
      st.satTeacherDocId.value =  RefreshManager.getCookie('satTeacherDocId');
      st.satmyPage.value = RefreshManager.getCookie('satmyPage');
      st.satpart.value = RefreshManager.getCookie('satpart');
      st.satUpdateDocId.value = RefreshManager.getCookie('satUpdateDocId');
      await firebaseSatGet();
      await satStatusChange('${st.satUpdateDocId}', '3');
      _timeController = AnimationController(vsync: this, duration: Duration(seconds: 1)); //10분
      _timeController.forward();
      _timeController.addListener(() async {
        if (_timeController.isCompleted) {a = 1;} else {a = 0;}
        setState(() {});
      });

      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }
  bool isNumeric(String? s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  @override
  void dispose() {
    _numberCon.dispose();
    _timeController.stop();
    _timeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return Future(() {
          if (st.satmyPage.value =='true') {
           Get.back();
          } else {
            showComponentDialog(context, '시험을 종료하시겠습니까?', () async {
              await satStatusChange('${st.satUpdateDocId}', '2'); //종료
              Get.offNamedUntil(BottomNavigator.id, (route) => true);
            });
          }
          return true;
        });
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: _isLoading
            ? LoadingBodyScreen()
            : Scaffold(
          appBar: PreferredSize(
            preferredSize: Size.fromHeight(95),
            child: AppBar(
              toolbarHeight: 95,
              titleSpacing: 0,
              title: Container(
                width: Get.width,
                height: 95,
                child: Column(
                  children: [
                    Padding(
                      padding:const EdgeInsets.fromLTRB(
                          30, 15, 30, 0),
                      child: Row(
                        children: [
                          Container(
                            width : (Get.width <= 1500) ? Get.width*0.375 : Get.width*0.465,
                            child: Text(
                              '${st.individualSatGet[0]['mainTitle']}',
                              style: f24w700,
                            ),
                          ),
                          Spacer(),
                          Container(
                            child: Center(
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () {
                                  showComponentDialog(
                                    context,
                                    '시험을 종료하시겠습니까?',
                                        () async {
                                          await satStatusChange('${st.satUpdateDocId}', '2'); //종료
                                          Get.offNamedUntil(BottomNavigator.id, (route) => true);
                                    },
                                  );
                                },
                                child: Text(
                                  'Exit',
                                  style: kIsWeb && (Get.width * 0.2 <= 171) ? f14w700primary : f16w700primary,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                        height: 10
                    ),
                    DottedLine()
                  ],
                ),
              ),
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [],
              backgroundColor: Colors.white,
            ),
          ),
          backgroundColor: Colors.white,
          body:  SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                SizedBox(
                  height: 1,
                ),
                Container(
                  width: Get.width*0.5,
                  height: Get.height*0.8,
                  decoration: BoxDecoration(
                    color: Colors.black,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20,left: 100),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                                Container(
                                  width: Get.width*0.15,
                                  height: 130,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.white)
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 20),
                                    child: Column(
                                      children: [
                                        Text('Remaing Break Time:',style: f21Whitew500,),
                                        Spacer(),
                                        Countdown(
                                          color: '1',
                                          animation: StepTween(
                                            begin: _timeController.duration!.inSeconds,
                                            end: 0,
                                          ).animate(_timeController),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                SizedBox(
                                height: 20,
                              ),
                              a==1?Center(
                                child: GestureDetector(
                                  onTap: (){
                                    if(st.satpart.value=='1'){
                                      showConfirmTapDialog(context, '영어 모듈2를 시작하시겠습니까?', () {
                                        RefreshManager.addToCookie('satpart', '2');
                                        Get.toNamed(TestIndividualSat.id);
                                      });
                                    }
                                    else if(st.satpart.value=='2'){
                                      showConfirmTapDialog(context, '수학 모듈1을 시작하시겠습니까?', () {
                                        RefreshManager.addToCookie('satpart', '3');
                                        Get.toNamed(TestIndividualSatMath.id);
                                      });
                                    }
                                    else if(st.satpart.value=='3'){
                                      showConfirmTapDialog(context, '수학 모듈2를 시작하시겠습니까?', () {
                                        RefreshManager.addToCookie('satpart', '4');
                                        Get.toNamed(TestIndividualSatMath.id);
                                      });
                                    }
                                  },
                                  child: Container(
                                    width: Get.width*0.1,
                                    height: 40,
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius: BorderRadius.circular(8)
                                    ),
                                    child: Center(
                                        child: Text('Resume Testing',style: f16Whitew500,)
                                    ),
                                  ),
                                ),
                              ):Container()
                            ]
                        ),
                        SizedBox(
                          width: 50,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 30,right: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Practice Test Break\n',style: f16Whitew700,),
                              Text("you can resume this practice test as soon as you're",style: f12Whitew400,),
                              Text("ready to move on. On test day, you'll wait unitl the",style: f12Whitew400,),
                              Text('clock counts down.',style: f12Whitew400,),
                              SizedBox(
                                height: 20,
                              ),
                              SizedBox(
                                width: 280,
                                height: 1,
                                child: Divider(
                                  thickness: 1,
                                  color: const Color(0xffDADADA),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text('Take a Break\n',style: f16Whitew700,),
                              Text("you may leave the room, but do not disturb",style: f12Whitew400,),
                              Text("students who are still testing\n",style: f12Whitew400,),
                              Text("Do not exit the app or close your device\n",style: f12Whitew400,),
                              Text("Testing won't resume until you return\n",style: f12Whitew400,),
                              Text('Follow these rules during the break:\n',style: f16Whitew700,),
                              Text("1. Do not access your phone,smartwatch,",style: f12Whitew400,),
                              Text("textbooks, notes, or the internet\n",style: f12Whitew400,),
                              Text("2. Do not eat or drink in the test room\n",style: f12Whitew400,),
                              Text("3. Do not speak in the test room; outside the test",style: f12Whitew400,),
                              Text("room. do not discuss the exam with anyone.",style: f12Whitew400,),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Container(
                  height: 10,
                ),
                SizedBox(
                  height: 20,
                ),
                Footer(),
              ],
            ),
          )
        ),
      ),
    );
  }
}
