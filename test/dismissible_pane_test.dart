import 'package:flutter/material.dart';
import 'package:flutter_slidable/src/action_pane_motions.dart';
import 'package:flutter_slidable/src/actions.dart';
import 'package:flutter_slidable/src/controller.dart';
import 'package:flutter_slidable/src/dismissible_pane.dart';
import 'package:flutter_slidable/src/dismissible_pane_motions.dart';
import 'package:flutter_slidable/src/slidable.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  group('DismissiblePane', () {
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
                    SlidableAction(
                        onPressed: (_) {},
                        icon: const SizedBox(
                          child: Icon(Icons.share),
                        )),
                    SlidableAction(
                        onPressed: (_) {},
                        icon: const SizedBox(
                          child: Icon(Icons.share),
                        )),
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

      final flutterError = tester.takeException() as FlutterError?;
      expect(flutterError, isNotNull);
    });

    testWidgets('startActionPane can be dismissed', (tester) async {
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

    testWidgets('endActionPane can be dismissed', (tester) async {
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
                endActionPane: ActionPane(
                  dismissible: DismissiblePane(
                    onDismissed: handleDismissed,
                    dismissThreshold: 0.8,
                  ),
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
                child: const SizedBox.expand(),
              ),
            ),
          ),
        ),
      );

      expect(dismissed, isFalse);

      await tester.timedDrag(
        find.byTypeOf<Slidable>(),
        const Offset(-80, 0),
        const Duration(milliseconds: 400),
      );

      // Wait for the resize to finish.
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
    });

    testWidgets(
        'startActionPane cannot be drag dismissed if dragDismissible is false',
        (tester) async {
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
                  dragDismissible: false,
                  dismissible: DismissiblePane(
                    onDismissed: handleDismissed,
                    dismissThreshold: 0.8,
                  ),
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
      SlidableController? controller;

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
      expect(controller!.ratio, 0);
    });
  });
}
