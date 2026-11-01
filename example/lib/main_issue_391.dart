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
  final items = List.generate(10, (index) => index);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Issue 391')),
      body: ListView(
        children: [
          for (final item in items)
            Slidable(
              key: ValueKey(item),
              endActionPane: ActionPane(
                motion: const BehindMotion(),
                children: [
                  SlidableAction(
                    // autoClose is true by default: the dismiss must still
                    // run to the end.
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
        ],
      ),
    );
  }
}
