import 'package:flutter/material.dart';
import 'package:flutter_slidable/src/action_pane_motions.dart';
import 'package:flutter_slidable/src/actions.dart';
import 'package:flutter_slidable/src/slidable.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Slidable', () {
    testWidgets(
        'child should be able to open the horitzontal start action pane',
        (tester) async {
      const gestureDetectorKey = ValueKey('gesture_detector');
      const startActionPaneKey = ValueKey('start');
      const endActionPaneKey = ValueKey('end');
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Slidable(
            startActionPane: ActionPane(
              key: startActionPaneKey,
              motion: const BehindMotion(),
              children: [
                SlidableAction(onPressed: (_) {}, icon: Icons.share),
                SlidableAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            endActionPane: ActionPane(
              key: endActionPaneKey,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(onPressed: (_) {}, icon: Icons.share),
                SlidableAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            child: Builder(builder: (context) {
              return GestureDetector(
                key: gestureDetectorKey,
                onTap: () {
                  Slidable.of(context)!.openStartActionPane();
                },
              );
            }),
          ),
        ),
      );

      expect(find.byKey(startActionPaneKey), findsNothing);
      expect(find.byKey(endActionPaneKey), findsNothing);

      await tester.tap(find.byKey(gestureDetectorKey));
      await tester.pumpAndSettle();

      expect(find.byKey(startActionPaneKey), findsOneWidget);
      expect(find.byKey(endActionPaneKey), findsNothing);
    });

    testWidgets('child should be able to open the horizontal end action pane',
        (tester) async {
      const gestureDetectorKey = ValueKey('gesture_detector');
      const startActionPaneKey = ValueKey('start');
      const endActionPaneKey = ValueKey('end');
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Slidable(
            startActionPane: ActionPane(
              key: startActionPaneKey,
              motion: const BehindMotion(),
              children: [
                SlidableAction(onPressed: (_) {}, icon: Icons.share),
                SlidableAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            endActionPane: ActionPane(
              key: endActionPaneKey,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(onPressed: (_) {}, icon: Icons.share),
                SlidableAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            child: Builder(builder: (context) {
              return GestureDetector(
                key: gestureDetectorKey,
                onTap: () {
                  Slidable.of(context)!.openEndActionPane();
                },
              );
            }),
          ),
        ),
      );

      expect(find.byKey(startActionPaneKey), findsNothing);
      expect(find.byKey(endActionPaneKey), findsNothing);

      await tester.tap(find.byKey(gestureDetectorKey));
      await tester.pumpAndSettle();

      expect(find.byKey(startActionPaneKey), findsNothing);
      expect(find.byKey(endActionPaneKey), findsOneWidget);
    });

    testWidgets('child should be able to open the vertical start action pane',
        (tester) async {
      const gestureDetectorKey = ValueKey('gesture_detector');
      const startActionPaneKey = ValueKey('start');
      const endActionPaneKey = ValueKey('end');
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Slidable(
            direction: Axis.vertical,
            startActionPane: ActionPane(
              key: startActionPaneKey,
              motion: const BehindMotion(),
              children: [
                SlidableAction(onPressed: (_) {}, icon: Icons.share),
                SlidableAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            endActionPane: ActionPane(
              key: endActionPaneKey,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(onPressed: (_) {}, icon: Icons.share),
                SlidableAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            child: Builder(builder: (context) {
              return GestureDetector(
                key: gestureDetectorKey,
                onTap: () {
                  Slidable.of(context)!.openStartActionPane();
                },
              );
            }),
          ),
        ),
      );

      expect(find.byKey(startActionPaneKey), findsNothing);
      expect(find.byKey(endActionPaneKey), findsNothing);

      await tester.tap(find.byKey(gestureDetectorKey));
      await tester.pumpAndSettle();

      expect(find.byKey(startActionPaneKey), findsOneWidget);
      expect(find.byKey(endActionPaneKey), findsNothing);
    });

    testWidgets('child should be able to open the vertical end action pane',
        (tester) async {
      const gestureDetectorKey = ValueKey('gesture_detector');
      const startActionPaneKey = ValueKey('start');
      const endActionPaneKey = ValueKey('end');
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Slidable(
            direction: Axis.vertical,
            startActionPane: ActionPane(
              key: startActionPaneKey,
              motion: const BehindMotion(),
              children: [
                SlidableAction(onPressed: (_) {}, icon: Icons.share),
                SlidableAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            endActionPane: ActionPane(
              key: endActionPaneKey,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(onPressed: (_) {}, icon: Icons.share),
                SlidableAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            child: Builder(builder: (context) {
              return GestureDetector(
                key: gestureDetectorKey,
                onTap: () {
                  Slidable.of(context)!.openEndActionPane();
                },
              );
            }),
          ),
        ),
      );

      expect(find.byKey(startActionPaneKey), findsNothing);
      expect(find.byKey(endActionPaneKey), findsNothing);

      await tester.tap(find.byKey(gestureDetectorKey));
      await tester.pumpAndSettle();

      expect(find.byKey(startActionPaneKey), findsNothing);
      expect(find.byKey(endActionPaneKey), findsOneWidget);
    });
  });

  testWidgets('cannot drag to show startActionPane if null', (tester) async {
    const gestureDetectorKey = ValueKey('gesture_detector');
    const endActionPaneKey = ValueKey('end');
    const childKey = ValueKey('child');
    final findSlidable = find.byType(Slidable);
    const duration = Duration(milliseconds: 300);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Slidable(
          endActionPane: ActionPane(
            key: endActionPaneKey,
            motion: const ScrollMotion(),
            children: [
              SlidableAction(onPressed: (_) {}, icon: Icons.share),
              SlidableAction(onPressed: (_) {}, icon: Icons.delete),
            ],
          ),
          child: Builder(
            key: childKey,
            builder: (context) {
              return GestureDetector(
                key: gestureDetectorKey,
                onTap: () {
                  Slidable.of(context)!.openEndActionPane();
                },
              );
            },
          ),
        ),
      ),
    );

    expect(tester.getTopLeft(find.byKey(childKey)), const Offset(0, 0));

    await tester.timedDrag(findSlidable, const Offset(50, 0), duration);

    expect(tester.getTopLeft(find.byKey(childKey)), const Offset(0, 0));
  });

  testWidgets('cannot drag to show endActionPane if null', (tester) async {
    const gestureDetectorKey = ValueKey('gesture_detector');
    const startActionPaneKey = ValueKey('start');
    const childKey = ValueKey('child');
    final findSlidable = find.byType(Slidable);
    const duration = Duration(milliseconds: 300);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Slidable(
          startActionPane: ActionPane(
            key: startActionPaneKey,
            motion: const ScrollMotion(),
            children: [
              SlidableAction(onPressed: (_) {}, icon: Icons.share),
              SlidableAction(onPressed: (_) {}, icon: Icons.delete),
            ],
          ),
          child: Builder(
            key: childKey,
            builder: (context) {
              return GestureDetector(
                key: gestureDetectorKey,
                onTap: () {
                  Slidable.of(context)!.openEndActionPane();
                },
              );
            },
          ),
        ),
      ),
    );

    expect(tester.getTopLeft(find.byKey(childKey)), const Offset(0, 0));

    await tester.timedDrag(findSlidable, const Offset(-50, 0), duration);

    expect(tester.getTopLeft(find.byKey(childKey)), const Offset(0, 0));
  });

  testWidgets(
      'should work if TextDirection.rtl and only startActionPane is set',
      (tester) async {
    const gestureDetectorKey = ValueKey('gesture_detector');
    const actionPaneKey = ValueKey('action_pane');
    final actionPane = ActionPane(
      key: actionPaneKey,
      motion: const BehindMotion(),
      children: [
        SlidableAction(onPressed: (_) {}, icon: Icons.share),
        SlidableAction(onPressed: (_) {}, icon: Icons.delete),
      ],
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: Slidable(
          startActionPane: actionPane,
          child: Builder(builder: (context) {
            return GestureDetector(
              key: gestureDetectorKey,
              onTap: () {
                Slidable.of(context)!.openStartActionPane();
              },
            );
          }),
        ),
      ),
    );

    expect(find.byKey(actionPaneKey), findsNothing);

    await tester.tap(find.byKey(gestureDetectorKey));
    await tester.pumpAndSettle();

    expect(find.byKey(actionPaneKey), findsOneWidget);
  });

  testWidgets('should work if TextDirection.rtl and only endActionPane is set',
      (tester) async {
    const gestureDetectorKey = ValueKey('gesture_detector');
    const actionPaneKey = ValueKey('action_pane');
    final actionPane = ActionPane(
      key: actionPaneKey,
      motion: const BehindMotion(),
      children: [
        SlidableAction(onPressed: (_) {}, icon: Icons.share),
        SlidableAction(onPressed: (_) {}, icon: Icons.delete),
      ],
    );

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.rtl,
        child: Slidable(
          endActionPane: actionPane,
          child: Builder(builder: (context) {
            return GestureDetector(
              key: gestureDetectorKey,
              onTap: () {
                Slidable.of(context)!.openEndActionPane();
              },
            );
          }),
        ),
      ),
    );

    expect(find.byKey(actionPaneKey), findsNothing);

    await tester.tap(find.byKey(gestureDetectorKey));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    expect(find.byKey(actionPaneKey), findsOneWidget);
  });

  group('Diagonal gestures -', () {
    testWidgets(
        'vertical-dominant diagonal drag in ListView scrolls vertically without opening horizontal Slidable',
        (tester) async {
      final scrollController = ScrollController();
      const startActionPaneKey = ValueKey('start');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              controller: scrollController,
              itemCount: 50,
              itemBuilder: (context, index) {
                return Slidable(
                  key: ValueKey(index),
                  startActionPane: ActionPane(
                    key: index == 0 ? startActionPaneKey : null,
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(onPressed: (_) {}, icon: Icons.archive),
                    ],
                  ),
                  child: SizedBox(
                    height: 100,
                    child: Text('Item $index'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(scrollController.offset, 0.0);
      expect(find.byKey(startActionPaneKey), findsNothing);

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('Item 0')));
      // Fast thumb scroll diagonally: vertical (-60) dominates horizontal (25).
      await gesture.moveBy(const Offset(25, -60));
      await tester.pump();
      await gesture.moveBy(const Offset(0, -60));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(scrollController.offset, greaterThan(0.0));
      expect(find.byKey(startActionPaneKey), findsNothing);
    });

    testWidgets(
        'horizontal-dominant diagonal drag in ListView opens horizontal Slidable without scrolling vertically',
        (tester) async {
      final scrollController = ScrollController();
      const startActionPaneKey = ValueKey('start');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              controller: scrollController,
              itemCount: 50,
              itemBuilder: (context, index) {
                return Slidable(
                  key: ValueKey(index),
                  startActionPane: ActionPane(
                    key: index == 0 ? startActionPaneKey : null,
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(onPressed: (_) {}, icon: Icons.archive),
                    ],
                  ),
                  child: SizedBox(
                    height: 100,
                    child: Text('Item $index'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(scrollController.offset, 0.0);
      expect(find.byKey(startActionPaneKey), findsNothing);

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('Item 0')));
      // Intentional swipe: horizontal (300) dominates vertical (50).
      await gesture.moveBy(const Offset(300, 50));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(scrollController.offset, 0.0);
      expect(find.byKey(startActionPaneKey), findsOneWidget);
    });

    testWidgets(
        'horizontal-dominant diagonal drag in horizontal ListView scrolls horizontally without opening vertical Slidable',
        (tester) async {
      final scrollController = ScrollController();
      const startActionPaneKey = ValueKey('start');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              itemCount: 50,
              itemBuilder: (context, index) {
                return Slidable(
                  direction: Axis.vertical,
                  key: ValueKey(index),
                  startActionPane: ActionPane(
                    key: index == 0 ? startActionPaneKey : null,
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(onPressed: (_) {}, icon: Icons.archive),
                    ],
                  ),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Text('Item $index'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(scrollController.offset, 0.0);
      expect(find.byKey(startActionPaneKey), findsNothing);

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('Item 0')));
      // Horizontal scroll (-60) dominates vertical (25).
      await gesture.moveBy(const Offset(-60, 25));
      await tester.pump();
      await gesture.moveBy(const Offset(-60, 0));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(scrollController.offset, greaterThan(0.0));
      expect(find.byKey(startActionPaneKey), findsNothing);
    });

    testWidgets(
        'vertical-dominant diagonal drag in horizontal ListView opens vertical Slidable without scrolling horizontally',
        (tester) async {
      final scrollController = ScrollController();
      const startActionPaneKey = ValueKey('start');

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              scrollDirection: Axis.horizontal,
              controller: scrollController,
              itemCount: 50,
              itemBuilder: (context, index) {
                return Slidable(
                  direction: Axis.vertical,
                  key: ValueKey(index),
                  startActionPane: ActionPane(
                    key: index == 0 ? startActionPaneKey : null,
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(onPressed: (_) {}, icon: Icons.archive),
                    ],
                  ),
                  child: SizedBox(
                    width: 100,
                    height: 100,
                    child: Text('Item $index'),
                  ),
                );
              },
            ),
          ),
        ),
      );

      expect(scrollController.offset, 0.0);
      expect(find.byKey(startActionPaneKey), findsNothing);

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('Item 0')));
      // Vertical swipe (300) dominates horizontal (50).
      await gesture.moveBy(const Offset(50, 300));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(scrollController.offset, 0.0);
      expect(find.byKey(startActionPaneKey), findsOneWidget);
    });

    testWidgets(
        'RTL: vertical-dominant diagonal drag in ListView scrolls vertically without opening Slidable',
        (tester) async {
      final scrollController = ScrollController();
      const startActionPaneKey = ValueKey('start');

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: ListView.builder(
                controller: scrollController,
                itemCount: 50,
                itemBuilder: (context, index) {
                  return Slidable(
                    key: ValueKey(index),
                    startActionPane: ActionPane(
                      key: index == 0 ? startActionPaneKey : null,
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(onPressed: (_) {}, icon: Icons.archive),
                      ],
                    ),
                    child: SizedBox(
                      height: 100,
                      child: Text('Item $index'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(scrollController.offset, 0.0);
      expect(find.byKey(startActionPaneKey), findsNothing);

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('Item 0')));
      await gesture.moveBy(const Offset(-25, -60));
      await tester.pump();
      await gesture.moveBy(const Offset(0, -60));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(scrollController.offset, greaterThan(0.0));
      expect(find.byKey(startActionPaneKey), findsNothing);
    });

    testWidgets(
        'RTL: horizontal-dominant diagonal drag in ListView opens Slidable',
        (tester) async {
      final scrollController = ScrollController();
      const startActionPaneKey = ValueKey('start');

      await tester.pumpWidget(
        MaterialApp(
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: Scaffold(
              body: ListView.builder(
                controller: scrollController,
                itemCount: 50,
                itemBuilder: (context, index) {
                  return Slidable(
                    key: ValueKey(index),
                    startActionPane: ActionPane(
                      key: index == 0 ? startActionPaneKey : null,
                      motion: const DrawerMotion(),
                      children: [
                        SlidableAction(onPressed: (_) {}, icon: Icons.archive),
                      ],
                    ),
                    child: SizedBox(
                      height: 100,
                      child: Text('Item $index'),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      );

      expect(scrollController.offset, 0.0);
      expect(find.byKey(startActionPaneKey), findsNothing);

      final gesture =
          await tester.startGesture(tester.getCenter(find.text('Item 0')));
      // In RTL, startActionPane is revealed by dragging left (-300).
      await gesture.moveBy(const Offset(-300, 50));
      await tester.pump();
      await gesture.up();
      await tester.pumpAndSettle();

      expect(scrollController.offset, 0.0);
      expect(find.byKey(startActionPaneKey), findsOneWidget);
    });
  });
}
