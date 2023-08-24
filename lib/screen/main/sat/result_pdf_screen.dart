import 'package:academy/provider/sat_state.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../../../../provider/user_state.dart';
import '../../../../util/loading.dart';

class ResultPdfScreen extends StatefulWidget {
  static final String id = '/result_pdf';
  final String? title;

  const ResultPdfScreen({Key? key, this.title}) : super(key: key);

  @override
  State<ResultPdfScreen> createState() => _ResultPdfScreenState();
}

class _ResultPdfScreenState extends State<ResultPdfScreen> {
  List _firebaseList = [];
  List _allCompany = [];
  List _satData = [];
  List _satAnswerData = [];
  List _mathIdx = [];
  bool _isLoading = true;
  int _englishScore = 0;
  int _mathScore = 0;
  int _3total = 0;
  PrintingInfo? printingInfo;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      final info = await Printing.info();

      await _firebaseAnswerGet();
      await _firebaseSatGet();
      String s = '';
      for(int i = 0; i < 54; i++){
        if(_satAnswerData[0]['answer'][i] == _satData[0]['answer'][i]){
          _englishScore++;
        }
      }

      for(int i = 0; i < 44; i++){
        s = _satData[0]['answer'][i+54].toString().replaceAll(" ", "");

        if(s.contains('/')){
          if(s.split('/').contains(_satAnswerData[0]['answer'][i+54])){
            _mathScore++;
            _mathIdx.add(i+54);
          }
        }
        else if(_satAnswerData[0]['answer'][i+54] == _satData[0]['answer'][i+54]){
          _mathScore++;
        }

      }
      setState(() {
        printingInfo = info;
        _isLoading = false;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? LoadingBodyScreen()
          : PdfPreview(
              allowPrinting: true,
              maxPageWidth: 700,
              canChangeOrientation: false,
              canChangePageFormat: false,
              // dynamicLayout: false,
              canDebug: false,
              pdfFileName: '${DateFormat('y-MM-dd').format(DateTime.now())}Digital Sat Report.pdf',
              build: (format) => _generatePdf(),
            ),
    );
  }

