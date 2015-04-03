var uid;
var accessToken;
var KEY_TOKEN = "access_token";

function initFB(onSuccess) {
  window.fbAsyncInit = function() {
    initParse();
    Parse.FacebookUtils.init({ // this line replaces FB.init({
      appId      : '303348743168816', // Facebook App ID
      status     : true,  // check Facebook Login status
      cookie     : true,  // enable cookies to allow Parse to access the session
      xfbml      : true,  // initialize Facebook social plugins on the page
      version    : 'v1.0' // point to the latest Facebook Graph API version
    });
 
    onSuccess(1);
  };
 
  (function(d, s, id) {
    var js, fjs = d.getElementsByTagName(s)[0];
    if (d.getElementById(id)) return;
    js = d.createElement(s); js.id = id;
    js.src = "http://connect.facebook.net/zh_TW/all.js";
    fjs.parentNode.insertBefore(js, fjs);
  }(document, 'script', 'facebook-jssdk'));
}

function getLoginState(onSuccess, onFail) {
  initParse();
  
  FB.getLoginStatus(function (response) {
    console.log('getLoginState: status:' + response.status);
    if (response.status === 'connected') {
      uid = response.authResponse.userID;
      onSuccess(1);
      return;
    } else if (response.status === 'not_authorized') {
      onSuccess(2);
      return;
    } else { 
      onSuccess(3);
      return;
    }
    onFail('onknown facebook login status:' + response.status);
  });
}

function fb_login() {
  console.log('fb_login called');
  var scope = 'email,publish_stream,user_friends';

  initParse();
  Parse.FacebookUtils.logIn(scope, {
    success: function(user) {
      if (!user.existed()) {
        console.log("User signed up and logged in through Facebook!");
      } else {
        console.log("User logged in through Facebook!");
      }
      console.log(JSON.stringify(user));

      uid = user.get("authData").facebook.id;
      accessToken = user.get("authData").facebook.access_token;
      saveAccessToken(accessToken);
    },
    error: function(user, error) {
      console.log(error);
      console.log("User cancelled the Facebook login or did not fully authorize.");
    }
  });
}

function fb_login_callback(onSuccess, onFail) {
  console.log('fb_login called');
  var scope = 'email,publish_stream,user_friends';

  initParse();
  Parse.FacebookUtils.logIn(scope, {
    success: function(user) {
      if (!user.existed()) {
        console.log("User signed up and logged in through Facebook!");
      } else {
        console.log("User logged in through Facebook!");
      }
      console.log(JSON.stringify(user));

      uid = user.get("authData").facebook.id;
      accessToken = user.get("authData").facebook.access_token;
      saveAccessToken(accessToken);
      onSuccess({user:user});
    },
    error: function(user, error) {
      console.log(error);
      console.log("User cancelled the Facebook login or did not fully authorize.");
      onFail(JSON.stringify(error));
    }
  }); 
}

function fb_share() {
  FB.ui({
    method: 'feed',
    name: 'DIDADIDI',
    link: document.URL,
    picture: 'http://www.csie.ntu.edu.tw/~b01902030/fb_test/pig.jpg',
    caption: '測試',
    description: 'testtesttest'
  }, function(response) {
    if (response && response.post_id) {
     //alert('Post was published.');
    } else {
     //alert('Post was not published.');
    }
  });
}

function saveAccessToken(token) {
  localStorage.setItem(KEY_TOKEN, token);
  console.log("accesstoken stored to storage with key=" + KEY_TOKEN);
}

function getAccessToken() {
  var token = localStorage.getItem(KEY_TOKEN);
  console.log("get accesstoken from localstorage");
  return token;
}