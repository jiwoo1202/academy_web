import 'package:academy/model/user.dart';
import 'package:get/get.dart';

class TestState extends GetxController{
  final answer = <String>[].obs;
  final testDocId = ''.obs;
  final realAnswer = [].obs;
  final myAnswer = [].obs;
  final mySingleAnswer = [].obs;
  // final name = ''.obs;
  final answerDocId = ''.obs;//(추가)
  final submitLng = [].obs;// (추가)

  final getMypageList = [].obs; //마이페이지 정답 리스트(추가)

}