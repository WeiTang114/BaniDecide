library client.component;

import "dart:html";
import "dart:async";
import "dart:js" as js;

import '../generic/field_name.dart';


Future checkLoggedIn() {
  print('checkLoggedIn called');

  final Completer cmpl = new Completer();
  var ok = (response) => cmpl.complete(response.toString() == '1');
  var fail = (error) => cmpl.completeError(error);
  js.context.callMethod('getLoginState', [ok, fail]);
  return cmpl.future;
}


class QuestionInput {
  TextInputElement question;
  //List<TextInputElement> options = new List(DEFAULT_OPTION_NUM);
  
  FormElement _parent;
  DivElement _child;
  FormElement _sender;
  DivElement _removeBtn;
  String _qid;
  
  QuestionInput() {
    question = querySelector('#question');
    //options = querySelectorAll('.option');
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
      if (!_isValidInput) {
        print('inpud is invalid.');
        return;
      }
      
      checkLoggedIn()
          .then((loggedIn) {
            print('loggedIn $loggedIn');
            if (loggedIn)
              _addQuestion();
            else {                
              print('Please login first!');
              js.context.callMethod('fb_login');
            }
          }).then((response) {
            _qid = response[QUESTION_ID];
            print("qid: $_qid");
            _jumpPage();
          }).catchError((ex)
            => print('fail to add question: $ex'));
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
    List<String> a = new List(_ansCount);
    for (int i = 0; i < _ansCount; i++)
      a[i] = _options[i].value;
    return a;
  }
  
  bool get _isValidInput {
    if (_q.isEmpty) return false;
    for (int i = 0; i < _ansCount; i++)
      if (_ans[i].isEmpty) return false;
    return true;
  }

  List<TextInputElement> get _options 
    => querySelectorAll('.option');

  int get _ansCount 
    => _options.length;


  Future _checkLoggedIn() {
    print('checkLoggedIn called');

    final Completer cmpl = new Completer();
    var ok = (response) => cmpl.complete(response.toString() == '1');
    var fail = (error) => cmpl.completeError(error);
    js.context.callMethod('getLoginState', [ok, fail]);
    return cmpl.future;
  }
}


class QuestionOutput {
  SpanElement question;
  List<RadioButtonInputElement> optionsRadio;
  List<SpanElement> options;
  List<DivElement> optionsCount;
  
  String qid;
  String uid;
  int ansCount;

  QuestionOutput(this.qid) {
    question = querySelector('#question-wrapper .content');
  }
  
  void generate() {
    _getQuestion().then((response) {
      question.text = response[QUESTION_CONTENT];
      ansCount = response[AN];

      optionsRadio = querySelectorAll('#option-wrapper #options input');
      options = querySelectorAll('#option-wrapper #options .content');
      optionsCount = querySelectorAll('#option-wrapper #options .count');
      for (int i = 0; i < ansCount; i++) {
        options[i].text = response[QUESTION_OPTIONS][i].toString();
        optionsCount[i].text = response[OPTIONS_COUNTS][i].toString() + ' 票';
      }  
      startSelectListener();
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
      for (int i = 0; i < ansCount; i++) 
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

    checkLoggedIn()
        .then((loggedIn) {
          if (!loggedIn) {
            print("Please login first!");
            js.context.callMethod('fb_login');      
          }
          else {
            uid = js.context['uid'].toString();
            print('uid: $uid');
            var ok = (response) => cmpl.complete(response);
            var fail = (error) => cmpl.completeError(error);
            js.context.callMethod('selectItem', [qid, _selectedOption, ok, fail]);
          }
        });


    // if (!_isLoggedin) {
    //   print("Please login first!");
    //   js.context.callMethod('fb_login');
    // } else {
    //   uid = js.context['uid'].toString();
    //   print('uid: $uid');
    //   var ok = (response) => cmpl.complete(response);
    //   var fail = (error) => cmpl.completeError(error);
    //   js.context.callMethod('selectItem', [uid, qid, _selectedOption, ok, fail]);
    // }
    return cmpl.future;
  }
  
  int get _selectedOption {
    for (int i = 0; i < ansCount; i++) {
      if (optionsRadio[i].checked)
        return i;
    }
    return NONE_SELECTED;
  }
  
  bool get _isLoggedin
    => js.context.callMethod('getLoginState').toString() == '1';
}


class FBComment {
  DivElement a;
  
  FBComment(String url) {
    a.dataset['href'] = url;
  }
}