import 'package:academy/components/button/choose_button.dart';
import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/components/footer/footer.dart';
import 'package:academy/provider/sat_state.dart';
import 'package:academy/screen/main/student/test/individual/sat/test_breakTime_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dotted_line/dotted_line.dart';
import 'package:academy/util/colors.dart';
import 'package:academy/util/loading.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:extended_image/extended_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../../../../../firebase/firebase_sat.dart';
import '../../../../../../firebase/firebase_user.dart';
import '../../../../../../provider/user_state.dart';
import '../../../../../../util/count_down.dart';
import '../../../../../../util/font/font.dart';
import '../../../../../../util/refresh_manager.dart';
import '../../../../../login/login_main_screen.dart';

class TestIndividualSatMath extends StatefulWidget {
  static final String id = '/test_ind_satMath';
  final String? docId;
  final String? isChecked;
  final bool? myPage;
  final int? part;
  const TestIndividualSatMath({Key? key, this.docId, this.isChecked= '', this.myPage, this.part})
      : super(key: key);

  @override
  State<TestIndividualSatMath> createState() => _TestIndividualState();
}

class _TestIndividualState extends State<TestIndividualSatMath>
    with TickerProviderStateMixin {
  final controller = PageController();
  final controller2 = PageController();
  int _pageIndex = 0;
  int correct = 0;
  List<String> number = ['1', '2', '3', '4'];
  List<String> number2 = ['a', 'b', 'c', 'd'];

  List _answer = [];
  bool _isLoading = true;
  AudioPlayer _player = AudioPlayer();
  Animation? _animation;
  Function() animationListener = () {};

  TextEditingController _numberCon = TextEditingController();
  AnimationController? _timeController;
  int first = 0;
  int selectedValue = 0;
  String studentList = '';
  List answerList = [];
  List<TextEditingController> ltec = [];

  @override
  void initState() {
    final st = Get.put(SatState());
    Future.delayed(Duration.zero, () async {
      await userGet(RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
      st.satTeacherDocId.value =  RefreshManager.getCookie('satTeacherDocId');
      st.satmyPage.value = RefreshManager.getCookie('satmyPage');
      st.satpart.value = RefreshManager.getCookie('satpart');
      st.satUpdateDocId.value = RefreshManager.getCookie('satUpdateDocId');
      studentList = RefreshManager.getCookie('studentList');
      /// 새로고침했을때 데이터 넣기
      if(st.satUpdateDocId.value!=''){
        CollectionReference ref2 = FirebaseFirestore.instance.collection('satAnswer');
        QuerySnapshot snapshot2 = await ref2.where('docId', isEqualTo: '${st.satUpdateDocId.value}').get();
        final allData = snapshot2.docs.map((doc) => doc.data()).toList();
        List a = allData;
        await firebaseSatGet();
        st.satAnswer.value = st.individualSatGet[0]['answer'];
        if(st.satpart.value=='3') {
          st.totalAnswer.value = a[0]['answer'];
          ltec = List.generate(22, (i) => TextEditingController());
          _answer = st.totalAnswer.sublist(54, 76).toList();
        }
        else if(st.satpart.value=='4') {
          st.totalAnswer.value = a[0]['answer'];
          ltec = List.generate(22, (i) => TextEditingController());
          _answer = st.totalAnswer.sublist(76, 98).toList();
        }
        if(a[0]['minute']=='0' && a[0]['second']=='0' || a[0]['status'] == '3'){
          await satStatusChange('${st.satUpdateDocId}', ''); //초기화
          _timeController = AnimationController(vsync: this, duration: Duration(minutes: 35)); //35
        }
        else{
          _timeController = AnimationController(vsync: this, duration: Duration(minutes: int.parse(a[0]['minute']),seconds:int.parse(a[0]['second']) ));
        }
        _timeController!.forward();
      }
      else{
        if(st.satpart.value=='3') {
          ltec = List.generate(22, (i) => TextEditingController());
          _answer = st.totalAnswer.sublist(54, 76).toList();
        }
        /// 파트 2 (안들어옴 예외?)
        else if(st.satpart.value=='4') {
          ltec = List.generate(22, (i) => TextEditingController());
          _answer = st.totalAnswer.sublist(76, 98).toList();
        }
        _timeController = AnimationController(vsync: this, duration: Duration(minutes: 35)); //35
        _timeController!.forward();
      }

      /// 타임 리스너
      _timeController!.addListener(() async {
        Duration duration = _timeController!.duration! * (1.0 - _timeController!.value); // 남은 시간 계산
        int minutes = duration.inMinutes;
        int seconds = (duration.inSeconds % 60);
        if(st.satUpdateDocId.value!=''){
          await firebaseSatTimeUpdate(minutes,seconds);
        }
        if (_timeController!.isCompleted) {
          /// 파트 3 쉬는시간
          if(st.satpart.value=='3'){
            showConfirmTapDialog(context, '수고하셨습니다\n\n수학 모듈1이 종료되었습니다.',
                    () {
                  Get.back();
                  Get.toNamed(BreakTimeScreen.id,
                      arguments: BreakTimeScreen(
                        docId: st.satTeacherDocId.value,
                        myPage: false,
                        part: 1,
                      ));
                });
          }
          ///파트 4 쉬는 시간
          else if(st.satpart.value=='4'){
            showConfirmTapDialog(context, '수고하셨습니다\n\n수학 모듈2가 종료되었습니다.',
                    () async {
                  Get.back();
                  await satStatusChange('${st.satUpdateDocId}', '4'); //종료
                  Get.offNamedUntil(BottomNavigator.id,(route) =>true);
                });
          }
        }
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
    _player.dispose();
    _timeController!.stop();
    _timeController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final us = Get.put(UserState());
    AnimationController _animationController = AnimationController(duration: Duration(milliseconds: 200), vsync: this);
    final st = Get.put(SatState());
    return WillPopScope(
      onWillPop: () {
        return Future(() {
          if (st.satmyPage.value=='true') {
            Get.back();
          } else {
            showComponentDialog(context, '시험을 종료하시겠습니까?', () async {
              await satStatusChange('${st.satUpdateDocId}', '2'); //종료
              Get.back();
              Get.back();
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
                child: PageView.builder(
                  controller: controller2,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _answer.length,
                  onPageChanged: (value) {
                    setState(() {
                      _pageIndex = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    return Column(
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
                              Center(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Center(
                                      child:Countdown(
                                        animation: StepTween(
                                          begin: _timeController!.duration!.inSeconds,
                                          end: 0,
                                        ).animate(_timeController!),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: 50,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.black,
                                        ),
                                      ),
                                      child: Center(child: Text('show',style: f12w500,)),
                                    ),
                                  ],
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
                                          Get.toNamed(BottomNavigator.id);
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
                    );
                  },
                ),
              ),
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [],
              backgroundColor: Colors.white,
            ),
          ),
          backgroundColor: Colors.white,
          body: StreamBuilder<QuerySnapshot>(
            stream:
            FirebaseFirestore.instance.collection('satAnswer')
                .where('docId', isEqualTo: '${st.satUpdateDocId}')
                .snapshots(),
            builder: (_,snapshot){
              return  PageView.builder(
                controller: controller,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (value) {
                  setState(() {
                    _pageIndex = value;
                  });
                },
                itemCount: _answer.length,
                itemBuilder: (context, index) {
                  if(st.satpart.value=='3'){
                    index = index+54;
                  }
                  else if(st.satpart.value=='4'){
                    index = index+76;
                  }
                  if (first ==0&&snapshot.connectionState == ConnectionState.waiting) {
                    first = 1;
                    return Center(
                      child: LoadingBodyScreen(),
                    );
                  }
                  else{
                    return SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              /// 왼쪽
                              Expanded(
                                child: Container(
                                  width: (Get.width <= 1500) ? Get.width*0.4 : Get.width*0.495,
                                  height: Get.height*0.8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        color: Colors.grey.withOpacity(0.5),
                                        offset: Offset(-2, 0),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: EdgeInsets.only(bottom: 20),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        st.individualSatGet[0]['image'][index]==''
                                            ?Container():
                                        Padding(
                                          padding: const EdgeInsets.only(left: 30,right: 30),
                                          child: Column(
                                            children: [
                                              st.individualSatGet[0]['image'].length == 0
                                                  ? SizedBox(height:0)
                                                  : !st.individualSatGet[0]['image'][index].contains('no')
                                                  ? (kIsWeb && (Get.width * 0.2 <= 171))
                                              //     ? ExtendedImage.network(
                                              //   '',
                                              //   fit: BoxFit.contain,
                                              //   mode: ExtendedImageMode.gesture,
                                              //   width: (kIsWeb &&
                                              //       (Get.width * 0.2 <= 171))
                                              //       ? Get.width
                                              //       : Get.width * 0.6,
                                              //   height: (kIsWeb &&
                                              //       (Get.width * 0.2 <= 171))
                                              //       ? Get.width
                                              //       : Get.width * 0.4,
                                              //   cache: true,
                                              //   enableLoadState: false,
                                              //   onDoubleTap:
                                              //       (ExtendedImageGestureState state) {
                                              //     var pointerDownPosition =
                                              //         state
                                              //             .pointerDownPosition;
                                              //     double begin = state
                                              //         .gestureDetails!
                                              //         .totalScale!;
                                              //     double end;
                                              //     _animation?.removeListener(
                                              //         animationListener);
                                              //     _animationController.stop();
                                              //     _animationController
                                              //         .reset();
                                              //
                                              //     if (begin == 1) {
                                              //       end = 1.5;
                                              //     } else {
                                              //       end = 1;
                                              //     }
                                              //     animationListener = () {
                                              //       state.handleDoubleTap(
                                              //           scale:
                                              //           _animation!.value,
                                              //           doubleTapPosition:
                                              //           pointerDownPosition);
                                              //     };
                                              //     _animation =
                                              //         _animationController
                                              //             .drive(
                                              //             Tween<double>(
                                              //                 begin:
                                              //                 begin,
                                              //                 end: end));
                                              //
                                              //     _animation!.addListener(
                                              //         animationListener);
                                              //
                                              //     _animationController
                                              //         .forward();
                                              //   },
                                              // )
                                              ? SizedBox(height: 0,)
                                                  : Center(
                                                child: ExtendedImage.network(
                                                  'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/sat%2F${st.satTeacherDocId}%2F${index}.png?alt=media',
                                                  // 'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/teacher%2F${ts.individualTestGet[0]['teacher']}%2F${ts.individualTestGet[0]['docId']}%2F${ts.individualTestGet[0]['images'][index]}?alt=media',
                                                  fit: BoxFit.contain,
                                                  // mode: ExtendedImageMode.gesture,
                                                  width:
                                                  // (kIsWeb &&
                                                  //         (Get.width * 0.2 <= 171))
                                                  //     ? Get.width
                                                  //     : Get.width * 0.6,
                                                  Get.width*0.2,
                                                  height: (kIsWeb &&
                                                      (Get.width * 0.2 <= 171))
                                                      ? Get.width
                                                      : Get.width * 0.2,
                                                  cache: true,
                                                  enableLoadState: false,
                                                ),
                                              )
                                                  : SizedBox(height: 0,),
                                                  st.individualSatGet[0]['image'].length == 0
                                                  ?  SizedBox(height: 0,)
                                                  :st.individualSatGet[0]['image'][index] != '' ? SizedBox(height: 20,)
                                                  :  SizedBox(height: 0,)
                                            ],
                                          ),
                                        ),
                                        Spacer(),
                                        Divider(
                                          color: Colors.black,
                                          height: 1,
                                          thickness: 3,
                                          indent: 10,
                                          endIndent: 10,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12,),
                              /// 오른쪽
                              Expanded(
                                child: Container(
                                  width: (Get.width <= 1500) ? Get.width*0.4 : Get.width*0.495,
                                  height: Get.height*0.8,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    boxShadow: [
                                      BoxShadow(
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        color: Colors.grey.withOpacity(0.5),
                                        offset: Offset(2, 2),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 20),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: (kIsWeb && (Get.width * 0.2 <= 171))
                                              ? EdgeInsets.only(right: 24, left: 24)
                                              : EdgeInsets.only(right: 24, left: 24),
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                                top: 32, right: 24, left: 24,bottom: 24),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                GestureDetector(
                                                  onTap: () {
                                                    _numberCon.text = '';
                                                    showEditDialogSat(context, '몇 번으로 이동하시겠습니까',
                                                            () {
                                                          Get.back();
                                                          controller.animateToPage(
                                                            int.parse('${_numberCon.text}') - 1,
                                                            duration: Duration(milliseconds: 200),
                                                            curve: Curves.linear,
                                                          );
                                                          controller2.animateToPage(
                                                            int.parse('${_numberCon.text}') - 1,
                                                            duration: Duration(milliseconds: 200),
                                                            curve: Curves.linear,
                                                          );
                                                          _player.stop();
                                                        }, _numberCon,(v){
                                                          Get.back();
                                                          controller.animateToPage(
                                                            int.parse('${_numberCon.text}') - 1,
                                                            duration: Duration(milliseconds: 200),
                                                            curve: Curves.linear,
                                                          );
                                                          controller2.animateToPage(
                                                            int.parse('${_numberCon.text}') - 1,
                                                            duration: Duration(milliseconds: 200),
                                                            curve: Curves.linear,
                                                          );
                                                          _player.stop();
                                                        });
                                                  },
                                                  child: Container(
                                                    width:40,
                                                    height: 30,
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius: BorderRadius.circular(4)
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        '${index + 1}',
                                                        style: f12Whitew700,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 12,
                                                ),

                                                ///  우측 사진 보이는 곳
                                                // ExtendedImage.network(
                                                //   'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/sat%2F${st.satTeacherDocId}%2F${index}.png?alt=media',
                                                //   fit: BoxFit.contain,
                                                //   width: Get.width*0.2,
                                                //   height: (kIsWeb &&
                                                //       (Get.width * 0.2 <= 171))
                                                //       ? Get.width
                                                //       : Get.width * 0.2,
                                                //   cache: true,
                                                //   enableLoadState: false,
                                                // ),
                                                SizedBox(
                                                  height: 20,
                                                ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(horizontal: 30),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      st.satAnswer[index] == 'a' || st.satAnswer[index] == 'b' ||
                                                          st.satAnswer[index] == 'c' || st.satAnswer[index] == 'd' ||
                                                          st.satAnswer[index] == '' ?
                                                      Container(
                                                        height: 35,
                                                        decoration: BoxDecoration(
                                                            border: Border(
                                                                bottom: BorderSide(
                                                                    width: 1,
                                                                    color: Colors.grey.withOpacity(0.4)
                                                                )
                                                            )
                                                        ),
                                                        child: Padding(
                                                          padding: const EdgeInsets.only(top: 6),
                                                          child: Text(
                                                            st.satmyPage.value  == 'true'
                                                                ? '내가 입력한 답 : ${st.individualSatGet[index] == '1'
                                                                ? 'A'
                                                                : st.individualSatGet[index] == '2'
                                                                ? 'B'
                                                                : st.individualSatGet[index] == '3'
                                                                ? 'C'
                                                                : st.individualSatGet[index] == '4'
                                                                ? 'D'
                                                                : '${st.individualSatGet[index]}'}'
                                                                : '정답 선택',
                                                            style: f16w700,
                                                          ),
                                                        ),
                                                      ) : const SizedBox(height: 0,),
                                                      SizedBox(
                                                        width: 30,
                                                      ),
                                                      Padding(
                                                        padding: const EdgeInsets.only(top: 6),
                                                        child: st.individualSatGet[0]['answer'][index] == ''?Container():
                                                        Text('정답 : ',style: f16w700,),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      Container(
                                                          height: 35,
                                                          decoration: BoxDecoration(
                                                              border: Border(
                                                                  bottom: BorderSide(
                                                                      width: 1,
                                                                      color: Colors.black
                                                                  )
                                                              )
                                                          ),
                                                          child:
                                                            st.satAnswer[index] == 'a' || st.satAnswer[index] == 'b' ||
                                                            st.satAnswer[index] == 'c' || st.satAnswer[index] == 'd' ||
                                                                st.satAnswer[index] == ''?
                                                          Row(
                                                            children: [
                                                              ListView(
                                                                scrollDirection: Axis.horizontal,
                                                                shrinkWrap: true,
                                                                children: List.generate(number.length, (i) => Column(
                                                                  children: [
                                                                    Row(
                                                                      children: [
                                                                        st.satmyPage.value=='true'
                                                                        /// 점수확인 라디오
                                                                            ? Radio(
                                                                          value:'${i+1}',
                                                                          groupValue: st.totalAnswer[index],
                                                                          onChanged: (value) {
                                                                            setState(() {
                                                                            });
                                                                          },
                                                                          activeColor: st.totalAnswer[index]== '${i+1}'? nowColor : Colors.transparent,
                                                                        )
                                                                        /// 학생 시험 라디오
                                                                            : Radio(
                                                                          value:'${number2[i]}',
                                                                          groupValue: st.totalAnswer[index],
                                                                          onChanged: (value){
                                                                            if( st.satmyPage.value  !='true'){
                                                                              st.totalAnswer[index] = '${value}';
                                                                              firebaseSatAnswerUpdate(st.totalAnswer).then((value){
                                                                                // if(_pageIndex != 21) {
                                                                                //   Future.delayed(Duration(milliseconds: 200),(){
                                                                                //     controller.animateToPage(
                                                                                //         controller.page!.toInt() + 1,
                                                                                //         duration: Duration(milliseconds: 200),
                                                                                //         curve: Curves.linear);
                                                                                //     controller2.animateToPage(
                                                                                //         controller2.page!.toInt() + 1,
                                                                                //         duration: Duration(milliseconds: 200),
                                                                                //         curve: Curves.linear);
                                                                                //   });
                                                                                // }
                                                                              });
                                                                              setState((){});
                                                                            }
                                                                          },
                                                                          activeColor: st.totalAnswer[index] == '${number2[i]}'? nowColor : Colors.transparent,
                                                                        ),
                                                                        Text('${String.fromCharCode('A'.codeUnitAt(0) + i)}',style: f16w700,),
                                                                        SizedBox(
                                                                          width: 30,
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ],
                                                                )),
                                                              ),
                                                            ],
                                                          )
                                                          : Container(width: 200,
                                                              child: TextField(
                                                                onChanged: (value) {
                                                                  if (st.satmyPage.value != 'true') {
                                                                    st.totalAnswer[index] = '${value}';
                                                                    firebaseSatAnswerUpdate(st.totalAnswer);
                                                                  }
                                                                },
                                                                controller:
                                                                st.satpart.value=='4' ? ltec[index - 76] : ltec[index - 54],
                                                                decoration: InputDecoration(
                                                                  filled: false,
                                                                  isDense: true,
                                                                  fillColor: Colors.transparent,
                                                                  enabledBorder: OutlineInputBorder(
                                                                    // borderRadius: BorderRadius.all(Radius.circular(12.0)),
                                                                    borderSide: BorderSide(color: Colors.transparent),
                                                                  ),
                                                                  focusedBorder: OutlineInputBorder(
                                                                    // borderRadius: BorderRadius.all(Radius.circular(10.0)),
                                                                    borderSide: BorderSide(color: Colors.transparent),
                                                                  ),
                                                                ),
                                                                keyboardType: TextInputType.text,
                                                                minLines: 1,
                                                                inputFormatters: [
                                                                  LengthLimitingTextInputFormatter(100),
                                                                ],
                                                              ),
                                                            )
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Spacer(),
                                        SizedBox(
                                          width: (Get.width <= 1500) ? Get.width*0.4 : Get.width*0.495,
                                          child: Divider(
                                            color: Colors.black,
                                            height: 1,
                                            thickness: 3,
                                            indent: 10,
                                            endIndent: 10,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Padding(
                            padding:const EdgeInsets.fromLTRB(
                                30, 5, 30, 0),
                            child: Row(
                              children: [
                                Text(
                                  '${us.userList[0].nickName}',
                                  style: f24w700,
                                ),
                                Spacer(),
                                GestureDetector(
                                    onTap: () {
                                      _numberCon.text = '';
                                      showEditDialog(
                                          context, '몇 번으로 이동하시겠습니까',
                                              () {
                                            Get.back();
                                            controller.animateToPage(int.parse('${_numberCon.text}') - 1,
                                              duration: Duration(milliseconds: 200),
                                              curve: Curves.linear,
                                            );
                                            controller2.animateToPage(
                                              int.parse('${_numberCon.text}') - 1,
                                              duration: Duration(milliseconds: 200),
                                              curve: Curves.linear,
                                            );
                                            _player.stop();
                                          }, _numberCon);
                                    },
                                    child: Container(
                                      width: Get.width*0.08,
                                      height: 30,
                                      decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(8)
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10,right: 10),
                                        child: Row(
                                          children: [
                                            Text(
                                              // 'question\t${index + 1}/${st.individualSatGet[0]['answer'].length}',
                                              st.satpart.value=='4'
                                                  ?'question\t${(index-76) + 1}/${_answer.length}'
                                                  :'question\t${(index-54) + 1}/${_answer.length}',
                                              style: f16Whitew500,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )),
                                Spacer(),
                                Container(
                                    child: Row(
                                      children: [
                                        LeftRightButtonSat(
                                            onTap: () {
                                              _player.stop();
                                              controller.previousPage(
                                                duration: Duration(
                                                    milliseconds: 200),
                                                curve: Curves.linear,
                                              );
                                              controller2.previousPage(
                                                duration: Duration(
                                                    milliseconds: 200),
                                                curve: Curves.linear,
                                              );
                                            },
                                            title: 'back',
                                            icon: true),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        LeftRightButtonSat(
                                            onTap: () {
                                              _player.stop();
                                              if (st.satmyPage.value != 'true') {
                                                /// 76번까지
                                                if(_pageIndex==21 && st.satpart == '3'){
                                                  showComponentDialog(
                                                      context, '수학 모듈2로 넘어가시겠습니까?', () async {
                                                    Get.back();
                                                    Get.toNamed(BreakTimeScreen.id,
                                                        arguments: BreakTimeScreen(
                                                          docId: st.satTeacherDocId.value,
                                                          myPage: false,
                                                          part: 1,
                                                        ));
                                                  });
                                                }
                                                else if (_pageIndex==21 && st.satpart == '4') {
                                                    showComponentDialog(
                                                        context,
                                                        '제출하시겠습니까?',
                                                            () async {
                                                          Get.back();
                                                          showConfirmTapDialog(
                                                              context,
                                                              '수고하셨습니다\n\n작성하신 답안이 정상적으로 제출 되었습니다',
                                                                  () async {
                                                                await satStatusChange('${st.satUpdateDocId}', '4'); //종료
                                                                Get.offNamedUntil(
                                                                    BottomNavigator
                                                                        .id,
                                                                        (route) =>
                                                                    true);
                                                              });
                                                        });
                                                  } else {
                                                    controller.animateToPage(
                                                        controller.page!.toInt() + 1,
                                                        duration: Duration(milliseconds: 200),
                                                        curve: Curves.linear);
                                                    controller2.animateToPage(
                                                        controller2.page!.toInt() + 1,
                                                        duration: Duration(milliseconds: 200),
                                                        curve: Curves.linear);
                                                  }
                                              }
                                              else if (_pageIndex == st.individualSatGet[0]['answer'].length - 1) {
                                                Get.back();
                                              } else {
                                                controller.animateToPage(
                                                    controller.page!.toInt() + 1,
                                                    duration: Duration(milliseconds: 200),
                                                    curve: Curves.linear);
                                                controller2.animateToPage(
                                                    controller2.page!.toInt() + 1,
                                                    duration: Duration(
                                                        milliseconds: 200),
                                                    curve: Curves.linear);
                                              }
                                            },
                                            title: 'next',
                                            icon: false),
                                      ],
                                    )),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Footer(),
                        ],
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
