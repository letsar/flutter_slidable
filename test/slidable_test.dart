import 'package:flutter_slidable/src/action_pane_motions.dart';
import 'package:flutter_slidable/src/actions.dart';
import 'package:flutter_slidable/src/controller.dart';
import 'package:flutter_slidable/src/dismissible_pane.dart';
import 'package:flutter_slidable/src/slidable.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

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

  testWidgets('controller can be replaced without throwing (#523)',
      (tester) async {
    final controllerA = SlidableController(const TestVSync());
    final controllerB = SlidableController(const TestVSync());
    addTearDown(controllerA.dispose);
    addTearDown(controllerB.dispose);
    const startActionPaneKey = ValueKey('start');

    Widget build(SlidableController? controller) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Slidable(
          controller: controller,
          startActionPane: ActionPane(
            key: startActionPaneKey,
            motion: const BehindMotion(),
            children: [
              SlidableAction(onPressed: (_) {}, icon: Icons.share),
            ],
          ),
          child: const SizedBox(width: 200, height: 50),
        ),
      );
    }

    // internal -> A -> B -> internal.
    await tester.pumpWidget(build(null));
    await tester.pumpWidget(build(controllerA));
    expect(tester.takeException(), isNull);

    controllerA.openStartActionPane();
    await tester.pumpAndSettle();
    expect(find.byKey(startActionPaneKey), findsOneWidget);

    await tester.pumpWidget(build(controllerB));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(startActionPaneKey), findsNothing);

    controllerB.openStartActionPane();
    await tester.pumpAndSettle();
    expect(find.byKey(startActionPaneKey), findsOneWidget);

    controllerB.close();
    await tester.pumpAndSettle();
    expect(find.byKey(startActionPaneKey), findsNothing);

    await tester.pumpWidget(build(null));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // The new internal controller is used by the Slidable.
    final context = tester.element(find.byType(SizedBox));
    final controller = Slidable.of(context)!;
    expect(controller, isNot(controllerA));
    expect(controller, isNot(controllerB));
    controller.openStartActionPane();
    await tester.pumpAndSettle();
    expect(find.byKey(startActionPaneKey), findsOneWidget);
  });

  testWidgets(
      'dismiss called from a SlidableAction with autoClose is not cancelled',
      (tester) async {
    final controller = SlidableController(const TestVSync());
    addTearDown(controller.dispose);
    var dismissed = false;

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Slidable(
          controller: controller,
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (context) {
                  Slidable.of(context)!.dismiss(
                    ResizeRequest(
                      const Duration(milliseconds: 300),
                      () => dismissed = true,
                    ),
                  );
                },
                icon: Icons.delete,
              ),
            ],
          ),
          child: const SizedBox(width: 200, height: 50),
        ),
      ),
    );

    controller.openEndActionPane();
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.delete));
    await tester.pumpAndSettle();

    expect(dismissed, isTrue);
  });

  group('onActionPaneChanged', () {
    Widget build(
      List<ActionPaneType> logs, {
      SlidableController? controller,
      VoidCallback? onDismissed,
    }) {
      return Directionality(
        textDirection: TextDirection.ltr,
        child: Slidable(
          key: const ValueKey('slidable'),
          controller: controller,
          onActionPaneChanged: logs.add,
          startActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SlidableAction(onPressed: (_) {}, icon: Icons.share),
            ],
          ),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            dismissible: onDismissed == null
                ? null
                : DismissiblePane(onDismissed: onDismissed),
            children: [
              SlidableAction(onPressed: (_) {}, icon: Icons.delete),
            ],
          ),
          child: const SizedBox(height: 50),
        ),
      );
    }

    testWidgets('is called once the action pane is opened or closed by a drag',
        (tester) async {
      final logs = <ActionPaneType>[];
      await tester.pumpWidget(build(logs));

      await tester.drag(find.byType(Slidable), const Offset(-600, 0));
      await tester.pumpAndSettle();
      expect(logs, [ActionPaneType.end]);

      await tester.drag(find.byType(Slidable), const Offset(300, 0));
      await tester.pumpAndSettle();
      expect(logs, [ActionPaneType.end, ActionPaneType.none]);
    });

    testWidgets('is not called when a drag does not open the action pane',
        (tester) async {
      final logs = <ActionPaneType>[];
      await tester.pumpWidget(build(logs));

      await tester.drag(find.byType(Slidable), const Offset(-100, 0));
      await tester.pumpAndSettle();

      expect(logs, isEmpty);
    });

    testWidgets('is called when the controller moves the Slidable',
        (tester) async {
      final controller = SlidableController(const TestVSync());
      addTearDown(controller.dispose);
      final logs = <ActionPaneType>[];
      await tester.pumpWidget(build(logs, controller: controller));

      controller.openEndActionPane();
      await tester.pumpAndSettle();
      controller.openEndActionPane();
      await tester.pumpAndSettle();
      expect(logs, [ActionPaneType.end]);

      controller.close();
      await tester.pumpAndSettle();
      controller.openStartActionPane();
      await tester.pumpAndSettle();
      expect(logs, [
        ActionPaneType.end,
        ActionPaneType.none,
        ActionPaneType.start,
      ]);
    });

    testWidgets('reports the new action pane when dragged from one to another',
        (tester) async {
      final controller = SlidableController(const TestVSync());
      addTearDown(controller.dispose);
      final logs = <ActionPaneType>[];
      await tester.pumpWidget(build(logs, controller: controller));

      controller.openStartActionPane();
      await tester.pumpAndSettle();
      await tester.drag(find.byType(Slidable), const Offset(-800, 0));
      await tester.pumpAndSettle();

      expect(logs.first, ActionPaneType.start);
      expect(logs.last, ActionPaneType.end);
      expect(logs.where((type) => type == ActionPaneType.start), hasLength(1));
    });

    testWidgets('is not called when the Slidable is dismissed',
        (tester) async {
      final logs = <ActionPaneType>[];
      var dismissed = false;
      await tester.pumpWidget(build(logs, onDismissed: () => dismissed = true));

      await tester.timedDrag(
        find.byType(Slidable),
        const Offset(-700, 0),
        const Duration(milliseconds: 400),
      );
      await tester.pumpAndSettle();

      expect(dismissed, isTrue);
      expect(logs, isEmpty);
    });
  });
}
