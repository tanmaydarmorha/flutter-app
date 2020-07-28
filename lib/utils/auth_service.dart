import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluvidmobile/modals/user.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'networking.dart';

class AuthService {
  static Future<User> handleGoogleSignIn(context) async {
    final GoogleSignIn googleSignIn = GoogleSignIn(
      scopes: <String>[
        'email',
      ],
      signInOption: SignInOption.standard,
    );

    try {
      final GoogleSignInAccount googleUser = await googleSignIn.signIn();
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      NetworkHelper networkHelper = NetworkHelper(
          url:
              'https://api.fluvid.com/api/v1/auth/login/google?authToken=${googleAuth.accessToken}&idToken=${googleAuth.idToken}');
      var response = await networkHelper.postData(
        header: {'Content-Type': 'application/json'},
      );

      if (response['status'] == 1) {
        return _handleSignInDetails(context, response);
      }
    } catch (error) {
      print('Error : $error');
    }
    return null;
  }

  static Future<User> handleFacebookSignIn(context) async {
    final facebookLogin = FacebookLogin();

    final result = await facebookLogin.logIn(['email', 'public_profile']);
    switch (result.status) {
      case FacebookLoginStatus.loggedIn:
        NetworkHelper networkHelper = NetworkHelper(
            url:
                'https://api.fluvid.com/api/v1/auth/login/facebook?authToken=${result.accessToken.token}');
        var response = await networkHelper.postData(
          header: {'Content-Type': 'application/json'},
        );

        if (response['status'] == 1) {
          return _handleSignInDetails(context, response);
        }
        break;
      case FacebookLoginStatus.cancelledByUser:
        print('Cancelled by User');
        break;
      case FacebookLoginStatus.error:
        print('Error Message ---- ${result.errorMessage}');
        break;
    }
    return null;
  }

  static Future<User> handleEmailSignIn({context, email, password}) async {
    NetworkHelper networkHelper =
        NetworkHelper(url: 'https://api.fluvid.com/api/v1/auth/login');
    var response = await networkHelper.postData(
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response['status'] == 1) {
      // save access token to local storage
      final prefs = await SharedPreferences.getInstance();
      currentUserToken = response['data']['userToken'];
      prefs.setString('fluvidToken', currentUserToken);

      // do not call _handleSignInDetails as the API endpoints are different
      return User(
        firstName: response['data']['userInfo']['first_name'],
        lastName: response['data']['userInfo']['last_name'],
        email: response['data']['userInfo']['email'],
        photoUrl: response['data']['userInfo']['profile_pic'],
      );
    } else {
      return null;
    }
  }

  static Future<User> _handleSignInDetails(context, response) async {
    // save access token to local storage
    final prefs = await SharedPreferences.getInstance();
    currentUserToken = response['data']['userToken'];
    prefs.setString('fluvidToken', currentUserToken);

    return User(
      firstName: response['data']['userProfile']['first_name'],
      lastName: response['data']['userProfile']['last_name'],
      email: response['data']['userProfile']['email'],
      photoUrl: response['data']['userProfile']['profile_pic'],
    );
  }
}
