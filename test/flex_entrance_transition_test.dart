import 'package:flutter/material.dart';
import 'package:flutter_slidable/src/flex_entrance_transition.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlexEntranceTransition', () {
    testWidgets('children must have a non-zero flex', (tester) async {
      final controller = AnimationController(vsync: const TestVSync());

      await tester.pumpWidget(
        Center(
          child: SizedBox(
            height: 100,
            width: 100,
            child: FlexEntranceTransition(
              mainAxisPosition: controller,
              direction: Axis.horizontal,
              startToEnd: true,
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
