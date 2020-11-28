import 'package:flutter/material.dart';
import 'package:flutter_slidable/src/controller.dart';
import 'package:flutter_slidable/src/dismissal_transition.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

// ignore_for_file: invalid_use_of_protected_member

void main() {
  group('DimissalTransition', () {
    test(
      'constructor asserts',
      () {
        final values = [
          Axis.horizontal,
          SlidableController(const TestVSync()),
          const SizedBox(),
        ];

        testConstructorAsserts(
          values: values,
          factory: (valueOrNull) => DismissalTransition(
            axis: valueOrNull(0),
            controller: valueOrNull(1),
            child: valueOrNull(2),
          ),
        );
      },
    );

    testWidgets('has 0 height when horizontal and dismissed', (tester) async {
      final slidableController = SlidableController(const TestVSync());

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox.shrink(
              child: DismissalTransition(
                axis: Axis.horizontal,
                controller: slidableController,
                child: const SizedBox(height: 100, width: 200),
              ),
            ),
          ),
        ),
      );

      slidableController.dismiss(ResizeRequest(
        const Duration(milliseconds: 300),
        () {},
      ));

      await tester.pumpAndSettle();
      final finder = find.byTypeOf<DismissalTransition>();
      expect(finder, findsOneWidget);
      expect(tester.getSize(finder).height, 0);
    });

    testWidgets('has 0 width when vertical and dismissed', (tester) async {
      final slidableController = SlidableController(const TestVSync());

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox.shrink(
              child: DismissalTransition(
                axis: Axis.vertical,
                controller: slidableController,
                child: const SizedBox(height: 200, width: 100),
              ),
            ),
          ),
        ),
      );

      slidableController.dismiss(ResizeRequest(
        const Duration(milliseconds: 300),
        () {},
      ));

      await tester.pumpAndSettle();
      final finder = find.byTypeOf<DismissalTransition>();
      expect(finder, findsOneWidget);
      expect(tester.getSize(finder).width, 0);
    });

    testWidgets('throws a FlutterError 0 if rebuilt after dissmissed',
        (tester) async {
      final slidableController = SlidableController(const TestVSync());

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox.shrink(
              child: DismissalTransition(
                axis: Axis.vertical,
                controller: slidableController,
                child: const SizedBox(height: 200, width: 100),
              ),
            ),
          ),
        ),
      );

      slidableController.dismiss(ResizeRequest(
        const Duration(milliseconds: 300),
        () {},
      ));

      await tester.pumpAndSettle();

      FlutterError flutterError;
      flutterError = tester.takeException() as FlutterError;
      expect(flutterError, isNull);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox.shrink(
              child: DismissalTransition(
                axis: Axis.vertical,
                controller: slidableController,
                child: const SizedBox(height: 200, width: 100),
              ),
            ),
          ),
        ),
      );

      flutterError = tester.takeException() as FlutterError;
      expect(flutterError, isNotNull);
    });

    testWidgets('listeners are correctly removed when updated', (tester) async {
      final slidableController1 = SlidableController(const TestVSync());
      final slidableController2 = SlidableController(const TestVSync());

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox.shrink(
              child: DismissalTransition(
                axis: Axis.vertical,
                controller: slidableController1,
                child: const SizedBox(height: 200, width: 100),
              ),
            ),
          ),
        ),
      );

      expect(slidableController1.resizeRequest.hasListeners, isTrue);
      expect(slidableController2.resizeRequest.hasListeners, isFalse);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: SizedBox.shrink(
              child: DismissalTransition(
                axis: Axis.vertical,
                controller: slidableController2,
                child: const SizedBox(height: 200, width: 100),
              ),
            ),
          ),
        ),
      );

      expect(slidableController1.resizeRequest.hasListeners, isFalse);
      expect(slidableController2.resizeRequest.hasListeners, isTrue);
    });
  });
}
