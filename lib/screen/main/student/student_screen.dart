import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../components/tile/main_tile.dart';
import '../main_search_screen.dart';

class StudentScreen extends StatefulWidget {
  const StudentScreen({Key? key}) : super(key: key);

  @override
  State<StudentScreen> createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    return Container(width: Get.width, height: Get.height,
        padding: EdgeInsets.symmetric(horizontal: Get.width*0.2, vertical: 30),
        child: Column(
          children: [
            SizedBox(height: 30,),
            Text(
              ' 학생',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 30,),
            //검색
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                var drugName =
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MainSearchScreen(),
                  ),
                );
                // Get.to(() => MainSearchScreen.id);
                // setState(() {
                //   if (drugName != null && drugName != '') createDrugItem(drugName);
                // });
              },
              child: Container(
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: 1,
                      color: Colors.black,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox(width: 50,),
                      Text(
                        '검색',
                        style: const TextStyle(
                            fontSize: 30,
                            color: Colors.black,
                            fontFamily: 'NotoSansKr',
                            fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.add,
                            size: 24,
                          ),
                          SizedBox(
                            width: 15,
                          )
                        ],
                      ),
                    ],
                  )),
            ),
            SizedBox(height: 40,),
            //조건 비어있으면 Text or 카드 있으면 카드 ListView 부르기
            false ?
            Text('선생님 이름 혹은\n코드를 검색해주세요', style: TextStyle(fontSize: 20),):
            ListView.builder(
              itemCount: 3,
              shrinkWrap: true,
              physics: const ClampingScrollPhysics(),
              itemBuilder: (context, index) {
                return Column(
                  children: [
                    MainTile(),
                    SizedBox(height: 30,),
                  ],
                );
              },
            ),
          ],
        ),
      );
  }
}
