library client.question;

import "dart:html";

import 'package:BaniDecide/client/util.dart';
import 'package:BaniDecide/client/component.dart';

void main() {
  String qid = getQuestionId(window.location);
  QuestionOutput output = new QuestionOutput(qid);
  output.generate();
  output.startSelectListener();
  
  querySelector('.fb-comments').dataset['href'] = window.location.toString();
}