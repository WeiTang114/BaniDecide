library client.add_question;

import 'package:BaniDecide/client/component.dart';

void main() {
  QuestionInput input = new QuestionInput();
  input..startAddOptionListener()
       ..startSubmitListener();
}