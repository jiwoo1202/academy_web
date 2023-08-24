import 'dart:io';

import 'package:academy/provider/user_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../components/dialog/showAlertDialog.dart';
import '../../../components/tile/textform_field.dart';
import '../../../util/colors.dart';
import '../../../util/font/font.dart';
import '../../../util/loading.dart';
import '../../../util/mouse_scroll.dart';

class QnaWrite extends StatefulWidget {
  final String? state;
  final String? title;
  final String? body;
  final String? docId;
  final GlobalKey<RefreshIndicatorState>? refreshIndicatorKey;

  const QnaWrite(
      {Key? key,
      this.state,
      this.title,
      this.body,
      this.docId,
      this.refreshIndicatorKey})
      : super(key: key);

  @override
  State<QnaWrite> createState() => _QnaWriteState();
}

class _QnaWriteState extends State<QnaWrite> {
  TextEditingController _titleCon = TextEditingController();
  TextEditingController _bodyCon = TextEditingController();
  List<XFile>? _imageFileList = []; // 이미지 파일 담기
  List _firebaseImg = []; // 수정상태  일 때 사진담기
  List _editImg = [];
  final ImagePicker _picker = ImagePicker();
  bool _imageLoading = false;
  final us = Get.put(UserState());
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      new GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    if (widget.state == 'edit') {
      _titleCon.text = widget.title!;
      _bodyCon.text = widget.body!;
      _editImg = us.getmyQna[0]['images'];
      print(_editImg);

      if (us.getmyQna[0]['images'].length != 0) {
        for (int i = 0; i < us.getmyQna[0]['images'].length; i++) {
          _firebaseImg.add(
              'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/picture%2F${us.userList[0].phoneNumber}%2F${widget.docId}%2F${us.getmyQna[0]['images'][i]}?alt=media');
        }
        print(_firebaseImg);
      }
    }

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              SvgPicture.asset(
                'assets/logo.svg',
                width:
                    (GetPlatform.isWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
                height:
                    (GetPlatform.isWeb && (Get.width * 0.2 <= 171)) ? 16 : 20,
              ),
              SizedBox(
                width: 8,
              ),
              GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                  ? Container()
                  : Text('QnA')
            ],
          ),
          automaticallyImplyLeading: false,
          centerTitle: false,
          backgroundColor: nowColor,
          actions: [
            GestureDetector(
              onTap: () async {
                if (_titleCon.text.trim().isEmpty ||
                    _bodyCon.text.trim().isEmpty) {
                  showOnlyConfirmDialog(context, '제목 혹은 내용을 입력해주세요');
                } else {
                  showComponentDialog(context, '업로드하시겠습니까?', () async {
                    if (widget.state == 'edit') {
                      await _editWriting('${widget.docId}');
                      showConfirmTapDialog(context, '업로드 되었습니다', () {
                        widget.refreshIndicatorKey?.currentState?.show();
                        Get.back();
                        Get.back();
                        Get.back();
                      });
                    } else {
                      Get.back();
                      await qnaUpload();
                      showConfirmTapDialog(context, '업로드 되었습니다', () {
                        widget.refreshIndicatorKey?.currentState?.show();
                        Get.back();
                        Get.back();
                      });
                    }
                  });
                }
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 28),
                child: Center(
                    child: Text(
                  '업로드',
                  style: f16Whitew700,
                )),
              ),
            )
          ],
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: GetPlatform.isWeb
                          ? (Get.width * 0.2 <= 171)
                              ? 20
                              : Get.width * 0.24
                          : 24,
                      vertical: 20),
                  child: TextFormFields(
                      controller: _titleCon,
                      onChanged: (v) {
                        // us.qnaTitle.value = _titleCon.text;
                      },
                      obscureText: true,
                      hintText: '제목을 입력해주세요',
                      surffixIcon: ''),
                ),
                const SizedBox(
                  height: 16,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: GetPlatform.isWeb
                          ? (Get.width * 0.2 <= 171)
                              ? 20
                              : Get.width * 0.24
                          : 24,
                      vertical: 20),
                  child: ScrollConfiguration(
                    behavior: MyCustomScrollBehavior(),
                    child: SingleChildScrollView(
                      physics: const ClampingScrollPhysics(),
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (_imageFileList!.length + _firebaseImg.length >
                                  9) {
                                showOnlyConfirmDialog(
                                    context, '사진은 10장까지 올리실 수 있습니다');
                              } else {
                                await _openImagePicker();
                              }
                            },
                            child: Container(
                              height: GetPlatform.isWeb
                                  ? (Get.width * 0.2 <= 171)
                                      ? 80
                                      : Get.width * 0.13
                                  : Get.width * 0.23,
                              width: GetPlatform.isWeb
                                  ? (Get.width * 0.2 <= 171)
                                      ? 80
                                      : Get.width * 0.13
                                  : Get.width * 0.23,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: const Color(0xffE9E9E9),
                                ),
                                color: Colors.white,
                              ),
                              padding: EdgeInsets.symmetric(
                                  horizontal:
                                      (Get.width * 0.2 <= 171) ? 12 : 24,
                                  vertical: 14),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icon/camera.svg',
                                    height: 24,
                                    width: 24,
                                  ),
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
                          // Container(
                          //   height: _firebaseImg.length == 0 ? 1 : 132,
                          //   child: ListView.builder(
                          //     shrinkWrap: true,
                          //     itemCount: _firebaseImg.length,
                          //     physics: const ClampingScrollPhysics(),
                          //     scrollDirection: Axis.horizontal,
                          //     itemBuilder: (context, index) {
                          //       return Container(
                          //         margin: EdgeInsets.only(right: 10),
                          //         child: Stack(
                          //           children: [
                          //             ClipRRect(
                          //                 borderRadius: BorderRadius.circular(10.0),
                          //                 child: ExtendedImage.network(
                          //                   _firebaseImg[index],
                          //                   fit: BoxFit.fill,
                          //                   width: 132,
                          //                   height: 132,
                          //                   cache: false,
                          //                   enableLoadState: false,
                          //                 )),
                          //             Positioned(
                          //               child: GestureDetector(
                          //                 onTap: () {
                          //                   _firebaseImg.removeAt(index);
                          //                   _editImg.removeAt(index);
                          //
                          //                   setState(() {});
                          //                 },
                          //                 child: Container(
                          //                   height: 24,
                          //                   width: 24,
                          //                   decoration: BoxDecoration(
                          //                       color: Colors.grey.withOpacity(0.4),
                          //                       borderRadius: BorderRadius.circular(100)),
                          //                   child: Icon(
                          //                     Icons.close,
                          //                     color: Colors.white,
                          //                     size: 14,
                          //                   ),
                          //                 ),
                          //               ),
                          //               top: 3,
                          //               right: 5,
                          //             ),
                          //           ],
                          //         ),
                          //         decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
                          //       );
                          //     },
                          //   ),
                          // ),
                          Container(
                            height: _firebaseImg.length == 0
                                ? 1
                                : GetPlatform.isWeb
                                    ? (Get.width * 0.2 <= 171)
                                        ? 80
                                        : Get.width * 0.13
                                    : Get.width * 0.23,
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
                                              width: GetPlatform.isWeb
                                                  ? (Get.width * 0.2 <= 171)
                                                      ? 80
                                                      : Get.width * 0.13
                                                  : Get.width * 0.23,
                                              height: GetPlatform.isWeb
                                                  ? (Get.width * 0.2 <= 171)
                                                      ? 80
                                                      : Get.width * 0.13
                                                  : Get.width * 0.23,
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
                            height: _imageFileList!.length == 0
                                ? 1
                                : GetPlatform.isWeb
                                    ? (Get.width * 0.2 <= 171)
                                        ? 80
                                        : Get.width * 0.13
                                    : Get.width * 0.23,
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
                                            child: GetPlatform.isWeb
                                                ? Image.network(
                                                    _imageFileList![index].path,
                                                    // fit: BoxFit.none,
                                                    width:
                                                        (Get.width * 0.2 <= 171)
                                                            ? 80
                                                            : Get.width * 0.13,
                                                    height:
                                                        (Get.width * 0.2 <= 171)
                                                            ? 80
                                                            : Get.width * 0.13,
                                                  )
                                                : Image.file(
                                                    File(_imageFileList![index]
                                                        .path),
                                                    width: Get.width * 0.23,
                                                    height: Get.width * 0.23,
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
                const SizedBox(
                  height: 20,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: GetPlatform.isWeb
                          ? (Get.width * 0.2 <= 171)
                              ? 20
                              : Get.width * 0.24
                          : 24,
                      vertical: 20),
                  child: TextField(
                    controller: _bodyCon,
                    onChanged: (v) {
                      // us.qnaBody.value = _bodyCon.text;
                    },
                    keyboardType: TextInputType.multiline,
                    style: f16w400,
                    minLines: 10,
                    maxLines: null,
                    decoration: InputDecoration(
                        hintText: '내용을 입력해주세요',
                        hintStyle: f16w400greyA,
                        enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1, color: Colors.transparent)),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                                width: 1, color: Colors.transparent))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openImagePicker() async {
    final us = Get.put(UserState());
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
      print('image error : $e');
    }
  }

  Future<void> qnaUpload() async {
    final us = Get.put(UserState());
    CollectionReference ref = FirebaseFirestore.instance.collection('qna');
    ref.add({
      'title': us.qnaTitle.value,
      'body': us.qnaBody.value,
      'images': [],
      'writeDocId': us.userList[0].docId,
      'createDate': '${DateTime.now()}',
      'hasImage': false,
      'state': '대기중',
      'admin': '',
    }).then((doc) async {
      DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('qna').doc(doc.id);
      await userDocRef.update({'docId': '${doc.id}'});
      if (_imageFileList!.length != 0) {
        await userDocRef.update({'hasImage': 'true'});
        await uploadFile(doc.id, '${us.userList[0].phoneNumber}', 'qna');
      } else {
        await userDocRef.update({'hasImage': 'false'});
      }
    });
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
      final uploadTask = GetPlatform.isWeb
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

  Future<void> _editWriting(String docId) async {
    final us = Get.put(UserState());
    DocumentReference userRef =
        FirebaseFirestore.instance.collection('qna').doc(docId);

    // 사진이 0이 아니고 사진을 추가하지 않았을 때
    if (_editImg.length != 0 && _imageFileList!.length == 0) {
      await userRef.update({
        'title': _titleCon.text,
        'body': _bodyCon.text,
        'hasImage': 'true',
        'images': _editImg,
      });
      // 변경한 사진이 없고 추가한 사진만 있을 때
    } else if (_editImg.length != 0 && _imageFileList!.length != 0) {
      await userRef.update({
        'title': _titleCon.text,
        'body': _bodyCon.text,
        'hasImage': 'true',
        'state': '대기중',
        'images': _editImg,
        'createDate': '${DateTime.now()}',
        'docId': widget.docId,
        'writeDocId': '${us.userList[0].docId}',
      });
      await uploadFile(
          '${widget.docId}', '${us.userList[0].phoneNumber}', 'qna');
    } else if (_editImg.length == 0 && _imageFileList!.length != 0) {
      await userRef.update({
        'title': _titleCon.text,
        'body': _bodyCon.text,
        'hasImage': 'true',
        'state': '대기중',
        'images': _editImg,
        'createDate': '${DateTime.now()}',
        'docId': widget.docId,
        'writeDocId': '${us.userList[0].docId}',
      });
      await uploadFile(
          '${widget.docId}', '${us.userList[0].phoneNumber}', 'qna');
    } else if (_editImg.length == 0 && _imageFileList!.length == 0) {
      await userRef.update({
        'title': _titleCon.text,
        'body': _bodyCon.text,
        'hasImage': 'false',
        'state': '대기중',
        'images': [],
        'createDate': '${DateTime.now()}',
        'docId': widget.docId,
        'writeDocId': '${us.userList[0].docId}',
      });
    }
    Get.back();
  }
}
