import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluvidmobile/screens/social_login_screen.dart';
import 'package:fluvidmobile/utils/auth_service.dart';
import 'package:fluvidmobile/utils/update_service.dart';
import 'package:fluvidmobile/utils/validation_service.dart';
import 'package:fluvidmobile/widgets/background_design.dart';
import 'package:fluvidmobile/widgets/rounded_button.dart';
import 'package:fluvidmobile/widgets/submit_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../constants.dart';
import 'home_screen.dart';

class SocialSignUpScreen extends StatefulWidget {
  @override
  _SocialSignUpScreenState createState() => _SocialSignUpScreenState();
}

class _SocialSignUpScreenState extends State<SocialSignUpScreen> {
  final _emailController = TextEditingController();

  String email;
  bool signUpHUD = false;
  bool showMessage = false;
  String message;

  int borderColor;
  int color;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: ModalProgressHUD(
        inAsyncCall: signUpHUD,
        child: SafeArea(
          child: Stack(
            children: <Widget>[
              Background(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Flexible(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 14.0, right: 24.0),
                        child: Image.asset(
                          'images/fluvid-logo-text.png',
                          alignment: Alignment.topCenter,
                          height: 80,
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          'Already have an account?  ',
                          textAlign: TextAlign.center,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) {
                              return SocialLoginScreen();
                            }));
                          },
                          child: Text(
                            'Login',
                            style: TextStyle(
                                color: Color(0xFFF3D032),
                                decoration: TextDecoration.underline),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    MediaQuery.of(context).viewInsets.bottom == 0.0
                        ? AutoSizeText(
                            'WELCOME',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFFF3D032),
                              fontWeight: FontWeight.w600,
                              fontSize: 28,
                            ),
                          )
                        : SizedBox(),
                    MediaQuery.of(context).viewInsets.bottom == 0.0
                        ? AutoSizeText(
                            'Be One of Us!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 35,
                                height: 1,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF39447A)),
                          )
                        : SizedBox(),
                    SizedBox(height: 30.0),
                    MediaQuery.of(context).viewInsets.bottom == 0.0
                        ? SocialMediaButton(
                            onPressed: () async {
                              loggedInUser =
                                  await AuthService.handleGoogleSignIn(context);
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          HomeScreen()));
                            },
                            buttonText: 'Sign Up With Google',
                            circleAvatar: CircleAvatar(
                              backgroundColor: Color(0xFFFFFFFF),
                              child: Image.asset(
                                'images/google-icon.png',
                                scale: 2.3,
                              ),
                            ),
                          )
                        : SizedBox(),
//                    SizedBox(
//                      height: MediaQuery.of(context).viewInsets.bottom == 0.0
//                          ? 10
//                          : 0,
//                    ),
//                    MediaQuery.of(context).viewInsets.bottom == 0.0
//                        ? SocialMediaButton(
//                            onPressed: () async {
//                              loggedInUser =
//                                  await AuthService.handleFacebookSignIn(
//                                      context);
//                              Navigator.pushReplacement(
//                                  context,
//                                  MaterialPageRoute(
//                                      builder: (BuildContext context) =>
//                                          HomeScreen()));
//                            },
//                            circleAvatar: CircleAvatar(
//                              backgroundColor: Color(0xFFF6F6F6),
//                              child: Icon(
//                                FontAwesome.facebook_f,
//                                color: Color(0xFF4267B2),
//                              ),
//                            ),
//                            buttonText: 'Facebook Sign Up',
//                          )
//                        : SizedBox(),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          MediaQuery.of(context).viewInsets.bottom == 0.0
                              ? Divider(
                                  indent: 20,
                                  endIndent: 20,
                                  thickness: 2,
                                  color: Color(0xFFd9d9d9),
                                )
                              : SizedBox(),
                          MediaQuery.of(context).viewInsets.bottom == 0.0
                              ? CircleAvatar(
                                  radius: 20,
                                  backgroundColor: Color(0xFFd9d9d9),
                                  child: Text(
                                    'OR',
                                    style: TextStyle(color: Colors.black),
                                  ),
                                )
                              : SizedBox(),
                        ],
                      ),
                    ),
                    TextField(
                      controller: _emailController,
                      style: TextStyle(color: Colors.black, fontSize: 14.0),
                      keyboardType: TextInputType.emailAddress,
                      decoration: kLoginTextFieldDecoration.copyWith(
                        labelText: 'Email',
                        prefixIcon: Icon(MaterialCommunityIcons.email_outline),
                        errorText: ValidationService.validateEmail(email),
                      ),
                      onChanged: (value) {
                        email = value;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: SubmitButton(
                        buttonText: 'Sign Up',
                        color: Color(0xFFFFD341),
                        onPressed: (email == null ||
                                ValidationService.validateEmail(email) != null)
                            ? null
                            : () async {
                                _emailController.clear();
                                setState(() {
                                  signUpHUD = true;
                                });

                                if (await UpdateService.registerNewUser(
                                    email: email)) {
                                  message = 'Email Sent';
                                  color = 0xAACFF1CC;
                                  borderColor = 0xFFB6EDB1;
                                } else {
                                  message = 'Email Already Registered';
                                  color = 0xAAFFDCDC;
                                  borderColor = 0xFFFDBDBD;
                                }

                                email = null;
                                setState(() {
                                  showMessage = true;
                                  signUpHUD = false;
                                });
                              },
                      ),
                    ),
                    showMessage
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(color),
                                border: Border.all(color: Color(borderColor)),
                              ),
                              child: Text(
                                message,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Color(message == 'Email Sent'
                                        ? 0xFF509B4B
                                        : 0xFFFF0000)),
                              ),
                            ),
                          )
                        : SizedBox(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
