import 'dart:io';

import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/util/padding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../components/tile/textform_field.dart';
import '../../../../firebase/firebase_answer.dart';
import '../../../../model/answer.dart';
import '../../../../provider/answer_state.dart';
import '../../../../provider/user_state.dart';
import '../../../../util/colors.dart';
import '../../../../util/font.dart';
import '../../../../util/loading.dart';
import '../../../login/login_main_screen.dart';
import 'pdf_upload_individual_screen.dart';

class PdfIndMainScreen extends StatefulWidget {
  static final String id = '/pdf_ind_main';
  final String edit;
  final String category;
  final String password;
  final String docId;
  final List? answer;
  final List? body;
  final List? title;
  final List? image;

  const PdfIndMainScreen(
      {Key? key,
      this.edit: '',
      this.docId: '',
      this.answer,
      this.body,
      this.title,
      this.image,
      this.password: '',
      this.category: ''})
      : super(key: key);

  @override
  State<PdfIndMainScreen> createState() => _PdfIndMainScreenState();
}

class _PdfIndMainScreenState extends State<PdfIndMainScreen> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  TextEditingController _testNameController = TextEditingController();
  TextEditingController _testPwController = TextEditingController();
  TextEditingController _testCountController = TextEditingController();
  final _obscureText = false.obs;
  bool _imageLoading = false;
  List _answerList = [];

  @override
  void initState() {
    super.initState();
    final as = Get.put(AnswerState());
    as.essayList.value = [''];
    as.individualTitle.value = [''];
    as.individualBody.value = [''];
    as.individualFile.value = [''];
    as.individualFilePath.value = [''];
    as.choiceList.value = [''];
    // for (int i = 0; i < 20; i++) {
    //   _answerList.add('1');
    // }
    _answerList.add('1');
    _testCountController.text = '1';

    if (widget.edit == 'true') {
      _testPwController.text = widget.password;
      _testNameController.text = widget.category;
      _testCountController.text = '${widget.answer!.length}';
      _answerList = widget.answer!;
      as.individualFile.value = widget.image!;
      as.individualTitle.value = widget.title!;
      as.individualBody.value = widget.body!;
      as.essayList.value = List.generate(widget.answer!.length, (index) => '');
      as.choiceList.value = List.generate(widget.answer!.length, (index) => '');
      for(int i = 0; i < widget.answer!.length; i ++){
        if(isNumeric(widget.answer![i])&& widget.answer![i].length == 1){
          as.choiceList.value[i] = widget.answer![i];
        }else{
          as.essayList.value[i] = widget.answer![i];
        }
      }
      // as.essayList.value = widget.answer!;
      // print('file : ${as.essayList}');
      // for(int i = 0; i < widget.answer!.length; i++){
      //   _answerList.add('1');
      // }
    }
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
  }

  @override
  Widget build(BuildContext context) {
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              showComponentDialog(context, '작성을 취소하시겠습니까?', () {
                Get.back();
                Get.back();
              });
            },
          ),
          centerTitle: false,
          title: Text(
            '문제 추가(개별)',
            style: f21w700grey5,
          ),
          actions: [
            GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  print('asd: ${pickedFile} , ${pickedFile?.name}');
                  as.answer.clear();
                  for (int i = 0; i < _answerList.length; i++) {
                    if (as.essayList[i] != '') {
                      as.answer.add('${as.essayList[i]}');
                    } else {
                      as.answer.add(as.choiceList[i]);
                    }
                  }

                  as.group.value = '';
                  as.password.value = _testPwController.text;
                  as.pdfCategory.value = _testNameController.text;
                  as.pdfName.value = '${DateTime.now()}';
                  as.teacher.value = us.userList[0].id!;

                  showComponentDialog(context, widget.edit == 'true' ? '수정하시겠습니까?' : '업로드하시겠습니까?', () async {
                    Get.back();
                    if(widget.edit == 'true'){
                      await _update(widget.docId);
                     showConfirmTapDialog(context, '업로드를 완료했습니다', () {
                       Get.offAll(() => BottomNavigator());
                     });
                    }else{
                      await firebaseAnswerUploadIndividual(uploadTask);
                    }
                  });
                  // as.pdfUploadName.value = '${pickedFile?.name}';
                  // as.path.value = pickedFile!.path!;
                  // await _uploadFile('12345', as.docId.value);
                },
                child: Container(
                  padding: const EdgeInsets.only(right: 28),
                  child: const Center(
                      child: Text(
                    '저장',
                    style: f16w700primary,
                  )),
                ))
          ],
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            width: Get.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
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
                  width: Get.width,
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8.0)),
                            color: testCountColor,
                          ),
                          width: Get.width * 0.6,
                          child: TextFormField(
                            controller: _testCountController,
                            style: f16w400,
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              border: InputBorder.none,
                              prefixIcon: InkWell(
                                onTap: () {
                                  _answerList.removeLast();
                                  as.essayList.value.removeLast();
                                  as.individualTitle.value.removeLast();
                                  as.individualBody.value.removeLast();
                                  as.individualFile.value.removeLast();
                                  as.individualFilePath.value.removeLast();
                                  as.choiceList.value.removeLast();
                                  setState(() {
                                    // final x = _testCountController.text.obs;

                                    ///_testCountController -
                                    _testCountController.text =
                                        (_testCountController.text != '0'
                                                ? int.parse(_testCountController
                                                        .text) -
                                                    1
                                                : 0)
                                            .toString();
                                  });
                                },
                                child: Material(
                                  elevation: 0.0,
                                  color: textFormColor,
                                  shadowColor: textFormColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(8.0),
                                    bottomLeft: Radius.circular(8.0),
                                  ),
                                  child: Container(
                                    width: 40,
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 14),
                                    child: SvgPicture.asset(
                                      'assets/icon/minus.svg',
                                      height: 20,
                                      width: 20,
                                      color: teacherColor,
                                    ),
                                  ),
                                ),
                              ),
                              suffixIcon: InkWell(
                                onTap: () {
                                  _answerList.add('1');
                                  as.essayList.value.add('');
                                  as.individualTitle.value.add('');
                                  as.individualBody.value.add('');
                                  as.individualFile.value.add('');
                                  as.individualFilePath.value.add('');
                                  as.choiceList.value.add('');
                                  setState(() {
                                    ///_testCountController +
                                    _testCountController.text =
                                        (int.parse(_testCountController.text) +
                                                1)
                                            .toString();
                                  });
                                },
                                child: Material(
                                  elevation: 0.0,
                                  color: textFormColor,
                                  shadowColor: textFormColor,
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(8.0),
                                    bottomRight: Radius.circular(8.0),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 18, vertical: 14),
                                    child: SvgPicture.asset(
                                      'assets/icon/plus.svg',
                                      height: 20,
                                      width: 20,
                                      color: teacherColor,
                                    ),
                                  ),
                                ),
                              ),
                              hintText: '20',
                              hintStyle: f16w400grey8,
                            ),
                          )),
                      SizedBox(
                        width: 4,
                      ),
                      Container(
                        width: Get.width * 0.25,
                        child: ElevatedButton(
                            onPressed: () async {
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
                                      as.individualBody.value.add('');
                                      as.individualFile.value.add('');
                                      as.individualFilePath.value.add('');
                                      as.choiceList.value.add('');
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
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  textFormColor),
                              splashFactory: NoSplash.splashFactory,
                              elevation: MaterialStateProperty.all<double>(0.0),
                            ),
                            child: Text('확인', style: f16w700primary)),
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
                            print('as list : ${as.essayList}');
                            Get.to(() => PdfUploadIndividualScreen(
                                      idx: idx,
                                    ))!
                                .then((value) {
                              setState(() {});
                            });
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '문항 ${idx + 1}.',
                                style: f18w700,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              Text(
                                as.individualFile[idx] != ''
                                    ? '제목(파일첨부)'
                                    : '제목',
                                style: f18w400,
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
                                  style: f16w400,
                                ),
                              ),
                              const SizedBox(
                                height: 16,
                              ),
                              Row(
                                children: [
                                  Text(
                                    '답안 :',
                                    style: f18w400,
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
                                    style: f18w700,
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
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Future<void> _uploadFile(String teacher, String docid) async {
  //   final file = File(pickedFile!.path!);
  //   print('2: ${docid}');
  //   final ref = FirebaseStorage.instance
  //       .ref()
  //       .child('12345')
  //       .child('${teacher}')
  //       .child('${docid}.pdf');
  //   print('3: ${docid}');
  //   uploadTask = ref.putFile(file);
  //   final snapshot = await uploadTask!.whenComplete(() => null);
  // }

  Future<void> _update(String docId)async{
    final as = Get.put(AnswerState());
    DocumentReference ref = FirebaseFirestore.instance.collection('answer').doc(docId);
    ref.update({
      'password' : _testPwController.text,
      'pdfCategory' : _testNameController.text,
      'answer' : as.answer.toList(),
      'individualBody': as.individualBody,
      'individualTitle': as.individualTitle,
    });

  }

  Future<void> firebaseAnswerUploadIndividual(UploadTask? uploadTask) async {
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());

    CollectionReference ref = FirebaseFirestore.instance.collection('answer');
    Answer ass = Answer(
        isIndividual: 'true',
        individualBody: as.individualBody,
        individualTitle: as.individualTitle,
        individualFile: [],
        createDate: '${DateTime.now()}',
        answer: as.answer.toList(),
        answerCount: '',
        docId: '',
        group: '',
        password: '${as.password}',
        pdfCategory: '${as.pdfCategory}',
        pdfName: '${as.pdfName}',
        pdfUploadName: '${as.pdfUploadName}',
        state: '대기',
        teacher: '${as.teacher}',
        temp1: '',
        temp2: '');
    ref.add(ass.toMap()).then((doc) async {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('answer').doc(doc.id);
      as.docId.value = doc.id;
      as.individualFile.removeWhere((item) => item == '');
      as.individualFilePath.removeWhere((item) => item == '');
      await userDocRef.update({'docId': '${doc.id}'});
      if (as.individualFile.length != 0) {
        await _uploadFile(doc.id, '${us.userList[0].id}');
        showConfirmTapDialog(context, '업로드를 완료했습니다', () {
          Get.offAll(() => BottomNavigator());
        });
      } else {
        showConfirmTapDialog(context, '업로드를 완료했습니다', () {
          Get.offAll(() => BottomNavigator());
        });
      }
    });
  }

  Future _uploadFile(String docId, String phoneNumber) async {
    final as = Get.put(AnswerState());
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
    for (int i = 0; i < as.individualFile.length; i++) {
      final firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('teacher')
          .child('$phoneNumber')
          .child('$docId')
          .child('${DateTime.now()}');
      final uploadTask = firebaseStorageRef.putFile(
          File(as.individualFilePath[i]),
          SettableMetadata(contentType: 'image/png'));
      await uploadTask;
    }
    final pathReference = FirebaseStorage.instance
        .ref()
        .child('teacher')
        .child('$phoneNumber')
        .child(docId);
    ListResult nestedResult = await pathReference.listAll();
    nestedResult.items.forEach((element) async {
      await userDocRef.update({
        "images": FieldValue.arrayUnion(['${element.name}'])
      });
    });

    setState(() {
      _imageLoading = false;
      Navigator.pop(context);
    });
  }
}
