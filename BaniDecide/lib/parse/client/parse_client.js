var init = false;

/**
 * Parse SDK initializaiton. You must call this before any function below is called.
 * Remember to add the <script> of Parse SDK to your html file.
 */
function initParse() {
  if (isNullOrUndef(Parse)) {
    console.error("'Parse' is undefined. Please check if you've added PARSE SDK into your html file.");
  }

  var appId = "EeGKlcEmDhT5SMjQhs6iRaYdIIohsM6rGWNn9iP2";
  var jsKey = "CEnbro29EZJaKvRqIdpH46yaJcfk8UTdEspS5Qrm";
  Parse.initialize(appId, jsKey);
  init = true;
}


/**
 * getQuestion. initParse() is required to be called before getQuestion().
 * @param  {string} qid       the qid of the question you are getting
 * @param  {function} onSuccess function({q:q, a:a, counts:counts})
 * @param  {function} onFailure function({failtype:"errrrr"})
 * @return {[type]}           [description]
 */
function getQuestion(qid, onSuccess, onFailure) {
  if (!init) {
    console.error("getQuestoin(): initParse() hasn't been called.");
    return;
  }
  Parse.Cloud.run("getQuestion", {qid: qid}).then(function(respStr) {
    console.log(respStr);
    var resp = JSON.parse(respStr);
    console.log("question:" + resp.q + ", options:" + resp.a + ", counts:" + resp.counts);
    onSuccess({q:resp.q, a:resp.a, counts: resp.counts});
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
    console.error("addQuestoin(): initParse() hasn't been called.");
    return;
  }

  Parse.Cloud.run("addQuestion", {q: question, a: answers}).then(function(respStr) {
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
 * @param  {string} uid         your uid
 * @param  {string} qid         your qid
 * @param  {int}    number      the option number you vote, 0 to 3
 * @param  {function} onSuccess function({counts:newCounts})
 * @param  {function} onFailure function({failtype:"errrrr"})
 * @return {[type]}           [description]
 */
function selectItem(uid, qid, number, onSuccess, onFailure) {
  if (!init) {
    console.error("selectItem(): initParse() hasn't been called.");
    return;
  }

  Parse.Cloud.run("selectItem", 
    {uid: uid, qid: qid, number: number}
  ).then(function(respStr) {
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


function isNullOrUndef(obj) {
  return (typeof obj === 'undefined' || obj == null);
}

 