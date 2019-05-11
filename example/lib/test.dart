import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() => runApp(MyDemoWidget());

class MyDemoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('DEMO'),
        ),
        body: Center(
          child: Container(
            height: 100.0,
            width: 100.0,
            color: Colors.orange,
            child: FractionallyAlignedSizedBox(
              leftFactor: 0.10,
              topFactor: 0.20,
              rightFactor: 0.30,
              bottomFactor: 0.40,
              child: Container(
                color: Colors.yellow,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
