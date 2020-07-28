import 'package:flutter/material.dart';
import 'package:fluvidmobile/screens/social_login_screen.dart';
import 'package:fluvidmobile/utils/validation_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    openFirstScreen();
  }

  /// Check if the user is logged in.
  openFirstScreen() async {
    final prefs = await SharedPreferences.getInstance();
    String token = prefs.getString('fluvidToken');
    if (token == null) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => SocialLoginScreen()));
    } else {
      loggedInUser = await ValidationService.validateToken(token: token);
      if (loggedInUser != null) {
        currentUserToken = token;
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomeScreen()));
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => SocialLoginScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Center(
            child: Image.asset(
              'images/fluvid-logo-no-text.png',
              scale: 1.5,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                child: Center(child: CircularProgressIndicator()),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
