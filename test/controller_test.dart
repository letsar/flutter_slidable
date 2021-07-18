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
  });
}
