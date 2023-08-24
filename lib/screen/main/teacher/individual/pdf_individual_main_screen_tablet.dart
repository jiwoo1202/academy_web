import 'dart:io';
import 'dart:convert';
import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/components/footer/footer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;

import '../../../../components/tile/textform_field.dart';
import '../../../../firebase/firebase_answer.dart';
import '../../../../model/answer.dart';
import '../../../../provider/answer_state.dart';
import '../../../../provider/user_state.dart';
import '../../../../util/colors.dart';
import '../../../../util/font/font.dart';
import '../../../../util/font/font.dart';
import '../../../../util/loading.dart';
import '../../../../util/refresh_manager.dart';
import '../../../login/login_main_screen.dart';
import '../../main_screen.dart';
import 'pdf_upload_individual_screen.dart';

class PdfIndMainScreenTablet extends StatefulWidget {
  static final String id = '/pdf_ind_main_tablet';
  final String edit;
  final String category;
  final String password;
  final String docId;
  final String? teacher;
  final List? answer;
  final List? body;
  final List? title;
  final List? image;
  final List? file;

  final List? audio;
  final List? pdfUploadName;
  final List? pdfUploadName2;
  final String? countdown;
  final String? state;
  final List? essayAnswer;

  const PdfIndMainScreenTablet(
      {Key? key,
      this.edit= '',
      this.docId= '',
      this.answer,
      this.body,
      this.title,
      this.image,
      this.password= '',
      this.category= '',
      this.file,
      this.countdown, this.teacher, this.audio, this.pdfUploadName, this.pdfUploadName2, this.state, this.essayAnswer})
      : super(key: key);

  @override
  State<PdfIndMainScreenTablet> createState() => _PdfIndMainScreenTabletState();
}

class _PdfIndMainScreenTabletState extends State<PdfIndMainScreenTablet> {
  List<String> pickedFiles = ['']; //사진 파일
  List<String> pickedFiles2 = ['']; // 듣기 파일
  UploadTask? uploadTask;
  TextEditingController _testNameController = TextEditingController();
  TextEditingController _testPwController = TextEditingController();
  TextEditingController _testCountController = TextEditingController();
  TextEditingController _testCountController2 = TextEditingController();

  bool _obscureText = false;
  bool _imageLoading = false;
  bool _titleCheck = true; // 제목입력했는지 검사하는 bool
  bool _bodyCheck = true; // 내용입력했는지 검사하는 bool
  List _answerList = [];
  List _imagesList = [];

