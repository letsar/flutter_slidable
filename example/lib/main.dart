import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Slidable Demo',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: new MyHomePage(title: 'Flutter Slidable Demo'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
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

  SlidableDelegate _getDelegate(int index) {
    switch (index % 4) {
      case 0:
        return new SlidableBehindDelegate();
      case 1:
        return new SlidableStrechDelegate();
      case 2:
        return new SlidableScrollDelegate();
      case 3:
        return new SlidableDrawerDelegate();
      default:
        return null;
    }
  }

  Color _getAvatarColor(int index) {
    switch (index % 4) {
      case 0:
        return Colors.red;
      case 1:
        return Colors.green;
      case 2:
        return Colors.blue;
      case 3:
        return Colors.indigoAccent;
      default:
        return null;
    }
  }

  String _getSubtitle(int index) {
    switch (index % 4) {
      case 0:
        return 'SlidableBehindDelegate';
      case 1:
        return 'SlidableStrechDelegate';
      case 2:
        return 'SlidableScrollDelegate';
      case 3:
        return 'SlidableDrawerDelegate';
      default:
        return null;
    }
  }
}

class _HomePageSlideAction extends StatelessWidget {
  _HomePageSlideAction({
    this.text,
    this.icon,
    this.color,
  });

  final String text;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light
            ? Colors.black
            : Colors.white;
    final Text textWidget = new Text(
      text,
      overflow: TextOverflow.ellipsis,
      style: Theme
          .of(context)
          .primaryTextTheme
          .caption
          .copyWith(color: foregroundColor),
    );
    return GestureDetector(
      onTap: () =>
          Scaffold.of(context).showSnackBar(SnackBar(content: textWidget)),
      child: Container(
        color: color,
        child: new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Icon(
                icon,
                color: foregroundColor,
              ),
              textWidget,
            ],
          ),
        ),
      ),
    );
  }
}
