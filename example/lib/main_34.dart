import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class Data {
  final String url = 'https://via.placeholder.com/350x150';
}

void main() => runApp(new MyApp());

Future<Data> getData() async {
  await Future.delayed(Duration(seconds: 1));
  return Data();
}

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
  final SlidableController slidableController = new SlidableController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (context, index) {
          return FutureBuilder<Data>(
            future: getData(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Slidable(
                  delegate: SlidableScrollDelegate(),
                  actionExtentRatio: 0.25,
                  secondaryActions: <Widget>[
                    IconSlideAction(
                      caption: 'Delete',
                      color: Colors.red,
                      icon: Icons.delete,
                      //onTap: () => removeLocation(location),
                    ),
                  ],
                  child: ListTile(
                    // onTap: () {
                    //   Navigator.pushNamed(context, Routes.closeUp);
                    // },

                    leading: SizedBox(
                      width: 64.0,
                      height: 64.0,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(64.0),
                        child: RepaintBoundary(
                          child: Image(
                            image: NetworkImage(snapshot.data.url),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }
              return CircularProgressIndicator();
            },
          );
        },
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods.
  }
}
