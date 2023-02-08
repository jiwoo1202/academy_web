import 'package:academy/components/tile/textform_field.dart';
import 'package:academy/provider/user_state.dart';
import 'package:academy/screen/login/login_main_screen.dart';
import 'package:academy/screen/register/policy.dart';
import 'package:academy/screen/register/privatePolicy.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../firebase/firebase_user.dart';
import '../../util/font.dart';
import '../../util/loading.dart';

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
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new,
              color: Colors.black,
            ),
            onPressed: () {
              Get.back();
            },
          ),
          title: Text(
            '회원가입',
            style: TextStyle(
                color: Colors.black,
                fontSize: 21,
                fontFamily: "Pretendard",
                fontWeight: FontWeight.w700),
          ),
          elevation: 0,
          backgroundColor: Colors.white,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(24, 25, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text('${us.id}',style: f16w500,),
              // Obx(() =>Text('${us.id}',style: f16w500,)),
              Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
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
                  Expanded(
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
                          print('중복검사');
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
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      content: idCheck == false
                                          ? Text('사용불가능한 아이디 입니다.')
                                          : Text('사용가능한 아이디 입니다.'),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('네'))
                                      ],
                                    ));
                          } else {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) => AlertDialog(
                                      content: Text('아이디는 영어랑 숫자만 입력 가능합니다.'),
                                      actions: [
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: Text('네'))
                                      ],
                                    ));
                          }
                        },
                        child: Text(
                          '중복 체크',
                          style: TextStyle(
                              color: Color(0xff3A8EFF),
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
                        ),
                      ),
                    ),
                  )
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
                surffixIcon: "1",
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextFormFields(
                        controller: _phoneCon,
                        onChanged: (v) {
                          us.number.value = _phoneCon.text.trim();
                        },
                        obscureText: true,
                        hintText: '휴대폰 번호를 입력해주세요',
                        keyboardType: TextInputType.number,
                        surffixIcon: '0'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
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
                            verificationFailed: (verificationFalied) async {
                              print('실패했습니다.');
                              print('${verificationFalied.message}');
                            },
                            codeSent: (verifiationId,resendingToken) async {
                              print('코드를 보냈습니다.');
                              setState(() {
                                verificationId = verifiationId;
                              });
                            },
                            codeAutoRetrievalTimeout: (verificationId) async {},
                          );
                        },
                        child: Text(
                          '인증번호',
                          style: TextStyle(
                              color: Color(0xff3A8EFF),
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
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
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.7,
                    child: TextFormFields(
                        controller: _otpCon,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(13),
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        obscureText: true,
                        hintText: '인증번호를 입력해주세요',
                        surffixIcon: '0'),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
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
                            signInWithPhoneAuthCredential(phoneAuthCredential);
                          } else {
                            print('2');
                          }
                          setState(() {});
                        },
                        child: Text(
                          '인증번호 확인 ',
                          style: TextStyle(
                              color: Color(0xff3A8EFF),
                              fontFamily: "Pretendard",
                              fontWeight: FontWeight.w700,
                              fontSize: 16),
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
                          child: Text('인증에 성공하였습니다.'),
                        ),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('인증에 실패했습니다.'),
                      ],
                    ),
              const SizedBox(
                height: 16,
              ),
              TextFormFields(
                controller: _nameCon,
                obscureText: true,
                hintText: '이름',
                surffixIcon: '0',
                keyboardType: TextInputType.text,
              ),
              const SizedBox(
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
              SizedBox(
                height: 16,
              ),
              Row(
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: MediaQuery.of(context).size.width * 0.45,
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          typeCheck = false;
                          us.userType.value = '학생';
                          print('${us.userType.value}');
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
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: SizedBox(
                      height: MediaQuery.of(context).size.height * 0.05,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            typeCheck = true;
                            us.userType.value = '선생님';
                            print('${us.userType.value}');
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
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Container(
              //   decoration: BoxDecoration(
              //       borderRadius: BorderRadius.all(Radius.circular(10)),
              //       border: Border.all(width: 1.0)),
              //   child: DropdownButton<String>(
              //     isExpanded: true,
              //     value: selectedValue,
              //     hint: Text('타입을 선택해주세요'),
              //     onChanged: (newValue) {
              //       setState(() {
              //         selectedValue = newValue;
              //         us.userType.value = selectedValue!;
              //       });
              //     },
              //     items: <String>['학생', '선생']
              //         .map<DropdownMenuItem<String>>((String value) {
              //       // ignore: missing_required_param
              //       return DropdownMenuItem<String>(
              //         value: value,
              //         child: Text(
              //           value,
              //         ),
              //       );
              //     }).toList(),
              //   ),
              // ),
              SizedBox(
                height: 12,
              ),
              // ElevatedButton(
              //     onPressed: () {
              //       if (_idCon.text.trim().isEmpty == true ||
              //           _pwCon.text.trim().isEmpty == true ||
              //           _phoneCon.text.trim().isEmpty == true ||
              //           _nameCon.text.trim().isEmpty == true ||
              //           _birthCon.text.trim().isEmpty == true) {
              //         showDialog(
              //             context: context,
              //             builder: (BuildContext context) => AlertDialog(
              //                   content: Text('모든 칸에 입력해주세요'),
              //                   actions: [
              //                     ElevatedButton(
              //                         onPressed: () {
              //                           Navigator.of(context).pop();
              //                         },
              //                         child: Text('네'))
              //                   ],
              //                 ));
              //       } else {
              //         us.addUser(
              //             us.id.value,
              //             us.pw.value,
              //             us.number.value,
              //             us.name.value,
              //             us.year.value,
              //             us.month.value,
              //             us.day.value,
              //             us.userType.value);
              //         showDialog(
              //             context: context,
              //             builder: (BuildContext context) => AlertDialog(
              //                   content: Text('회원가입이 완료되었습니다.'),
              //                   actions: [
              //                     ElevatedButton(
              //                         onPressed: () {
              //                           Navigator.of(context).pop();
              //                         },
              //                         child: Text('네'))
              //                   ],
              //                 ));
              //       }
              //       ;
              //     },
              //     child: Text('회원가입 완료'))
              Row(
                children: [
                  policyCheck == false
                      ? GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            print('이용약관 처리');
                            setState(() {
                              policyCheck = true;
                            });
                          },
                          child: SvgPicture.asset('assets/notcheckBox.svg'),
                        )
                      : GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            print('이용약관 처리');
                            setState(() {
                              policyCheck = false;
                            });
                          },
                          child: SvgPicture.asset('assets/checkBox.svg'),
                        ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    '이용약관',
                    style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 16,
                        fontWeight: FontWeight.w400),
                  ),
                  Spacer(),
                  TextButton(
                      onPressed: () {
                        Get.toNamed(PolicyPage.id);
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
              Row(
                children: [
                  privatePolicyCheck == false
                      ? GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              privatePolicyCheck = true;
                            });
                          },
                          child: SvgPicture.asset('assets/notcheckBox.svg'),
                        )
                      : GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () {
                            setState(() {
                              privatePolicyCheck = false;
                            });
                          },
                          child: SvgPicture.asset('assets/checkBox.svg'),
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
            ],
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
                policyCheck == false ||
                privatePolicyCheck == false) {
              showDialog(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                        content: Text('모든 칸에 입력해주세요'),
                        actions: [
                          ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('네'))
                        ],
                      ));
            } else {
              if (idCheck == false) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          content: Text('아이디 중복체크를 해주세요'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('네'))
                          ],
                        ));
              } else if (_phoneAuth == false) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          content: Text('인증번호 확인을 해주세요'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('네'))
                          ],
                        ));
              } else {
                if(typeCheck==false){
                  us.userType.value='학생';
                }
                us.addUser(
                    us.id.value,
                    us.pw.value,
                    us.number.value,
                    us.name.value,
                    us.year.value,
                    us.month.value,
                    us.day.value,
                    us.userType.value);
                showDialog(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                          content: Text('회원가입이 완료되었습니다.'),
                          actions: [
                            ElevatedButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                  Get.to(() => LoginMainScreen());
                                },
                                child: Text('네'))
                          ],
                        ));
              }
            }
            ;
          },
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.1,
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
        print('인공입니다');
        setState(() {
          _authOk = true;
          _phoneAuth = true;
          _isConfirm = true;
          print("인증완료 및 로그인성공 _auth ok 는 true");
        });
        _doubleCheck = 1;
        await _auth.currentUser!.delete();
        print("auth정보삭제");
        _auth.signOut();
        print("phone 로그인된것 로그아웃");

        // cancelTimer();
        print('인증번호 일치');

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
        _authOk = false;
      });
      print('인증번호 일치하지 않습니다');
      print('실패');
      print('Error Log Phone Auth : ');
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
}
