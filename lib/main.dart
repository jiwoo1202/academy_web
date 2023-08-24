import 'package:academy/screen/community/job/job_hunting_detail_screen.dart';
import 'package:academy/screen/community/story/story_main_screen_web.dart';
import 'package:academy/screen/landing_page_app.dart';
import 'package:academy/screen/landing_page_main.dart';
import 'package:academy/screen/landing_page_tablet.dart';
import 'package:academy/screen/landing_page_web.dart';
import 'package:academy/screen/leadingPage.dart';
import 'package:academy/screen/login/login_main_screen.dart';
import 'package:academy/screen/login/login_main_screen_main.dart';
import 'package:academy/screen/main/main_screen_app.dart';
import 'package:academy/screen/main/main_screen_main.dart';
import 'package:academy/screen/main/student/test/individual/test_individual_screen_tablet.dart';
import 'package:academy/screen/main/student/test/test_main_screen_tablet.dart';
import 'package:academy/screen/main/student/video/student_video_show.dart';
import 'package:academy/screen/main/teacher/all/pdf_upload_screen_tablet.dart';
import 'package:academy/screen/main/teacher/individual/pdf_individual_main_screen_tablet.dart';
import 'package:academy/screen/main/teacher/individual/pdf_upload_individual_screen.dart';
import 'package:academy/screen/mypage/mypage/mypage_screen_student.dart';
import 'package:academy/screen/mypage/mypage/mypage_screen_teacher.dart';
import 'package:academy/screen/mypage/qna/qnaDetail_screen.dart';
import 'package:academy/util/web_scroll_behavior.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_strategy/url_strategy.dart';

