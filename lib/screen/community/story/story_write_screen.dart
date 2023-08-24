import 'dart:io';

import 'package:academy/components/tile/textform_field.dart';
import 'package:academy/util/colors.dart';
import 'package:academy/util/padding.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';

import '../../../components/appbar/appbars.dart';
import '../../../components/button/choose_button.dart';
import '../../../components/dialog/showAlertDialog.dart';
import '../../../components/footer/footer.dart';
import '../../../firebase/firebase_user.dart';
import '../../../provider/community_state.dart';
import '../../../provider/job_state.dart';
import '../../../provider/user_state.dart';
import '../../../util/cupertino_utill.dart';
import '../../../util/font/font.dart';
import '../../../util/loading.dart';
import '../../../util/mouse_scroll.dart';
import '../../../util/refresh_manager.dart';
import '../../login/login_main_screen.dart';
import '../job/job_timer_screen.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class StoryWriteScreen extends StatefulWidget {
  static final String id = '/story_write';
  final String? state;
  final String? whichScreen;
  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;
  const StoryWriteScreen({Key? key, this.whichScreen, this.state, this.refreshIndicatorKey})
      : super(key: key);

  @override
  State<StoryWriteScreen> createState() => _StoryWriteScreenState();
}

class _StoryWriteScreenState extends State<StoryWriteScreen> {
  TextEditingController _titleCon = TextEditingController();
  TextEditingController _bodyCon = TextEditingController();
  TextEditingController _ageCon = TextEditingController();
  TextEditingController _sidoCon = TextEditingController();
  TextEditingController _moneyCon = TextEditingController();
  List<XFile>? _imageFileList = [];
  List _firebaseImg = [];
  List _editImg = [];
  final ImagePicker _picker = ImagePicker();
  String? _dropdown = '이상';
  String? _dropdown2 = '월급';

  // String? _dropdown3 = '09:00';
  // String? _dropdown4 = '18:00';
  bool _imageLoading = false;
  int _gender = 0;
  bool _pay = false;
  int _indexTime = 0;
  int _indexTime2 = 0;
  int _indexTime3 = 0;
  int _indexTime4 = 0;
  var hourList = new List<int>.generate(24, (i) => i);
  var minList = new List<int>.generate(60, (i) => i);

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      final cs = Get.put(CommunityState());
      final us = Get.put(UserState());
      final js = Get.put(JobState());
      final args = ModalRoute.of(context)!.settings.arguments as StoryWriteScreen;

