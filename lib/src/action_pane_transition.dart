import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_slidable/src/flex_entrance_transition.dart';

class SlidableBehindTransition extends StatelessWidget {
  const SlidableBehindTransition({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pane = ActionPane.of(context);
    final style = ActionPaneStyle.of(context);
    return Flex(
      direction: style.direction,
      children: pane.children,
    );
  }
}

class SlidableStretchTransition extends StatelessWidget {
  const SlidableStretchTransition({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pane = ActionPane.of(context);
    final style = ActionPaneStyle.of(context);
    final controller = Slidable.of(context);

    return AnimatedBuilder(
      animation: controller.animation,
      builder: (BuildContext context, Widget child) {
        final value = controller.animation.value / pane.extentRatio;

        return FractionallySizedBox(
          alignment: style.alignment,
          widthFactor: style.direction == Axis.horizontal ? value : null,
          heightFactor: style.direction == Axis.horizontal ? null : value,
          child: child,
        );
      },
      child: const SlidableBehindTransition(),
    );
  }
}

class SlidableScrollTransition extends StatelessWidget {
  const SlidableScrollTransition({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pane = ActionPane.of(context);
    final style = ActionPaneStyle.of(context);
    final controller = Slidable.of(context);

    // Each child starts just outside of the Slidable.
    final startOffset = Offset(style.alignment.x, style.alignment.y);

    final animation = controller.animation
        .drive(CurveTween(curve: Interval(0, pane.extentRatio)))
        .drive(Tween(begin: startOffset, end: Offset.zero));

    return SlideTransition(
      position: animation,
      child: const SlidableBehindTransition(),
    );
  }
}

class SlidableDrawerTransition extends StatelessWidget {
  const SlidableDrawerTransition({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pane = ActionPane.of(context);
    final style = ActionPaneStyle.of(context);
    final controller = Slidable.of(context);
    final animation = controller.animation
        .drive(CurveTween(curve: Interval(0, pane.extentRatio)));

    return FlexEntranceTransition(
      mainAxisPosition: animation,
      direction: style.direction,
      fromStart: style.fromStart,
      children: pane.children,
    );
  }
}
