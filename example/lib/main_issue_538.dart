import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Slidable Example',
      home: Scaffold(
        appBar: AppBar(title: const Text('Issue 538')),
        body: ListView(
          children: const [
            ListItem(title: 'Only endActionPane', hasStartActionPane: false),
            ListItem(title: 'Only endActionPane', hasStartActionPane: false),
            ListItem(title: 'Both action panes', hasStartActionPane: true),
            ListItem(title: 'Both action panes', hasStartActionPane: true),
          ],
        ),
      ),
    );
  }
}

class ListItem extends StatelessWidget {
  const ListItem({
    Key? key,
    required this.title,
    required this.hasStartActionPane,
  }) : super(key: key);

  final String title;
  final bool hasStartActionPane;

  @override
  Widget build(BuildContext context) {
    return Slidable(
      startActionPane: hasStartActionPane
          ? ActionPane(
              motion: const BehindMotion(),
              children: [
                SlidableAction(
                  onPressed: (_) {},
                  backgroundColor: Colors.blue,
                  icon: Icons.archive,
                  label: 'Archive',
                ),
              ],
            )
          : null,
      endActionPane: ActionPane(
        motion: const BehindMotion(),
        children: [
          SlidableAction(
            onPressed: (_) {},
            backgroundColor: Colors.red,
            icon: Icons.delete,
            label: 'Delete',
          ),
        ],
      ),
      child: ColoredBox(
        color: Colors.grey.shade300,
        child: ListTile(title: Text(title)),
      ),
    );
  }
}
