import 'package:academy/model/user.dart';
import 'package:get/get.dart';

class TestState extends GetxController{
  final answer = <String>[].obs;
  final testDocId = ''.obs;
  final teacherPassword = ''.obs;
  final realAnswer = [].obs;
  final myAnswer = [].obs;
  final mySingleAnswer = [].obs;
  // final name = ''.obs;
  final answerDocId = ''.obs;//(추가)
  final submitLng = [].obs;// (추가)

  final teacherNameList = [].obs;
  final individualTestGet = [].obs;

  //test ind
  final individualAnswer = [].obs;

  final answerVisiual = [].obs; // 답 공개비공개
  final answerScore = [].obs;// 추가
  final answerDate = [].obs;// 추가
  final answerVisiual2 = [].obs; // 답 공개비공개
}