import 'dart:convert';

import 'package:http/http.dart' as http;

class NetworkHelper {
  final String url;

  NetworkHelper({this.url});

  Future getData({token}) async {
    http.Response response = await http.get(
      url,
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (response.statusCode == 200) {
      String data = response.body;

      return jsonDecode(data);
    } else {
      print('Error fetching details with error code ${response.statusCode}');
    }
  }

  Future postData({header, body}) async {
    http.Response response;
    if (header == null && body == null) {
      response = await http.post(url);
    } else if (header != null && body == null) {
      response = await http.post(
        url,
        headers: header,
      );
    } else if (header == null && body != null) {
      response = await http.post(
        url,
        body: body,
      );
    } else {
      response = await http.post(
        url,
        headers: header,
        body: body,
      );
    }

    if (response.statusCode == 200) {
      String data = response.body;

      return jsonDecode(data);
    } else {
      print('Error fetching details with error code ${response.statusCode}');
    }
  }

  Future putData({header, body}) async {
    http.Response response;
    if (header == null && body == null) {
      response = await http.put(
        url,
      );
    } else if (header != null && body == null) {
      response = await http.put(
        url,
        headers: header,
      );
    } else if (header == null && body != null) {
      response = await http.put(
        url,
        body: body,
      );
    } else {
      response = await http.put(
        url,
        headers: header,
        body: body,
      );
    }

    if (response.statusCode == 200) {
      String data = response.body;

      return jsonDecode(data);
    } else {
      print('Error fetching details with error code ${response.statusCode}');
    }
  }

  Future deleteData({header}) async {
    http.Response response;
    if (header == null) {
      response = await http.delete(
        url,
      );
    } else {
      response = await http.delete(
        url,
        headers: header,
      );
    }

    if (response.statusCode == 200) {
      String data = response.body;

      return jsonDecode(data);
    } else {
      print('Error fetching details with error code ${response.statusCode}');
    }
  }
}
