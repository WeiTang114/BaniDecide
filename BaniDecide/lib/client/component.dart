library client.component;

import "dart:html";
import "dart:async";

import '../generic/field_name.dart';

class QuestionInput {
  TextInputElement question;
  List<TextInputElement> options = new List(DEFAULT_OPTION_NUM);
  
  QuestionInput() {
    question = querySelector('');
    options = querySelectorAll('');
  }
  
  Future submit() {
    final Completer completer = new Completer();
    return completer.future;
  }
  
  Map _jsonOfAddQuestion() {
    List data = new List() 
      ..add(question.text);
    options.forEach((option) {
      data.add(option.text);
    });
    
    Map json = new Map();
    json[QUESTION_INFO] = data;
    return json;
  }
}


class QuestionOutput {
  Element question;
  List<RadioButtonInputElement> options = new List(DEFAULT_OPTION_NUM);
  List<DivElement> optionsCount = new List(DEFAULT_OPTION_NUM);
  
  String uid;
  String qid;
  
  QuestionOutput(this.uid, this.qid) {
    question = querySelector('');
    options = querySelectorAll('');
    optionsCount = querySelectorAll('');
  }
  
  void generate(Map json) {
    List<String> questionInfo = json[QUESTION_INFO];
    List<String> optsCount = json[OPTIONS_COUNT];
    
    question.text = questionInfo[0];
    for (int i = 0; i < DEFAULT_OPTION_NUM; i++) {
      options[i].text = questionInfo[i+1];
      optionsCount[i].text = optsCount[i];
    }
  }
  
  Future select() {
    final Completer completer = new Completer();
    return completer.future;
  }
  
  Map _jsonOfSelectOption() {
    Map json = new Map();
    json[USER_ID] = uid;
    json[QUESTION_ID] = qid;
    json[OPTION_SELECTED] = _selectedOption;
    return json;
  }
  
  int get _selectedOption {
    for (int i = 0; i < DEFAULT_OPTION_NUM; i++) {
      if (options[i].checked)
        return i;
    }
    return NONE_SELECTED;
  }
}