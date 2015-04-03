library client.util;

import 'dart:html';
import 'dart:async';
import 'dart:js' as js;

String getQuestionId(Location location) 
  => location.search.isEmpty ? null : location.search.substring(4);

Future uploadUser() {
  final Completer cmpl = new Completer();
  
  var ok = (response) => cmpl.complete(response);
  var fail = (error) => cmpl.completeError(error);
  js.context.callMethod('uploadParseUser', [ok, fail]);
  
  return cmpl.future;
}

Future getLoginState() {
  final Completer cmpl = new Completer();
  
  var ok = (response) => cmpl.complete(response.toString());
  var fail = (error) => cmpl.completeError(error);
  js.context.callMethod('getLoginState', [ok, fail]);
  
  return cmpl.future;
}

Future initFB() {
  final Completer cmpl = new Completer();
  
  var ok = (response) => cmpl.complete(response);
  js.context.callMethod('initFB', [ok]);
  
  return cmpl.future;
}

Future fbLoginCallback() {
  final Completer cmpl = new Completer();
  
  var ok = (response) => cmpl.complete(response);
  var fail = (error) => cmpl.completeError(error);
  js.context.callMethod('fb_login_callback', [ok, fail]);
  
  return cmpl.future;
}