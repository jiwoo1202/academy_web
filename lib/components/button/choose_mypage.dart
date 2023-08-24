import 'package:flutter/material.dart';

import '../../util/colors.dart';
import '../../util/font/font.dart';

class ChooseMypage extends StatelessWidget {
  final String title;
  final bool isTrue;
  final VoidCallback onTap;

  const ChooseMypage({Key? key, required this.isTrue, required this.title, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 17),
        child: Text(
          title,
          style: isTrue ? f14Whitew700 : f14w400,
        ),
        height: 56,
        decoration: BoxDecoration(
          color: isTrue? const Color(0xff000000) : const Color(0xffffffff),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
