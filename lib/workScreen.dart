import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_postgre/resultWidget.dart';
import 'package:intl/intl.dart';
import 'package:linked_scroll_controller/linked_scroll_controller.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:postgres/postgres.dart';

class WorkScreen extends StatefulWidget {


  PostgreSQLConnection connection;


  WorkScreen(this.connection);

  @override
  State createState() => _WorkScreenState();
}

enum Table {
  Insurants,
  Employers,
  Events,
  Types,
  Custom
}

class _WorkScreenState extends State<WorkScreen> {

  var res;
  var loading = false;
  var currentTable;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 70,
            color: Colors.lightBlue,
            child: Row(
              children: [
                IconButton(icon: Icon(Icons.arrow_back_sharp, color: Colors.white,), onPressed: () {
                  Navigator.of(context).pop();
                },)
              ],
            ),
          ),
          Container(
            height: 120,
            padding: EdgeInsets.all(8),
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                myButton("Insurants", "SELECT * FROM insurant", table: Table.Insurants),
                myButton("Events", "SELECT * FROM insured_events", table: Table.Events),
                myButton("Employers", "SELECT * FROM employer", table: Table.Employers),
                myButton("Insurance types", "SELECT * FROM insurance_type", table: Table.Types),
              myButton2("Custom query", () async {
                currentTable = Table.Custom;
                setState(() {});
              }),
                myButton("Insurance types", "SELECT * FROM insurance_type", table: Table.Types),
              ],
            ),
          ),
          StatefulBuilder(
            builder: (context, setState) {
              if (currentTable != null) {
                return StreamBuilder(
                  stream: addForm(setState),
                  builder: (context, snapshot) {
                    if (snapshot.hasData)
                      return Container(
                        child: snapshot.data,
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      );
                    return Container();
                },);
              }
              return Container();
            },
          ),

          Expanded(child: ResultWidget(res, GlobalKey(), loading))
        ],
      ),
    );
  }

  Widget myButton(String text, String query, {substitutionValues, Table table}) {
    return GestureDetector(
      onTap: () async {
        if (query.isNotEmpty) {
          loading = true;
          setState(() {});
          widget.connection.query(query, substitutionValues: substitutionValues)
              .then((value) {
            res = value;
            loading = false;
            setState(() {});
          });
        } else {
          setState(() {});
        }
      },
      child: Container(
        width: 180,
        height: 80,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white70,
          borderRadius: BorderRadius.all(Radius.circular(8)),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 3
            )
          ]
        ),
        alignment: Alignment.center,
        child: Stack(
          children: [
            Center(child: Text(text)),
            table != null ? Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: InkWell(
                  child: Icon(Icons.add),
                  onTap: () {
                    currentTable = table;
                    setState(() {});
                  },
                ),
              ),
            ) : Container()
          ],
        ),
      ),
    );
  }

  Widget myButton2(String text, onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        height: 80,
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
            color: Colors.white70,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  spreadRadius: 3
              )
            ]
        ),
        alignment: Alignment.center,
        child: Stack(
          children: [
            Center(child: Text(text))
          ],
        ),
      ),
    );
  }

  Stream<Widget> addForm(setState2) async* {

    yield Container(
      height: 200,
      child: CircularProgressIndicator(
        strokeWidth: 4,
        valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
      ),
    );
    if (currentTable == null) {

    }

    if (currentTable == Table.Insurants) {
      var employers = await widget.connection.query('SELECT did, name FROM employer');
      var types = await widget.connection.query('SELECT did, name FROM insurance_type');
      Insurant insurant = Insurant();
      yield Container(
        height: 200,
        child: Column(
          children: [
            Row(
              children: [
                tf((value) {
                  insurant.policyNumber = value;
                }, 'policy'),
                tf((value) {
                  insurant.passport = value;
                }, 'passport'),
                tf((value) {
                  insurant.name = value;
                }, 'name'),
                dp(context, (v) {insurant.bday = v;}, 'birthday'),
                StatefulBuilder(builder: (context, setState) =>
                    PopupMenuButton<int>(
                      child: Container(
                          width: 120,
                          height: 48,
                          alignment: Alignment.center,
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(4)),
                            border:  Border.all(color: Colors.black45),
                          ),
                          child: Text(insurant.type == null ? 'Select type' : insurant.type.toString())),
                      onSelected: (int result) { if (result != null) setState(() { insurant.type = result; }); },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                        ...types.map((e) {
                          return  PopupMenuItem<int>(
                            value: e[0] ?? 0,
                            child: Text('${e[1]}'),
                          );
                        })
                      ],
                    )
                ),
              ],
            ),
            Row(
              children: [
                tf((value) {
                  insurant.premium = value;
                }, 'premium'),
                tf((value) {
                  insurant.price = value;
                }, 'price'),
                StatefulBuilder(builder: (context, setState) =>
                PopupMenuButton<int>(
                  child: Container(
                    width: 120,
                    height: 48,
                    alignment: Alignment.center,
                    padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        border:  Border.all(color: Colors.black45),
                      ),
                      child: Text(insurant.manager == null ? 'Select employer' : employers[insurant.manager-1][1])),
                  onSelected: (int result) { if (result != null) setState(() { insurant.manager = result; }); },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
                    ...employers.map((e) {
                      return  PopupMenuItem<int>(
                        value: e[0] ?? 0,
                        child: Text('${e[1]}'),
                      );
                    })
                  ],
                )
                ),
                dp(context,  (v) {insurant.dateOfBegin = v;}, 'date of begin'),
                dp(context,  (v) {insurant.dateOfEnd = v;}, 'date of end'),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0),
                  child: MaterialButton(onPressed:() {
                    setState2(() {
                      currentTable = null;
                    });
                  }, child: Text('Cancel'), color: Colors.lightBlue,),
                ),
                MaterialButton(onPressed:() {
                  if (insurant.type != null && insurant.price != null && insurant.premium != null && insurant.dateOfEnd != null
                      && insurant.dateOfBegin != null && insurant.manager != null && insurant.bday != null && insurant.name != null && insurant.passport != null && insurant.policyNumber != null) {
                    widget.connection.query('''
              INSERT INTO insurant(policy_number, passport, name, bday, type, manager, date_of_begin, date_of_end, premium, price) VALUES
              ('${insurant.policyNumber}', '${insurant.passport}', '${insurant.name}', '${insurant.bday.toIso8601String()}',${insurant.type},${insurant.manager}, '${insurant.dateOfBegin.toIso8601String()}', '${insurant.dateOfEnd}', ${insurant.premium}, ${insurant.price})
              ''');
                  } else {
                    showModalBottomSheet(context: context, builder: (context) => Container(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text('Заполните все поля'),),);
                  }
                  setState2(() {
                    currentTable = null;
                  });
                }, child: Text('Add'), color: Colors.lightBlue,)
              ],
            )

          ],
        ),
      );
    } else if (currentTable == Table.Employers) {
      Employer employer = Employer();
      yield Column(
        children: [
          Row(
            children: [
              tf((value) {
                employer.name = value;
              }, 'name'),
              tf((value) {
                employer.passport = value;
              }, 'passport'),
              tf((value) {
                employer.position = value;
              }, 'position')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: MaterialButton(onPressed:() {
                  setState2(() {
                    currentTable = null;
                  });
                }, child: Text('Cancel'), color: Colors.lightBlue,),
              ),
              MaterialButton(onPressed:() async {
                if (employer.passport != null && employer.name != null && employer.position != null) {
                  var employers = await widget.connection.query('SELECT did, name FROM employer ORDER BY did');
                  int id = 1;
                  for (var e in employers) {
                    if (e[0] - id > 1) {
                      id = e[0] - 1;
                      break;
                    } else {
                      id++;
                    }
                  }
                  widget.connection.query('''
                  INSERT INTO employer(did, name, passport, position) VALUES
                  (${id}, '${employer.name}', '${employer.passport}', '${employer.position}')
              ''');
                } else {
                  showModalBottomSheet(context: context, builder: (context) => Container(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text('Заполните все поля'),),);
                }
                setState2(() {
                  currentTable = null;
                });
              }, child: Text('Add'), color: Colors.lightBlue,)
            ],
          )
        ],
      );
    } else if (currentTable == Table.Types) {
      InsuranceType insType = InsuranceType();
      yield Column(
        children: [
          Row(
            children: [
              tf((value) {
                insType.name = value;
              }, 'name'),
              tf((value) {
                insType.description = value;
              }, 'description'),
              tf((value) {
                insType.price = value;
              }, 'price')
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: MaterialButton(onPressed:() {
                  setState2(() {
                    currentTable = null;
                  });
                }, child: Text('Cancel'), color: Colors.lightBlue,),
              ),
              MaterialButton(onPressed:() async {
                if (insType.price != null && insType.name != null && insType.description != null) {
                  var employers = await widget.connection.query('SELECT did, name FROM insurance_type ORDER BY did');
                  int id = 1;
                  for (var e in employers) {
                    if (e[0] - id > 1) {
                      id = e[0] - 1;
                      break;
                    } else {
                      id++;
                    }
                  }
                  widget.connection.query('''
                  INSERT INTO insurance_type(did, name, description, price) VALUES
                  (${id}, '${insType.name}', '${insType.description}', ${insType.price})
              ''');
                } else {
                  showModalBottomSheet(context: context, builder: (context) => Container(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text('Заполните все поля'),),);
                }
                setState2(() {
                  currentTable = null;
                });
              }, child: Text('Add'), color: Colors.lightBlue,)
            ],
          )
        ],
      );
    } else if (currentTable == Table.Events) {
      InsuranceEvent event = InsuranceEvent();
      var insurants = await widget.connection.query('SELECT policy_number, passport, name FROM insurant ORDER BY name');
      yield Column(
        children: [
          Row(
            children: [
              StatefulBuilder(builder: (context, setState) =>
                  PopupMenuButton<String>(
                    child: Container(
                        width: 120,
                        height: 48,
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(4)),
                          border:  Border.all(color: Colors.black45),
                        ),
                        child: Text(event.insurant == null ? 'Select insurant' : insurants.where((e) => e[0] == event.insurant).first[0])),
                    onSelected: (String result) { if (result != null) setState(() { event.insurant = result; }); },
                    itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                      ...insurants.map((e) {
                        return  PopupMenuItem<String>(
                          value: e[0] ?? 0,
                          child: Text('${e[2]} ${e[1]} ${e[0]}'),
                        );
                      })
                    ],
                  )
              ),
              tf((value) {
                event.description = value;
              }, 'description'),
              tf((value) {
                event.payment = value;
              }, 'payment'),
              dp(context,  (v) {event.date = v;}, 'date'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: MaterialButton(onPressed:() {
                  setState2(() {
                    currentTable = null;
                  });
                }, child: Text('Cancel'), color: Colors.lightBlue,),
              ),
              MaterialButton(onPressed:() async {
                if (event.insurant != null && event.payment != null && event.description != null && event.date != null) {
                  var employers = await widget.connection.query('SELECT did, name FROM insurance_type ORDER BY did');
                  int id = 1;
                  for (var e in employers) {
                    if (e[0] - id > 1) {
                      id = e[0] - 1;
                      break;
                    } else {
                      id++;
                    }
                  }
                  widget.connection.query('''
                  INSERT INTO insured_events(insurant, description, occurance_date, payment) VALUES
                  ('${event.insurant}', '${event.description}', '${event.date.toIso8601String()}', ${event.payment})
              ''');
                } else {
                  showModalBottomSheet(context: context, builder: (context) => Container(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text('Заполните все поля'),),);
                }
                setState2(() {
                  currentTable = null;
                });
              }, child: Text('Add'), color: Colors.lightBlue,)
            ],
          )
        ],
      );
    } else if (currentTable == Table.Custom) {
      String query = '';
      yield Column(
        children: [
        TextField(
        onChanged: (value) {
          query = value;
        },
        decoration: InputDecoration(
            labelText: 'query'
        ),
        ),
        Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: MaterialButton(onPressed:() {
                  setState2(() {
                    currentTable = null;
                  });
                }, child: Text('Cancel'), color: Colors.lightBlue,),
              ),
              MaterialButton(onPressed:() {
                if (query != null && query.isNotEmpty) {
                  widget.connection.query(query).then((value) {
                    res = value;
                    setState((){});
                  });
                } else {
                  showModalBottomSheet(context: context, builder: (context) => Container(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text('Заполните все поля'),),);
                }

              }, child: Text('Execute'), color: Colors.lightBlue,)
            ],
          )
        ],
      );
    }

  }

}

