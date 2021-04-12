import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:postgres/postgres.dart';

class ResultWidget extends StatefulWidget {

  PostgreSQLResult data;
  bool loading;
  List<dynamic> tables;

  ResultWidget(this.data, key, this.loading) : super(key: key);

  @override
  State createState() => _ResultWidgetState();
}

class _ResultWidgetState extends State<ResultWidget> {

  LinkedScrollControllerGroup scrollControllerGroup;
  List<ScrollController> controllers = [];


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.lightBlueAccent[100].withOpacity(0.5),
          borderRadius: BorderRadius.all(Radius.circular(8))
        ),
        padding: EdgeInsets.all(8),
        child: widget.loading ? Container(
          child: SizedBox(
            width: 160,
            height: 160,
            child: Center(
              child: Container(
                alignment: Alignment.center,
                color: Colors.white60,
                child: CircularProgressIndicator(
                  strokeWidth: 6,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                ),
              ),
            ),
          ),
        ) : widget.data == null ? Container(
          child: Center(
            child: Text(
              'empty'
            ),
          ),
        ) : resultWidget(widget.data),
      ),
    );
  }



  Widget resultWidget(PostgreSQLResult data) {

    if (widget.data != null) {
      scrollControllerGroup = LinkedScrollControllerGroup();
      for (var d in widget.data) {
        controllers.add(scrollControllerGroup.addAndGet());
      }
      controllers.add(scrollControllerGroup.addAndGet());
    }

    if (data == null) {
      return Container();
    }
    int i = 0;
    var playerRows = data.map((e) => playerRow(e, 50, controllers[i++]));

    return Column(
      children: [
        Container(
          child: Text(
            widget.data[0].toTableColumnMap().keys.toString().replaceFirst('(', "").replaceFirst(')', ''),
            style: TextStyle(
              fontSize: 30
            ),
          ),
        ),
        Expanded(
          child: ListView(
              scrollDirection: Axis.vertical,
              children: [
                playerRow(data.columnDescriptions.map((e) => e.columnName).toList(), 50, controllers.last),
                ...playerRows
              ]
          ),
        ),
      ],
    );
  }

  Widget playerRow(List rowData, double rowHeight, controller) {
    int sum = 0;

/*    Widget addButton = GestureDetector(
        onTap: () {
          int addScore = 0;
          showModalBottomSheet(
              context: context,
              backgroundColor: Colors.transparent,
              builder: (BuildContext bc){
                var controller = TextEditingController()
                  ..text = addScore.toString();
                Function saveSetState;
                return StatefulBuilder(
                  builder: (context, setState) {
                    controller.text = addScore.toString();
                    return Container(
                      decoration: BoxDecoration(
                          color: Colors.lightBlue,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16))
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 400,
                            padding: EdgeInsets.only(left: 8, right: 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: (){
                                      addScore-=10;
                                      addScore = max(addScore, 0);
                                      setState(() {});
                                    },
                                    child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.lightBlueAccent,
                                            borderRadius: BorderRadius.horizontal(left: Radius.circular(8))
                                        ),
                                        height: 50,
                                        child: Icon(Icons.remove, color: Colors.white,)
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: controller,
                                    onChanged: (value) {
                                      int a = int.tryParse(value);
                                      if (value.isNotEmpty && (a == null || a < 0)) {
                                        controller.text = addScore.toString();
                                      } else {
                                        addScore = a ?? 0;
                                      }
                                      saveSetState((){});
                                    },
                                    showCursor: false,
                                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        counterText: ""
                                    ),
                                    maxLength: 4,

                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.white, fontSize: 42),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: (){
                                      addScore+=10;
                                      addScore = min(addScore, 9999);
                                      setState(() {});
                                    },
                                    child: Container(
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: Colors.lightBlueAccent,
                                            borderRadius: BorderRadius.horizontal(right: Radius.circular(8))
                                        ),
                                        height: 50,
                                        child: Icon(Icons.add, color: Colors.white,)
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          StatefulBuilder(
                              builder: (context, setState) {
                                saveSetState = setState;
                                return InkWell(
                                  onTap: addScore > 0 ? (){
                                    Navigator.of(context).pop(addScore);
                                  } : null,
                                  child: Container(
                                    height: 50,
                                    alignment: Alignment.center,
                                    margin: new EdgeInsets.only(left: 0.0, top: 8),
                                    decoration: new BoxDecoration(
                                      color: Colors.lightBlueAccent.withOpacity(addScore > 0 ? 1.0 : 0.7),
                                      shape: BoxShape.rectangle,
                                      borderRadius: new BorderRadius.circular(8.0),
                                    ),
                                    child: Padding(
                                      padding: EdgeInsets.all(8),
                                      child: FittedBox(
                                        fit: BoxFit.fitHeight,
                                        child: Text(
                                          'Done',
                                          style: TextStyle(color: Colors.white.withOpacity(addScore > 0 ? 1.0 : 0.7), fontSize: 50),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              }
                          )
                        ],
                      ),
                    );
                  },
                );
              }
          ).then((value) {
            if (value != null) {
              player.score += value;
              playerScores.add(value);
              if (!isGameFinished()) {
                widget.saveGame();
                setState(() {});
              } else {
                Game.deleteSaved();
                Navigator.of(context).pushReplacement(new MaterialPageRoute(builder: (context) => RewardScreen(widget.players, widget.maxScore, widget.gameVariant)));
              }
            }
          });
        },
        child: Container(
            child: Icon(Icons.add, color: Colors.white, size: height/4),
            decoration: BoxDecoration(
              color: Colors.lightBlueAccent,
              shape: BoxShape.circle,
            )
        )
    );*/

    var scoresPart = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      controller: controller,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ...rowData.map((e) => Container(
            height: 30,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: Text(e.toString()),
                  width: 200,
                  padding: EdgeInsets.symmetric(horizontal: 2),
                ),
              ],
            ),
          )),
        ],
      ),
    );

    return Container(
      child: scoresPart
    );

  }


}