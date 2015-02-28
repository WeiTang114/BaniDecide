library client.question;

import "dart:html";

import 'package:BaniDecide/client/util.dart';

void main() {
  String qid = getQuestionId(window.location);
  print(qid);
}