  List<bool> firstTrue = [false]; //주관식 변경
  List<bool> secondTrue = [false];
  List<String> number = ['1', '2', '3', '4', '5']; //원형 숫자 만들기
  List<TextEditingController> _testBodyCon = [TextEditingController()]; //내용
  List<TextEditingController> _testTiCon = [TextEditingController()]; //문제제목
  List<TextEditingController> _testEssayCon = [TextEditingController()]; //주관식 답
  List<String> _answer = ['0']; // 정답 입력
  List<int> textLength = [0];
  List<int> textLength2 = [0];
  List _editList = [];
  bool scoreVisual = false;
  @override
  void initState() {
    Future.delayed(Duration.zero,(){
      final args = ModalRoute.of(context)!.settings.arguments as PdfIndMainScreenTablet?;
      final as = Get.put(AnswerState());
      as.essayList.value = [''];
      as.individualTitle.value = [''];
      as.individualBody.value = [''];
      as.individualFile.value = [''];
      as.individualFilePath.value = [''];
      as.individualFile2.value = [''];
      as.individualFilePath2.value = [''];
      as.pdfUploadName.value=[''];
      as.pdfUploadName2.value=[''];
      as.choiceList.value = [''];
      as.tmpidx.value = ['']; // tmpidx 주관식만 답는 용도

      _answerList.add('1');
      _testCountController.text = '1';
      _testCountController2.text = '100';
      _editList.add('');

      setState(() {});
      if (args?.edit == 'true') {
        firstTrue = [];
        secondTrue = [];
        _testTiCon = [];
        _testBodyCon = [];
        textLength = [];
        textLength2 = [];
        _answer = [];
        pickedFiles = [];
        pickedFiles2 = [];
        _editList = [];
        as.individualFile.value = [];
        as.individualFile2.value = [];

        as.individualFilePath.value = [];
        as.individualFilePath2.value = [];
        as.indEditList.value = [];
        as.indEditList2.value = [];

        as.pdfUploadName.value=[]; // pdf 이름
        as.pdfUploadName2.value=[]; // 오디오 이름
        _testPwController.text = args!.password;
        _testNameController.text = args.category;
        _testCountController.text = '${args.answer!.length}';
        _testCountController2.text = args.countdown!;
        _answerList = args.answer!;

        as.individualTitle.value = args.title!;
        as.individualBody.value = args.body!;
        for(int i = 0; i < args.file!.length; i++){
          args.file![i] == 'edit' ||  args.file![i] == 'yes' ? as.individualFile.add('yes') : as.individualFile.add('');
          args.file![i] == 'edit' ||  args.file![i] == 'yes' ? as.individualFilePath.add('yes') : as.individualFilePath.add('');
          args.file![i] == 'edit' ||  args.file![i] == 'yes' ? as.indEditList.add('yes') : as.indEditList.add('');
        }
        for(int i = 0; i < args.audio!.length; i++){
          args.audio![i].contains('no')?as.individualFile2.add(''):as.individualFile2.add('yes'); //
          args.audio![i].contains('no')?as.individualFilePath2.add(''):as.individualFilePath2.add('yes');//파일업로드
          args.audio![i].contains('no')?as.indEditList2.add(''):as.indEditList2.add('yes');//파일업로드
        }

        as.editIndividualImage.value = args.image!;

        as.editIndividualAudio.value = args.audio!;
        as.pdfUploadName.value= args.pdfUploadName!; //pdf이름 담기
        as.pdfUploadName2.value = args.pdfUploadName2!; // 오디오 이름 담기

        as.essayList.value = List.generate(args.answer!.length, (index) => ''); // 주관식
        as.tmpidx.value = List.generate(args.answer!.length, (index) => ''); // 수정할 때 tmpidx길이도 증가
        as.choiceList.value = List.generate(args.answer!.length, (index) => '');
        for (int i = 0; i < args.answer!.length; i++) {
          _testTiCon.add(TextEditingController()); // 제목 텍스트콘에 저장
          _testTiCon[i].text = ( args.title![i]); // 제목 텍스트콘에 저장
          _testBodyCon.add(TextEditingController()); // 내용 텍스트콘에 저장
          _testBodyCon[i].text = (args.body![i]); // 내용 텍스트콘에 저장
          _testEssayCon.add(TextEditingController()); //주관식 저장
          _testEssayCon[i].text = (args.essayAnswer![i]); // 주관식 저장
          textLength.add(_testTiCon[i].text.length);
          // _testBodyCon[i].text = ;
          textLength2.add(_testBodyCon[i].text.length);
          // textLength2[i] = _testBodyCon[i].text.length;
          _answer.add(args.answer![i]);


          firstTrue.add(args.essayAnswer![i]!='');
          secondTrue.add(false);
          // textLength.add(0);
          // textLength2.add(0);
          pickedFiles.add(args.pdfUploadName![i]);
          pickedFiles2.add(args.pdfUploadName2![i]);
          _editList.add('');


          if (isNumeric(args.answer![i]) && args.answer![i].length == 1) {
            as.choiceList[i] = args.answer![i];
          } else {
            as.essayList[i] = args.essayAnswer![i];
          }
        }
        // as.essayList.value = widget.answer!;
        // for(int i = 0; i < args.answer!.length; i++){
        //   _answerList.add('1');
        // }
        setState(() {

        });
      }
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
    super.dispose();
    _testNameController.dispose();
    _testPwController.dispose();
    _testCountController.dispose();
    _testCountController2.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());
    final args = ModalRoute.of(context)!.settings.arguments as PdfIndMainScreenTablet?;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: WillPopScope(
        onWillPop: () {
          return Future(() {
            _useBackKey(context);
            return true;
          });
        },
        child: Scaffold(backgroundColor: backColor,
          appBar: AppBar(
            backgroundColor: nowColor,
            elevation: 0,
            // leading: IconButton(
            //   icon: Icon(
            //     Icons.arrow_back_ios,
            //     color: Colors.black,
            //   ),
            //   onPressed: () {
            //     showComponentDialog(context, '작성을 취소하시겠습니까?', () {
            //       Get.offAllNamed(MainScreen.id);
            //     });
            //   },
            // ),
            centerTitle: false,
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                SvgPicture.asset(
                  'assets/logo.svg',
                  width: (kIsWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
                  height: (kIsWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
                ),
                SizedBox(
                  width: 8,
                ),
                kIsWeb && (Get.width * 0.2 <= 171)
                    ? Container()
                    : Text('문제추가(개별)')
              ],
            ),
            // actions: [
            //   args?.state=='임시'||args?.edit!='true'?
            //   GestureDetector(
            //       onTap: (){
            //         as.answer.clear();
            //         for (int i = 0; i < _answerList.length; i++) {
            //           if (as.essayList[i] != '') {
            //             as.answer.add('');
            //           } else {
            //             as.answer.add(as.choiceList[i]);
            //           }
            //         }
            //         as.group.value = '';
            //         as.password.value = _testPwController.text;
            //         as.pdfCategory.value = _testNameController.text;
            //         as.pdfName.value = '${DateTime.now()}';
            //         as.teacher.value = us.userList[0].id!;
            //
            //         showComponentDialog(context,
            //             args?.edit == 'true' ? '수정하시겠습니까?' : '임시저장하시겠습니까?',
            //                 () async {
            //               Get.back();
            //               if (args?.edit == 'true') {
            //                 await _update(args!.docId);
            //                 await _updateTimer('${args.docId}');
            //                 showConfirmTapDialog(context, '업로드를 완료했습니다', () {
            //                   Get.offAll(() => BottomNavigator());
            //                 });
            //               } else {
            //                 var contain = as.individualFile.where((element) => element != "");
            //                 await firebaseAnswerUploadIndividualSave(
            //                     uploadTask, contain.isEmpty);
            //               }
            //             });
            //       },
            //       child: Container(
            //         padding: const EdgeInsets.only(right: 28),
            //         child: const Center(
            //             child: Text(
            //               '임시저장',
            //               style: f16Whitew700,
            //             )),
            //       )
            //   ):Container(),
            //   // args?.state!='임시'?
            //   GestureDetector(
            //       behavior: HitTestBehavior.opaque,
            //       onTap: () async {
            //
            //         as.answer.clear();
            //         for (int i = 0; i < _answerList.length; i++) {
            //           if (as.essayList[i] != '') {
            //             as.answer.add('');
            //           } else {
            //             as.answer.add(as.choiceList[i]);
            //           }
            //         }
            //         as.group.value = '';
            //         as.password.value = _testPwController.text;
            //         as.pdfCategory.value = _testNameController.text;
            //         as.pdfName.value = '${DateTime.now()}';
            //         as.teacher.value = us.userList[0].id!;
            //
            //         //임시일때 저장버튼
            //         if(args?.state=='임시'){
            //           _titleCheck = true;
            //           _bodyCheck = true;
            //           for(int i=0;i<_answerList.length;i++){
            //             if(as.individualTitle[i]==''){
            //               setState(() {
            //                 _titleCheck = false;
            //               });
            //             }
            //             if(as.individualBody[i] ==''){
            //               setState(() {
            //                 _bodyCheck=false;
            //               });
            //             }
            //           }
            //           if(_titleCheck==true&&_bodyCheck==true){
            //             showComponentDialog(context, '업로드하시겠습니까?', () async{
            //               Get.back();
            //               await updateState('${args!.docId}');
            //               showConfirmTapDialog(context, '업로드를 완료했습니다', () {
            //                 Get.offAll(() => BottomNavigator());
            //               });
            //             });}
            //           else{
            //             showOnlyConfirmDialog(context, '문제를 입력해주세요');
            //           }
            //         }
            //         else{
            //           showComponentDialog(context,
            //               args?.edit == 'true' ? '수정하시겠습니까?' : '업로드하시겠습니까?',
            //                   () async {
            //                 Get.back();
            //                 if (args?.edit == 'true') {
            //                   await _update(args!.docId);
            //                   await _updateTimer('${args.docId}');
            //                   showConfirmTapDialog(context, '업로드를 완료했습니다', () {
            //                     // Get.offAll(() => BottomNavigator());
            //                     Get.offAllNamed(MainScreen.id);
            //                   });
            //                 } else {
            //                   var contain =
            //                   as.individualFile.where((element) => element != "");
            //
            //                   await firebaseAnswerUploadIndividual(
            //                       uploadTask, contain.isEmpty);
            //
            //                   // print(contain.isEmpty);
            //                 }
            //               });
            //         }
            //       },
            //       child: Container(
            //         padding: const EdgeInsets.only(right: 28),
            //         child: const Center(
            //             child: Text(
            //           '저장',
            //           style: f16Whitew700,
            //         )),
            //       )),
            //       // :Container(),
            //   GestureDetector(
            //     onTap: () {
            //       showComponentDialog(context, '로그아웃을 하시겠습니까?', () {
            //         Get.offAllNamed(LoginMainScreen.id);
            //         RefreshManager.addToCookie('id', '');
            //         RefreshManager.addToCookie('pw', '');
            //         us.isLogin.value = '';
            //       });
            //     },
            //     child: Center(
            //         child: Padding(
            //       padding: const EdgeInsets.only(right: 8.0),
            //       child: Image.asset(
            //         'assets/icon/logout.png',
            //         color: Colors.white,
            //         width: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
            //         height: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
            //       ),
            //     )),
            //   ),
            // ],
          ),
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Center(
              child: Column(
                children: [
                  Container(
                    width: Get.width * 0.8,
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: ScrollConfiguration(
                      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                      child: SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 40,),
                            Row(children: [
                              Text('문제추가 - 한개씩 등록', style: f32w700,),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  showComponentDialog(context, '문제추가를 종료할까요? ', () {
                                    Get.back();
                                    Get.back();
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(child: Text('나가기', style: f16w700,)),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xff535353),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12,),
                              GestureDetector(
                                onTap: (){
                                  as.answer.clear();
                                  for (int i = 0; i < _answerList.length; i++) {
                                    if (as.essayList[i] != '') {
                                      as.answer.add('');
                                    } else {
                                      as.answer.add(as.choiceList[i]);
                                    }
                                  }
                                  as.group.value = '';
                                  as.password.value = _testPwController.text;
                                  as.pdfCategory.value = _testNameController.text;
                                  as.pdfName.value = '${DateTime.now()}';
                                  as.teacher.value = us.userList[0].id!;
                                  showComponentDialog(context,
                                      args?.edit == 'true' ? '수정하시겠습니까?' : '임시저장하시겠습니까?',
                                          () async {
                                        Get.back();
                                        if (args?.edit == 'true') {
                                          await _update(args!.docId);
                                          await _updateTimer('${args.docId}');
                                          showConfirmTapDialog(context, '업로드를 완료했습니다', () {
                                            Get.offAll(() => BottomNavigator());
                                          });
                                        } else {
                                          var contain = as.individualFile.where((element) => element != "");
                                          await firebaseAnswerUploadIndividualSave(
                                              uploadTask, contain.isEmpty,scoreVisual);
                                        }
                                      });
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(child: Text('임시저장', style: f16w700,)),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: const Color(0xff535353),
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12,),
                              GestureDetector(
                                onTap: () async {

                                  as.answer.clear();
                                  for (int i = 0; i < _answerList.length; i++) {
                                    if (as.essayList[i] != '') {
                                      as.answer.add('');
                                    } else {
                                      as.answer.add(as.choiceList[i]);
                                    }
                                  }
                                  as.group.value = '';
                                  as.password.value = _testPwController.text;
                                  as.pdfCategory.value = _testNameController.text;
                                  as.pdfName.value = '${DateTime.now()}';
                                  as.teacher.value = us.userList[0].id!;

                                  //임시일때 저장버튼
                                  if(args?.state=='임시'){
                                    _titleCheck = true;
                                    _bodyCheck = true;
                                    for(int i=0;i<_answerList.length;i++){
                                      if(as.individualTitle[i]==''){
                                        setState(() {
                                          _titleCheck = false;
                                        });
                                      }
                                      if(as.individualBody[i] ==''){
                                        setState(() {
                                          _bodyCheck=false;
                                        });
                                      }
                                    }
                                    if(_titleCheck==true&&_bodyCheck==true){
                                      showComponentDialog(context, '업로드하시겠습니까?', () async{
                                        Get.back();
                                        await updateState('${args!.docId}');
                                        showConfirmTapDialog(context, '업로드를 완료했습니다', () {
                                          Get.offAll(() => BottomNavigator());
                                        });
                                      });}
                                    else{
                                      showOnlyConfirmDialog(context, '문제를 입력해주세요');
                                    }
                                  }
                                  else{
                                    showComponentDialog(context,
                                        args?.edit == 'true' ? '수정하시겠습니까?' : '업로드하시겠습니까?',
                                            () async {
                                          Get.back();
                                          if (args?.edit == 'true') {
                                            await _update(args!.docId);
                                            await _updateTimer('${args.docId}');
                                            showConfirmTapDialog(context, '업로드를 완료했습니다', () {
                                              // Get.offAll(() => BottomNavigator());
                                              Get.offAllNamed(MainScreen.id);
                                            });
                                          } else {
                                            var contain =
                                            as.individualFile.where((element) => element != "");

                                            await firebaseAnswerUploadIndividual(
                                                uploadTask, contain.isEmpty,scoreVisual);

                                            // print(contain.isEmpty);
                                          }
                                        });
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(12.0),
                                  child: Center(child: Text('저장', style: f16Whitew700,)),
                                  decoration: BoxDecoration(
                                    color: const Color(0xff070707),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],),

                            const SizedBox(height: 30,),
                            Container(
                              width: Get.width,
                              child: TextFormFields(
                                controller: _testNameController,
                                hintText: '시험 명을 입력해주세요',
                                surffixIcon: '0',
                                obscureText: true,
                              ),
                            ),
                            const SizedBox(
                              height: 40,
                            ),
                            SizedBox(
                              width: Get.width,
                              height: 1,
                              child: Divider(
                                thickness: 1,
                                color: const Color(0xffDADADA),
                              ),
                            ),

                            const SizedBox(
                              height: 40,
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: Get.width * 0.3,
                                  child: Column(mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('문항수', style: f18w400,),
                                      const SizedBox(height: 10,),
                                      Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
                                            color: testCountColor,
                                          ),
                                          width: Get.width * 0.2,
                                          child: TextFormField(
                                            controller: _testCountController,
                                            textAlign: TextAlign.center,
                                            enabled: args?.edit == true ? false : true,
                                            style: f16w400,
                                            textAlignVertical: TextAlignVertical.center,
                                            decoration: InputDecoration(
                                              isDense: false,
                                              hintText: '20',
                                              hintStyle: f16w400,
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              focusedBorder: InputBorder.none,
                                              prefixIcon: Container(height: 50,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.only(topLeft: Radius.circular(8.0), bottomLeft: Radius.circular(8.0)),
                                                    color: const Color(0xffEBEBEB)
                                                ),
                                                child: InkWell(
                                                  onTap: args?.edit == true ? null
                                                      : () {
                                                    if (args?.state == '임시') {
                                                      _answerList.removeLast();
                                                      _editList.removeLast();
                                                      as.essayList.value.removeLast();
                                                      as.tmpidx.value
                                                          .removeLast(); // tmp마지막 지우기
                                                      as.individualTitle.value.removeLast();
                                                      as.individualBody.value.removeLast();
                                                      as.individualFile.value.removeLast();
                                                      as.individualFilePath.value
                                                          .removeLast();

                                                      as.editIndividualImage.value
                                                          .removeLast(); // 이미지 지우기
                                                      as.editIndividualAudio.value
                                                          .removeLast(); // 오디오 지우기

                                                      as.individualFile2.value.removeLast();
                                                      as.individualFilePath2.value
                                                          .removeLast();
                                                      as.pdfUploadName2.value.removeLast();
                                                      as.pdfUploadName.value.removeLast();

                                                      as.choiceList.value.removeLast();
                                                      if (args?.edit == 'true') {
                                                        as.indEditList.value.removeLast();
                                                        as.indEditList2.value.removeLast();
                                                      }
                                                    }
                                                    else {
                                                      _answerList.removeLast();
                                                      _editList.removeLast();
                                                      as.essayList.value.removeLast();
                                                      as.tmpidx.value
                                                          .removeLast(); // tmp마지막 지우기
                                                      as.individualTitle.value.removeLast();
                                                      as.individualBody.value.removeLast();
                                                      as.individualFile.value.removeLast();
                                                      as.individualFilePath.value
                                                          .removeLast();

                                                      as.individualFile2.value.removeLast();
                                                      as.individualFilePath2.value
                                                          .removeLast();
                                                      as.pdfUploadName2.value.removeLast();
                                                      as.pdfUploadName.value.removeLast();
                                                      as.choiceList.value.removeLast();
                                                      if (args?.edit == 'true') {
                                                        as.indEditList.value.removeLast();
                                                        as.indEditList2.value.removeLast();
                                                      }
                                                    }

                                                    _testBodyCon.removeLast();
                                                    _testTiCon.removeLast();
                                                    _testEssayCon.removeLast();
                                                    firstTrue.removeLast();
                                                    secondTrue.removeLast();
                                                    _answer.removeLast();
                                                    textLength.removeLast();
                                                    textLength2.removeLast();
                                                    pickedFiles.removeLast();
                                                    pickedFiles2.removeLast();

                                                    setState(() {
                                                      // final x = _testCountController.text.obs;
                                                      ///_testCountController -
                                                      _testCountController.text = (_testCountController.text != '0' ?
                                                      int.parse(_testCountController.text) - 1 : 0).toString();
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.remove,
                                                    fill: 1,
                                                    // color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              suffixIcon: Container(height: 50,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.only(topRight: Radius.circular(8.0), bottomRight: Radius.circular(8.0)),
                                                    color: const Color(0xffEBEBEB)
                                                ),
                                                child: InkWell(
                                                  onTap: args?.edit == 'true'&&args?.state!='임시' ? (){}
                                                      : () {
                                                    if (args?.state == '임시') {
                                                      _answerList.add('1');
                                                      _editList.add('');
                                                      as.essayList.value.add('');
                                                      as.tmpidx.value.add(''); //tmp 길이 증가
                                                      as.individualTitle.value.add('');
                                                      as.individualBody.value.add('');
                                                      as.individualFile.value.add('');
                                                      as.individualFilePath.value.add('');
                                                      as.choiceList.value.add('');

                                                      as.editIndividualImage.value.add(
                                                          'no'); // 이미지 넣기
                                                      as.editIndividualAudio.value.add(
                                                          'no'); // 오디오 넣기
                                                      as.individualFile2.value.add('');
                                                      as.individualFilePath2.value.add('');
                                                      as.pdfUploadName2.value.add('');
                                                      as.pdfUploadName.value.add('');
                                                      if (args?.edit == 'true') {
                                                        as.indEditList.value.add('');
                                                        as.indEditList2.value.add('');
                                                      }
                                                    }
                                                    else {
                                                      _editList.add('');
                                                      _answerList.add('1');
                                                      as.essayList.value.add('');
                                                      as.tmpidx.value.add(''); //tmp 길이 증가
                                                      as.individualTitle.value.add('');
                                                      as.individualBody.value.add('');
                                                      as.individualFile.value.add('');
                                                      as.individualFilePath.value.add('');
                                                      as.choiceList.value.add('');

                                                      as.individualFile2.value.add('');
                                                      as.individualFilePath2.value.add('');
                                                      as.pdfUploadName2.value.add('');
                                                      as.pdfUploadName.value.add('');

                                                      if (args?.edit == 'true') {
                                                        as.indEditList.value.add('');
                                                        as.indEditList2.value.add('');
                                                      }
                                                    }

                                                    _testBodyCon.add(TextEditingController());
                                                    _testTiCon.add(TextEditingController());
                                                    _testEssayCon.add(TextEditingController());
                                                    firstTrue.add(false);
                                                    secondTrue.add(false);
                                                    _answer.add('0');
                                                    textLength.add(0);
                                                    textLength2.add(0);
                                                    pickedFiles.add('');
                                                    pickedFiles2.add('');

                                                    setState(() {
                                                      ///_testCountController +
                                                      _testCountController.text = (int.parse(_testCountController.text) + 1).toString();
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )),
                                      const SizedBox(height: 16,),

                                      Text('시간 설정 (초단위)', style: f18w400,),
                                      const SizedBox(height: 10,),
                                      Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8.0)),
                                            color: testCountColor,
                                          ),
                                          width: Get.width * 0.2,
                                          child: TextFormField(
                                            controller: _testCountController2,
                                            textAlign: TextAlign.center,
                                            enabled: args?.edit == true ? false : true,
                                            style: f16w400,
                                            textAlignVertical: TextAlignVertical.center,
                                            decoration: InputDecoration(
                                              isDense: false,
                                              hintText: '20',
                                              hintStyle: f16w400,
                                              border: InputBorder.none,
                                              contentPadding: EdgeInsets.zero,
                                              prefixIcon: Container(height: 50,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.only(topLeft: Radius.circular(8.0), bottomLeft: Radius.circular(8.0)),
                                                    color: const Color(0xffEBEBEB)
                                                ),
                                                child: InkWell(
                                                  onTap: args?.edit == true
                                                      ? null
                                                      : () {
                                                    setState(() {
                                                      // final x = _testCountController.text.obs;
                                                      ///_testCountController -
                                                      _testCountController2.text = (_testCountController2.text != '0'
                                                          ? int.parse(_testCountController2.text) - 1 : 0).toString();
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.remove,
                                                    fill: 1,
                                                    // color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                              suffixIcon: Container(height: 50,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.only(topRight: Radius.circular(8.0), bottomRight: Radius.circular(8.0)),
                                                    color: const Color(0xffEBEBEB)
                                                ),
                                                child: InkWell(
                                                  onTap: args?.edit == true
                                                      ? null
                                                      : () {
                                                    setState(() {
                                                      ///_testCountController +
                                                      _testCountController2.text = (int.parse(_testCountController2.text) + 1).toString();
                                                    });
                                                  },
                                                  child: Icon(
                                                    Icons.add,
                                                    color: Colors.black,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )),
                                      const SizedBox(height: 16,),

                                      Text('비밀번호', style: f18w400,),
                                      const SizedBox(height: 10,),
                                      Container(
                                        width: Get.width * 0.2,
                                        child: TextFormFields(
                                          controller: _testPwController,
                                          hintText: '비밀번호를 입력해 주세요',
                                          surffixIcon: '1',
                                          obscureText: _obscureText,
                                          onTap: () {
                                            setState(() {
                                              _obscureText = !_obscureText;
                                            });
                                          },
                                        ),
                                      ),
                                    ],),
                                ),
                                Spacer(),
                                Container( width: Get.width * 0.4, height: Get.height * 0.5,
                                  child: ListView.builder(
                                      itemCount: _answerList.length,
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(),
                                      itemBuilder: (c, idx) {
                                        return Column(
                                          children: [
                                            args?.state=='임시' ? component(idx, args!.edit, as,'${args.state}','${args.teacher}','${args.docId}',args.image) :
                                            component(idx,'true', as,'${args?.state}','${args?.teacher}','${args?.docId}',args?.image),
                                            SizedBox(height: 40,),
                                          ],
                                        );
                                      }),
                                ),
                              ],),
                            const SizedBox(
                              height: 30,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Footer()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> _uploadFile(String teacher, String docid) async {
  //   final file = File(pickedFile!.path!);
  //   final ref = FirebaseStorage.instance
  //       .ref()
  //       .child('12345')
  //       .child('${teacher}')
  //       .child('${docid}.pdf');
  //   uploadTask = ref.putFile(file);
  //   final snapshot = await uploadTask!.whenComplete(() => null);
  // }

  Widget component(int idx, String? edit, AnswerState as,String state,String teacher, String docId,List? image) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const ClampingScrollPhysics(),

      child: Container(
        width: Get.width,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('문항 ${idx + 1}.', style: f18w700,),
            SizedBox(height: 20,),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () {
                          firstTrue[idx] = !firstTrue[idx];
                          _testEssayCon[idx].text = '';
                          setState(() {});
                        },
                        child: SvgPicture.asset(firstTrue[idx]
                            ? 'assets/checkBox.svg'
                            : 'assets/notcheckBox.svg'),
                      ),
                      SizedBox(width: 10,),
                      Text(
                        '주관식 문제로 변경',
                        style: f18w700,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20,),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('문제 제목', style: f18w400,),
                      Text('${textLength[idx]}/ 80', style: f14w400greyA,)
                    ],
                  ),
                  const SizedBox(height: 10,),
                  TextFormField(
                    onChanged: (value) {setState(() {
                      textLength[idx] = value.length;
                      as.individualTitle[idx] = _testTiCon[idx].text;
                    });},
                    controller: _testTiCon[idx],
                    minLines: 1,
                    maxLines: 10,
                    maxLength: 80,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      counterText: '',
                      fillColor: Color(0xffEBEBEB),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8)),
                      hintText: '내용을 입력해주세요',
                      hintStyle: f16w400grey8,
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('내용', style: f18w400,),
                      Text('${textLength2[idx]}/ 80', style: f14w400greyA,)
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    onChanged: (value) {setState(() {
                      textLength2[idx] = value.length;
                      as.individualBody[idx] = _testBodyCon[idx].text;
                    });},
                    controller: _testBodyCon[idx],
                    maxLength: 80,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      counterText: '',
                      fillColor: Color(0xffEBEBEB),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8)),
                      hintText: '내용을 입력해주세요',
                      hintStyle: (kIsWeb && (Get.width * 0.2 <= 171))
                          ? f12w400grey8
                          : f16w400grey8,
                    ),
                  ),

                  const SizedBox(height: 20,),
                  Text('문제 파일', style: f18w400,),
                  const SizedBox(height: 10,),
                  Row(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
                        child: ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                                allowedExtensions: [
                                  // 'pdf',
                                  'png',
                                  'jpg',
                                  'jpeg',
                                  // 'svg'
                                ],
                                type: FileType.custom,
                              );

                              if (result == null) return;

                              as.hasFile.value = true;
                              PlatformFile? pickedFile = result.files.first;
                              pickedFiles[idx] = pickedFile.name;
                              if (edit == 'true') {
                                as.editIndividualImage.value[idx] = result.files.single.bytes;
                                as.pdfUploadName.value[idx] = pickedFile!.name;
                                as.individualFile.value[idx] = 'yes';
                                as.indEditList.value[idx] = 'edit';
                              } else {
                                as.individualFile.value[idx] = 'yes';
                                as.individualFilePath.value[idx] = result.files.single.bytes;
                                as.pdfUploadName[idx] = pickedFile!.name;
                              }
                              _editList[idx] = 'true';
                              setState(() {});
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              )),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.symmetric(
                                      vertical: 14, horizontal: 20)),
                              backgroundColor:
                              MaterialStateProperty.all<Color>(textFormColor),
                              splashFactory: NoSplash.splashFactory,
                              elevation: MaterialStateProperty.all<double>(0.0),
                            ),
                            child: Text('찾아보기', style: f16w700primary)),
                      ),
                      SizedBox(width: 26,),
                      pickedFiles[idx] == '' && state !='임시'? Container() :
                      Column(mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: (state =='임시'&& _editList[idx] == '') || edit =='true'
                                ? ExtendedImage.network(
                              'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/teacher%2F${teacher}%2F${docId}%2F${image?[idx]}?alt=media',
                              fit: BoxFit.fill,
                              // mode: ExtendedImageMode.gesture,
                              width:300,
                              height: as.pdfUploadName[idx]==''?0:300,
                              cache: true,
                              enableLoadState: false,
                            )
                                :_editList[idx] == 'true'
                                ? Image.memory(
                                edit == 'true' ? as.editIndividualImage[idx] :
                            as.individualFilePath[idx],
                                width: 300, height: 300, fit: BoxFit.fill) : Container(),
                          ),
                          SizedBox(height: 10,),
                          edit == true ? Container(width: Get.width * 0.1,
                              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: const Color(0xffDADADA),
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${pickedFiles[idx]}',
                                style: f16w400grey8,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              )) :
                          _editList[idx]== ''&& pickedFiles[idx]==''&& as.pdfUploadName[idx]==''?Container():
                          Container(width: Get.width * 0.1,
                            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                            decoration: BoxDecoration(
                              border: Border.all(color: const Color(0xffDADADA),),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    '${as.pdfUploadName[idx]}',
                                    style: f16w400grey8,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // pickedFile = null;
                                    pickedFiles[idx] = '';
                                    as.individualFile[idx] = '';
                                    as.pdfUploadName[idx] = '';

                                    if (edit == 'true') {
                                      as.editIndividualImage[idx] = 'no';
                                    } else {
                                      as.individualFilePath[idx] = '';
                                    }
                                    _editList[idx] = '';
                                    setState(() {});
                                  },
                                  child: Icon(Icons.close, size: 20,),
                                ),
                              ],
                            ),
                          ),
                        ],)
                    ],
                  ),

                  const SizedBox(height: 20,),
                  Text('듣기 파일', style: f18w400,),
                  const SizedBox(height: 10,),
                  Row(crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
                        child: ElevatedButton(
                            onPressed: () async {
                              FilePickerResult? result =
                              await FilePicker.platform.pickFiles(
                                type: FileType.audio,
                              );
                              if (result == null) return;
                              // as.hasFile.value = true;
                              PlatformFile? pickedFile2 = result.files.first;
                              pickedFiles2[idx] = pickedFile2.name;
                              setState(() {});
                              // pickedFile2![idx] = result.files.first;
                              if (edit == 'true') {
                                as.editIndividualAudio.value[idx] = result.files.single.bytes;
                                as.indEditList2.value[idx] = 'edit';
                                as.pdfUploadName2.value[idx] = pickedFile2!.name;

                              } else {
                                as.individualFile2.value[idx] = 'yes';
                                as.individualFilePath2.value[idx] = result.files.single.bytes;
                                as.pdfUploadName2[idx] = pickedFile2!.name;

                              }
                              // }
                              setState(() {});
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              )),
                              padding: MaterialStateProperty.all<EdgeInsets>(
                                  EdgeInsets.symmetric(
                                      vertical: 10, horizontal: 20)),
                              backgroundColor:
                              MaterialStateProperty.all<Color>(textFormColor),
                              splashFactory: NoSplash.splashFactory,
                              elevation: MaterialStateProperty.all<double>(0.0),
                            ),
                            child: Text('찾아보기',
                                style: (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? f12w700primary
                                    : f16w700primary)),
                      ),
                      SizedBox(width: 26,),
                      pickedFiles2[idx] != '' ?
                      Container(width: Get.width * 0.1,
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffDADADA),),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Flexible(
                              child: Text(
                                '${as.pdfUploadName2[idx]}',
                                style: f16w400grey8,
                                textAlign: TextAlign.center,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                pickedFiles2[idx] = '';
                                as.pdfUploadName2[idx] = '';
                                if (edit == 'true') {
                                  as.editIndividualAudio[idx] = 'no';
                                }
                                as.individualFile2[idx] = '';
                                as.individualFilePath2[idx] = '';
                                setState(() {});
                              },
                              child: Icon(Icons.close, size: 20,),
                            ),
                          ],
                        ),
                      ) : edit == true ? Container(width: Get.width * 0.1,
                          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0xffDADADA),
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${as.pdfUploadName2[idx]}',
                            style: f16w400grey8,
                            textAlign: TextAlign.center,
                          )) : Container(),
                    ],
                  ),

                  const SizedBox(height: 20,),
                  Text('답안', style: f18w400,),
                  const SizedBox(
                    height: 10,
                  ),
                  firstTrue[idx]
                      ? TextFormField(
                    onChanged: (v){
                      as.tmpidx[idx] = v.toString();
                    },
                    controller: _testEssayCon[idx],
                    maxLines: null,
                    enabled: !secondTrue[idx],
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      fillColor: Color(0xffEBEBEB),
                      contentPadding: EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.circular(8)),
                      hintText:
                      secondTrue[idx] ? '서술형은 입력할 수 없습니다' : '답을 입력해주세요',
                      hintStyle: (kIsWeb && (Get.width * 0.2 <= 171))
                          ? f12w400grey8
                          : f16w400grey8,
                    ),
                  )
                      : Container(
                      height: 60,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        children: List.generate(
                            number.length,
                                (i) => Column(
                              children: [
                                Row(
                                  children: [
                                    TextButton(
                                        onPressed: () {
                                          as.choiceList[idx] = '${i + 1}';
                                          _answer[idx] = '${i + 1}';
                                          // as.answer[idx] = '${i + 1}';
                                          setState(() {});
                                        },
                                        style: TextButton.styleFrom(
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                              BorderRadius.circular(
                                                  20)),
                                          side: BorderSide(
                                              width: 1,
                                              color: Colors.grey),
                                          minimumSize: Size(52, 52),
                                          foregroundColor: Colors.black,
                                          backgroundColor: _answer[idx] == number[i] ? nowColor : Colors.white,
                                          padding: EdgeInsets.only(
                                              right: 12, left: 12),
                                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        ),
                                        child: Text('${i + 1}',
                                            style: _answer[idx] == number[i] ? f16Whitew700 : f16w700)),
                                    SizedBox(
                                      width: 10,
                                    ),
                                  ],
                                ),
                              ],
                            )),
                      )),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Uint8List convertStringToUint8List(String str) {
    List<int> list = utf8.encode(str);
    Uint8List bytes = Uint8List.fromList(list);

    final List<int> codeUnits = str.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);
    return bytes;
  }

  Future<void> _update(String docId) async {
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());
    final args = ModalRoute.of(context)!.settings.arguments as PdfIndMainScreenTablet?;
    DocumentReference ref =
    FirebaseFirestore.instance.collection('answer').doc(docId);
    ref.update({
      'password': _testPwController.text,
      'pdfCategory': _testNameController.text,
      'answer': _answer,
      'individualBody': as.individualBody,
      'individualTitle': as.individualTitle,
      'pdfUploadName' : as.pdfUploadName,
      'pdfUploadName2' : as.pdfUploadName2,
      'temp1':as.tmpidx
    });
    var contain =  as.indEditList.where((element) => element == "edit");
    var contain2 = as.indEditList2.where((element) => element=='edit');

    if(!contain.isEmpty){

      await ref.update({
        "images": [],
        'individualFile' : as.individualFile,
      });
      setState(() {
        _imageLoading = true;
      });
      _imageLoading == true
          ? showDialog(
        barrierDismissible: false,
        builder: (ctx) {
          return Center(child: LoadingBodyScreen());
        },
        context: context,
      )
          : Container();
      for(int i = 0; i < as.individualFile.length; i++){

        if(as.indEditList[i] == 'edit'){
          var time = DateTime.now();
          final firebaseStorageRef = FirebaseStorage.instance
              .ref()
              .child('teacher')
              .child('${us.userList[0].id}')
              .child('$docId')
              .child('${time}');
          final uploadTask = firebaseStorageRef.putData(as.editIndividualImage[i],
              SettableMetadata(contentType: 'image/png'));
          await uploadTask.then((p0) => null);
          await ref.update({
            "images": FieldValue.arrayUnion(['${time}']),
          });
        }else{
          if(as.editIndividualImage[i].contains('no')){
            await ref.update({
              "images": FieldValue.arrayUnion(['no$i']),
            });
          }
          else {
            await ref.update({
              "images": FieldValue.arrayUnion(['${as.editIndividualImage[i]}']),
            });
          }
        }
      }
    }else{
      await ref.update({
        "images": as.editIndividualImage,
        'individualFile' :  as.individualFile,
      });
    }
    if(!contain2.isEmpty){
      await ref.update({
        "audio": [],
      });
      setState(() {
        _imageLoading = true;
      });
      _imageLoading == true
          ? showDialog(
        barrierDismissible: false,
        builder: (ctx) {
          return Center(child: LoadingBodyScreen());
        },
        context: context,
      )
          : Container();
      DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('answer').doc(docId);
      for (int i = 0; i < as.individualFile2.length; i++) {
        if (as.indEditList2[i] == 'edit') {

          var time = DateTime.now();
          final firebaseStorageRef = FirebaseStorage.instance
              .ref()
              .child('teacher')
              .child('audio')
              .child('${args?.teacher}')
              .child('${args!.docId}')
              .child('${time}');
          final uploadTask = firebaseStorageRef.putData(as.editIndividualAudio[i],
              SettableMetadata(contentType: 'audio/mpeg'));
          await uploadTask.then((p0) => null);

          await userDocRef.update({
            "audio": FieldValue.arrayUnion(['${time}'])
          });

        } else {
          if(as.editIndividualAudio[i].contains('no')){
            await userDocRef.update({
              "audio": FieldValue.arrayUnion(['no$i'])
            });
          }
          else {
            await userDocRef.update({
              "audio": FieldValue.arrayUnion(['${as.editIndividualAudio[i]}'])
            });
          }
        }
      }
    }else{

      await ref.update({
        "audio": as.editIndividualAudio,
      });
    }
  }

  Future<void> firebaseAnswerUploadIndividual(
      UploadTask? uploadTask, bool image,bool scoreVisual) async {
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());

    CollectionReference ref = FirebaseFirestore.instance.collection('answer');
    Answer ass = Answer(
        isIndividual: 'true',
        audio: [],
        individualBody: as.individualBody,
        individualTitle: as.individualTitle,
        nickName: us.userList[0].nickName,
        individualFile: as.individualFile,
        images: [],
        student: [],
        createDate: '${DateTime.now()}',
        answer: as.answer.toList(),
        answerCount: '',
        docId: '',
        group: '',
        scoreVisual:'${scoreVisual}',
        password: '${as.password}',
        pdfCategory: '${as.pdfCategory}',
        pdfName: '${as.pdfName}',
        pdfUploadName: as.pdfUploadName,
        pdfUploadName2: as.pdfUploadName2,
        state: '완료',
        teacher: '${as.teacher}',
        temp1: as.tmpidx,
        temp2: _testCountController2.text);
    ref.add(ass.toMap()).then((doc) async {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('answer').doc(doc.id);
      as.docId.value = doc.id;
      // as.individualFile.removeWhere((item) => item == '');
      // as.individualFilePath.removeWhere((item) => item == '');
      await userDocRef.update({'docId': '${doc.id}'});

      setState(() {
        _imageLoading = true;
      });

      _imageLoading == true
          ? showDialog(
              barrierDismissible: false,
              builder: (ctx) {
                return Center(child: LoadingBodyScreen());
              },
              context: context,
            )
          : Container();
      if (as.individualFile2.contains('yes')) {
        await _uploadFile2(doc.id, '${us.userList[0].id}');
      }

      if (image == false) {
        await _uploadFile(doc.id, '${us.userList[0].id}');
        // showConfirmTapDialog(context, '업로드를 완료했습니다', () {
        //   Get.offAllNamed(MainScreen.id);
        // });
      }

      setState(() {
        _imageLoading = false;
        Navigator.pop(context);
      });

      showConfirmTapDialog(context, '업로드를 완료했습니다', () {
        Get.offAllNamed(MainScreen.id);
      });
    });
  }

  Future<void> firebaseAnswerUploadIndividualSave(
      UploadTask? uploadTask, bool image,bool scoreVisual) async {
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());

    CollectionReference ref = FirebaseFirestore.instance.collection('answer');
    Answer ass = Answer(
        isIndividual: 'true',
        individualBody: as.individualBody,
        individualTitle: as.individualTitle,
        individualFile: as.individualFile,
        images: [],
        student : [],
        nickName:us.userList[0].nickName,
        createDate: '${DateTime.now()}',
        answer: as.answer.toList(),
        answerCount: '',
        docId: '',
        group: '',
        scoreVisual:'${scoreVisual}',
        password: '${as.password}',
        pdfCategory: '${as.pdfCategory}',
        pdfName: '${as.pdfName}',
        pdfUploadName: as.pdfUploadName,
        pdfUploadName2: as.pdfUploadName2,
        state: '임시',
        teacher: '${as.teacher}',
        temp1: as.tmpidx,
        temp2: _testCountController2.text,
        audio :[]);
    ref.add(ass.toMap()).then((doc) async {
      DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('answer').doc(doc.id);
      as.docId.value = doc.id;
      // as.individualFile.removeWhere((item) => item == '');
      // as.individualFilePath.removeWhere((item) => item == '');
      await userDocRef.update({'docId': '${doc.id}'});
      await _uploadFile2(doc.id, '${us.userList[0].id}');
      // }

      // if (image == false) {
      await _uploadFile(doc.id, '${us.userList[0].id}');
      showConfirmTapDialog(context, '업로드를 완료했습니다', () {
        Get.offAllNamed(MainScreen.id);
      });
      // } else {
      //   showConfirmTapDialog(context, '업로드를 완료했습니다', () {
      //     Get.offAll(() => BottomNavigator());
      //   });
      // }
    });
  }

  Future _uploadFile(String docId, String phoneNumber) async {
    final as = Get.put(AnswerState());
    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('answer').doc(docId);

    for (int i = 0; i < as.individualFile.length; i++) {
      if (as.individualFile[i] != '') {

        var time = DateTime.now();
        final firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child('teacher')
            .child('$phoneNumber')
            .child('$docId')
            .child('${time}');
        final uploadTask = firebaseStorageRef.putData(as.individualFilePath[i],
            SettableMetadata(contentType: 'image/png'));
        // final uploadTask =     firebaseStorageRef.putData(
        //   await _imageFileList![i].readAsBytes(),
        //   SettableMetadata(contentType: 'image/jpeg'),
        // );
        await uploadTask.then((p0) => null);

        await userDocRef.update({
          "images": FieldValue.arrayUnion(['${time}'])
        });

      } else {

        await userDocRef.update({
          "images": FieldValue.arrayUnion(['no$i'])
        });
      }
    }

    // setState(() {
    //   _imageLoading = false;
    //   Navigator.pop(context);
    // });
  }

  Future _uploadFile2(String docId, String phoneNumber) async {
    final as = Get.put(AnswerState());
    _imageLoading == true
        ? showDialog(
            barrierDismissible: false,
            builder: (ctx) {
              return Center(child: LoadingBodyScreen());
            },
            context: context,
          )
        : Container();

    DocumentReference userDocRef =
        FirebaseFirestore.instance.collection('answer').doc(docId);

    for (int i = 0; i < as.individualFile2.length; i++) {
      if (as.individualFile2[i] != '') {

        var time = DateTime.now();
        final firebaseStorageRef = FirebaseStorage.instance
            .ref()
            .child('teacher')
            .child('audio')
            .child('$phoneNumber')
            .child('$docId')
            .child('${time}');
        final uploadTask = firebaseStorageRef.putData(as.individualFilePath2[i],
            SettableMetadata(contentType: 'audio/mpeg'));
        await uploadTask.then((p0) => null);

        await userDocRef.update({
          "audio": FieldValue.arrayUnion(['${time}'])
        });

      } else {

        await userDocRef.update({
          "audio": FieldValue.arrayUnion(['no$i'])
        });
      }
    }
  }

  Future<void> _updateTimer(String docId) async {
    final as = Get.put(AnswerState());
    DocumentReference ref =
        FirebaseFirestore.instance.collection('answer').doc(docId);
    ref.update({
      'temp2': _testCountController2.text,
    });
  }

  Future<bool> _useBackKey(BuildContext context) async {
    return await showComponentDialog(context, '작성을 취소하시겠습니까?', () {
     Get.back();
     Get.back();
    });
  }
  // 임시저장일 때 저장버튼 클릭시 상태 임시 -> 대기로 변하는 함수
  Future<void> updateState(String docId) async{
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());
    DocumentReference ref = FirebaseFirestore.instance.collection('answer').doc(docId);
    ref.update({
      'password': _testPwController.text,
      'pdfCategory': _testNameController.text,
      'answer': as.answer.toList(),
      'individualBody': as.individualBody,
      'individualTitle': as.individualTitle,
      'pdfUploadName' : as.pdfUploadName,
      'pdfUploadName2' : as.pdfUploadName2,
      'temp1':as.tmpidx,
      'state' : '완료'
    });
    var contain =  as.indEditList.where((element) => element == "edit");
    var contain2 = as.indEditList2.where((element) => element=='edit');
    if(!contain.isEmpty){
      await ref.update({
        "images": [],
        'individualFile' : as.individualFile,
      });
      setState(() {
        _imageLoading = true;
      });
      _imageLoading == true
          ? showDialog(
        barrierDismissible: false,
        builder: (ctx) {
          return Center(child: LoadingBodyScreen());
        },
        context: context,
      )
          : Container();
      for(int i = 0; i < as.individualFile.length; i++){
        if(as.indEditList[i] == 'edit'){
          var time = DateTime.now();
          final firebaseStorageRef = FirebaseStorage.instance
              .ref()
              .child('teacher')
              .child('${us.userList[0].id}')
              .child('$docId')
              .child('${time}');
          final uploadTask = firebaseStorageRef.putFile(
              File(as.editIndividualImage[i]),
              SettableMetadata(contentType: 'image/png'));
          await uploadTask.then((p0) => null);
          await ref.update({
            "images": FieldValue.arrayUnion(['${time}']),
          });
        }else{
          if(as.editIndividualImage[i].contains('no')){
            await ref.update({
              "images": FieldValue.arrayUnion(['no$i']),
            });
          }
          else {
            await ref.update({
              "images": FieldValue.arrayUnion(['${as.editIndividualImage[i]}']),
            });
          }
        }
      }
    }else{
      await ref.update({
        "images": as.editIndividualImage,
        'individualFile' :  as.individualFile,
      });
    }
    if(!contain2.isEmpty){
      await ref.update({
        "audio": [],
      });
      setState(() {
        _imageLoading = true;
      });
      _imageLoading == true
          ? showDialog(
        barrierDismissible: false,
        builder: (ctx) {
          return Center(child: LoadingBodyScreen());
        },
        context: context,
      )
          : Container();
      DocumentReference userDocRef =
      FirebaseFirestore.instance.collection('answer').doc(docId);
      for (int i = 0; i < as.individualFile2.length; i++) {
        if (as.indEditList2[i] == 'edit') {
          var time = DateTime.now();
          final firebaseStorageRef = FirebaseStorage.instance
              .ref()
              .child('teacher')
              .child('audio')
              .child('${widget.teacher}')
              .child('${widget.docId}')
              .child('${time}');
          final uploadTask = firebaseStorageRef.putFile(File('${as.editIndividualAudio[i]}'),
              SettableMetadata(contentType: 'audio/mpeg'));
          await uploadTask.then((p0) => null);
          await userDocRef.update({
            "audio": FieldValue.arrayUnion(['${time}'])
          });
        } else {
          if(as.editIndividualAudio[i].contains('no')){
            await userDocRef.update({
              "audio": FieldValue.arrayUnion(['no$i'])
            });
          }
          else {
            await userDocRef.update({
              "audio": FieldValue.arrayUnion(['${as.editIndividualAudio[i]}'])
            });
          }
        }
      }
    }else{
      await ref.update({
        "audio": as.editIndividualAudio,
      });
    }
  }

}
