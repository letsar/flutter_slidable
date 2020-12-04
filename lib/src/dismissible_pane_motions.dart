import 'package:flutter/material.dart';

import 'action_pane.dart';
import 'flex_exit_transition.dart';
import 'slidable.dart';

class InversedDrawerMotion extends StatelessWidget {
  const InversedDrawerMotion({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final paneData = ActionPane.of(context);
    final controller = Slidable.of(context);
    final animation = controller.animation
        .drive(CurveTween(curve: Interval(paneData.extentRatio, 1)));

    return FlexExitTransition(
      mainAxisExtent: animation,
      initialExtentRatio: paneData.extentRatio,
      direction: paneData.direction,
      startToEnd: paneData.fromStart,
      children: paneData.children,
    );
  }
}
