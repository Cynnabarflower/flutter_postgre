import 'package:database_adapter_postgre/database_adapter_postgre.dart';
import 'package:flutter/material.dart';
import 'package:flutter_postgre/workScreen.dart';
import 'package:postgres/postgres.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'My Insurance Client'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String ip = 'localhost';
  int port = 5432;
  String dbName = 'postgres';
  String username = 'postgres';
  String pass = '0000';
  bool loading = false;


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(

        title: Text(widget.title),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(
            // Center is a layout widget. It takes a single child and positions it
            // in the middle of the parent.
            child: Stack(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Row(children: [
                            Flexible(
                              child: TextField(
                                controller: new TextEditingController(
                                    text: ip
                                ),
                                decoration: InputDecoration(
                                  labelText: 'ip'
                                ),
                                onChanged: (value) {
                                  ip = value;
                                },
                              ),
                            ),
                            Flexible(
                              child: TextField(
                                controller: new TextEditingController(
                                    text: port.toString()
                                ),
                                decoration: InputDecoration(
                                    labelText: 'port',
                                ),
                                onChanged: (value) {
                                  port = int.tryParse(value);
                                },
                              ),
                            ),
                            Flexible(
                              child: TextField(
                                controller: new TextEditingController(
                                    text: dbName
                                ),
                                decoration: InputDecoration(
                                  labelText: 'db name',
                                ),
                                onChanged: (value) {
                                  dbName = value;
                                },
                              ),
                            )
                          ],),
                          Row(children: [
                            Flexible(
                              child: TextField(
                                controller: new TextEditingController(
                                    text: username
                                ),
                                decoration: InputDecoration(
                                    labelText: 'username'
                                ),
                                onChanged: (value) {
                                  username = value;
                                },
                              ),
                            ),
                            Flexible(
                              child: TextField(
                                controller: new TextEditingController(
                                    text: pass
                                ),
                                decoration: InputDecoration(
                                  labelText: 'pass',
                                ),
                                onChanged: (value) {
                                  pass = value;
                                },
                              ),
                            )
                          ],)
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        loading = true;
                        setState(() {});
                        var connection = PostgreSQLConnection(ip, port, dbName, username: username, password: pass);
                        connection.open().then((value) {
                          loading = false;
                          setState(() {});
                          Navigator.of(context).push(new MaterialPageRoute(builder: (context) => WorkScreen(connection),));
                        },
                          onError: (e) {
                          loading = false;
                          setState(() {});
                          showModalBottomSheet(context: context, builder: (context) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                child: Text(e.toString()),
                              ),
                            );
                          },);
                          }
                        );
                        },
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.all(8),
                        height: 70,
                        color: Colors.lightBlue,
                        child: Text('Connect', style: TextStyle(color: Colors.white),),
                      ),
                    )
                  ],
                ),
                AnimatedCrossFade(
                    firstChild: Container(),
                    secondChild:  Center(
                  child: Container(
                    alignment: Alignment.center,
                    color: Colors.white60,
                    child: SizedBox(
                      width: 200,
                      height: 200,
                      child: CircularProgressIndicator(
                        strokeWidth: 8,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                      ),
                    ),
                  ),
                ),
                    crossFadeState: loading ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                    duration: Duration(milliseconds: 500))

              ],
            ),
          ),
        ),
      ), 
    );
  }
}
