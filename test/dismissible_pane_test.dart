import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_slidable/src/slidable.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  group('DismissiblePane', () {
    test('constructor asserts', () {
      final values = [
        () {},
        0.75,
        const Duration(milliseconds: 300),
        const Duration(milliseconds: 300),
        true,
        const InversedDrawerMotion(),
      ];

      testConstructorAsserts(
        values: values,
        factory: (valueOrNull) => DismissiblePane(
          onDismissed: valueOrNull(0),
          dismissThreshold: valueOrNull(1),
          dismissalDuration: valueOrNull(2),
          resizeDuration: valueOrNull(3),
          closeOnCancel: valueOrNull(4),
          motion: valueOrNull(5),
        ),
      );
    });

    testWidgets('throws if Slidable has not key', (tester) async {
      void handleDismissed() {}

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              height: 200,
              width: 100,
              child: Slidable(
                startActionPane: ActionPane(
                  dismissible: DismissiblePane(
                    onDismissed: handleDismissed,
                    dismissThreshold: 0.8,
                    motion:
                        // For coverage:
                        // ignore: prefer_const_constructors
                        InversedDrawerMotion(),
                  ),
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(onPressed: (_) {}, icon: Icons.share),
                    SlidableAction(onPressed: (_) {}, icon: Icons.delete),
                  ],
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );

      await tester.timedDrag(
        find.byTypeOf<Slidable>(),
        const Offset(80, 0),
        const Duration(milliseconds: 400),
      );

      final flutterError = tester.takeException() as FlutterError;
      expect(flutterError, isNotNull);
    });

    testWidgets('can be dismissed', (tester) async {
      bool dismissed = false;
      void handleDismissed() {
        dismissed = true;
      }

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              height: 200,
              width: 100,
              child: Slidable(
                key: const ValueKey('key'),
                startActionPane: ActionPane(
                  dismissible: DismissiblePane(
                    onDismissed: handleDismissed,
                    dismissThreshold: 0.8,
                  ),
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(onPressed: (_) {}, icon: Icons.share),
                    SlidableAction(onPressed: (_) {}, icon: Icons.delete),
                  ],
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );

      expect(dismissed, isFalse);

      await tester.timedDrag(
        find.byTypeOf<Slidable>(),
        const Offset(80, 0),
        const Duration(milliseconds: 400),
      );

      // Wait for the resize to finish.
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets(
        'when the drag is not past the dismissThreshold, the Slidable stays open',
        (tester) async {
      bool dismissed = false;
      void handleDismissed() {
        dismissed = true;
      }

      const startActionPaneKey = ValueKey('start');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              height: 200,
              width: 100,
              child: Slidable(
                key: const ValueKey('key'),
                startActionPane: ActionPane(
                  key: startActionPaneKey,
                  dismissible: DismissiblePane(
                    onDismissed: handleDismissed,
                    dismissThreshold: 0.8,
                  ),
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(onPressed: (_) {}, icon: Icons.share),
                    SlidableAction(onPressed: (_) {}, icon: Icons.delete),
                  ],
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );

      expect(dismissed, isFalse);

      await tester.timedDrag(
        find.byTypeOf<Slidable>(),
        const Offset(70, 0),
        const Duration(milliseconds: 400),
      );

      // Wait for the resize to finish.
      await tester.pumpAndSettle();

      expect(dismissed, isFalse);
      expect(find.byKey(startActionPaneKey), findsOneWidget);
    });

    testWidgets('can be canceled', (tester) async {
      bool dismissed = false;
      void handleDismissed() {
        dismissed = true;
      }

      Future<bool> confirmDismiss() async {
        return false;
      }

      const startActionPaneKey = ValueKey('start');

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              height: 200,
              width: 100,
              child: Slidable(
                key: const ValueKey('key'),
                startActionPane: ActionPane(
                  key: startActionPaneKey,
                  dismissible: DismissiblePane(
                    onDismissed: handleDismissed,
                    confirmDismiss: confirmDismiss,
                    dismissThreshold: 0.8,
                  ),
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(onPressed: (_) {}, icon: Icons.share),
                    SlidableAction(onPressed: (_) {}, icon: Icons.delete),
                  ],
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );

      expect(dismissed, isFalse);

      await tester.timedDrag(
        find.byTypeOf<Slidable>(),
        const Offset(80, 0),
        const Duration(milliseconds: 400),
      );

      // Wait for the resize to finish.
      await tester.pumpAndSettle();

      expect(dismissed, isFalse);
      expect(find.byKey(startActionPaneKey), findsOneWidget);
    });

    testWidgets('can be canceled and close', (tester) async {
      bool dismissed = false;
      void handleDismissed() {
        dismissed = true;
      }

      Future<bool> confirmDismiss() async {
        return false;
      }

      const startActionPaneKey = ValueKey('start');
      SlidableController controller;

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox(
              height: 200,
              width: 100,
              child: Slidable(
                key: const ValueKey('key'),
                startActionPane: ActionPane(
                  key: startActionPaneKey,
                  dismissible: DismissiblePane(
                    onDismissed: handleDismissed,
                    confirmDismiss: confirmDismiss,
                    closeOnCancel: true,
                    dismissThreshold: 0.8,
                  ),
                  motion: const BehindMotion(),
                  children: [
                    SlidableAction(onPressed: (_) {}, icon: Icons.share),
                    SlidableAction(onPressed: (_) {}, icon: Icons.delete),
                  ],
                ),
                child: Builder(
                  builder: (context) {
                    controller = Slidable.of(context);
                    return const SizedBox.expand();
                  },
                ),
              ),
            ),
          ),
        ),
      );

      expect(dismissed, isFalse);

      await tester.timedDrag(
        find.byTypeOf<Slidable>(),
        const Offset(80, 0),
        const Duration(milliseconds: 400),
      );

      // Wait for the resize to finish.
      await tester.pumpAndSettle();

      expect(dismissed, isFalse);
      expect(controller.ratio, 0);
    });
  });
}
