import 'package:flutter/gestures.dart';
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
      double? ratio = 0;
      when(() => mockSlidableController.ratio)
          .thenAnswer((realInvocation) => ratio!);
      when(() => mockSlidableController.ratio = any())
          .thenAnswer((realInvocation) {
        ratio = realInvocation.positionalArguments[0] as double?;
        return ratio!;
      });

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
        () => mockSlidableController.dispatchEndGesture(
          any(),
          GestureDirection.opening,
        ),
      );

      await tester.fling(finder, negDelta, speed);

      verify(
        () => mockSlidableController.dispatchEndGesture(
          any(),
          GestureDirection.closing,
        ),
      );
    });

    testWidgets('cannot slide horizontally when drag is predominantly vertical',
        (tester) async {
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

      final gesture = await tester.startGesture(tester.getCenter(finder));
      await gesture.moveBy(const Offset(20, 30));
      await tester.pump();
      expect(slidableController.ratio, 0);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(slidableController.ratio, 0);
    });

    testWidgets('can slide horizontally when drag is predominantly horizontal',
        (tester) async {
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

      final gesture = await tester.startGesture(tester.getCenter(finder));
      await gesture.moveBy(const Offset(30, 10));
      await tester.pump();
      expect(slidableController.ratio, 0.3);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets('cannot slide vertically when drag is predominantly horizontal',
        (tester) async {
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

      final gesture = await tester.startGesture(tester.getCenter(finder));
      await gesture.moveBy(const Offset(30, 20));
      await tester.pump();
      expect(slidableController.ratio, 0);

      await gesture.up();
      await tester.pumpAndSettle();
      expect(slidableController.ratio, 0);
    });

    testWidgets('can slide vertically when drag is predominantly vertical',
        (tester) async {
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

      final gesture = await tester.startGesture(tester.getCenter(finder));
      await gesture.moveBy(const Offset(10, 30));
      await tester.pump();
      expect(slidableController.ratio, 0.3);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'multi-pointer: second finger moving vertically does not corrupt active horizontal drag',
        (tester) async {
      final slidableController = SlidableController(const TestVSync());

      await tester.pumpWidget(Center(
        child: SizedBox(
          height: 100,
          width: 200,
          child: SlidableGestureDetector(
            controller: slidableController,
            direction: Axis.horizontal,
            child: const SizedBox.expand(),
          ),
        ),
      ));

      final center = tester.getCenter(finder);
      final gesture1 = await tester.startGesture(center);
      await gesture1.moveBy(const Offset(40, 0));
      await tester.pump();
      expect(slidableController.ratio, 0.2);

      final gesture2 =
          await tester.startGesture(center + const Offset(10, 10), pointer: 2);
      await tester.pump();

      // Finger 2 moves vertically and gets rejected.
      await gesture2.moveBy(const Offset(0, 30));
      await tester.pump();

      // Finger 1 continues horizontal drag.
      await gesture1.moveBy(const Offset(40, 0));
      await tester.pump();
      expect(slidableController.ratio, 0.4);

      await gesture2.up();
      await gesture1.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'multi-pointer: first finger moving vertically is rejected, second finger moving horizontally drags',
        (tester) async {
      final slidableController = SlidableController(const TestVSync());

      await tester.pumpWidget(Center(
        child: SizedBox(
          height: 100,
          width: 200,
          child: SlidableGestureDetector(
            controller: slidableController,
            direction: Axis.horizontal,
            child: const SizedBox.expand(),
          ),
        ),
      ));

      final center = tester.getCenter(finder);
      final gesture1 = await tester.startGesture(center, pointer: 1);
      // Finger 1 moves vertically -> rejected.
      await gesture1.moveBy(const Offset(0, 40));
      await tester.pump();
      expect(slidableController.ratio, 0);

      // Finger 2 touches down and moves horizontally -> accepted.
      final gesture2 =
          await tester.startGesture(center + const Offset(10, 10), pointer: 2);
      await gesture2.moveBy(const Offset(40, 0));
      await tester.pump();
      expect(slidableController.ratio, 0.2);

      await gesture1.up();
      await gesture2.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'multi-pointer: second finger dragging horizontally continues drag, and lifting finger 2 hands back to finger 1',
        (tester) async {
      final slidableController = SlidableController(const TestVSync());

      await tester.pumpWidget(Center(
        child: SizedBox(
          height: 100,
          width: 200,
          child: SlidableGestureDetector(
            controller: slidableController,
            direction: Axis.horizontal,
            child: const SizedBox.expand(),
          ),
        ),
      ));

      final center = tester.getCenter(finder);
      final gesture1 = await tester.startGesture(center, pointer: 1);
      await gesture1.moveBy(const Offset(40, 0));
      await tester.pump();
      expect(slidableController.ratio, 0.2);

      // Finger 2 joins and drags horizontally.
      final gesture2 =
          await tester.startGesture(center + const Offset(10, 10), pointer: 2);
      await gesture2.moveBy(const Offset(40, 0));
      await tester.pump();
      expect(slidableController.ratio, 0.4);

      // Finger 2 lifts up.
      await gesture2.up();
      await tester.pump();

      // Finger 1 moves further horizontally.
      await gesture1.moveBy(const Offset(40, 0));
      await tester.pump();
      expect(slidableController.ratio, 0.6);

      await gesture1.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'transformed: RotatedBox quarterTurns 1 dragging along local horizontal axis slides Slidable',
        (tester) async {
      final slidableController = SlidableController(const TestVSync());

      await tester.pumpWidget(Center(
        child: RotatedBox(
          quarterTurns: 1,
          child: SizedBox(
            height: 100,
            width: 200,
            child: SlidableGestureDetector(
              controller: slidableController,
              direction: Axis.horizontal,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ));

      // With 1 quarter turn (90 deg clockwise), local horizontal (width 200) points global down (+Y).
      final gesture = await tester.startGesture(tester.getCenter(finder));
      await gesture.moveBy(const Offset(0, 60));
      await tester.pump();
      expect(slidableController.ratio, 0.3);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'transformed: RotatedBox quarterTurns 1 dragging along local vertical axis does not slide',
        (tester) async {
      final slidableController = SlidableController(const TestVSync());

      await tester.pumpWidget(Center(
        child: RotatedBox(
          quarterTurns: 1,
          child: SizedBox(
            height: 100,
            width: 200,
            child: SlidableGestureDetector(
              controller: slidableController,
              direction: Axis.horizontal,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ));

      // Local vertical is global horizontal.
      final gesture = await tester.startGesture(tester.getCenter(finder));
      await gesture.moveBy(const Offset(60, 0));
      await tester.pump();
      expect(slidableController.ratio, 0);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'transformed: Transform.scale dragging along local horizontal axis slides Slidable',
        (tester) async {
      final slidableController = SlidableController(const TestVSync());

      await tester.pumpWidget(Center(
        child: Transform.scale(
          scale: 2,
          child: SizedBox(
            height: 100,
            width: 100,
            child: SlidableGestureDetector(
              controller: slidableController,
              direction: Axis.horizontal,
              child: const SizedBox.expand(),
            ),
          ),
        ),
      ));

      final gesture = await tester.startGesture(tester.getCenter(finder));
      // With scale 2.0, moving global 40 is local 20. 20 / 100 = 0.2.
      await gesture.moveBy(const Offset(40, 0));
      await tester.pump();
      expect(slidableController.ratio, 0.2);

      await gesture.up();
      await tester.pumpAndSettle();
    });

    testWidgets(
        'trackpad: horizontal PointerPanZoom slides horizontal Slidable',
        (tester) async {
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

      final center = tester.getCenter(finder);
      final trackpad = TestPointer(1, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(trackpad.panZoomStart(center));
      await tester.sendEventToBinding(
          trackpad.panZoomUpdate(center, pan: const Offset(30, 5)));
      await tester.pump();
      expect(slidableController.ratio, 0.3);

      await tester.sendEventToBinding(trackpad.panZoomEnd());
      await tester.pumpAndSettle();
    });

    testWidgets(
        'trackpad: vertical PointerPanZoom does not slide horizontal Slidable',
        (tester) async {
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

      final center = tester.getCenter(finder);
      final trackpad = TestPointer(1, PointerDeviceKind.trackpad);
      await tester.sendEventToBinding(trackpad.panZoomStart(center));
      await tester.sendEventToBinding(
          trackpad.panZoomUpdate(center, pan: const Offset(5, 30)));
      await tester.pump();
      expect(slidableController.ratio, 0);

      await tester.sendEventToBinding(trackpad.panZoomEnd());
      await tester.pumpAndSettle();
    });
  });
}
