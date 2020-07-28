import 'package:flutter/material.dart';

import 'modals/user.dart';

const kLoginTextFieldDecoration = InputDecoration(
  isDense: true,
  labelText: 'Enter custom text',
  labelStyle: TextStyle(color: Colors.black),
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0x998397D2), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF8397D2), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(32.0)),
  ),
);

const kCommentTextFieldDecoration = InputDecoration(
  border: OutlineInputBorder(
    borderRadius: BorderRadius.all(Radius.circular(0.0)),
  ),
  enabledBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0x995C5C86), width: 1.0),
    borderRadius: BorderRadius.all(Radius.circular(0.0)),
  ),
  focusedBorder: OutlineInputBorder(
    borderSide: BorderSide(color: Color(0xFF5C5C86), width: 2.0),
    borderRadius: BorderRadius.all(Radius.circular(0.0)),
  ),
);

User loggedInUser;

String currentUserToken;

const kPrivacyOptionsTextFieldDecoration = InputDecoration(
  labelText: 'Custom Text',
  labelStyle: TextStyle(color: Color(0xFF39447A)),
  isDense: true,
  filled: true,
);

// not a constant but used to start HUD
bool videoPageHud = false;

// variable used to check if video is deleted or removed
bool removeVideo = false;
