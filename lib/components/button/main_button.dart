import 'package:academy/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class MainButton extends StatelessWidget {
  final bool disabled;
  final VoidCallback onPressed;
  final String text;
  final String submit;
  const MainButton({
    Key? key,
    required this.onPressed,
    this.text: '회원가입',
    this.disabled: false,
    this.submit: '1'
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: GetPlatform.isWeb ? Get.width : Get.width,
      height: GetPlatform.isWeb
          ? submit=='1'?MediaQuery.of(context).size.height * 0.06:MediaQuery.of(context).size.height * 0.05
          : MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor:  GetPlatform.isWeb
                ? nowColor : Color(0xff3A8EFF),
            padding: (kIsWeb && (Get.width * 0.2 <=
                171 )) ? EdgeInsets.zero : EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Pretendard',
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: (kIsWeb && (Get.width * 0.2 <=
                    171 )) ? 12 : 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}
