var RESP_BADREQUEST = "Bad request.";
var RESP_UNKNOWN = "Unknown Error.";
var FB_APIURL = "https://graph.facebook.com/";

// DIDADIDI
var FB_APPID = "303348743168816";
var FB_APPSECRET = "233b0d6c54b3393e9b5827a573184c3f";

// qrdota_test
// var FB_APPID = "522857694518715";
// var FB_APPSECRET = "61c4853d2944845fcfcbfa9908c42864";



// general keys
var KEY_OBJECT_ID = "objectId";
var KEY_FB_UID = "fbUid";

// keys of User
var KEY_AUTHDATA = "authData";
var KEY_ANSWERED_QIDS = "answeredQids";
var KEY_ANSWERED_CNT = "answeredCount";

// keys of Question
var KEY_UID = "uid";
var KEY_Q = "q";
var KEY_A = "a";
var KEY_AN = "an";
var KEY_COUNTS = "counts";


// Use Parse.Cloud.define to define as many cloud functions as you want.
// For example:
Parse.Cloud.define("hello", function(request, response) {
  response.success("Hello world!");
});




Parse.Cloud.define("uploadParseUser", function(request, response) {
  var user = request.params.user;
  var fbUid = user.authData.facebook.id;
  var msg;
  var query = new Parse.Query(Parse.User);
  query.get(user.objectId).then(function(parseUser) {
    var answeredCnt = parseUser.get(KEY_ANSWERED_CNT);
    var answeredQids = parseUser.get(KEY_ANSWERED_QIDS);

    // save fbUid in a seperate column, save authdata 
    parseUser.set(KEY_FB_UID, fbUid);
    parseUser.set(KEY_ANSWERED_CNT,isNullOrUndef(answeredCnt) ? 0 : answeredCnt);
    parseUser.set(KEY_ANSWERED_QIDS,isNullOrUndef(answeredQids) ? [] : answeredQids);
    return parseUser.save();
  }).then(function(resp) {
    response.success(resp);
  }, function(error) {
    console.error("uploadParseUser fail." + JSON.stringify(error));
    response.error(JSON.stringify(error));
  }); 
});


/**
 * get a question's data, including items and their numbers
 * 
 * request: {"qid":qid}
 * response: 
 *   success: {"uid":uid, "q":q, "a":[a, b, c, d], "an":an, "counts":[n1, n2, n3, n4]}
 *   fail: "message"
 */
Parse.Cloud.define("getQuestion", function(request, response) {
  var qid = request.params.qid;
  if (typeof qid === 'undefined' || qid == null) {
    response.error(
      JSON.stringify(RESP_BADREQUEST + 'correct: {"qid":qid}')
    );
    return;
  }

  var Question = Parse.Object.extend("Question");
  var query = new Parse.Query(Question);
  var question;
  query.get(qid).then(function(questionResp) {
    question = questionResp;
    var qResp = {
      fbUid:  question.get(KEY_FB_UID),
      q:      question.get(KEY_Q),
      a:      question.get(KEY_A),
      an:     question.get(KEY_AN),
      counts: question.get(KEY_COUNTS)
    };
    response.success(JSON.stringify(qResp));
  }, function(error) {
    console.log("Error A: " + error);
    response.error(error);
  });
});

/**
 * add a new question
 * 
 * request:  {“uid":uid, "q":q, "a":[a1, a2...,an], "an":an}
 * response: 
 *   success: {"qid":qid}  
 *   fail: "message"
 */
