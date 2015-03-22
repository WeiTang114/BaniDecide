var uid;
var accessToken;

function getLoginState() {
	FB.getLoginStatus(function (response) {
		if (response.status === 'connected') {      
			uid = response.authResponse.userID;
			return 1;
		} else if (response.status === 'not_authorized')
			return 2;
		else 
			return 3;
	})

}

function fb_login() {
	var scope = 'email,publish_stream,user_friends';

  initParse();
	Parse.FacebookUtils.logIn(scope, {
		success: function(user) {
		  if (!user.existed()) {
		    alert("User signed up and logged in through Facebook!");
		  } else {
		    alert("User logged in through Facebook!");
		  }
		  console.log(JSON.stringify(user));

      uid = user.get("authData").facebook.id;
      accessToken = user.get("authData").facebook.access_token;
		},
		error: function(user, error) {
		  alert("User cancelled the Facebook login or did not fully authorize.");
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