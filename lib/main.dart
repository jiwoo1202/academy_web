
import 'package:academy/screen/login/login_main_screen.dart';
import 'package:academy/screen/mypage/blockPage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';

import 'screen/community/community_main_screen.dart';
import 'screen/community/story/story_main_screen.dart';
import 'screen/community/story/story_write_screen.dart';
import 'screen/login/findPassword.dart';
import 'screen/main/main_screen.dart';
import 'screen/main/main_search_screen.dart';
import 'screen/mypage/score/score_check_screen.dart';
import 'screen/mypage/setting/setting_main_screen.dart';
import 'screen/register/policy.dart';
import 'screen/register/register_main_screen.dart';

void main() async {
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  print('— WidgetsFlutterBinding.ensureInitialized');
  // NotificationController.initioalizeNotificationService();
  // print('— NotificationController.initioalizeNotificationService');
  await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: "AIzaSyAQOc3PTyw4VyqM2ILYwEg3NBMKLubTZ6I",
      authDomain: "academy-957f7.firebaseapp.com",
      projectId: "academy-957f7",
      storageBucket: "academy-957f7.appspot.com",
      messagingSenderId: "9676366788",
      appId: "1:9676366788:web:d1f2f64a467f0a61d47a91",
      measurementId: "G-V388LH44NW"
  ));
  print('— main: Firebase.initializeApp');
  setPathUrlStrategy();
  runApp(MyApp());
}


class MyApp extends StatelessWidget {

  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return  GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'academy',
      // home: ,
      initialRoute: LoginMainScreen.id,
      routes: {

        //login
        LoginMainScreen.id : (_) => LoginMainScreen(),

        //register
        RegisterMainScreen.id : (_) => RegisterMainScreen(),


        //bottom
        BottomNavigator.id : (_) => BottomNavigator(),


        //find password
        FindPassword.id : (_) => FindPassword(),

        //search
        MainSearchScreen.id : (_) => MainSearchScreen(),

        //community
        CommunityMainScreen.id : (_) => CommunityMainScreen(),
        // JobHuntingRequestScreen.id : (_) => JobHuntingRequestScreen(),
        StoryMainScreen.id : (_) => StoryMainScreen(),
        StoryWriteScreen.id : (_) => StoryWriteScreen(),
        // StoryDetailScreen.id : (_) => StoryDetailScreen(),

        //test
        // TestMainScreen.id : (_) => TestMainScreen(),

        //score
        ScoreCheckScreen.id : (_) => ScoreCheckScreen(),
        //block
        BlockPage.id : (_)=> BlockPage(),

        //setting
        SettingMainScreen.id : (_) => SettingMainScreen(),

        //main screen
        MainScreen.id : (_) => MainScreen(),


        //policy
        PolicyPage.id : (_) => PolicyPage(),
      },
    );
  }
}
