import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/components/footer/footer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show Uint8List, kIsWeb;
import '../../../../../components/switch/switch_button.dart';
import '../../../../../components/tile/textform_field.dart';
import '../../../../../provider/user_state.dart';
import '../../../../../util/colors.dart';
import '../../../../../util/font/font.dart';
import '../../../../../util/loading.dart';
import '../../../firebase/firebase_sat.dart';
import '../../../provider/sat_state.dart';
import 'package:http/http.dart' as http;

class SatUploadScreen extends StatefulWidget {
  final String edit;
  static final String id = '/sat_upload';

  const SatUploadScreen({Key? key, this.edit = '',}) : super(key: key);

  @override
  State<SatUploadScreen> createState() => _SatUploadScreenState();
}

class _SatUploadScreenState extends State<SatUploadScreen> {
  List<String> pickedFiles = [''];
  List<String> pickedFiles2 = [''];
  TextEditingController _testNameController = TextEditingController();
  TextEditingController _testPwController = TextEditingController();
  TextEditingController _testCountController = TextEditingController();
  TextEditingController _testCountController2 = TextEditingController();
  TextEditingController _countCountController = TextEditingController();
  ScrollController _controller = ScrollController(); //
  bool _obscureText = false;
  List<String> number = ['1', '2', '3', '4', '5']; //원형 숫자 만들기
  List<String> number2 = ['A', 'B', 'C', 'D']; //sat용 넘버 만들기

  List<TextEditingController> _scoreController = [TextEditingController()];
  List<TextEditingController> _scoreController2 = [TextEditingController()];
  List _englishScoreList = [];
  List _mathScoreList = [];

  ///1
  List<TextEditingController> _testBodyCon = [TextEditingController()]; //내용
  List<TextEditingController> _testTiCon = [TextEditingController()]; //문제제목
  List<TextEditingController> _testAnswerA = [TextEditingController()];
  List<TextEditingController> _testAnswerB = [TextEditingController()];
  List<TextEditingController> _testAnswerC = [TextEditingController()];
  List<TextEditingController> _testAnswerD = [TextEditingController()];
  List _checkAnswer = [];
  List _imageList = [];
  List _titleTextList = [];
  List _bodyTextList = [];

  ///2
  List<TextEditingController> _testBodyCon2 = [TextEditingController()]; //내용
  List<TextEditingController> _testTiCon2 = [TextEditingController()]; //문제제목
  List<TextEditingController> _testAnswerA2 = [TextEditingController()];
  List<TextEditingController> _testAnswerB2 = [TextEditingController()];
  List<TextEditingController> _testAnswerC2 = [TextEditingController()];
  List<TextEditingController> _testAnswerD2 = [TextEditingController()];
  List _checkAnswer2 = [];
  List _imageList2 = [];
  List _titleTextList2 = [];
  List _bodyTextList2 = [];

  ///3
  List _checkAnswer3 = [];
  List _imageList3 = [];
  List<String> pickedFiles3 = [''];
  List<TextEditingController> _testEssayCon = [TextEditingController()];
  List<bool> firstTrue = [];

  /// 4
  List _checkAnswer4 = [];
  List _imageList4 = [];
  List<String> pickedFiles4 = [''];
  List<TextEditingController> _testEssayCon2 = [TextEditingController()];
  List<bool> firstTrue2 = [];

  List _blankList = [];
  List<int> textLength = [0];
  List<int> textLength2 = [0];
  int _moduleIdx = 0;

  bool scoreVisual = false;
  bool mathOn = false;
  bool _isLoading = true;
  bool _isdoNotEdit = false;
  bool _editing = false;

  /// scroll

