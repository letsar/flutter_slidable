import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_slidable/src/slidable.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  group('Slidable', () {
    test('constructor asserts', () {
      final values = [
        true,
        true,
        Axis.horizontal,
        DragStartBehavior.down,
        true,
        const SizedBox(),
      ];

      testConstructorAsserts(
        values: values,
        factory: (valueOrNull) => Slidable(
          enabled: valueOrNull(0),
          closeOnScroll: valueOrNull(1),
          direction: valueOrNull(2),
          dragStartBehavior: valueOrNull(3),
          useTextDirection: valueOrNull(4),
          child: valueOrNull(5),
        ),
      );
    });

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
              transition: const SlidableBehindTransition(),
              children: [
                SlidableIconAction(onPressed: (_) {}, icon: Icons.share),
                SlidableIconAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            endActionPane: ActionPane(
              key: endActionPaneKey,
              transition: const SlidableScrollTransition(),
              children: [
                SlidableIconAction(onPressed: (_) {}, icon: Icons.share),
                SlidableIconAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            child: Builder(builder: (context) {
              return GestureDetector(
                key: gestureDetectorKey,
                onTap: () {
                  Slidable.of(context).openStartActionPane();
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
              transition: const SlidableBehindTransition(),
              children: [
                SlidableIconAction(onPressed: (_) {}, icon: Icons.share),
                SlidableIconAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            endActionPane: ActionPane(
              key: endActionPaneKey,
              transition: const SlidableScrollTransition(),
              children: [
                SlidableIconAction(onPressed: (_) {}, icon: Icons.share),
                SlidableIconAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            child: Builder(builder: (context) {
              return GestureDetector(
                key: gestureDetectorKey,
                onTap: () {
                  Slidable.of(context).openEndActionPane();
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
              transition: const SlidableBehindTransition(),
              children: [
                SlidableIconAction(onPressed: (_) {}, icon: Icons.share),
                SlidableIconAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            endActionPane: ActionPane(
              key: endActionPaneKey,
              transition: const SlidableScrollTransition(),
              children: [
                SlidableIconAction(onPressed: (_) {}, icon: Icons.share),
                SlidableIconAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            child: Builder(builder: (context) {
              return GestureDetector(
                key: gestureDetectorKey,
                onTap: () {
                  Slidable.of(context).openStartActionPane();
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
              transition: const SlidableBehindTransition(),
              children: [
                SlidableIconAction(onPressed: (_) {}, icon: Icons.share),
                SlidableIconAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            endActionPane: ActionPane(
              key: endActionPaneKey,
              transition: const SlidableScrollTransition(),
              children: [
                SlidableIconAction(onPressed: (_) {}, icon: Icons.share),
                SlidableIconAction(onPressed: (_) {}, icon: Icons.delete),
              ],
            ),
            child: Builder(builder: (context) {
              return GestureDetector(
                key: gestureDetectorKey,
                onTap: () {
                  Slidable.of(context).openEndActionPane();
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
}
