import 'dart:convert';

import 'package:flutter/material.dart';
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

  static Future<Score> getScore(String username) {
    return http
        .post(Uri.parse(baseUrl + 'getscore'),
            headers: <String, String>{
              'Content-Type': 'application/json; charset=UTF-8',
            },
            body: jsonEncode(<String, dynamic>{
              'username': username,
            }))
        .then((response) {
      if (response.statusCode == 200) {
        return Score.fromJson(json.decode(response.body));
      } else {
        throw Exception('Could not get score');
      }
    });
  }

  static Future<Widget> getScoreWidget(String username) {
    return getScore(username).then((score) {
      return ScoreWidget(score: score);
    });
  }
}

// score widget

class ScoreWidget extends StatelessWidget {
  const ScoreWidget({
    Key? key,
    required this.score,
  }) : super(key: key);
  final Score score;
  @override
  Widget build(BuildContext context) {
    int largestScore = score.score.values.reduce((a, b) => a > b ? a : b);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Score'),
        Text(score.username),
        for (MapEntry e in score.score.entries)
          Row(
            children: [
              Text(e.key.toString()),
              if (e.value > 0)
                Expanded(
                  /*  width: 300, */
                  child: FractionallySizedBox(
                    widthFactor: e.value / largestScore,
                    child: Container(
                      color: Colors.green,
                      child:
                          Text(e.value.toString(), textAlign: TextAlign.right),
                    ),
                  ),
                )
              else
                Text(',' + e.value.toString())
            ],
          )
      ],
    );
  }
}

class Score {
  String username;
  Map<int, int> score = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0};
  Score({required this.username, required this.score});

  factory Score.fromJson(Map<String, dynamic> json) {
    if (json['score'] == null) {
      return Score(
          username: json['username'] ?? '<null>',
          score: {1: 0, 2: 0, 3: 0, 4: 0, 5: 0, 6: 0});
    }
    return Score(
      username: json['username'] ?? '<null>',
      score: {
        1: json['score']['1'] ?? 0,
        2: json['score']['2'] ?? 0,
        3: json['score']['3'] ?? 0,
        4: json['score']['4'] ?? 0,
        5: json['score']['5'] ?? 0,
        6: json['score']['6'] ?? 0,
      },
    );
  }
}
