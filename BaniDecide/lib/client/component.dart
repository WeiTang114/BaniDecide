library client.component;

import "dart:html";
import "dart:async";
import "dart:js" as js;

import 'util.dart';
import '../generic/field_name.dart';

class QuestionInput {
  TextInputElement question;
  
  FormElement _parent;
  DivElement _child;
  DivElement _removeBtn;
  
  QuestionInput() {
    uploadUser().then((_) {
      question = querySelector('#question');
      _parent = querySelector('#question-container form');
      _child = querySelector('.option-wrapper');
      _removeBtn = querySelector('.remove-button');

      _startRemoveListener(querySelector('.option-wrapper'));
    })
    .catchError((ex) {
      print('Upload user failed: $ex');
      window.location.href = 'authen.html';
    });
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
      _addQuestion().then((response) {
        _jumpPage(response[QUESTION_ID]);
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
  
  void _jumpPage(String qid) {
    window.location.href = 'question.html?id=' + qid;
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

}


class QuestionOutput {
  SpanElement question;
  List<DivElement> options;
  FormElement parent;
  
  String qid;
  int ansCount;
  
  DivElement _optionTemplate;
  int _selectedOption;

  QuestionOutput(this.qid) {
    question = querySelector('#question-wrapper .content');
    options = new List();
    parent = querySelector('#options');
    _optionTemplate = querySelector('.option');
  }
  
  void generate() {
    _getQuestion().then((response) {
      question.text = response[QUESTION_CONTENT];
      ansCount = response[AN];

      for (int i = 0; i < ansCount; i++) {        
        DivElement temp = _optionTemplate.clone(true);
        temp.classes.remove('hidden');
        (temp.querySelector('input') as InputElement).value = '$i';
        temp.querySelector('.content').text = response[QUESTION_OPTIONS][i];
        temp.querySelector('.count').text = response[OPTIONS_COUNTS][i].toString() + ' 票';
        options.add(temp);
        
        parent.children.insert(i, temp);        
      }
      startSelectListener();
    }).catchError((ex)
        => print('fail to generate question: $ex'));
  }
  
  void startSelectListener() {
    for (int i = 0; i < options.length; i++) {
      options[i].onClick.listen((_) {
      _selectedOption = i;
      _select();
      });
    }
  }
  
  Future _getQuestion() {
    final Completer cmpl = new Completer();
    
    var ok = (response) => cmpl.complete(response);
    var fail = (error) => cmpl.completeError(error);
    js.context.callMethod('getQuestion', [qid, ok, fail]);
    
    return cmpl.future;
  }
  
  void _select() {
    _selectItem().then((response) {
      for (int i = 0; i < ansCount; i++)
        options[i].querySelector('.count').text = response[OPTIONS_COUNTS][i].toString() + ' 票';
    }).catchError((ex)
        => print('fail to select option: $ex'));
  }
  
  Future _selectItem() {
    final Completer cmpl = new Completer();
    var ok = (response) => cmpl.complete(response);
    var fail = (error) => cmpl.completeError(error);
    
    uploadUser()
    .then((response)
       => js.context.callMethod('selectItem', [qid, _selectedOption, ok, fail]))
    .catchError((ex) {
      print('Upload user failed: $ex');
      //TODO: click login
      querySelector('#FBLogin').click();
    });
    return cmpl.future;
  }
}


class FBComment {
  DivElement a;
  
  FBComment(String url) {
    a.dataset['href'] = url;
  }
}