      await userGet(RefreshManager.getCookie('id'), RefreshManager.getCookie('pw'));
      us.isLogin.value = RefreshManager.getCookie('type');
      if (us.isLogin == '' || us.userList.length == 0) {

        showConfirmTapDialog(context, '로그인 후에 이용할 수 있습니다', () {
          Get.offAllNamed(LoginMainScreen.id);
        });
      }
      if (args.whichScreen == 'job') {
        _firebaseImg = [];
        if (args.state == 'edit') {
          _titleCon.text = '${js.selectJobTile[0]['title']}';
          _bodyCon.text = '${js.selectJobTile[0]['body']}';
          _ageCon.text = '${js.selectJobTile[0]['age']}';
          _sidoCon.text = '${js.selectJobTile[0]['sido']}';
          _moneyCon.text = js.selectJobTile[0]['pay'] == '협의'
              ? '0'
              : '${js.selectJobTile[0]['pay']}';

          ///사진추가
          _editImg = js.selectJobTile[0]['images'];
          if (js.jobList.length != 0) {
            for (int i = 0; i < _editImg.length; i++) {
              _firebaseImg.add(
                  'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/picture%2F${us.userList[0].phoneNumber}%2F${js.jobDocId.value}%2F${_editImg[i]}?alt=media');
            }
          }
          _dropdown = '${js.selectJobTile[0]['ageValue']}';
          _dropdown2 = '${js.selectJobTile[0]['payValue']}';
          _gender = js.selectJobTile[0]['gender'] == '남자'
              ? 0
              : js.selectJobTile[0]['gender'] == '여자'
                  ? 1
                  : 2;
          _pay = js.selectJobTile[0]['pay'] == '협의' ? true : false;
          _indexTime = js.selectJobTile[0]['openH'];
          _indexTime2 = js.selectJobTile[0]['openM'];
          _indexTime3 = js.selectJobTile[0]['closeH'];
          _indexTime4 = js.selectJobTile[0]['closeM'];
        }
      }
      else if (args.whichScreen == 'qna') {
        if (args.state == 'edit') {
          _titleCon.text = us.qnaTitle.value;
          _bodyCon.text = us.qnaBody.value;
          _editImg = us.qnaImgs;
          String docIds = '${us.qnaDocId.value}'.trim();
          // print('docId : ${us.qnaDocId.value}');
          if (us.qnaImgs.length != 0) {
            for (int i = 0; i < us.qnaImgs.length; i++) {
              _firebaseImg.add(
                  'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/picture%2F${us.userList[0].phoneNumber}%2F${docIds}%2F${us.qnaImgs[i]}?alt=media');
            }
            // print('https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/picture%2F${us.userList[0].phoneNumber}%2F${us.qnaDocId.value}%2F${us.qnaImgs[0]}?alt=media');
          }
        }
      }
      else {
        if (args.state == 'edit') {
          _titleCon.text = cs.communityList[0]['title'];
          _bodyCon.text = cs.communityList[0]['body'];
          ///사진추가
          _editImg = cs.communityList[0]['images'];
          if (cs.communityList[0]['images'].length != 0) {
            for (int i = 0; i < cs.communityList[0]['images'].length; i++) {
              _firebaseImg.add('https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/picture%2F${us.userList[0].phoneNumber}%2F${cs.communityList[0]['docId']}%2F${cs.communityList[0]['images'][i]}?alt=media');
            }
          }
        }
      }
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _titleCon.dispose();
    _bodyCon.dispose();
    _ageCon.dispose();
    _sidoCon.dispose();
    _moneyCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as StoryWriteScreen;
    final us = Get.put(UserState());
    return WillPopScope(
      onWillPop: (){
        return Future(() {
          Get.back();
          return true;
        });
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          backgroundColor: backColor,
          appBar: Appbars(us: us, context: context),
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Column(
              children: [
                Container(margin: EdgeInsets.symmetric(horizontal: Get.width * 0.15),
                  width: Get.width * 0.8,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: ScrollConfiguration(
                    behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      child: Column(mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 40,),
                          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('글쓰기', style: f32w700,),
                              Container(
                                child: Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        Get.back();
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Center(child: Text('목록으로', style: f16w700,)),
                                        decoration: BoxDecoration(
                                          color: const Color(0xffffffff),
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            width: 1,
                                            color: const Color(0xff535353),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12,),
                                    GestureDetector(
                                      onTap: () {
                                        if (_titleCon.text.trim().isEmpty == true ||
                                            _bodyCon.text.trim().isEmpty == true) {
                                          showOnlyConfirmDialog(context, '제목 또는 내용을 입력해주세요');
                                        } else {
                                          if (args.whichScreen == 'job' &&
                                              (_ageCon.text.trim().isEmpty == true || _sidoCon.text.trim().isEmpty == true ||
                                                  (_indexTime == _indexTime3) &&
                                                      (_indexTime2 == _indexTime4))) {
                                            showOnlyConfirmDialog(context, '정확히 입력해주세요');
                                          } else {
                                            showComponentDialog(context, '업로드하시겠습니까?', () async {
                                              if (args.whichScreen == 'job') {
                                                if (args.state == 'edit') {
                                                  await _editWriting('jobHunting');
                                                } else {
                                                  await jobUpload(
                                                      _titleCon.text,
                                                      _bodyCon.text,
                                                      _gender,
                                                      _ageCon.text,
                                                      _sidoCon.text,
                                                      _dropdown!,
                                                      _dropdown2!,
                                                      _pay,
                                                      _moneyCon.text,
                                                      _indexTime,
                                                      _indexTime2,
                                                      _indexTime3,
                                                      _indexTime4);
                                                }
                                              }
                                              else if(args.whichScreen =='qna'){
                                                if (args.state == 'edit') {
                                                  await _editWriting('qna');
                                                }
                                                else { //job
                                                  // print('dsddddddd');
                                                  await communityUpload(_titleCon.text, _bodyCon.text);
                                                }
                                              }
                                              else {
                                                if (args.state == 'edit') {
                                                  await _editWriting('story');
                                                }
                                                else { //job
                                                  // print('dsddddddd');
                                                  await communityUpload(_titleCon.text, _bodyCon.text);
                                                }
                                              }
                                              showConfirmTapDialog(context, '업로드 되었습니다', () {
                                                setState(() {
                                                  if (args.state == 'edit') {
                                                    Get.back();
                                                  }
                                                  Get.back();
                                                  Get.back();
                                                  Get.back();
                                                });
                                              });
                                            });
                                          }
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
                                  ],
                                ),
                              )
                            ],),

                          const SizedBox(height: 77,),
                          Center(
                            child: Container(width: Get.width * 0.4,
                              child: TextFormFields(
                                  controller: _titleCon,
                                  obscureText: true,
                                  hintText: '제목을 입력해주세요',
                                  surffixIcon: ''),
                            ),
                          ),

                          const SizedBox(height: 20,),
                          Center(child: Container(width: Get.width * 0.4,child: Text('이미지 첨부', style: f18w400))),
                          const SizedBox(height: 10,),
                          Center(
                            child: Container(width: Get.width * 0.4,
                              child: ScrollConfiguration(
                                behavior: MyCustomScrollBehavior(),
                                child: SingleChildScrollView(
                                  physics: const ClampingScrollPhysics(),
                                  scrollDirection: Axis.horizontal,
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          if (_imageFileList!.length + _firebaseImg.length > 9) {
                                            showOnlyConfirmDialog(context, '사진은 10장까지 올리실 수 있습니다');
                                          } else {
                                            await _openImagePicker();
                                          }
                                        },
                                        child: Container(height: 80,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(8),
                                            border: Border.all(
                                              color: const Color(0xffE9E9E9),
                                            ),
                                            color: Colors.white,
                                          ),
                                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Icon(Icons.photo_camera_outlined,
                                                size: 24,),
                                              // SvgPicture.asset(
                                              //   'assets/icon/camera.svg',
                                              //   height: 24,
                                              //   width: 24,
                                              // ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Text(
                                                  '${_imageFileList!.length + _firebaseImg.length}/10',
                                                  style: (Get.width * 0.2 <= 171)
                                                      ? f12w400
                                                      : f16w400),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: _firebaseImg.length == 0 ? 1 : 80,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _firebaseImg.length,
                                          physics: const ClampingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              child: Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  Stack(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(8.0),
                                                        child: ExtendedImage.network(
                                                          _firebaseImg[index],
                                                          // width: kIsWeb
                                                          //     ? (Get.width * 0.2 <= 171)
                                                          //         ? 80
                                                          //         : Get.width * 0.13
                                                          //     : Get.width * 0.23,
                                                          height: 80,
                                                          cache: false,
                                                          enableLoadState: false,
                                                          // fit: BoxFit.fill
                                                        ),
                                                      ),
                                                      Positioned(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            // _firebaseImg.removeAt(index);
                                                            _firebaseImg.removeAt(index);
                                                            _editImg.removeAt(index);
                                                            // FirebaseStorage.instance.refFromURL('https://firebasestorage.googleapis.com/v0/b/clicksound-af0c0.appspot.com/o/picture%2F$phoneNumber2FtqdmVbK9U8BDvZCS2Hpg%2FSimulator%20Screen%20Shot%20-%20iPhone%2013%20Pro%20-%202022-08-08%20at%2015.33.20.png?alt=media&token=ed9e8242-056e-4201-af95-d2ae609c924e').delete();
                                                            setState(() {});
                                                          },
                                                          child: Container(
                                                            height: 24,
                                                            width: 24,
                                                            decoration: BoxDecoration(
                                                                color: Colors.black,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        100)),
                                                            child: Icon(
                                                              Icons.close,
                                                              color: Colors.white,
                                                              size: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        top: 3,
                                                        right: 4,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8)),
                                            );
                                          },
                                        ),
                                      ),
                                      Container(
                                        height: _imageFileList!.length == 0 ? 1 : 80,
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: _imageFileList!.length,
                                          physics: const ClampingScrollPhysics(),
                                          scrollDirection: Axis.horizontal,
                                          itemBuilder: (context, index) {
                                            return Container(
                                              child: Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 12,
                                                  ),
                                                  Stack(
                                                    children: [
                                                      ClipRRect(
                                                        borderRadius:
                                                            BorderRadius.circular(8.0),
                                                        child: kIsWeb
                                                            ? Image.network(
                                                                _imageFileList![index].path,
                                                                // fit: BoxFit.none,
                                                                // width:
                                                                //     (Get.width * 0.2 <= 171)
                                                                //         ? 80
                                                                //         : Get.width * 0.13,
                                                                height: 80,
                                                              )
                                                            : Image.file(
                                                                File(_imageFileList![index]
                                                                    .path),
                                                                // width: Get.width * 0.23,
                                                                height: 80,
                                                                fit: BoxFit.fill),
                                                      ),
                                                      Positioned(
                                                        child: GestureDetector(
                                                          onTap: () {
                                                            // _firebaseImg.removeAt(index);
                                                            _imageFileList!.removeAt(index);
                                                            // FirebaseStorage.instance.refFromURL('https://firebasestorage.googleapis.com/v0/b/clicksound-af0c0.appspot.com/o/picture%2F$phoneNumber2FtqdmVbK9U8BDvZCS2Hpg%2FSimulator%20Screen%20Shot%20-%20iPhone%2013%20Pro%20-%202022-08-08%20at%2015.33.20.png?alt=media&token=ed9e8242-056e-4201-af95-d2ae609c924e').delete();
                                                            setState(() {});
                                                          },
                                                          child: Container(
                                                            height: 24,
                                                            width: 24,
                                                            decoration: BoxDecoration(
                                                                color: Colors.black,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        100)),
                                                            child: Icon(
                                                              Icons.close,
                                                              color: Colors.white,
                                                              size: 16,
                                                            ),
                                                          ),
                                                        ),
                                                        top: 3,
                                                        right: 4,
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8)),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20,),
                          Center(
                            child: Container(width: Get.width * 0.4,
                              child: TextField(
                                controller: _bodyCon,
                                keyboardType: TextInputType.multiline,
                                style: f16w400,
                                minLines: 10,
                                maxLines: null,
                                decoration: InputDecoration(
                                    hintText: '내용을 입력해주세요',
                                    hintStyle: f16w400greyA,
                                    enabledBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(width: 1, color: Colors.transparent)),
                                    focusedBorder: OutlineInputBorder(
                                        borderSide:
                                            BorderSide(width: 1, color: Colors.transparent))),
                              ),
                            ),
                          ),
                          args.whichScreen == 'job' ?
                               SingleChildScrollView(
                                 child: Center(
                                   child: Container(width: Get.width * 0.4,
                                     child: Column(
                                       crossAxisAlignment: CrossAxisAlignment.start,
                                       children: [
                                         const SizedBox(
                                           height: 24,
                                         ),
                                         Text(
                                           '성별',
                                           style: f18w400,
                                         ),
                                         const SizedBox(
                                           height: 10,
                                         ),
                                         Row(
                                           children: [
                                             Expanded(
                                               child: ChooseButton(
                                                 title: '남자',
                                                 isTrue: _gender == 0 ? true : false,
                                                 onTap: () {
                                                   _gender = 0;
                                                   setState(() {});
                                                 },
                                               ),
                                             ),
                                             SizedBox(
                                               width: 10,
                                             ),
                                             Expanded(
                                               child: ChooseButton(
                                                 title: '여자',
                                                 isTrue: _gender == 1 ? true : false,
                                                 onTap: () {
                                                   _gender = 1;
                                                   setState(() {});
                                                 },
                                               ),
                                             ),
                                             SizedBox(
                                               width: 10,
                                             ),
                                             Expanded(
                                               child: ChooseButton(
                                                 title: '성별 무관',
                                                 isTrue: _gender == 2 ? true : false,
                                                 onTap: () {
                                                   _gender = 2;
                                                   setState(() {});
                                                 },
                                               ),
                                             )
                                           ],
                                         ),
                                         const SizedBox(
                                           height: 16,
                                         ),
                                         Text(
                                           '나이',
                                           style: f18w400,
                                         ),
                                         const SizedBox(
                                           height: 10,
                                         ),
                                         Row(
                                           children: [
                                             Expanded(
                                               flex: 2,
                                               child: TextFormField(
                                                 controller: _ageCon,
                                                 decoration: InputDecoration(
                                                   isDense: true,
                                                   filled: true,
                                                   fillColor: Color(0xffEBEBEB),
                                                   contentPadding: EdgeInsets.symmetric(
                                                       horizontal: 20, vertical: 14),
                                                   border: OutlineInputBorder(
                                                       borderSide: BorderSide.none,
                                                       borderRadius: BorderRadius.circular(8)),
                                                   hintText: '나이',
                                                   hintStyle: f16w400grey8,
                                                 ),
                                               ),
                                             ),
                                             const SizedBox(
                                               width: 10,
                                             ),
                                             Expanded(
                                               flex: 1,
                                               child: DecoratedBox(
                                                 decoration: BoxDecoration(
                                                     borderRadius: BorderRadius.circular(8),
                                                     color: Color(0xffebebeb)),
                                                 child: Padding(
                                                   padding: ph20v14,
                                                   child: DropdownButton<String>(
                                                     focusColor: Colors.white,
                                                     isDense: true,
                                                     isExpanded: true,
                                                     underline: Container(),
                                                     icon: Icon(
                                                       Icons.keyboard_arrow_down,
                                                       color: Color(0xff535353),
                                                     ),
                                                     value: _dropdown,
                                                     //elevation: 5,
                                                     style: TextStyle(color: Colors.white),
                                                     iconEnabledColor: Colors.black,
                                                     items: <String>[
                                                       '이상',
                                                       '이하',
                                                     ].map<DropdownMenuItem<String>>(
                                                         (String value) {
                                                       return DropdownMenuItem<String>(
                                                         value: value,
                                                         child: Text(value, style: f16w400),
                                                       );
                                                     }).toList(),
                                                     hint: Text(
                                                       "나이",
                                                       style: f14w500,
                                                     ),
                                                     onChanged: (v) {
                                                       setState(() {
                                                         _dropdown = v;
                                                       });
                                                     },
                                                   ),
                                                 ),
                                               ),
                                             ),
                                           ],
                                         ),
                                         const SizedBox(
                                           height: 16,
                                         ),
                                         Text(
                                           '지역',
                                           style: f18w400,
                                         ),
                                         const SizedBox(
                                           height: 10,
                                         ),
                                         TextFormField(
                                           controller: _sidoCon,
                                           decoration: InputDecoration(
                                             isDense: true,
                                             filled: true,
                                             fillColor: Color(0xffEBEBEB),
                                             contentPadding: EdgeInsets.symmetric(
                                                 horizontal: 20, vertical: 14),
                                             border: OutlineInputBorder(
                                                 borderSide: BorderSide.none,
                                                 borderRadius: BorderRadius.circular(8)),
                                             hintText: '지역',
                                             hintStyle: f16w400grey8,
                                           ),
                                         ),
                                         const SizedBox(
                                           height: 16,
                                         ),
                                         Text(
                                           '급여',
                                           style: f18w400,
                                         ),
                                         const SizedBox(
                                           height: 10,
                                         ),
                                         Row(
                                           children: [
                                             Expanded(
                                               flex: 2,
                                               child: TextFormField(
                                                 enabled: !_pay,
                                                 controller: _moneyCon,
                                                 decoration: InputDecoration(
                                                   isDense: true,
                                                   filled: true,
                                                   fillColor: Color(0xffEBEBEB),
                                                   contentPadding: EdgeInsets.symmetric(
                                                       horizontal: 20, vertical: 14),
                                                   border: OutlineInputBorder(
                                                       borderSide: BorderSide.none,
                                                       borderRadius: BorderRadius.circular(8)),
                                                   hintText: '만원 단위',
                                                   hintStyle: f16w400grey8,
                                                 ),
                                               ),
                                             ),
                                             Theme(
                                               data: Theme.of(context).copyWith(
                                                 unselectedWidgetColor: Color(0xffdadada),
                                               ),
                                               child: Row(
                                                 children: [
                                                   SizedBox(
                                                     width: 30,
                                                     height: 30,
                                                     child: Checkbox(
                                                       value: _pay,
                                                       shape: RoundedRectangleBorder(
                                                           borderRadius:
                                                               BorderRadius.circular(3)),
                                                       checkColor: Colors.white,
                                                       activeColor: nowColor,
                                                       onChanged: (v) {
                                                         setState(() {
                                                           _pay = !_pay;
                                                         });
                                                       },
                                                     ),
                                                   ),
                                                   Text(
                                                     '협의',
                                                     style: f16w400,
                                                   ),
                                                 ],
                                               ),
                                             ),
                                             const SizedBox(
                                               width: 10,
                                             ),
                                             Expanded(
                                               flex: 1,
                                               child: DecoratedBox(
                                                 decoration: BoxDecoration(
                                                     borderRadius: BorderRadius.circular(8),
                                                     color: Color(0xffebebeb)),
                                                 child: Padding(
                                                   padding: ph20v14,
                                                   child: DropdownButton<String>(
                                                     focusColor: Colors.white,
                                                     isDense: true,
                                                     isExpanded: true,
                                                     underline: Container(),
                                                     icon: Icon(
                                                       Icons.keyboard_arrow_down,
                                                       color: Color(0xff535353),
                                                     ),
                                                     value: _dropdown2,
                                                     //elevation: 5,
                                                     style: TextStyle(color: Colors.white),
                                                     iconEnabledColor: Colors.black,
                                                     items: <String>[
                                                       '월급',
                                                       '주급',
                                                       '시급',
                                                     ].map<DropdownMenuItem<String>>(
                                                         (String value) {
                                                       return DropdownMenuItem<String>(
                                                         value: value,
                                                         child: Text(value, style: f16w400),
                                                       );
                                                     }).toList(),
                                                     hint: Text(
                                                       "월급",
                                                       style: f14w500,
                                                     ),
                                                     onChanged: (v) {
                                                       setState(() {
                                                         _dropdown2 = v;
                                                       });
                                                     },
                                                   ),
                                                 ),
                                               ),
                                             ),
                                           ],
                                         ),
                                         const SizedBox(
                                           height: 16,
                                         ),
                                         Text(
                                           '시간',
                                           style: f18w400,
                                         ),
                                         const SizedBox(
                                           height: 10,
                                         ),
                                         Row(
                                           children: [
                                             // Expanded(
                                             //   flex: 1,
                                             //   child: DecoratedBox(
                                             //     decoration: BoxDecoration(
                                             //         borderRadius: BorderRadius.circular(8),
                                             //         color: Color(0xffebebeb)),
                                             //     child: Padding(
                                             //       padding: ph20v14,
                                             //       child: DropdownButton<String>(
                                             //         focusColor: Colors.white,
                                             //         isDense: true,
                                             //         isExpanded: true,
                                             //         underline: Container(),
                                             //         icon: Icon(
                                             //           Icons.keyboard_arrow_down,
                                             //           color: Color(0xff535353),
                                             //         ),
                                             //         value: _dropdown3,
                                             //         //elevation: 5,
                                             //         style: TextStyle(color: Colors.white),
                                             //         iconEnabledColor: Colors.black,
                                             //         items: _timeList.map<DropdownMenuItem<String>>(
                                             //                 (String value) {
                                             //               return DropdownMenuItem<String>(
                                             //                 value: value,
                                             //                 child: Text(value, style: f16w400),
                                             //               );
                                             //             }).toList(),
                                             //         hint: Text(
                                             //           "월급",
                                             //           style: TextStyle(
                                             //               color: Colors.black,
                                             //               fontSize: 14,
                                             //               fontWeight: FontWeight.w500),
                                             //         ),
                                             //         onChanged: (v) {
                                             //           setState(() {
                                             //             _dropdown3 = v;
                                             //           });
                                             //         },
                                             //       ),
                                             //     ),
                                             //   ),
                                             // ),
                                             Expanded(
                                               flex: 1,
                                               child: DecoratedBox(
                                                 decoration: BoxDecoration(
                                                     borderRadius: BorderRadius.circular(8),
                                                     color: Color(0xffebebeb)),
                                                 child: GestureDetector(
                                                   onTap: () async {
                                                     var ls = await showDialog(context: context, builder: (context){
                                                       return Dialog(
                                                           // insetPadding: EdgeInsets.all(10),
                                                           child: Container(width: Get.width, height: Get.width * 0.3,
                                                             child: JobTimerScreen(
                                                         indexTime: _indexTime,
                                                         indexTime2: _indexTime2,
                                                       ),
                                                           ));
                                                     });
                                                     // var ls =
                                                     //     await Get.to(() => JobTimerScreen(
                                                     //           indexTime: _indexTime,
                                                     //           indexTime2: _indexTime2,
                                                     //         ));

                                                     setState(() {
                                                       _indexTime = ls[0];
                                                       _indexTime2 = ls[1];
                                                     });
                                                   },
                                                   child: Padding(
                                                     padding: ph20v14,
                                                     child: Text(
                                                       '${_indexTime.toString().padLeft(2, '0')} : '
                                                       '${_indexTime2.toString().padLeft(2, '0')}',
                                                       style: f16w400,
                                                       textAlign: TextAlign.center,
                                                     ),
                                                   ),
                                                 ),
                                               ),
                                             ),
                                             const SizedBox(
                                               width: 10,
                                             ),
                                             Text(
                                               ' ~ ',
                                               style: f16w400,
                                             ),
                                             const SizedBox(
                                               width: 10,
                                             ),
                                             Expanded(
                                               flex: 1,
                                               child: DecoratedBox(
                                                 decoration: BoxDecoration(
                                                     borderRadius: BorderRadius.circular(8),
                                                     color: Color(0xffebebeb)),
                                                 child: GestureDetector(
                                                   onTap: () async {
                                                     var ls = await showDialog(context: context, builder: (context){
                                                       return Dialog(
                                                         // insetPadding: EdgeInsets.all(10),
                                                           child: Container(width: Get.width, height: Get.width * 0.3,
                                                             child: JobTimerScreen(
                                                               indexTime: _indexTime3,
                                                               indexTime2: _indexTime4,
                                                             ),
                                                           ));
                                                     });

                                                     // var ls =
                                                     //     await Get.to(() => JobTimerScreen(
                                                     //           indexTime: _indexTime3,
                                                     //           indexTime2: _indexTime4,
                                                     //         ));

                                                     setState(() {
                                                       _indexTime3 = ls[0];
                                                       _indexTime4 = ls[1];
                                                     });
                                                   },
                                                   child: Padding(
                                                     padding: ph20v14,
                                                     child: Text(
                                                       '${_indexTime3.toString().padLeft(2, '0')} : '
                                                       '${_indexTime4.toString().padLeft(2, '0')}',
                                                       style: f16w400,
                                                       textAlign: TextAlign.center,
                                                     ),
                                                   ),
                                                 ),
                                               ),
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
                               )
                              : Container(),

                        ],
                      ),
                    ),
                  ),
                ),
                args.whichScreen=='job'?Container():SizedBox(
                  height: 100,
                ),
                Footer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> jobUpload(
      String title,
      String body,
      int gender,
      String age,
      String sido,
      String ageValue,
      String payValue,
      bool pay,
      String money,
      int openH,
      int openM,
      int closeH,
      int closeM) async {
    final us = Get.put(UserState());
    CollectionReference ref =
        FirebaseFirestore.instance.collection('jobHunting');
    ref.add({
      'age': age,
      'sido': sido,
      'ageValue': ageValue,
      'body': body,
      'closeH': closeH,
      'closeM': closeM,
      'docId': '',
      'gender': gender == 0
          ? '남자'
          : gender == 1
              ? '여자'
              : '성별 무관',
      'hasImage': 'false',
      'openH': openH,
      'openM': openM,
      'pay': pay ? '협의' : money,
      'payValue': payValue,
      'teacher': '${us.userList[0].phoneNumber}',
      'title': title,
      'images': [],
      'jobIs': 'true',
      'createDate': '${DateTime.now()}',
    }).then((doc) async {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('jobHunting').doc(doc.id);
      await userDocRef.update({'docId': '${doc.id}'});
      if (_imageFileList!.length != 0) {
        await userDocRef.update({'hasImage': 'true'});
        await uploadFile(doc.id, '${us.userList[0].phoneNumber}', 'jobHunting');
      }
    });
  }

  Future<void> communityUpload(String title, String body) async {
    final us = Get.put(UserState());
    final args = ModalRoute.of(context)!.settings.arguments as StoryWriteScreen;
    CollectionReference ref = FirebaseFirestore.instance.collection(args.whichScreen=='qna'?'qna':'story');

    ref.add({
      'id': '${args.whichScreen=='qna'? us.userList[0].id:us.userList[0].phoneNumber}',
      'docId': '',
      'title': title,
      'body': body,
      'hasImage': 'false',
      '${args.whichScreen=='qna'? 'state' : 'status'}': '${args.whichScreen=='qna'? '대기중' : '게시중'}',
      'type': '${us.userList[0].userType}',
      'name': '${us.userList[0].name}',
      'images': [],
      'createDate': '${DateTime.now()}',
      '${args.whichScreen=='qna'? 'admin' : 'temp'}': '',
    }).then((doc) async {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection(args.whichScreen=='qna'?'qna':'story').doc(doc.id);
      await userDocRef.update({'docId': '${doc.id}'});
      if (_imageFileList!.length != 0) {
        await userDocRef.update({'hasImage': 'true'});
        await uploadFile(doc.id, '${us.userList[0].phoneNumber}', args.whichScreen=='qna'?'qna':'story');
      }
      args.refreshIndicatorKey?.currentState?.show();
    });
  }

  Future<void> _openImagePicker() async {
    try {
      final List<XFile>? selectedImages = await _picker.pickMultiImage();
      if (selectedImages!.isNotEmpty) {
        if (selectedImages.length > 10) {
          showOnlyConfirmDialog(context, '사진은 10장까지 올리실 수 있습니다');
        } else {
          if (_imageFileList!.length + selectedImages.length > 10) {
            showOnlyConfirmDialog(context, '사진은 10장까지 올리실 수 있습니다');
          } else {
            _imageFileList!.addAll(selectedImages);
          }
        }
        setState(() {});
      }
    } catch (e) {
      // print('image error : $e');
    }
  }

  Future uploadFile(String docId, String phoneNumber, String category) async {
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
        FirebaseFirestore.instance.collection(category).doc(docId);
    List<String> ls = [];
    for (int i = 0; i < _imageFileList!.length; i++) {
      ls.add('${DateTime.now()}');
      final firebaseStorageRef = FirebaseStorage.instance
          .ref()
          .child('picture')
          .child('$phoneNumber')
          .child('$docId')
          .child(ls[i]);
      final uploadTask = kIsWeb
          ? firebaseStorageRef.putData(
              await _imageFileList![i].readAsBytes(),
              SettableMetadata(contentType: 'image/jpeg'),
            )
          // .whenComplete(() async {
          //       await firebaseStorageRef.getDownloadURL().then((value) {
          //         uploadedPhotoUrl = value;
          //       });})
          : firebaseStorageRef.putFile(File(_imageFileList![i].path),
              SettableMetadata(contentType: 'image/png'));
      await uploadTask;
    }
    final pathReference = FirebaseStorage.instance
        .ref()
        .child('picture')
        .child('$phoneNumber')
        .child(docId);
    ListResult nestedResult = await pathReference.listAll();
    nestedResult.items.forEach((element) async {
      for (int i = 0; i < ls.length; i++) {
        if ('${element.name}' == ls[i]) {
          await userDocRef.update({
            "images": FieldValue.arrayUnion(['${element.name}'])
          });
        }
      }
    });
    // ListResult nestedResult = await pathReference.listAll();
    // nestedResult.items.forEach((element) async {
    //   await userDocRef.update({
    //     "images": FieldValue.arrayUnion(['${element.name}'])
    //   });
    // });

    setState(() {
      _imageLoading = false;
      Get.back();
    });
  }

  Future<void> _editWriting(String collection) async {
    final cs = Get.put(CommunityState());
    final js = Get.put(JobState());
    final us = Get.put(UserState());
    DocumentReference userRef = FirebaseFirestore.instance
        .collection(collection)
        .doc(collection == 'jobHunting' ? '${js.jobDocId}' : collection == 'qna' ? us.qnaDocId.value
        : cs.communityList[0]['docId']);
    if (_editImg.length != 0 && _imageFileList!.length == 0) {
      collection == 'jobHunting'
          ? await userRef.update({
              'title': _titleCon.text,
              'body': _bodyCon.text,
              'hasImage': 'true',
              'images': _editImg,
              'age': _ageCon.text,
              'sido': _sidoCon.text,
              'ageValue': _dropdown!,
              'closeH': _indexTime3,
              'closeM': _indexTime4,
              'gender': _gender == 0
                  ? '남자'
                  : _gender == 1
                      ? '여자'
                      : '성별 무관',
              'openH': _indexTime,
              'openM': _indexTime2,
              'pay': _pay ? '협의' : _moneyCon.text,
              'payValue': _dropdown2!,
            })
          : await userRef.update({
              'title': _titleCon.text,
              'body': _bodyCon.text,
              'hasImage': 'true',
              'images': _editImg,
            });
    } else if (_editImg.length == 0 && _imageFileList!.length != 0) {
      collection == 'jobHunting'
          ? await userRef.update({
              'title': _titleCon.text,
              'body': _bodyCon.text,
              'hasImage': 'true',
              'images': [],
              'age': _ageCon.text,
              'sido': _sidoCon.text,
              'ageValue': _dropdown!,
              'closeH': _indexTime3,
              'closeM': _indexTime4,
              'gender': _gender == 0
                  ? '남자'
                  : _gender == 1
                      ? '여자'
                      : '성별 무관',
              'openH': _indexTime,
              'openM': _indexTime2,
              'pay': _pay ? '협의' : _moneyCon.text,
              'payValue': _dropdown2!,
            })
          : await userRef.update({
              'title': _titleCon.text,
              'body': _bodyCon.text,
              'hasImage': 'true',
              'images': [],
            });
      await deleteFolder(
          path:
              "picture/${us.userList[0].phoneNumber}/${collection == 'jobHunting' ? '${js.jobDocId}' : cs.communityList[0]['docId']}");
      await uploadFile(
          collection == 'jobHunting' ? '${js.jobDocId}' : collection == 'qna' ? us.qnaDocId.value : cs.communityList[0]['docId'],
          '${us.userList[0].phoneNumber}', collection);
    } else if (_editImg.length != 0 && _imageFileList!.length != 0) {
      collection == 'jobHunting'
          ? await userRef.update({
              'title': _titleCon.text,
              'body': _bodyCon.text,
              'hasImage': 'true',
              'images': _editImg,
              'age': _ageCon.text,
              'sido': _sidoCon.text,
              'ageValue': _dropdown!,
              'closeH': _indexTime3,
              'closeM': _indexTime4,
              'gender': _gender == 0
                  ? '남자'
                  : _gender == 1
                      ? '여자'
                      : '성별 무관',
              'openH': _indexTime,
              'openM': _indexTime2,
              'pay': _pay ? '협의' : _moneyCon.text,
              'payValue': _dropdown2!,
            })
          : await userRef.update({
              'title': _titleCon.text,
              'body': _bodyCon.text,
              'hasImage': 'true',
              'images': _editImg,
            });
      await uploadFile(
          collection == 'jobHunting'
              ? '${js.jobDocId}'
              : collection == 'qna' ? us.qnaDocId.value : cs.communityList[0]['docId'],
          '${us.userList[0].phoneNumber}',
          collection);
    } else if (_editImg.length == 0 && _imageFileList!.length == 0) {
      collection == 'jobHunting'
          ? await userRef.update({
              'title': _titleCon.text,
              'body': _bodyCon.text,
              'hasImage': 'false',
              'images': [],
              'age': _ageCon.text,
              'sido': _sidoCon.text,
              'ageValue': _dropdown!,
              'closeH': _indexTime3,
              'closeM': _indexTime4,
              'gender': _gender == 0
                  ? '남자'
                  : _gender == 1
                      ? '여자'
                      : '성별 무관',
              'openH': _indexTime,
              'openM': _indexTime2,
              'pay': _pay ? '협의' : _moneyCon.text,
              'payValue': _dropdown2!,
            })
          : await userRef.update({
              'title': _titleCon.text,
              'body': _bodyCon.text,
              'hasImage': 'false',
              'images': [],
            });

      await deleteFolder(
          path:
              "picture/${us.userList[0].phoneNumber}/${collection == 'jobHunting' ? '${js.jobDocId}' : collection == 'qna' ? us.qnaDocId.value : cs.communityList[0]['docId']}");
    }
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
}
