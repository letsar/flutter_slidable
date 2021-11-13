import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/src/controller.dart';
import 'package:flutter_slidable/src/notifications_old.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'common.dart';

final mockSlidableController = MockSlidableController();

void main() {
  setUp(() {
    reset(mockSlidableController);
  });

  group('SlidableNotificationSender -', () {
    testWidgets(
      'should build outside of a SlidableNotificationListener',
      (tester) async {
        await tester.pumpWidget(
          SlidableNotificationSender(
            tag: null,
            controller: mockSlidableController,
            child: const SizedBox(),
          ),
        );
      },
    );
  });

  group('SlidableNotificationListener & SlidableNotificationSender -', () {
    testWidgets(
      'notifications are sent to SlidableNotificationListener',
      (tester) async {
        final notifications = <SlidableNotification>[];
        void handleNotification(SlidableNotification notification) {
          notifications.add(notification);
        }

        final controller = SlidableController(const TestVSync());

        await tester.pumpWidget(
          SlidableNotificationListener(
            onNotification: handleNotification,
            child: SlidableNotificationSender(
              tag: 'tag',
              controller: controller,
              child: const SizedBox(),
            ),
          ),
        );

        expect(notifications, <SlidableNotification>[]);

        controller.ratio = 0.2;
        expect(notifications, <SlidableNotification>[
          const SlidableRatioNotification(tag: 'tag', ratio: 0.2),
        ]);

        controller.ratio = 0.2;
        expect(notifications, <SlidableNotification>[
          const SlidableRatioNotification(tag: 'tag', ratio: 0.2),
        ]);

        controller.ratio = 0.1;
        expect(notifications, <SlidableNotification>[
          const SlidableRatioNotification(tag: 'tag', ratio: 0.2),
          const SlidableRatioNotification(tag: 'tag', ratio: 0.1),
        ]);
      },
    );

    testWidgets(
      'notifications are still sent to SlidableNotificationListener when widget tree changed',
      (tester) async {
        final notifications = <SlidableNotification>[];
        void handleNotification(SlidableNotification notification) {
          notifications.add(notification);
        }

        final controller = SlidableController(const TestVSync());

        await tester.pumpWidget(
          SlidableNotificationListener(
            onNotification: handleNotification,
            autoClose: false,
            child: SlidableNotificationSender(
              tag: 'tag',
              controller: controller,
              child: const SizedBox(),
            ),
          ),
        );

        expect(notifications, <SlidableNotification>[]);

        controller.ratio = 0.2;
        expect(notifications, <SlidableNotification>[
          const SlidableRatioNotification(tag: 'tag', ratio: 0.2),
        ]);

        controller.ratio = 0.2;
        expect(notifications, <SlidableNotification>[
          const SlidableRatioNotification(tag: 'tag', ratio: 0.2),
        ]);

        await tester.pumpWidget(
          SlidableNotificationListener(
            onNotification: handleNotification,
            autoClose: false,
            child: Builder(builder: (context) {
              return SlidableNotificationSender(
                tag: 'tag',
                controller: controller,
                child: const SizedBox(),
              );
            }),
          ),
        );

        controller.ratio = 0.1;
        expect(notifications, <SlidableNotification>[
          const SlidableRatioNotification(tag: 'tag', ratio: 0.2),
          const SlidableRatioNotification(tag: 'tag', ratio: 0.1),
        ]);

        await tester.pumpWidget(
          SlidableNotificationSender(
            tag: 'tag',
            controller: controller,
            child: const SizedBox(),
          ),
        );

        controller.ratio = 0.2;
        expect(notifications, <SlidableNotification>[
          const SlidableRatioNotification(tag: 'tag', ratio: 0.2),
          const SlidableRatioNotification(tag: 'tag', ratio: 0.1),
        ]);

        await tester.pumpWidget(
          SlidableNotificationListener(
            onNotification: handleNotification,
            autoClose: false,
            child: SlidableNotificationSender(
              tag: 'tag',
              controller: controller,
              child: const SizedBox(),
            ),
          ),
        );

        controller.ratio = 0.3;
        expect(notifications, <SlidableNotification>[
          const SlidableRatioNotification(tag: 'tag', ratio: 0.2),
          const SlidableRatioNotification(tag: 'tag', ratio: 0.1),
          const SlidableRatioNotification(tag: 'tag', ratio: 0.3),
        ]);

        await tester.pumpWidget(
          SlidableNotificationListener(
            onNotification: handleNotification,
            autoClose: false,
            child: const SizedBox(),
          ),
        );

        controller.ratio = 0.2;
        expect(notifications, <SlidableNotification>[
          const SlidableRatioNotification(tag: 'tag', ratio: 0.2),
          const SlidableRatioNotification(tag: 'tag', ratio: 0.1),
          const SlidableRatioNotification(tag: 'tag', ratio: 0.3),
        ]);
      },
    );

    testWidgets('can automatically close controllers', (tester) async {
      final controllers = List.generate(
        4,
        (index) => SlidableController(const TestVSync()),
      );

      await tester.pumpWidget(
        SlidableNotificationListener(
          child: Column(
            children: [
              ...controllers.map(
                (controller) => SlidableNotificationSender(
                  tag: 'tag',
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
        'when opening more than one slidables at the same time, only the last one stays open',
        (tester) async {
      final controllers = List.generate(
        4,
        (index) => SlidableController(const TestVSync()),
      );

      await tester.pumpWidget(
        SlidableNotificationListener(
          child: Column(
            children: [
              ...controllers.map(
                (controller) => SlidableNotificationSender(
                  tag: 'tag',
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

      expect(controllers[0].ratio, 0);
      expect(controllers[1].ratio, 0);
      expect(controllers[2].ratio, 0);
      expect(controllers[3].ratio, 0.5);
    });

    testWidgets('can have more than one group', (tester) async {
      final controllers = List.generate(
        4,
        (index) => SlidableController(const TestVSync()),
      );

      await tester.pumpWidget(
        SlidableNotificationListener(
          child: Column(
            children: [
              for (int i = 0; i < 4; i++)
                SlidableNotificationSender(
                  tag: i.isEven ? 'even' : 'odd',
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

      expect(controllers[0].ratio, 0);
      expect(controllers[1].ratio, 0);
      expect(controllers[2].ratio, 0.5);
      expect(controllers[3].ratio, 0.5);
    });

    testWidgets('prevent to reopen a closing slidable', (tester) async {
      final controllers = List.generate(
        4,
        (index) => SlidableController(const TestVSync()),
      );

      await tester.pumpWidget(
        SlidableNotificationListener(
          child: Column(
            children: [
              for (int i = 0; i < 4; i++)
                SlidableNotificationSender(
                  tag: 'tag',
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

      expect(controllers[0].ratio, 0);
      expect(controllers[1].ratio, 0.5);
    });
  });
}
