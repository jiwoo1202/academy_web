import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/components/tile/textform_field.dart';
import 'package:academy/provider/user_state.dart';
import 'package:academy/screen/login/login_main_screen.dart';
import 'package:academy/screen/register/policy.dart';
import 'package:academy/screen/register/privatePolicy.dart';
import 'package:academy/util/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'dart:html' as html;

import '../../components/footer/footer.dart';
import '../../util/font/font.dart';
import '../leadingPage.dart';

class RegisterMainScreen extends StatefulWidget {
  static final String id = '/register_main';

  const RegisterMainScreen({Key? key}) : super(key: key);

  @override
  State<RegisterMainScreen> createState() => _RegisterMainScreenState();
}

class _RegisterMainScreenState extends State<RegisterMainScreen>
    with TickerProviderStateMixin {
  TextEditingController _idCon = TextEditingController();
  TextEditingController _pwCon = TextEditingController();
  TextEditingController _phoneCon = TextEditingController();
  TextEditingController _otpCon = TextEditingController();
  TextEditingController _nameCon = TextEditingController();
  TextEditingController _birthCon = TextEditingController();
  TextEditingController _nickNameCon = TextEditingController();
  late TabController _nestedController;

  // TextEditingController _monthCon = TextEditingController();
  // TextEditingController _dayCon = TextEditingController();
  bool _obscureText = false;
  var maskFormatter = new MaskTextInputFormatter(mask: '###-####-####');
  var maskFormatter2 = new MaskTextInputFormatter(mask: '####/##/##');
  String? selectedValue;
  FirebaseAuth _auth = FirebaseAuth.instance;
  String verificationId = '';
  bool otpCode = false;
  bool _phoneAuth = false;
  bool _authOk = false;
  bool _isConfirm = false;
  int _doubleCheck = 0;
  bool typeCheck = false;
  bool idDoubleCheck = false; //아이디 중복 체크
  bool nickCheck = false; // 닉네임 중복 체크
  bool idCheck = false;
  bool _isLoading = true;
  bool policyCheck = false; // 이용약관 체크
  bool privatePolicyCheck = false; // 개인정보 처리방침 체크
  @override
  void initState() {
    final us = Get.put(UserState());
    _phoneAuth = false;
    typeCheck = false;
    idCheck = false;
    super.initState();
    _nestedController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _idCon.dispose();
    _pwCon.dispose();
    _phoneCon.dispose();
    _otpCon.dispose();
    _nameCon.dispose();
    _birthCon.dispose();
    bool _phoneAuth = false;
    _nestedController.dispose();

    // _monthCon.dispose();
    // _dayCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final us = Get.put(UserState());
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).requestFocus(new FocusNode());
      },
      child: Scaffold(
        appBar: AppBar(
          // title: Text(GetPlatform.isWeb ? "ACADEMY WEB" : "ACADEMY"),
          automaticallyImplyLeading: false,
          title: GetPlatform.isWeb
              ? Row(
                  children: [
                    SvgPicture.asset('assets/logo.svg'),
                  ],
                )
              : SvgPicture.asset('assets/logo.svg'),
          backgroundColor: GetPlatform.isWeb ? nowColor : primaryColor,
        ),
        body: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 25, 24, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Text('${us.id}',style: f16w500,),
                // Obx(() =>Text('${us.id}',style: f16w500,)),
                Row(
                  children: [
                    GetPlatform.isWeb
                        ? TextFormFields(
                            controller: _idCon,
                            onChanged: (v) {
                              us.id.value = _idCon.text.trim();
                            },
                            obscureText: true,
                            hintText: "아이디",
                            surffixIcon: "0")
                        : Expanded(
                            flex: 2,
                            child: TextFormFields(
                                controller: _idCon,
                                onChanged: (v) {
                                  us.id.value = _idCon.text.trim();
                                },
                                obscureText: true,
                                hintText: "아이디",
                                surffixIcon: "0"),
                          ),
                    SizedBox(
                      width: 10,
                    ),
                    GetPlatform.isWeb
                        ? GestureDetector(
                            onTap: () async {
                              if (_idCon.text == '') {
                                showOnlyConfirmDialog(
                                    context, "공백은 입력 불가능 합니다.");
                              } else {
                                if (RegExp(r"^[a-zA-Z|0-9]*$")
                                        .hasMatch(_idCon.text) ==
                                    true) {
                                  await registerIdCheck(us.id.value);
                                  if (idCheck == false) {
                                    setState(() {
                                      idCheck = false;
                                    });
                                  } else {
                                    setState(() {
                                      idCheck = true;
                                    });
                                  }
                                  idCheck == false
                                      ? showOnlyConfirmDialog(
                                          context, '사용불가능한 아이디입니다.')
                                      : showOnlyConfirmDialog(
                                          context, '사용가능한 아이디입니다.');
                                } else {
                                  showOnlyConfirmDialog(
                                      context, '아이디는 영어랑 숫자만 입력 가능합니다.');
                                }
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: Color(0xffEBEBEB),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text('중복 체크',
                                  style: (GetPlatform.isWeb &&
                                          (Get.width * 0.2 <= 171))
                                      ? f12w700primary
                                      : f16w700primary),
                            ),
                          )
                        : Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () async {
                                if (_idCon.text == '') {
                                  showOnlyConfirmDialog(
                                      context, "공백은 입력 불가능 합니다.");
                                } else {
                                  if (RegExp(r"^[a-zA-Z|0-9]*$")
                                          .hasMatch(_idCon.text) ==
                                      true) {
                                    await registerIdCheck(us.id.value);
                                    if (idCheck == false) {
                                      setState(() {
                                        idCheck = false;
                                      });
                                    } else {
                                      setState(() {
                                        idCheck = true;
                                      });
                                    }
                                    idCheck == false
                                        ? showOnlyConfirmDialog(
                                            context, '사용불가능한 아이디입니다.')
                                        : showOnlyConfirmDialog(
                                            context, '사용가능한 아이디입니다.');
                                  } else {
                                    showOnlyConfirmDialog(
                                        context, '아이디는 영어랑 숫자만 입력 가능합니다.');
                                  }
                                }
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0xffEBEBEB),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '중복체크',
                                      style: (GetPlatform.isWeb &&
                                              (Get.width * 0.2 <= 171))
                                          ? f12w700primary
                                          : f16w700primary,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                TextFormFields(
                  controller: _pwCon,
                  onChanged: (v) {
                    us.pw.value = _pwCon.text.trim();
                  },
                  obscureText: _obscureText,
                  hintText: '비밀번호를 입력해주세요',
                  surffixIcon: '1',
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    GetPlatform.isWeb
                        ? TextFormFields(
                            controller: _phoneCon,
                            onChanged: (v) {
                              us.number.value = _phoneCon.text.trim();
                            },
                            obscureText: true,
                            enableText: !_phoneAuth,
                            hintText: '휴대폰 번호를 입력해주세요',
                            keyboardType: TextInputType.number,
                            surffixIcon: '0',
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(13),
                              FilteringTextInputFormatter.digitsOnly,
                              MaskTextInputFormatter(mask: '###-####-####')
                            ],
                          )
                        : Expanded(
                            flex: 2,
                            child: TextFormFields(
                              controller: _phoneCon,
                              onChanged: (v) {
                                us.number.value = _phoneCon.text.trim();
                              },
                              obscureText: true,
                              hintText: '휴대폰 번호를 입력해주세요',
                              keyboardType: TextInputType.number,
                              surffixIcon: '0',
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(13),
                                FilteringTextInputFormatter.digitsOnly,
                                MaskTextInputFormatter(mask: '###-####-####')
                              ],
                            ),
                          ),
                    SizedBox(
                      width: 10,
                    ),
                    GetPlatform.isWeb
                        ? GestureDetector(
                            onTap: () {
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
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
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
                        : Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xffEBEBEB),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xffEBEBEB),
                                  elevation: 0,
                                ),
                                onPressed: () async {
                                  //휴대폰 인증번호 보내기
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
                                },
                                child: Text(
                                  '인증번호',
                                  style: (GetPlatform.isWeb &&
                                          (Get.width * 0.2 <= 171))
                                      ? f12w700primary
                                      : f16w700primary,
                                ),
                              ),
                            ),
                          )
                  ],
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    GetPlatform.isWeb
                        ? TextFormFields(
                            controller: _otpCon,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(6),
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            obscureText: true,
                            hintText: '인증번호를 입력해주세요',
                            surffixIcon: '0',
                            enableText: !_phoneAuth,
                            keyboardType: TextInputType.number,
                          )
                        : Expanded(
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
                    SizedBox(
                      width: 10,
                    ),
                    GetPlatform.isWeb
                        ? GestureDetector(
                            onTap: () {
                              if (_doubleCheck == 0) {
                                PhoneAuthCredential phoneAuthCredential =
                                    PhoneAuthProvider.credential(
                                        verificationId: verificationId,
                                        smsCode: _otpCon.text);
                                signInWithPhoneAuthCredential(
                                    phoneAuthCredential);
                              } else {
                              }
                              setState(() {});
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
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
                        : Expanded(
                            flex: 1,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xffEBEBEB),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  primary: Color(0xffEBEBEB),
                                  elevation: 0,
                                ),
                                onPressed: () {
                                  if (_doubleCheck == 0) {
                                    PhoneAuthCredential phoneAuthCredential =
                                        PhoneAuthProvider.credential(
                                            verificationId: verificationId,
                                            smsCode: _otpCon.text);
                                    signInWithPhoneAuthCredential(
                                        phoneAuthCredential);
                                  } else {
                                  }
                                  setState(() {});
                                },
                                child: Text(
                                  '인증번호\n확인 ',
                                  textAlign: TextAlign.center,
                                  style: (GetPlatform.isWeb &&
                                          (Get.width * 0.2 <= 171))
                                      ? f12w700primary
                                      : f16w700primary,
                                ),
                              ),
                            ),
                          )
                  ],
                ),
                SizedBox(
                  height: 7,
                ),
                _phoneAuth == true
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            child: Text(
                              '인증에 성공하였습니다.',
                              style: f16w500,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text(
                            '',
                            style: f16w500,
                          ),
                        ],
                      ),
                // : Row(
                //     mainAxisAlignment: MainAxisAlignment.start,
                //     children: [
                //       Text(
                //         '인증에 실패했습니다.',
                //         style: f16w500,
                //       ),
                //     ],
                //   ),
                const SizedBox(
                  height: 16,
                ),
                TextFormFields(
                  controller: _nameCon,
                  onChanged: (v) {
                    us.name.value = _nameCon.text.trim();
                  },
                  obscureText: true,
                  hintText: '이름',
                  surffixIcon: '0',
                  keyboardType: TextInputType.text,
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    GetPlatform.isWeb
                        ? TextFormFields(
                            controller: _nickNameCon,
                            onChanged: (v) {
                              us.nickName.value = _nickNameCon.text.trim();
                            },
                            obscureText: true,
                            hintText: "닉네임",
                            surffixIcon: "0")
                        : Expanded(
                            flex: 2,
                            child: TextFormFields(
                                controller: _nickNameCon,
                                onChanged: (v) {
                                  us.nickName.value = _nickNameCon.text.trim();
                                },
                                obscureText: true,
                                hintText: "닉네임",
                                surffixIcon: "0"),
                          ),
                    SizedBox(
                      width: 10,
                    ),
                    GetPlatform.isWeb
                        ? GestureDetector(
                            onTap: () async {
                              await nickNameCheck(_nickNameCon.text);
                              if (_nickNameCon.text != '') {
                                if (nickCheck == true) {
                                  showOnlyConfirmDialog(
                                      context, '사용가능한 닉네임 입니다.');
                                  // setState(() {
                                  //   nickCheck=true;
                                  // });
                                } else {
                                  showOnlyConfirmDialog(
                                      context, '이미 사용중인 닉네임입니다.');
                                  // setState(() {
                                  //   nickCheck=false;
                                  // });
                                }
                              } else {
                                showOnlyConfirmDialog(
                                    context, '공백은 입력 불가능합니다.');
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 10),
                              decoration: BoxDecoration(
                                color: Color(0xffEBEBEB),
                                borderRadius: BorderRadius.circular(8.0),
                              ),
                              child: Text('중복 체크',
                                  style: (GetPlatform.isWeb &&
                                          (Get.width * 0.2 <= 171))
                                      ? f12w700primary
                                      : f16w700primary),
                            ),
                          )
                        : Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () async {
                                await nickNameCheck(_nickNameCon.text);
                                if (_nickNameCon.text != '') {
                                  if (nickCheck == true) {
                                    showOnlyConfirmDialog(
                                        context, '사용가능한 닉네임 입니다.');
                                    // setState(() {
                                    //   nickCheck=true;
                                    // });
                                  } else {
                                    showOnlyConfirmDialog(
                                        context, '이미 사용중인 닉네임입니다.');
                                    // setState(() {
                                    //   nickCheck=false;
                                    // });
                                  }
                                } else {
                                  showOnlyConfirmDialog(
                                      context, '공백은 입력 불가능합니다.');
                                }
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Color(0xffEBEBEB),
                                  borderRadius: BorderRadius.circular(8.0),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      '중복체크',
                                      style: (GetPlatform.isWeb &&
                                              (Get.width * 0.2 <= 171))
                                          ? f12w700primary
                                          : f16w700primary,
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
                SizedBox(
                  height: 16,
                ),
                TextFormFields(
                  controller: _birthCon,
                  onChanged: (v) {
                    us.year.value = _birthCon.text.split('/')[0];
                    us.month.value = _birthCon.text.split('/')[1];
                    us.day.value = _birthCon.text.split('/')[2];
                  },
                  inputFormatters: [
                    LengthLimitingTextInputFormatter(10),
                    FilteringTextInputFormatter.digitsOnly,
                    maskFormatter2
                  ],
                  obscureText: true,
                  hintText: '생년월일',
                  surffixIcon: "0",
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(
                  height: 16,
                ),
                Row(
                  children: [
                    GetPlatform.isWeb
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  typeCheck = false;
                                  us.userType.value = '학생';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 0,
                                  side: BorderSide(
                                      width: 1,
                                      color: typeCheck
                                          ? Colors.white
                                          : Color(0xff3A8EFF))),
                              child: Text('학생으로 가입',
                                  style: us.userType.value == '학생'
                                      ? (GetPlatform.isWeb &&
                                              (Get.width * 0.2 <= 171))
                                          ? f12w500
                                          : f16w500
                                      : (GetPlatform.isWeb &&
                                              (Get.width * 0.2 <= 171))
                                          ? f12w500
                                          : f16w500),
                            ),
                          )
                        : SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.45,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  typeCheck = false;
                                  us.userType.value = '학생';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 0,
                                  side: BorderSide(
                                      width: 1,
                                      color: typeCheck
                                          ? Colors.white
                                          : Color(0xff3A8EFF))),
                              child: Text(
                                '학생으로 가입',
                                style: (GetPlatform.isWeb &&
                                        (Get.width * 0.2 <= 171))
                                    ? f12w500
                                    : f16w500,
                              ),
                            ),
                          ),
                    const SizedBox(
                      width: 10,
                    ),
                    GetPlatform.isWeb
                        ? SizedBox(
                            height: MediaQuery.of(context).size.height * 0.05,
                            width: MediaQuery.of(context).size.width * 0.3,
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  typeCheck = true;
                                  us.userType.value = '선생님';
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  elevation: 0,
                                  side: BorderSide(
                                      width: 1,
                                      color: typeCheck
                                          ? Color(0xff3A8EFF)
                                          : Colors.white)),
                              child: Text(
                                '선생님으로 가입',
                                style: us.userType.value == '선생님'
                                    ? (GetPlatform.isWeb &&
                                            (Get.width * 0.2 <= 171))
                                        ? f12w500
                                        : f16w500
                                    : (GetPlatform.isWeb &&
                                            (Get.width * 0.2 <= 171))
                                        ? f12w500
                                        : f16w500,
                              ),
                            ),
                          )
                        : Expanded(
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height * 0.05,
                              child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    typeCheck = true;
                                    us.userType.value = '선생님';
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    elevation: 0,
                                    side: BorderSide(
                                        width: 1,
                                        color: typeCheck
                                            ? Color(0xff3A8EFF)
                                            : Colors.white)),
                                child: Text(
                                  '선생님으로 가입',
                                  style: (GetPlatform.isWeb &&
                                          (Get.width * 0.2 <= 171))
                                      ? f12w500
                                      : f16w500,
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
                const SizedBox(
                  height: 12,
                ),
                GetPlatform.isWeb
                    ? Row(
                        children: [
                          policyCheck == false
                              ? GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      policyCheck = true;
                                    });
                                  },
                                  child: SvgPicture.asset(
                                      'assets/notcheckBox.svg'),
                                )
                              : GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      policyCheck = false;
                                    });
                                  },
                                  child:
                                      SvgPicture.asset('assets/checkBox.svg'),
                                ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text('이용약관',
                              style: (GetPlatform.isWeb &&
                                      (Get.width * 0.2 <= 171))
                                  ? f12w500
                                  : f16w500),
                          const SizedBox(
                            width: 10,
                          ),
                          TextButton(
                              onPressed: () async {
                                showComponentDialog(context, '이용약관을 확인하시겠습니까?',
                                    () {
                                  Get.back();
                                  html.window.open(
                                      'http://misnetwork.iptime.org:8880/useService',
                                      'naver');
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    '확인하기',
                                    style: (GetPlatform.isWeb &&
                                            (Get.width * 0.2 <= 171))
                                        ? f12w500
                                        : f16w500,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  SvgPicture.asset('assets/arrow.svg')
                                ],
                              ))
                        ],
                      )
                    : Row(
                        children: [
                          policyCheck == false
                              ? GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      policyCheck = true;
                                    });
                                  },
                                  child: SvgPicture.asset(
                                      'assets/notcheckBox.svg'),
                                )
                              : GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      policyCheck = false;
                                    });
                                  },
                                  child:
                                      SvgPicture.asset('assets/checkBox.svg'),
                                ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('이용약관',
                              style: (GetPlatform.isWeb &&
                                      (Get.width * 0.2 <= 171))
                                  ? f12w500
                                  : f16w500),
                          Spacer(),
                          TextButton(
                              onPressed: () {
                                Get.toNamed(PolicyPage.id);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    '확인하기',
                                    style: (GetPlatform.isWeb &&
                                            (Get.width * 0.2 <= 171))
                                        ? f12w500
                                        : f16w500,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  SvgPicture.asset('assets/arrow.svg')
                                ],
                              ))
                        ],
                      ),
                GetPlatform.isWeb
                    ? Row(
                        children: [
                          privatePolicyCheck == false
                              ? GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      privatePolicyCheck = true;
                                    });
                                  },
                                  child: SvgPicture.asset(
                                      'assets/notcheckBox.svg'),
                                )
                              : GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      privatePolicyCheck = false;
                                    });
                                  },
                                  child:
                                      SvgPicture.asset('assets/checkBox.svg'),
                                ),
                          const SizedBox(
                            width: 10,
                          ),
                          Text('개인정보 처리방침',
                              style: (GetPlatform.isWeb &&
                                      (Get.width * 0.2 <= 171))
                                  ? f12w500
                                  : f16w500),
                          const SizedBox(
                            width: 10,
                          ),
                          TextButton(
                              onPressed: () async {
                                showComponentDialog(
                                    context, '개인정보 처리방침을 확인하시겠습니까?', () {
                                  Get.back();

                                  html.window.open(
                                      'http://misnetwork.iptime.org:8880/policy',
                                      'daum');
                                });
                              },
                              child: Row(
                                children: [
                                  Text(
                                    '확인하기',
                                    style: (GetPlatform.isWeb &&
                                            (Get.width * 0.2 <= 171))
                                        ? f12w500
                                        : f16w500,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  SvgPicture.asset('assets/arrow.svg')
                                ],
                              ))
                        ],
                      )
                    : Row(
                        children: [
                          privatePolicyCheck == false
                              ? GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      privatePolicyCheck = true;
                                    });
                                  },
                                  child: SvgPicture.asset(
                                      'assets/notcheckBox.svg'),
                                )
                              : GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      privatePolicyCheck = false;
                                    });
                                  },
                                  child:
                                      SvgPicture.asset('assets/checkBox.svg'),
                                ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            '개인정보 처리방침',
                            style: TextStyle(
                                fontFamily: 'Pretendard',
                                fontSize: 16,
                                fontWeight: FontWeight.w400),
                          ),
                          Spacer(),
                          TextButton(
                              onPressed: () {
                                Get.toNamed(PrivatePolicy.id);
                              },
                              child: Row(
                                children: [
                                  Text(
                                    '확인하기',
                                    style: f16w400,
                                  ),
                                  SizedBox(
                                    width: 8,
                                  ),
                                  SvgPicture.asset('assets/arrow.svg')
                                ],
                              ))
                        ],
                      ),

                const SizedBox(
                  height: 120,
                ),
                GetPlatform.isWeb
                    ? Row(
                        children: [
                          Footer(),
                        ],
                      )
                    : Container(),
                const SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
        bottomNavigationBar: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (_idCon.text.trim().isEmpty == true ||
                _pwCon.text.trim().isEmpty == true ||
                _phoneCon.text.trim().isEmpty == true ||
                _nameCon.text.trim().isEmpty == true ||
                _birthCon.text.trim().isEmpty == true ||
                _nickNameCon.text.trim().isEmpty == true ||
                policyCheck == false ||
                privatePolicyCheck == false) {
              showOnlyConfirmDialog(context, '필수항목들을 입력해주세요');
            } else {
              if (idCheck == false) {
                showOnlyConfirmDialog(context, '아이디 중복체크를 확인해 주세요');
              } else if (_phoneAuth == false) {
                showConfirmTapDialog(context, '인증번호를 확인해 주세요', () {
                  Navigator.of(context).pop();
                });
              } else if (nickCheck == false) {
                showOnlyConfirmDialog(context, '닉네임 중복체크를 확인해주세요');
              } else {
                if (typeCheck == false) {
                  us.userType.value = '학생';
                }
                us.addUser(
                  us.id.value,
                  us.pw.value,
                  us.number.value,
                  us.name.value,
                  us.year.value,
                  us.month.value,
                  us.day.value,
                  us.userType.value,
                  us.nickName.value,
                );
                showConfirmTapDialog(context, '회원가입이 완료되었습니다.', () {
                  Navigator.of(context).pop();
                  Get.offAll(() => LoginMainScreen());
                });
              }
            }
          },
          child: SizedBox(
            height: GetPlatform.isWeb
                ? Get.height * 0.06
                : MediaQuery.of(context).size.height * 0.1,
            child: Container(
              decoration: BoxDecoration(color: Color(0xff270BD3)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '가입 하기',
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
      ),
    );
  }

  //휴대폰 인증 확인
  void signInWithPhoneAuthCredential(
      PhoneAuthCredential phoneAuthCredential) async {
    try {
      final authCredential =
          await _auth.signInWithCredential(phoneAuthCredential);
      if (authCredential.user != null) {
        setState(() {
          _authOk = true;
          _phoneAuth = true;
          _isConfirm = true;
          showOnlyConfirmDialog(context, "인증이 완료되었습니다.");
        });
        _doubleCheck = 1;
        await _auth.currentUser!.delete();
        _auth.signOut();
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _authOk = false;
      });
      showOnlyConfirmDialog(context, "인증번호가 일치하지 않습니다.");
    }
  }

  // 아이디 중복 체크
  Future<bool> registerIdCheck(String id) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('user');
    QuerySnapshot snapshot = await ref.where('id', isEqualTo: id).get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    if (allData.length == 1) {
      return idCheck = false;
    } else {
      return idCheck = true;
    }
  }

  // 닉네임 중복 체크
  Future<bool> nickNameCheck(String nickName) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('user');
    QuerySnapshot snapshot =
        await ref.where('nickName', isEqualTo: nickName).get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    if (allData.length == 1) {
      return nickCheck = false;
    } else {
      return nickCheck = true;
    }
  }
}
