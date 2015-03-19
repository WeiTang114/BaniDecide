library client.component;

import "dart:html";
import "dart:async";
import "dart:js" as js;

import '../generic/field_name.dart';

class QuestionInput {
  TextInputElement question;
  List<TextInputElement> options = new List(DEFAULT_OPTION_NUM);
  
  FormElement _parent;
  DivElement _child;
  FormElement _sender;
  DivElement _removeBtn;
  String _qid;
  
  QuestionInput() {
    question = querySelector('#question');
    options = querySelectorAll('.option');
    _parent = querySelector('#question-container form');
    _child = querySelector('.option-wrapper').clone(true);
    _sender = querySelector('#send-form');
    _removeBtn = querySelector('.remove-button');
    
    _startRemoveListener(querySelector('.option-wrapper'));
  }
  
  void startAddOptionListener() {
    querySelector('#add-option').onClick.listen((_) {
      DivElement child = _child.clone(true);
      (child.querySelector('input') as InputElement).value = '';
      
     _parent.children.insert(_parent.children.length, child);
     _parent.children.insert(_parent.children.length, new BRElement());
     
     _displayRemoveBtn();
     _startRemoveListener(child);
    });
  }
  
  void startSubmitListener() {
    querySelector('#create-question').onClick.listen((_) {
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
  
  void _displayRemoveBtn() {
    List<DivElement> optionWrappers = _parent.querySelectorAll('.option-wrapper');
    if (optionWrappers.length > 1) {
      optionWrappers.forEach((option) {
        option.querySelector('.remove-button').classes.remove('hidden');
      });
    } else {
      optionWrappers[0].querySelector('.remove-button').classes.add('hidden');
    }
  }
  
  void _startRemoveListener(DivElement newElem) {
    var listener;
    listener = newElem.querySelector('.remove-button').onClick.listen((_) {
      newElem.remove();
      _displayRemoveBtn();
      listener.cancel();
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
    question = querySelector('#question-wrapper .content');
    optionsRadio = querySelectorAll('#option-wrapper #options input');
    options = querySelectorAll('#option-wrapper #options .content');
    optionsCount = querySelectorAll('#option-wrapper #options .count');
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
  
  void startSelectListener() {
    optionsRadio.forEach((RadioButtonInputElement optionRadio) {
      optionRadio.onClick.listen((_) => _select());
    });
  }
  void _select() {
    _selectItem().then((response) {
      for (int i = 0; i < DEFAULT_OPTION_NUM; i++) 
        optionsCount[i].text = response[OPTIONS_COUNTS][i].toString() + ' 票';
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
      js.context.callMethod('fb_login');
    } else {
      uid = js.context['uid'].toString();
      print('uid: $uid');
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
    => js.context.callMethod('getLoginState').toString() != '3';
}


class FBComment {
  DivElement a;
  
  FBComment(String url) {
    a.dataset['href'] = url;
  }
}