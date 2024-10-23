import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MarioGame());
}

class MarioGame extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mario Game',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.pressStart2pTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: GameScreen(),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Posição do Mario
  static double marioX = 0;
  static double marioY = 1; // O Mario começa no chão
  double initialMarioY = marioY;
  bool gameStarted = false;
  double time = 0;
  double height = 0;
  double gravity = -4.9;
  double velocity = 3.5;
  double pipeX = 1;
  double turtleX = 2;
  double bulletX = 3;
  int score = 0;
  static const double groundY = 1; // O chão fica na posição Y = 1

  void jump() {
    // O Mario só pode pular se estiver no chão
    if (marioY == groundY) {
      setState(() {
        time = 0;
        initialMarioY = marioY;
      });
    }
  }

  void moveRight() {
    setState(() {
      if (marioX < 1) {
        marioX += 0.05;
      }
    });
  }

  void moveLeft() {
    setState(() {
      if (marioX > -1) {
        marioX -= 0.05;
      }
    });
  }

  void startGame() {
    gameStarted = true;
    Timer.periodic(Duration(milliseconds: 50), (timer) {
      time += 0.05;
      height = gravity * time * time + velocity * time;

      setState(() {
        marioY = initialMarioY - height;

        // O Mario não pode cair abaixo do chão
        if (marioY > groundY) {
          marioY = groundY;
        }

        // Movimentação dos obstáculos
        pipeX -= 0.05;
        turtleX -= 0.05;
        bulletX -= 0.05;

        // Verifica se Mario passou pelos obstáculos e conta ponto
        if (pipeX < -1) {
          pipeX += 3;
          score++;
        }
        if (turtleX < -1) {
          turtleX += 3;
          score++;
        }
        if (bulletX < -1) {
          bulletX += 3;
          score++;
        }

        // Verificar colisão entre Mario e obstáculos
        if ((pipeX - marioX).abs() < 0.1 && marioY >= groundY ||
            (turtleX - marioX).abs() < 0.1 && marioY >= groundY ||
            (bulletX - marioX).abs() < 0.1 && marioY >= groundY) {
          timer.cancel();
          gameStarted = false;
          _showGameOverDialog();
        }

        // Condição de game over: Se Mario cair muito abaixo do chão
        if (marioY > 1.5) {
          timer.cancel();
          gameStarted = false;
          _showGameOverDialog();
        }
      });
    });
  }

  void _showGameOverDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("Your score: $score"),
          actions: <Widget>[
            TextButton(
              child: Text("Play Again"),
              onPressed: () {
                Navigator.of(context).pop();
                resetGame();
              },
            ),
          ],
        );
      },
    );
  }

  void resetGame() {
    setState(() {
      marioY = groundY;
      pipeX = 1;
      turtleX = 2;
      bulletX = 3;
      marioX = 0;
      gameStarted = false;
      time = 0;
      score = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: gameStarted ? jump : startGame,
      child: Scaffold(
        body: Column(
          children: <Widget>[
            Expanded(
              flex: 2,
              child: Stack(
                children: <Widget>[
                  AnimatedContainer(
                    alignment: Alignment(marioX, marioY),
                    duration: Duration(milliseconds: 0),
                    color: Colors.blue,
                    child: MarioCharacter(),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(pipeX, 1),
                    duration: Duration(milliseconds: 0),
                    child: Pipe(),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(turtleX, 1),
                    duration: Duration(milliseconds: 0),
                    child: Turtle(),
                  ),
                  AnimatedContainer(
                    alignment: Alignment(bulletX, 1),
                    duration: Duration(milliseconds: 0),
                    child: Bullet(),
                  ),
                  Container(
                    alignment: Alignment(0, -0.3),
                    child: gameStarted
                        ? Text("")
                        : Text(
                            "TAP TO PLAY",
                            style: TextStyle(fontSize: 20, color: Colors.white),
                          ),
                  ),
                  ScoreBoard(score: score),
                ],
              ),
            ),
            Container(
              height: 50, // Define a altura do chão aqui
              color: Colors.green,
            ),
          ],
        ),
      ),
    );
  }
}

class MarioCharacter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      child: Image.asset('assets/mario.gif'),
    );
  }
}

class Pipe extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 60,
      child: Image.asset('assets/pipe.png'), // Imagem do cano
    );
  }
}

class Turtle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      width: 60,
      child: Image.asset('assets/turtle.gif'), // Imagem da tartaruga
    );
  }
}

class Bullet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 40,
      child: Image.asset('assets/bullet.png'), // Imagem da bala
    );
  }
}

class ScoreBoard extends StatelessWidget {
  final int score;

  const ScoreBoard({required this.score});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(0, -0.9),
      child: Container(
        padding: EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(width: 2, color: Colors.black),
        ),
        child: Text(
          'Score: $score',
          style: TextStyle(fontSize: 20, fontFamily: 'monospace'),
        ),
      ),
    );
  }
}
