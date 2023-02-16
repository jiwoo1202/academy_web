import 'package:academy/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MainButton extends StatelessWidget {
  final bool disabled;
  final VoidCallback onPressed;
  final String text;

  const MainButton({
    Key? key,
    required this.onPressed,
    this.text: '회원가입',
    this.disabled: false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: GetPlatform.isWeb
          ? MediaQuery.of(context).size.width * 0.3
          : MediaQuery.of(context).size.width,
      height: GetPlatform.isWeb
          ? MediaQuery.of(context).size.height * 0.05
          : MediaQuery.of(context).size.height * 0.07,
      child: ElevatedButton(
        onPressed: disabled ? null : onPressed,
        style: ElevatedButton.styleFrom(
            backgroundColor:  GetPlatform.isWeb
                ? nowColor :Color(0xff3A8EFF),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                fontSize: 16,
              ),
            )
          ],
        ),
      ),
    );
  }
}
