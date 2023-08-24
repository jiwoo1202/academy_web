import 'package:academy/util/padding.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../../../components/footer/footer.dart';
import '../../../../provider/answer_state.dart';
import '../../../../provider/user_state.dart';
import '../../../../util/colors.dart';
import '../../../../util/font/font.dart';
import '../../../../util/font/font.dart';

class PdfUploadIndividualScreen extends StatefulWidget {
  static final String id = '/pdfUploadIndividualScreen';

  final int idx;
  final String edit;

  const PdfUploadIndividualScreen({
    Key? key,
    this.idx: 0,
    this.edit: '',
  }) : super(key: key);

  @override
  State<PdfUploadIndividualScreen> createState() =>
      _PdfUploadIndividualScreenState();
}

class _PdfUploadIndividualScreenState extends State<PdfUploadIndividualScreen> {
  PlatformFile? pickedFile;
  PlatformFile? pickedFile2;
  UploadTask? uploadTask;
  // AudioPlayer _player = AudioPlayer();
  TextEditingController _testNameController = TextEditingController();
  TextEditingController _testBodyCon = TextEditingController();
  TextEditingController _testEssayCon = TextEditingController();
  String _answer = '0';
  String _fileName = '';
  String _fileName2 = '';
  List _answerList = [];
  bool _isPlaying = false;
  bool firstTrue = false;
  bool secondTrue = false;
  bool titleTrue = false;
  bool contentTrue = false;
  List<String> number = ['1', '2', '3', '4', '5'];

  // List<String> _answer = ['', '', '','',''];

