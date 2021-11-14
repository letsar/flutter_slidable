import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_slidable/src/auto_close_behavior.dart';
import 'package:flutter_slidable/src/controller.dart';
import 'package:flutter_slidable/src/notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'common.dart';

final mockSlidableController = MockSlidableController();

void main() {
  setUp(() {
    reset(mockSlidableController);
    when(() => mockSlidableController.animation)
        .thenReturn(const AlwaysStoppedAnimation(0));
  });

  group('SlidableAutoCloseNotificationSender -', () {
    testWidgets(
      'should build outside of a SlidableAutoCloseBehavior',
      (tester) async {
        await tester.pumpWidget(
          SlidableAutoCloseInteractor(
            groupTag: null,
            controller: mockSlidableController,
            child: const SizedBox(),
          ),
        );
      },
    );
  });

  group('SlidableGroupBehaviorListener & SlidableAutoCloseNotificationSender -',
      () {
    testWidgets(
      'notifications are sent to SlidableGroupBehaviorListener',
      (tester) async {
        final notifications = <SlidableAutoCloseNotification>[];
        void handleNotification(SlidableAutoCloseNotification notification) {
          notifications.add(notification);
        }

        final controller = SlidableController(const TestVSync());

        await tester.pumpWidget(
          SlidableAutoCloseBehavior(
            child: SlidableGroupBehaviorListener<SlidableAutoCloseNotification>(
              onNotification: handleNotification,
              child: SlidableAutoCloseNotificationSender(
                groupTag: 'tag',
                controller: controller,
                child: const SizedBox(),
              ),
            ),
          ),
        );

        expect(notifications, <SlidableAutoCloseNotification>[]);

        controller.ratio = 0.2;
        expect(notifications.length, 1);

        controller.ratio = 0.2;
        expect(notifications.length, 1);

        controller.ratio = 0.1;
        expect(notifications.length, 1);
      },
    );

    testWidgets(
      'notifications are still sent to SlidableGroupBehaviorListener when widget tree changed',
      (tester) async {
        final notifications = <SlidableAutoCloseNotification>[];
        void handleNotification(SlidableAutoCloseNotification notification) {
          notifications.add(notification);
        }

        final controller = SlidableController(const TestVSync());

        await tester.pumpWidget(
          SlidableAutoCloseBehavior(
            child: SlidableGroupBehaviorListener<SlidableAutoCloseNotification>(
              onNotification: handleNotification,
              child: SlidableAutoCloseNotificationSender(
                groupTag: 'tag',
                controller: controller,
                child: const SizedBox(),
              ),
            ),
          ),
        );

        expect(notifications, <SlidableAutoCloseNotification>[]);

        controller.ratio = 0.2;
        expect(notifications.length, 1);

        controller.ratio = 0.2;
        expect(notifications.length, 1);

        await tester.pumpWidget(
          SlidableAutoCloseBehavior(
            child: SlidableGroupBehaviorListener<SlidableAutoCloseNotification>(
              onNotification: handleNotification,
              child: Builder(builder: (context) {
                return SlidableAutoCloseNotificationSender(
                  groupTag: 'tag',
                  controller: controller,
                  child: const SizedBox(),
                );
              }),
            ),
          ),
        );

        controller.ratio = 0.1;
        expect(notifications.length, 1);

        await tester.pumpWidget(
          SlidableAutoCloseNotificationSender(
            groupTag: 'tag',
            controller: controller,
            child: const SizedBox(),
          ),
        );

        controller.ratio = 0.2;
        expect(notifications.length, 1);

        await tester.pumpWidget(
          SlidableAutoCloseBehavior(
            child: SlidableGroupBehaviorListener<SlidableAutoCloseNotification>(
              onNotification: handleNotification,
              child: SlidableAutoCloseNotificationSender(
                groupTag: 'tag',
                controller: controller,
                child: const SizedBox(),
              ),
            ),
          ),
        );

        controller.ratio = 0.3;
        expect(notifications.length, 1);

        await tester.pumpWidget(
          SlidableGroupBehaviorListener<SlidableAutoCloseNotification>(
            onNotification: handleNotification,
            child: const SizedBox(),
          ),
        );

        controller.ratio = 0.2;
        expect(notifications.length, 1);
      },
    );

    testWidgets('can automatically close controllers', (tester) async {
      final controllers = List.generate(
        4,
        (index) => SlidableController(const TestVSync()),
      );

      await tester.pumpWidget(
        SlidableAutoCloseBehavior(
          child: Column(
            children: [
              ...controllers.map(
                (controller) => SlidableAutoCloseInteractor(
                  groupTag: 'tag',
                  controller: controller,
                  child: const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      );

      const duration = Duration(milliseconds: 100);

      controllers[0].openTo(0.5, duration: duration);
      await tester.pumpAndSettle();

      expect(controllers[0].ratio, 0.5);

      controllers[1].openTo(0.5, duration: duration);
      await tester.pumpAndSettle();

      expect(controllers[0].ratio, 0);
      expect(controllers[1].ratio, 0.5);

      controllers[0].openTo(0.5, duration: duration);
      await tester.pumpAndSettle();

      expect(controllers[0].ratio, 0.5);
      expect(controllers[1].ratio, 0);
    });

    testWidgets(
        'when opening more than one slidables at the same time, only the first one stays open',
        (tester) async {
      final controllers = List.generate(
        4,
        (index) => SlidableController(const TestVSync()),
      );

      await tester.pumpWidget(
        SlidableAutoCloseBehavior(
          child: Column(
            children: [
              ...controllers.map(
                (controller) => SlidableAutoCloseInteractor(
                  groupTag: 'tag',
                  controller: controller,
                  child: const SizedBox(),
                ),
              ),
            ],
          ),
        ),
      );

      const duration = Duration(milliseconds: 100);

      controllers[0].openTo(0.5, duration: duration);
      controllers[1].openTo(0.5, duration: duration);
      controllers[2].openTo(0.5, duration: duration);
      controllers[3].openTo(0.5, duration: duration);
      await tester.pumpAndSettle();

      expect(controllers[0].ratio, 0.5);
      expect(controllers[1].ratio, 0);
      expect(controllers[2].ratio, 0);
      expect(controllers[3].ratio, 0);
    });

    testWidgets('can have more than one group', (tester) async {
      final controllers = List.generate(
        4,
        (index) => SlidableController(const TestVSync()),
      );

      await tester.pumpWidget(
        SlidableAutoCloseBehavior(
          child: Column(
            children: [
              for (int i = 0; i < 4; i++)
                SlidableAutoCloseInteractor(
                  groupTag: i.isEven ? 'even' : 'odd',
                  controller: controllers[i],
                  child: const SizedBox(),
                ),
            ],
          ),
        ),
      );

      const duration = Duration(milliseconds: 100);

      controllers[0].openTo(0.5, duration: duration);
      controllers[1].openTo(0.5, duration: duration);
      controllers[2].openTo(0.5, duration: duration);
      controllers[3].openTo(0.5, duration: duration);
      await tester.pumpAndSettle();

      expect(controllers[0].ratio, 0.5);
      expect(controllers[1].ratio, 0.5);
      expect(controllers[2].ratio, 0);
      expect(controllers[3].ratio, 0);
    });

    testWidgets('prevent to reopen a closing slidable', (tester) async {
      final controllers = List.generate(
        4,
        (index) => SlidableController(const TestVSync()),
      );

      await tester.pumpWidget(
        SlidableAutoCloseBehavior(
          child: Column(
            children: [
              for (int i = 0; i < 4; i++)
                SlidableAutoCloseInteractor(
                  groupTag: 'tag',
                  controller: controllers[i],
                  child: const SizedBox(),
                ),
            ],
          ),
        ),
      );

      const duration = Duration(milliseconds: 100);

      controllers[0].openTo(0.5, duration: duration);
      controllers[1].openTo(0.5, duration: duration);
      controllers[0].ratio = 0.5;
      await tester.pumpAndSettle();

      expect(controllers[0].ratio, 0.5);
      expect(controllers[1].ratio, 0);
    });
  });

  testWidgets(
      'when a Slidable is tapped while another is opened, all the group are closed',
      (tester) async {
    final controllers = List.generate(
      4,
      (index) => SlidableController(const TestVSync()),
    );

    await tester.pumpWidget(
      SlidableAutoCloseBehavior(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...controllers.mapIndexed(
              (index, controller) => SlidableAutoCloseBehaviorInteractor(
                key: ValueKey('tag_$index'),
                groupTag: 'tag',
                controller: controller,
                child: Container(height: 40, width: 100, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );

    const duration = Duration(milliseconds: 100);
    controllers[1].openTo(0.5, duration: duration);
    await tester.pumpAndSettle();

    expect(controllers[0].ratio, 0);
    expect(controllers[1].ratio, 0.5);
    expect(controllers[2].ratio, 0);
    expect(controllers[3].ratio, 0);

    await tester.tap(find.byKey(const ValueKey('tag_0')));
    await tester.pumpAndSettle();

    expect(controllers[0].ratio, 0);
    expect(controllers[1].ratio, 0);
    expect(controllers[2].ratio, 0);
    expect(controllers[3].ratio, 0);
  });

  testWidgets(
      "when the Slidable's child is tapped while it is opened, it is automatically closed",
      (tester) async {
    final controllers = List.generate(
      4,
      (index) => SlidableController(const TestVSync()),
    );

    await tester.pumpWidget(
      SlidableAutoCloseBehavior(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...controllers.mapIndexed(
              (index, controller) => SlidableAutoCloseBehaviorInteractor(
                key: ValueKey('tag_$index'),
                groupTag: 'tag',
                controller: controller,
                child: Container(height: 40, width: 100, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );

    const duration = Duration(milliseconds: 100);
    controllers[1].openTo(0.5, duration: duration);
    await tester.pumpAndSettle();

    expect(controllers[0].ratio, 0);
    expect(controllers[1].ratio, 0.5);
    expect(controllers[2].ratio, 0);
    expect(controllers[3].ratio, 0);

    await tester.tap(find.byKey(const ValueKey('tag_1')));
    await tester.pumpAndSettle();

    expect(controllers[0].ratio, 0);
    expect(controllers[1].ratio, 0);
    expect(controllers[2].ratio, 0);
    expect(controllers[3].ratio, 0);
  });

  testWidgets(
      'GestureDetector onTap callback is called on the child only if not opened',
      (tester) async {
    final List<int> tapped = [];

    final controllers = List.generate(
      4,
      (index) => SlidableController(const TestVSync()),
    );

    await tester.pumpWidget(
      SlidableAutoCloseBehavior(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...controllers.mapIndexed(
              (index, controller) => SlidableAutoCloseBehaviorInteractor(
                key: ValueKey('tag_$index'),
                groupTag: 'tag',
                controller: controller,
                child: GestureDetector(
                  onTap: () => tapped.add(index),
                  child: Container(height: 40, width: 100, color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );

    const duration = Duration(milliseconds: 100);
    controllers[1].openTo(0.5, duration: duration);
    await tester.pumpAndSettle();

    expect(controllers[0].ratio, 0);
    expect(controllers[1].ratio, 0.5);
    expect(controllers[2].ratio, 0);
    expect(controllers[3].ratio, 0);

    await tester.tap(find.byKey(const ValueKey('tag_1')));
    await tester.pumpAndSettle();
    expect(controllers[0].ratio, 0);
    expect(controllers[1].ratio, 0);
    expect(controllers[2].ratio, 0);
    expect(controllers[3].ratio, 0);
    expect(tapped, isEmpty);

    await tester.tap(find.byKey(const ValueKey('tag_1')));
    await tester.pumpAndSettle();
    expect(tapped, [1]);
  });
}
