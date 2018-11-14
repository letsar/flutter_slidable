import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/src/widgets/slidable.dart';

const Duration _kResizeDuration = const Duration(milliseconds: 300);

/// A wiget that controls how the [Slidable] is dismissed.
///
/// The [Slidable] widget calls the [onDismissed] callback either after its size has
/// collapsed to zero (if [resizeDuration] is non-null) or immediately after
/// the slide animation (if [resizeDuration] is null). If the [Slidable] is a
/// list item, it must have a key that distinguishes it from the other items and
/// its [onDismissed] callback must remove the item from the list.
///
/// See also:
///
///  * [SlideToDismissDrawerDelegate], which creates slide actions that are displayed like drawers
///  while the item is dismissing.///
class SlidableDismissal extends StatelessWidget {
  const SlidableDismissal({
    @required this.dismissal,
    this.dismissThresholds = const <SlideActionType, double>{},
    this.onResize,
    this.onDismissed,
    this.resizeDuration = _kResizeDuration,
    this.crossAxisEndOffset = 0.0,
    this.onWillDismiss,
    this.closeOnCanceled = false,
  }) : assert(dismissThresholds != null);

  /// The offset threshold the item has to be dragged in order to be considered
  /// dismissed.
  ///
  /// Represented as a fraction, e.g. if it is 0.4 (the default), then the item
  /// has to be dragged at least 40% towards one direction to be considered
  /// dismissed. Clients can define different thresholds for each dismiss
  /// direction.
  ///
  /// Flinging is treated as being equivalent to dragging almost to 1.0, so
  /// flinging can dismiss an item past any threshold less than 1.0.
  ///
  /// Setting a threshold of 1.0 (or greater) prevents a drag for
  //  the given [SlideActionType]
  final Map<SlideActionType, double> dismissThresholds;

  /// Called when the widget has been dismissed, after finishing resizing.
  final DismissSlideActionCallback onDismissed;

  /// Called before the widget is dismissed. If the call returns false, the
  /// item will not be dismissed.
  ///
  /// If null, the widget will always be dismissed.
  final SlideActionWillBeDismissed onWillDismiss;

  /// Specifies to close this slidable after canceling dismiss.
  ///
  /// Defaults to false.
  final bool closeOnCanceled;

  /// Called when the widget changes size (i.e., when contracting before being dismissed).
  final VoidCallback onResize;

  /// The amount of time the widget will spend contracting before [onDismissed] is called.
  ///
  /// If null, the widget will not contract and [onDismissed] will be called
  /// immediately after the widget is dismissed.
  final Duration resizeDuration;

  /// Defines the end offset across the main axis after the card is dismissed.
  ///
  /// If non-zero value is given then widget moves in cross direction depending on whether
  /// it is positive or negative.
  final double crossAxisEndOffset;

  final Widget dismissal;

  Widget build(BuildContext context) {
    final SlidableState state = Slidable.of(context);

    return AnimatedBuilder(
      animation: state.overallMoveAnimation,
      builder: (BuildContext context, Widget child) {
        if (state.overallMoveAnimation.value > state.totalActionsExtent) {
          return dismissal;
        } else {
          return state.widget.actionPane;
        }
      },
    );
  }
}

/// A delegate that creates slide actions that are displayed like drawers
/// while the item is dismissing.
/// The further slide action will grow faster than the other ones.
class SlidableDrawerDismissal extends StatelessWidget {
  const SlidableDrawerDismissal({Key key}) : super(key: key);

  Widget build(BuildContext context) {
    final SlidableState state = Slidable.of(context);

    final alignment = state.alignment;
    final startOffset = Offset(alignment.x, alignment.y);
    final positions = Iterable.generate(state.actionCount).map((index) {
      return AlwaysStoppedAnimation(startOffset * (index - 1.0));
    }).toList();

    final positions2 = Iterable.generate(state.actionCount).map((index) {
      return Tween<Offset>(
        begin: startOffset * (index - 1.0),
        end: startOffset * (index - 1.0),
      ).animate(state.dismissAnimation);
    }).toList();

    final sizes = Iterable.generate(state.actionCount).map((index) {
      return Tween<double>(
        begin: state.widget.actionExtentRatio,
        end: 1.0 -
            state.widget.actionExtentRatio * (state.actionCount - index - 1),
      ).animate(state.dismissAnimation);
    }).toList();

    final animation = Tween<Offset>(
      begin: Offset.zero,
      end: state.createOffset(state.actionSign),
    ).animate(state.overallMoveAnimation);

    return Stack(
      children: <Widget>[
        Positioned.fill(
          child: Stack(
            alignment: state.alignment,
            children: List.generate(
              state.actionCount,
              (index) {
                int displayIndex =
                    state.showActions ? state.actionCount - index - 1 : index;
                return SlideTransition(
                  position: positions2[index],
                  child: SizeTransition(
                    sizeFactor: sizes[index],
                    axis: state.widget.direction,
                    child: state.actionDelegate.build(
                      context,
                      displayIndex,
                      state.actionsMoveAnimation,
                      SlidableRenderingMode.slide,
                    ),
                  ),
                );
              },
            ),
          ),
        ),
        SlideTransition(
          position: animation,
          child: state.widget.child,
        ),
      ],
    );

    // return Container(
    //   child: Stack(
    //     children: <Widget>[
    //       Positioned.fill(
    //         child: LayoutBuilder(builder: (context, constraints) {
    //           final count = state.actionCount;
    //           final double totalExtent = state.getMaxExtent(constraints);
    //           final double actionExtent =
    //               totalExtent * state.widget.actionExtentRatio;

    //           final extentAnimations = Iterable.generate(count).map((index) {
    //             return Tween<double>(
    //               begin: actionExtent,
    //               end: totalExtent -
    //                   (actionExtent * (state.actionCount - index - 1)),
    //             ).animate(
    //               CurvedAnimation(
    //                 parent: state.overallMoveAnimation,
    //                 curve: Interval(state.totalActionsExtent, 1.0),
    //               ),
    //             );
    //           }).toList();

    //           return AnimatedBuilder(
    //               animation: state.overallMoveAnimation,
    //               builder: (context, child) {
    //                 return Stack(
    //                   children: List.generate(state.actionCount, (index) {
    //                     // For the main actions we have to reverse the order if we want the last item at the bottom of the stack.
    //                     int displayIndex = state.showActions
    //                         ? state.actionCount - index - 1
    //                         : index;
    //                     return state.createPositioned(
    //                       position:
    //                           actionExtent * (state.actionCount - index - 1),
    //                       extent: extentAnimations[index].value,
    //                       child: state.actionDelegate.build(
    //                           context,
    //                           displayIndex,
    //                           state.actionsMoveAnimation,
    //                           state.renderingMode),
    //                     );
    //                   }),
    //                 );
    //               });
    //         }),
    //       ),
    //       SlideTransition(
    //         position: animation,
    //         child: state.widget.child,
    //       ),
    //     ],
    //   ),
    // );
  }
}
