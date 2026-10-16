import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_slidable/src/controller.dart' show GestureDirection;
import 'package:flutter_test/flutter_test.dart';

const _childKey = ValueKey('content');

Widget _buildSlidable({
  SlidableController? controller,
  ValueChanged<SlidableController>? onController,
}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(
      child: SizedBox(
        width: 200,
        height: 80,
        child: Slidable(
          controller: controller,
          startActionPane: const ActionPane(
            motion: BehindMotion(),
            children: [Expanded(child: SizedBox())],
          ),
          child: Builder(
            builder: (context) {
              onController?.call(Slidable.of(context)!);
              return const SizedBox.expand(key: _childKey);
            },
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('replacing an open controller rebinds the action pane',
      (tester) async {
    final first = SlidableController(const TestVSync())..ratio = 0.5;
    final second = SlidableController(const TestVSync())..ratio = 0.3;
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    await tester.pumpWidget(_buildSlidable(controller: first));
    expect(first.actionPaneConfigurator, isNotNull);
    await tester.pumpWidget(_buildSlidable(controller: second));

    expect(tester.takeException(), isNull);
    expect(first.actionPaneConfigurator, isNull);
    expect(second.actionPaneConfigurator, isNotNull);
    second.dispatchEndGesture(0, GestureDirection.opening);
    await tester.pumpAndSettle();
    expect(second.ratio, 0.5);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('replacing an external controller updates the slide animation',
      (tester) async {
    final first = SlidableController(const TestVSync());
    final second = SlidableController(const TestVSync())..ratio = 0.25;
    addTearDown(first.dispose);
    addTearDown(second.dispose);

    await tester.pumpWidget(_buildSlidable(controller: first));
    final origin = tester.getTopLeft(find.byKey(_childKey));
    await tester.pumpWidget(_buildSlidable(controller: second));

    expect(tester.takeException(), isNull);
    expect(
        tester.getTopLeft(find.byKey(_childKey)), origin + const Offset(50, 0));

    // A replacement that is already open must drive the child immediately,
    // even when its action pane type does not change.
    second.ratio = 0.4;
    await tester.pump();
    expect(
        tester.getTopLeft(find.byKey(_childKey)), origin + const Offset(80, 0));

    first.ratio = 0.5;
    await tester.pump();
    expect(
        tester.getTopLeft(find.byKey(_childKey)), origin + const Offset(80, 0));
    await tester.pumpWidget(const SizedBox.shrink());

    // The old controller must no longer call setState on the removed widget.
    first.ratio = 0;
    expect(tester.takeException(), isNull);
  });

  testWidgets('replacing an internal controller disposes its active animation',
      (tester) async {
    late SlidableController internal;
    final external = SlidableController(const TestVSync());
    addTearDown(external.dispose);
    await tester.pumpWidget(_buildSlidable(
      onController: (controller) => internal = controller,
    ));
    internal.openStartActionPane();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpWidget(_buildSlidable(controller: external));
    expect(tester.takeException(), isNull);
    expect(() => internal.direction.addListener(() {}), throwsFlutterError);

    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
    // The externally owned controller remains usable after unmounting.
    external.ratio = 0.5;
    expect(external.ratio, 0.5);
  });

  testWidgets('removing an external controller creates a usable internal one',
      (tester) async {
    final external = SlidableController(const TestVSync());
    addTearDown(external.dispose);
    await tester.pumpWidget(_buildSlidable(controller: external));
    final origin = tester.getTopLeft(find.byKey(_childKey));
    late SlidableController internal;

    await tester.pumpWidget(_buildSlidable(
      onController: (controller) => internal = controller,
    ));
    expect(tester.takeException(), isNull);
    expect(internal, isNot(same(external)));
    internal.openStartActionPane();
    await tester.pumpAndSettle();
    expect(tester.getTopLeft(find.byKey(_childKey)),
        origin + const Offset(100, 0));

    external.ratio = 0.25;
    expect(external.ratio, 0.25);
    await tester.pumpWidget(const SizedBox.shrink());
    expect(() => internal.direction.addListener(() {}), throwsFlutterError);
    expect(tester.takeException(), isNull);
  });
}
