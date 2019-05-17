import 'dart:async';
import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flt_login/src/common/common.dart';
import 'package:flt_login/src/models/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_reactive_button/flutter_reactive_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/game_enums.dart';
import 'cell.dart';
import 'game_dialog.dart';
import 'game_item.dart';

class Game extends StatefulWidget {
  FirebaseUser firebaseUser;
  User player1;
  GameMode gameMode;

  User player2;

  Game(this.gameMode, this.player1, this.player2);

  @override
  _GameState createState() => _GameState();
}

class _GameState extends State<Game> {
  List<GameItem> itemlist;
  List<int> player1List;
  List<int> player2List;
  var activePlayer;

  List<ReactiveIconDefinition> _icons = <ReactiveIconDefinition>[
    ReactiveIconDefinition(
      assetIcon: 'assets/images/mess.gif',
      code: 'mess',
    ),
  ];

  @override
  void initState() {
    super.initState();
    itemlist = doInit();
    doFristTurn();
  }

  List<GameItem> doInit() {
    player1List = new List();
    player2List = new List();
    activePlayer = 1;
    List<GameItem> gameItems = new List();
    for (var i = 0; i < SUM; i++) {
      gameItems.add(new GameItem(id: i));
    }

    return gameItems;
  }

  GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _icon;

  @override
  Widget build(BuildContext context) {
    Widget playerInfo() => Container(
        color: Colors.orange,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildPlayer(widget.player1),
            _buildText('VS'),
            _buildPlayer(widget.player2),
          ],
        ));

    return new Scaffold(
      key: _scaffoldKey,
      body: Container(
        decoration: BoxDecoration(color: Colors.white),
        alignment: AlignmentDirectional.bottomEnd,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
//          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
//            Container(
//              child: SizedBox(
//                height: 20.0,
//              ),
//            ),
            Container(
              child: playerInfo(),
            ),
            Expanded(
              child: new GridView.builder(
                  gridDelegate: new SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: COLUMNS,
                      crossAxisSpacing: 0.5,
                      mainAxisSpacing: 0.5),
                  itemCount: itemlist.length,
                  itemBuilder: (context, i) => new SizedBox(
                        width: 20.0,
                        height: 20.0,
                        child: new RaisedButton(
                          padding: const EdgeInsets.all(1.0),
                          onPressed: itemlist[i].enabled
                              ? () => playGame(itemlist[i], i)
                              : null,
                          child: itemlist[i],
//                          child: Text('$i'),
                          color: itemlist[i].bg,
                          disabledColor: itemlist[i].bg,
                        ),
                      )),
            ),
          ],
        ),
      ),
