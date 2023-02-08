import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../../../components/tile/textform_field.dart';
import '../../../../firebase/firebase_answer.dart';
import '../../../../provider/answer_state.dart';
import '../../../../provider/user_state.dart';
import '../../../../util/colors.dart';
import '../../../../util/font.dart';

class PdfUploadScreen extends StatefulWidget {
  const PdfUploadScreen({Key? key}) : super(key: key);

  @override
  State<PdfUploadScreen> createState() => _PdfUploadScreenState();
}

class _PdfUploadScreenState extends State<PdfUploadScreen> {
  PlatformFile? pickedFile;
  UploadTask? uploadTask;
  TextEditingController _testNameController = TextEditingController();
  TextEditingController _testPwController = TextEditingController();
  TextEditingController _testCountController = TextEditingController();
  final _obscureText = false.obs;
  List _answerList = [];

  @override
  void initState() {
    super.initState();
    for (int i=0; i<20; i++) {
      _answerList.add('1');
    }
    _testCountController.text = '20';
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
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(
          icon: SvgPicture.asset(
            'assets/icon/back.svg',
            width: 7,
            height: 14,
          ),
          onPressed: () {
            Get.back();
          },
        ),
        centerTitle: false,
        title: Text(
          '문제 추가', style: f21w700grey5,
        ),
        actions: [
          GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                print('asd: ${pickedFile} , ${pickedFile?.name}');
                as.answer.clear();
                for (int i=0; i< _answerList.length; i++) {
                  as.answer.add(_answerList[i]);
                }
                as.group.value = '';
                as.password.value = _testPwController.text;
                as.pdfCategory.value = _testNameController.text;
                as.pdfName.value = '${DateTime.now()}';
                as.pdfUploadName.value = '${pickedFile?.name}';
                as.teacher.value = '12345'; //us.userList[0].name;
                as.path.value = pickedFile!.path!;
                await firebaseAnswerUpload(uploadTask);
                // await _uploadFile('12345', as.docId.value);

                Get.back();
              },
              child: Container(padding: const EdgeInsets.only(right: 28),
                child: const Center(child: Text('저장', style: f16w700primary,)),))
        ],
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Container(width: Get.width,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40,),
              Container(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('시험명', style: f18w400,)),
              const SizedBox(height: 10,),
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
                width: Get.width,
              ),
              const SizedBox(height: 16,),

              Container(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('문제 파일', style: f18w400,)),
              const SizedBox(height: 10,),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    pickedFile?.name != null
                        ? Container(
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                              color: textFormColor,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 18.5, horizontal: 20),
                            width: Get.width * 0.6,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: new EdgeInsets.only(right: 13.0),
                                    child: Text(
                                      '${pickedFile?.name}',
                                      style: f16w400el
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
                                    size: 20,
                                  ),
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
                            padding: const EdgeInsets.symmetric(vertical: 18.5, horizontal: 20),
                            width: Get.width * 0.6,
                            child: Text('시험 문제를 추가해 주세요', style: f16w400grey8,),
                          ),
                    SizedBox(width: 4,),
                    Container(
                      width: Get.width * 0.25,
                      child: ElevatedButton(
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              allowedExtensions: [
                                'pdf',
                                'png',
                                'jpg',
                                'jpeg',
                                'svg'
                              ],
                              type: FileType.custom,
                            );

                            if (result == null) return;

                            pickedFile = result.files.first;
                            setState(() {});
                          },
                          style: ButtonStyle(
                            shape:
                                MaterialStateProperty.all<RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            )),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.symmetric(vertical: 18.5, horizontal: 20)),
                            backgroundColor: MaterialStateProperty.all<Color>(
                                textFormColor),
                            splashFactory: NoSplash.splashFactory,
                            elevation: MaterialStateProperty.all<double>(0.0),
                          ),
                          child: Text('찾아보기', style: f16w700primary)),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16,),

              Container(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('문항수', style: f18w400,)),
              const SizedBox(height: 10,),
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
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          prefixIcon: InkWell(
                            onTap: () {
                              _answerList.removeLast();
                              setState(() {
                                // final x = _testCountController.text.obs;

                                ///_testCountController -
                                _testCountController.text =
                                    (_testCountController.text != '0' ?
                                    int.parse(_testCountController.text) - 1 : 0).toString();
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
                              child: Container(width: 40, height: Get.height*0.07,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
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
                                  setState(() {
                                    ///_testCountController +
                                    _testCountController.text = (int.parse(_testCountController.text) + 1).toString();
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
                              child: Container(height: Get.height*0.07,
                                padding: const EdgeInsets.symmetric(horizontal: 18),
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
                      )
                    ),
                    SizedBox(width: 4,),
                    Container(
                      width: Get.width * 0.25,
                      child: ElevatedButton(
                          onPressed: () async {
                            try {
                              if(int.tryParse(_testCountController.text) != null) {
                                if (int.parse(_testCountController.text) < _answerList.length) {
                                  _answerList.removeRange(int.parse(_testCountController.text), _answerList.length);
                                }
                                if (int.parse(_testCountController.text) > _answerList.length) {
                                  int diff= int.parse(_testCountController.text) - _answerList.length;
                                  for(int i=0; i< diff; i++){
                                    _answerList.add('1');
                                  }
                                }
                                setState(() {});
                              }
                            }catch(e){ print(e);}
                          },
                          style: ButtonStyle(
                            shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                )),
                            padding: MaterialStateProperty.all<EdgeInsets>(
                                EdgeInsets.symmetric(vertical: 18.5, horizontal: 20)),
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
              const SizedBox(height: 16,),

              Container(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('비밀번호', style: f18w400,)),
              const SizedBox(height: 10,),
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
              const SizedBox(height: 30,),

              const Divider(height: 1, color: cameraBackColor,),
              const SizedBox(height: 30,),

              Container(padding: EdgeInsets.symmetric(horizontal: 24), child: Text('답안', style: f18w400,)),
              const SizedBox(height: 10,),
              Container(padding: EdgeInsets.symmetric(horizontal: 24),
                child: ListView.builder(
                  itemCount: _answerList.length,
                  shrinkWrap: true,
                  physics: const ClampingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${index+1} :', style: f18w700,),
                            const SizedBox(width: 12,),
                            Container(
                              width: Get.width * 0.7,
                              padding: const EdgeInsets.symmetric(horizontal: 10.0),
                              decoration: BoxDecoration(
                                color: textFormColor,
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: Color(0xffE9E9E9), style: BorderStyle.solid, width: 0.80),
                              ),
                              child: DropdownButton<String>(
                                dropdownColor: textFormColor,
                                isExpanded: true,
                                value: _answerList[index],
                                icon: Icon(Icons.arrow_drop_down),
                                iconSize: 30,
                                elevation: 16,
                                hint: Text(
                                    '답안을 선택해 주세요',
                                    style: f18w400
                                ),
                                style: const TextStyle(color: Colors.black),
                                underline: Container(
                                  height: 10,
                                  color: Colors.transparent,
                                ),
                                onChanged: (newValue) {
                                  setState(() {
                                    _answerList[index] = newValue!;
                                  });
                                },
                                items: <String>['1', '2', '3', '4', '5'].map<DropdownMenuItem<String>>((String val) {
                                  // ignore: missing_required_param
                                  return DropdownMenuItem<String>(
                                    value: val,
                                    child: Text(
                                        val,
                                        style: f16w500
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10,),
                      ],
                    );
                  },),
              ),
              const SizedBox(height: 40,),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _uploadFile(String teacher, String docid) async {
    final file = File(pickedFile!.path!);
    print('2: ${docid}');
    final ref = FirebaseStorage.instance
        .ref()
        .child('12345')
        .child('${teacher}')
        .child('${docid}.pdf');
    print('3: ${docid}');
    uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() => null);
  }
}
