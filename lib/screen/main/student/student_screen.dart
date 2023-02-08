import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:academy/firebase/firebase_answer.dart';
import 'package:academy/provider/answer_state.dart';
import 'package:academy/provider/test_state.dart';
import 'package:academy/screen/main/student/test/individual/test_individual_screen.dart';
import 'package:academy/util/loading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../api/pdf/pdf_api.dart';
import '../../../components/tile/main_tile.dart';
import '../../../util/colors.dart';


import '../../../../util/font.dart';
import 'test/test_main_screen.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  TextEditingController _pwcontroller = TextEditingController();
  bool isLoading = true;

  @override
  void initState() {
    final as = Get.put(AnswerState());
    as.getDocid.value = [];
    as.teacherList.value = [];
    as.createList.value = [];
    // Future.delayed(Duration.zero, () async {
    //   as.getDocid.value = [];
    //   as.teacherList.value = [];
    //   as.createList.value = [];
    //   _pwcontroller;
    //   await getState('대기');
    //   setState(() {
    //     isLoading = false;
    //   });
    // });
    super.initState();
  }

  @override
  void dispose() {
    _pwcontroller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final as = Get.put(AnswerState());
    final ts = Get.put(TestState());
    return SingleChildScrollView(
      physics: ClampingScrollPhysics(),
      child: Container(
        width: Get.width,
        padding: EdgeInsets.only(right: 24, left: 24, top: 60),
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('answer')
              .where('state', isEqualTo: '대기')
              .orderBy('createDate', descending: true)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return LoadingBodyScreen();
            }
            return Column(
              children: [
                Text(
                  '학생',
                  style: f24w500,
                ),
                const SizedBox(
                  height: 30,
                ),
                //검색
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    // var drugName =
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => MainSearchScreen(),
                    //   ),
                    // );
                  },
                  child: Container(
                    alignment: Alignment.topCenter,
                    padding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 18.5),
                    decoration: BoxDecoration(
                      color: textFormColor,
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text('검색', style: f16w400grey8),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
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
                          subject: snapshot.data!.docs[index]['pdfCategory'],
                          tName: snapshot.data!.docs[index]['teacher'],
                          tCreateDate:
                          '${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.parse(snapshot.data!.docs[index]['createDate']))}',
                          onTap: () async {
                            getAnswerLength(snapshot.data!.docs[index]['docId']);
                            ts.answerDocId.value = '${snapshot.data!.docs[index]['docId']}';
                            as.getTeacherName.value =
                            '${snapshot.data!.docs[index]['teacher']}';
                            showPasswordDialog(context, '비밀번호', () async {
                              if (_pwcontroller.text == snapshot.data!.docs[index]['password']) {
                                if(snapshot.data!.docs[index]['isIndividual'] == 'true'){
                                  Get.back();
                                  _pwcontroller.text = '';
                                  Get.to(() => TestIndividual(docId: snapshot.data!.docs[index]['docId'],));
                                }else{
                                  final url =
                                      'https://firebasestorage.googleapis.com/v0/b/academy-957f7.appspot.com/o/12345%2F12345%2F${snapshot.data!.docs[index]['docId']}.pdf?alt=media&token=5bcde09c-3145-4cdd-bbf8-886299c8a44f';
                                  final file = await PDFApi.loadNetwork(url);
                                  Get.back();
                                  Get.to(() => TestMainScreen(file: file));
                                }
                              } else {
                                Get.back();
                                showOnlyConfirmDialog(context, '비밀번호가 맞지 않습니다');
                                _pwcontroller.text = '';
                                print('꽝');
                              }
                            }, _pwcontroller);
                            // print('index : $index');
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
    );
  }
}
