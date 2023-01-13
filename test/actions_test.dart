import 'package:flutter/material.dart';
import 'package:flutter_slidable/src/actions.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomSlidableAction', () {
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
                icon: Container(),
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
                icon: Container(),
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