  @override
  void initState() {
    Future.delayed(Duration.zero,(){
      final as = Get.put(AnswerState());
      final args = ModalRoute.of(context)!.settings.arguments as PdfUploadIndividualScreen?;
      // _player = AudioPlayer()..setSourceAsset('assets/audio/waterfall.mp3');

      if (as.essayList.value[args!.idx] != '') {
        firstTrue = true;
        _testEssayCon.text = as.essayList[args.idx];
      }

      if (as.essayList.value[args.idx] == '서술형') {
        secondTrue = true;
        _testEssayCon.text = '';
      }

      if (as.individualTitle.value[args.idx] != '') {
        _testNameController.text = as.individualTitle.value[args.idx];
      }

      if (as.individualBody.value[args.idx] != '') {
        _testBodyCon.text = as.individualBody.value[args.idx];
      }

      if (as.choiceList.value[args.idx] != '') {
        _answer = as.choiceList.value[args.idx];
      }

      if (as.individualFile.value[args.idx] != '') {
        _fileName = as.individualFile.value[args.idx];
      }

      if (as.individualFile2.value[args.idx] != '') {
        _fileName2 = as.individualFile2.value[args.idx];
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
    // _player.dispose();
    _testBodyCon.dispose();
    _testEssayCon.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());
    final args = ModalRoute.of(context)!.settings.arguments as PdfUploadIndividualScreen?;
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: nowColor,
          elevation: 0,
          automaticallyImplyLeading: false,
          // leading: IconButton(
          //   icon: Icon(
          //     Icons.arrow_back_ios_new,
          //     color: Color(0xff6f7072),
          //   ),
          //   onPressed: () {
          //     as.individualTitle.value[widget.idx] = _testNameController.text;
          //     as.individualBody.value[widget.idx] = _testBodyCon.text;
          //     if (_testEssayCon.text == '' && firstTrue == true) {
          //       as.essayList.value[widget.idx] = '서술형';
          //     } else {
          //       as.essayList.value[widget.idx] = _testEssayCon.text;
          //     }
          //     if (firstTrue) {
          //       as.choiceList.value[widget.idx] = '';
          //     }
          //     Get.back();
          //   },
          // ),
          centerTitle: false,
          actions: [
            GestureDetector(
              onTap: () {
                as.individualTitle.value[args!.idx] = _testNameController.text;
                as.individualBody.value[args.idx] = _testBodyCon.text;
                // if(_testEssayCon.text!=''){
                //   as.tmpidx.add(widget.idx);
                // }
                // else if(_testEssayCon.text ==''){
                //   as.tmpidx.remove(widget.idx);
                // }

                if (_testEssayCon.text == '' && firstTrue == true) {
                  as.essayList.value[args.idx] = '서술형';
                } else {
                  as.essayList.value[args.idx] = _testEssayCon.text;
                  as.tmpidx.value[args.idx] = _testEssayCon.text;

                }
                if (firstTrue) {
                  as.choiceList.value[args.idx] = '';
                }
                Get.back();
              },
              child: Container(
                padding: const EdgeInsets.only(right: 28),
                child: const Center(
                    child: Text(
                  '저장',
                  style: f16Whitew700,
                )),
              ),
            )
          ],

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
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Container(
            padding: GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                ? EdgeInsets.symmetric(horizontal: 24)
                : EdgeInsets.symmetric(horizontal: Get.width * 0.24),
            width: Get.width,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text(
                      '주관식 문제로 변경',
                      style: (kIsWeb && (Get.width * 0.2 <= 171))
                          ? f12w400
                          : f18w400,
                    ),
                    Spacer(),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        firstTrue = !firstTrue;
                        _testEssayCon.text = '';

                        setState(() {});
                      },
                      child: SvgPicture.asset(firstTrue
                          ? 'assets/checkBox.svg'
                          : 'assets/notcheckBox.svg'),
                    )
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                // Container(
                //   padding: EdgeInsets.symmetric(horizontal: 24),
                //   child: Row(
                //     children: [
                //       // Spacer(),
                //       // GestureDetector(
                //       //   behavior: HitTestBehavior.opaque,
                //       //   onTap: () {
                //       //     setState(() {
                //       //       titleTrue = !titleTrue;
                //       //     });
                //       //   },
                //       //   child: SvgPicture.asset(titleTrue
                //       //       ? 'assets/checkBox.svg'
                //       //       : 'assets/notcheckBox.svg'),
                //       // )
                //     ],
                //   ),
                // ),
                Text(
                  '문제 제목',
                  style:
                      (kIsWeb && (Get.width * 0.2 <= 171)) ? f12w400 : f18w400,
                ),
                const SizedBox(
                  height: 20,
                ),

                TextFormField(
                  controller: _testNameController,
                  minLines: 1,
                  maxLines: 10,
                  maxLength: 80,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Color(0xffEBEBEB),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8)),
                    hintText: '내용을 입력해주세요',
                    hintStyle: (kIsWeb && (Get.width * 0.2 <= 171))
                        ? f12w400grey8
                        : f16w400grey8,
                  ),
                ),

                const SizedBox(
                  height: 20,
                ),
                Text(
                  '내용',
                  style:
                      (kIsWeb && (Get.width * 0.2 <= 171)) ? f12w400 : f18w400,
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _testBodyCon,
                  maxLines: null,
                  decoration: InputDecoration(
                    isDense: true,
                    filled: true,
                    fillColor: Color(0xffEBEBEB),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8)),
                    hintText: '내용을 입력해주세요',
                    hintStyle: (kIsWeb && (Get.width * 0.2 <= 171))
                        ? f12w400grey8
                        : f16w400grey8,
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  '문제 파일',
                  style:
                      (kIsWeb && (Get.width * 0.2 <= 171)) ? f12w400 : f18w400,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    pickedFile?.name != null || _fileName != ''
                        ? Container(
                            height:
                                (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
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
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Container(
                                    padding: new EdgeInsets.only(right: 13.0),
                                    child: args?.edit=='true'
                                        ? Text('${as.pdfUploadName[args!.idx]}')
                                        : Text('파일이 첨부돼있습니다',
                                        style: (kIsWeb && (Get.width * 0.2 <= 171))
                                                ? f12w500
                                                : f16w500),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    pickedFile = null;
                                    _fileName = '';
                                    as.individualFile.value[args!.idx] = '';
                                    as.pdfUploadName.value[args.idx] = '';
                                    if (args.edit == 'true') {
                                      as.editIndividualImage.value[args.idx] = 'no';
                                    } else {
                                      as.individualFilePath.value[args.idx] = '';
                                    }
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
                            height:
                                (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
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
                            child: Center(
                              child: Text(
                                (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? '문제를 추가해주세요'
                                    : '시험 문제를 추가해 주세요',
                                style: (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? f12w400greyAel
                                    : f16w400grey8,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                    SizedBox(
                      width: 4,
                    ),
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
                            pickedFile = result.files.first;

                            if (args?.edit == 'true') {
                              as.editIndividualImage.value[args!.idx] =
                                  result.files.single.bytes;
                              as.pdfUploadName.value[args.idx] =
                                  pickedFile!.name;
                              as.individualFile.value[args.idx] = 'yes';
                              as.indEditList.value[args.idx] = 'edit';

                            } else {
                              as.individualFile.value[args!.idx] = 'yes';
                              as.individualFilePath.value[args.idx] =
                                  result.files.single.bytes;
                              as.pdfUploadName[args.idx] = pickedFile!.name;
                            }
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
                          child: Text('찾아보기',
                              style: (kIsWeb && (Get.width * 0.2 <= 171))
                                  ? f12w700primary
                                  : f16w700primary)),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Text(
                  '듣기 파일',
                  style:
                      (kIsWeb && (Get.width * 0.2 <= 171)) ? f12w400 : f18w400,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Container(
                      height: (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                        color: textFormColor,
                      ),
                      padding: (kIsWeb && (Get.width * 0.2 <= 171))
                          ? EdgeInsets.zero
                          : const EdgeInsets.symmetric(
                              vertical: 0, horizontal: 12),
                      width: (kIsWeb && (Get.width * 0.2 <= 171))
                          ? Get.width * 0.4
                          : Get.width * 0.3,
                      child: pickedFile2 == null && _fileName2 == ''
                          ? Center(
                              child: Text(
                                (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? '파일을 추가해주세요'
                                    : args?.edit=='true'
                                    ? '${as.pdfUploadName2[args!.idx]}'
                                    : '듣기 파일을 추가해 주세요',
                                style: (kIsWeb && (Get.width * 0.2 <= 171))
                                    ? f12w400greyAel
                                    : f16w400grey8,
                                textAlign: TextAlign.center,
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${as.pdfUploadName2[args!.idx]}',
                                  style: (kIsWeb && (Get.width * 0.2 <= 171))
                                      ? f12w500
                                      : f16w500,
                                  textAlign: TextAlign.center,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    pickedFile2 = null;
                                    _fileName2 = '';
                                    as.pdfUploadName2.value[args!.idx] = '';
                                    if (args.edit == 'true') {

                                      as.editIndividualAudio.value[args.idx] =
                                      'no';
                                    }
                                    as.individualFile2.value[args.idx] = '';
                                    as.individualFilePath2.value[args.idx] = '';
                                    setState(() {});
                                  },
                                  child: Icon(
                                    Icons.close,
                                    size: 20,
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
                          onPressed: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.audio,
                            );
                            if (result == null) return;
                            // as.hasFile.value = true;
                            pickedFile2 = result.files.first;
                            _fileName2 = pickedFile2!.name;
                            if (args?.edit == 'true') {
                              as.editIndividualAudio.value[args!.idx] =
                                  result.files.single.bytes;
                              as.indEditList2.value[args.idx] = 'edit';
                              as.pdfUploadName2.value[args.idx] =
                                  pickedFile2!.name;

                            } else {
                              as.individualFile2.value[args!.idx] = 'yes';
                              as.individualFilePath2.value[args.idx] =
                                  result.files.single.bytes;
                              as.pdfUploadName2[args.idx] = pickedFile2?.name;

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
                    // SizedBox(
                    //   width: 4,
                    // ),
                    // Container(
                    //   height: (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
                    //   child: ElevatedButton(
                    //       onPressed: () async {
                    //         await _player.setSourceUrl(
                    //             'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/audio%2Fwaterfall.mp3?alt=media');
                    //         // _player.play(AssetSource('assets/audio/waterfall.mp3'));
                    //         _player.pause();
                    //         _player.onPlayerStateChanged.listen(
                    //             (PlayerState s) =>
                    //                 {print('Current player state: $s')});
                    //       },
                    //       style: ButtonStyle(
                    //         shape: MaterialStateProperty.all<
                    //             RoundedRectangleBorder>(RoundedRectangleBorder(
                    //           borderRadius: BorderRadius.circular(8.0),
                    //         )),
                    //         padding: MaterialStateProperty.all<EdgeInsets>(
                    //             EdgeInsets.symmetric(
                    //                 vertical: 14, horizontal: 20)),
                    //         backgroundColor:
                    //             MaterialStateProperty.all<Color>(textFormColor),
                    //         splashFactory: NoSplash.splashFactory,
                    //         elevation: MaterialStateProperty.all<double>(0.0),
                    //       ),
                    //       child: Text('정지',
                    //           style: (kIsWeb && (Get.width * 0.2 <= 171))
                    //               ? f12w700primary
                    //               : f16w700primary)),
                    // ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    Text(
                      '답안',
                      style: (kIsWeb && (Get.width * 0.2 <= 171))
                          ? f12w400
                          : f18w400,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                firstTrue
                    ? TextFormField(
                        controller: _testEssayCon,
                        maxLines: null,
                        enabled: !secondTrue,
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
                              secondTrue ? '서술형은 입력할 수 없습니다' : '답을 입력해주세요',
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
                                                as.choiceList
                                                        .value[args!.idx] =
                                                    '${i + 1}';
                                                _answer = '${i + 1}';
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
                                                backgroundColor:
                                                    _answer == number[i]
                                                        ? nowColor
                                                        : Colors.white,
                                                padding: EdgeInsets.only(
                                                    right: 12, left: 12),
                                                tapTargetSize:
                                                    MaterialTapTargetSize
                                                        .shrinkWrap,
                                              ),
                                              child: Text('${i + 1}',
                                                  style: _answer == number[i]
                                                      ? f16Whitew700
                                                      : f16w700)),
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
                const Divider(
                  height: 1,
                  color: cameraBackColor,
                ),
                const SizedBox(
                  height: 40,
                ),

                Footer(),
                SizedBox(
                  height: 40,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> _useBackKey(BuildContext context) async {
    final as = Get.put(AnswerState());

    as.individualTitle.value[widget.idx] = _testNameController.text;
    as.individualBody.value[widget.idx] = _testBodyCon.text;
    if (_testEssayCon.text == '' && firstTrue == true) {
      as.essayList.value[widget.idx] = '서술형';
    } else {
      as.essayList.value[widget.idx] = _testEssayCon.text;
    }

    if (firstTrue) {
      as.choiceList.value[widget.idx] = '';
    }
    Get.back();

    return false;
  }
}
