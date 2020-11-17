import 'package:flutter/material.dart';
import 'package:flutter_slidable/src/action_pane.dart';
import 'package:flutter_slidable/src/flex_exit_transition.dart';
import 'package:flutter_slidable/src/slidable.dart';

class DismissiblePaneTransition extends StatelessWidget {
  const DismissiblePaneTransition({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final pane = ActionPane.of(context);
    final style = ActionPaneStyle.of(context);
    final controller = Slidable.of(context);
    final animation = controller.animation
        .drive(CurveTween(curve: Interval(pane.extentRatio, 1)));

    return FlexExitTransition(
      mainAxisExtent: animation,
      initialExtentRatio: pane.extentRatio,
      direction: style.direction,
      fromStart: style.fromStart,
      children: pane.children,
    );
  }
}
