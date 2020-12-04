import 'package:flutter/material.dart';
import 'package:flutter_slidable/src/flex_exit_transition.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  group('FlexExitTransition', () {
    test(
      'constructor asserts',
      () {
        final values = [
          AnimationController(vsync: const TestVSync()),
          Axis.horizontal,
          true,
          0.5,
          [const SizedBox()],
        ];

        testConstructorAsserts(
          values: values,
          factory: (valueOrNull) => FlexExitTransition(
            mainAxisExtent: valueOrNull(0),
            direction: valueOrNull(1),
            startToEnd: valueOrNull(2),
            initialExtentRatio: valueOrNull(3),
            children: valueOrNull(4),
          ),
        );
      },
    );

    testWidgets('children must have a non-zero flex', (tester) async {
      final controller = AnimationController(vsync: const TestVSync());

      await tester.pumpWidget(
        Center(
          child: SizedBox(
            height: 100,
            width: 100,
            child: FlexExitTransition(
              mainAxisExtent: controller,
              direction: Axis.horizontal,
              startToEnd: true,
              initialExtentRatio: 0.5,
              children: const [
                SizedBox.expand(),
              ],
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNotNull);
    });
  });
}
