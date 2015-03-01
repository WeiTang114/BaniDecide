var uid;
var accessToken;

FB.init({
  appId: '303348743168816',
  status: true,
  cookie: true,
  xfbml: true,
  oauth: true,
  version : 'v2.2'
});
	
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
	FB.login(function(response) {
		if (response.authResponse) {
			uid = response.authResponse.userID;
			accessToken = response.authResponse.accessToken;
		}
	}, {
	scope: 'email,publish_stream'
	});
}

function fb_share() {
	FB.ui({
	  method: 'feed',
	  name: 'DIDADIDI',
		link: 'http://localhost/index.html',
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