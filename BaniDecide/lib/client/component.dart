library client.component;

import "dart:html";
import "dart:async";
import "dart:js" as js;
import "dart:convert";

import 'util.dart';
import '../generic/field_name.dart';

class QuestionInput {
  TextInputElement question;
  
  FormElement _parent;
  DivElement _child;
  DivElement _removeBtn;
  
  QuestionInput() {
    question = querySelector('#question');
    _parent = querySelector('#question-container form');
    _child = querySelector('.option-wrapper');
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
      getLoginState().then((response) {   
        if (response == '1') {
          return uploadUser().then((_) =>_addQuestion().then((response) {
          _jumpPage(response[QUESTION_ID]);
          }));
        } else {
          return fbLoginCallback().then((_) {
            return uploadUser().then((_) =>_addQuestion().then((response) {
              _jumpPage(response[QUESTION_ID]);
            }));
          });
        }
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
  DivElement submit;
  
  String qid;
  int ansCount;
  Map data;
  
  DivElement _optionTemplate;
  int _selectedOption;

  QuestionOutput(this.qid) {
    question = querySelector('#question-wrapper .content');
    options = new List();
    parent = querySelector('#options');
    submit = querySelector('#submit-option');
    _optionTemplate = querySelector('.option');
    
    data = new Map();
  }
  
  void generate() {
    _getQuestion().then((response) {
      
      data.addAll({QUESTION_CONTENT: response[QUESTION_CONTENT],
                   AN: response[AN],
                   QUESTION_OPTIONS: response[QUESTION_OPTIONS],
                   OPTIONS_COUNTS: response[OPTIONS_COUNTS]
                  });
      
      question.text = data[QUESTION_CONTENT];
      ansCount = data[AN];
      
      for (int i = 0; i < ansCount; i++) {        
        DivElement temp = _optionTemplate.clone(true);
        temp.classes.remove('hidden');
        (temp.querySelector('input') as InputElement).value = '$i';
        temp.querySelector('.content').text = data[QUESTION_OPTIONS][i];
        //temp.querySelector('.count').text = data[OPTIONS_COUNTS][i].toString() + ' 票';
        
        options.add(temp);
        parent.children.insert(i, temp);        
      }
      submit.classes.remove('hidden');
      startSelectListener();
    }).catchError((ex)
        => print('fail to generate question: $ex'));
  }
  
  void startSelectListener() {
    for (int i = 0; i < options.length; i++) {
      options[i].onClick.listen((_) {
      _selectedOption = i;
      (options[i].querySelector('input') as RadioButtonInputElement).checked = true;
      });
    }
  }
  
  void startSubmitListener() {
    submit.onClick.listen((_) {
      getLoginState().then((response) {   
        if (response == '1') {
          return uploadUser().then((_) => _select());
        } else {
          return fbLoginCallback().then((_) => uploadUser().then((_) => _select()));
        }
      }).catchError((ex) => print(ex));
    });
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
      data[OPTIONS_COUNTS] = response[OPTIONS_COUNTS];
    }).catchError((ex) {
      print('fail to select option: $ex');
    }).whenComplete(() {
      for (int i = 0; i < ansCount; i++)
        options[i].querySelector('.count').text = data[OPTIONS_COUNTS][i].toString() + ' 票';
      querySelector('#questions-asked').classes.remove('hidden');
      new OtherQuestions().generate();
      return _createChart();
    });
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
      querySelector('#FBLogin').click();
    });
    return cmpl.future;
  }
  
  Future _createChart() {
    final Completer cmpl = new Completer();
    var ok = (response) => cmpl.complete(response);
    var fail = (error) => cmpl.completeError(error);
    js.context.callMethod('createChart', [data[QUESTION_CONTENT],
                                          data[AN],
                                          data[QUESTION_OPTIONS],
                                          data[OPTIONS_COUNTS],
                                          ok, fail]);
    return cmpl.future;
  }
}


class OtherQuestions {
  
  DivElement _askedWrapper;
  AnchorElement _askedContainer;

  OtherQuestions() {
    _askedWrapper = querySelector('#questions-asked');
    _askedContainer = querySelector('#questions-asked .question-container');
  }

  void generate() {
    handlerError(var ex) {
      print('Upload user failed: $ex');
    }

    _getOtherQuestions('friends_asked').then((response) {
      print('friends_asked:' + response.toString());
      var questions = response['questions'];
      for (int i = 0; i < questions.length; i++) {
        AnchorElement block = _newQuestionBlock(questions[i]);
        block.href = 'question.html?id=' + questions[i][QUESTION_ID];
        _askedWrapper.children.insert(i + 1, block);  
      }
    }).catchError(handlerError);

    // give up friends_answered  
    /*
    _getOtherQuestions('friends_answered').then((response) {
      print('friends_answered:' + response.toString());
      var questions = response['questions'];
      for (var q in questions) {
        DivElement block = _newQuestionBlock(q);      
        _answeredContainer.children.insert(_answeredContainer.children.length, block);  
      }
    }).catchError(handlerError);
    */
  }

  Future _getOtherQuestions(String type) {
    final Completer cmpl = new Completer();
    
    var ok = (response) => cmpl.complete(response);
    var fail = (error) => cmpl.completeError(error[FAIL_TYPE]);
    js.context.callMethod('getOtherQuestions', [type, 3, ok, fail]);
    
    return cmpl.future;
  }

  AnchorElement _newQuestionBlock(js.JsObject question) {
    AnchorElement newQuestion = _askedContainer.clone(true);
    newQuestion.classes.remove('hidden');

    var fbUrl = "https://graph.facebook.com/";
    String fbUid = question['fbUid'];

    var urlProfile = fbUrl + fbUid + '?access_token=' + getAccessToken();
    var urlPicture = fbUrl + fbUid + "/picture?type=large&access_token=" + getAccessToken();

    print('urlProfile:' + urlProfile);
    print('urlPicture:' + urlPicture);

    var request = HttpRequest.getString(urlProfile).then((respText) {
      newQuestion.querySelector('.name').text = JSON.decode(respText)['name'];
    });
    
    newQuestion.querySelector('.question').text = question['q'].toString();
    (newQuestion.querySelector('.thumb')as ImageElement).src = urlPicture;

    return newQuestion;
  }

  String getAccessToken() {
    return js.context.callMethod('getAccessToken');
  }

}

