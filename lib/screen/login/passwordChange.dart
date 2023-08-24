import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/components/footer/footer.dart';
import 'package:academy/provider/user_state.dart';
import 'package:academy/screen/login/login_main_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../components/tile/textform_field.dart';
import '../../util/colors.dart';
import '../../util/font/font.dart';
import '../../util/loading.dart';

class PasswordChange extends StatefulWidget {
  static final String id = '/password_change_screen';
  const PasswordChange({Key? key}) : super(key: key);

  @override
  State<PasswordChange> createState() => _PasswordChangeState();
}

class _PasswordChangeState extends State<PasswordChange> {
  bool _isLoading = false;
  bool _obscureText = false;
  bool _obscureText2 = false;
  bool _passTrue = false;
  TextEditingController _pwCon = TextEditingController();
  TextEditingController _pwCon2 = TextEditingController();

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      setState(() {
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    _pwCon.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    final us = Get.put(UserState());
    return _isLoading
        ? LoadingBodyScreen()
        : Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title:  Padding(
              padding: Get.width < 1024 ?const EdgeInsets.only(left: 100) :const EdgeInsets.only(left: 370),

              child: Row(
                children: [
                  SvgPicture.asset('assets/logo.svg'),
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
                    Container(width: Get.width*0.4, height: Get.height * 0.6,
                      padding: const EdgeInsets.fromLTRB(24, 25, 24, 0),
                    child: Column(children: [
                      TextFormFields(
                        controller: _pwCon,
                        onChanged: (v) {
                          setState(() {});
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
                      SizedBox(
                        height: 20,
                      ),
                      TextFormFields(
                        controller: _pwCon2,
                        onChanged: (v) {
                          // 비밀번호 일치할때 true
                          if (_pwCon.text == _pwCon2.text) {
                            _passTrue = true;
                            setState(() {});
                          }
                          // 비밀번호 실패할 때 false
                          else {
                            setState(() {
                              _passTrue = false;
                            });
                          }
                        },
                        obscureText: _obscureText2,
                        hintText: '비밀번호를 입력해주세요',
                        surffixIcon: '1',
                        onTap: () {
                          setState(() {
                            _obscureText2 = !_obscureText2;
                          });
                        },
                      ),
                      _pwCon.text == '' && _pwCon2.text == ''
                          ? Container()
                          : _passTrue == true
                          ? Container(child: Text('비밀번호가 일치합니다.'))
                          : Container(
                        child: Text('비밀번호가 일치하지 않습니다.'),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (_passTrue == true) {
                            await updatePassword(us.phoneText.value, _pwCon2.text);
                            showConfirmTapDialog(context, '비밀번호가 변경되었습니다.', () {
                              Get.offAll(LoginMainScreen());
                            });
                          } else {
                            showOnlyConfirmDialog(context, '비밀번호를 다시 입력해 주세요');
                          }
                        },
                        child: Container(
                          width: Get.width * 0.5,
                          height: 50,
                          decoration: BoxDecoration(
                              color: Color(0xffffEBEBEB),
                              borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '비밀번호 변경',
                                style: f18w700primary,
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],),),

                    const SizedBox(height: 40,),
                    Footer(),
                  ],
                ),
              ),
            ),
          );
  }

  Future<void> updatePassword(String phone, String password) async {
    CollectionReference ref = FirebaseFirestore.instance.collection('user');
    QuerySnapshot snapshot = await ref
        .where('phoneNumber', isEqualTo: phone).get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    List ls = allData;

    DocumentReference ref2 =
    FirebaseFirestore.instance.collection('user').doc(ls[0]['docId']);
    ref2.update({'pw': password});
  }
}