import 'screen/community/community_main_screen.dart';
import 'screen/community/job/job_hunting_screen.dart';
import 'screen/community/story/story_detail_screen.dart';
import 'screen/community/story/story_main_screen.dart';
import 'screen/community/story/story_write_screen.dart';
import 'screen/login/findPassword.dart';
import 'screen/login/passwordChange.dart';
import 'screen/main/main_sat_screen_main.dart';
import 'screen/main/main_screen.dart';
import 'screen/main/main_search_screen.dart';
import 'screen/main/sat/result_pdf_screen.dart';
import 'screen/main/sat/sat_upload_screen.dart';
import 'screen/main/student/test/individual/sat/test_breakTime_screen.dart';
import 'screen/main/student/test/individual/sat/test_individual_screen_sat.dart';
import 'screen/main/student/test/individual/sat/test_individula_screen_satMath.dart';
import 'screen/main/student/test/individual/test_individual_screen.dart';
import 'screen/main/student/test/test_file.dart';
import 'screen/main/student/test/test_main_screen.dart';
import 'screen/main/teacher/all/pdf_upload_screen.dart';
import 'screen/main/teacher/individual/pdf_individual_main_screen.dart';
import 'screen/main/teacher/video/videoUpload.dart';
import 'screen/main_sat_screen.dart';
import 'screen/mypage/mypage/blockPage.dart';
import 'screen/mypage/mypage/mypage_screen.dart';
import 'screen/mypage/mypage/score/score_check_screen.dart';
import 'screen/mypage/mypage/setting/setting_main_screen.dart';
import 'screen/mypage/mypage/testcheck/test_check_detail_screen.dart';
import 'screen/mypage/mypage/testcheck/test_check_main_screen.dart';
import 'screen/mypage/qna/qna.dart';
import 'screen/mypage/qna/qnaDetail.dart';
import 'screen/register/policy.dart';
import 'screen/register/register_main_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
      options: FirebaseOptions(
          apiKey: "AIzaSyAQOc3PTyw4VyqM2ILYwEg3NBMKLubTZ6I",
          authDomain: "academy-957f7.firebaseapp.com",
          projectId: "academy-957f7",
          storageBucket: "academy-957f7.appspot.com",
          messagingSenderId: "9676366788",
          appId: "1:9676366788:web:d1f2f64a467f0a61d47a91",
          measurementId: "G-V388LH44NW"));

  setPathUrlStrategy();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'academy',
      home: LandingPageMain(),
      scrollBehavior: AppScrollBehavior(),
      initialRoute: LandingPageMain.id,
      getPages: [
        GetPage(
            name: LandingPageMain.id,
            page: () => LandingPageMain(),
            transition: Transition.topLevel),
        GetPage(
            name: LandingPage.id,
            page: () => LandingPage(),
            transition: Transition.topLevel),
        GetPage(
            name: LandingPageTablet.id,
            page: () => LandingPageTablet(),
            transition: Transition.topLevel),
        GetPage(
            name: LandingPageApp.id,
            page: () => LandingPageApp(),
            transition: Transition.topLevel),
        GetPage(
            name: LeadingPage.id,
            page: () => LeadingPage(),
            transition: Transition.topLevel),
        //LoginMainScreen
        GetPage(
            name: LoginMainScreenMain.id,
            page: () => LoginMainScreenMain(),
            transition: Transition.topLevel),
        GetPage(
            name: LoginMainScreen.id,
            page: () => LoginMainScreen(),
            transition: Transition.topLevel),
        //bottomNavigator
        GetPage(
            name: BottomNavigator.id,
            page: () => BottomNavigator(),
            transition: Transition.topLevel),
        // MainScreen
        GetPage(
            name: MainScreen.id,
            page: () => MainScreen(),
            transition: Transition.fade,
            transitionDuration: const Duration(milliseconds: 600)),
        GetPage(
            name: MainScreenMain.id,
            page: () => MainScreenMain(),
            transition: Transition.fade,
            transitionDuration: const Duration(milliseconds: 600)),
        GetPage(
            name: MainSatScreenMain.id,
            page: () => MainSatScreenMain(),
            transition: Transition.fade,
            transitionDuration: const Duration(milliseconds: 600)),
        GetPage(
            name: MainSatScreen.id,
            page: () => MainSatScreen(),
            transition: Transition.fade,
            transitionDuration: const Duration(milliseconds: 600)),
        GetPage(name: SatUploadScreen.id, page: () => SatUploadScreen()),
        GetPage(
            name: MainScreenApp.id,
            page: () => MainScreenApp(),
            transition: Transition.fade,
            transitionDuration: const Duration(milliseconds: 600)),
        //RegisterMainScreen
        GetPage(name: RegisterMainScreen.id, page: () => RegisterMainScreen()),

        //FindPassword
        GetPage(name: FindPassword.id, page: () => FindPassword()),
        GetPage(name: PasswordChange.id, page: () => PasswordChange()),

        //CommunityMainScreen
        GetPage(
            name: CommunityMainScreen.id,
            page: () => CommunityMainScreen(),
            transition: Transition.fade,
            transitionDuration: const Duration(milliseconds: 600)),

        //StoryMainScreen
        GetPage(
            name: StoryMainScreen.id,
            page: () => StoryMainScreen(),
            transition: Transition.fade,
            transitionDuration: const Duration(milliseconds: 600)),
        GetPage(
            name: StoryDetailScreen.id,
            page: () => StoryDetailScreen(),
            transition: Transition.fade,
            transitionDuration: const Duration(milliseconds: 600)),

        //JobHuntingScreen
        GetPage(
            name: JobHuntingScreen.id,
            page: () => JobHuntingScreen(),
            transition: Transition.fade,
            transitionDuration: const Duration(milliseconds: 600)),
        GetPage(
            name: JobHuntingDetailScreen.id,
            page: () => JobHuntingDetailScreen(),
            transition: Transition.fade,
            transitionDuration: const Duration(milliseconds: 600)),

        //StoryWriteScreen
        GetPage(name: StoryWriteScreen.id, page: () => StoryWriteScreen()),
        GetPage(name: StoryMainScreenWeb.id, page: () => StoryMainScreenWeb()),
        //TestMainScreen
        GetPage(name: TestMainScreen.id, page: () => TestMainScreen()),
        GetPage(name: TestIndividual.id, page: () => TestIndividual()),
        GetPage(
            name: TestMainScreenTablet.id, page: () => TestMainScreenTablet()),
        GetPage(
            name: TestIndividualTablet.id, page: () => TestIndividualTablet()),
        //PdfIndMainScreen
        GetPage(name: PdfIndMainScreen.id, page: () => PdfIndMainScreen()),
        GetPage(name: PdfUploadScreen.id, page: () => PdfUploadScreen()),
        GetPage(
            name: PdfUploadIndividualScreen.id,
            page: () => PdfUploadIndividualScreen()),
        GetPage(
            name: PdfUploadScreenTablet.id,
            page: () => PdfUploadScreenTablet()),
        GetPage(
            name: PdfIndMainScreenTablet.id,
            page: () => PdfIndMainScreenTablet()),
        GetPage(
            name: ResultPdfScreen.id,
            page: () => ResultPdfScreen()),

        //MyPageScreen
        GetPage(name: MyPageScreen.id, page: () => MyPageScreen()),
        GetPage(
            name: MyPageScreenTeacher.id, page: () => MyPageScreenTeacher()),
        GetPage(
            name: MyPageScreenStudent.id, page: () => MyPageScreenStudent()),
        GetPage(name: QnaDetailScreen.id, page: () => QnaDetailScreen()),
        //ScoreCheckScreen
        GetPage(name: ScoreCheckScreen.id, page: () => ScoreCheckScreen()),

        //BlockPage
        GetPage(name: BlockPage.id, page: () => BlockPage()),

        //SettingMainScreen
        GetPage(name: SettingMainScreen.id, page: () => SettingMainScreen()),
        GetPage(name: QnaPage.id, page: () => QnaPage()),
        GetPage(name: QnaDetail.id, page: () => QnaDetail()),

        //TestFilePage
        GetPage(name: TestFilePage.id, page: () => TestFilePage()),

        //PolicyPage
        GetPage(name: PolicyPage.id, page: () => PolicyPage()),

        //Test Check(Teacher)
        GetPage(
            name: TestCheckMainScreen.id, page: () => TestCheckMainScreen()),
        GetPage(
            name: TestCheckDetailScreen.id,
            page: () => TestCheckDetailScreen()),

        ///video
        GetPage(name: VideoUpload.id, page: () => VideoUpload()),
        GetPage(name: StudentVideoShow.id, page: () => StudentVideoShow()),

        GetPage(name: TestIndividualSat.id, page: () => TestIndividualSat()),
        GetPage(name: TestIndividualSatMath.id, page: () => TestIndividualSatMath()),
        GetPage(name: BreakTimeScreen.id, page: () => BreakTimeScreen()),
      ],
      // routes: {
      //   //login
      //   LoginMainScreen.id: (_) => LoginMainScreen(),
      //
      //   //register
      //   RegisterMainScreen.id: (_) => RegisterMainScreen(),
      //
      //   //bottom
      //   BottomNavigator.id: (_) => BottomNavigator(),
      //
      //   //find password
      //   FindPassword.id: (_) => FindPassword(),
      //
      //   //search
      //   MainSearchScreen.id: (_) => MainSearchScreen(),
      //
      //   //community
      //   CommunityMainScreen.id: (_) => CommunityMainScreen(),
      //   // JobHuntingRequestScreen.id : (_) => JobHuntingRequestScreen(),
      //   StoryMainScreen.id: (_) => StoryMainScreen(),
      //   StoryWriteScreen.id: (_) => StoryWriteScreen(),
      //   // StoryDetailScreen.id : (_) => StoryDetailScreen(),
      //
      //   //test
      //   TestMainScreen.id: (_) => TestMainScreen(),
      //
      //   MyPageScreen.id : (_) => MyPageScreen(),
      //
      //   //score
      //   ScoreCheckScreen.id: (_) => ScoreCheckScreen(),
      //   //block
      //   BlockPage.id: (_) => BlockPage(),
      //
      //   //setting
      //   SettingMainScreen.id: (_) => SettingMainScreen(),
      //
      //   //test
      //   TestFilePage.id : (_) => TestFilePage(),
      //
      //   //main screen
      //   MainScreen.id: (_) => MainScreen(),
      //
      //   //policy
      //   PolicyPage.id: (_) => PolicyPage(),
      // },
    );
  }
}
