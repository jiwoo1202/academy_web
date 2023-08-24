import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/components/footer/footer.dart';
import 'package:academy/components/tile/textform_field.dart';
import 'package:academy/firebase/firebase_user.dart';
import 'package:academy/provider/user_state.dart';
import 'package:academy/util/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../util/colors.dart';
import '../../util/font/font.dart';
import 'passwordChange.dart';

class FindPassword extends StatefulWidget {
  static final String id = '/find_password';

  const FindPassword({Key? key}) : super(key: key);

  @override
  State<FindPassword> createState() => _FindPasswordState();
}

class _FindPasswordState extends State<FindPassword> {
  TextEditingController _phoneCon = TextEditingController();
  TextEditingController _otpCon = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  List _hasList = [];
  int _doubleCheck = 0;
  bool _phoneAuth = false;
  String verificationId = '';
  String passWord = '';
  bool _isLoading = false;
  final us = Get.put(UserState());

  @override
  void initState() {
    // Future.delayed(Duration.zero, () async {
    //   // us.findPassWord.value = '';
    //   // await findPassWord(_phoneCon.text);
    //   // setState(() {
    //   //   _isLoading = false;
    //   // });
    // });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Padding(
          padding: Get.width < 1024 ?const EdgeInsets.only(left: 100) :const EdgeInsets.only(left: 370),
          child: Row(
            children: [
              GestureDetector(
                onTap: (){
                  Get.back();
                },
                  child: SvgPicture.asset('assets/logo.svg')),
            ],
          ),
        ),
        backgroundColor: GetPlatform.isWeb ? nowColor : primaryColor,
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Center(
          child: Column(
            children: [
              Container(
                width: Get.width * 0.4,
                height: Get.height * 0.6,
                padding: const EdgeInsets.fromLTRB(24, 25, 24, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: TextFormFields(
                            controller: _phoneCon,
                            obscureText: true,
                            hintText: '번호를 입력해주세요',
                            keyboardType: TextInputType.number,
                            surffixIcon: '0',
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(13),
                              FilteringTextInputFormatter.digitsOnly,
                              MaskTextInputFormatter(mask: '###-####-####')
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () async {
                            _hasList.clear();
                            await _findId(_phoneCon.text.replaceAll('-',''));
                            if (_hasList.length != 0) {
                              //휴대폰 인증번호 보내기
                              if (_phoneCon.text.trim().isEmpty) {
                                showOnlyConfirmDialog(context, '번호를 입력해주세요');
                              } else {
                                _auth.verifyPhoneNumber(
                                  phoneNumber: '+82${_phoneCon.text}',
                                  verificationCompleted:
                                      (PhoneAuthCredential credential) async {
                                    await _auth
                                        .signInWithCredential(credential)
                                        .then((value) => print('success'));
                                  },
                                  verificationFailed:
                                      (verificationFalied) async {
                                    showOnlyConfirmDialog(
                                        context, "인증번호 보내기가 실패하였습니다.");
                                    // print('${verificationFalied.message}');
                                  },
                                  codeSent:
                                      (verifiationId, resendingToken) async {
                                    showOnlyConfirmDialog(
                                        context, "인증번호를 보냈습니다");
                                    setState(() {
                                      verificationId = verifiationId;
                                    });
                                  },
                                  timeout: Duration(seconds: 30),
                                  codeAutoRetrievalTimeout:
                                      (verificationId) async {},
                                );
                              }
                            } else {
                              showConfirmTapDialog(context, '휴대폰 번호를 확인해주세요',
                                  () {
                                Get.back();
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            decoration: BoxDecoration(
                              color: Color(0xffEBEBEB),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              '인증번호',
                              style: (GetPlatform.isWeb &&
                                      (Get.width * 0.2 <= 171))
                                  ? f12w700primary
                                  : f16w700primary,
                            ),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      height: 25,
                    ),
                    Row(
                      children: [
                        Flexible(
                          flex: 2,
                          child: TextFormFields(
                            controller: _otpCon,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            obscureText: true,
                            hintText: '인증번호를 입력해주세요',
                            surffixIcon: '0',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (_doubleCheck == 0) {
                              PhoneAuthCredential phoneAuthCredential =
                                  PhoneAuthProvider.credential(
                                      verificationId: verificationId,
                                      smsCode: _otpCon.text);
                              signInWithPhoneAuthCredential(
                                  phoneAuthCredential);
                            }
                            setState(() {});
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 20, vertical: 15),
                            decoration: BoxDecoration(
                              color: Color(0xffEBEBEB),
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                            child: Text(
                              '인증번호 확인 ',
                              textAlign: TextAlign.center,
                              style: (GetPlatform.isWeb &&
                                      (Get.width * 0.2 <= 171))
                                  ? f12w700primary
                                  : f16w700primary,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 16,
                    ),
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (_phoneAuth == true) {
                          us.phoneText.value = _phoneCon.text;
                          Get.offAndToNamed(PasswordChange.id);
                        } else if (_phoneCon.text == '') {
                          showOnlyConfirmDialog(context, '휴대폰 번호를 입력해 주세요');
                        } else {
                          showOnlyConfirmDialog(context, '등록되지않은 휴대폰 번호입니다.');
                        }
                        // Get.offAndToNamed(PasswordChange.id);
                      },
                      child: SizedBox(
                        height: Get.height * 0.06,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xff270BD3),
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '비밀번호 변경',
                                style: TextStyle(
                                    color: Color(0xffFAFAFA),
                                    fontFamily: 'Pretendard',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Footer()
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _findId(String phone) async {
    print('??${phone}');
    CollectionReference ref = FirebaseFirestore.instance.collection('user');
    QuerySnapshot snapshot = await ref.where('phoneNumber', isEqualTo: '${phone}').get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    List a = allData;
    _hasList = a;
    print('has :: ${phone}');
    print('has :: ${_hasList}');
  }

  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    // print('test111');
    try {
      // print('2');
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      if (authCredential.user != null) {
        // print('인공입니다');
        setState(() {
          _phoneAuth = true;
          showOnlyConfirmDialog(context, "인증이 완료되었습니다.");
          // print("인증완료 및 로그인성공 _auth ok 는 true");
        });
        // print('3');
        _doubleCheck = 1;
        await _auth.currentUser!.delete();
        // print("auth정보삭제");
        _auth.signOut();
        // print("phone 로그인된것 로그아웃");
        // cancelTimer();
        // print('인증번호 일치');
        //     CollectionReference ref = FirebaseFirestore.instance.collection('fcm');
        //     QuerySnapshot snapshot = await ref.where('1', isEqualTo: _otpCon.text).get();
        //     final allData = snapshot.docs.map((doc) => {doc.data()}).toList();
        //     List as = allData;
        //     if (as.length != 0) {
        //       FirebaseFirestore.instance
        //           .collection('fcm')
        //           .doc(as[0].toString().replaceAll('{', '').replaceAll('}', '').split(',')[3].split(' ')[2])
        //           .delete();
        //     }
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _phoneAuth = false;
      });
      showOnlyConfirmDialog(context, "인증번호가 일치하지 않습니다.");
      print('Error Log Phone Auth : ${e}');
    }
  }
}
