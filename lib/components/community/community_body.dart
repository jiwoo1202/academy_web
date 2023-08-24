import 'package:academy/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CommunityBody extends StatelessWidget {
  final Widget body;
  final VoidCallback floatingTap;
  final Icon floatingIcon;
  final double paddingSize;

  const CommunityBody(
      {Key? key,
      required this.body,
      required this.floatingTap,
      required this.floatingIcon,
      required this.paddingSize})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: paddingSize),
        child: body,
      ),
      floatingActionButton: GetPlatform.isWeb && (Get.width * 0.2 <= 171)
          ? FloatingActionButton.small(
              onPressed: floatingTap,
              backgroundColor: nowColor,
              child: floatingIcon,
            )
          : FloatingActionButton(
              onPressed: floatingTap,
              backgroundColor: nowColor,
              child: floatingIcon,
            ),
    );
  }
}
