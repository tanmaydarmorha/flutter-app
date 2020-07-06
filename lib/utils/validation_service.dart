import 'package:fluvidmobile/modals/user.dart';

import 'networking.dart';

class ValidationService {
  static String validateEmail(String value) {
    String pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = new RegExp(pattern);
    if (value == null) {
      return null;
    } else if (value.isEmpty) {
      return "Email is Required";
    } else if (!regExp.hasMatch(value)) {
      return "Invalid Email";
    } else {
      return null;
    }
  }

  static String validateTag(String value) {
    RegExp regExp = new RegExp('[,]+');
    if (value == null || value.isEmpty) {
      return null;
    } else if (regExp.hasMatch(value)) {
      return 'Tag cannot contain commas';
    } else {
      return null;
    }
  }

  static String validatePassword(String value) {
    if (value == null) {
      return null;
    } else if (value.length == 0) {
      return 'Password cannot be empty';
    }
    return null;
  }

  static String validateFolderName(String value) {
    if (value == null) {
      return null;
    } else if (value.length == 0) {
      return 'Name cannot be empty';
    } else if (value.length > 150) {
      return 'Name cannot exceed 150 characters';
    }
    return null;
  }

  static Future<User> validateToken({token}) async {
    NetworkHelper networkHelper =
        NetworkHelper(url: 'https://api.fluvid.com/api/v1/auth/verifyToken');

    var response = await networkHelper.getData(token: token);

    if (response['status'] == 1) {
      return User(
        firstName: response['data']['userInfo']['first_name'],
        lastName: response['data']['userInfo']['last_name'],
        email: response['data']['userInfo']['email'],
        photoUrl: response['data']['userInfo']['profile_pic'],
      );
    }
    return null;
  }
}
