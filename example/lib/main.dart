import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const AppState(
        direction: Axis.horizontal,
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    Key key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool alive = true;

  @override
  Widget build(BuildContext context) {
    final direction = AppState.of(context).direction;
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Slidable'),
      ),
      body: SlidableNotificationListener(
        onNotification: (notification) {},
        child: ListView(
          scrollDirection: flipAxis(direction),
          children: [
            Slidable(
              tag: '0',
              direction: direction,
              startActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.green, icon: Icons.share),
                  SlideAction(color: Colors.amber, icon: Icons.delete),
                ],
              ),
              endActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.red, icon: Icons.delete_forever),
                  SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                ],
              ),
              child: Tile(color: Colors.grey, text: 'hello'),
            ),
            Slidable(
              tag: '0',
              direction: direction,
              startActionPane: ActionPane(
                transition: SlidableStretchTransition(),
                children: [
                  SlideAction(color: Colors.green, icon: Icons.share),
                  SlideAction(color: Colors.amber, icon: Icons.delete),
                ],
              ),
              endActionPane: ActionPane(
                transition: SlidableStretchTransition(),
                children: [
                  SlideAction(color: Colors.red, icon: Icons.delete_forever),
                  SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                ],
              ),
              child: Tile(color: Colors.pink, text: 'hello 2'),
            ),
            Slidable(
              direction: direction,
              startActionPane: ActionPane(
                transition: SlidableScrollTransition(),
                children: [
                  SlideAction(color: Colors.green, icon: Icons.share),
                  SlideAction(color: Colors.amber, icon: Icons.delete),
                ],
              ),
              endActionPane: ActionPane(
                transition: SlidableScrollTransition(),
                children: [
                  SlideAction(color: Colors.red, icon: Icons.delete_forever),
                  SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                ],
              ),
              child: Tile(color: Colors.yellow, text: 'hello 3'),
            ),
            if (alive)
              Slidable(
                key: ValueKey(4),
                direction: direction,
                startActionPane: ActionPane(
                  transition: SlidableDrawerTransition(),
                  dismissible: DismissiblePane(
                    onDismissed: () {
                      setState(() {
                        alive = false;
                      });
                    },
                    closeOnCancel: true,
                    confirmDismiss: () async {
                      return showDialog<bool>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Are you sure?'),
                            content: const Text('Are you sure to dismiss?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Yes'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('No'),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  children: [
                    SlideAction(color: Colors.green, icon: Icons.share),
                    SlideAction(color: Colors.amber, icon: Icons.delete),
                  ],
                ),
                endActionPane: ActionPane(
                  transition: SlidableDrawerTransition(),
                  children: [
                    SlideAction(color: Colors.red, icon: Icons.delete_forever),
                    SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                  ],
                ),
                child: Tile(color: Colors.lime, text: 'hello 4'),
              ),
            Slidable(
              direction: direction,
              startActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.green, icon: Icons.share),
                  SlideAction(color: Colors.amber, icon: Icons.delete),
                ],
              ),
              endActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.red, icon: Icons.delete_forever),
                  SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                ],
              ),
              child: Tile(color: Colors.grey, text: 'hello'),
            ),
            Slidable(
              direction: direction,
              startActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.green, icon: Icons.share),
                  SlideAction(color: Colors.amber, icon: Icons.delete),
                ],
              ),
              endActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.red, icon: Icons.delete_forever),
                  SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                ],
              ),
              child: Tile(color: Colors.grey, text: 'hello'),
            ),
            Slidable(
              direction: direction,
              startActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.green, icon: Icons.share),
                  SlideAction(color: Colors.amber, icon: Icons.delete),
                ],
              ),
              endActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.red, icon: Icons.delete_forever),
                  SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                ],
              ),
              child: Tile(color: Colors.grey, text: 'hello'),
            ),
            Slidable(
              direction: direction,
              startActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.green, icon: Icons.share),
                  SlideAction(color: Colors.amber, icon: Icons.delete),
                ],
              ),
              endActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.red, icon: Icons.delete_forever),
                  SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                ],
              ),
              child: Tile(color: Colors.grey, text: 'hello'),
            ),
            Slidable(
              direction: direction,
              startActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.green, icon: Icons.share),
                  SlideAction(color: Colors.amber, icon: Icons.delete),
                ],
              ),
              endActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.red, icon: Icons.delete_forever),
                  SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                ],
              ),
              child: Tile(color: Colors.grey, text: 'hello'),
            ),
            Slidable(
              direction: direction,
              startActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.green, icon: Icons.share),
                  SlideAction(color: Colors.amber, icon: Icons.delete),
                ],
              ),
              endActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.red, icon: Icons.delete_forever),
                  SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                ],
              ),
              child: Tile(color: Colors.grey, text: 'hello'),
            ),
            Slidable(
              direction: direction,
              startActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.green, icon: Icons.share),
                  SlideAction(color: Colors.amber, icon: Icons.delete),
                ],
              ),
              endActionPane: ActionPane(
                transition: SlidableBehindTransition(),
                children: [
                  SlideAction(color: Colors.red, icon: Icons.delete_forever),
                  SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                ],
              ),
              child: Tile(color: Colors.grey, text: 'hello'),
            ),
          ],
        ),
      ),
    );
  }
}

class SlideAction extends StatelessWidget {
  const SlideAction({
    Key key,
    @required this.color,
    @required this.icon,
    this.flex = 1,
  }) : super(key: key);

  final Color color;
  final IconData icon;
  final int flex;

  @override
  Widget build(BuildContext context) {
    final direction = AppState.of(context).direction;
    return Expanded(
      flex: flex,
      child: Container(
        height: direction == Axis.horizontal ? double.infinity : null,
        width: direction == Axis.horizontal ? null : double.infinity,
        color: color,
        child: Center(
          child: Icon(
            icon,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({
    Key key,
    @required this.color,
    @required this.text,
  }) : super(key: key);

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final direction = AppState.of(context).direction;
    return Container(
      color: color,
      height: direction == Axis.horizontal ? 100 : double.infinity,
      width: direction == Axis.horizontal ? double.infinity : 100,
      child: Center(child: Text(text)),
    );
  }
}

class AppState extends InheritedWidget {
  const AppState({
    Key key,
    @required this.direction,
    @required Widget child,
  }) : super(key: key, child: child);

  final Axis direction;

  @override
  bool updateShouldNotify(covariant AppState oldWidget) {
    return direction != oldWidget.direction;
  }

  static AppState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppState>();
  }
}
