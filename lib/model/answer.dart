import 'package:cloud_firestore/cloud_firestore.dart';

class Answer {
  String? createDate;
  List answer;
  List individualFile;
  List individualTitle;
  List individualBody;
  List images;
  String? isIndividual;
  String? answerCount;
  String? docId;
  String? group;
  String? password;
  String? pdfCategory;
  String? pdfName;
  String? pdfUploadName;
  String? state;
  String? teacher;
  String? temp1;
  String? temp2;

  Answer(
      {required this.createDate,
        required this.answer,
        required this.individualFile,
        required this.individualTitle,
        required this.individualBody,
        required this.images,
        required this.isIndividual,
        required this.answerCount,
        required this.docId,
        required this.group,
        required this.password,
        required this.pdfCategory,
        required this.pdfName,
        required this.pdfUploadName,
        required this.state,
        required this.teacher,
        required this.temp1,
        required this.temp2,});

  Answer.fromMap(Map<String, dynamic> map)
      : createDate = map['createDate'],
        answer = map['answer'].cast<String>(),
        individualTitle = map['individualTitle'].cast<String>(),
        individualBody = map['individualBody'].cast<String>(),
        images = map['images'].cast<String>(),
        answerCount = map['answerCount'],
        isIndividual = map['isIndividual'],
        individualFile = map['individualFile'].cast<String>(),
        docId = map['docId'],
        group = map['group'],
        password = map['password'],
        pdfCategory = map['pdfCategory'],
        pdfName = map['pdfName'],
        pdfUploadName = map['pdfUploadName'],
        state = map['state'],
        teacher = map['teacher'],
        temp1 = map['temp1'],
        temp2 = map['temp2'];

  Map<String, dynamic> toMap() {
    return {
      "createDate": createDate,
      "answer": answer,
      "individualFile": individualFile,
      "individualBody": individualBody,
      "individualTitle": individualTitle,
      "images": images,
      "isIndividual": isIndividual,
      "answerCount": answerCount,
      "docId" : docId,
      "group" : group,
      "password" : password,
      "pdfCategory" : pdfCategory,
      "pdfName" : pdfName,
      "pdfUploadName" : pdfUploadName,
      "state": state,
      "teacher" : teacher,
      "temp1": temp1,
      "temp2": temp2,
    };
  }

  factory Answer.fromDocument(DocumentSnapshot doc) {
    return Answer(
      docId: doc.id,
      createDate: doc['createDate'],
      answer: doc['answer'].cast<String>(),
      individualFile: doc['individualFile'].cast<String>(),
      individualTitle: doc['individualTitle'].cast<String>(),
      individualBody: doc['individualBody'].cast<String>(),
      images: doc['images'].cast<String>(),
      isIndividual: doc['isIndividual'],
      answerCount : doc['answerCount'],
      group: doc['group'],
      password: doc['password'],
      pdfCategory : doc['pdfCategory'],
      pdfName : doc['pdfName'],
      pdfUploadName : doc['pdfUploadName'],
      state : doc['state'],
      teacher : doc['teacher'],
      temp1: doc['temp1'],
      temp2: doc['temp2'],
    );
  }
}
