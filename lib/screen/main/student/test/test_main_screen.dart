import 'dart:io';
import 'package:academy/provider/answer_state.dart';
import 'package:academy/provider/test_state.dart';
import 'package:academy/util/loading.dart';
import 'package:get/get.dart';

import 'package:academy/components/dialog/showAlertDialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

import '../../../../firebase/firebase_test.dart';
import '../../../../util/colors.dart';
import '../../../../util/font.dart';



class TestMainScreen extends StatefulWidget {
  final File file;
  const TestMainScreen({Key? key, required this.file}) : super(key: key);

  @override
  State<TestMainScreen> createState() => _TestMainScreenState();
}

class _TestMainScreenState extends State<TestMainScreen> {
  bool isLoading = true;
  final as = Get.put(AnswerState());
  late PDFViewController controller;
  int pages = 0;
  int indexPage = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController _scrollController = ScrollController();
  List<String> number = ['1', '2', '3', '4', '5'];
  List<String> _answer = [];
  // doc('test')/ answer에 리스트 만드는 함수
    void addNumber() async{
    for(int i=0;i<as.answerlength.length;i++) {
      _answer.add('');
      print('2');
    }
  }
  @override
  void initState() {
      Future.delayed(Duration.zero,()async{
     addNumber();
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ts = Get.put(TestState());
    final as = Get.put(AnswerState());
    return Scaffold(
      key: _scaffoldKey,
      //   endDrawer: isLoading?LoadingBodyScreen():Drawer(
      //    elevation: 16.0,
      //    child: Padding(
      //     padding: const EdgeInsets.all(8.0),
      //     child: ListView.builder(
      //       physics: const ClampingScrollPhysics(),
      //       shrinkWrap: true,
      //       itemCount: as.answerlength.length,
      //       itemBuilder: (_, index) {
      //         return Column(
      //           crossAxisAlignment: CrossAxisAlignment.start,
      //           children: [
      //             Text('${index + 1}번 문제', style: f18w500),
      //             isLoading?LoadingBodyScreen():
      //             Container(
      //                 height: 40,
      //                 child: ListView(
      //                   scrollDirection: Axis.horizontal,
      //                   children: number.map((number) {
      //                     return TextButton(
      //                         onPressed: () {
      //                           _answer[index] = number;
      //                           setState(() {});
      //                         },
      //                         style: TextButton.styleFrom(
      //                           minimumSize: Size.zero,
      //                           foregroundColor: Colors.transparent,
      //                           backgroundColor: Colors.transparent,
      //                           padding: EdgeInsets.only(right: 12, left: 12),
      //                           tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      //                         ),
      //                         child: Text(
      //                           '$number',
      //                           style: _answer[index] == number
      //                               ? f20Greenw700
      //                               : f18w500,
      //                         ));
      //                   }).toList(),
      //                 )),
      //             const SizedBox(
      //               height: 12,
      //             ),
      //           ],
      //         );
      //       },
      //     ),
      //   ),
      // ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: () {
      //     showComponentDialog(context, '제출하시겠습니까?', () async {
      //       // answerListAdd('SIg3OP2qqovlBZROIaRr');
      //       ts.answer.value = _answer;
      //       Get.back();
      //       await firebaseTestUpload();
      //     });
      //   },
      //   icon: Icon(Icons.check),
      //   label: Text(
      //     '제출하기',
      //     style: f16Whitew500,
      //   ),
      // ),
      appBar: AppBar(
        title: Text(
          '문제',
          style: f21w700grey5,
        ),
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Color(0xff6f7072),
          ),
          onPressed: () {
            Get.back();
          },
        ),
        flexibleSpace: GestureDetector(
          onTap: (){
            controller.setPage(0);
            print('hi');
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(
              right: 20
            ),
            child: Container(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(
                    right: 20
                  ),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: modelSheetClick,
                    child: Text('정답 입력',style: f16w700primary,),
                  ),
                ),
              ),
            ),
          )
        ],
        backgroundColor: backColor,
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.file.path,
            // autoSpacing: false,
            // swipeHorizontal: true,
            // pageSnap: false,
            // pageFling: false,
            onRender: (pages) => setState(() => this.pages = pages!),
            onViewCreated: (controller) =>
                setState(() => this.controller = controller),
            onPageChanged: (indexPage, _) =>
                setState(() => this.indexPage = indexPage!),
          ),
        ],
      ),
    );
  }
  void modelSheetClick(){
      final ts = Get.put(TestState());
     showModalBottomSheet(
       backgroundColor: Colors.grey,
         shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.only(
             topLeft: Radius.circular(20),
             topRight:Radius.circular(20),
           )
         ),
         context: context,
         isScrollControlled: true,
         builder: (builder){
           return StatefulBuilder(builder: (context, setState) {
             return DraggableScrollableSheet(
                 initialChildSize: 0.3,
                 minChildSize: 0.1,
                 maxChildSize: 0.7,
                 expand: false,
                 builder: (BuildContext context, ScrollController scrollController){
                   return Column(
                     children: [
                       Row(
                         children: [
                           FloatingActionButton.extended(
                             onPressed: () {
                               showComponentDialog(context, '제출하시겠습니까?', () async {
                                 // answerListAdd('SIg3OP2qqovlBZROIaRr');
                                 ts.answer.value = _answer;
                                 Get.back();
                                 await firebaseTestUpload();
                               });
                             },
                             icon: Icon(Icons.check),
                             label: Text(
                               '제출하기',
                               style: f16Whitew500,
                             ),
                           ),
                         ],
                         mainAxisAlignment: MainAxisAlignment.end,
                       ),
                       ListView.builder(
                         physics: const ClampingScrollPhysics(),
                         shrinkWrap: true,
                         itemCount: as.answerlength.length,
                         controller: scrollController,
                         itemBuilder: (_, index) {
                           return Padding(
                             padding: const EdgeInsets.all(20),
                             child: Column(
                               crossAxisAlignment: CrossAxisAlignment.start,
                               children: [
                                 Text('${index + 1}번 문제', style: f18w500),
                                 isLoading?LoadingBodyScreen():
                                 Container(
                                     height: 60,
                                     child: ListView(
                                       scrollDirection: Axis.horizontal,
                                       children: number.map((number) {
                                         return Row(
                                           children: [
                                             TextButton(
                                                 onPressed: () {
                                                   _answer[index] = number;
                                                   setState(() {
                                                   });
                                                 },
                                                 style: TextButton.styleFrom(
                                                     minimumSize: Size(52,52),
                                                     foregroundColor: Colors.transparent,
                                                     backgroundColor: _answer[index]==number?nowColor:Colors.white,
                                                     padding: EdgeInsets.only(right: 12, left: 12),
                                                     tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                                     shape: RoundedRectangleBorder(
                                                         borderRadius: BorderRadius.circular(20),
                                                         side: BorderSide(
                                                             width: 1,
                                                             color: Colors.grey
                                                         )
                                                     )
                                                 ),
                                                 child: Text(
                                                   '$number',
                                                   style: _answer[index] == number
                                                       ? f16Whitew700
                                                       : f16w700,
                                                 )),
                                             SizedBox(
                                               width: 10,
                                             )
                                           ],
                                         );
                                       }).toList(),
                                     )),
                                 const SizedBox(
                                   height: 12,
                                 ),
                               ],
                             ),
                           );
                         },
                       ),
                     ],
                   );
                 }
             );
            }
           );
         });
  }
}
