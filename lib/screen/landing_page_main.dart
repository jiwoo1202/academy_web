import 'package:academy/screen/landing_page_app.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'landing_page_tablet.dart';
import 'landing_page_web.dart';

class LandingPageMain extends StatefulWidget {
  static final String id = '/landing_page_main';

  const LandingPageMain({Key? key}) : super(key: key);

  @override
  State<LandingPageMain> createState() => _LandingPageMainState();
}

class _LandingPageMainState extends State<LandingPageMain> {
  @override
  Widget build(BuildContext context) {
    return Get.width*0.2 <171?LandingPageApp():Get.width < 1024 ? LandingPageTablet() : LandingPage();
  }
}
