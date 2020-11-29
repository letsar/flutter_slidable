import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'action_pane.dart';
import 'flex_entrance_transition.dart';
import 'slidable.dart';

/// An [ActionPane] transition which reveals actions as if they were behind the
/// [Slidable].
class SlidableBehindTransition extends StatelessWidget {
  /// Creates a [SlidableBehindTransition].
  const SlidableBehindTransition({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paneData = ActionPane.of(context);
    return Flex(
      direction: paneData.direction,
      children: paneData.children,
    );
  }
}

/// An [ActionPane] transition which reveals actions by stretching their extent
/// while sliding the [Slidable].
class SlidableStretchTransition extends StatelessWidget {
  /// Creates a [SlidableStretchTransition].
  const SlidableStretchTransition({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paneData = ActionPane.of(context);
    final controller = Slidable.of(context);

    return AnimatedBuilder(
      animation: controller.animation,
      builder: (BuildContext context, Widget child) {
        final value = controller.animation.value / paneData.extentRatio;

        return FractionallySizedBox(
          alignment: paneData.alignment,
          widthFactor: paneData.direction == Axis.horizontal ? value : null,
          heightFactor: paneData.direction == Axis.horizontal ? null : value,
          child: child,
        );
      },
      child: const SlidableBehindTransition(),
    );
  }
}

/// An [ActionPane] transition which reveals actions as if they were scrolling
/// from the outside.
class SlidableScrollTransition extends StatelessWidget {
  /// Creates a [SlidableScrollTransition].
  const SlidableScrollTransition({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paneData = ActionPane.of(context);
    final controller = Slidable.of(context);

    // Each child starts just outside of the Slidable.
    final startOffset = Offset(paneData.alignment.x, paneData.alignment.y);

    final animation = controller.animation
        .drive(CurveTween(curve: Interval(0, paneData.extentRatio)))
        .drive(Tween(begin: startOffset, end: Offset.zero));

    return SlideTransition(
      position: animation,
      child: const SlidableBehindTransition(),
    );
  }
}

/// An [ActionPane] transition which reveals actions as if they were drawers.
class SlidableDrawerTransition extends StatelessWidget {
  /// Creates a [SlidableDrawerTransition].
  const SlidableDrawerTransition({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paneData = ActionPane.of(context);
    final controller = Slidable.of(context);
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
