import 'dart:io';
import 'dart:typed_data';

import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/components/footer/footer.dart';
import 'package:academy/screen/main/main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../components/switch/switch_button.dart';
import '../../../../components/tile/textform_field.dart';
import '../../../../firebase/firebase_answer.dart';
import '../../../../provider/answer_state.dart';
import '../../../../provider/user_state.dart';
import '../../../../util/colors.dart';

import '../../../../util/font/font.dart';
import '../../../../util/loading.dart';
import '../../../../util/refresh_manager.dart';
import '../../../login/login_main_screen.dart';

class PdfUploadScreenApp extends StatefulWidget {
  static final String id = '/pdf_upload';

  final String? category;
  final List? pdfUploadName;
  final String? password;
  final String? docId;
  final bool? edit;
  final String? teacherName;
  final String? audio;
  final String? countdown;
  final List? answerlength;

  const PdfUploadScreenApp(
      {Key? key,
      this.category,
      this.pdfUploadName,
      this.password,
      this.edit,
      this.answerlength,
      this.docId,
      this.teacherName, this.audio, this.countdown})
      : super(key: key);

  @override
  State<PdfUploadScreenApp> createState() => _PdfUploadScreenAppState();
}

class _PdfUploadScreenAppState extends State<PdfUploadScreenApp> {
  PlatformFile? pickedFile;
  PlatformFile? pickedFile2;
  UploadTask? uploadTask;
  String isfilePath = '';
  String _hasAudio = '';
  TextEditingController _testNameController = TextEditingController();
  TextEditingController _testPwController = TextEditingController();
  TextEditingController _testCountController = TextEditingController();
  TextEditingController _testCountController2 = TextEditingController();

