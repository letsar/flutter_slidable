import 'package:flutter/material.dart';
import 'package:flutter_slidable/src/actions.dart';
import 'package:flutter_test/flutter_test.dart';

import 'common.dart';

void main() {
  group('CustomSlidableAction', () {
    test('constructor asserts', () {
      final values = [
        true,
        Colors.black,
        1,
        const SizedBox(),
      ];

      testConstructorAsserts(
        values: values,
        factory: (valueOrNull) => CustomSlidableAction(
          onPressed: null,
          autoClose: valueOrNull(0),
          backgroundColor: valueOrNull(1),
          flex: valueOrNull(2),
          child: valueOrNull(3),
        ),
      );
    });

    testWidgets('can be pressed', (tester) async {
      final logs = <String>[];
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              CustomSlidableAction(
                onPressed: (_) => logs.add('pressed'),
                child: const SizedBox(),
              )
            ],
          ),
        ),
      );

      expect(logs, <String>[]);

      await tester.tap(find.byType(CustomSlidableAction));

      expect(logs, <String>['pressed']);
    });
  });

  group('SlidableAction', () {
    test('constructor asserts', () {
      final values = [
        true,
        Colors.black,
        1,
        4.0,
      ];

      testConstructorAsserts(
        values: values,
        factory: (valueOrNull) => SlidableAction(
          onPressed: null,
          autoClose: valueOrNull(0),
          backgroundColor: valueOrNull(1),
          flex: valueOrNull(2),
          spacing: valueOrNull(3),
          icon: Icons.ac_unit,
        ),
      );

      expect(() => SlidableAction(onPressed: null), throwsAssertionError);
    });

    testWidgets('can be pressed', (tester) async {
      final logs = <String>[];
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              SlidableAction(
                onPressed: (_) => logs.add('pressed'),
                label: 'label',
              )
            ],
          ),
        ),
      );

      expect(logs, <String>[]);

      await tester.tap(find.byType(CustomSlidableAction));

      expect(logs, <String>['pressed']);
    });

    testWidgets('can only have label', (tester) async {
      final logs = <String>[];
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              SlidableAction(
                onPressed: (_) => logs.add('pressed'),
                label: 'my_label',
              )
            ],
          ),
        ),
      );

      expect(find.text('my_label'), findsOneWidget);
    });

    testWidgets('can only have icon', (tester) async {
      final logs = <String>[];
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              SlidableAction(
                onPressed: (_) => logs.add('pressed'),
                icon: Icons.ac_unit,
              )
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
    });

    testWidgets('can have icon and label', (tester) async {
      final logs = <String>[];
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              SlidableAction(
                onPressed: (_) => logs.add('pressed'),
                icon: Icons.ac_unit,
                label: 'my_label',
              )
            ],
          ),
        ),
      );

      expect(find.byIcon(Icons.ac_unit), findsOneWidget);
      expect(find.text('my_label'), findsOneWidget);
    });
  });
}
