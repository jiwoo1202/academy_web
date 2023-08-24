import 'dart:io';
import 'dart:typed_data';

import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/util/padding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../components/footer/footer.dart';
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

class PdfIndMainScreenApp extends StatefulWidget {
  static final String id = '/pdf_ind_main_app';
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
  const PdfIndMainScreenApp(
      {Key? key,
      this.edit: '',
      this.docId: '',
      this.answer,
      this.body,
      this.title,
      this.image,
      this.password: '',
      this.category: '',
      this.file,
      this.countdown, this.teacher, this.audio, this.pdfUploadName, this.pdfUploadName2, this.state, this.essayAnswer})
      : super(key: key);

  @override
  State<PdfIndMainScreenApp> createState() => _PdfIndMainScreenAppState();
}

class _PdfIndMainScreenAppState extends State<PdfIndMainScreenApp> {
  PlatformFile? pickedFile;
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
  bool scoreVisual = false;
  @override
  void initState() {
    Future.delayed(Duration.zero,(){
      final args = ModalRoute.of(context)!.settings.arguments as PdfIndMainScreenApp?;
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

      setState(() {});
      if (args?.edit == 'true') {
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

          args.file![i] == 'edit' ||  args.file![i] == 'yes' ? as.individualFile.value.add('yes') : as.individualFile.value.add('');
          args.file![i] == 'edit' ||  args.file![i] == 'yes' ? as.individualFilePath.value.add('yes') : as.individualFilePath.value.add('');
          args.file![i] == 'edit' ||  args.file![i] == 'yes' ? as.indEditList.value.add('yes') : as.indEditList.value.add('');
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
          if (isNumeric(args.answer![i]) && args.answer![i].length == 1) {
            as.choiceList.value[i] = args.answer![i];
          } else {
            as.essayList.value[i] = args.essayAnswer![i];
          }
        }

        // as.essayList.value = widget.answer!;

        // for(int i = 0; i < widget.answer!.length; i++){
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
    final args = ModalRoute.of(context)!.settings.arguments as PdfIndMainScreenApp?;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: WillPopScope(
        onWillPop: () {
          return _useBackKey(context);
        },
        child: Scaffold(
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
            actions: [
              args?.state=='임시'||args?.edit!='true'?
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
                    padding: const EdgeInsets.only(right: 28),
                    child: const Center(
                        child: Text(
                          '임시저장',
                          style: f16Whitew700,
                        )),
                  )
              ):Container(),
              // args?.state!='임시'?
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
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
                    // as.pdfUploadName.value = '${pickedFile?.name}';
                    // as.path.value = pickedFile!.path!;
                    // await _uploadFile('12345', as.docId.value);
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 28),
                    child: const Center(
                        child: Text(
                      '저장',
                      style: f16Whitew700,
                    )),
                  )),
                  // :Container(),
              GestureDetector(
                onTap: () {
                  showComponentDialog(context, '로그아웃을 하시겠습니까?', () {
                    Get.offAllNamed(LoginMainScreen.id);
                    RefreshManager.addToCookie('id', '');
                    RefreshManager.addToCookie('pw', '');
                    us.isLogin.value = '';
                  });
                },
                child: Center(
                    child: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Image.asset(
                    'assets/icon/logout.png',
                    color: Colors.white,
                    width: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                    height: kIsWeb && (Get.width * 0.2 <= 171) ? 20 : 24,
                  ),
                )),
              ),
            ],
          ),
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Container(
              width: Get.width,
              padding: GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                  ? EdgeInsets.zero
                  : EdgeInsets.symmetric(horizontal: Get.width * 0.24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 20,
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '시험명',
                        style: f18w400,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: TextFormFields(
                      controller: _testNameController,
                      hintText: '시험 명을 입력해주세요',
                      surffixIcon: '0',
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '문항수',
                        style: f18w400,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              color: testCountColor,
                            ),
                            width: Get.width * 0.3,
                            height:
                                (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
                            child: TextFormField(
                              controller: _testCountController,
                              enabled: args?.edit == true ? false : true,
                              style: (kIsWeb && (Get.width * 0.2 <= 171))
                                  ? f12w400
                                  : f16w400,
                              textAlign: TextAlign.center,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                isDense: (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? true
                                    : false,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                prefixIcon: InkWell(
                                  onTap: () {
                                    if(args?.edit=='true'&& args?.state!='임시'){
                                      return;
                                    }
                                    else {
                                      if (args?.state == '임시') {
                                        _answerList.removeLast();
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
                                        setState(() {
                                          // final x = _testCountController.text.obs;

                                          ///_testCountController -
                                          _testCountController.text =
                                              (_testCountController.text != '0'
                                                  ? int.parse(
                                                  _testCountController
                                                      .text) -
                                                  1
                                                  : 0)
                                                  .toString();
                                        });
                                      }
                                      else {
                                        _answerList.removeLast();
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
                                        setState(() {
                                          // final x = _testCountController.text.obs;

                                          ///_testCountController -
                                          _testCountController.text =
                                              (_testCountController.text != '0'
                                                  ? int.parse(
                                                  _testCountController
                                                      .text) -
                                                  1
                                                  : 0)
                                                  .toString();
                                        });
                                      }
                                    }
                                  },
                                  child: Icon(
                                    Icons.exposure_minus_1,
                                    color: Colors.black,
                                  ),
                                ),
                                suffixIcon: InkWell(
                                  onTap: () {
                                    if(args?.edit=='true'&& args?.state!='임시'){
                                      return;
                                    }
                                    else {
                                      if (args?.state == '임시') {
                                        _answerList.add('1');
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
                                        setState(() {
                                          ///_testCountController +
                                          _testCountController.text =
                                              (int.parse(
                                                  _testCountController.text) +
                                                  1)
                                                  .toString();
                                        });
                                      }
                                      else {
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
                                        setState(() {
                                          ///_testCountController +
                                          _testCountController.text =
                                              (int.parse(
                                                  _testCountController.text) +
                                                  1)
                                                  .toString();
                                        });
                                      }
                                    }
                                  },
                                  child: Icon(
                                    Icons.plus_one,
                                    color: Colors.black,
                                  ),
                                  // child: SvgPicture.asset(
                                  //   'assets/icon/plus.svg',
                                  //   height: kIsWeb && (Get.width * 0.2 <= 171)
                                  //       ? 20
                                  //       : 24,
                                  //   width: kIsWeb && (Get.width * 0.2 <= 171)
                                  //       ? 20
                                  //       : 24,
                                  //   color: teacherColor,
                                  // ),
                                ),
                                hintText: '20',
                                hintStyle: f16w400grey8,
                              ),
                            )),
                        SizedBox(
                          width: 4,
                        ),
                        Container(
                          height:
                              (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
                          child: ElevatedButton(
                              onPressed:
                              args?.edit=='true'&& args?.state!='임시'?
                                  null
                                  : args?.edit == true
                                  ? null
                                  : () async {
                                try {
                                  if (int.tryParse(_testCountController.text) !=
                                      null) {
                                    if (int.parse(_testCountController.text) <
                                        _answerList.length) {
                                      _answerList.removeRange(
                                          int.parse(_testCountController.text),
                                          _answerList.length);
                                      as.essayList.value.removeRange(
                                          int.parse(_testCountController.text),
                                          _answerList.length);
                                      as.tmpidx.value.removeRange(int.parse(_testCountController.text), _answerList.length);
                                      as.individualTitle.value.removeRange(
                                          int.parse(_testCountController.text),
                                          _answerList.length);
                                      as.individualBody.value.removeRange(
                                          int.parse(_testCountController.text),
                                          _answerList.length);
                                      as.individualFile.value.removeRange(
                                          int.parse(_testCountController.text),
                                          _answerList.length);
                                      as.individualFilePath.value.removeRange(
                                          int.parse(_testCountController.text),
                                          _answerList.length);
                                      as.choiceList.value.removeRange(
                                          int.parse(_testCountController.text),
                                          _answerList.length);
                                      as.individualFile2.value.removeRange(
                                          int.parse(_testCountController.text),
                                          _answerList.length);
                                      as.individualFilePath2.value.removeRange(
                                          int.parse(_testCountController.text),
                                          _answerList.length);
                                      as.pdfUploadName2.value.removeRange(
                                          int.parse(_testCountController.text),
                                          _answerList.length);
                                      as.pdfUploadName.value.removeRange(
                                          int.parse(_testCountController.text),
                                          _answerList.length);
                                    }
                                    if (int.parse(_testCountController.text) >
                                        _answerList.length) {
                                      int diff =
                                          int.parse(_testCountController.text) -
                                              _answerList.length;
                                      for (int i = 0; i < diff; i++) {
                                        _answerList.add('1');
                                        as.essayList.value.add('');
                                        as.individualTitle.value.add('');
                                        as.tmpidx.value.add('');
                                        as.individualBody.value.add('');

                                        as.individualFile.value.add('');
                                        as.individualFilePath.value.add('');

                                        as.individualFile2.value.add('');
                                        as.individualFilePath2.value.add('');
                                        as.pdfUploadName2.value.add('');
                                        as.pdfUploadName.value.add('');
                                        as.choiceList.value.add('');
                                        if(args?.edit == 'true'){
                                          as.indEditList.value.add('');
                                          as.indEditList2.value.add('');
                                        }
                                      }
                                    }
                                    setState(() {});
                                  }
                                } catch (e) {
                                  print(e);
                                }
                                    },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                )),
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.symmetric(
                                        vertical: 14, horizontal: 20)),
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        textFormColor),
                                splashFactory: NoSplash.splashFactory,
                                elevation:
                                    MaterialStateProperty.all<double>(0.0),
                              ),
                              child: Text('확인',
                                  style: (kIsWeb && (Get.width * 0.2 <= 171))
                                      ? f12w700primary
                                      : f16w700primary)),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '시간 설정 (초단위)',
                        style: f18w400,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                          color: testCountColor,
                        ),
                        width: Get.width * 0.3,
                        height: (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
                        child: TextFormField(
                          maxLength: 4,
                          controller: _testCountController2,
                          enabled: true,
                          style: (kIsWeb && (Get.width * 0.2 <= 171))
                              ? f12w400
                              : f16w400,
                          textAlign: TextAlign.center,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            counterText: '',
                            isDense: (kIsWeb && (Get.width * 0.2 <= 171))
                                ? true
                                : false,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            prefixIcon: InkWell(
                              onTap: () {
                                if(args?.edit=='true'&& args?.state!='임시'){
                                  return;
                                }
                                else {
                                  setState(() {
                                    // final x = _testCountController.text.obs;
                                    ///_testCountController -
                                    _testCountController2
                                        .text =
                                        (_testCountController2.text != '0'
                                            ? int.parse(
                                            _testCountController2.text) -
                                            1
                                            : 0)
                                            .toString();
                                  });
                                }
                              },
                              child: Icon(
                                Icons.exposure_minus_1,
                                color: Colors.black,
                              ),
                            ),
                            suffixIcon: InkWell(
                              onTap: () {
                                if(args?.edit=='true'&& args?.state!='임시'){
                                  return;
                                }
                                else {
                                  setState(() {
                                    ///_testCountController +
                                    _testCountController2.text =
                                        (int.parse(_testCountController2.text) +
                                            1)
                                            .toString();
                                  });
                                }
                              },
                              child: Icon(
                                Icons.plus_one,
                                color: Colors.black,
                              ),
                            ),
                            hintText: '100',
                            hintStyle: (kIsWeb && (Get.width * 0.2 <= 171))
                                ? f12w400grey8
                                : f16w400grey8,
                          ),
                        )),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '비밀번호',
                        style: f18w400,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
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
                  const SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: ph24,
                    child: ListView.builder(
                        itemCount: _answerList.length,
                        shrinkWrap: true,
                        physics: const ClampingScrollPhysics(),
                        itemBuilder: (c, idx) {
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if(args?.edit=='true'&& args?.state!='임시'){
                                return;
                              }else{
                                    if(args?.state=='임시') {
                                      Get.toNamed(PdfUploadIndividualScreen.id,
                                          arguments: PdfUploadIndividualScreen(
                                            idx: idx,
                                            edit: args!.edit,))!
                                          .then((value) {
                                        setState(() {});
                                      });
                                    }
                                    else {
                                      Get.toNamed(PdfUploadIndividualScreen.id,
                                          arguments: PdfUploadIndividualScreen(
                                              idx: idx,
                                          ))!.then((value) {
                                            setState(() {
                                            });
                                      });
                                    }
                                  }},
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '문항 ${idx + 1}.',
                                  style: (kIsWeb && (Get.width * 0.2 <= 171))
                                      ? f12w400
                                      : f18w700,
                                ),
                                const SizedBox(
                                  height: 20,
                                ),
                                Text(
                                  as.individualFile[idx] != ''
                                      ? '제목(파일첨부)'
                                      : '제목',
                                  style: (kIsWeb && (Get.width * 0.2 <= 171))
                                      ? f12w400
                                      : f18w400,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Container(
                                  width: Get.width,
                                  padding: ph24v12,
                                  decoration: BoxDecoration(
                                    color: Color(0xffEBEBEB),
                                    borderRadius: BorderRadius.circular(7),
                                  ),
                                  child: Text(
                                    as.individualTitle[idx] == ''
                                        ? '문제를 입력해주세요'
                                            ''
                                        : '${as.individualTitle[idx]}',
                                    style: (kIsWeb && (Get.width * 0.2 <= 171))
                                        ? f12w400
                                        : f16w400,
                                  ),
                                ),
                                const SizedBox(
                                  height: 16,
                                ),
                                Row(
                                  children: [
                                    Text(
                                      '답안 :',
                                      style:
                                          (kIsWeb && (Get.width * 0.2 <= 171))
                                              ? f12w400
                                              : f18w400,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      as.essayList[idx] != ''
                                          ? '${as.essayList[idx]}'
                                          : as.choiceList[idx] == ''
                                              ? '답을 입력해주세요'
                                              : '${as.choiceList[idx]}',
                                      style:
                                          (kIsWeb && (Get.width * 0.2 <= 171))
                                              ? f12w700
                                              : f18w700,
                                    ),
                                    // Obx(() =>Text('${as.essayList[idx]}',style: f18w700,)),
                                    // as.essayList[idx] == 'true' ? Text('주관식',style: f18w700,):  Text(
                                    //   '1',
                                    //   style: f18w700,
                                    // ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
                                Divider(),
                                const SizedBox(
                                  height: 10,
                                ),
                              ],
                            ),
                          );
                        }),
                  ),
                  Padding(padding: ph24, child: Footer()),
                  SizedBox(
                    height: 40,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }


  Future<void> _update(String docId) async {
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());
    final args = ModalRoute.of(context)!.settings.arguments as PdfIndMainScreenApp?;
    DocumentReference ref =
    FirebaseFirestore.instance.collection('answer').doc(docId);
    ref.update({
      'password': _testPwController.text,
      'pdfCategory': _testNameController.text,
      'answer': as.answer.toList(),
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
      Get.offAllNamed(MainScreen.id);
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
      'state' : '대기'
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
