import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:material_ui/material_ui.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Slidable Example',
      home: ItemList(),
    );
  }
}

class ItemList extends StatefulWidget {
  const ItemList({
    Key? key,
  }) : super(key: key);

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  final items = List.generate(5, (index) => index);
  final logs = <String>[];

  void log(int item, ActionPaneType type) {
    setState(() => logs.insert(0, 'Item $item: ${type.name}'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('onActionPaneChanged')),
      body: SlidableAutoCloseBehavior(
        child: Column(
          children: [
            for (final item in items)
              Slidable(
                key: ValueKey(item),
                groupTag: 'items',
                onActionPaneChanged: (type) => log(item, type),
                startActionPane: ActionPane(
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) {},
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.archive,
                      label: 'Archive',
                    ),
                  ],
                ),
                endActionPane: ActionPane(
                  motion: const BehindMotion(),
                  dismissible: DismissiblePane(
                    onDismissed: () => setState(() => items.remove(item)),
                  ),
                  children: [
                    SlidableAction(
                      onPressed: (context) {
                        Slidable.of(context)!.dismiss(
                          ResizeRequest(
                            const Duration(milliseconds: 300),
                            () => setState(() => items.remove(item)),
                          ),
                        );
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(title: Text('Item $item')),
              ),
            const Divider(),
            Expanded(
              child: ListView(
                children: [
                  for (final entry in logs)
                    ListTile(dense: true, title: Text(entry)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
