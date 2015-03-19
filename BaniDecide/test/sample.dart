library test.sample;

import "dart:js" as js;
import "dart:convert";

var appId = "EeGKlcEmDhT5SMjQhs6iRaYdIIohsM6rGWNn9iP2";
var jsKey = "CEnbro29EZJaKvRqIdpH46yaJcfk8UTdEspS5Qrm";

js.JsObject parse;

void main() {
  parse = js.context['Parse'];
  parse.callMethod('initialize', [appId, jsKey]);
  
  test();
}

void test() {
  var theQid = "q3yq9juWU0"; // 暫時放的假問題的ID~
  js.JsObject a = js.context['Parse']['Cloud'];
  a.callMethod('run', ["getQuestion", {"qid": theQid}])
   .callMethod('then', [(_) => print("ok!"), (_) => print(js.context['JSON'].callMethod('stringify', [_]))]);
}