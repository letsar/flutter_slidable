import 'package:flutter/material.dart';

import 'action_pane.dart';
import 'flex_exit_transition.dart';
import 'slidable.dart';

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