  @override
  void initState() {
    _testBodyCon = List.generate(27, (i) => TextEditingController());
    _testTiCon = List.generate(27, (i) => TextEditingController());
    _testAnswerA = List.generate(27, (i) => TextEditingController());
    _testAnswerB = List.generate(27, (i) => TextEditingController());
    _testAnswerC = List.generate(27, (i) => TextEditingController());
    _testAnswerD = List.generate(27, (i) => TextEditingController());
    _checkAnswer = List.generate(27, (i) => '');
    _bodyTextList = List.generate(27, (i) => '');
    _imageList = List.generate(27, (i) => '');
    pickedFiles = List.generate(27, (i) => '');
    _titleTextList = List.generate(27, (i) => '');

    _testBodyCon2 = List.generate(27, (i) => TextEditingController());
    _testTiCon2 = List.generate(27, (i) => TextEditingController());
    _testAnswerA2 = List.generate(27, (i) => TextEditingController());
    _testAnswerB2 = List.generate(27, (i) => TextEditingController());
    _testAnswerC2 = List.generate(27, (i) => TextEditingController());
    _testAnswerD2 = List.generate(27, (i) => TextEditingController());
    _checkAnswer2 = List.generate(27, (i) => '');
    _bodyTextList2 = List.generate(27, (i) => '');
    _imageList2 = List.generate(27, (i) => '');
    pickedFiles2 = List.generate(27, (i) => '');
    _titleTextList2 = List.generate(27, (i) => '');

    _blankList = List.generate(44, (i) => '');

    _checkAnswer3 = List.generate(22, (i) => '');
    _imageList3 = List.generate(22, (i) => '');
    pickedFiles3 = List.generate(22, (i) => '');
    _testEssayCon = List.generate(22, (i) => TextEditingController());
    firstTrue = List.generate(22, (i) => false);

    _checkAnswer4 = List.generate(22, (i) => '');
    _imageList4 = List.generate(22, (i) => '');
    pickedFiles4 = List.generate(22, (i) => '');
    _testEssayCon2 = List.generate(22, (i) => TextEditingController());
    firstTrue2 = List.generate(22, (i) => false);

    _scoreController = List.generate(55, (i) => TextEditingController());
    _scoreController2 = List.generate(55, (i) => TextEditingController());

    _englishScoreList = List.generate(55, (i) => '');
    _mathScoreList = List.generate(55, (i) => '');

    Future.delayed(Duration.zero, () async {
      final args = ModalRoute.of(context)!.settings.arguments as SatUploadScreen?;
      final st = Get.put(SatState());
      if (args?.edit == 'true') {
        await firebaseSatGet();
        _scoreController[54].text = st.individualSatGet[0]['englishScore'][54];
        _scoreController2[54].text = st.individualSatGet[0]['mathScore'][54];
        _englishScoreList = st.individualSatGet[0]['englishScore'];
        _mathScoreList = st.individualSatGet[0]['mathScore'];
        _isdoNotEdit = st.individualSatGet[0]['status'] == '1';
        _editing = true;
        mathOn = st.individualSatGet[0]['math'] == 'true' ? true : false;
        _testPwController.text = st.individualSatGet[0]['pw'];
        _testNameController.text = st.individualSatGet[0]['mainTitle'];

        //1 =>27개
        _checkAnswer = List.generate(27, (i) => st.individualSatGet[0]['answer'][i]);
        _titleTextList = List.generate(27, (i) => st.individualSatGet[0]['title'][i]);
        _bodyTextList = List.generate(27, (i) => st.individualSatGet[0]['body'][i]);
        pickedFiles = List.generate(27, (i) => st.individualSatGet[0]['image'][i]);

        //28 =>27개
        _checkAnswer2 = List.generate(27, (i) => st.individualSatGet[0]['answer'][i+27]);
        _titleTextList2 = List.generate(27, (i) => st.individualSatGet[0]['title'][i+27]);
        _bodyTextList2 = List.generate(27, (i) => st.individualSatGet[0]['body'][i+27]);
        pickedFiles2 = List.generate(27, (i) => st.individualSatGet[0]['image'][i+27]);

        _imageList = [];
        _imageList2 = [];
        for(int i=0; i<27; i++) {
          _scoreController[i].text = st.individualSatGet[0]['englishScore'][i];
          _scoreController2[i].text = st.individualSatGet[0]['mathScore'][i];
          _scoreController[i+27].text = st.individualSatGet[0]['englishScore'][i+27];
          _scoreController2[i+27].text = st.individualSatGet[0]['mathScore'][i+27];
          _testTiCon[i].text = st.individualSatGet[0]['title'][i];
          _testBodyCon[i].text = st.individualSatGet[0]['body'][i];
          _testTiCon2[i].text = st.individualSatGet[0]['title'][i+27];
          _testBodyCon2[i].text = st.individualSatGet[0]['body'][i+27];

          if(pickedFiles[i] == '') {
            _imageList.add('');
          } else {
            Uint8List? imageData = await getImageDataFromUrl('https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/sat%2F'
                '${st.individualSatGet[0]['docId']}%2F${i}.png?alt=media');
            _imageList.add(imageData);
          }

          if(pickedFiles2[i] == '') {
            _imageList2.add('');
          } else {
            Uint8List? imageData = await getImageDataFromUrl('https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/sat%2F'
                '${st.individualSatGet[0]['docId']}%2F${i+27}.png?alt=media');
            _imageList2.add(imageData);
          }
        }
      /// 수학일때
        if(mathOn) {
          _imageList3 = [];
          _imageList4 = [];
          for(int i=0; i<22; i++) {
            //55 =>22개
            _checkAnswer3[i] = st.individualSatGet[0]['answer'][i+54];
            pickedFiles3[i] = st.individualSatGet[0]['image'][i+54];
            if(_checkAnswer3[i] == 'a' || _checkAnswer3[i] == 'b' || _checkAnswer3[i] == 'c' || _checkAnswer3[i] == 'd'){
              firstTrue[i] = false;
            } else {
              firstTrue[i] = true;
              _testEssayCon[i].text = st.individualSatGet[0]['answer'][i+54];
            }

            if(pickedFiles3[i] == '') {
              _imageList3.add('');
            } else {
              Uint8List? imageData = await getImageDataFromUrl('https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/sat%2F'
                  '${st.individualSatGet[0]['docId']}%2F${i+54}.png?alt=media');
              _imageList3.add(imageData);
            }

            //77 =>22개
            _checkAnswer4[i] = st.individualSatGet[0]['answer'][i+76];
            pickedFiles4[i] = st.individualSatGet[0]['image'][i+76];
            if(_checkAnswer4[i] == 'a' || _checkAnswer4[i] == 'b' || _checkAnswer4[i] == 'c' || _checkAnswer4[i] == 'd'){
              firstTrue2[i] = false;
            } else {
              firstTrue2[i] = true;
              _testEssayCon2[i].text = st.individualSatGet[0]['answer'][i+76];
            }

            if(pickedFiles4[i] == '') {
              _imageList4.add('');
            } else {
              Uint8List? imageData = await getImageDataFromUrl('https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/sat%2F'
                  '${st.individualSatGet[0]['docId']}%2F${i+76}.png?alt=media');
              _imageList4.add(imageData);
            }
          }
        }
      }
      setState(() { _isLoading = false;});
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
    _countCountController.dispose();
    _testBodyCon.clear();
    _testTiCon.clear();
    _testAnswerA.clear();
    _testAnswerB.clear();
    _testAnswerC.clear();
    _testAnswerD.clear();

    _testBodyCon2.clear();
    _testTiCon2.clear();
    _testAnswerA2.clear();
    _testAnswerB2.clear();
    _testAnswerC2.clear();
    _testAnswerD2.clear();
  }

  @override
  Widget build(BuildContext context) {
    final st = Get.put(SatState());
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: WillPopScope(
        onWillPop: () {
          return Future(() {
            _useBackKey(context);
            return true;
          });
        },
        child: Scaffold(
          backgroundColor: backColor,
          appBar: AppBar(
            backgroundColor: nowColor,
            elevation: 0,
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
                kIsWeb && (Get.width * 0.2 <= 171) ? Container() : _editing ? Text('SAT 문제 수정') : Text('SAT 문제 추가')
              ],
            ),
          ),
          body: _isLoading ? LoadingBodyScreen() :
          SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 100),
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
                            Row(
                              children: [
                                Text(
                                  _editing ? '문제수정 - SAT' : '문제추가 - SAT',
                                  style: f32w700,
                                ),
                                Spacer(),
                                GestureDetector(
                                  onTap: () {
                                    showComponentDialog(context, '문제${_editing ? '수정을' : '추가를'} 종료할까요? ', () {
                                      Get.back();
                                      Get.back();
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                        child: Text(
                                      '나가기',
                                      style: f16w700,
                                    )),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xff535353),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                GestureDetector(
                                  onTap: _isdoNotEdit ? () {} : () {
                                    showComponentDialog(context, '임시 저장하시겠습니까?', () async {
                                      Get.back();
                                      for (int i = 0; i < 22; i++) {
                                        if (firstTrue[i] == true) {
                                          _checkAnswer3[i] = _testEssayCon[i].text.toString();
                                        }
                                        if (firstTrue2[i] == true) {
                                          _checkAnswer4[i] = _testEssayCon2[i].text.toString();
                                        }
                                      }
                                      final args = ModalRoute.of(context)!.settings.arguments as SatUploadScreen?;
                                      if(args?.edit == 'true') {
                                        await _firebaseTemporary(st.individualSatGet[0]['docId']);
                                      } else {
                                        await _firebaseUpload('0');
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                        child: Text(
                                      '임시저장',
                                      style: f16w700,
                                    )),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                        color: const Color(0xff535353),
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 12,
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    showComponentDialog(context, '저장하시겠습니까?', () async {
                                      Get.back();
                                      int blankCheck = 0;
                                      if(_checkAnswer.contains('') || _checkAnswer2.contains('') || _englishScoreList.contains('')) {
                                        blankCheck = 1;
                                      }
                                      for (int i = 0; i < 22; i++) {
                                        if (firstTrue[i] == true) {
                                          _checkAnswer3[i] = _testEssayCon[i].text.toString();
                                        }
                                        if (firstTrue2[i] == true) {
                                          _checkAnswer4[i] = _testEssayCon2[i].text.toString();
                                        }
                                        if (mathOn == true && (pickedFiles3[i] == '' || pickedFiles4[i] == '' || _mathScoreList.contains(''))) {
                                          blankCheck = 1;
                                        }
                                      }
                                      if (blankCheck == 0) {
                                        final args = ModalRoute.of(context)!.settings.arguments as SatUploadScreen?;
                                        if(args?.edit == 'true') {
                                          if(_isdoNotEdit) {
                                            await _firebaseUpdate(st.individualSatGet[0]['docId']);
                                          }
                                          else {
                                            await _firebaseTemporary(st.individualSatGet[0]['docId']);
                                            await _firebaseUp(st.individualSatGet[0]['docId']);
                                          }
                                        } else {
                                          await _firebaseUpload('1');
                                        }
                                      } else {
                                        showOnlyConfirmDialog(context, '없는 파일을 확인해주세요');
                                      }
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Center(
                                        child: Text(
                                      '저장',
                                      style: f16Whitew700,
                                    )),
                                    decoration: BoxDecoration(
                                      color: const Color(0xff070707),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            Container(
                              width: Get.width,
                              child: TextFormFields(
                                controller: _testNameController,
                                hintText: '시험 명을 입력해주세요',
                                surffixIcon: '0',
                                obscureText: true,

                              ),
                            ),
                            const SizedBox(height: 8,),
                            Align(alignment: Alignment.centerRight,child: Text('주관식 중복 답안 입력 시 \'/\'를 넣어주세요', style: f16w500,)),
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
                              height: 20,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: Get.width * 0.3,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '문항 수',
                                            style: f18w400,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                '(수학 포함 시 체크)',
                                                style: f18w400,
                                              ),
                                              SizedBox(
                                                width: 16,
                                              ),
                                              SwitchButton(
                                                onTap: _isdoNotEdit ? () {} : () {
                                                  mathOn = !mathOn;
                                                  if (!mathOn && _moduleIdx > 1) {
                                                    _moduleIdx = 1;
                                                  }

                                                  setState(() {});
                                                },
                                                value: mathOn,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                          color: testCountColor,
                                        ),
                                        width: Get.width * 0.2,
                                        height: 50,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Center(
                                              child: Text(
                                                mathOn ? '98' : '54',
                                                style: f16w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Text(
                                        '비밀번호',
                                        style: f18w400,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
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
                                      const SizedBox(
                                        height: 16,
                                      ),
                                      Text(
                                        '점수입력',
                                        style: f18w400,
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      GestureDetector(
                                        onTap: (){

                                          showSatScoreDialog(context,_scoreController,_scoreController2,(){
                                            for(int i = 0; i < 55;i++){
                                              _englishScoreList[i] = _scoreController[i].text;
                                              _mathScoreList[i] = _scoreController2[i].text;
                                            }
                                            Get.back();
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                                            color: testCountColor,
                                          ),
                                          width: Get.width * 0.2,
                                          height: 50,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Center(
                                                child: Text(
                                                  '점수입력',
                                                  style: f16w400,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Spacer(),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                            onTap: () {
                                              if (_moduleIdx > 0) {
                                                _moduleIdx--;
                                              }
                                              _controller.animateTo(_controller.position.minScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
                                              setState(() {});
                                            },
                                            child: Icon(
                                              Icons.arrow_back,
                                              color: _moduleIdx > 0 ? Colors.black : Colors.grey[400],
                                            )),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        Text(
                                          '${_moduleIdx > 1 ? '수학 ' : '영어 '}'
                                          'Module ${_moduleIdx > 1 ? _moduleIdx - 1 : _moduleIdx + 1}',
                                          style: f18w700,
                                        ),
                                        SizedBox(
                                          width: 8,
                                        ),
                                        GestureDetector(
                                            onTap: () {
                                              if (mathOn) {
                                                if (_moduleIdx < 3) {
                                                  _moduleIdx++;
                                                }
                                              } else {
                                                if (_moduleIdx < 1) {
                                                  _moduleIdx++;
                                                }
                                              }
                                              _controller.animateTo(_controller.position.minScrollExtent, duration: Duration(milliseconds: 300), curve: Curves.fastOutSlowIn);
                                              setState(() {});
                                            },
                                            child: mathOn
                                                ? Icon(Icons.arrow_forward, color: _moduleIdx < 3 ? Colors.black : Colors.grey[400])
                                                : Icon(Icons.arrow_forward, color: _moduleIdx < 1 ? Colors.black : Colors.grey[400])),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Container(
                                      width: Get.width * 0.46,
                                      height: Get.height * 0.6,
                                      child: ListView.builder(
                                          itemCount: _moduleIdx == 0 || _moduleIdx == 1 ? 27 : 22,
                                          shrinkWrap: true,
                                          controller: _controller,
                                          physics: const ClampingScrollPhysics(),
                                          itemBuilder: (c, idx) {
                                            return Column(
                                              children: [
                                                _moduleIdx == 0
                                                    ? component(idx)
                                                    : _moduleIdx == 1
                                                        ? component2(idx)
                                                        : _moduleIdx == 2
                                                            ? component3(idx)
                                                            : component4(idx),
                                                SizedBox(
                                                  height: 40,
                                                ),
                                              ],
                                            );
                                          }),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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

  Future<Uint8List?> getImageDataFromUrl(String imageUrl) async {
    // Make a network request to get the image data
    var response = await http.get(Uri.parse(imageUrl));

    // Check if the request was successful
    if (response.statusCode == 200) {
      // If successful, return the image data as Uint8List
      return response.bodyBytes;
    } else {
      return null;
    }
  }

  Future<void> _imageUpload(String docId) async {
    for (int i = 0; i < 27; i++) {
      if (_imageList[i] != '') {
        final firebaseStorageRef = FirebaseStorage.instance.ref().child('sat').child('$docId').child('${i}.png');
        final uploadTask = firebaseStorageRef.putData(_imageList[i], SettableMetadata(contentType: 'image/png'));
        await uploadTask.then((p0) => null);
      }

      if (_imageList2[i] != '') {
        final firebaseStorageRef = FirebaseStorage.instance.ref().child('sat').child('$docId').child('${i+27}.png');
        final uploadTask = firebaseStorageRef.putData(_imageList2[i], SettableMetadata(contentType: 'image/png'));
        await uploadTask.then((p0) => null);
      }
    }
  }

  Future<void> _imageUploadMath(String docId) async {
    for (int i = 0; i < 22; i++) {
      if (_imageList3[i] != '') {
        final firebaseStorageRef = FirebaseStorage.instance.ref().child('sat').child('$docId').child('${i+54}.png');
        final uploadTask = firebaseStorageRef.putData(_imageList3[i], SettableMetadata(contentType: 'image/png'));
        await uploadTask.then((p0) => null);
      }

      if (_imageList4[i] != '') {
        final firebaseStorageRef = FirebaseStorage.instance.ref().child('sat').child('$docId').child('${i+76}.png');
        final uploadTask = firebaseStorageRef.putData(_imageList4[i], SettableMetadata(contentType: 'image/png'));
        await uploadTask.then((p0) => null);
      }
    }
  }

  Future<void> _firebaseUpdate(String docId) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('sat');
    QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();
    snapshot.docs[0].reference.update({
      'mainTitle': _testNameController.text,
      'pw': '${_testPwController.text}',
    });
  }
  Future<void> _firebaseUp(String docId) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('sat');
    QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();
    snapshot.docs[0].reference.update({
      'status': '1',
    });
  }

  Future<void> _firebaseTemporary(String docId) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('sat');
    QuerySnapshot snapshot = await ref.where('docId', isEqualTo: docId).get();
    snapshot.docs[0].reference.update({
      'mainTitle': _testNameController.text,
      'pw': '${_testPwController.text}',
      'math': '${mathOn}',
      'answer': [..._checkAnswer, ..._checkAnswer2, ..._checkAnswer3, ..._checkAnswer4],
      'title': [..._titleTextList, ..._titleTextList2, ..._blankList],
      'body': [..._bodyTextList, ..._bodyTextList2, ..._blankList],
      'image': [...pickedFiles, ...pickedFiles2, ...pickedFiles3, ...pickedFiles4],
      'createDate': '${DateTime.now()}',
      'mathScore' : _mathScoreList,
      'englishScore' : _englishScoreList
    }).then((doc) async {
      bool _imageLoading = true;
      _imageLoading == true
          ? showDialog(
        barrierDismissible: false,
        builder: (ctx) {
          return Center(child: LoadingBodyScreen());
        },
        context: context,
      )
          : Container();

      await deleteFolder(path: "sat/${docId}");
      if(mathOn) {
        await _imageUploadMath(docId);
      }
      await _imageUpload(docId);
      setState(() {
        _imageLoading = false;
        Get.back();
        Get.back();
      });
    });
  }

  Future<void> deleteFolder({required String path}) async {
    List<String> paths = [];
    paths = await _deleteFolder(path, paths);
    for (String path in paths) {
      await FirebaseStorage.instance.ref().child(path).delete();
    }
  }

  Future<List<String>> _deleteFolder(String folder, List<String> paths) async {
    ListResult list =
    await FirebaseStorage.instance.ref().child(folder).listAll();
    List<Reference> items = list.items;
    List<Reference> prefixes = list.prefixes;
    for (Reference item in items) {
      paths.add(item.fullPath);
    }
    for (Reference subfolder in prefixes) {
      paths = await _deleteFolder(subfolder.fullPath, paths);
    }
    return paths;
  }

  Future<void> _firebaseUpload(String status) async {
    final us = Get.put(UserState());
    FirebaseFirestore.instance.collection('sat').add({
      'docId': '',
      'id': '${us.userList[0].id}',
      'math': '${mathOn}',
      'pw': '${_testPwController.text}',
      'status': status,
      'mainTitle': _testNameController.text,
      'answer': [..._checkAnswer, ..._checkAnswer2, ..._checkAnswer3, ..._checkAnswer4],
      'title': [..._titleTextList, ..._titleTextList2, ..._blankList], //3 = ['' * 44개],4 빈칸으로
      'body': [..._bodyTextList, ..._bodyTextList2, ..._blankList], //3 = ['' * 44개],4 빈칸으로
      // 'a' : [..._aTextList,..._aTextList2, ..._blankList], //3 = ['' * 44개],4 빈칸으로
      // 'b' : [..._bTextList,..._bTextList2, ..._blankList], //3 = ['' * 44개],4 빈칸으로
      // 'c' : [..._cTextList,..._cTextList2, ..._blankList], //3 = ['' * 44개],4 빈칸으로
      // 'd' : [..._dTextList,..._dTextList2, ..._blankList], //3 = ['' * 44개],4 빈칸으로
      'image': [...pickedFiles, ...pickedFiles2, ...pickedFiles3, ...pickedFiles4], //3,4번은 이미지 필수  contains로 빈칸있음 안되게
      'studentList':[],
      'createDate': '${DateTime.now()}',
      'nickName' : '${us.userList[0].nickName}',
      'mathScore'  : _mathScoreList,
      'visual' : 'false',
      'englishScore' : _englishScoreList,
    }).then((doc) async {
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('sat').doc(doc.id);
      await userDocRef.update({'docId': '${doc.id}'});
      bool _imageLoading = true;
      _imageLoading == true
          ? showDialog(
              barrierDismissible: false,
              builder: (ctx) {
                return Center(child: LoadingBodyScreen());
              },
              context: context,
            )
          : Container();
      if(mathOn) {
        await _imageUploadMath(doc.id);
      }
      await _imageUpload(doc.id);
      setState(() {
        _imageLoading = false;
        Get.back();
        Get.back();
      });
    });
  }

  Widget component(int idx) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Container(
        width: Get.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '문항 ${idx + 1}.',
                style: f18w700,
              ),
            ),
            SizedBox(
              height: 20,
            ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '지문',
                        style: f18w400,
                      ),
                      Text(
                        '${_testBodyCon[idx].text.length}/ 5000',
                        style: f14w400greyA,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    readOnly: _isdoNotEdit,
                    onChanged: (value) {
                      _bodyTextList[idx] = value;

                      setState(() {});
                    },
                    controller: _testBodyCon[idx],
                    maxLength: 5000,
                    maxLines: 10,
                    enabled: true,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      counterText: '',
                      fillColor: Color(0xffEBEBEB),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
                      hintText: '내용을 입력해주세요',
                      hintStyle: (kIsWeb && (Get.width * 0.2 <= 171)) ? f12w400grey8 : f16w400grey8,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    '문제 및 선택지',
                    style: f18w400,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    readOnly: _isdoNotEdit,
                    onChanged: (value) {
                      _titleTextList[idx] = _testTiCon[idx].text;
                      setState(() {});
                    },
                    enabled: true,
                    controller: _testTiCon[idx],
                    minLines: 5,
                    maxLines: 5,
                    maxLength: 2000,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      counterText: '',
                      fillColor: Color(0xffEBEBEB),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
                      hintText: '내용을 입력해주세요',
                      hintStyle: f16w400grey8,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    '문제 파일',
                    style: f18w400,
                  ),
                  SizedBox(
                    height: pickedFiles[idx] == '' ? 0 : 10,
                  ),
                  pickedFiles[idx] == ''
                      ? SizedBox(
                          height: 0,
                        )
                      : Row(
                          children: [
                            Text(
                              '${pickedFiles[idx]}',
                              style: f18w400,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            GestureDetector(
                              onTap: _isdoNotEdit ? () {} : () {
                                pickedFiles[idx] = '';
                                _imageList[idx] = '';
                                setState(() {});
                              },
                              child: Icon(
                                Icons.close,
                                size: 20,
                              ),
                            )
                          ],
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 40,
                        child: ElevatedButton(
                            onPressed: _isdoNotEdit ? () {} : () async {
                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                allowedExtensions: [
                                  'png',
                                  'jpg',
                                  'jpeg',
                                ],
                                type: FileType.custom,
                              );
                              if (result == null) return;
                              PlatformFile? pickedFile = result.files.first;
                              pickedFiles[idx] = pickedFile.name;
                              _imageList[idx] = result.files.single.bytes;
                              setState(() {});
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              )),
                              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 14, horizontal: 20)),
                              backgroundColor: MaterialStateProperty.all<Color>(textFormColor),
                              splashFactory: NoSplash.splashFactory,
                              elevation: MaterialStateProperty.all<double>(0.0),
                            ),
                            child: Text('찾아보기', style: f16w700primary)),
                      ),
                      SizedBox(
                        width: 26,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    '답안',
                    style: f18w400,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        'A)',
                        style: f18w400,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                          onTap: _isdoNotEdit ? () {} : () {
                            _checkAnswer[idx] = 'a';
                            setState(() {});
                          },
                          child: SvgPicture.asset(_checkAnswer[idx] == 'a' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        'B)',
                        style: f18w400,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                          onTap: _isdoNotEdit ? () {} : () {
                            _checkAnswer[idx] = 'b';
                            setState(() {});
                          },
                          child: SvgPicture.asset(_checkAnswer[idx] == 'b' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        'C)',
                        style: f18w400,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                          onTap: _isdoNotEdit ? () {} : () {
                            _checkAnswer[idx] = 'c';
                            setState(() {});
                          },
                          child: SvgPicture.asset(_checkAnswer[idx] == 'c' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        'D)',
                        style: f18w400,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                          onTap: _isdoNotEdit ? () {} : () {
                            _checkAnswer[idx] = 'd';
                            setState(() {});
                          },
                          child: SvgPicture.asset(_checkAnswer[idx] == 'd' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget component2(int idx) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Container(
        width: Get.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '문항 ${idx + 28}.',
                style: f18w700,
              ),
            ),
            SizedBox(
              height: 20,
            ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '지문',
                        style: f18w400,
                      ),
                      Text(
                        '${_testBodyCon2[idx].text.length}/ 5000',
                        style: f14w400greyA,
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    readOnly: _isdoNotEdit,
                    onChanged: (value) {
                      _bodyTextList2[idx] = value;
                      setState(() {});
                    },
                    controller: _testBodyCon2[idx],
                    maxLength: 5000,
                    maxLines: 10,
                    enabled: true,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      counterText: '',
                      fillColor: Color(0xffEBEBEB),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
                      hintText: '내용을 입력해주세요',
                      hintStyle: (kIsWeb && (Get.width * 0.2 <= 171)) ? f12w400grey8 : f16w400grey8,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    '문제 및 선택지',
                    style: f18w400,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  TextFormField(
                    readOnly: _isdoNotEdit,
                    onChanged: (value) {
                      _titleTextList2[idx] = value;
                      setState(() {});
                    },
                    enabled: true,
                    controller: _testTiCon2[idx],
                    minLines: 5,
                    maxLines: 5,
                    maxLength: 2000,
                    decoration: InputDecoration(
                      isDense: true,
                      filled: true,
                      counterText: '',
                      fillColor: Color(0xffEBEBEB),
                      contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
                      hintText: '내용을 입력해주세요',
                      hintStyle: f16w400grey8,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    '문제 파일',
                    style: f18w400,
                  ),
                  SizedBox(
                    height: pickedFiles2[idx] == '' ? 0 : 10,
                  ),
                  pickedFiles2[idx] == ''
                      ? SizedBox(
                    height: 0,
                  )
                      : Row(
                    children: [
                      Text(
                        '${pickedFiles2[idx]}',
                        style: f18w400,
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      GestureDetector(
                        onTap: _isdoNotEdit ? () {} : () {
                          pickedFiles2[idx] = '';
                          _imageList2[idx] = '';
                          setState(() {});
                        },
                        child: Icon(
                          Icons.close,
                          size: 20,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
                        child: ElevatedButton(
                            onPressed: _isdoNotEdit ? () {} : () async {
                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                allowedExtensions: [
                                  'png',
                                  'jpg',
                                  'jpeg',
                                ],
                                type: FileType.custom,
                              );
                              if (result == null) return;
                              PlatformFile? pickedFile = result.files.first;
                              pickedFiles2[idx] = pickedFile.name;
                              _imageList2[idx] = result.files.single.bytes;
                              setState(() {});
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              )),
                              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 14, horizontal: 20)),
                              backgroundColor: MaterialStateProperty.all<Color>(textFormColor),
                              splashFactory: NoSplash.splashFactory,
                              elevation: MaterialStateProperty.all<double>(0.0),
                            ),
                            child: Text('찾아보기', style: f16w700primary)),
                      ),
                      SizedBox(
                        width: 26,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    '답안',
                    style: f18w400,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        'A)',
                        style: f18w400,
                      ),
                      // const SizedBox(
                      //   width: 10,
                      // ),
                      // SizedBox(
                      //   width: Get.width * 0.3,
                      //   child: TextFormField(
                      //     onChanged: (value) {
                      //       _aTextList2[idx] = value;
                      //
                      //       setState(() {});
                      //     },
                      //     enabled: true,
                      //     controller: _testAnswerA2[idx],
                      //     minLines: 1,
                      //     maxLines: 1,
                      //     maxLength: 200,
                      //
                      //     decoration: InputDecoration(
                      //       isDense: true,
                      //       filled: true,
                      //       counterText: '',
                      //       fillColor: Color(0xffEBEBEB),
                      //       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      //       border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
                      //       hintText: '내용을 입력해주세요',
                      //       hintStyle: f16w400grey8,
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                          onTap: _isdoNotEdit ? () {} : () {
                            _checkAnswer2[idx] = 'a';
                            setState(() {});
                          },
                          child: SvgPicture.asset(_checkAnswer2[idx] == 'a' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        'B)',
                        style: f18w400,
                      ),
                      // const SizedBox(
                      //   width: 10,
                      // ),
                      // SizedBox(
                      //   width: Get.width * 0.3,
                      //   child: TextFormField(
                      //     onChanged: (value) {
                      //       _bTextList2[idx]= value;
                      //
                      //       setState(() {});
                      //     },
                      //     enabled: true,
                      //     controller: _testAnswerB2[idx],
                      //     minLines: 1,
                      //     maxLines: 1,
                      //     maxLength: 200,
                      //
                      //     decoration: InputDecoration(
                      //       isDense: true,
                      //       filled: true,
                      //       counterText: '',
                      //       fillColor: Color(0xffEBEBEB),
                      //       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      //       border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
                      //       hintText: '내용을 입력해주세요',
                      //       hintStyle: f16w400grey8,
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                          onTap: _isdoNotEdit ? () {} : () {
                            _checkAnswer2[idx] = 'b';
                            setState(() {});
                          },
                          child: SvgPicture.asset(_checkAnswer2[idx] == 'b' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        'C)',
                        style: f18w400,
                      ),
                      // const SizedBox(
                      //   width: 10,
                      // ),
                      // SizedBox(
                      //   width: Get.width * 0.3,
                      //   child: TextFormField(
                      //     onChanged: (value) {
                      //       _cTextList2[idx] = value;
                      //
                      //       setState(() {});
                      //     },
                      //     enabled: true,
                      //     controller: _testAnswerC2[idx],
                      //     minLines: 1,
                      //     maxLines: 1,
                      //     maxLength: 200,
                      //
                      //     decoration: InputDecoration(
                      //       isDense: true,
                      //       filled: true,
                      //       counterText: '',
                      //       fillColor: Color(0xffEBEBEB),
                      //       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      //       border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
                      //       hintText: '내용을 입력해주세요',
                      //       hintStyle: f16w400grey8,
                      //     ),
                      //   ),
                      // ),
                      const SizedBox(
                        width: 10,
                      ),
                      GestureDetector(
                          onTap: _isdoNotEdit ? () {} : () {
                            _checkAnswer2[idx] = 'c';
                            setState(() {});
                          },
                          child: SvgPicture.asset(_checkAnswer2[idx] == 'c' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      Text(
                        'D)',
                        style: f18w400,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      // SizedBox(
                      //   width: Get.width * 0.3,
                      //   child: TextFormField(
                      //     onChanged: (value) {
                      //       _dTextList2[idx]= value;
                      //
                      //       setState(() {});
                      //     },
                      //     enabled: true,
                      //     controller: _testAnswerD2[idx],
                      //     minLines: 1,
                      //     maxLines: 1,
                      //     maxLength: 200,
                      //
                      //     decoration: InputDecoration(
                      //       isDense: true,
                      //       filled: true,
                      //       counterText: '',
                      //       fillColor: Color(0xffEBEBEB),
                      //       contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                      //       border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
                      //       hintText: '내용을 입력해주세요',
                      //       hintStyle: f16w400grey8,
                      //     ),
                      //   ),
                      // ),
                      // const SizedBox(
                      //   width: 10,
                      // ),
                      GestureDetector(
                          onTap: _isdoNotEdit ? () {} : () {
                            _checkAnswer2[idx] = 'd';
                            setState(() {});
                          },
                          child: SvgPicture.asset(_checkAnswer2[idx] == 'd' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget component3(int idx) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Container(
        width: Get.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '문항 ${idx + 55}.',
                style: f18w700,
              ),
            ),
            SizedBox(
              height: 20,
            ),
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
                        onTap: _isdoNotEdit ? () {} : () {
                          firstTrue[idx] = !firstTrue[idx];
                          // _testEssayCon[idx].text = '';
                          setState(() {});
                        },
                        child: SvgPicture.asset(firstTrue[idx] ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      const Text(
                        '주관식 문제로 변경',
                        style: f18w700,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    '문제 파일',
                    style: f18w400,
                  ),
                  SizedBox(
                    height: pickedFiles3[idx] == '' ? 0 : 10,
                  ),
                  pickedFiles3[idx] == ''
                      ? SizedBox(
                          height: 0,
                        )
                      : Row(
                          children: [
                            Text(
                              '${pickedFiles3[idx]}',
                              style: f18w400,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            GestureDetector(
                              onTap: _isdoNotEdit ? () {} : () {
                                pickedFiles3[idx] = '';
                                _imageList3[idx] = '';
                                setState(() {});
                              },
                              child: Icon(
                                Icons.close,
                                size: 20,
                              ),
                            )
                          ],
                        ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
                        child: ElevatedButton(
                            onPressed: _isdoNotEdit ? () {} : () async {
                              FilePickerResult? result = await FilePicker.platform.pickFiles(
                                allowedExtensions: [
                                  'png',
                                  'jpg',
                                  'jpeg',
                                ],
                                type: FileType.custom,
                              );
                              if (result == null) return;
                              PlatformFile? pickedFile = result.files.first;
                              pickedFiles3[idx] = pickedFile.name;
                              _imageList3[idx] = result.files.single.bytes;
                              setState(() {});
                            },
                            style: ButtonStyle(
                              shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              )),
                              padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 14, horizontal: 20)),
                              backgroundColor: MaterialStateProperty.all<Color>(textFormColor),
                              splashFactory: NoSplash.splashFactory,
                              elevation: MaterialStateProperty.all<double>(0.0),
                            ),
                            child: Text('찾아보기', style: f16w700primary)),
                      ),
                      SizedBox(
                        width: 26,
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    '답안',
                    style: f18w400,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  firstTrue[idx]
                      ? TextFormField(
                          readOnly: _isdoNotEdit,
                          controller: _testEssayCon[idx],
                          maxLines: null,
                          decoration: InputDecoration(
                            isDense: true,
                            filled: true,
                            fillColor: Color(0xffEBEBEB),
                            contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                            border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
                            hintText: '답을 입력해주세요',
                            hintStyle: (kIsWeb && (Get.width * 0.2 <= 171)) ? f12w400grey8 : f16w400grey8,
                          ),
                        )
                      : Container(
                          child: Column(
                          children: [
                            Row(
                              children: [
                                Text(
                                  'A)',
                                  style: f18w400,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                    onTap: _isdoNotEdit ? () {} : () {
                                      _checkAnswer3[idx] = 'a';
                                      setState(() {});
                                    },
                                    child: SvgPicture.asset(_checkAnswer3[idx] == 'a' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Text(
                                  'B)',
                                  style: f18w400,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                    onTap: _isdoNotEdit ? () {} : () {
                                      _checkAnswer3[idx] = 'b';
                                      setState(() {});
                                    },
                                    child: SvgPicture.asset(_checkAnswer3[idx] == 'b' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Text(
                                  'C)',
                                  style: f18w400,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                    onTap: _isdoNotEdit ? () {} : () {
                                      _checkAnswer3[idx] = 'c';
                                      setState(() {});
                                    },
                                    child: SvgPicture.asset(_checkAnswer3[idx] == 'c' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                              ],
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Row(
                              children: [
                                Text(
                                  'D)',
                                  style: f18w400,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                GestureDetector(
                                    onTap: _isdoNotEdit ? () {} : () {
                                      _checkAnswer3[idx] = 'd';
                                      setState(() {});
                                    },
                                    child: SvgPicture.asset(_checkAnswer3[idx] == 'd' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                              ],
                            ),
                          ],
                        ))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget component4(int idx) {
    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Container(
        width: Get.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                '문항 ${idx + 77}.',
                style: f18w700,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
                const SizedBox(
                  height: 20,
                ),
                Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _isdoNotEdit ? () {} : () {
                        firstTrue2[idx] = !firstTrue2[idx];
                        setState(() {});
                      },
                      child: SvgPicture.asset(firstTrue2[idx] ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text(
                      '주관식 문제로 변경',
                      style: f18w700,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  '문제 파일',
                  style: f18w400,
                ),
                SizedBox(
                  height: pickedFiles4[idx] == '' ? 0 : 10,
                ),
                pickedFiles4[idx] == ''
                    ? const SizedBox(
                        height: 0,
                      )
                    : Row(
                        children: [
                          Text(
                            '${pickedFiles4[idx]}',
                            style: f18w400,
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          GestureDetector(
                            onTap: _isdoNotEdit ? () {} : () {
                              pickedFiles4[idx] = '';
                              _imageList4[idx] = '';
                              setState(() {});
                            },
                            child: Icon(
                              Icons.close,
                              size: 20,
                            ),
                          )
                        ],
                      ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: (kIsWeb && (Get.width * 0.2 <= 171)) ? 32 : 40,
                      child: ElevatedButton(
                          onPressed: _isdoNotEdit ? () {} : () async {
                            FilePickerResult? result = await FilePicker.platform.pickFiles(
                              allowedExtensions: [
                                'png',
                                'jpg',
                                'jpeg',
                              ],
                              type: FileType.custom,
                            );
                            if (result == null) return;
                            PlatformFile? pickedFile = result.files.first;
                            pickedFiles4[idx] = pickedFile.name;
                            _imageList4[idx] = result.files.single.bytes;
                            setState(() {});
                          },
                          style: ButtonStyle(
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            )),
                            padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.symmetric(vertical: 14, horizontal: 20)),
                            backgroundColor: MaterialStateProperty.all<Color>(textFormColor),
                            splashFactory: NoSplash.splashFactory,
                            elevation: MaterialStateProperty.all<double>(0.0),
                          ),
                          child: Text('찾아보기', style: f16w700primary)),
                    ),
                    SizedBox(
                      width: 26,
                    ),
                  ],
                ),
                const SizedBox(
                  height: 20,
                ),
                const Text(
                  '답안',
                  style: f18w400,
                ),
                const SizedBox(
                  height: 20,
                ),
                firstTrue2[idx]
                    ? TextFormField(
                        readOnly: _isdoNotEdit,
                        controller: _testEssayCon2[idx],
                        maxLines: null,
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Color(0xffEBEBEB),
                          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          border: OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.circular(8)),
                          hintText: '답을 입력해주세요',
                          hintStyle: (kIsWeb && (Get.width * 0.2 <= 171)) ? f12w400grey8 : f16w400grey8,
                        ),
                      )
                    : Container(
                        child: Column(
                        children: [
                          Row(
                            children: [
                              Text(
                                'A)',
                                style: f18w400,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                  onTap: _isdoNotEdit ? () {} : () {
                                    _checkAnswer4[idx] = 'a';
                                    setState(() {});
                                  },
                                  child: SvgPicture.asset(_checkAnswer4[idx] == 'a' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Text(
                                'B)',
                                style: f18w400,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                  onTap: _isdoNotEdit ? () {} : () {
                                    _checkAnswer4[idx] = 'b';
                                    setState(() {});
                                  },
                                  child: SvgPicture.asset(_checkAnswer4[idx] == 'b' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Text(
                                'C)',
                                style: f18w400,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                  onTap: _isdoNotEdit ? () {} : () {
                                    _checkAnswer4[idx] = 'c';
                                    setState(() {});
                                  },
                                  child: SvgPicture.asset(_checkAnswer4[idx] == 'c' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            children: [
                              Text(
                                'D)',
                                style: f18w400,
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              GestureDetector(
                                  onTap: _isdoNotEdit ? () {} : () {
                                    _checkAnswer4[idx] = 'd';
                                    setState(() {});
                                  },
                                  child: SvgPicture.asset(_checkAnswer4[idx] == 'd' ? 'assets/checkBox.svg' : 'assets/notcheckBox.svg'))
                            ],
                          ),
                        ],
                      ))
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _useBackKey(BuildContext context) async {
    return await showComponentDialog(context, '작성을 취소하시겠습니까?', () {
      Get.back();
      Get.back();
    });
  }
}
