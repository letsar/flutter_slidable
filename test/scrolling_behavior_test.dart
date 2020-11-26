import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/src/scrolling_behavior.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'common.dart';

final mockSlidableController = MockSlidableController();

void main() {
  setUp(() {
    reset(mockSlidableController);
  });

  group('SlidableScrollingBehavior -', () {
    test('constructor asserts', () {
      final values = [
        mockSlidableController,
        true,
        const SizedBox(),
      ];

      testConstructorAsserts(
        values: values,
        factory: (valueOrNull) => SlidableScrollingBehavior(
          controller: valueOrNull(0),
          closeOnScroll: valueOrNull(1),
          child: valueOrNull(2),
        ),
      );
    });

    testWidgets('should build outside a Scrollable', (tester) async {
      await tester.pumpWidget(
        SlidableScrollingBehavior(
          controller: mockSlidableController,
          child: const SizedBox(),
        ),
      );
    });

    testWidgets(
        'should close the slidable when scrolling and closeOnScroll is true',
        (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListView.builder(
            itemCount: 10,
            itemExtent: 100,
            itemBuilder: (context, index) {
              if (index == 0) {
                return SlidableScrollingBehavior(
                  controller: mockSlidableController,
                  child: const SizedBox(),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      );

      verifyNever(mockSlidableController.close(
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ));

      await tester.drag(find.byType(ListView), const Offset(0, -250));

      verify(mockSlidableController.close(
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ));
    });

    testWidgets(
        'should not close the slidable when scrolling and closeOnScroll is false',
        (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListView.builder(
            itemCount: 10,
            itemExtent: 100,
            itemBuilder: (context, index) {
              if (index == 0) {
                return SlidableScrollingBehavior(
                  closeOnScroll: false,
                  controller: mockSlidableController,
                  child: const SizedBox(),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      );

      verifyNever(mockSlidableController.close(
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ));

      await tester.drag(find.byType(ListView), const Offset(0, -250));

      verifyNever(mockSlidableController.close(
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ));
    });

    testWidgets(
        'should not close the slidable when scrolling and closeOnScroll become false',
        (tester) async {
      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListView.builder(
            itemCount: 10,
            itemExtent: 100,
            itemBuilder: (context, index) {
              if (index == 0) {
                return SlidableScrollingBehavior(
                  controller: mockSlidableController,
                  child: const SizedBox(),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      );

      verifyNever(mockSlidableController.close(
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ));

      await tester.drag(find.byType(ListView), const Offset(0, -250));

      verify(mockSlidableController.close(
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ));

      clearInteractions(mockSlidableController);

      await tester.pumpWidget(
        Directionality(
          textDirection: TextDirection.ltr,
          child: ListView.builder(
            itemCount: 10,
            itemExtent: 100,
            itemBuilder: (context, index) {
              if (index == 0) {
                return SlidableScrollingBehavior(
                  closeOnScroll: false,
                  controller: mockSlidableController,
                  child: const SizedBox(),
                );
              }
              return const SizedBox();
            },
          ),
        ),
      );

      await tester.drag(find.byType(ListView), const Offset(0, -250));

      verifyNever(mockSlidableController.close(
        duration: anyNamed('duration'),
        curve: anyNamed('curve'),
      ));
    });
  });
}
