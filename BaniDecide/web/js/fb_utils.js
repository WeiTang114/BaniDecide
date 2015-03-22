var uid;
var accessToken;

function getLoginState(onSuccess, onFail) {
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
	Parse.FacebookUtils.logIn(null, {
		success: function(user) {
		  if (!user.existed()) {
		    console.log("User signed up and logged in through Facebook!");
		  } else {
		    consolg.log("User logged in through Facebook!");
		  }
		  console.log(JSON.stringify(user));

      uid = user.get("authData").facebook.id;
      accessToken = user.get("authData").facebook.access_token;
		},
		error: function(user, error) {
      console.log(error);
		  console.log("User cancelled the Facebook login or did not fully authorize.");
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
	  },
		function(response) {
		    if (response && response.post_id) {
		    //	alert('Post was published.');
			} else {
			//alert('Post was not published.');
			}
	  }
	);
}