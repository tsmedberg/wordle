import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'web.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'words.dart';

const qwerty = ["qwertyuiop", "asdfghjkl", "zxcvbnm"];

class Wordle {
  String word = Words.getWord();
  String? username;
  bool solved = false;
  DateTime solvedTime = DateTime(0);
  List<String> guesses = List.empty(growable: true);
  List<String> correctLetters = List.empty(growable: true);
  List<String> incorrectLetters = List.empty(growable: true);
  List<String> excludedLetters = List.empty(growable: true);

  Wordle() {
    init();
  }
  bool guess(String guessWord) {
    if (Words.canGuess(guessWord) && canGuessToday()) {
      guesses.add(guessWord);
      //calculate correct letters
      for (String row in qwerty) {
        for (String letter in row.characters) {
          if (guessWord.contains(letter) &&
              word.indexOf(letter) == guessWord.indexOf(letter)) {
            correctLetters.add(letter);
          } else if (guessWord.contains(letter) &&
              word.contains(letter) &&
              !correctLetters.contains(letter)) {
            incorrectLetters.add(letter);
          } else if (guessWord.contains(letter)) {
            excludedLetters.add(letter);
          }
        }
      }
      if (guessWord == word) {
        //solved wordle
        setSolveTime();
        solved = true;
        if (username != null) {
          Web.setScore(username!, guesses.length);
        }
      } else if (guesses.length == 6) {
        setSolveTime();
      }
      return true;
    }
    return false;
  }

  void setSolveTime() async {
    solvedTime = DateTime.now();
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('solvedtime', DateTime.now().millisecondsSinceEpoch);
  }

  void init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('solvedtime')) {
      solvedTime =
          DateTime.fromMillisecondsSinceEpoch(prefs.getInt('solvedtime') ?? 0);
    }
  }

  bool canGuessToday() {
    DateTime now = DateTime.now();
    return solvedTime.isBefore(DateTime(now.year, now.month, now.day));
  }

  Widget widget() {
    return WordleWidget(this);
  }

  WordleState state(x, string) {
    String letter = (string.length > x ? string[x] : "");
    if (word[x] == letter) {
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
        return Colors.amber;
      case WordleState.excluded:
        return Colors.grey;
    }
  }

  MaterialColor keyColor(String letter) {
    if (correctLetters.contains(letter)) {
      return Colors.green;
    } else if (incorrectLetters.contains(letter)) {
      return Colors.amber;
    } else if (excludedLetters.contains(letter)) {
      return Colors.blueGrey;
    } else {
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
          child: Text(
            letter.toUpperCase(),
            style: GoogleFonts.roboto(fontSize: 20, color: Colors.black),
          ),
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
    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (RawKeyEvent e) {
        if (e.repeat) return;
        if (e.runtimeType != RawKeyDownEvent) return;
        if (e.logicalKey == LogicalKeyboardKey.enter) {
          setState(() {
            widget.wordle.guess(currentGuess);
            currentGuess = "";
          });
        } else if (e.logicalKey == LogicalKeyboardKey.backspace) {
          setState(() {
            currentGuess = currentGuess.substring(0, currentGuess.length - 1);
          });
        } else if (e.character != null &&
            e.character != "" &&
            currentGuess.length < 5) {
          setState(() {
            currentGuess += e.character!;
          });
        }
      },
      child: Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
        if (widget.wordle.solved)
          const Text(
            'You solved it! 💯',
            style: TextStyle(fontSize: 20),
          ),
        if (widget.wordle.guesses.length == 6 || widget.wordle.solved)
          Text("correct answer: " + widget.wordle.word),
        /* Text("guesses: " + widget.wordle.guesses.join(", ")), */

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
        if (!widget.wordle.canGuessToday())
          Row(mainAxisSize: MainAxisSize.min, children: const [
            Icon(Icons.info_outline),
            Text("You can't guess anymore today!"),
          ]),
        //keyboard
        if (!widget.wordle.solved)
          Column(children: [
            for (String row in qwerty)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (qwerty.indexOf(row) == 2)
                    ElevatedButton(
                        onPressed: (currentGuess.length != 5 ||
                                !widget.wordle.canGuessToday())
                            ? null
                            : () {
                                setState(() {
                                  widget.wordle.guess(currentGuess);
                                  currentGuess = "";
                                });
                              },
                        child: const Icon(Icons.check)),
                  for (String letter in row.characters)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: widget.wordle.keyColor(letter),
                        onPrimary: Colors.white,
                      ),
                      onPressed: () => {
                        if (currentGuess.length < 5)
                          {
                            setState(() {
                              currentGuess += letter;
                            })
                          }
                      },
                      child: Text(letter.toUpperCase()),
                    ),
                  if (qwerty.indexOf(row) == 2)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        primary: Colors.grey,
                        onPrimary: Colors.white,
                      ),
                      onPressed: currentGuess.isEmpty
                          ? null
                          : () => {
                                if (currentGuess.isNotEmpty)
                                  {
                                    setState(() {
                                      currentGuess = currentGuess.substring(
                                          0, currentGuess.length - 1);
                                    })
                                  }
                              },
                      child: const Icon(Icons.backspace),
                    )
                ].map((e) => Expanded(child: e)).toList(),
              ),
          ]),
      ]),
    );
  }
}
