library client.question;

import "dart:html";

import 'package:BaniDecide/client/util.dart';
import 'package:BaniDecide/client/component.dart';

void main() {
  String qid = getQuestionId(window.location);
print(qid);
  QuestionOutput output = new QuestionOutput(qid);
  output.generate();
}