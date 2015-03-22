var init = false;

/**
 * Parse SDK initializaiton. You must call this before any function below is called.
 * Remember to add the <script> of Parse SDK to your html file.
 */
function initParse() {
  if (isNullOrUndef(Parse)) {
    console.error("'Parse' is undefined. Please check if you've added PARSE SDK into your html file.");
  }
  if (init) {
    return;
  }

  var appId = "EeGKlcEmDhT5SMjQhs6iRaYdIIohsM6rGWNn9iP2";
  var jsKey = "CEnbro29EZJaKvRqIdpH46yaJcfk8UTdEspS5Qrm";
  Parse.initialize(appId, jsKey);

  init = true;
}


function uploadParseUser(onSuccess, onFailure) {
  if (!init) {
    initParse();
  }

  var user = Parse.User.current();
  if (isNullOrUndef(user)) {
    var msg = "Parse.User.current() is null, not logged in";
    console.error(msg);
    onFailure({failtype:msg});
    return;
  }

  Parse.Cloud.run("uploadParseUser", {
    user:Parse.User.current().toJSON()
  }).then(function(response) {
    onSuccess("OK");
  }, function(error) {
    onFailure({failtype:error.message});
  });
}


/**
 * getQuestion. initParse() is required to be called before getQuestion().
 * @param  {string} qid       the qid of the question you are getting
 * @param  {function} onSuccess function({fbUid:fbUid, q:q, a:a, an:an, counts:counts})
 * @param  {function} onFailure function({failtype:"errrrr"})
 * @return {[type]}           [description]
 */
function getQuestion(qid, onSuccess, onFailure) {
  if (!init) {
    initParse();
  }
  Parse.Cloud.run("getQuestion", {qid: qid}).then(function(respStr) {
    console.log(respStr);
    var resp = JSON.parse(respStr);
    console.log("question:" + resp.q + ", options:" + resp.a + ", counts:" + resp.counts);
    
    onSuccess({
      fbUid:  resp.fbUid, 
      q:      resp.q, 
      a:      resp.a, 
      an:     resp.an,
      counts: resp.counts
    });
  }, function(error) {
    console.log(JSON.stringify(error));
    if (!isNullOrUndef(error.message)) {
      onFailure({failtype:error.message});
    }
    else {
      onFailure({failtype: "Unknown Error, response: " + JSON.stringify(error)});
    }
  });
}

/**
 * addQuestion. initParse() is required to be called before addQuestion().
 * @param {string} question    eg. "How are you?"
 * @param {array} answers      eg. ["fine", "yo", "apple", "qrdota"]
 * @param {function} onSuccess function({qid:newQid})
 * @param {function} onFailure function({failtype:"errrrr"})
 */
function addQuestion(question, answers, onSuccess, onFailure) {
  if (!init) {
    initParse();
  }

  // check parse log in!
  if (!isParseLoggedIn()) {
    var msg = "not logged in yet";
    console.error(msg);
    onFailure({failtype:msg});
    return;
  }

  // add question
  Parse.Cloud.run("addQuestion", {
    uid:Parse.User.current().id, 
    q: question, 
    a: answers, 
    an:answers.length
  }).then(function(respStr) {
    var resp = JSON.parse(respStr);
    console.log("new qid=" + resp.qid);
    onSuccess({qid:resp.qid});
  }, function(error) {
    console.log(JSON.stringify(error));
    if (!isNullOrUndef(error.message)) {
      onFailure({failtype:error.message});
    }
    else {
      onFailure({failtype: "Unknown Error, response: " + JSON.stringify(error)});
    }
  });

}


/**
 * select an item. initParse() is required to be called before selectItem().
 * @param  {string} qid         your qid
 * @param  {int}    number      the option number you vote, 0 to 3
 * @param  {function} onSuccess function({counts:newCounts})
 * @param  {function} onFailure function({failtype:"errrrr"})
 * @return {[type]}           [description]
 */
function selectItem(qid, number, onSuccess, onFailure) {
  if (!init) {
    initParse();
  }

  // check parse log in
  if (!isParseLoggedIn()) {
    var msg = "not logged in yet";
    console.error(msg);
    onFailure({failtype:msg});
    return;
  }


  Parse.Cloud.run("selectItem", {
      uid: Parse.User.current().id, 
      qid: qid, 
      number: number
  }).then(function(respStr) {
    var resp = JSON.parse(respStr);
    console.log(respStr);
    onSuccess({counts:resp.counts});
  }, function(error) {
    console.log(JSON.stringify(error));
    if (!isNullOrUndef(error.message)) {
      onFailure({failtype:error.message});
    }
    else {
      onFailure({failtype: "Unknown Error, response: " + JSON.stringify(error)});
    }
  });
}

/**
 * get 2 type of list of questions: "friends_asked" or "friends_answered"
 * Facebook permission: "user_friends" is required. (got when log in)
 * 
 * @param  {string} type       "friends_asked" or "friends_answered"
 * @param  {int}    count      limit of the number of questions you want. 
 *                             the returned questions will be no more than "count"
 * @param  {func}   onSuccess  func({questions:[q1, q2,..], count: count})
 *                             qi: {fbUid:fbUid, qid:qid, q:q, a:a, an:an, counts:counts}
 *                             count: the number of returned questions
 * @param  {func}   onFailure  func({failtype:string msg})
 * @return {void}
 */
function getOtherQuestions(type, count, onSuccess, onFailure) {
    if (!init) {
    initParse();
  }

  // check parse log in
  if (!isParseLoggedIn()) {
    var msg = "not logged in yet";
    console.error(msg);
    onFailure({failtype:msg});
    return;
  }

  Parse.Cloud.run("getOtherQuestions", {
    uid:   Parse.User.current().id,
    type:  type,
    count: count
  }).then(function(resp) {
    console.log(JSON.parse(resp));
    onSuccess(JSON.parse(resp));
  }, function(error) {
    onFailure({failtype:error.message});
  });
}

function isNullOrUndef(obj) {
  return (typeof obj === 'undefined' || obj == null);
}


function isParseLoggedIn() {
  var user = Parse.User.current();
  if (user) {
    return true;
  }
  return false;
}

 