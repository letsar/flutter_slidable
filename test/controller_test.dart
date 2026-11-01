import 'package:flutter_slidable/src/controller.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SlidableController', () {
    test('Manually changing ratio, changes action pane type', () async {
      final controller = SlidableController(const TestVSync());
      final actionTypeLogs = <ActionPaneType>[];
      final actionPaneType = controller.actionPaneType;
      actionPaneType.addListener(() {
        actionTypeLogs.add(actionPaneType.value);
      });

      expect(actionPaneType.value, ActionPaneType.none);

      controller.ratio = 0.5;
      expect(actionPaneType.value, ActionPaneType.start);
      controller.ratio = 0;
      expect(actionPaneType.value, ActionPaneType.none);
      controller.ratio = -0.5;
      expect(actionPaneType.value, ActionPaneType.end);
    });

    test(
        'Setting a ratio toward a disabled action pane, clamps the ratio to 0',
        () {
      final controller = SlidableController(const TestVSync())
        ..enableStartActionPane = false;

      controller.ratio = -0.3;
      expect(controller.ratio, -0.3);
      controller.ratio = 0.1;
      expect(controller.ratio, 0);
      expect(controller.actionPaneType.value, ActionPaneType.none);

      controller
        ..enableStartActionPane = true
        ..enableEndActionPane = false;

      controller.ratio = 0.3;
      expect(controller.ratio, 0.3);
      controller.ratio = -0.1;
      expect(controller.ratio, 0);
      expect(controller.actionPaneType.value, ActionPaneType.none);
    });

    testWidgets('Acting on the animation, changes action pane type',
        (tester) async {
      TestWidgetsFlutterBinding.ensureInitialized();
      final controller = SlidableController(const TestVSync());
      final actionTypeLogs = <ActionPaneType>[];
      final actionPaneType = controller.actionPaneType;
      actionPaneType.addListener(() {
        actionTypeLogs.add(actionPaneType.value);
      });
      controller.startActionPaneExtentRatio = 0.5;
      controller.endActionPaneExtentRatio = 0.5;

      expect(actionPaneType.value, ActionPaneType.none);

      controller.openStartActionPane();
      await tester.pumpAndSettle();
      expect(actionPaneType.value, ActionPaneType.start);
      controller.close();
      await tester.pumpAndSettle();
      expect(actionPaneType.value, ActionPaneType.none);
      controller.openEndActionPane();
      await tester.pumpAndSettle();
      expect(actionPaneType.value, ActionPaneType.end);
    });

    testWidgets('close does not cancel a running dismiss', (tester) async {
      final controller = SlidableController(tester);
      final requests = <ResizeRequest?>[];
      controller.resizeRequest.addListener(() {
        requests.add(controller.resizeRequest.value);
      });

      controller
          .dismiss(ResizeRequest(const Duration(milliseconds: 300), () {}));
      controller.close();
      await tester.pumpAndSettle();

      expect(controller.animation.value, 1);
      expect(requests, hasLength(1));
    });

    testWidgets('close works again after a dismiss has been cancelled',
        (tester) async {
      final controller = SlidableController(tester);

      controller
          .dismiss(ResizeRequest(const Duration(milliseconds: 300), () {}));
      await tester.pump(const Duration(milliseconds: 50));
      // Another animation, like a drag release, cancels the dismiss.
      controller.openTo(0.5);
      await tester.pumpAndSettle();
      expect(controller.resizeRequest.value, isNull);

      controller.close();
      await tester.pumpAndSettle();
      expect(controller.animation.value, 0);
    });
  });
}
