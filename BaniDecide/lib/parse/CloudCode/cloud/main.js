
var RESP_BADREQUEST = "Bad request.";
var RESP_UNKNOWN = "Unknown Error.";
var RESP_QUERY



// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});




/**
 * get a question's data, including items and their numbers
 * 
 * request: {"qid":qid}
 * response: 
 *   success: {"items":[q, a, b, c, d], "numbers":[n1, n2, n3, n4]}
 *   fail: {"failtype":"message"}
 */
Parse.Cloud.define("getQuestion", function(request, response) {
  var qid = request.params.qid;
  if (typeof qid === 'undefined' || qid == null) {
    response.error(
      JSON.stringify({failtype: RESP_BADREQUEST + 'correct: {"qid":qid}'})
    );
  }

  var Question = Parse.Object.extend("Question");
  var query = new Parse.Query(Question);
  query.get(qid).then(function(question) {
    var qJSON = question.toJSON();
    var qResp = {
      items: [qJSON.q].concat(qJSON.items),
      numbers: qJSON.numbers,
    }
    response.success(JSON.stringify(qResp));
  }, function(error) {
    response.error(JSON.stringify({"failtype":error}));
  });
});

/**
 * add a new question
 * 
 * request:  {"items":[q, a, b, c, d]}
 * response: 
 *   success: {"qid":qid}  
 *   fail: {"failtype":"message"}
 */
Parse.Cloud.define("addQuestion", function(request, response) {
  var items = request.params.items;
  if (typeof items === 'undefined' && items == null) {
    response.error(
      JSON.stringify({failtype: RESP_BADREQUEST + 'correct: {"qid":qid}'})
    );
  }

  var Question = Parse.Object.extend("Question");
  var question = new Question();
  question.set("q", items[0])
  question.set("items", items.slice(1, 1 + 4));
  question.set("numbers", [0, 0, 0, 0]);
  question.save(null).then(function(qAgain) {
    var qid = qAgain.id;
    response.success(JSON.stringify({"qid":qid}));
  }, function(error) {
    response.error(JSON.stringify({"failtype":error}));
  });
});


/**
 * select an item of a problem
 * 
 * request:  {"uid":uid, "qid":qid, "number":n}
 * response: 
 *   success: ~~
 *   fail: {"failtype":"message"}
 */
Parse.Cloud.define("selectItem", function(request, response) {
  
});