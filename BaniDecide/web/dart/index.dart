library client.question;

import 'dart:html';
import 'package:BaniDecide/client/util.dart';
import 'package:BaniDecide/client/component.dart';

OtherQuestions obj;

void main() {
  initFB().then((_) => getLoginState())
  .then((response) {    
    if (response == '1') {
      obj = new OtherQuestions();
      obj.generate();
    } else {
      querySelector('#fblogin').classes.remove('hidden');
    }
  }).catchError((ex) => print(ex));
}