Parse.Cloud.define("addQuestion", function(request, response) {
  var uid = request.params.uid;
  var q = request.params.q;
  var a = request.params.a;
  var an = request.params.an;
  if (isNullOrUndef(q) || isNullOrUndef(a)) {
    response.error(RESP_BADREQUEST + '{“uid":uid, "q":q, "a":[q, a1, a2...,an], "an":an}');
    return;
  }
  if (isNullOrUndef(an)) {
    an = a.length;
  }
 
  var query = new Parse.Query(Parse.User);
  query.get(uid).then(function(user) {
    var Question = Parse.Object.extend("Question");
    var question = new Question();
    question.set(KEY_UID, uid);
    question.set(KEY_Q, q);
    question.set(KEY_A, a);
    question.set(KEY_AN, an);
    question.set(KEY_COUNTS, Array.apply(null, new Array(an)).map(Number.prototype.valueOf,0));
    question.set(KEY_FB_UID, user.get(KEY_AUTHDATA).facebook.id);
    return question.save();
  }).then(function(qAgain) {
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
  var Question = Parse.Object.extend("Question");

  // check request
  if (isNullOrUndef(uid) || 
      isNullOrUndef(qid) ||
      isNullOrUndef(number)) {
    response.error(RESP_BADREQUEST + 'correct: {"uid":uid, "qid":qid, "number":n}');
    return;
  }

  var query = new Parse.Query(Parse.User);
  var user;
  var userJSON;
  var qJSON;
  query.get(uid).then(function(userResp) {
    user = userResp;
    userJSON = user.toJSON();
    console.log("user:" + JSON.stringify(userJSON));

    // check if he/she has voted!
    var answeredQids = userJSON[KEY_ANSWERED_QIDS];
    if (!isNullOrUndef(answeredQids) && answeredQids.indexOf(qid) >= 0) {
      return Parse.Promise.error("You have voted!");
    }

    // select!  
    query = new Parse.Query(Question);
    return query.get(qid);
  }).then(function(question) {
    if (number < 0 || number > question.get(KEY_AN) - 1) {
      return Parse.Promise.error("number is not between 0 and an(" + question.get(KEY_AN) - 1 + "), number = " + number);
    }

    // get question object
    qJSON = question.toJSON();
    console.log("item number ++");
    qJSON[KEY_COUNTS][number] ++;
    question.set(KEY_COUNTS, qJSON[KEY_COUNTS]);
    return question.save();
    //return question.save({KEY_COUNTS: qJSON[KEY_COUNTS]});
  }).then(function(qAgain) {
    // question item seleted
    if (isNullOrUndef(userJSON[KEY_ANSWERED_QIDS])) {
      userJSON[KEY_ANSWERED_QIDS] = [];
      userJSON[KEY_ANSWERED_CNT] = 0;
    }
    userJSON[KEY_ANSWERED_QIDS].push(qid);
    userJSON[KEY_ANSWERED_CNT]++;
    user.set(KEY_ANSWERED_QIDS, userJSON[KEY_ANSWERED_QIDS]);
    user.set(KEY_ANSWERED_CNT, userJSON[KEY_ANSWERED_CNT]);
    return user.save();
  }).then(function(results){
    // done
    response.success(JSON.stringify({counts:qJSON.counts}));
  }, function(error) {
    console.log("Error: " + error)
    response.error(error);
  });
});



var TYPE_FRIEND_ASKED = "friends_asked";
var TYPE_FRIEND_ANSWERED = "friends_answered";
/**
 * get other questions of some certain types, eg. those your friends asked or answered
 * request   {"uid":uid, "access_token":access_token, type":type, "count":count}
 *           type: either "friends_asked" or "friends_answered"
 * response  
 *    success: {"count":count, "questions":questions}
 *    fail:    {"failtype":failtype}
 *
 *       questions:[q1, q2, q3 ... qn]
 *       qi: {"fbUid":fbUid, "qid":qid, "q":q, "a":a, "an":an, "counts":counts}
 */
Parse.Cloud.define("getOtherQuestions", function(request, response) {
  var uid       = request.params.uid;
  var type      = request.params.type;
  var count     = request.params.count;
  var Question  = Parse.Object.extend("Question");
  var questions;

  // check request
  if (isNullOrUndef(uid) || 
      isNullOrUndef(type) ||
      isNullOrUndef(count)) {
    response.error(RESP_BADREQUEST + 'correct: {"uid":uid, "type":type, "count":count}');
    return;
  }

  // check "type" argument
  if (type != TYPE_FRIEND_ANSWERED && type != TYPE_FRIEND_ASKED) {
    response.error("Unknown type:" + type);
    return;
  }

  // query user
  var query = new Parse.Query(Parse.User);
  query.get(uid).then(function(user) {
    console.log("queried ParseUser " + user.toString());
    var fbUser = user.get("authData").facebook;
    var url = FB_APIURL + fbUser.id
              + "/friends?" 
              + "access_token=" + fbUser.access_token;

    console.log("requesting facebook:" + url);

    // request facebook for using friends
    return Parse.Cloud.httpRequest({url:url});
  }).then(function(resp) {
    console.log("facebook response:" + JSON.stringify(resp));
    var friends = resp.data.data;
    var fIds = [];
    for (var i = 0; i < friends.length; i++) {
      var f = friends[i];
      fIds.push(f.id);
    }

    if (fIds.length == 0) {
      response.error("no friends found");
      return;
    }

    // two types!
    if (type == TYPE_FRIEND_ASKED) {
      query = new Parse.Query(Question);
      query.containedIn(KEY_FB_UID, fIds);
      return query.find();
    }
    else if (type == TYPE_FRIEND_ANSWERED) {
      query = new Parse.Query(Parse.User);
      query.containedIn(KEY_FB_UID, fIds);
      query.greaterThan(KEY_ANSWERED_CNT, 0);
      return query.find();
    }
  }).then(function(resp) {
    if (type == TYPE_FRIEND_ASKED) {
      questions = resp;
      return Parse.Promise.as();
    }
    else if (type == TYPE_FRIEND_ANSWERED) {  
      var answeredFriends = resp;
      var qids = [];
      for (var i = 0; i < answeredFriends.length; i++) {
        var f = answeredFriends[i];
        var ansQids = f.get(KEY_ANSWERED_QIDS); 
        if (isNullOrUndef(ansQids)) {
          continue;
        }

        for (var j = 0; j < ansQids.length; j++) {
          var qid = ansQids[j];
          qids.push(qid);
        }
      }
      query = new Parse.Query(Question);
      query.containedIn(KEY_OBJECT_ID, qids);
      return query.find();
    }
  }).then(function(resp) {
    if (type == TYPE_FRIEND_ASKED) {
      return Parse.Promise.as();
    }
    else if (type == TYPE_FRIEND_ANSWERED) {  
      questions = resp;
      return Parse.Promise.as();
    }    
  }).then(function(resp) {
    var qRet = [];
    var cntRet = 0;
    for (var i = 0; i < count; i++, cntRet++) {
      if (isNullOrUndef(questions) || i >= questions.length) {
        // no question!
        break;
      }
      var q = questions[i].toJSON();
      qRet.push({
        fbUid:  q[KEY_FB_UID],
        qid:    q[KEY_OBJECT_ID],
        q:      q[KEY_Q],
        a:      q[KEY_A],
        counts: q[KEY_COUNTS]
      });
    }

    response.success(JSON.stringify({count: cntRet, questions: qRet}));
  }, function(error) {

    response.error(JSON.stringify(error));
  });
});





function isNullOrUndef(obj) {
  return (typeof obj === 'undefined' || obj == null);
}

