import 'package:flutter_slidable/src/actions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

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
    testWidgets('uses the material_ui theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            textTheme: const TextTheme(labelLarge: TextStyle(fontSize: 33)),
          ),
          home: Scaffold(
            body: Row(
              children: [
                SlidableAction(
                  onPressed: (_) {},
                  label: 'label',
                )
              ],
            ),
          ),
        ),
      );

      final textStyle = tester
          .widget<DefaultTextStyle>(
            find
                .ancestor(
                  of: find.text('label'),
                  matching: find.byType(DefaultTextStyle),
                )
                .first,
          )
          .style;

      expect(textStyle.fontSize, 33);
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

    testWidgets('merges labelStyle with the theme', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            textTheme: const TextTheme(labelLarge: TextStyle(fontSize: 33)),
          ),
          home: Scaffold(
            body: Row(
              children: [
                SlidableAction(
                  onPressed: (_) {},
                  label: 'label',
                  labelStyle: const TextStyle(fontStyle: FontStyle.italic),
                )
              ],
            ),
          ),
        ),
      );

      final textStyle = tester
          .widget<RichText>(
            find.descendant(
              of: find.byType(SlidableAction),
              matching: find.byType(RichText),
            ),
          )
          .text
          .style!;

      expect(textStyle.fontStyle, FontStyle.italic);
      expect(textStyle.fontSize, 33);
    });

    testWidgets('uses iconSize', (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: Row(
            children: [
              SlidableAction(
                onPressed: (_) {},
                icon: Icons.ac_unit,
                iconSize: 40,
              )
            ],
          ),
        ),
      );

      expect(tester.getSize(find.byIcon(Icons.ac_unit)), const Size(40, 40));
    });

    testWidgets('accepts a BorderRadiusDirectional', (tester) async {
      const borderRadius = BorderRadiusDirectional.only(
        topStart: Radius.circular(8),
      );

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.rtl,
          child: Row(
            children: [
              SlidableAction(
                onPressed: (_) {},
                label: 'label',
                borderRadius: borderRadius,
              )
            ],
          ),
        ),
      );

      final shape = tester
          .widget<OutlinedButton>(find.byType(OutlinedButton))
          .style!
          .shape!
          .resolve({})! as RoundedRectangleBorder;

      expect(shape.borderRadius, borderRadius);
    });
  });
}