  final _obscureText = false.obs;
  List _answerList = [];
  bool _imageLoading = false;
  late Uint8List uploadfile;
  late Uint8List? uploadfile2;
  bool scoreVisual = false;
  String? _dropdown = '전체';
  List<String> _dropdownList= ['전체','국어','수학','영어','과학','사회','한국사'];
  @override
  void initState() {
    Future.delayed(Duration.zero,(){
      final args = ModalRoute.of(context)!.settings.arguments as PdfUploadScreenApp?;
      final as = Get.put(AnswerState());
      as.pdfUploadName.value = []; // 문제 제목
      as.pdfUploadName2.value = []; // 듣기 제목

      for (int i = 0; i < 20; i++) {
        _answerList.add('1');
        as.pdfUploadName.add('');
        as.pdfUploadName2.add('');
      }
      _testCountController.text = '20';
      _testCountController2.text = '100';

      if (args?.edit == true) {
        _answerList.clear();

        _testNameController.text = args!.category!;
        _testPwController.text = args.password!;
        // as.pdfUploadName.value = args.pdfUploadName![0];
        _testCountController.text = '${args.answerlength?.length}';
        _testCountController2.text = args.countdown!;
        _hasAudio = '${args.audio}';

        as.essayList1.value =
            List.generate(args.answerlength!.length, (index) => '');
        as.choiceList1.value =
            List.generate(args.answerlength!.length, (index) => '');

        for (int i = 0; i < args.answerlength!.length; i++) {
          _answerList.add(args.answerlength![i]);

        }
        // a = args.path!;
        isfilePath = '1';
      }
      setState(() {
      });
    });

    super.initState();
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
    final args = ModalRoute.of(context)!.settings.arguments as PdfUploadScreenApp?;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
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
            //     Icons.arrow_back_ios_new,
            //     color: Color(0xff6f7072),
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
                kIsWeb && (Get.width * 0.2 <= 171) ? Container() : Text('문제추가')
              ],
            ),
            actions: [
              GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    // print('asd: ${pickedFile} , ${pickedFile?.name}');

                    as.answer.clear();
                    for (int i = 0; i < _answerList.length; i++) {
                      as.answer.add(_answerList[i]);
                    }
                    as.group.value = '';
                    as.password.value = _testPwController.text;
                    as.pdfCategory.value = _testNameController.text;
                    as.pdfName.value = '${DateTime.now()}';
                    as.pdfUploadName[0] = '${pickedFile?.name}';
                    as.pdfUploadName2[0] = '${pickedFile2?.name}';
                    as.teacher.value = '${us.userList[0].id}';
                    as.path.value = 'onweb';
                    if (_testNameController.text.trim().isEmpty == true ||
                        _testPwController.text.trim().isEmpty == true) {
                      showOnlyConfirmDialog(context, "제목 또는 비밀번호를 입력해주세요");
                    } else if (pickedFile == null && isfilePath == '') {
                      showOnlyConfirmDialog(context, "파일을 등록해주세요");
                    } else {
                      showComponentDialog(context,
                          args?.edit == true ? '수정하시겠습니까?' : '업로드 하시겠습니까?',
                          () async {
                        Get.back();
                        if (args?.edit == true) {
                          await _updateTest('${args!.docId}');
                          await _updateTimer('${args.docId}');
                          showConfirmTapDialog(context, '업로드가 완료되었습니다.', () {
                            // Get.offAll(() => BottomNavigator());
                            Get.offAllNamed(MainScreen.id);
                          });
                        } else {
                          await firebaseAnswerUpload(uploadfile,uploadfile2,_testCountController2.text,scoreVisual,_dropdown!);

                          showConfirmTapDialog(context, "업로드가 완료되었습니다.", () {
                            // Get.offAll(() => BottomNavigator());
                            Get.offAllNamed(MainScreen.id);
                          });
                        }
                      });
                      // await firebaseAnswerUpload(uploadTask);
                      // // await _uploadFile('12345', as.docId.value);
                      //
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 28),
                    child: const Center(
                        child: Text(
                      '저장',
                      style: f16Whitew700,
                    )),
                  )),
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
                    height: 40,
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

                    // TextFormField(
                    //   controller: _testNameController,
                    //   textAlign: TextAlign.start,
                    //   style: TextStyle(
                    //       fontSize: 17,
                    //       fontFamily: 'NotoSansKr',
                    //       color: Color(0xff292929)),
                    //   enabled: true,
                    //   keyboardType: TextInputType.text,
                    //   decoration: InputDecoration(
                    //       enabledBorder: UnderlineInputBorder(
                    //         borderSide: BorderSide(color: Colors.blueGrey[200]!),
                    //       ),
                    //       focusedBorder: UnderlineInputBorder(
                    //         borderSide: BorderSide(color: Colors.black),
                    //       ),
                    //       prefixIconConstraints: BoxConstraints(minWidth: 23),
                    //       hintText: '시험 명을 입력해주세요',
                    //       hintStyle: TextStyle(
                    //           fontSize: 24,
                    //           fontWeight: FontWeight.w500,
                    //           fontFamily: 'NotoSansKr',
                    //           color: Colors.blueGrey[200])),
                    // ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '문제 파일',
                        style: f18w400,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        pickedFile?.name != null
                            ? Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  color: textFormColor,
                                ),
                                padding: (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? EdgeInsets.zero
                                    : const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 12),
                                width: (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? Get.width * 0.4
                                    : Get.width * 0.3,
                                height: (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? 32
                                    : 40,
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Flexible(
                                      child: Container(
                                        padding:
                                            new EdgeInsets.only(right: 13.0),
                                        child: Text(
                                          '${pickedFile?.name}',
                                          style: (kIsWeb &&
                                                  (Get.width * 0.2 <= 171))
                                              ? f12w400greyAel
                                              : f16w400grey8,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        pickedFile = null;
                                        setState(() {});
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size:
                                            (kIsWeb && (Get.width * 0.2 <= 171))
                                                ? 16
                                                : 20,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 4,
                                    ),
                                  ],
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(8.0)),
                                  color: textFormColor,
                                ),
                                padding: (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? EdgeInsets.all(8)
                                    : const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 12),
                                width: (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? Get.width * 0.4
                                    : Get.width * 0.3,
                                height: (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? 32
                                    : 40,
                                child: args?.edit == true
                                    ? Text(
                                        args?.pdfUploadName![0],
                                        style:
                                            (kIsWeb && (Get.width * 0.2 <= 171))
                                                ? f12w400greyAel
                                                : f16w400grey8,
                                        textAlign: TextAlign.center,
                                      )
                                    : Text(
                                        (kIsWeb && (Get.width * 0.2 <= 171))
                                            ? '문제를 추가해주세요'
                                            : '시험 문제를 추가해 주세요',
                                        style:
                                            (kIsWeb && (Get.width * 0.2 <= 171))
                                                ? f12w400greyAel
                                                : f16w400grey8,
                                        textAlign: TextAlign.center,
                                      ),
                              ),
                        SizedBox(
                          width: 4,
                        ),
                        args?.edit == true
                            ? Container(
                                height: (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? 32
                                    : 40,
                                child: ElevatedButton(
                                    onPressed: () async {},
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      )),
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                              (kIsWeb &&
                                                      (Get.width * 0.2 <= 171))
                                                  ? EdgeInsets.symmetric(
                                                      vertical: 12,
                                                      horizontal: 12)
                                                  : EdgeInsets.symmetric(
                                                      vertical: 18.5,
                                                      horizontal: 20)),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              textFormColor),
                                      splashFactory: NoSplash.splashFactory,
                                      elevation:
                                          MaterialStateProperty.all<double>(
                                              0.0),
                                    ),
                                    child: Text('찾아보기',
                                        style:
                                            (kIsWeb && (Get.width * 0.2 <= 171))
                                                ? f12w700primary
                                                : f16w700primary)),
                              )
                            : Container(
                                height: (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? 32
                                    : 40,
                                child: ElevatedButton(
                                    onPressed: () async {
                                      FilePickerResult? result =
                                          await FilePicker.platform.pickFiles(
                                        allowedExtensions: [
                                          'pdf',
                                        ],
                                        type: FileType.custom,
                                      );

                                      if (result == null) return;
                                      pickedFile = result.files.first;
                                      uploadfile = result.files.single.bytes!;

                                      if (pickedFile != null) {
                                        isfilePath = '11';
                                      }
                                      setState(() {});
                                    },
                                    style: ButtonStyle(
                                      shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      )),
                                      padding:
                                          MaterialStateProperty.all<EdgeInsets>(
                                              (kIsWeb &&
                                                      (Get.width * 0.2 <= 171))
                                                  ? EdgeInsets.symmetric(
                                                      vertical: 10,
                                                      horizontal: 12)
                                                  : EdgeInsets.symmetric(
                                                      vertical: 18.5,
                                                      horizontal: 20)),
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              textFormColor),
                                      splashFactory: NoSplash.splashFactory,
                                      elevation:
                                          MaterialStateProperty.all<double>(
                                              0.0),
                                    ),
                                    child: Text('찾아보기',
                                        style:
                                            (kIsWeb && (Get.width * 0.2 <= 171))
                                                ? f12w700primary
                                                : f16w700primary)),
                              ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 16,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: Row(
                      children: [
                        Container(
                          height: (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            color: textFormColor,
                          ),
                          padding: (kIsWeb && (Get.width * 0.2 <= 171))
                              ? EdgeInsets.symmetric(horizontal: 8)
                              : const EdgeInsets.symmetric(
                                  vertical: 0, horizontal: 12),
                          width: (kIsWeb && (Get.width * 0.2 <= 171))
                              ? Get.width * 0.4
                              : Get.width * 0.3,
                          child: pickedFile2 == null&& _hasAudio == ''
                              ? Center(
                                  child: Text(
                                    (kIsWeb && (Get.width * 0.2 <= 171))
                                        ? '파일을 추가해주세요'
                                        : '듣기 파일을 추가해 주세요',
                                    style: (kIsWeb && (Get.width * 0.2 <= 171))
                                        ? f12w400greyAel
                                        : f16w400grey8,
                                    textAlign: TextAlign.center,
                                  ),
                                )
                              : Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '파일이 첨부돼있습니다',
                                      style: (kIsWeb && (Get.width * 0.2 <= 171))
                                          ? f12w500
                                          : f16w500,
                                      textAlign: TextAlign.center,
                                    ),
                                    GestureDetector(
                                      onTap: args?.edit == true ? null :  () {
                                        pickedFile2 = null;
                                        setState(() {});
                                      },
                                      child: Icon(
                                        Icons.close,
                                        size: (kIsWeb && (Get.width * 0.2 <= 171)) ?12 :20,
                                      ),
                                    )
                                  ],
                                ),
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Container(
                          height: (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
                          child: ElevatedButton(
                              onPressed: args?.edit == true  ?  null : () async {
                                FilePickerResult? result =
                                    await FilePicker.platform.pickFiles(
                                  type: FileType.audio,
                                );
                                if (result == null) return;
                                pickedFile2 = result.files.first;
                                uploadfile2 = result.files.single.bytes!;
                                setState(() {});
                              },
                              style: ButtonStyle(
                                shape: MaterialStateProperty.all<
                                        RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                )),
                                padding: MaterialStateProperty.all<EdgeInsets>(
                                    EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 20)),
                                backgroundColor: MaterialStateProperty.all<Color>(
                                    textFormColor),
                                splashFactory: NoSplash.splashFactory,
                                elevation: MaterialStateProperty.all<double>(0.0),
                              ),
                              child: Text('찾아보기',
                                  style: (kIsWeb && (Get.width * 0.2 <= 171))
                                      ? f12w700primary
                                      : f16w700primary)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
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
                            width: (kIsWeb && (Get.width * 0.2 <= 171))
                                ? Get.width * 0.4
                                : Get.width * 0.3,
                            height:
                                (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
                            child: TextFormField(
                              controller: _testCountController,
                              textAlign: TextAlign.center,
                              enabled: args?.edit == true ? false : true,
                              style: (kIsWeb && (Get.width * 0.2 <= 171))
                                  ? f12w400
                                  : f16w400,
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                isDense: (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? true
                                    : false,
                                hintText: '20',
                                hintStyle: (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? f12w400
                                    : f16w400,
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.zero,
                                prefixIcon: InkWell(
                                  onTap: args?.edit == true
                                      ? null
                                      : () {
                                          _answerList.removeLast();
                                          as.pdfUploadName.removeLast();
                                          as.pdfUploadName2.removeLast();
                                          setState(() {
                                            // final x = _testCountController.text.obs;
                                            ///_testCountController -
                                            _testCountController
                                                .text = (_testCountController
                                                            .text !=
                                                        '0'
                                                    ? int.parse(
                                                            _testCountController
                                                                .text) -
                                                        1
                                                    : 0)
                                                .toString();
                                          });
                                        },
                                  child: Icon(
                                    Icons.exposure_minus_1,
                                    color: Colors.black,
                                  ),
                                  // child: SvgPicture.asset(
                                  //   'assets/icon/minus.svg',
                                  //   height: kIsWeb && (Get.width * 0.2 <= 171)
                                  //       ? 14
                                  //       : 12,
                                  //   width: kIsWeb && (Get.width * 0.2 <= 171)
                                  //       ? 14
                                  //       : 12,
                                  //   color: Colors.black,
                                  // ),
                                ),
                                suffixIcon: InkWell(
                                  onTap: args?.edit == true
                                      ? null
                                      : () {
                                          _answerList.add('1');
                                          as.pdfUploadName.add('');
                                          as.pdfUploadName.add('');
                                          setState(() {
                                            ///_testCountController +
                                            _testCountController.text =
                                                (int.parse(_testCountController
                                                            .text) +
                                                        1)
                                                    .toString();
                                          });
                                        },
                                  child: Icon(
                                    Icons.plus_one,
                                    color: Colors.black,
                                  ),
                                  // child: SvgPicture.asset(
                                  //   'assets/icon/plus.svg',
                                  //   height: kIsWeb && (Get.width * 0.2 <= 171)
                                  //       ? 20
                                  //       : 12,
                                  //   width: kIsWeb && (Get.width * 0.2 <= 171)
                                  //       ? 20
                                  //       : 12,
                                  //   color: teacherColor,
                                  // ),
                                ),
                              ),
                            )),
                        SizedBox(
                          width: 4,
                        ),
                        Container(
                          height:
                              (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
                          child: ElevatedButton(
                              onPressed: args?.edit == true
                                  ? null
                                  : () async {
                                      try {
                                        if (int.tryParse(
                                                _testCountController.text) !=
                                            null) {
                                          if (int.parse(
                                                  _testCountController.text) <
                                              _answerList.length) {
                                            _answerList.removeRange(
                                                int.parse(
                                                    _testCountController.text),
                                                _answerList.length);
                                            as.pdfUploadName.removeRange(
                                                int.parse(
                                                    _testCountController.text),
                                                _answerList.length);
                                            as.pdfUploadName2.removeRange(
                                                int.parse(
                                                    _testCountController.text),
                                                _answerList.length);

                                          }
                                          if (int.parse(
                                                  _testCountController.text) >
                                              _answerList.length) {
                                            int diff = int.parse(
                                                    _testCountController.text) -
                                                _answerList.length;
                                            for (int i = 0; i < diff; i++) {
                                              _answerList.add('1');
                                              as.pdfUploadName.add('');
                                              as.pdfUploadName2.add('');
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
                                    (kIsWeb && (Get.width * 0.2 <= 171))
                                        ? EdgeInsets.symmetric(
                                            vertical: 10, horizontal: 12)
                                        : EdgeInsets.symmetric(
                                            vertical: 18.5, horizontal: 20)),
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
                          borderRadius:
                          BorderRadius.all(Radius.circular(8.0)),
                          color: testCountColor,
                        ),
                        width: (kIsWeb && (Get.width * 0.2 <= 171))
                            ? Get.width * 0.4
                            : Get.width * 0.3,
                        height:
                        (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
                        child: TextFormField(
                          maxLength: 4,
                          controller: _testCountController2,
                          textAlign: TextAlign.center,
                          enabled: true,
                          style: (kIsWeb && (Get.width * 0.2 <= 171))
                              ? f12w400
                              : f16w400,
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            counterText: '',
                            isDense: (kIsWeb && (Get.width * 0.2 <= 171))
                                ? true
                                : false,
                            hintText: '100',
                            hintStyle: (kIsWeb && (Get.width * 0.2 <= 171))
                                ? f12w400grey8
                                : f16w400grey8,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                            prefixIcon: InkWell(
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
                              child: Icon(Icons.exposure_minus_1,color: Colors.black,),
                            ),
                            suffixIcon: InkWell(
                              onTap: args?.edit == true
                                  ? null
                                  : () {
                                setState(() {
                                  ///_testCountController +
                                  _testCountController2.text = (int.parse(_testCountController2.text) + 1).toString();
                                });
                              },
                              child: Icon(Icons.plus_one,color: Colors.black,),
                            ),
                          ),
                        )),
                  ),
                  const SizedBox(height: 16,),
                  Row(
                    children: [
                      Text('답 공개', style: f18w400,),
                      SizedBox(
                        width: 7,
                      ),
                      SwitchButton(onTap: (){
                        scoreVisual = !scoreVisual;
                        setState(() {

                        });
                      },value: scoreVisual,),
                    ],
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
                      obscureText: _obscureText.isTrue,
                      onTap: () {
                        setState(() {
                          _obscureText.value = !_obscureText.value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  const Divider(
                    height: 1,
                    color: cameraBackColor,
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        '답안',
                        style: f18w400,
                      )),
                  const SizedBox(
                    height: 10,
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 24),
                    child: ListView.builder(
                      itemCount: _answerList.length,
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return args?.edit == true
                            ? Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${index + 1} :',
                                        style:
                                            (kIsWeb && (Get.width * 0.2 <= 171))
                                                ? f16w700
                                                : f18w700,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                          width: (kIsWeb &&
                                                  (Get.width * 0.2 <= 171))
                                              ? Get.width * 0.3
                                              : Get.width * 0.3,
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10.0),
                                          decoration: BoxDecoration(
                                            color: textFormColor,
                                            borderRadius:
                                                BorderRadius.circular(4),
                                            border: Border.all(
                                                color: Color(0xffE9E9E9),
                                                style: BorderStyle.solid,
                                                width: 0.80),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Text(
                                              '${_answerList[index]}',
                                              style: f16w500,
                                            ),
                                          )),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              )
                            : Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${index + 1} :',
                                        style:
                                            (kIsWeb && (Get.width * 0.2 <= 171))
                                                ? f16w700
                                                : f18w700,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Container(
                                        width: Get.width * 0.3,
                                        height:
                                            (kIsWeb && (Get.width * 0.2 <= 171))
                                                ? 32
                                                : 40,
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 10.0),
                                        decoration: BoxDecoration(
                                          color: textFormColor,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                              color: Color(0xffE9E9E9),
                                              style: BorderStyle.solid,
                                              width: 0.80),
                                        ),
                                        child: DropdownButton<String>(
                                          dropdownColor: textFormColor,
                                          isExpanded: true,
                                          value: _answerList[index],
                                          icon: Icon(Icons.arrow_drop_down),
                                          iconSize: 30,
                                          elevation: 16,
                                          hint: Text('답안을 선택해 주세요',
                                              style: f18w400),
                                          style: const TextStyle(
                                              color: Colors.black),
                                          underline: Container(
                                            height: 10,
                                            color: Colors.transparent,
                                          ),
                                          onChanged: (newValue) {
                                            setState(() {
                                              _answerList[index] = newValue!;
                                            });
                                          },
                                          items: <String>[
                                            '1',
                                            '2',
                                            '3',
                                            '4',
                                            '5'
                                          ].map<DropdownMenuItem<String>>(
                                              (String val) {
                                            // ignore: missing_required_param
                                            return DropdownMenuItem<String>(
                                              value: val,
                                              child: Text(val, style: f16w500),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 40,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 24),
                    child: Footer(),
                  ),
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


  Future<void> _updateTest(String docId) async {
    final as = Get.put(AnswerState());
    DocumentReference ref =
        FirebaseFirestore.instance.collection('answer').doc(docId);
    ref.update({
      'pdfCategory': _testNameController.text,
      'password': _testPwController.text,
      // 'answer': as.answer.toList(),
      // 'pdfUploadName':pickedFile?.name==null?args.pdfUploadName:pickedFile?.name,
    });
    // if(isfilePath == '11'){
    //   await _uploadFile(as.teacher.value, args.docId!);
    // }
  }

  Future<void> _updateTimer(String docId) async {
    final as = Get.put(AnswerState());
    DocumentReference ref =
    FirebaseFirestore.instance.collection('answer').doc(docId);
    ref.update({
      'temp2' : _testCountController2.text,
    });
  }

  Future<bool> _useBackKey(BuildContext context) async {
    return await showComponentDialog(context, '작성을 취소하시겠습니까?', () {
      Get.offAllNamed(MainScreen.id);
    });
  }
}
