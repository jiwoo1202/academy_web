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

import 'package:http/http.dart' as http;
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

class PdfUploadScreenTablet extends StatefulWidget {
  static final String id = '/pdf_upload_tablet';

  final String? category;
  final List? pdfUploadName;
  final List? pdfUploadName2;
  final String? password;
  final String? docId;
  final bool? edit;
  final String? teacherName;
  final String? audio;
  final String? countdown;
  final List? answerlength;
  final String? state;
  const PdfUploadScreenTablet(
      {Key? key,
      this.category,
      this.pdfUploadName,
      this.password,
      this.edit,
      this.answerlength,
      this.docId,
      this.teacherName, this.audio, this.countdown, this.state, this.pdfUploadName2})
      : super(key: key);

  @override
  State<PdfUploadScreenTablet> createState() => _PdfUploadScreenTabletState();
}

class _PdfUploadScreenTabletState extends State<PdfUploadScreenTablet> {
  PlatformFile? pickedFile;
  PlatformFile? pickedFile2;
  UploadTask? uploadTask;
  String isfilePath = '';
  String isfilePath2 = '';
  String _hasAudio = '';
  TextEditingController _testNameController = TextEditingController();
  TextEditingController _testPwController = TextEditingController();
  TextEditingController _testCountController = TextEditingController();
  TextEditingController _testCountController2 = TextEditingController();
  List<String> number = ['1', '2', '3', '4', '5'];

