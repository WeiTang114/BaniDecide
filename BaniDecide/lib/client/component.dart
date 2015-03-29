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
  DivElement submit;
  
  String qid;
  int ansCount;
  
  DivElement _optionTemplate;
  int _selectedOption;

  QuestionOutput(this.qid) {
    question = querySelector('#question-wrapper .content');
    options = new List();
    parent = querySelector('#options');
    submit = querySelector('#submit-option');
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
    submit.onClick.listen((_) => _select());
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


class OtherQuestions {
  
  DivElement _qBlock;
  DivElement _askedContainer;
  DivElement _answeredContainer;
  // ImageElement _thumb;
  // SpanElement _name;
  // SpanElemnt _question;

  OtherQuestions() {
    _askedContainer = querySelector('.asked');
    _answeredContainer = querySelector('.answered');
    _qBlock = querySelector('.q_block');
    //_qBlock.style.display = 'none';
    // _thumb = querySelector('.q_block img');
    // _name = querySelector('.q_block .name');
    // _question = querySelector('.q_block .question');
    
  }

  void generate() {
    handlerError(var ex) {
      print('Upload user failed: $ex');
    }

    _getOtherQuestions('friends_asked').then((response) {
      print('friends_asked:' + response.toString());
      var questions = response['questions'];
      for (var q in questions) {
        DivElement block = _newQuestionBlock(q, '問');      
        _askedContainer.children.insert(_askedContainer.children.length, block);  
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

  DivElement _newQuestionBlock(js.JsObject question, String actionStr) {
    DivElement block = _qBlock.clone(true);
    //block.style.display = 'r';
    SpanElement q = block.querySelector('.question');
    SpanElement name = block.querySelector('.name');
    SpanElement action = block.querySelector('.action');
    ImageElement thumb = block.querySelector('.thumb');
    String fbUid = question['fbUid'];
    action.text = actionStr + '：';
    q.text = question['q'];

    var fbUrl = "https://graph.facebook.com/";
    var uid = question['fbUid'];
    var urlProfile = fbUrl + uid + '?access_token=' + getAccessToken();
    var urlPicture = fbUrl + uid + "/picture?type=large&access_token=" + getAccessToken();

    print('urlProfile:' + urlProfile);
    print('urlPicture:' + urlPicture);

    var request = HttpRequest.getString(urlProfile).then((respText) {
      Map resp = JSON.decode(respText);
      var jsonString = respText;
      print(jsonString);
      name.text = resp['name'];
    });

    // var requestPic = HttpRequest.getString(urlPicture).then((respText) {
    //   Map resp = JSON.decode(respText);
    //   var jsonString = respText;
    //   //print(jsonString);
    //   var picUrl = resp['data']['url'];
    //   print("picUrl:" + picUrl);
    //   thumb.src = picUrl;
    // });

    thumb.src = urlPicture;

    return block;
  }

  String getAccessToken() {
    return js.context.callMethod('getAccessToken');
  }

}


class FBComment {
  DivElement a;
  
  FBComment(String url) {
    a.dataset['href'] = url;
  }
}