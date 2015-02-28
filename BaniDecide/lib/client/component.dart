library client.component;

import "dart:html";
import "dart:async";
import "dart:js" as js;

import '../generic/field_name.dart';

class QuestionInput {
  TextInputElement question;
  List<TextInputElement> options = new List(DEFAULT_OPTION_NUM);
  
  FormElement _sender;
  String _qid;
  
  QuestionInput() {
    question = querySelector('#question');
    options = querySelectorAll('.option');
    _sender = querySelector('#send-form');
    _startSubmitListener();
  }
  
  void _startSubmitListener() {
    querySelector('#create_question').onClick.listen((_) {
      if (_isValidInput) {
        _addQuestion().then((response) {
          _qid = response[QUESTION_ID];
print("qid: $_qid");
          _jumpPage();
        }).catchError((ex)
            => print('fail to add question: $ex'));
      }
    });    
  }
  
  Future _addQuestion() {
    final Completer cmpl = new Completer();
    
    var ok = (response) => cmpl.complete(response);
    var fail = (error) => cmpl.completeError(error[FAIL_TYPE]);
    js.context.callMethod('addQuestion', [_q, new js.JsArray.from(_ans), ok, fail]);
    
    return cmpl.future;
  }
  
  void _jumpPage() {
    AnchorElement jump = querySelector('#jump-page');
    jump.href = 'question.html?' + _qid;
    jump.click();
  }
  
  String get _q => question.value;
  
  List<String> get _ans {
    List<String> a = new List(DEFAULT_OPTION_NUM);
    for (int i = 0; i < DEFAULT_OPTION_NUM; i++)
      a[i] = options[i].value;
    return a;
  }
  
  bool get _isValidInput {
    if (_q.isEmpty) return false;
    for (int i = 0; i < 4; i++)
      if (_ans[i].isEmpty) return false;
    return true;
  }
}


class QuestionOutput {
  SpanElement question;
  List<RadioButtonInputElement> optionsRadio = new List(DEFAULT_OPTION_NUM);
  List<SpanElement> options = new List(DEFAULT_OPTION_NUM);
  List<DivElement> optionsCount = new List(DEFAULT_OPTION_NUM);
  
  String qid;
  String uid;
  
  QuestionOutput(this.qid) {
    question = querySelector('#question_wrapper .content');
    optionsRadio = querySelectorAll('#option_wrapper #options input');
    options = querySelectorAll('#option_wrapper #options .content');
    optionsCount = querySelectorAll('#option_wrapper #options .count');
  }
  
  void generate() {
    _getQuestion().then((response) {
      question.text = response[QUESTION_CONTENT];
      for (int i = 0; i < DEFAULT_OPTION_NUM; i++) {
        options[i].text = response[QUESTION_OPTIONS][i].toString();
        optionsCount[i].text = response[OPTIONS_COUNTS][i].toString() + ' 票';
      }  
    }).catchError((ex)
        => print('fail to generate question: $ex'));
  }
  
  void select() {
    _selectItem().then((response) {
      for (int i = 0; i < DEFAULT_OPTION_NUM; i++) 
        optionsCount[i].text = response[OPTIONS_COUNTS][i];
    }).catchError((ex)
        => print('fail to select option: $ex'));
  }
  
  Future _getQuestion() {
    final Completer cmpl = new Completer();
    
    var ok = (response) => cmpl.complete(response);
    var fail = (error) => cmpl.completeError(error);
    js.context.callMethod('getQuestion', [qid, ok, fail]);
    
    return cmpl.future;
  }
  
  Future _selectItem() {
    final Completer cmpl = new Completer();

    if (!_isLoggedin) {
      print("Please login first!");
    } else {
      var ok = (response) => cmpl.complete(response);
      var fail = (error) => cmpl.completeError(error);
      js.context.callMethod('selectItem', [uid, qid, _selectedOption, ok, fail]);
    }
    return cmpl.future;
  }
  
  int get _selectedOption {
    for (int i = 0; i < DEFAULT_OPTION_NUM; i++) {
      if (optionsRadio[i].checked)
        return i;
    }
    return NONE_SELECTED;
  }
  
  bool get _isLoggedin
    => js.context.callMethod('getloginstatus');
}