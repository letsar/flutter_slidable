import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'action_pane.dart';
import 'flex_exit_transition.dart';
import 'slidable.dart';

/// A [DismissiblePane] motion which will make the furthest action grows faster
/// as the [Slidable] dismisses.
class InversedDrawerMotion extends StatelessWidget {
  /// Creates a [InversedDrawerMotion].
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
