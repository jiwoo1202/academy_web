import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:academy/screen/main/student/test/test_check_screen.dart';
import 'package:academy/util/loading.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pdfx/pdfx.dart';

import '../../../../provider/answer_state.dart';
import '../../../../util/colors.dart';
import '../../../../util/font/font.dart';
import '../../../../util/font/font.dart';

class TestFilePage extends StatefulWidget {
  static final String id = '/test_file_page';
  final FutureOr<Uint8List>? content;

  const TestFilePage({Key? key, this.content}) : super(key: key);

  @override
  State<TestFilePage> createState() => _TestFilePageState();
}

class _TestFilePageState extends State<TestFilePage> {
  int pages = 0;
  late PdfController _pdfController;
  int indexPage = 0;
  List<String> _answer = [];
  bool isLoading = true;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      final args = ModalRoute.of(context)!.settings.arguments as TestFilePage;
      _pdfController = PdfController(
        document: PdfDocument.openData(args.content!),
      );
      addNumber();
      setState(() {
        isLoading = false;
      });
    });
    super.initState();
  }

  void addNumber() async {
    final as = Get.put(AnswerState());
    for (int i = 0; i < as.answerlength.length; i++) {
      _answer.add('');
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _pdfController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(
                Icons.navigate_before,
                color: Colors.black,
              ),
              onPressed: () {
                _pdfController.previousPage(
                  curve: Curves.ease,
                  duration: const Duration(milliseconds: 100),
                );
              },
            ),
            PdfPageNumber(
              controller: _pdfController,
              builder: (_, loadingState, page, pagesCount) => Container(
                alignment: Alignment.center,
                child: Text(
                  '$page/${pagesCount ?? 0}',
                  style: GetPlatform.isWeb && (Get.width * 0.2 <= 171)
                      ? f14w500
                      : f20w500,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(
                Icons.navigate_next,
                color: Colors.black,
              ),
              onPressed: () {
                _pdfController.nextPage(
                  curve: Curves.ease,
                  duration: const Duration(milliseconds: 100),
                );
              },
            ),
          ],
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        backgroundColor: backColor,
        // leading: IconButton(
        //   icon: Icon(
        //     Icons.arrow_back_ios_new,
        //     color: Color(0xff6f7072),
        //   ),
        //   onPressed: () {
        //     Get.back();
        //   },
        // ),
        elevation: 0,
      ),
      body: isLoading
          ? LoadingBodyScreen()
          : PdfView(
              builders: PdfViewBuilders<DefaultBuilderOptions>(
                options: const DefaultBuilderOptions(),
                documentLoaderBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                pageLoaderBuilder: (_) =>
                    const Center(child: CircularProgressIndicator()),
                pageBuilder: _pageBuilder,
              ),
              controller: _pdfController,
            ),
    );
  }

  PhotoViewGalleryPageOptions _pageBuilder(
    BuildContext context,
    Future<PdfPageImage> pageImage,
    int index,
    PdfDocument document,
  ) {
    return PhotoViewGalleryPageOptions(
      imageProvider: PdfPageImageProvider(
        pageImage,
        index,
        document.id,
      ),
      minScale: PhotoViewComputedScale.contained * 1,
      maxScale: PhotoViewComputedScale.contained * 2,
      initialScale: PhotoViewComputedScale.contained * 1.0,
      heroAttributes: PhotoViewHeroAttributes(tag: '${document.id}-$index'),
    );
  }

  Future<bool> onTerminated(BuildContext context) async {
    Get.back();
    return true;
  }
}
