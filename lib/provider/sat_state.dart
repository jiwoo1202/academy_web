import 'package:academy/model/user.dart';
import 'package:get/get.dart';

class SatState extends GetxController{

  final individualSatGet = [].obs; /// 선생님 시험 정보 담는 변수
  final totalAnswer = [].obs;

  final satUpdateDocId = ''.obs; /// 학생이 문제 업데이트

  ///
  final satTeacherDocId = ''.obs;
  final satmyPage = ''.obs;
  final satpart  = ''.obs;
  final satAnswerDocId  = ''.obs;
  final satAnswer = [].obs;

  /// 0808 추가
  final teacherSatAnswerDocId = ''.obs;/// 선생님쪽 마이페이지에서 학생들 점수 확인
  final isTeacher = ''.obs;

}