Widget tf(changed, label) {
  return Container(
    width: 100,
    padding: EdgeInsets.all(8),
    child: TextField(
      onChanged: changed,
      decoration: InputDecoration(
          labelText: label
      ),
    ),
  );
}

Widget dp(context, picked, label) {
  // return MaterialButton(onPressed: () => showDatePicker(context: context, initialDate: DateTime.now(), firstDate: DateTime(1900), lastDate: DateTime.now()).then((value) {
  //   picked(value);
  // }),
  // color: Colors.lightBlue,
  // child: Text(
  //   label
  // ),
  // );

  var _dateController = TextEditingController();
  var maskFormatter = new MaskTextInputFormatter(mask: '##.##.####', filter: { "#": RegExp(r'[0-9]'), });

  return Padding(
    padding: const EdgeInsets.all(8.0),
    child: Container(
      width: 160,
      child: TextFormField(
        controller: _dateController,
        inputFormatters: [maskFormatter],
        validator: (value) {
          if (value.isEmpty) {
            return 'Это надо заполнить';
          } else {
            var d = myDateParse(_dateController.text);
            if (d != null) {
              if (d.year > 1800)
                return null;
              else return 'Люди столько не живут';
            } else return 'Кажется, такой даты нет';
          }
        },
        decoration: InputDecoration(
            labelText: label,
            hintText: 'дд.мм.гггг',
            contentPadding:
            EdgeInsets.symmetric(horizontal: 10.0),
            border: OutlineInputBorder(),
            suffixIcon: InkWell(
                onTap: () => showDatePicker(
                  context: context,
                  initialDatePickerMode:
                  myDateParse(_dateController.text) != null ? DatePickerMode.day : DatePickerMode.year,
                  initialDate: myDateParse(_dateController.text) ?? DateTime(2012),
                  firstDate: DateTime(1950),
                  lastDate: DateTime.now(),
                ).then((value) {
                  if (value != null) {
                    _dateController.text =
                        DateFormat('dd.MM.yyyy').format(value);
                    picked(value);
                  }
                }),
                child: Icon(Icons.calendar_today))),
      ),
    ),
  );

}

DateTime myDateParse(String s) {
  if (s.isEmpty)
    return null;
  s = s.trim().replaceAll('/', '.').replaceAll('-', '.').replaceAll(',', '.').replaceAll('\\', '.').replaceAll(':', '.');
  if (s.contains('.')) {
    try {
      var d =  DateFormat('dd.MM.yyyy').parseLoose(s);
      if (d.year >= 1950)
        return d;
    }
    catch (_) {}
  }
  return null;
}

class InsuranceType {
  int did;
  String name;
  String description;
  String price;
}


class InsuranceEvent {
  String insurant;
  String description;
  DateTime date;
  String payment;
}

class Employer {
  int did;
  String name;
  String passport;
  String position;
}

class Insurant {
  String policyNumber = '';
  String passport = '';
  String name = '';
  DateTime bday;
  int manager;
  DateTime dateOfBegin;
  DateTime dateOfEnd;
  String premium;
  String price;
  int type;
}