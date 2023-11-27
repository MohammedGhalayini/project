import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import the SystemChrome class

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hangman Game',
      home: HangmanGame(),
    );
  }
}

class HangmanGame extends StatefulWidget {
  @override
  _HangmanGameState createState() => _HangmanGameState();
}

enum DifficultyLevel { Easy, Medium, Hard }

class _HangmanGameState extends State<HangmanGame> {
  Map<DifficultyLevel, List<String>> difficultyLevels = {
    DifficultyLevel.Easy: ["CAT", "DOG", "SUN", "MILK", "FISH"],
    DifficultyLevel.Medium: ["PYTHON", "JAVASCRIPT", "FLUTTER", "DART", "ANDROID"],
    DifficultyLevel.Hard: ["FOOTBALL", "BASEBALL", "PHILOSOPHY", "QUADRATIC", "ZOMBIE"],
  };

  DifficultyLevel currentDifficulty = DifficultyLevel.Medium;

  List<String> get currentWordList => difficultyLevels[currentDifficulty]!;
  String selectedWord = "";
  Set<String> guessedLetters = Set<String>();
  int attemptsLeft = 6;
  int score = 0;
  bool isGameActive = true;
  List<String> hangmanStages = [
    "Head",
    "Body",
    "Left Arm",
    "Right Arm",
    "Left Leg",
    "Right Leg",
  ];
  int currentHangmanStage = 0;
  late Timer timer;
  int secondsRemaining = 60;

  Color getThemeColor() {
    switch (currentDifficulty) {
      case DifficultyLevel.Easy:
        return Colors.blue;
      case DifficultyLevel.Medium:
        return Colors.yellow;
      case DifficultyLevel.Hard:
        return Colors.red;
    }
  }

  @override
  void initState() {
    super.initState();
    startGame();
    startTimer();
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        if (secondsRemaining > 0 && isGameActive) {
          secondsRemaining--;
        } else {
          timer.cancel();
          if (isGameActive) {
            isGameActive = false;
            showTimeoutDialog();
          }
        }
      });
    });
  }

  void showTimeoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Time's up!"),
          content: Text("You ran out of time. The word was $selectedWord."),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
                startTimer();
              },
              child: Text('New Game'),
              style: ElevatedButton.styleFrom(
                primary: getThemeColor(),
              ),
            ),
          ],
        );
      },
    );
  }

  void startGame() {
    setState(() {
      guessedLetters.clear();
      attemptsLeft = 6;
      selectedWord = currentWordList[Random().nextInt(currentWordList.length)];
      isGameActive = true;
      currentHangmanStage = 0;
      secondsRemaining = 30;

      switch (currentDifficulty) {
        case DifficultyLevel.Easy:
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.blue,
            systemNavigationBarColor: Colors.blue,
          ));
          break;
        case DifficultyLevel.Medium:
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.yellow,
            systemNavigationBarColor: Colors.yellow,
          ));
          break;
        case DifficultyLevel.Hard:
          SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
            statusBarColor: Colors.red,
            systemNavigationBarColor: Colors.red,
          ));
          break;
      }
    });
  }

  bool isGameWon() {
    return selectedWord.split('').toSet().difference(guessedLetters).isEmpty;
  }

  bool isGameLost() {
    return attemptsLeft == 0;
  }

  void makeGuess(String letter) {
    setState(() {
      if (!guessedLetters.contains(letter) && isGameActive) {
        guessedLetters.add(letter);
        if (!selectedWord.contains(letter)) {
          attemptsLeft--;
          currentHangmanStage++;
        }
      }
      if (isGameWon() || isGameLost()) {
        isGameActive = false;
        timer.cancel();
      }
    });
  }

  void handleGameEnd() {
    if (isGameWon()) {
      setState(() {
        score++;
      });
      showWinDialog();
    }
  }

  void showWinDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You won! Your score: $score'),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                startGame();
                startTimer();
              },
              child: Text('New Game'),
              style: ElevatedButton.styleFrom(
                primary: getThemeColor(),
              ),
            ),
          ],
        );
      },
    );
  }

  ElevatedButton buildNewGameButton() {
    return ElevatedButton(
      onPressed: () {
        startGame();
        startTimer();
      },
      child: Text('New Game'),
      style: ElevatedButton.styleFrom(
        primary: getThemeColor(),
      ),
    );
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hangman Game'),
        backgroundColor: getThemeColor(),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            DropdownButton<DifficultyLevel>(
              value: currentDifficulty,
              items: DifficultyLevel.values
                  .map((level) => DropdownMenuItem(
                value: level,
                child: Text(level.toString().split('.').last),
              ))
                  .toList(),
              onChanged: (DifficultyLevel? value) {
                setState(() {
                  currentDifficulty = value!;
                  startGame();
                  startTimer();
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Time left: $secondsRemaining seconds',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Text(
              'Attempts left: $attemptsLeft',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            if (isGameLost())
              Text(
                'You lost! The word was $selectedWord.',
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            if (isGameWon())
              Text(
                'Congratulations! You won!',
                style: TextStyle(fontSize: 20, color: Colors.green),
              ),
            if (isGameActive)
              Column(
                children: [
                  Text(
                    buildWordWithGuesses(),
                    style: TextStyle(fontSize: 30),
                  ),
                  SizedBox(height: 20),
                  GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 8.0,
                      crossAxisSpacing: 8.0,
                    ),
                    shrinkWrap: true,
                    itemCount: 26,
                    itemBuilder: (context, index) {
                      final letter = String.fromCharCode('A'.codeUnitAt(0) + index);
                      return ElevatedButton(
                        onPressed: () {
                          makeGuess(letter);
                          handleGameEnd();
                        },
                        child: Text(letter),
                        style: ElevatedButton.styleFrom(
                          primary: getThemeColor(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            SizedBox(height: 20),
            if (isGameLost())
              Text(
                'Hangman Stage: ${hangmanStages[currentHangmanStage]}',
                style: TextStyle(fontSize: 20, color: Colors.red),
              ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Score: $score',
                  style: TextStyle(fontSize: 20),
                ),
                buildNewGameButton(),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String buildWordWithGuesses() {
    return selectedWord.split('').map((letter) {
      return guessedLetters.contains(letter) ? letter : '_';
    }).join(' ');
  }
}
