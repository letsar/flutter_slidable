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
    Key? key,
  }) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool alive = true;

  @override
  Widget build(BuildContext context) {
    final direction = AppState.of(context)!.direction;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Slidable'),
      ),
      body: SlidableAutoCloseBehavior(
        child: Column(
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Slidable(
                  groupTag: '0',
                  direction: direction,
                  startActionPane: const ActionPane(
                    openThreshold: 0.1,
                    closeThreshold: 0.4,
                    motion: BehindMotion(),
                    children: [
                      SlideAction(color: Colors.green, icon: Icons.share),
                      SlideAction(color: Colors.amber, icon: Icons.delete),
                    ],
                  ),
                  endActionPane: const ActionPane(
                    motion: BehindMotion(),
                    children: [
                      SlideAction(
                          color: Colors.red, icon: Icons.delete_forever),
                      SlideAction(
                          color: Colors.blue, icon: Icons.alarm, flex: 2),
                    ],
                  ),
                  child: const Tile(color: Colors.grey, text: 'hello'),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Slidable(
                groupTag: '0',
                direction: direction,
                startActionPane: const ActionPane(
                  motion: StretchMotion(),
                  children: [
                    SlideAction(color: Colors.green, icon: Icons.share),
                    SlideAction(color: Colors.amber, icon: Icons.delete),
                  ],
                ),
                endActionPane: const ActionPane(
                  motion: StretchMotion(),
                  children: [
                    SlideAction(color: Colors.red, icon: Icons.delete_forever),
                    SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 3),
                  ],
                ),
                child: const Tile(color: Colors.pink, text: 'hello 2'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Slidable(
                direction: direction,
                startActionPane: const ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlideAction(color: Colors.green, icon: Icons.share),
                    SlideAction(color: Colors.amber, icon: Icons.delete),
                  ],
                ),
                endActionPane: const ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlideAction(color: Colors.red, icon: Icons.delete_forever),
                    SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                  ],
                ),
                child: const Tile(color: Colors.yellow, text: 'hello 3'),
              ),
            ),
            if (alive)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Slidable(
                  key: const ValueKey(4),
                  direction: direction,
                  startActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    dismissible: DismissiblePane(
                      onDismissed: () {
                        setState(() {
                          alive = false;
                        });
                      },
                      closeOnCancel: true,
                      confirmDismiss: () async {
                        return await showDialog<bool>(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Are you sure?'),
                                  content:
                                      const Text('Are you sure to dismiss?'),
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
                            ) ??
                            false;
                      },
                    ),
                    children: const [
                      SlideAction(color: Colors.green, icon: Icons.share),
                      SlideAction(color: Colors.amber, icon: Icons.delete),
                    ],
                  ),
                  endActionPane: const ActionPane(
                    motion: DrawerMotion(),
                    children: [
                      SlideAction(
                          color: Colors.red, icon: Icons.delete_forever),
                      SlideAction(
                          color: Colors.blue, icon: Icons.alarm, flex: 2),
                    ],
                  ),
                  child: const Tile(color: Colors.lime, text: 'hello 4'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class SlideAction extends StatelessWidget {
  const SlideAction({
    Key? key,
    required this.color,
    required this.icon,
    this.flex = 1,
  }) : super(key: key);

  final Color color;
  final IconData icon;
  final int flex;

  @override
  Widget build(BuildContext context) {
    return SlidableAction(
      flex: flex,
      backgroundColor: color,
      foregroundColor: Colors.white,
      onPressed: (_) {},
      icon: icon,
      label: 'hello',
    );
  }
}

class Tile extends StatelessWidget {
  const Tile({
    Key? key,
    required this.color,
    required this.text,
  }) : super(key: key);

  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    final direction = AppState.of(context)!.direction;
    return GestureDetector(
      onLongPress: () => Slidable.of(context)!.openEndActionPane(),
      child: Container(
        color: color,
        height: direction == Axis.horizontal ? 100 : double.infinity,
        width: direction == Axis.horizontal ? double.infinity : 100,
        child: Center(child: Text(text)),
      ),
    );
  }
}

class AppState extends InheritedWidget {
  const AppState({
    Key? key,
    required this.direction,
    required Widget child,
  }) : super(key: key, child: child);

  final Axis direction;

  @override
  bool updateShouldNotify(covariant AppState oldWidget) {
    return direction != oldWidget.direction;
  }

  static AppState? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppState>();
  }
}
