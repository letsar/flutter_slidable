import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/src/controller.dart';
import 'package:flutter_slidable/src/gesture_detector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'common.dart';

final mockSlidableController = MockSlidableController();
final finder = find.byTypeOf<SlidableGestureDetector>();

void main() {
  setUp(() {
    reset(mockSlidableController);
  });

  group('SlidableGestureDetector -', () {
    test('constructor asserts', () {
      final values = [
        true,
        mockSlidableController,
        Axis.horizontal,
        DragStartBehavior.down,
        const SizedBox(),
      ];

      testConstructorAsserts(
        values: values,
        factory: (valueOrNull) => SlidableGestureDetector(
          enabled: valueOrNull(0),
          controller: valueOrNull(1),
          direction: valueOrNull(2),
          dragStartBehavior: valueOrNull(3),
          child: valueOrNull(4),
        ),
      );
    });

    testWidgets('can slide horizontally', (tester) async {
      final slidableController = SlidableController(const TestVSync());

      await tester.pumpWidget(Center(
        child: SizedBox(
          height: 200,
          width: 100,
          child: SlidableGestureDetector(
            controller: slidableController,
            direction: Axis.horizontal,
            child: const SizedBox.expand(),
          ),
        ),
      ));

      const posDelta = Offset(10, 0);
      const negDelta = Offset(-10, 0);

      await tester.drag(finder, posDelta);
      expect(slidableController.ratio, 0.1);

      await tester.drag(finder, negDelta);
      expect(slidableController.ratio, 0);

      await tester.drag(finder, negDelta);
      expect(slidableController.ratio, -0.1);
    });

    testWidgets('can slide vertically', (tester) async {
      final slidableController = SlidableController(const TestVSync());

      await tester.pumpWidget(Center(
        child: SizedBox(
          height: 100,
          width: 200,
          child: SlidableGestureDetector(
            controller: slidableController,
            direction: Axis.vertical,
            child: const SizedBox.expand(),
          ),
        ),
      ));

      const posDelta = Offset(0, 10);
      const negDelta = Offset(0, -10);

      await tester.drag(finder, posDelta);
      expect(slidableController.ratio, 0.1);

      await tester.drag(finder, negDelta);
      expect(slidableController.ratio, 0);

      await tester.drag(finder, negDelta);
      expect(slidableController.ratio, -0.1);
    });

    testWidgets('cannot slide horizontally if asked', (tester) async {
      final slidableController = SlidableController(const TestVSync());

      await tester.pumpWidget(Center(
        child: SizedBox(
          height: 200,
          width: 100,
          child: SlidableGestureDetector(
            enabled: false,
            controller: slidableController,
            direction: Axis.horizontal,
            child: const SizedBox.expand(),
          ),
        ),
      ));

      const posDelta = Offset(0, 10);
      const negDelta = Offset(0, -10);

      await tester.drag(finder, posDelta);
      expect(slidableController.ratio, 0);

      await tester.drag(finder, negDelta);
      expect(slidableController.ratio, 0);

      await tester.drag(finder, negDelta);
      expect(slidableController.ratio, 0);
    });

    testWidgets('cannot slide vertically if asked', (tester) async {
      final slidableController = SlidableController(const TestVSync());

      await tester.pumpWidget(Center(
        child: SizedBox(
          height: 100,
          width: 200,
          child: SlidableGestureDetector(
            enabled: false,
            controller: slidableController,
            direction: Axis.vertical,
            child: const SizedBox.expand(),
          ),
        ),
      ));

      const posDelta = Offset(0, 10);
      const negDelta = Offset(0, -10);

      await tester.drag(finder, posDelta);
      expect(slidableController.ratio, 0);

      await tester.drag(finder, negDelta);
      expect(slidableController.ratio, 0);

      await tester.drag(finder, negDelta);
      expect(slidableController.ratio, 0);
    });

    testWidgets('handleEndGesture should be called with the correct direction',
        (tester) async {
      double ratio = 0;
      when(mockSlidableController.ratio).thenAnswer((realInvocation) => ratio);
      when(mockSlidableController.ratio = any).thenAnswer((realInvocation) {
        ratio = realInvocation.positionalArguments[0] as double;
      });

      final mockActionPanelType = ValueNotifier(ActionPaneType.none);
      when(mockSlidableController.actionPaneType)
          .thenReturn(mockActionPanelType);

      await tester.pumpWidget(Center(
        child: SizedBox(
          height: 200,
          width: 100,
          child: SlidableGestureDetector(
            controller: mockSlidableController,
            direction: Axis.horizontal,
            child: const SizedBox.expand(),
          ),
        ),
      ));

      const posDelta = Offset(10, 0);
      const negDelta = Offset(-10, 0);
      const speed = 10.0;

      await tester.fling(finder, posDelta, speed);

      verify(mockSlidableController.dispatchEndGesture(
        any,
        GestureDirection.opening,
      ));

      await tester.fling(finder, negDelta, speed);

      verify(mockSlidableController.dispatchEndGesture(
        any,
        GestureDirection.closing,
      ));
    });
  });
}
