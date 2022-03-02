import 'web.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'words.dart';

const qwerty = ["qwertyuiop", "asdfghjkl", "zxcvbnm"];

class Wordle {
  Web web;
  String word = "water";
  List<String> guesses = List.empty(growable: true);

  Wordle({required this.web});
  bool guess(String guessWord) {
    if (Words.words.contains(guessWord)) {
      guesses.add(guessWord);
      return true;
    }
    return false;
  }

  Widget widget() {
    return WordleWidget(this);
  }

  WordleState state(x, string) {
    String letter = (string.length > x ? string[x] : "");
    if (this.word[x] == letter) {
      return WordleState.correct;
    } else if (word.contains(letter)) {
      return WordleState.incorrect;
    } else {
      return WordleState.excluded;
    }
  }

  static MaterialColor stateColor(WordleState state) {
    switch (state) {
      case WordleState.correct:
        return Colors.green;
      case WordleState.incorrect:
        return Colors.yellow;
      case WordleState.excluded:
        return Colors.grey;
    }
  }

  static Container letter(x, y, Wordle wordle, String currentGuess) {
    List<String> guesses = [...wordle.guesses];
    if (currentGuess != '') guesses.add(currentGuess);
    bool isGuessed = y < wordle.guesses.length;
    String letter =
        y < guesses.length ? (guesses[y].length > x ? guesses[y][x] : "") : "";
    Color color = Colors.grey.shade100;
    if (wordle.guesses.length > y) {
      color = Wordle.stateColor(wordle.state(x, guesses[y]));
    }
    return Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black,
            width: 1,
          ),
          color: color,
        ),
        child: Center(
          child: Text(letter),
        ));
  }
}

enum WordleState { correct, incorrect, excluded }

class WordleWidget extends StatefulWidget {
  Wordle wordle;
  WordleWidget(this.wordle);
  @override
  _WordleWidgetState createState() => _WordleWidgetState();
}

class _WordleWidgetState extends State<WordleWidget> {
  String currentGuess = "";
  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text("answer: " + widget.wordle.word),
      Text("guesses: " + widget.wordle.guesses.join(", ")),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int y = 0; y < 6; y++)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (int x = 0; x < 5; x++)
                  Wordle.letter(x, y, widget.wordle, currentGuess)
              ],
            ),
        ],
      ),
      Column(children: [
        for (String row in qwerty)
          Row(
            children: [
              for (String letter in row.characters)
                TextButton(
                  onPressed: () => {
                    setState(() {
                      currentGuess += letter;
                    })
                  },
                  child: Text(letter),
                )
            ],
            mainAxisSize: MainAxisSize.min,
          ),
        ElevatedButton(
            onPressed: currentGuess.length != 5
                ? null
                : () {
                    setState(() {
                      widget.wordle.guess(currentGuess);
                      currentGuess = "";
                    });
                  },
            child: const Text("guess"))
      ]),
    ]);
  }
}
