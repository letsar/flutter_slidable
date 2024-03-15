import 'package:flutter/gestures.dart';
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
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.share),
                    )),
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.delete),
                    )),
              ],
            ),
            endActionPane: ActionPane(
              key: endActionPaneKey,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.share),
                    )),
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.delete),
                    )),
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
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.share),
                    )),
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.delete),
                    )),
              ],
            ),
            endActionPane: ActionPane(
              key: endActionPaneKey,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.share),
                    )),
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.delete),
                    )),
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
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.share),
                    )),
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.delete),
                    )),
              ],
            ),
            endActionPane: ActionPane(
              key: endActionPaneKey,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.share),
                    )),
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.delete),
                    )),
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
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.share),
                    )),
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.delete),
                    )),
              ],
            ),
            endActionPane: ActionPane(
              key: endActionPaneKey,
              motion: const ScrollMotion(),
              children: [
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.share),
                    )),
                SlidableAction(
                    onPressed: (_) {},
                    icon: const SizedBox(
                      child: Icon(Icons.delete),
                    )),
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
              SlidableAction(
                  onPressed: (_) {},
                  icon: const SizedBox(
                    child: Icon(Icons.share),
                  )),
              SlidableAction(
                  onPressed: (_) {},
                  icon: const SizedBox(
                    child: Icon(Icons.delete),
                  )),
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
              SlidableAction(
                  onPressed: (_) {},
                  icon: const SizedBox(
                    child: Icon(Icons.share),
                  )),
              SlidableAction(
                  onPressed: (_) {},
                  icon: const SizedBox(
                    child: Icon(Icons.delete),
                  )),
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
        SlidableAction(
            onPressed: (_) {},
            icon: const SizedBox(
              child: Icon(Icons.share),
            )),
        SlidableAction(
            onPressed: (_) {},
            icon: const SizedBox(
              child: Icon(Icons.delete),
            )),
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
        SlidableAction(
            onPressed: (_) {},
            icon: const SizedBox(
              child: Icon(Icons.share),
            )),
        SlidableAction(
            onPressed: (_) {},
            icon: const SizedBox(
              child: Icon(Icons.delete),
            )),
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
}
