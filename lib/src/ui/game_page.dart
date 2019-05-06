import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flt_login/src/common/common.dart';
import 'package:flt_login/src/ui/ai/ai.dart';
import 'package:flt_login/src/ui/shape/circle/circle.dart';
import 'package:flt_login/src/ui/shape/cross/cross.dart';
import 'package:flt_login/src/ui/victory.dart';
import 'package:flt_login/src/ui/victory_checker.dart';
import 'package:flt_login/src/ui/victory_line.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Game extends StatefulWidget {
  final SharedPreferences prefs;
  Game({Key key, this.title, this.type, this.me, this.gameId, this.withId, this.prefs})
      : super(key: key);

  final String title, type, me, gameId, withId;

  @override
  GameState createState() =>
      GameState(type: type, me: me, gameId: gameId, withId: withId);
}

class GameState extends State<Game> {
  BuildContext _context;
  List<List<String>> field = [
    ['', '', ''],
    ['', '', ''],
    ['', '', '']
  ];
  AI ai;
  String playerChar = 'X', aiChar = 'O';
  bool playersTurn = true;
  Victory victory;
  final String type, me, gameId, withId;

  GameState({this.type, this.me, this.gameId, this.withId});

  @override
  void initState() {
    super.initState();
    if (me != null) {
      playersTurn = me == 'X';
      playerChar = me;

      FirebaseDatabase.instance
          .reference()
          .child('games')
          .child(gameId)
          .onChildAdded
          .listen((Event event) {
        String key = event.snapshot.key;
        if (key != 'restart') {
          int row = int.parse(key.substring(0, 1));
          int column = int.parse(key.substring(2, 3));
          if (field[row][column] != me) {
            setState(() {
              field[row][column] = event.snapshot.value;
              playersTurn = true;
              Timer(Duration(milliseconds: 600), () {
                setState(() {
                  checkForVictory();
                });
              });
            });
          }
        } else if (key == 'restart') {
          FirebaseDatabase.instance.reference().child(gameId).set(null);

          setState(() {
            Scaffold.of(_context).hideCurrentSnackBar();
            cleanUp();
          });
        }
      });

      // Haven't figured out how to display a Snackbar during build yet
      new Timer(Duration(milliseconds: 1000), () {
        String text = playersTurn ? 'Your turn' : 'Opponent\'s turn';
        print(text);
        Scaffold.of(_context).showSnackBar(SnackBar(content: Text(text)));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ai = AI(field, playerChar, aiChar);

    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
            actions: <Widget>[
              Container(
                margin: const EdgeInsets.all(15.0),
                padding: const EdgeInsets.all(3.0),
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(5)),
                child: InkWell(
                  onTap: _showDialog,
                  child: Text(
                    'X',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          body: Builder(builder: (BuildContext context) {
            _context = context;
            return Center(
                child: Stack(
                    children: [buildGrid(), buildField(), buildVictoryLine()]));
          })),
    );
  }

  Widget buildGrid() => AspectRatio(
      aspectRatio: 1.0,
      child: Stack(
        children: [
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            buildHorizontalLine,
            buildHorizontalLine,
          ]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            buildVerticalLine,
            buildVerticalLine,
          ])
        ],
      ));

  Container get buildVerticalLine => Container(
      margin: EdgeInsets.only(top: 16.0, bottom: 16.0),
      color: Colors.grey,
      width: 5.0);

  Container get buildHorizontalLine => Container(
      margin: EdgeInsets.only(left: 16.0, right: 16.0),
      color: Colors.grey,
      height: 5.0);

  Widget buildField() => AspectRatio(
      aspectRatio: 1.0,
      child:
          Column(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        Expanded(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              buildCell(0, 0),
              buildCell(0, 1),
              buildCell(0, 2),
            ])),
        Expanded(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              buildCell(1, 0),
              buildCell(1, 1),
              buildCell(1, 2),
            ])),
        Expanded(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
              buildCell(2, 0),
              buildCell(2, 1),
              buildCell(2, 2),
            ]))
      ]));

  Widget buildCell(int row, int column) => AspectRatio(
      aspectRatio: 1.0,
      child: GestureDetector(
          onTap: () {
            if (!gameIsDone() && playersTurn) {
              setState(() {
                displayPlayersTurn(row, column);

                if (!gameIsDone() && type == null) {
                  displayAiTurn();
                }
              });
            }
          },
          child: buildCellItem(row, column)));

  Widget buildCellItem(int row, int column) {
    var cell = field[row][column];
    if (cell.isNotEmpty) {
      if (cell == 'X') {
        return Container(padding: EdgeInsets.all(24.0), child: Cross());
      } else {
        return Container(padding: EdgeInsets.all(24.0), child: Circle());
      }
    } else {
      return null;
    }
  }

  Widget buildVictoryLine() => AspectRatio(
      aspectRatio: 1.0, child: CustomPaint(painter: VictoryLine(victory)));

  void displayPlayersTurn(int row, int column) {
    print('clicked on row $row column $column');
    playersTurn = false;
    field[row][column] = playerChar;

    if (type != null && type == 'wifi') {
      FirebaseDatabase.instance
          .reference()
          .child('games')
          .child(gameId)
          .child('${row}_${column}')
          .set(me);
    }

    Timer(Duration(milliseconds: 600), () {
      setState(() {
        checkForVictory();
      });
    });
  }

  void displayAiTurn() {
    Timer(Duration(milliseconds: 1000), () {
      setState(() {
        // AI turn
        var aiDecision = ai.getDecision();
        field[aiDecision.row][aiDecision.column] = aiChar;
        playersTurn = true;
        Timer(Duration(milliseconds: 600), () {
          setState(() {
            checkForVictory();
          });
        });
      });
    });
  }

  bool gameIsDone() {
    return allCellsAreTaken() || victory != null;
  }

  bool allCellsAreTaken() {
    return field[0][0].isNotEmpty &&
        field[0][1].isNotEmpty &&
        field[0][2].isNotEmpty &&
        field[1][0].isNotEmpty &&
        field[1][1].isNotEmpty &&
        field[1][2].isNotEmpty &&
        field[2][0].isNotEmpty &&
        field[2][1].isNotEmpty &&
        field[2][2].isNotEmpty;
  }

  void checkForVictory() {
    victory = VictoryChecker.checkForVictory(field, playerChar);
    if (victory != null) {
      String message;

      if (victory.winner == PLAYER_WINNER) {
        message = 'You Win!';
      } else if (victory.winner == AI_WINNER) {
        message = type == null ? 'AI Win!' : 'You loose!';
      } else if (victory.winner == DRAFT) {
        message = 'Draft';
      }
      print(message);
      Scaffold.of(_context).showSnackBar(SnackBar(
        content: Text(message),
        duration: Duration(minutes: 1),
        action: SnackBarAction(
            label: 'Retry',
            onPressed: () {
              if (type == null) {
                setState(() {
                  victory = null;
                  field = [
                    ['', '', ''],
                    ['', '', ''],
                    ['', '', '']
                  ];
                  playersTurn = true;
                });
              } else {
                restart();
              }
            }),
      ));
    }
  }

  void restart() async {
    await FirebaseDatabase.instance
        .reference()
        .child('games')
        .child(gameId)
        .set(null);

    await FirebaseDatabase.instance
        .reference()
        .child('games')
        .child(gameId)
        .child('restart')
        .set(true);

    setState(() {
      cleanUp();
    });
  }

  void cleanUp() {
    victory = null;
    field = [
      ['', '', ''],
      ['', '', ''],
      ['', '', '']
    ];
    playersTurn = me == 'X';
    String text = playersTurn ? 'Your turn' : 'Opponent\'s turn';
    print(text);
    Scaffold.of(_context).showSnackBar(SnackBar(content: Text(text)));
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Text('Do you want to quit the game ?'),
            actions: <Widget>[
              FlatButton(
                child: Text('Close'),
                onPressed: () {
                  Navigator.of(context).pop(CANCEL);
                },
              ),
              FlatButton(
                child: Text('Yes'),
                onPressed: () {
                  Navigator.pushNamed(context, MYPAGE);
                },
              )
            ],
          );
        });
  }
}