//      bottomNavigationBar: Container(
////        color: Colors.orange,
//        child: BottomNavigationBar(
//            backgroundColor: Colors.deepOrangeAccent,
//            items: [
//              BottomNavigationBarItem(
//                icon: ReactiveButton(
//                  child: Container(
////                    decoration: BoxDecoration(
////                        border: Border.all(color: Colors.black, width: 1.0)),
//                    color: Colors.white,
//                    width: 60.0,
//                    height: 40.0,
//                    child: Center(
//                      child: Image.asset('assets/images/emotion.png'),
//                    ),
//                  ),
//                  containerAbove: false,
//                  iconWidth: 32.0,
//                  iconGrowRatio: 1.5,
//                  roundIcons: false,
//                  icons: _icons,
//                  onTap: () => print('on tap'),
//                  onSelected: (ReactiveIconDefinition button) {
//                    setState(() {
//                      _icon = button.code;
//                    });
//                  },
//                ),
//                title: Text(''),
//              ),
//              BottomNavigationBarItem(
//                icon: GestureDetector(
//                  onTap: _backToMain,
//                  child: Image.asset(
//                    SURRENDER_FLAG,
//                    width: 50,
//                    height: 50,
//                    fit: BoxFit.cover,
//                  ),
//                ),
//                title: Text('surrender'),
//              )
//            ]),
//      ),
    );
  }

  Widget buildCell(BuildContext context, int i, activePlayer) {
    return Cell(context, i, activePlayer, null);
  }

  void resetGame() {
    if (Navigator.canPop(context)) Navigator.pop(context);
    setState(() {
      itemlist = doInit();
    });
    doFristTurn();
  }

  void playGame(GameItem item, int cellNumber) {
    print('User click: $activePlayer . Cell number: $cellNumber');

    setState(() {
      var imageUrl = 'assets/images/p$activePlayer.png';
      var newGameItem = [
        GameItem(
          id: cellNumber,
          image: Image.asset(imageUrl),
          enabled: false,
        )
      ];

      if (activePlayer == 1) {
        itemlist.replaceRange(cellNumber, cellNumber + 1, newGameItem);
        activePlayer = 2;
        player1List.add(cellNumber);
      } else {
        itemlist.replaceRange(cellNumber, cellNumber + 1, newGameItem);
        activePlayer = 1;
        player2List.add(cellNumber);
      }
      int winner;
      if (player1List.length > 4 || player2List.length > 4) {
        winner = checkWinner(cellNumber);
      }
      if (winner == 0) {
        if (itemlist.every((p) => p.text != "")) {
          showDialog(
              context: context,
              builder: (_) =>
                  new GameDialog('Game title', 'Reset game', resetGame));
        }
      } else {
        activePlayer == 2 ? autoPlay(cellNumber) : null;
      }
    });
  }

  int checkWinner(id) {
    int winner;
    player1List.sort((i1, i2) => i1 - i2);
    player2List.sort((i1, i2) => i1 - i2);
    //check user 1 win
    if (activePlayer == 2) {
      winner = doReferee(player1List, 1, id);
    } else {
      //check user 2 win
      winner = doReferee(player2List, 2, id);
    }

    if (winner != null) {
      if (winner == 1) {
        showDialog(
            context: context,
            builder: (_) => new GameDialog("Player 1 Won",
                "Press the reset button to start again.", resetGame));
      } else {
        showDialog(
            context: context,
            builder: (_) => new GameDialog("Player 2 Won",
                "Press the reset button to start again.", resetGame));
      }
    }

    return winner;
  }

  void autoPlay(int cellNumber) {
    var rowBefore = cellNumber - COLUMNS;
    var rowAfter = cellNumber + COLUMNS;
    List aroundCell = [];
    var multiColRow = COLUMNS * ROWS;
    if (cellNumber == 0) {
      aroundCell.add(1);
      aroundCell.add(COLUMNS);
      aroundCell.add(COLUMNS + 1);
    } else if (cellNumber == COLUMNS - 1) {
      aroundCell.add(COLUMNS - 2);
      aroundCell.add(COLUMNS * 2);
      aroundCell.add(COLUMNS * 2 - 1);
    } else if (cellNumber == multiColRow - COLUMNS) {
      aroundCell.add(multiColRow - COLUMNS);
      aroundCell.add(multiColRow + 1);
      aroundCell.add(multiColRow - COLUMNS + 1);
    } else if (cellNumber == multiColRow - 1) {
      aroundCell.add(multiColRow - COLUMNS);
      aroundCell.add(multiColRow - 1);
      aroundCell.add(multiColRow - 1);
    } else if (cellNumber % 12 == 0) {
      aroundCell.add(rowBefore);
      aroundCell.add(rowBefore + 1);
      aroundCell.add(cellNumber + 1);
      aroundCell.add(rowAfter);
      aroundCell.add(rowAfter + 1);
    } else if (cellNumber % 12 == 0) {
      aroundCell.add(rowBefore);
      aroundCell.add(rowBefore + 1);
      aroundCell.add(cellNumber + 1);
      aroundCell.add(rowAfter);
      aroundCell.add(rowAfter + 1);
    } else if (0 < cellNumber && cellNumber < COLUMNS - 1) {
      aroundCell.add(cellNumber - 1);
      aroundCell.add(cellNumber + 1);
      aroundCell.add(rowAfter);
      aroundCell.add(rowAfter - 1);
      aroundCell.add(rowAfter + 1);
    } else if (multiColRow - COLUMNS < cellNumber &&
        cellNumber < multiColRow - 1) {
      aroundCell.add(cellNumber - 1);
      aroundCell.add(cellNumber + 1);
      aroundCell.add(rowBefore);
      aroundCell.add(rowBefore - 1);
      aroundCell.add(rowBefore + 1);
    } else if ((cellNumber + 1) % 12 == 0) {
      aroundCell.add(rowBefore);
      aroundCell.add(rowBefore - 1);
      aroundCell.add(cellNumber - 1);
      aroundCell.add(rowAfter);
      aroundCell.add(rowAfter - 1);
    } else {
      aroundCell.add(rowAfter - 1);
      aroundCell.add(rowAfter);
      aroundCell.add(rowAfter + 1);
      aroundCell.add(cellNumber - 1);
      aroundCell.add(cellNumber + 1);
      aroundCell.add(rowBefore);
      aroundCell.add(rowBefore - 1);
      aroundCell.add(rowBefore + 1);
    }

//    var list = new List.generate(SUM, (i) => i + 1);
    var tempList = List.from(aroundCell);
    for (var cellId in tempList) {
      if (player1List.contains(cellId)) {
        aroundCell.remove(cellId);
      }
      if (player2List.contains(cellId)) {
        aroundCell.remove(cellId);
      }
    }

    var r = new Random();
    var cellId = aroundCell[r.nextInt(aroundCell.length)];
    int i = itemlist.indexWhere((p) => p.id == cellId);
    playGame(itemlist[i], i);
  }

  /// detect winner
  int doReferee(List<int> players, int winner, int currentCell) {
    // check vertically
    for (var i = 0; i < players.length; i++) {
      var player = players[i];
      var vertically = players.contains(player + COLUMNS) &&
          players.contains(player + COLUMNS * 2) &&
          players.contains(player + COLUMNS * 3) &&
          players.contains(player + COLUMNS * 4);
      if (vertically) return winner;
      var horizontally = players.contains(player + 1) &&
          players.contains(player + 2) &&
          players.contains(player + 3) &&
          players.contains(player + 4);
      if (horizontally) return winner;
      var crossRight = players.contains(player + COLUMNS * 4 + 4) &&
          players.contains(player + COLUMNS * 3 + 3) &&
          players.contains(player + COLUMNS * 2 + 2) &&
          players.contains(player + COLUMNS + 1);
      if (crossRight) return winner;
      var crossLeft = players.contains(player + COLUMNS * 4 - 4) &&
          players.contains(player + COLUMNS * 3 - 3) &&
          players.contains(player + COLUMNS * 2 - 2) &&
          players.contains(player + COLUMNS - 1);
      if (crossLeft) return winner;
    }
    return null;
  }

  Column _buildPlayer(User player) {
    String _imagePath = player.gender == 0
        ? 'assets/images/female.png'
        : 'assets/images/male.png';
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Image(
          image: AssetImage(_imagePath),
          width: 30,
          height: 30,
        ),
        Container(
          margin: const EdgeInsets.only(top: 1),
          child: Text(player.firstname),
        )
      ],
    );
  }

  Text _buildText(String s) {
    return Text(s,
        style: TextStyle(
            color: Colors.red, fontSize: 30.0, fontWeight: FontWeight.w600));
  }

  void _backToMain() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Text('Do you surrender in this game ?'),
          actions: <Widget>[
            FlatButton(
              child: Text('Not'),
              onPressed: () {
                Navigator.of(context).pop(CANCEL);
              },
            ),
            FlatButton(
              child: Text('Yes'),
              onPressed: () {
                Navigator.pushNamed(context, MYPAGE);
              },
            ),
          ],
        );
      },
    );
  }

  void doFristTurn() {
    int firstCell = (COLUMNS * ROWS) ~/ 2 - 1;
    var gameItem = GameItem(
      id: firstCell,
      image: Image.asset('assets/images/p$activePlayer.png'),
      enabled: false,
    );
    playGame(itemlist[firstCell], firstCell);
  }
}
