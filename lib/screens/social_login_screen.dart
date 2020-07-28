import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluvidmobile/screens/social_signup_screen.dart';
import 'package:fluvidmobile/utils/auth_service.dart';
import 'package:fluvidmobile/utils/validation_service.dart';
import 'package:fluvidmobile/widgets/background_design.dart';
import 'package:fluvidmobile/widgets/rounded_button.dart';
import 'package:fluvidmobile/widgets/submit_button.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

import '../constants.dart';
import 'forgot_password_screen.dart';
import 'home_screen.dart';

class SocialLoginScreen extends StatefulWidget {
  @override
  _SocialLoginScreenState createState() => _SocialLoginScreenState();
}

class _SocialLoginScreenState extends State<SocialLoginScreen> {
  String email;
  String password;

  bool hud = false;

  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: hud,
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
                          'Don\'t have an account?  ',
                          textAlign: TextAlign.center,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushReplacement(context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) {
                              return SocialSignUpScreen();
                            }));
                          },
                          child: Text(
                            'Sign Up',
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
                            'Be Connected!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 35,
                                height: 1,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF39447A)),
                          )
                        : SizedBox(),
                    SizedBox(height: 30.0),
                    Row(
                      children: <Widget>[
                        MediaQuery.of(context).viewInsets.bottom == 0.0
                            ? Expanded(
                                child: SocialMediaButton(
                                  onPressed: () async {
                                    setState(() {
                                      hud = true;
                                    });
                                    loggedInUser =
                                        await AuthService.handleGoogleSignIn(
                                            context);
                                    setState(() {
                                      hud = false;
                                    });
                                    if (loggedInUser != null) {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  HomeScreen()));
                                    }
                                  },
                                  buttonText: 'Google',
                                  circleAvatar: CircleAvatar(
                                    backgroundColor: Color(0xFFFFFFFF),
                                    child: Image.asset(
                                      'images/google-icon.png',
                                      scale: 2.3,
                                    ),
                                  ),
                                ),
                              )
                            : SizedBox(),
                        SizedBox(
                          width: MediaQuery.of(context).viewInsets.bottom == 0.0
                              ? 10
                              : 0,
                        ),
                        MediaQuery.of(context).viewInsets.bottom == 0.0
                            ? Expanded(
                                child: SocialMediaButton(
                                  onPressed: () async {
                                    setState(() {
                                      hud = true;
                                    });
                                    loggedInUser =
                                        await AuthService.handleFacebookSignIn(
                                            context);
                                    setState(() {
                                      hud = false;
                                    });
                                    if (loggedInUser != null) {
                                      Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  HomeScreen()));
                                    }
                                  },
                                  circleAvatar: CircleAvatar(
                                    backgroundColor: Color(0xFFF6F6F6),
                                    child: Icon(
                                      FontAwesome.facebook_f,
                                      color: Color(0xFF4267B2),
                                    ),
                                  ),
                                  buttonText: 'Facebook ',
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          MediaQuery.of(context).viewInsets.bottom == 0.0
                              ? Divider(
                                  indent: 50,
                                  endIndent: 50,
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
                      style: TextStyle(color: Colors.black, fontSize: 14.0),
                      keyboardType: TextInputType.emailAddress,
                      decoration: kLoginTextFieldDecoration.copyWith(
                          labelText: 'Email',
                          errorText: ValidationService.validateEmail(email),
                          prefixIcon:
                              Icon(MaterialCommunityIcons.email_outline)),
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                    ),
                    SizedBox(
                      height: 15.0,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: <Widget>[
                        TextField(
                          style: TextStyle(color: Colors.black, fontSize: 14.0),
                          decoration: kLoginTextFieldDecoration.copyWith(
                            labelText: 'Password',
                            errorText:
                                ValidationService.validatePassword(password),
                            prefixIcon: Icon(MaterialCommunityIcons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                showPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey,
                              ),
                              onPressed: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              password = value;
                            });
                          },
                          obscureText: !showPassword,
                        ),
                        FlatButton(
                          child: Text(
                            'Forgot Password ?',
                            style:
                                TextStyle(color: Colors.blue, fontSize: 10.0),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return ForgotPasswordScreen();
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: Builder(
                        builder: (BuildContext context) => SubmitButton(
                          buttonText: 'Login',
                          color: Color(0xFFFFD341),
                          onPressed: (email != null && password != null)
                              ? (ValidationService.validateEmail(email) ==
                                          null &&
                                      ValidationService.validatePassword(
                                              password) ==
                                          null)
                                  ? () async {
                                      setState(() {
                                        hud = true;
                                      });
                                      loggedInUser =
                                          await AuthService.handleEmailSignIn(
                                        context: context,
                                        email: email,
                                        password: password,
                                      );
                                      setState(() {
                                        hud = false;
                                      });
                                      if (loggedInUser != null) {
                                        Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder:
                                                    (BuildContext context) =>
                                                        HomeScreen()));
                                      } else {
                                        Scaffold.of(context)
                                            .showSnackBar(SnackBar(
                                          content: Text("Invalid Credentials"),
                                          duration: Duration(seconds: 2),
                                          elevation: 10,
                                        ));
                                      }
                                    }
                                  : null
                              : null,
                        ),
                      ),
                    ),
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
