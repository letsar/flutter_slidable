import 'package:flutter/material.dart';

void main() => runApp(MyDemoWidget());

class MyDemoWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // The child's left edge should be indented at 10% of the parent's width.
    const double leftFactor = 0.10;
    // The child's top edge should be indented at 20% of the parent's height.
    const double topFactor = 0.20;
    // The child should have a width of 60% (100 - 10 - 30) of the parent's width.
    const double widthFactor = 0.60;
    // The child should have a height of 40% (100 - 20 - 40) of the parent's height.
    const double heightFactor = 0.40;

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
            child: Align(
              alignment: FractionalOffset(
                leftFactor / (1.0 - widthFactor),
                topFactor / (1.0 - heightFactor),
              ),
              child: FractionallySizedBox(
                widthFactor: widthFactor,
                heightFactor: heightFactor,
                child: Container(
                  color: Colors.yellow,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
