
var RESP_BADREQUEST = "Bad request.";
var RESP_UNKNOWN = "Unknown Error.";



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
 *   success: {"q":q, "a":[a, b, c, d], "counts":[n1, n2, n3, n4]}
 *   fail: "message"
 */
Parse.Cloud.define("getQuestion", function(request, response) {
  var qid = request.params.qid;
  if (typeof qid === 'undefined' || qid == null) {
    response.error(
      JSON.stringify(RESP_BADREQUEST + 'correct: {"qid":qid}')
    );
  }

  var Question = Parse.Object.extend("Question");
  var query = new Parse.Query(Question);
  query.get(qid).then(function(question) {
    var qJSON = question.toJSON();
    var qResp = {
      q: qJSON.q,
      a: qJSON.a,
      counts: qJSON.counts,
    }
    response.success(JSON.stringify(qResp));
  }, function(error) {
    console.log("Error A: " + error)
    response.error(error);
  });
});

/**
 * add a new question
 * 
 * request:  {"q":q, "a":[q, a, b, c, d]}
 * response: 
 *   success: {"qid":qid}  
 *   fail: "message"
 */
Parse.Cloud.define("addQuestion", function(request, response) {
  var q = request.params.q;
  var a = request.params.a;
  if (isNullOrUndef(q) || isNullOrUndef(a) || a.length != 4) {
    response.error(RESP_BADREQUEST + 'correct: {"q":q, "a":[a1,a2,a3,a4]}');
  }

  var Question = Parse.Object.extend("Question");
  var question = new Question();
  question.set("q", q)
  question.set("a", a);
  question.set("counts", [0, 0, 0, 0]);
  question.save(null).then(function(qAgain) {
    var qid = qAgain.id;
    response.success(JSON.stringify({"qid":qid}));
  }, function(error) {
    console.log("Error B: " + error)
    response.error(error);
  });
});


/**
 * select an item of a problem
 * 
 * request:  {"uid":uid, "qid":qid, "number":n}
 * response: 
 *   success: {"counts":counts}
 *   fail: {"failtype":"message"}
 */
Parse.Cloud.define("selectItem", function(request, response) {
  var uid = request.params.uid;
  var qid = request.params.qid;
  var number = request.params.number;

  // check request
  if (isNullOrUndef(uid) || 
      isNullOrUndef(qid) ||
      isNullOrUndef(number)) {
    response.error(RESP_BADREQUEST + 'correct: {"uid":uid, "qid":qid, "number":n}');
  }

  var MyUser = Parse.Object.extend("MyUser");
  var query = new Parse.Query(MyUser);
  var myUser;
  var qJSON;
  query.equalTo("uid", uid);
  query.find().then(function(myUserList) {
    console.log("myUserList:" + JSON.stringify(myUserList));

    // user not exist yet
    if (myUserList.length == 0) {
      var newUser = new MyUser();
      newUser.set("uid", uid);
      newUser.set("answeredQids", []);
      return newUser.save(null);
    }

    myUser = myUserList[0];

    // check if he/she has voted!
    if (myUser.toJSON().answeredQids.indexOf(qid) >= 0) {
      return Parse.Promise.error("You have voted!");
    }
  }).then(function(newUserAgain){
    // new user added
    if (!isNullOrUndef(newUserAgain)) {
      myUser = newUserAgain;
      console.log("myUser = " + newUserAgain);
    }
    // select!
    var Question = Parse.Object.extend("Question");
    query = new Parse.Query(Question);
    return query.get(qid);
  }).then(function(question) {
    if (number < 0 || number > 3) {
      return Parse.Promise.error("number is not between 0 and 3, number = " + number);
    }

    // get question object
    qJSON = question.toJSON();
    console.log("item number ++");
    qJSON.counts[number] ++;
    return question.save({counts: qJSON.counts});
  }).then(function(qAgain) {
    // question item seleted
    var myUJSON = myUser.toJSON();
    myUJSON.answeredQids.push(qid);
    return myUser.save({answeredQids: myUJSON.answeredQids});
  }).then(function(results){
    // done
    response.success(JSON.stringify({counts:qJSON.counts}));
  }, function(error) {
    console.log("Error: " + error)
    response.error(error);
  });
});



function isNullOrUndef(obj) {
  return (typeof obj === 'undefined' || obj == null);
}

