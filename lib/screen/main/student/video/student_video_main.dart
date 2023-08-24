import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/components/footer/footer.dart';
import 'package:academy/provider/answer_state.dart';
import 'package:academy/provider/test_state.dart';
import 'package:academy/provider/user_state.dart';
import 'package:academy/screen/main/student/video/student_video_show.dart';
import 'package:academy/util/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../components/tile/main_tile.dart';
import '../../../../util/behavior.dart';
import '../../../../util/font/font.dart';


class StudentVideoMain extends StatefulWidget {
  const StudentVideoMain({Key? key}) : super(key: key);

  @override
  State<StudentVideoMain> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentVideoMain> with TickerProviderStateMixin{
  TextEditingController _pwcontroller = TextEditingController();
  TextEditingController _teacherCon = TextEditingController();
  TextEditingController _checkCon = TextEditingController();
  bool isLoading = true;
  List<String> data = [];
  String initial = '';
  int type = 0;

  @override
  void initState() {
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());
    as.getDocid.value = [];
    as.teacherList.value = [];
    as.createList.value = [];
    super.initState();
  }

  @override
  void dispose() {
    _pwcontroller.dispose();
    _checkCon.dispose();
    _teacherCon.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final as = Get.put(AnswerState());
    final us = Get.put(UserState());
    final ts = Get.put(TestState());
    return WillPopScope(
      onWillPop: () {
        return Future(() => true);
      },
      child: GestureDetector(
        onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
        child: Scaffold(
          body: ScrollConfiguration(
            behavior: MyBehavior(), //마우스
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: Column(
                  children: [
                    const SizedBox(height: 52,),
                    Text(
                      '강의',
                      style: f24w500,
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    //검색
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: Get.width * 0.15),
                      width: Get.width * 0.4,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: TextFormField(
                        // enabled: !_pay,
                        controller: _teacherCon,
                        keyboardType: TextInputType.text,
                        textInputAction: TextInputAction.go,
                        onFieldSubmitted: (v) {
                          setState(() {});
                        },
                        decoration: InputDecoration(
                          isDense: true,
                          filled: true,
                          fillColor: Color(0xffEBEBEB),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          border: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(8)),
                          hintText: '강의 검색',
                          suffixIcon: GestureDetector(
                              onTap: () {
                                setState(() {});
                              },
                              child: Icon(
                                Icons.search_outlined,
                                color: Colors.black,
                                size: 30,
                              )),
                          hintStyle: f16w400grey8,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: GetPlatform.isWeb ? 80 : 40,
                    ),
                    Container(margin: EdgeInsets.symmetric(horizontal: Get.width * 0.15),
                      width: Get.width * 0.4,
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: StreamBuilder<QuerySnapshot>(
                        stream: _teacherCon.text.trim().isNotEmpty
                            ? FirebaseFirestore.instance
                            .collection('video')
                            .orderBy('title').where('state',isEqualTo: '완료')
                            .startAt([_teacherCon.text]).endAt(
                            [_teacherCon.text + '\uf8ff']).snapshots()
                            : FirebaseFirestore.instance
                            .collection('video')
                            .where('state', isEqualTo: '완료')
                            .orderBy('createDate', descending: true)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Center(child: LoadingBodyScreen());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Container(
                              height: Get.height,
                              child: Center(child: Text("데이터가 없습니다.")),
                            );
                          }
                          return Column(
                            children: [
                              // snapshot.data?.docs==null?Text('22'):
                              ListView.builder(
                                itemCount: snapshot.data!.docs.length,
                                shrinkWrap: true,
                                physics: const ClampingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      MainTile(
                                        isOpened: true,
                                        isStudent: true,
                                        arrowString: '강의 보기',
                                        subject: snapshot.data!.docs[index]['title'],
                                        tName: snapshot.data!.docs[index]['teacherName'],
                                        tCreateDate:
                                        '${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(snapshot.data!.docs[index]['createDate']))}',
                                        onTap: () async {
                                          Get.toNamed(StudentVideoShow.id,arguments: StudentVideoShow(
                                          docId: '${snapshot.data!.docs[index]['docId']}',
                                           videoName: '${snapshot.data!.docs[index]['videoName']}',
                                            teacherDocId:'${snapshot.data!.docs[index]['teacherDocId']}',
                                            title:'${snapshot.data!.docs[index]['title']}',
                                          ));
                                        },
                                        switchOnTap: () {},
                                        title: '',
                                      ),
                                      SizedBox(
                                        height: 16,
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    Footer()
                  ],
                ),
              ),
            ),
          ),

        ),
      ),
    );
  }

  Future<bool> onTerminated(BuildContext context) async {
    return showComponentDialog(context, '앱을 종료하시겠습니까?', () {
      SystemNavigator.pop();
    });
  }

}