  final _obscureText = false.obs;
  List _answerList = [];
  bool _imageLoading = false;
  bool imagedelete = false;
  bool sounddelete = false;
  late Uint8List uploadfile;
  late Uint8List? uploadfile2;
  bool scoreVisual = false;
  String? _dropdown = '전체';
  List<String> _dropdownList= ['전체','국어','수학','영어','과학','사회','한국사'];
  @override
  void initState() {
    Future.delayed(Duration.zero,()async{
      final args = ModalRoute.of(context)!.settings.arguments as PdfUploadScreenTablet?;
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
       uploadfile2 = null;
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
        isfilePath2 = '1';
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
    final args = ModalRoute.of(context)!.settings.arguments as PdfUploadScreenTablet?;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: () async{
          return Future(() {
           Get.back();
            return true;
          });
        },
        child: Scaffold(backgroundColor: backColor,
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
                            const SizedBox(
                              height: 40,
                            ),
                            Row(children: [
                              Text('문제추가 - 한번에 등록', style: f32w700,),
                              Spacer(),
                              GestureDetector(
                                onTap: () {
                                  showComponentDialog(context, '작성을 취소하시겠습니까?', () {
                                    Get.back();
                                    Get.back();
                                    // Get.offAllNamed(BottomNavigator.id);
                                    // Navigator.pushNamedAndRemoveUntil(context, LoginMainScreen.id, (route) => false);
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
                                onTap: () async {
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
                                  if(pickedFile?.name==null){
                                    as.pdfUploadName[0] = '${args?.pdfUploadName![0]}';
                                  }
                                  if(pickedFile2?.name==null){
                                    as.pdfUploadName2[0] = '${args?.pdfUploadName2![0]}';
                                  }

                                  if (_testNameController.text.trim().isEmpty == true ||
                                      _testPwController.text.trim().isEmpty == true) {
                                    showOnlyConfirmDialog(context, "제목 또는 비밀번호를 입력해주세요");
                                  } else if (pickedFile == null && isfilePath == '') {
                                    showOnlyConfirmDialog(context, "파일을 등록해주세요");
                                  } else {
                                    showComponentDialog(context,
                                        args?.edit == true ? '수정하시겠습니까?' : '임시저장 하시겠습니까?',
                                            () async {
                                          Get.back();
                                          if (args?.edit == true) {
                                            await _updateTestSave('${args!.docId}');
                                            await _updateTimer('${args.docId}');
                                            showConfirmTapDialog(context, '업로드가 완료되었습니다.', () {
                                              // Get.offAll(() => BottomNavigator());
                                              Get.offAllNamed(MainScreen.id);
                                            });
                                          }

                                          else {
                                            await firebaseAnswerUploadSave(uploadfile,uploadfile2,_testCountController2.text,scoreVisual);
                                            showConfirmTapDialog(context, "임시저장이 완료되었습니다.", () {
                                              // Get.offAll(() => BottomNavigator());
                                              // Get.offAllNamed(MainScreen.id);
                                              Get.to(()=>BottomNavigator());
                                            });
                                          }
                                        });
                                    // await firebaseAnswerUpload(uploadTask);
                                    // // await _uploadFile('12345', as.docId.value);
                                    //
                                  }
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
                                  if(pickedFile?.name==null){
                                    as.pdfUploadName[0] = '${args?.pdfUploadName![0]}';
                                  }
                                  if(pickedFile2?.name==null){
                                    as.pdfUploadName2[0] = '${args?.pdfUploadName2![0]}';
                                  }
                                  if (_testNameController.text.trim().isEmpty == true ||
                                      _testPwController.text.trim().isEmpty == true) {
                                    showOnlyConfirmDialog(context, "제목 또는 비밀번호를 입력해주세요");
                                  } else if (pickedFile == null && isfilePath == ''||as.pdfUploadName[0]=='') {
                                    showOnlyConfirmDialog(context, "파일을 등록해주세요");
                                  } else {
                                    showComponentDialog(context,
                                        args?.edit == true ? '수정하시겠습니까?' : '업로드 하시겠습니까?',
                                            () async {
                                          Get.back();
                                          if (args?.edit == true) {
                                            if(args?.state=='임시'){

                                              _updateUpload('${args?.docId}');
                                              showConfirmTapDialog(context, "업로드가 완료되었습니다.", () {
                                                // Get.offAll(() => BottomNavigator());
                                                Get.offAllNamed(MainScreen.id);
                                              });
                                            }
                                            else {
                                              await _updateTest('${args!.docId}');
                                              await _updateTimer('${args.docId}');
                                              showConfirmTapDialog(
                                                  context, '업로드가 완료되었습니다.', () {
                                                // Get.offAll(() => BottomNavigator());
                                                Get.offNamedUntil(BottomNavigator.id, (route) => true);
                                              });
                                            }
                                          } else {
                                            if(pickedFile2 ==null){
                                              as.pdfUploadName2[0] = '';
                                            }
                                            await firebaseAnswerUpload(uploadfile,uploadfile2,_testCountController2.text,scoreVisual,_dropdown!);
                                            showConfirmTapDialog(context, "업로드가 완료되었습니다.", () {
                                              // Get.offAll(() => BottomNavigator());
                                              Get.offNamedUntil(BottomNavigator.id, (route) => true);
                                            });
                                          }
                                        });
                                    // await firebaseAnswerUpload(uploadTask);
                                    // // await _uploadFile('12345', as.docId.value);
                                    //
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
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Container(
                                width: Get.width * 0.3,
                                child: Column(mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('문제 파일', style: f18w400,),
                                    const SizedBox(height: 10,),
                                    args?.edit == true && args?.state !='임시'
                                        ? Container(height: 50,
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
                                                    EdgeInsets.symmetric(
                                                        vertical: 18.5,
                                                        horizontal: 100)),
                                                backgroundColor: MaterialStateProperty.all<Color>(textFormColor),
                                                splashFactory: NoSplash.splashFactory,
                                                elevation: MaterialStateProperty.all<double>(0.0),
                                              ),
                                              child: Text('찾아보기', style: f16w700primary)),
                                        )
                                        : Container(height: 50,
                                          child: ElevatedButton(
                                              onPressed: () async {
                                                FilePickerResult? result =
                                                await FilePicker.platform.pickFiles(
                                                  allowedExtensions: ['pdf',],
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
                                                    EdgeInsets.symmetric(
                                                        vertical: 18.5,
                                                        horizontal: 100)),
                                                backgroundColor: MaterialStateProperty.all<Color>(textFormColor),
                                                splashFactory: NoSplash.splashFactory,
                                                elevation: MaterialStateProperty.all<double>(0.0),
                                              ),
                                              child: Text('찾아보기', style: f16w700primary)),
                                        ),
                                    const SizedBox(height: 10,),
                                    pickedFile?.name != null
                                        ? Container(
                                              height: 54,
                                              width: 180,
                                              decoration: BoxDecoration(
                                                border: Border.all(color: const Color(0xffDADADA),),
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                                children: [
                                                  Flexible(
                                                    child: Text(
                                                      '${pickedFile?.name}',
                                                      style: f16w400grey8,
                                                      textAlign: TextAlign.center,
                                                    ),
                                                  ),
                                                  GestureDetector(
                                                    onTap: () {
                                                      pickedFile = null;
                                                      setState(() {});
                                                    },
                                                    child: Icon(Icons.close, size: 20,),
                                                  ),
                                                ],
                                              ),
                                            )
                                        : args?.edit == true &&args?.state !='임시'
                                        ? Container(
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: const Color(0xffDADADA),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(8),
                                                  ),
                                                  child: Text(
                                                    args?.pdfUploadName![0],
                                                    style: f16w400grey8,
                                                    textAlign: TextAlign.center,
                                                  ))
                                        : args?.state=='임시'
                                        ? imagedelete==true?Container():
                                    Container(
                                        width: 180,
                                      height: 39,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: const Color(0xffDADADA),),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Text(
                                              '${args?.pdfUploadName![0]}',
                                              style: f16w400grey8,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              //임시였을때 지우는곳
                                              args?.pdfUploadName![0] ='';
                                              imagedelete = true;
                                              setState(() {});
                                            },
                                            child: Icon(Icons.close, size: 20,),
                                          ),
                                        ],
                                      ),
                                    )
                                        :Container(),
                                    const SizedBox(height: 16,),

                                    Text('듣기 파일', style: f18w400,),
                                    const SizedBox(height: 10,),
                                    args?.edit == true
                                        ? args?.state=='임시'
                                        ? Container(height: 50,
                                          child: ElevatedButton(
                                          onPressed: () async {
                                            FilePickerResult? result =
                                            await FilePicker.platform.pickFiles(
                                              type: FileType.audio,
                                            );
                                            if (result == null) return;
                                            pickedFile2 = result.files.first;
                                            uploadfile2 = result.files.single.bytes!;
                                            if (pickedFile2 != null) {
                                              isfilePath2 = '11';
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
                                                EdgeInsets.symmetric(
                                                    vertical: 18.5,
                                                    horizontal: 100)),
                                            backgroundColor: MaterialStateProperty.all<Color>(textFormColor),
                                            splashFactory: NoSplash.splashFactory,
                                            elevation: MaterialStateProperty.all<double>(0.0),
                                          ),
                                          child: Text('찾아보기', style: f16w700primary)),
                                    )
                                        : Container(height: 50,
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
                                                EdgeInsets.symmetric(
                                                    vertical: 18.5,
                                                    horizontal: 100)),
                                            backgroundColor: MaterialStateProperty.all<Color>(textFormColor),
                                            splashFactory: NoSplash.splashFactory,
                                            elevation: MaterialStateProperty.all<double>(0.0),
                                          ),
                                          child: Text('찾아보기', style: f16w700primary)),
                                        )
                                        : Container(height: 50,
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
                                                  borderRadius:
                                                  BorderRadius.circular(8.0),
                                                )),
                                            padding:
                                            MaterialStateProperty.all<EdgeInsets>(
                                                EdgeInsets.symmetric(
                                                    vertical: 18.5,
                                                    horizontal: 100)),
                                            backgroundColor: MaterialStateProperty.all<Color>(textFormColor),
                                            splashFactory: NoSplash.splashFactory,
                                            elevation: MaterialStateProperty.all<double>(0.0),
                                          ),
                                          child: Text('찾아보기', style: f16w700primary)),
                                        ),
                                    const SizedBox(height: 10,),
                                    pickedFile2?.name != null
                                        ? Container(
                                        height: 54,
                                        width: 180,
                                      decoration: BoxDecoration(
                                        border: Border.all(color: const Color(0xffDADADA),),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            '${pickedFile2?.name}',
                                            style: f16w500,
                                            textAlign: TextAlign.center,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              pickedFile2 = null;
                                              setState(() {});
                                            },
                                            child: Icon(
                                              Icons.close,
                                              size: 20,
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                        : args?.edit == true
                                        ? args?.pdfUploadName2![0] =='null'
                                        ? Container()
                                        : sounddelete==false?
                                    Container(
                                        height: 54,
                                        width: 180,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: const Color(0xffDADADA),
                                          ),
                                          borderRadius:
                                          BorderRadius.circular(8),
                                        ),
                                        child:
                                         // Text(args?.pdfUploadName2![0],style: f16w400grey8,textAlign: TextAlign.center,),
                                          Row(
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              '${args?.pdfUploadName2![0]}',
                                              style: f16w400grey8,
                                              textAlign: TextAlign.center,
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                sounddelete = true;
                                                pickedFile2 = null;
                                                args?.pdfUploadName2![0]='';
                                                setState(() {});
                                              },
                                              child: Icon(
                                                Icons.close,
                                                size: 20,
                                              ),
                                            )
                                          ],
                                        )
                                    ) : Container():Container(),
                                    const SizedBox(height: 16,),

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
                                          enabled: args?.edit == true && args?.state !='임시'
                                              ? false
                                              : args?.state =='임시'
                                              ? true
                                              : true,
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
                                                onTap: args?.edit == true &&args?.state !='임시'
                                                    ? null
                                                    : args?.state == '임시'
                                                    ? () {
                                                  _answerList.removeLast();
                                                  as.pdfUploadName.removeLast();
                                                  as.pdfUploadName2.removeLast();
                                                  setState(() {
                                                    // final x = _testCountController.text.obs;
                                                    ///_testCountController -
                                                    _testCountController.text = (_testCountController.text != '0' ?
                                                    int.parse(_testCountController.text) - 1 : 0).toString();
                                                  });
                                                }
                                                    : () {
                                                  _answerList.removeLast();
                                                  as.pdfUploadName.removeLast();
                                                  as.pdfUploadName2.removeLast();
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
                                                onTap: args?.edit == true &&args?.state !='임시'
                                                    ? null
                                                    : args?.state == '임시'
                                                    ?() {
                                                  _answerList.add('1');
                                                  as.pdfUploadName.add('');
                                                  as.pdfUploadName.add('');
                                                  setState(() {
                                                    ///_testCountController +
                                                    _testCountController.text =
                                                        (int.parse(_testCountController.text) + 1).toString();
                                                  });
                                                }
                                                    : () {
                                                  _answerList.add('1');
                                                  as.pdfUploadName.add('');
                                                  as.pdfUploadName.add('');
                                                  setState(() {
                                                    ///_testCountController +
                                                    _testCountController.text =
                                                        (int.parse(_testCountController.text) + 1).toString();
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
                                    // const SizedBox(
                                    //   width: 4,
                                    // ),
                                    // Container(
                                    //   height: 40,
                                    //   child: ElevatedButton(
                                    //       onPressed: args?.edit == true ? null
                                    //           : () async {
                                    //               try {
                                    //                 if (int.tryParse(
                                    //                         _testCountController
                                    //                             .text) !=
                                    //                     null) {
                                    //                   if (int.parse(
                                    //                           _testCountController
                                    //                               .text) <
                                    //                       _answerList.length) {
                                    //                     _answerList.removeRange(
                                    //                         int.parse(
                                    //                             _testCountController
                                    //                                 .text),
                                    //                         _answerList.length);
                                    //                     as.pdfUploadName
                                    //                         .removeRange(
                                    //                             int.parse(
                                    //                                 _testCountController
                                    //                                     .text),
                                    //                             _answerList
                                    //                                 .length);
                                    //                     as.pdfUploadName2
                                    //                         .removeRange(
                                    //                             int.parse(
                                    //                                 _testCountController
                                    //                                     .text),
                                    //                             _answerList
                                    //                                 .length);
                                    //                   }
                                    //                   if (int.parse(
                                    //                           _testCountController
                                    //                               .text) >
                                    //                       _answerList.length) {
                                    //                     int diff = int.parse(
                                    //                             _testCountController
                                    //                                 .text) -
                                    //                         _answerList.length;
                                    //                     for (int i = 0;
                                    //                         i < diff;
                                    //                         i++) {
                                    //                       _answerList.add('1');
                                    //                       as.pdfUploadName
                                    //                           .add('');
                                    //                       as.pdfUploadName2
                                    //                           .add('');
                                    //                     }
                                    //                   }
                                    //                   setState(() {});
                                    //                 }
                                    //               } catch (e) {
                                    //                 print(e);
                                    //               }
                                    //             },
                                    //       style: ButtonStyle(
                                    //         shape: MaterialStateProperty.all<
                                    //                 RoundedRectangleBorder>(
                                    //             RoundedRectangleBorder(
                                    //           borderRadius:
                                    //               BorderRadius.circular(8.0),
                                    //         )),
                                    //         padding: MaterialStateProperty.all<
                                    //             EdgeInsets>((kIsWeb &&
                                    //                 (Get.width * 0.2 <= 171))
                                    //             ? EdgeInsets.symmetric(
                                    //                 vertical: 10,
                                    //                 horizontal: 12)
                                    //             : EdgeInsets.symmetric(
                                    //                 vertical: 18.5,
                                    //                 horizontal: 20)),
                                    //         backgroundColor:
                                    //             MaterialStateProperty.all<
                                    //                 Color>(textFormColor),
                                    //         splashFactory:
                                    //             NoSplash.splashFactory,
                                    //         elevation: MaterialStateProperty
                                    //             .all<double>(0.0),
                                    //       ),
                                    //       child: Text('확인',
                                    //           style: (kIsWeb &&
                                    //                   (Get.width * 0.2 <= 171))
                                    //               ? f12w700primary
                                    //               : f16w700primary)),
                                    // )
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
                                          enabled: args?.edit == true && args?.state !='임시'
                                              ? false
                                              : args?.state =='임시'
                                              ? true
                                              : true,
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
                                                onTap: args?.edit == true &&args?.state !='임시'
                                                    ? null
                                                    : args?.state == '임시'
                                                    ?() {
                                                  setState(() {
                                                    // final x = _testCountController.text.obs;
                                                    ///_testCountController -
                                                    _testCountController2.text = (_testCountController2.text != '0'
                                                        ? int.parse(_testCountController2.text) - 1 : 0).toString();
                                                  });
                                                }
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
                                                onTap: args?.edit == true &&args?.state !='임시'
                                                    ? null
                                                    :args?.state == '임시'
                                                    ?() {
                                                  setState(() {
                                                    ///_testCountController +
                                                    _testCountController2.text = (int.parse(_testCountController2.text) + 1).toString();
                                                  });
                                                }
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
                                    Text('비밀번호', style: f18w400,),
                                    const SizedBox(height: 10,),
                                    Container(
                                      width: Get.width * 0.2,
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
                                    ],),
                              ),
                              Spacer(),
                              Column(mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('답안', style: f24w700,),
                                  const SizedBox(height: 20,),
                                  Container(
                                    width: Get.width * 0.4, height: Get.height * 0.5,
                                    decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
                                    child: ListView.builder(
                                      itemCount: _answerList.length,
                                      shrinkWrap: true,
                                      physics: const ClampingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        return args?.edit == true&&args?.state !='임시'
                                            ? Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text('${index + 1}번 문제', style: f18w700,),
                                                Spacer(),
                                                Container(
                                                    height: 100, width: 310,
                                                    child: ListView(
                                                      scrollDirection: Axis.horizontal,
                                                      children: List.generate(
                                                          number.length, (i) =>
                                                          Row(
                                                            children: [
                                                              TextButton(
                                                                  onPressed:() {},
                                                                  style: TextButton
                                                                      .styleFrom(
                                                                    shape: RoundedRectangleBorder(
                                                                        borderRadius: BorderRadius.circular(20)),
                                                                    side: BorderSide(width: 1, color: Colors.grey),
                                                                    minimumSize: Size(52, 52),
                                                                    foregroundColor: _answerList[index] == number[i] ? Colors.white : Colors.black,
                                                                    backgroundColor: _answerList[index] == number[i] ? nowColor : Colors.white,
                                                                    padding: EdgeInsets.only(right: 12, left: 12),
                                                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                  ),
                                                                  child: Text(
                                                                      '${i + 1}',
                                                                      style: _answerList[index] == number[i] ? f10Whitew500 : f16Whitew700 )),
                                                              SizedBox(
                                                                width: 10,
                                                              ),
                                                            ],
                                                          )),
                                                    )),
                                              ],
                                            )
                                            : args?.state == '임시'
                                            ? Row(
                                          children: [
                                            Text('${index + 1}번 문제', style: f18w700,),
                                            Spacer(),
                                            Container(
                                                height: 100, width: 310,
                                                child: ListView(
                                                  scrollDirection: Axis.horizontal,
                                                  children: List.generate(
                                                      number.length, (i) =>
                                                      Row(
                                                        children: [
                                                          TextButton(
                                                              onPressed:() {setState(() {
                                                                _answerList[index] = number[i];
                                                              });},
                                                              style: TextButton
                                                                  .styleFrom(
                                                                shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.circular(20)),
                                                                side: BorderSide(width: 1, color: Colors.grey),
                                                                minimumSize: Size(52, 52),
                                                                backgroundColor: _answerList[index] == number[i] ? nowColor : Colors.white,
                                                                padding: EdgeInsets.only(right: 12, left: 12),
                                                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                              ),
                                                              child: Text(
                                                                  '${i + 1}',
                                                                  style: _answerList[index] == number[i] ? f16Whitew700 : f16w700 )),
                                                          SizedBox(
                                                            width: 10,
                                                          ),
                                                        ],
                                                      )),
                                                )),
                                          ],
                                        )
                                            : SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                              child: Row(
                                                children: [
                                                  Text('${index + 1}번 문제', style: f18w700,),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Container(
                                                      height: 100, width: 310,
                                                      child: ListView(
                                                        scrollDirection: Axis.horizontal,
                                                        children: List.generate(
                                                            number.length, (i) =>
                                                            Row(
                                                              children: [
                                                                TextButton(
                                                                    onPressed:() {setState(() {
                                                                      _answerList[index] = number[i];
                                                                    });},
                                                                    style: TextButton
                                                                        .styleFrom(
                                                                      shape: RoundedRectangleBorder(
                                                                          borderRadius: BorderRadius.circular(20)),
                                                                      side: BorderSide(width: 1, color: Colors.grey),
                                                                      minimumSize: Size(52, 52),
                                                                      backgroundColor: _answerList[index] == number[i] ? nowColor : Colors.white,
                                                                      padding: EdgeInsets.only(right: 12, left: 12),
                                                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                                    ),
                                                                    child: Text(
                                                                        '${i + 1}',
                                                                        style: _answerList[index] == number[i] ? f16Whitew700 : f16w700 )),
                                                                SizedBox(
                                                                  width: 10,
                                                                ),
                                                              ],
                                                            )),
                                                      )),
                                                ],
                                              ),
                                            );
                                      },
                                    ),
                                  ),
                              ],)
                            ],),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 30,
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
  // 임시저장일때 다시 저장하는 함수
  Future<void> _updateTestSave(String docId) async {
    final as = Get.put(AnswerState());
    DocumentReference ref =
    FirebaseFirestore.instance.collection('answer').doc(docId);
    ref.update({
      'pdfCategory': _testNameController.text,
      'password': _testPwController.text,
      'answer': as.answer.toList(),
      'pdfUploadName': as.pdfUploadName,
      'pdfUploadName2':as.pdfUploadName2
      // 'pdfUploadName':pickedFile?.name==null?args.pdfUploadName:pickedFile?.name,
    });
    if(isfilePath == '11'){
      final ref = FirebaseStorage.instance
          .ref()
          .child('12345')
          .child('${as.teacher}')
          .child('${docId}.pdf');
      UploadTask uploadTask = ref.putData(uploadfile,
        SettableMetadata(contentType: 'application/pdf'),
      );
      final snapshot = await uploadTask.whenComplete(() => null);
    }
    if(isfilePath2 =='11'){
      final firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('teacher')
          .child('audio')
          .child('${as.teacher}')
          .child('${docId}')
          .child('${docId}');
      final uploadTask2 = firebaseStorageRef.putData(
          uploadfile2!, SettableMetadata(contentType: 'audio/mpeg'));
      await ref.update({
        "audio": 'yes',
       });
    }
    else{
      await ref.update({
        "audio": 'no',
      });
    }
  }
  // 임시저장일때 저장버튼 누르면 -> 상태임시에서 완료로 바뀌는 함수
  Future<void> _updateUpload(String docId) async {
    final as = Get.put(AnswerState());
    DocumentReference ref =
    FirebaseFirestore.instance.collection('answer').doc(docId);
    ref.update({
      'pdfCategory': _testNameController.text,
      'password': _testPwController.text,
      'answer': as.answer.toList(),
      'pdfUploadName': as.pdfUploadName,
      'pdfUploadName2':as.pdfUploadName2,
      'scoreVisual':'${scoreVisual}',
      'state':'완료'
    });
    if(isfilePath == '11'){
      final ref = FirebaseStorage.instance
          .ref()
          .child('12345')
          .child('${as.teacher}')
          .child('${docId}.pdf');
      UploadTask uploadTask = ref.putData(uploadfile,
        SettableMetadata(contentType: 'application/pdf'),
      );
      final snapshot = await uploadTask.whenComplete(() => null);
    }
    if(isfilePath2 =='11'){
      final firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('teacher')
          .child('audio')
          .child('${as.teacher}')
          .child('${docId}')
          .child('${docId}');
      final uploadTask2 = firebaseStorageRef.putData(
          uploadfile2!, SettableMetadata(contentType: 'audio/mpeg'));
      await ref.update({
        "audio": 'yes',
      });
    }
    else{
      await ref.update({
        "audio": 'no',
      });
    }
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
