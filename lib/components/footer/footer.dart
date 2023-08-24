import 'package:academy/util/colors.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:html' as html;
import '../../screen/register/privatePolicy.dart';
import '../../util/font/font.dart';

class Footer extends StatelessWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: footerColor,
      width: Get.width,
      height: 200,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.copyright,color: footerTextColor,size:12,),
              SizedBox(
                width: 8,
              ),
              Text('2023 Copyright MiSolution',style: f14w400White,)
            ],
          ),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                  onTap: () {
                    GetPlatform.isWeb
                        ? html.window.open(
                        'http://misnetwork.iptime.org:8880/useService',
                        'naver')
                        : //https://www.naver.com
                    Get.toNamed(PrivatePolicy.id);
                  },
                  child: Text('이용약관',style: f14w400White,)),
              Text(' | ',style: f14w400White,),
              GestureDetector(
                  onTap: () {
                    GetPlatform.isWeb
                        ? html.window.open(
                        'http://misnetwork.iptime.org:8880/policy',
                        'naver')
                        : //https://www.naver.com
                    Get.toNamed(PrivatePolicy.id);
                  },
                  child: Text('개인정보 보호',style: f14w400White,)),
            ],
          ),
          SizedBox(
            height: 14,
          ),
          Text('대표 : 최현',style: f12w400grey8,),
          Text('주소 : 대전 유성구 테크노1로 75, 엠아이솔루션 311호 ',style: f12w400grey8,) ,
          Text('사업자 등록번호 : 393-81-02118 ',style: f12w400grey8,),
          const SizedBox(height: 13,),
          Text('MiSolution',style: f18Whitew700,)
        ],
      ),
    );
  }
}
