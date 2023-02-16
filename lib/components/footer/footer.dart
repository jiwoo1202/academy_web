import 'package:academy/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../util/font.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      // color: nowColor,
      // width: Get.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('MiSolution',style: f12w400grey8,),
          Text('대표 : 최현',style: f12w400grey8,),
          Text('주소 : 대전 유성구 테크노1로 75, 엠아이솔루션 311호 ',style: f12w400grey8,) ,
          Text('사업자 등록번호 : 393-81-02118 ',style: f12w400grey8,),
          const SizedBox(height: 10,),
          Row(
            children: [
              Text('이용약관',style: f12w400grey8,),
              Text(' | ',style: f12w400grey8,),
              Text('개인정보 보호',style: f12w400grey8,),
            ],
          ),
        ],
      ),
    );
  }
}
