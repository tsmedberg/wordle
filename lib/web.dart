import 'dart:convert';

import 'package:http/http.dart' as http;

class Web {
  //String username = "";
  static String baseUrl = "https://api.wordle.t0rre.dev/api/";
  //Web({required this.username});

  static Future<bool> validateUsername(String username) {
    return http
        .post(Uri.parse(baseUrl + 'validateusername'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{'username': username}))
        .then((response) {
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    });
  }

  static Future<bool> createUser(String username) {
    return http
        .post(Uri.parse(baseUrl + 'createuser'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, String>{'username': username}))
        .then((response) {
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    });
  }

  static Future<bool> setScore(String username, int guessCount) {
    return http
        .post(Uri.parse(baseUrl + 'score'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'username': username,
              'guessCount': guessCount
            }))
        .then((response) {
      if (response.statusCode == 200) {
        return true;
      } else {
        return false;
      }
    });
  }

  static Future<Map<String, dynamic>> getScore() {
    return http.get(Uri.parse(baseUrl + 'score')).then((response) {
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Could not get score');
      }
    });
  }
}
