import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/src/controller.dart';
import 'package:flutter_slidable/src/gesture_detector.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'common.dart';

final mockSlidableController = MockSlidableController();
final finder = find.byTypeOf<SlidableGestureDetector>();

void main() {
  setUp(() {
    reset(mockSlidableController);
  });

  group('SlidableGestureDetector -', () {
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
      when(() => mockSlidableController.movementRatio).thenReturn(0);

      final mockDirection = ValueNotifier(0);
      when(() => mockSlidableController.direction).thenReturn(mockDirection);

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

      verify(
        () => mockSlidableController.endDrag(
          any(),
          GestureDirection.opening,
        ),
      );

      await tester.fling(finder, negDelta, speed);

      verify(
        () => mockSlidableController.endDrag(
          any(),
          GestureDirection.closing,
        ),
      );
    });

    group('inside a vertical scrollable -', () {
      late SlidableController slidableController;
      late ScrollController scrollController;

      Future<void> pumpList(WidgetTester tester) async {
        slidableController = SlidableController(const TestVSync());
        scrollController = ScrollController();
        addTearDown(slidableController.dispose);
        addTearDown(scrollController.dispose);

        await tester.pumpWidget(Directionality(
          textDirection: TextDirection.ltr,
          child: ListView(
            controller: scrollController,
            children: [
              SizedBox(
                height: 100,
                child: SlidableGestureDetector(
                  controller: slidableController,
                  direction: Axis.horizontal,
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 2000),
            ],
          ),
        ));
      }

      testWidgets('a mostly vertical diagonal drag scrolls the list',
          (tester) async {
        await pumpList(tester);

        // Both components exceed the touch slop within the same event.
        final gesture = await tester.startGesture(tester.getCenter(finder));
        await gesture.moveBy(const Offset(30, -40));
        await gesture.moveBy(const Offset(10, -20));
        await gesture.up();
        await tester.pump();

        expect(slidableController.ratio, 0);
        expect(scrollController.offset, greaterThan(0));
      });

      testWidgets('a mostly horizontal diagonal drag slides', (tester) async {
        await pumpList(tester);

        final gesture = await tester.startGesture(tester.getCenter(finder));
        await gesture.moveBy(const Offset(40, -30));
        await gesture.moveBy(const Offset(20, -10));
        await gesture.up();
        await tester.pump();

        expect(slidableController.ratio, isNot(0));
        expect(scrollController.offset, 0);
      });
    });
  });
}
