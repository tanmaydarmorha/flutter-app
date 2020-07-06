import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_icons/flutter_icons.dart';
import 'package:fluvidmobile/utils/update_service.dart';
import 'package:fluvidmobile/utils/validation_service.dart';
import 'package:fluvidmobile/widgets/background_design.dart';
import 'package:fluvidmobile/widgets/submit_button.dart';

import '../constants.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  String email;
  final _emailController = TextEditingController();
  String snackBarMessage;

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
      appBar: AppBar(
        elevation: 2,
        title: Image.asset(
          'images/fluvid-logo-text.png',
          scale: 3,
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Background(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 24.0, top: 24.0),
                  child: AutoSizeText(
                    'WELCOME',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                      color: Color(0xFFF3D032),
                      fontWeight: FontWeight.w600,
                      fontSize: 28,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 24.0),
                  child: AutoSizeText(
                    'Be Connected!',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontSize: 35,
                        height: 1,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF39447A)),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24.0, vertical: 16.0),
                  child: TextField(
                    controller: _emailController,
                    style: TextStyle(color: Colors.black, fontSize: 14.0),
                    keyboardType: TextInputType.emailAddress,
                    decoration: kLoginTextFieldDecoration.copyWith(
                      labelText: 'Email',
                      prefixIcon: Icon(
                        MaterialCommunityIcons.email_outline,
                      ),
                      errorText: ValidationService.validateEmail(email),
                    ),
                    onChanged: (value) {
                      setState(() {
                        email = value;
                      });
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      vertical: 12.0, horizontal: 24.0),
                  child: SubmitButton(
                    buttonText: 'Submit',
                    color: Color(0xFFFFD341),
                    onPressed: (email == null ||
                            ValidationService.validateEmail(email) != null)
                        ? null
                        : () async {
                            _emailController.clear();
                            if (await UpdateService.resetPassword(
                                email: email)) {
                              snackBarMessage = 'Mail sent, check your inbox ';
                            } else {
                              snackBarMessage = 'Email not found.';
                            }
                            _scaffoldKey.currentState.showSnackBar(
                              SnackBar(
                                content: Text(snackBarMessage),
                                duration: Duration(milliseconds: 1500),
                              ),
                            );
                          },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
