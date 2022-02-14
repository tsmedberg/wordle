import 'web.dart';
import 'package:flutter/material.dart';

class Wordle {
  Web web;
  String word = "";
  List<String> guesses = List.empty(growable: true);

  Wordle({required this.web});
  void _guess(String guessWord) {
    guesses.add(guessWord);
  }

  Widget widget() {
    return WordleWidget();
  }
}

class WordleWidget extends StatefulWidget {
  @override
  _WordleWidgetState createState() => _WordleWidgetState();
}

class _WordleWidgetState extends State<WordleWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: const Text("hello wodl"),
    );
  }
}
