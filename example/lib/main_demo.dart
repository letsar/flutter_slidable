import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slidable Demo',
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
        child: ListView(
          scrollDirection: flipAxis(direction),
          children: [
            Directionality(
              textDirection: TextDirection.rtl,
              child: Slidable(
                key: const ValueKey(1),
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
                    SlideAction(color: Colors.red, icon: Icons.delete_forever),
                    SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                  ],
                ),
                child: const Tile(color: Colors.grey, text: 'hello'),
              ),
            ),
            Slidable(
              key: const ValueKey(2),
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
            Slidable(
              key: const ValueKey(3),
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
            if (alive)
              Slidable(
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
                    SlideAction(color: Colors.red, icon: Icons.delete_forever),
                    SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                  ],
                ),
                child: const Tile(color: Colors.lime, text: 'hello 4'),
              ),
            Slidable(
              key: const ValueKey(5),
              direction: direction,
              startActionPane: const ActionPane(
                motion: BehindMotion(),
                children: [
                  SlideAction(color: Colors.green, icon: Icons.share),
                  SlideAction(color: Colors.amber, icon: Icons.delete),
                ],
              ),
              endActionPane: const ActionPane(
                motion: BehindMotion(),
                children: [
                  SlideAction(color: Colors.red, icon: Icons.delete_forever),
                  SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                ],
              ),
              child: const Tile(color: Colors.grey, text: 'hello'),
            ),
            Slidable(
              key: const ValueKey(6),
              direction: direction,
              startActionPane: const ActionPane(
                motion: BehindMotion(),
                children: [
                  SlideAction(color: Colors.green, icon: Icons.share),
                  SlideAction(color: Colors.amber, icon: Icons.delete),
                ],
              ),
              endActionPane: const ActionPane(
                motion: BehindMotion(),
                children: [
                  SlideAction(color: Colors.red, icon: Icons.delete_forever),
                  SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                ],
              ),
              child: const Tile(color: Colors.grey, text: 'hello'),
            ),
            Slidable(
              key: const ValueKey(7),
              direction: direction,
              startActionPane: const ActionPane(
                motion: BehindMotion(),
                children: [
                  SlideAction(color: Colors.green, icon: Icons.share),
                  SlideAction(color: Colors.amber, icon: Icons.delete),
                ],
              ),
              endActionPane: const ActionPane(
                motion: BehindMotion(),
                children: [
                  SlideAction(color: Colors.red, icon: Icons.delete_forever),
                  SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                ],
              ),
              child: const Tile(color: Colors.grey, text: 'hello'),
            ),
            Slidable(
              key: const ValueKey(8),
              direction: direction,
              startActionPane: const ActionPane(
                motion: BehindMotion(),
                children: [
                  SlideAction(color: Colors.green, icon: Icons.share),
                  SlideAction(color: Colors.amber, icon: Icons.delete),
                ],
              ),
              endActionPane: const ActionPane(
                motion: BehindMotion(),
                children: [
                  SlideAction(color: Colors.red, icon: Icons.delete_forever),
                  SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                ],
              ),
              child: const Tile(color: Colors.grey, text: 'hello'),
            ),
            Slidable(
              direction: direction,
              startActionPane: ActionPane(
                motion: const BehindMotion(),
                children: [
                  SlideAction(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                    ),
                    color: Colors.green.withOpacity(0.8),
                    icon: Icons.share,
                  ),
                  SlideAction(
                    color: Colors.amber.withOpacity(0.8),
                    icon: Icons.delete,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(19),
                    ),
                  ),
                ],
              ),
              endActionPane: const ActionPane(
                motion: BehindMotion(),
                children: [
                  SlideAction(color: Colors.red, icon: Icons.delete_forever),
                  SlideAction(color: Colors.blue, icon: Icons.alarm, flex: 2),
                ],
              ),
              child: const Tile(color: Colors.red, text: 'hello'),
            ),
          ],
        ),
      ),
    );
  }
}

class SlideAction extends StatelessWidget {
  const SlideAction({
    required this.color,
    required this.icon,
    Key? key,
    this.flex = 1,
  }) : super(key: key);

  final Color color;
  final IconData icon;
  final int flex;
  final OutlinedBorder shape;
  final BorderSide side;
  @override
  Widget build(BuildContext context) {
    return SlidableAction(
      flex: flex,
      shape: shape,
      side: side,
      backgroundColor: color,
      foregroundColor: Colors.white,
      onPressed: (_) {
        print(icon);
      },
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
    return ActionTypeListener(
      child: GestureDetector(
        onTap: () {
          print(text);
        },
        onLongPress: () => Slidable.of(context)!.openEndActionPane(),
        child: Container(
          color: color,
          height: direction == Axis.horizontal ? 100 : double.infinity,
          width: direction == Axis.horizontal ? double.infinity : 100,
          child: Center(child: Text(text)),
        ),
      ),
    );
  }
}

class ActionTypeListener extends StatefulWidget {
  const ActionTypeListener({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _ActionTypeListenerState createState() => _ActionTypeListenerState();
}

class _ActionTypeListenerState extends State<ActionTypeListener> {
  ValueNotifier<ActionPaneType>? _actionPaneTypeValueNotifier;

  @override
  void initState() {
    super.initState();
    _actionPaneTypeValueNotifier = Slidable.of(context)?.actionPaneType;
    _actionPaneTypeValueNotifier?.addListener(_onActionPaneTypeChanged);
  }

  @override
  void dispose() {
    _actionPaneTypeValueNotifier?.removeListener(_onActionPaneTypeChanged);
    super.dispose();
  }

  void _onActionPaneTypeChanged() {
    debugPrint('Value is ${_actionPaneTypeValueNotifier?.value}');
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
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
