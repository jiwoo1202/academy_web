import 'package:flutter/material.dart';

import '../../util/colors.dart';
import '../../util/font/font.dart';

class ChooseButton extends StatelessWidget {
  final String title;
  final bool isTrue;
  final VoidCallback onTap;

  const ChooseButton({Key? key, required this.isTrue, required this.title, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Center(
            child: Text(
          title,
          style: isTrue ? f16w700 : f16w400greyA,
        )),
        height: 56,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: isTrue ? nowColor : blurColor,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class LeftRightButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool icon; //true 왼쪽 false 오른쪽
  const LeftRightButton({Key? key, required this.onTap, required this.title, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xffDADADA),
              ),
              borderRadius: BorderRadius.all(Radius.circular(8))
          ),
          child: IconButton(
              icon: icon?const Icon(
                Icons.navigate_before,
                color: Colors.black,
              ):
              const Icon(
                Icons.navigate_next,
                color: Colors.black,
              ),
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: onTap
          ),
        ),
        SizedBox(
          height: 10,
        ),
        Text(title,style: f16w700,)
      ],
    );
  }
}
class LeftRightButtonSat extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool icon; //true 왼쪽 false 오른쪽
  const LeftRightButtonSat({Key? key, required this.onTap, required this.title, required this.icon}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: 52,
            height: 30,
            decoration: BoxDecoration(
              color: nowColor,
                border: Border.all(
                  color: Colors.blue,
                ),
                borderRadius: BorderRadius.all(Radius.circular(30))
            ),
            child:Center(child: Text(title,style: f16Whitew500,))
          ),
        ),
      ],
    );
  }
}