  Future<Uint8List> _generatePdf() async {
    final us = Get.put(UserState());
    final regFont = await rootBundle.load("font/Pretendard/Pretendard-Regular.ttf");
    final Prebold = await rootBundle.load("font/Pretendard/Pretendard-Bold.ttf");

    // final _logo = await rootBundle.loadString('assets/icon.png');

    // final _logo = pw.MemoryImage(
    //   (await rootBundle.load('assets/landing/icon.png')).buffer.asUint8List(),
    // );

    // final _stamp = pw.MemoryImage(
    //   (await rootBundle.load('assets/stamp.png')).buffer.asUint8List(),
    // );

    final ttf = pw.Font.ttf(regFont);
    final bold = pw.Font.ttf(Prebold);
    // final sansW500 = pw.Font.ttf(fontSans);
    final pdf = pw.Document();

    /// 1번 페이지
    pdf.addPage(
      pw.Page(
        // orientation: pw.PageOrientation.landscape,
        margin: pw.EdgeInsets.symmetric(horizontal: 19, vertical: 27),
        // pageFormat: PdfPageFormat.a4,
        pageFormat: PdfPageFormat.a4.portrait,
        theme: pw.ThemeData.withFont(base: ttf),
        build: (pw.Context context) {
          return pw.Stack(children: [
            pw.ListView(children: [
              pw.Container(
                  decoration: pw.BoxDecoration(
                    border: pw.Border(
                      bottom: pw.BorderSide(
                        color: PdfColor.fromInt(0xffFF8C00),
                        width: 2.0,
                      ),
                      top: pw.BorderSide(
                        color: PdfColor.fromInt(0xffFF8C00),
                        width: 3.0,
                      ),
                    ),
                  ),
                  child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.end, children: [
                    // pw.Container(
                    //   width: 32,
                    //   height: 32,
                    //   child: pw.Image(_logo),
                    // ),
                    pw.SizedBox(width: 200),
                    pw.Container(
                      alignment: pw.Alignment.centerRight,
                      child: pw.Padding(
                          padding: pw.EdgeInsets.symmetric(vertical: 6),
                          child: pw.Text('DIGITAL SAT REPORT  ', style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffFF8C00), fontSize: 30))),
                    )
                  ])),
              pw.SizedBox(height: 40),

              pw.Padding(
                  padding: pw.EdgeInsets.symmetric(horizontal: 12),
                  child: pw.Container(
                      child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                    pw.Text('NAME : ', style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffFF8C00), fontSize: 12)),
                    pw.Text('${_satAnswerData[0]['name']}', style: pw.TextStyle(font: bold, fontSize: 12)),
                    pw.Spacer(),
                    pw.Text('ID : ', style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffFF8C00), fontSize: 12)),
                    pw.Text('${_satAnswerData[0]['id']}', style: pw.TextStyle(font: bold, fontSize: 12)),
                    pw.Spacer(),
                    pw.Text('DATE : ', style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffFF8C00), fontSize: 12)),
                    pw.Text('${DateFormat('y-MM-dd').format(DateTime.parse('${_satAnswerData[0]['createDate']}'))}', style: pw.TextStyle(font: bold, fontSize: 12)),
                    pw.Spacer(),
                  ]))),
              pw.SizedBox(height: 20),

              pw.Table(
                  defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                  // border: pw.TableBorder.all(color: PdfColor.fromInt(0xffBBBBBB), width: 1),
                  children: [
                    pw.TableRow(children: [
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(vertical: 12),
                        color: PdfColor.fromInt(0xffFF8C00),
                        width: Get.width * 0.07,
                        height: Get.width * 0.032,
                        child: pw.Center(
                          child:  pw.Text(
                            'READING & WRITING',
                            style: pw.TextStyle(fontSize: 12, color: PdfColor.fromInt(0xffffffff), font: ttf),
                            textAlign: pw.TextAlign.center,
                          ),
                        )
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(vertical: 12),
                        color: PdfColor.fromInt(0xffEEEFF0),
                        width: Get.width * 0.03,
                        height: Get.width * 0.032,
                        child: pw.Center(
                          child:  pw.Text(
                            '${_satData[0]['englishScore'][_satAnswerData[0]['englishScore']]}',
                            style: pw.TextStyle(fontSize: 12, font: ttf),
                            textAlign: pw.TextAlign.center,
                          ),
                        )
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(vertical: 12),
                        color: PdfColor.fromInt(0xffFF8C00),
                        width: Get.width * 0.035,
                        height: Get.width * 0.032,
                        child: pw.Center(
                          child: pw.Text(
                            'MATH',
                            style: pw.TextStyle(fontSize: 12, color: PdfColor.fromInt(0xffffffff), font: ttf),
                            textAlign: pw.TextAlign.center,
                          ),
                        )
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(vertical: 12),
                        color: PdfColor.fromInt(0xffEEEFF0),
                        width: Get.width * 0.03,
                        height: Get.width * 0.032,
                        child: pw.Center(
                          child: pw.Text(
                            _satData[0]['math']=='false'?'0':
                            '${_satData[0]['mathScore'][_mathScore]}',
                            style: pw.TextStyle(fontSize: 12, font: ttf),
                            textAlign: pw.TextAlign.center,
                          ),
                        )
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(vertical: 12),
                        color: PdfColor.fromInt(0xff000000),
                        width: Get.width * 0.05,
                        height: Get.width * 0.032,
                        child:pw.Center(
                          child:  pw.Text(
                            'TOTAL SCORE',
                            style: pw.TextStyle(fontSize: 12, color: PdfColor.fromInt(0xffffffff), font: ttf),
                            textAlign: pw.TextAlign.center,
                          ),
                        )
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(vertical: 12),
                        color: PdfColor.fromInt(0xffEEEFF0),
                        width: Get.width * 0.03,
                        height: Get.width * 0.032,
                        child: pw.Center(
                          child: pw.Text(
                            // '${int.parse('${_satData[0]['englishScore'][_englishScore]}') + int.parse('${_satData[0]['mathScore'][_mathScore]}')}',
                            _satData[0]['math']=='false'
                                ?'${int.parse('${_satData[0]['englishScore'][_satAnswerData[0]['englishScore']]}')}'
                                : '${int.parse('${_satData[0]['englishScore'][_satAnswerData[0]['englishScore']]}') + int.parse('${_satData[0]['mathScore'][_mathScore]}')}',
                            style: pw.TextStyle(fontSize: 12, font: ttf),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                      ),
                    ]),
                  ]),
              pw.SizedBox(height: 20),

              pw.Container(
                  child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.start, children: [
                pw.Text('[ Title : ${_satData[0]['mainTitle']} ]', style: pw.TextStyle(font: bold, fontSize: 16)),
              ])),
              pw.SizedBox(height: 8),

              pw.Table(
                  defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                  border: pw.TableBorder.all(color: PdfColor.fromInt(0xffffffff), width: 2),
                  children: [
                    pw.TableRow(children: [
                      // pw.Container(
                      //   padding: pw.EdgeInsets.symmetric(vertical: 12),
                      //   color: PdfColor.fromInt(0xffFF8C00),
                      //   width: Get.width * 0.04,
                      //   height: Get.width * 0.032,
                      //   child: pw.Center(
                      //     child: pw.Text(
                      //       'REPORT NO.',
                      //       style: pw.TextStyle(fontSize: 12, color: PdfColor.fromInt(0xffffffff), font: bold),
                      //       textAlign: pw.TextAlign.center,
                      //     ),
                      //   )
                      // ),
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(vertical: 12),
                        color: PdfColor.fromInt(0xffFF8C00),
                        width: Get.width * 0.04,
                        height: Get.width * 0.032,
                        child: pw.Center(
                          child: pw.Text(
                            'TEST DATE',
                            style: pw.TextStyle(fontSize: 12, color: PdfColor.fromInt(0xffffffff), font: bold),
                            textAlign: pw.TextAlign.center,
                          ),
                        )
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(vertical: 12),
                        color: PdfColor.fromInt(0xffFF8C00),
                        width: Get.width * 0.06,
                        height: Get.width * 0.032,
                        child: pw.Center(
                          child: pw.Text(
                            'READING & WRITING',
                            style: pw.TextStyle(fontSize: 12, color: PdfColor.fromInt(0xffffffff), font: bold),
                            textAlign: pw.TextAlign.center,
                          ),
                        )
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(vertical: 12),
                        color: PdfColor.fromInt(0xffFF8C00),
                        width: Get.width * 0.03,
                        height: Get.width * 0.032,
                        child: pw.Center(
                          child: pw.Text(
                            'MATH',
                            style: pw.TextStyle(fontSize: 12, color: PdfColor.fromInt(0xffffffff), font: bold),
                            textAlign: pw.TextAlign.center,
                          ),
                        )
                      ),
                      pw.Container(
                        padding: pw.EdgeInsets.symmetric(vertical: 12),
                        color: PdfColor.fromInt(0xffFF8C00),
                        width: Get.width * 0.045,
                        height: Get.width * 0.032,
                        child: pw.Center(
                          child: pw.Text(
                            'TOTAL SCORE',
                            style: pw.TextStyle(fontSize: 12, color: PdfColor.fromInt(0xffffffff), font: bold),
                            textAlign: pw.TextAlign.center,
                          ),
                        )
                      ),
                    ]),
                  ]),
              for (int i = 0; i < _satAnswerData.length; i++)
                pw.Table(
                    defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                    border: pw.TableBorder.all(color: PdfColor.fromInt(0xffffffff), width: 2),
                    children: [
                      pw.TableRow(children: [
                        // pw.Container(
                        //   padding: pw.EdgeInsets.symmetric(vertical: 12),
                        //   color: PdfColor.fromInt(0xffEEEFF0),
                        //   width: Get.width * 0.04,
                        //   height: Get.width * 0.032,
                        //   child: pw.Text(
                        //     '${12345}',
                        //     style:
                        //         pw.TextStyle(fontSize: 12, color: PdfColor.fromInt(0xff512BEE), decoration: pw.TextDecoration.underline, font: bold),
                        //     textAlign: pw.TextAlign.center,
                        //   ),
                        // ),
                        pw.Container(
                          padding: pw.EdgeInsets.symmetric(vertical: 12),
                          color: PdfColor.fromInt(0xffEEEFF0),
                          width: Get.width * 0.04,
                          height: Get.width * 0.032,
                          child: pw.Center(
                            child: pw.Text(
                              '${DateFormat('y-MM-dd').format(DateTime.parse('${_satAnswerData[i]['createDate']}'))}',
                              style: pw.TextStyle(fontSize: 12, font: bold),
                              textAlign: pw.TextAlign.center,
                            ),
                          )
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.symmetric(vertical: 12),
                          color: PdfColor.fromInt(0xffEEEFF0),
                          width: Get.width * 0.06,
                          height: Get.width * 0.032,
                          child: pw.Center(
                            child: pw.Text(
                              '${_satData[0]['englishScore'][_satAnswerData[i]['englishScore']]}',
                              style: pw.TextStyle(fontSize: 12, font: bold),
                              textAlign: pw.TextAlign.center,
                            ),
                          )
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.symmetric(vertical: 12),
                          color: PdfColor.fromInt(0xffEEEFF0),
                          width: Get.width * 0.03,
                          height: Get.width * 0.032,
                          child: pw.Center(
                            child:  pw.Text(
                              _satData[0]['math']=='false'?'0':
                              '${_satData[0]['mathScore'][_satAnswerData[i]['mathScore']]}',
                              style: pw.TextStyle(fontSize: 12, font: bold),
                              textAlign: pw.TextAlign.center,
                            ),
                          )
                        ),
                        pw.Container(
                          padding: pw.EdgeInsets.symmetric(vertical: 12),
                          color: PdfColor.fromInt(0xffEEEFF0),
                          width: Get.width * 0.045,
                          height: Get.width * 0.032,
                          child: pw.Center(
                            child: pw.Text(
                              _satData[0]['math']=='false'
                                  ?'${int.parse('${_satData[0]['englishScore'][_satAnswerData[i]['englishScore']]}')}'
                                  : '${int.parse('${_satData[0]['mathScore'][_satAnswerData[i]['mathScore']]}') + int.parse('${_satData[0]['englishScore'][_satAnswerData[i]['englishScore']]}')}',
                              style: pw.TextStyle(fontSize: 12, font: bold),
                              textAlign: pw.TextAlign.center,
                            ),
                          )
                        ),
                      ])
                    ]),
              // pw.SizedBox(height: 10),

              // pw.Table(
              //     defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              //     border: pw.TableBorder.all(color: PdfColor.fromInt(0xffffffff), width: 2),
              //     children: [
              //       pw.TableRow(children: [
              //         pw.Expanded(
              //           child: pw.Container(
              //               color: PdfColor.fromInt(0xffFF8C00),
              //               padding: pw.EdgeInsets.symmetric(vertical: 8),
              //               child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
              //                 pw.Text('READING & WRITING', style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 16)),
              //               ])),
              //         ),
              //         pw.Expanded(
              //           child: pw.Container(
              //               color: PdfColor.fromInt(0xffFF8C00),
              //               padding: pw.EdgeInsets.symmetric(vertical: 8),
              //               child: pw.Row(mainAxisAlignment: pw.MainAxisAlignment.center, children: [
              //                 pw.Text('MATH', style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 16)),
              //               ])),
              //         ),
              //       ])
              //     ]),

              // pw.Table(
              //     defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              //     border: pw.TableBorder.all(color: PdfColor.fromInt(0xffffffff), width: 2),
              //     children: [
              //       pw.TableRow(children: [
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8),
              //           color: PdfColor.fromInt(0xffFF8C00),
              //           width: Get.width * 0.25,
              //           child: pw.Text(
              //             'TYPE ANALYSIS',
              //             style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         ),
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8),
              //           color: PdfColor.fromInt(0xffFF8C00),
              //           width: Get.width * 0.1,
              //           child: pw.Text(
              //             'CORR',
              //             style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         ),
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8),
              //           color: PdfColor.fromInt(0xffFF8C00),
              //           width: Get.width * 0.1,
              //           child: pw.Text(
              //             '# of Q',
              //             style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         ),
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8),
              //           color: PdfColor.fromInt(0xffFF8C00),
              //           width: Get.width * 0.25,
              //           child: pw.Text(
              //             'TYPE ANALYSIS',
              //             style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         ),
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8),
              //           color: PdfColor.fromInt(0xffFF8C00),
              //           width: Get.width * 0.1,
              //           child: pw.Text(
              //             'CORR',
              //             style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         ),
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8),
              //           color: PdfColor.fromInt(0xffFF8C00),
              //           width: Get.width * 0.1,
              //           child: pw.Text(
              //             '# of Q',
              //             style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         )
              //       ]),
              //     ]),

              ///유형없음
              // pw.Table(
              //     defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              //     border: pw.TableBorder.all(color: PdfColor.fromInt(0xffffffff), width: 2),
              //     children: [
              //       pw.TableRow(children: [
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              //           color: PdfColor.fromInt(0xffffffff),
              //           width: Get.width * 0.25,
              //           child: pw.Text(
              //             '(유형없음)',
              //             style: pw.TextStyle(font: ttf, fontSize: 16),
              //             textAlign: pw.TextAlign.left,
              //           ),
              //         ),
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8),
              //           color: PdfColor.fromInt(0xffffffff),
              //           width: Get.width * 0.1,
              //           child: pw.Text(
              //             '${'31'}',
              //             style: pw.TextStyle(font: ttf, fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         ),
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8),
              //           color: PdfColor.fromInt(0xffffffff),
              //           width: Get.width * 0.1,
              //           child: pw.Text(
              //             '${'54'}',
              //             style: pw.TextStyle(font: ttf, fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         ),
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              //           color: PdfColor.fromInt(0xffffffff),
              //           width: Get.width * 0.25,
              //           child: pw.Text(
              //             '(유형없음)',
              //             style: pw.TextStyle(font: ttf, fontSize: 16),
              //             textAlign: pw.TextAlign.left,
              //           ),
              //         ),
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8),
              //           color: PdfColor.fromInt(0xffffffff),
              //           width: Get.width * 0.1,
              //           child: pw.Text(
              //             '${'31'}',
              //             style: pw.TextStyle(font: ttf, fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         ),
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8),
              //           color: PdfColor.fromInt(0xffffffff),
              //           width: Get.width * 0.1,
              //           child: pw.Text(
              //             '${'54'}',
              //             style: pw.TextStyle(font: ttf, fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         ),
              //       ])
              //     ]),

              ///total
              // pw.Table(
              //     defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
              //     border: pw.TableBorder.all(color: PdfColor.fromInt(0xffffffff), width: 2),
              //     children: [
              //       pw.TableRow(children: [
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              //           color: PdfColor.fromInt(0xff000000),
              //           width: Get.width * 0.25,
              //           child: pw.Text(
              //             'TOTAL',
              //             style: pw.TextStyle(font: ttf, color: PdfColor.fromInt(0xffffffff), fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         ),
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8),
              //           color: PdfColor.fromInt(0xff000000),
              //           width: Get.width * 0.1,
              //           child: pw.Text(
              //             '${'31'}',
              //             style: pw.TextStyle(font: ttf, color: PdfColor.fromInt(0xffffffff), fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         ),
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8),
              //           color: PdfColor.fromInt(0xff000000),
              //           width: Get.width * 0.1,
              //           child: pw.Text(
              //             '${'54'}',
              //             style: pw.TextStyle(font: ttf, color: PdfColor.fromInt(0xffffffff), fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         ),
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              //           color: PdfColor.fromInt(0xff000000),
              //           width: Get.width * 0.25,
              //           child: pw.Text(
              //             'TOTAL',
              //             style: pw.TextStyle(font: ttf, color: PdfColor.fromInt(0xffffffff), fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         ),
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8),
              //           color: PdfColor.fromInt(0xff000000),
              //           width: Get.width * 0.1,
              //           child: pw.Text(
              //             '${'31'}',
              //             style: pw.TextStyle(font: ttf, color: PdfColor.fromInt(0xffffffff), fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         ),
              //         pw.Container(
              //           padding: pw.EdgeInsets.symmetric(vertical: 8),
              //           color: PdfColor.fromInt(0xff000000),
              //           width: Get.width * 0.1,
              //           child: pw.Text(
              //             '${'54'}',
              //             style: pw.TextStyle(font: ttf, color: PdfColor.fromInt(0xffffffff), fontSize: 16),
              //             textAlign: pw.TextAlign.center,
              //           ),
              //         ),
              //       ])
              //     ])
            ]),
          ]);
        },
      ),
    );

    ///2번 페이지
    pdf.addPage(
      pw.Page(
        // orientation: pw.PageOrientation.landscape,
        margin: pw.EdgeInsets.symmetric(horizontal: 19, vertical: 27),
        // pageFormat: PdfPageFormat.a4,
        pageFormat: PdfPageFormat.a4.portrait,
        theme: pw.ThemeData.withFont(base: ttf),
        build: (pw.Context context) {
          return pw.Stack(children: [
            pw.ListView(children: [
              pw.Row(children: [
                pw.Expanded(
                  child: pw.Container(
                    color: PdfColor.fromInt(0xffFF8C00),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.symmetric(vertical: 6),
                        child: pw.Text('SECTION #1',
                            style: pw.TextStyle(font: ttf, color: PdfColor.fromInt(0xffFFFFFF), fontSize: 24), textAlign: pw.TextAlign.center)),
                  ),
                ),
                pw.SizedBox(width: 4),
                pw.Expanded(
                  child: pw.Container(
                    color: PdfColor.fromInt(0xffFF8C00),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.symmetric(vertical: 6),
                        child: pw.Text('SECTION #2',
                            style: pw.TextStyle(font: ttf, color: PdfColor.fromInt(0xffFFFFFF), fontSize: 24), textAlign: pw.TextAlign.center)),
                  ),
                ),
              ]),
              pw.Row(children: [
                pw.Expanded(
                  child: pw.Container(
                    color: PdfColor.fromInt(0xffFFFFFFF),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.symmetric(vertical: 6),
                        child: pw.Text('READING & WRITING', style: pw.TextStyle(font: ttf, fontSize: 16), textAlign: pw.TextAlign.center)),
                  ),
                ),
                pw.SizedBox(width: 4),
                pw.Expanded(
                  child: pw.Container(
                    child: pw.Padding(
                        padding: pw.EdgeInsets.symmetric(vertical: 6),
                        child: pw.Text('MATH', style: pw.TextStyle(font: ttf, fontSize: 16), textAlign: pw.TextAlign.center)),
                  ),
                ),
              ]),
              pw.Row(children: [
                pw.Expanded(
                  child: pw.Table(
                      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffffffff), width: 2),
                      children: [
                        pw.TableRow(children: [
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffF2D1B3),
                              child: pw.Text(
                                '#',
                                style: pw.TextStyle(font: ttf, fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffFF8C00),
                              child: pw.Text(
                                'Corr',
                                style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffFF8C00),
                              child: pw.Text(
                                'Stdt',
                                style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffFF8C00),
                              child: pw.Text(
                                'O/X',
                                style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          // pw.Flexible(
                          //   child: pw.Container(
                          //     padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          //     color: PdfColor.fromInt(0xffFF8C00),
                          //     child: pw.Text(
                          //       'Cor%',
                          //       style: pw.TextStyle(font: bold,  color:PdfColor.fromInt(0xffffffff),fontSize: 6),
                          //       textAlign: pw.TextAlign.center,
                          //     ),
                          //   ),
                          // ),
                        ]),
                      ]),
                ),
                pw.Expanded(
                  child: pw.Table(
                      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffffffff), width: 2),
                      children: [
                        pw.TableRow(children: [
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffF2D1B3),
                              child: pw.Text(
                                '#',
                                style: pw.TextStyle(font: ttf, fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffFF8C00),
                              child: pw.Text(
                                'Corr',
                                style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffFF8C00),
                              child: pw.Text(
                                'Stdt',
                                style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffFF8C00),
                              child: pw.Text(
                                'O/X',
                                style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          // pw.Flexible(
                          //   child: pw.Container(
                          //     padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          //     color: PdfColor.fromInt(0xffFF8C00),
                          //     child: pw.Text(
                          //       'Cor%',
                          //       style: pw.TextStyle(font: bold,  color:PdfColor.fromInt(0xffffffff),fontSize: 6),
                          //       textAlign: pw.TextAlign.center,
                          //     ),
                          //   ),
                          // ),
                        ]),
                      ]),
                ),
                pw.SizedBox(width: 4),
                pw.Expanded(
                  child: pw.Table(
                      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffffffff), width: 2),
                      children: [
                        pw.TableRow(children: [
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffF2D1B3),
                              child: pw.Text(
                                '#',
                                style: pw.TextStyle(font: ttf, fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffFF8C00),
                              child: pw.Text(
                                'Corr',
                                style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffFF8C00),
                              child: pw.Text(
                                'Stdt',
                                style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffFF8C00),
                              child: pw.Text(
                                'O/X',
                                style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          // pw.Flexible(
                          //   child: pw.Container(
                          //     padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          //     color: PdfColor.fromInt(0xffFF8C00),
                          //     child: pw.Text(
                          //       'Cor%',
                          //       style: pw.TextStyle(font: bold,  color:PdfColor.fromInt(0xffffffff),fontSize: 6),
                          //       textAlign: pw.TextAlign.center,
                          //     ),
                          //   ),
                          // ),
                        ]),
                      ]),
                ),
                pw.Expanded(
                  child: pw.Table(
                      defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
                      border: pw.TableBorder.all(color: PdfColor.fromInt(0xffffffff), width: 2),
                      children: [
                        pw.TableRow(children: [
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffF2D1B3),
                              child: pw.Text(
                                '#',
                                style: pw.TextStyle(font: ttf, fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffFF8C00),
                              child: pw.Text(
                                'Corr',
                                style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffFF8C00),
                              child: pw.Text(
                                'Stdt',
                                style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          pw.Flexible(
                            child: pw.Container(
                              padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                              color: PdfColor.fromInt(0xffFF8C00),
                              child: pw.Text(
                                'O/X',
                                style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                                textAlign: pw.TextAlign.center,
                              ),
                            ),
                          ),
                          // pw.Flexible(
                          //   child: pw.Container(
                          //     padding: pw.EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                          //     color: PdfColor.fromInt(0xffFF8C00),
                          //     child: pw.Text(
                          //       'Cor%',
                          //       style: pw.TextStyle(font: bold,  color:PdfColor.fromInt(0xffffffff),fontSize: 6),
                          //       textAlign: pw.TextAlign.center,
                          //     ),
                          //   ),
                          // ),
                        ]),
                      ]),
                ),
              ]),
              pw.Row(crossAxisAlignment: pw.CrossAxisAlignment.start, children: [
                /// 첫번째 Listview.builder
                pw.ListView.builder(
                    itemBuilder: (_, index) {
                      return pw.Row(children: [
                        pw.Container(
                          width: 24.5,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          margin: pw.EdgeInsets.symmetric(horizontal: 1),
                          color: PdfColor.fromInt(0xffF2D1B3),
                          child: pw.Text(
                            '${index + 1}',
                            style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          width: 36.4,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          margin: pw.EdgeInsets.symmetric(horizontal: 1),
                          color: PdfColor.fromInt(0xffF2F2F2),
                          child: pw.Text(
                            '${_satData[0]['answer'][index].toUpperCase()}',
                            style: pw.TextStyle(font: bold, fontSize: 6),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          width: 36.4,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          // margin: pw.EdgeInsets.only: 1),
                          color: PdfColor.fromInt(0xffF2F2F2),
                          child: pw.Text(
                            _satAnswerData[0]['answer'][index] == '' ? 'X' : '${_satAnswerData[0]['answer'][index].toUpperCase()}',
                            style: pw.TextStyle(font: bold, fontSize: 6),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          width: 34.4,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          margin: pw.EdgeInsets.only(left: 2, right: 0),
                          color: PdfColor.fromInt(0xffF2F2F2),
                          child: pw.Text(
                            '${_satAnswerData[0]['answer'][index].toUpperCase() == _satData[0]['answer'][index].toUpperCase() ? 'O' : 'X'}',
                            style: pw.TextStyle(
                                font: bold,
                                color: _satAnswerData[0]['answer'][index].toUpperCase() == _satData[0]['answer'][index].toUpperCase()
                                    ? PdfColor.fromInt(0xff0D0D0D)
                                    : PdfColor.fromInt(0xffF20505),
                                fontSize: 6),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        // pw.Container(
                        //   width: 31.5,
                        //   padding: pw.EdgeInsets.symmetric(vertical: 4),
                        //   margin: pw.EdgeInsets.symmetric(horizontal: 1),
                        //   color: PdfColor.fromInt(0xffF2F2F2),
                        //   child: pw.Text(
                        //     '${'D'}',
                        //     style: pw.TextStyle(font: bold,fontSize: 6),
                        //     textAlign: pw.TextAlign.center,
                        //   ),
                        // ),
                      ]);
                    },
                    itemCount: 27),

                /// 두번째 Listview.builder
                pw.ListView.builder(
                    itemBuilder: (_, index) {
                      return pw.Row(children: [
                        pw.Container(
                          width: 24.5,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          margin: pw.EdgeInsets.only(left: 1.5, right: 1),
                          color: PdfColor.fromInt(0xffF2D1B3),
                          child: pw.Text(
                            '${index + 28}',
                            style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          width: 36.4,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          margin: pw.EdgeInsets.symmetric(horizontal: 1),
                          color: PdfColor.fromInt(0xffF2F2F2),
                          child: pw.Text(
                            '${_satData[0]['answer'][index + 27].toUpperCase()}',
                            style: pw.TextStyle(font: bold, fontSize: 6),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          width: 35,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          margin: pw.EdgeInsets.only(left: 1),
                          color: PdfColor.fromInt(0xffF2F2F2),
                          child: pw.Text(
                            _satAnswerData[0]['answer'][index + 27] == '' ? 'X' : '${_satAnswerData[0]['answer'][index + 27].toUpperCase()}',
                            style: pw.TextStyle(font: bold, fontSize: 6),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          width: 34.8,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          margin: pw.EdgeInsets.only(left: 2, right: 0),
                          color: PdfColor.fromInt(0xffF2F2F2),
                          child: pw.Text(
                            '${_satAnswerData[0]['answer'][index + 27].toUpperCase() == _satData[0]['answer'][index + 27].toUpperCase() ? 'O' : 'X'}',
                            style: pw.TextStyle(
                                font: bold,
                                color: _satAnswerData[0]['answer'][index + 27].toUpperCase() == _satData[0]['answer'][index + 27].toUpperCase()
                                    ? PdfColor.fromInt(0xff0D0D0D)
                                    : PdfColor.fromInt(0xffF20505),
                                fontSize: 6),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        // pw.Container(
                        //   width: 31.5,
                        //   padding: pw.EdgeInsets.symmetric(vertical: 4),
                        //   margin: pw.EdgeInsets.symmetric(horizontal: 1),
                        //   color: PdfColor.fromInt(0xffF2F2F2),
                        //   child: pw.Text(
                        //     '${'D'}',
                        //     style: pw.TextStyle(font: bold,fontSize: 6),
                        //     textAlign: pw.TextAlign.center,
                        //   ),
                        // ),
                      ]);
                    },
                    itemCount: 27),
                pw.SizedBox(width: 4.8),

                /// 세번째 Listview.builder
                pw.ListView.builder(
                    itemBuilder: (_, index) {
                      return pw.Row(children: [
                        pw.Container(
                          width: 24.5,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          margin: pw.EdgeInsets.symmetric(horizontal: 1),
                          color: PdfColor.fromInt(0xffF2D1B3),
                          child: pw.Text(
                            '${index + 1}',
                            style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          width: 36.4,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          margin: pw.EdgeInsets.symmetric(horizontal: 1),
                          color: PdfColor.fromInt(0xffF2F2F2),
                          child: pw.Text(
                            '${_satData[0]['math'] == 'false' ? '없음' : '${_satData[0]['answer'][index + 54].toUpperCase()}'}',
                            style: pw.TextStyle(font: bold, fontSize: 6),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          width: 35,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          margin: pw.EdgeInsets.only(left: 1),
                          color: PdfColor.fromInt(0xffF2F2F2),
                          child: pw.Text(
                            '${_satData[0]['math'] == 'false' ? '없음' : '${_satAnswerData[0]['answer'][index + 54].toUpperCase()}'}',
                            style: pw.TextStyle(font: bold, fontSize: 6),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          width: 34.5,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          margin: pw.EdgeInsets.only(left: 2, right: 0),
                          color: PdfColor.fromInt(0xffF2F2F2),
                          child: pw.Text(
                            '${_satData[0]['math'] == 'false' ? '없음' : _mathIdx.contains(index+54) ?  'O' : '${_satAnswerData[0]['answer'][index + 54].toUpperCase() == _satData[0]['answer'][index + 54].toUpperCase() ? 'O' : 'X'}'}',
                            style: pw.TextStyle(
                                font: bold,
                                fontSize: 6,
                                color: _satData[0]['math'] == 'false'
                                    ? PdfColor.fromInt(0xff0D0D0D)
                                    :_mathIdx.contains(index+54) ?  PdfColor.fromInt(0xff0D0D0D) : _satAnswerData[0]['answer'][index + 54].toUpperCase() == _satData[0]['answer'][index + 54].toUpperCase()
                                        ? PdfColor.fromInt(0xff0D0D0D)
                                        : PdfColor.fromInt(0xffF20505)),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        // pw.Container(
                        //   width: 31.5,
                        //   padding: pw.EdgeInsets.symmetric(vertical: 4),
                        //   margin: pw.EdgeInsets.symmetric(horizontal: 1),
                        //   color: PdfColor.fromInt(0xffF2F2F2),
                        //   child: pw.Text(
                        //     '${_satData[0]['math'] == 'false' ? '없음' :'D'}',
                        //     style: pw.TextStyle(font: bold,fontSize: 6),
                        //     textAlign: pw.TextAlign.center,
                        //   ),
                        // ),
                      ]);
                    },
                    itemCount: 22),

                /// 네번째 Listview.builder
                pw.ListView.builder(
                    itemBuilder: (_, index) {
                      return pw.Row(children: [
                        pw.Container(
                          width: 24.5,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          margin: pw.EdgeInsets.only(left: 1.5, right: 1),
                          color: PdfColor.fromInt(0xffF2D1B3),
                          child: pw.Text(
                            '${index + 23}',
                            style: pw.TextStyle(font: bold, color: PdfColor.fromInt(0xffffffff), fontSize: 6),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          width: 36.4,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          margin: pw.EdgeInsets.symmetric(horizontal: 1),
                          color: PdfColor.fromInt(0xffF2F2F2),
                          child: pw.Text(
                            '${_satData[0]['math'] == 'false' ? '없음' : '${_satData[0]['answer'][index + 76].toUpperCase()}'}',
                            style: pw.TextStyle(font: bold, fontSize: 6),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          width: 35,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          margin: pw.EdgeInsets.only(left: 1),
                          color: PdfColor.fromInt(0xffF2F2F2),
                          child: pw.Text(
                            '${_satData[0]['math'] == 'false' ? '없음' : '${_satAnswerData[0]['answer'][index + 76].toUpperCase()}'}',
                            style: pw.TextStyle(font: bold, fontSize: 6),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        pw.Container(
                          width: 34.5,
                          padding: pw.EdgeInsets.symmetric(vertical: 4),
                          margin: pw.EdgeInsets.only(left: 2.5, right: 0),
                          color: PdfColor.fromInt(0xffF2F2F2),
                          child: pw.Text(
                            '${_satData[0]['math'] == 'false' ? '없음' : _mathIdx.contains(index+76) ?  'O' : '${_satAnswerData[0]['answer'][index + 76].toUpperCase() == _satData[0]['answer'][index + 76].toUpperCase() ? 'O' : 'X'}'}',
                            style: pw.TextStyle(font: bold, fontSize: 6,color: _satData[0]['math'] == 'false'
                                ? PdfColor.fromInt(0xff0D0D0D)
                                : _mathIdx.contains(index+76) ?  PdfColor.fromInt(0xff0D0D0D) :_satAnswerData[0]['answer'][index + 76].toUpperCase() == _satData[0]['answer'][index + 76].toUpperCase()
                                ? PdfColor.fromInt(0xff0D0D0D)
                                : PdfColor.fromInt(0xffF20505)),
                            textAlign: pw.TextAlign.center,
                          ),
                        ),
                        // pw.Container(
                        //   width: 31.5,
                        //   padding: pw.EdgeInsets.symmetric(vertical: 4),
                        //   margin: pw.EdgeInsets.symmetric(horizontal: 1),
                        //   color: PdfColor.fromInt(0xffF2F2F2),
                        //   child: pw.Text(
                        //     '${_satData[0]['math'] == 'false' ? '없음' :'D'}',
                        //     style: pw.TextStyle(font: bold,fontSize: 6),
                        //     textAlign: pw.TextAlign.center,
                        //   ),
                        // ),
                      ]);
                    },
                    itemCount: 22),
              ]),
              pw.SizedBox(height: 20),
              pw.Row(children: [
                pw.Expanded(
                  child: pw.Container(
                    color: PdfColor.fromInt(0xffFF8C00),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.symmetric(vertical: 6),
                        child: pw.Text('Score : ${_satData[0]['englishScore'][_englishScore]}',
                            style: pw.TextStyle(font: ttf, color: PdfColor.fromInt(0xffFFFFFF), fontSize: 24), textAlign: pw.TextAlign.center)),
                  ),
                ),
                pw.SizedBox(width: 4),
                pw.Expanded(
                  child: pw.Container(
                    color: PdfColor.fromInt(0xffFF8C00),
                    child: pw.Padding(
                        padding: pw.EdgeInsets.symmetric(vertical: 6),
                        child: pw.Text('Score : ${_satData[0]['math']=='false'?0:_satData[0]['mathScore'][_mathScore]}',
                            style: pw.TextStyle(font: ttf, color: PdfColor.fromInt(0xffFFFFFF), fontSize: 24), textAlign: pw.TextAlign.center)),
                  ),
                ),
              ]),
            ]),
          ]);
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _firebaseSatGet() async {
    final ss = Get.put(SatState());
    final CollectionReference ref = FirebaseFirestore.instance.collection('sat');
    QuerySnapshot snapshot = await ref.where('docId', isEqualTo: '${ss.satAnswerDocId.value}').get();
    final allData = snapshot.docs.map((doc) => doc.data()).toList();
    _satData = allData;
  }

  Future<void> _firebaseAnswerGet() async {
    final ss = Get.put(SatState());
    final us = Get.put(UserState());
    if(ss.isTeacher.value == 'true'){
      final CollectionReference ref = FirebaseFirestore.instance.collection('satAnswer');
      QuerySnapshot snapshot = await ref
          .orderBy('createDate',descending: true)
          .where('status', isEqualTo: '4')
          .where('answerDocId', isEqualTo: '${ss.satAnswerDocId.value}')
          .where('docId', isEqualTo: '${ss.teacherSatAnswerDocId.value}')
          .get();
      final allData = snapshot.docs.map((doc) => doc.data()).toList();
      _satAnswerData = allData;
    }
    else{
      final CollectionReference ref = FirebaseFirestore.instance.collection('satAnswer');
      QuerySnapshot snapshot = await ref
          .orderBy('createDate',descending: true)
          .where('status', isEqualTo: '4')
          .where('id',isEqualTo: '${us.userList[0].id}')
          .where('answerDocId', isEqualTo: '${ss.satAnswerDocId.value}').get();
      final allData = snapshot.docs.map((doc) => doc.data()).toList();
      _satAnswerData = allData;
    }

  }
}
