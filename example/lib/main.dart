import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or press Run > Flutter Hot Reload in IntelliJ). Notice that the
        // counter didn't reset back to zero; the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Demo Home Page'),
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
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return new Scaffold(
      appBar: new AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: new Text(widget.title),
      ),
      body: new Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: new ListView.builder(
          itemBuilder: (context, index) {
            return new Slidable(
              key: Key('$index'),
              delegate: _getDelegate(index),
              child: new Container(
                color: Colors.white,
                child: new ListTile(
                  leading: new CircleAvatar(
                    backgroundColor: _getAvatarColor(index),
                    child: new Text('$index'),
                    foregroundColor: Colors.white,
                  ),
                  title: new Text('Tile n°$index'),
                  subtitle: new Text(_getSubtitle(index)),
                ),
              ),
              leftActions: <Widget>[
                new _HomePageSlideAction(
                  text: 'Archive',
                  color: Colors.blue,
                  icon: Icons.archive,
                ),
                new _HomePageSlideAction(
                  text: 'Share',
                  color: Colors.indigo,
                  icon: Icons.share,
                ),
              ],
              rightActions: <Widget>[
                new _HomePageSlideAction(
                  text: 'More',
                  color: Colors.black45,
                  icon: Icons.more_horiz,
                ),
                new _HomePageSlideAction(
                  text: 'Delete',
                  color: Colors.red,
                  icon: Icons.delete,
                ),
              ],
            );
          },
          itemCount: 20,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  SlidableDelegate _getDelegate(int index){
    switch(index % 4){
      case 0 : return const SlidableBehindDelegate();
      case 1 : return const SlidableStrechDelegate();
      case 2 : return const SlidableScrollDelegate();
      case 3 : return const SlidableDrawerDelegate();
    }
  }

  Color _getAvatarColor(int index){
    switch(index % 4){
      case 0 : return Colors.red;
      case 1 : return Colors.green;
      case 2 : return Colors.blue;
      case 3 : return Colors.indigoAccent;
    }
  }

  String _getSubtitle(int index){
    switch(index % 4){
      case 0 : return 'SlidableBehindDelegate';
      case 1 : return 'SlidableStrechDelegate';
      case 2 : return 'SlidableScrollDelegate';
      case 3 : return 'SlidableDrawerDelegate';
    }
  }
}

class _HomePageSlideAction extends StatelessWidget {
  _HomePageSlideAction({this.text,this.icon,this.color,});

  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor = ThemeData.estimateBrightnessForColor(color) == Brightness.light ? Colors.black : Colors.white;
    final Text textWidget = new Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).primaryTextTheme.caption.copyWith(color: foregroundColor),
    );
    return GestureDetector(
      onTap: () => Scaffold.of(context).showSnackBar(SnackBar(content:textWidget)),
      child: Container(
        color: color,
        child: new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Icon(icon, color: foregroundColor,),
              textWidget,
            ],
          ),
        ),
      ),
    );
  }
}