import 'package:flutter/widgets.dart';

import 'flex_entrance_transition.dart';
import 'slidable.dart';

/// An [ActionPane] motion which reveals actions as if they were behind the
/// [Slidable].
///
class BehindMotion extends StatelessWidget {
  /// Creates a [BehindMotion].
  ///
  /// {@animation 664 200 https://raw.githubusercontent.com/letsar/flutter_slidable/assets/behind_motion.mp4}
  const BehindMotion({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paneData = ActionPane.of(context)!;
    return Flex(
      direction: paneData.direction,
      children: paneData.children,
    );
  }
}

/// An [ActionPane] motion which reveals actions by stretching their extent
/// while sliding the [Slidable].
class StretchMotion extends StatelessWidget {
  /// Creates a [StretchMotion].
  ///
  /// {@animation 664 200 https://raw.githubusercontent.com/letsar/flutter_slidable/assets/stretch_motion.mp4}
  const StretchMotion({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paneData = ActionPane.of(context);
    final controller = Slidable.of(context)!;

    return AnimatedBuilder(
      animation: controller.animation,
      builder: (BuildContext context, Widget? child) {
        final value = controller.animation.value / paneData!.extentRatio;

        return FractionallySizedBox(
          alignment: paneData.alignment,
          widthFactor: paneData.direction == Axis.horizontal ? value : 1,
          heightFactor: paneData.direction == Axis.horizontal ? 1 : value,
          child: child,
        );
      },
      child: const BehindMotion(),
    );
  }
}

/// An [ActionPane] motion which reveals actions as if they were scrolling
/// from the outside.
class ScrollMotion extends StatelessWidget {
  /// Creates a [ScrollMotion].
  ///
  /// {@animation 664 200 https://raw.githubusercontent.com/letsar/flutter_slidable/assets/scroll_motion.mp4}
  const ScrollMotion({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paneData = ActionPane.of(context)!;
    final controller = Slidable.of(context)!;

    // Each child starts just outside of the Slidable.
    final startOffset = Offset(paneData.alignment.x, paneData.alignment.y);

    final animation = controller.animation
        .drive(CurveTween(curve: Interval(0, paneData.extentRatio)))
        .drive(Tween(begin: startOffset, end: Offset.zero));

    return SlideTransition(
      position: animation,
      child: const BehindMotion(),
    );
  }
}

/// An [ActionPane] motion which reveals actions as if they were drawers.
class DrawerMotion extends StatelessWidget {
  /// Creates a [DrawerMotion].
  ///
  /// {@animation 664 200 https://raw.githubusercontent.com/letsar/flutter_slidable/assets/drawer_motion.mp4}
  const DrawerMotion({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paneData = ActionPane.of(context)!;
    final controller = Slidable.of(context)!;
    final animation = controller.animation
        .drive(CurveTween(curve: Interval(0, paneData.extentRatio)));

    return FlexEntranceTransition(
      mainAxisPosition: animation,
      direction: paneData.direction,
      startToEnd: paneData.fromStart,
      children: paneData.children,
    );
  }
}
