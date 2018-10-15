import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const double _kActionsExtentRatio = 0.25;
const double _kFastThreshold = 2500.0;
const double _kDismissThreshold = 0.75;
const Curve _kResizeTimeCurve = const Interval(0.4, 1.0, curve: Curves.ease);
const Duration _kResizeDuration = const Duration(milliseconds: 300);
const Duration _kMovementDuration = const Duration(milliseconds: 200);

/// The rendering mode in which the [Slidable] is.
enum SlidableRenderingMode {
  /// The [Slidable] is not showing actions.
  none,

  /// The [Slidable] is showing actions during sliding.
  slide,

  /// The [Slidable] is showing actions during dismissing.
  dismiss,

  /// The [Slidable] is resizing after dismissing.
  resize,
}

/// The type of slide action that is currently been showed by the [Slidable].
enum SlideActionType {
  /// The [actions] are being shown.
  primary,

  /// The [secondaryActions] are being shown.
  secondary,
}

/// Signature used by [SlideToDismissDelegate] to indicate that it has been
/// dismissed for the given [actionType].
///
/// Used by [SlideToDismissDelegate.onDismissed].
typedef void DismissSlideActionCallback(SlideActionType actionType);

/// Signature for determining whether the widget will be dismissed for the
/// given [actionType].
///
/// Used by [SlideToDismissDelegate.onWillDismiss].
typedef FutureOr<bool> SlideActionWillBeDismissed(SlideActionType actionType);

/// Signature for the builder callback used to create slide actions.
typedef Widget SlideActionBuilder(BuildContext context, int index,
    Animation<double> animation, SlidableRenderingMode step);

/// A delegate that controls how the [Slidable] is dismissed.
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
abstract class SlideToDismissDelegate {
  const SlideToDismissDelegate({
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

  Widget buildActions(BuildContext context, SlidableDelegateContext ctx,
      SlidableDelegate slidableDelegate) {
    if (ctx.state.overallMoveAnimation.value > ctx.state.totalActionsExtent) {
      return buildActionsWhileDismissing(context, ctx);
    } else {
      return slidableDelegate.buildActions(context, ctx);
    }
  }

  Widget buildActionsWhileDismissing(
      BuildContext context, SlidableDelegateContext ctx);
}

/// A delegate that creates slide actions that are displayed like drawers
/// while the item is dismissing.
/// The further slide action will grow faster than the other ones.
class SlideToDismissDrawerDelegate extends SlideToDismissDelegate {
  const SlideToDismissDrawerDelegate({
    Map<SlideActionType, double> dismissThresholds:
        const <SlideActionType, double>{},
    VoidCallback onResize,
    DismissSlideActionCallback onDismissed,
    Duration resizeDuration = _kResizeDuration,
    double crossAxisEndOffset = 0.0,
    SlideActionWillBeDismissed onWillDismiss,
    bool closeOnCanceled = false,
  }) : super(
          dismissThresholds: dismissThresholds,
          onResize: onResize,
          onDismissed: onDismissed,
          resizeDuration: resizeDuration,
          crossAxisEndOffset: crossAxisEndOffset,
          onWillDismiss: onWillDismiss,
          closeOnCanceled: closeOnCanceled,
        );

  Widget buildActionsWhileDismissing(
      BuildContext context, SlidableDelegateContext ctx) {
    final animation = new Tween(
      begin: Offset.zero,
      end: ctx.createOffset(ctx.state.dragSign),
    ).animate(ctx.state.overallMoveAnimation);

    return new Container(
      child: new Stack(
        children: <Widget>[
          new Positioned.fill(
            child: new LayoutBuilder(builder: (context, constraints) {
              final count = ctx.state.actionCount;
              final double actionExtent = ctx.getMaxExtent(constraints) *
                  ctx.state.widget.actionExtentRatio;
              final double totalExtent = ctx.getMaxExtent(constraints);

              final extentAnimations = Iterable.generate(count).map((index) {
                return new Tween(
                  begin: actionExtent,
                  end: totalExtent -
                      (actionExtent * (ctx.state.actionCount - index - 1)),
                ).animate(
                  new CurvedAnimation(
                    parent: ctx.state.overallMoveAnimation,
                    curve: new Interval(ctx.state.totalActionsExtent, 1.0),
                  ),
                );
              }).toList();

              return new AnimatedBuilder(
                  animation: ctx.state.overallMoveAnimation,
                  builder: (context, child) {
                    return new Stack(
                      children: List.generate(ctx.state.actionCount, (index) {
                        // For the main actions we have to reverse the order if we want the last item at the bottom of the stack.
                        int displayIndex = ctx.showActions
                            ? ctx.state.actionCount - index - 1
                            : index;
                        return ctx.createPositioned(
                          position: actionExtent *
                              (ctx.state.actionCount - index - 1),
                          extent: extentAnimations[index].value,
                          child: ctx.state.actionDelegate.build(
                              context,
                              displayIndex,
                              ctx.state.overallMoveAnimation,
                              ctx.state.renderingMode),
                        );
                      }),
                    );
                  });
            }),
          ),
          new SlideTransition(
            position: animation,
            child: ctx.state.widget.child,
          ),
        ],
      ),
    );
  }
}

/// A delegate that supplies slide actions.
///
/// It's uncommon to subclass [SlideActionDelegate]. Instead, consider using one
/// of the existing subclasses that provide adaptors to builder callbacks or
/// explicit action lists.
///
/// See also:
///
///  * [SlideActionBuilderDelegate], which is a delegate that uses a builder
///    callback to construct the slide actions.
///  * [SlideActionListDelegate], which is a delegate that has an explicit list
///    of slidable action.
abstract class SlideActionDelegate {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const SlideActionDelegate();

  /// Returns the child with the given index.
  ///
  /// Must not return null.
  Widget build(BuildContext context, int index, Animation<double> animation,
      SlidableRenderingMode step);

  /// Returns the number of actions this delegate will build.
  int get actionCount;
}

/// A delegate that supplies slide actions using a builder callback.
///
/// This delegate provides slide actions using a [SlideActionBuilder] callback,
/// so that the animation can be passed down to the final widget.
///
/// See also:
///
///  * [SlideActionListDelegate], which is a delegate that has an explicit list
///    of slide action.
class SlideActionBuilderDelegate extends SlideActionDelegate {
  /// Creates a delegate that supplies slide actions using the given
  /// builder callback.
  ///
  /// The [builder] must not be null. The [actionCount] argument must not be positive.
  const SlideActionBuilderDelegate({
    @required this.builder,
    @required this.actionCount,
  }) : assert(actionCount != null && actionCount >= 0);

  /// Called to build slide actions.
  ///
  /// Will be called only for indices greater than or equal to zero and less
  /// than [childCount].
  final SlideActionBuilder builder;

  /// The total number of slide actions this delegate can provide.
  final int actionCount;

  @override
  Widget build(BuildContext context, int index, Animation<double> animation,
          SlidableRenderingMode step) =>
      builder(context, index, animation, step);
}

/// A delegate that supplies slide actions using an explicit list.
///
/// This delegate provides slide actions using an explicit list,
/// which is convenient but reduces the benefit of passing the animation down
/// to the final widget.
///
/// See also:
///
///  * [SlideActionBuilderDelegate], which is a delegate that uses a builder
///    callback to construct the slide actions.
class SlideActionListDelegate extends SlideActionDelegate {
  /// Creates a delegate that supplies slide actions using the given
  /// list.
  ///
  /// The [actions] argument must not be null.
  const SlideActionListDelegate({
    @required this.actions,
  });

  /// The slide actions.
  final List<Widget> actions;

  @override
  int get actionCount => actions?.length ?? 0;

  @override
  Widget build(BuildContext context, int index, Animation<double> animation,
          SlidableRenderingMode step) =>
      actions[index];
}

/// A handle to various properties useful while calling [SlidableDelegate.buildActions].
///
/// See also:
///
///  * [SlidableState], which create this object.
///  * [SlidableDelegate] and other delegates inheriting it, which uses this object in [SlidableDelegate.buildActions].
class SlidableDelegateContext {
  const SlidableDelegateContext(
    this.state,
  );

  final SlidableStateView state;

  bool get showActions => state.actionType == SlideActionType.primary;

  /// Builds the slide actions using the active [SlideActionDelegate]'s builder.
  List<Widget> buildActions(BuildContext context) {
    return List.generate(
        state.actionCount,
        (int index) => state.actionDelegate.build(context, index,
            state.actionsMoveAnimation, SlidableRenderingMode.slide));
  }

  Offset createOffset(double value) {
    return state.directionIsXAxis
        ? new Offset(value, 0.0)
        : new Offset(0.0, value);
  }

  double getMaxExtent(BoxConstraints constraints) {
    return state.directionIsXAxis
        ? constraints.maxWidth
        : constraints.maxHeight;
  }

  Positioned createPositioned({Widget child, double extent, double position}) {
    return new Positioned(
      left: state.directionIsXAxis ? (showActions ? position : null) : 0.0,
      right: state.directionIsXAxis ? (showActions ? null : position) : 0.0,
      top: state.directionIsXAxis ? 0.0 : (showActions ? position : null),
      bottom: state.directionIsXAxis ? 0.0 : (showActions ? null : position),
      width: state.directionIsXAxis ? extent : null,
      height: state.directionIsXAxis ? null : extent,
      child: child,
    );
  }
}

/// A delegate that controls how the slide actions are displayed.
///
/// See also:
///
///  * [SlidableStrechDelegate], which creates slide actions that stretched
///  while the item is sliding.
///  * [SlidableBehindDelegate], which creates slide actions that stay behind the item
///  while it's sliding.
///  * [SlidableScrollDelegate], which creates slide actions that follow the item
///  while it's sliding.
///  * [SlidableDrawerDelegate], which creates slide actions that are displayed like drawers
///  while the item is sliding.
abstract class SlidableDelegate {
  /// Creates a delegate for a [Slidable].
  ///
  /// The [fastThreshold] argument must be positive.
  const SlidableDelegate({
    double fastThreshold,
  })  : fastThreshold = fastThreshold ?? _kFastThreshold,
        assert(fastThreshold == null || fastThreshold >= .0,
            'fastThreshold must be positive');

  /// The threshold used to know if a movement was fast and request to open/close the actions.
  final double fastThreshold;

  Widget buildActions(BuildContext context, SlidableDelegateContext ctx);
}

abstract class SlidableStackDelegate extends SlidableDelegate {
  const SlidableStackDelegate({
    double fastThreshold,
  }) : super(fastThreshold: fastThreshold);

  @override
  Widget buildActions(BuildContext context, SlidableDelegateContext ctx) {
    final animation = new Tween(
      begin: Offset.zero,
      end: ctx.createOffset(ctx.state.totalActionsExtent * ctx.state.dragSign),
    ).animate(ctx.state.actionsMoveAnimation);

    if (ctx.state.actionsMoveAnimation.value != .0) {
      return new Container(
        child: new Stack(
          children: <Widget>[
            buildStackActions(
              context,
              ctx,
            ),
            new SlideTransition(
              position: animation,
              child: ctx.state.widget.child,
            ),
          ],
        ),
      );
    } else {
      return ctx.state.widget.child;
    }
  }

  Widget buildStackActions(BuildContext context, SlidableDelegateContext ctx);
}

/// A delegate that creates slide actions which stretch while the item is sliding.
class SlidableStrechDelegate extends SlidableStackDelegate {
  const SlidableStrechDelegate({
    double fastThreshold,
  }) : super(
          fastThreshold: fastThreshold,
        );

  @override
  Widget buildStackActions(BuildContext context, SlidableDelegateContext ctx) {
    final animation = new Tween(
      begin: 0.0,
      end: ctx.state.totalActionsExtent * ctx.state.dragSign,
    ).animate(ctx.state.actionsMoveAnimation);

    return new Positioned.fill(
      child: new LayoutBuilder(builder: (context, constraints) {
        return new AnimatedBuilder(
            animation: ctx.state.actionsMoveAnimation,
            builder: (context, child) {
              return new Stack(
                children: <Widget>[
                  ctx.createPositioned(
                    position: 0.0,
                    extent:
                        ctx.getMaxExtent(constraints) * animation.value.abs(),
                    child: new Flex(
                      direction: ctx.state.widget.direction,
                      children: ctx
                          .buildActions(context)
                          .map((a) => Expanded(child: a))
                          .toList(),
                    ),
                  ),
                ],
              );
            });
      }),
    );
  }
}

/// A delegate that creates slide actions which stay behind the item while it's sliding.
class SlidableBehindDelegate extends SlidableStackDelegate {
  const SlidableBehindDelegate({
    double fastThreshold,
  }) : super(
          fastThreshold: fastThreshold,
        );

  @override
  Widget buildStackActions(BuildContext context, SlidableDelegateContext ctx) {
    return new Positioned.fill(
      child: new LayoutBuilder(builder: (context, constraints) {
        return new Stack(
          children: <Widget>[
            ctx.createPositioned(
              position: 0.0,
              extent:
                  ctx.getMaxExtent(constraints) * ctx.state.totalActionsExtent,
              child: new Flex(
                direction: ctx.state.widget.direction,
                children: ctx
                    .buildActions(context)
                    .map((a) => Expanded(child: a))
                    .toList(),
              ),
            ),
          ],
        );
      }),
    );
  }
}

/// A delegate that creates slide actions which follow the item while it's sliding.
class SlidableScrollDelegate extends SlidableStackDelegate {
  const SlidableScrollDelegate({
    double fastThreshold,
  }) : super(
          fastThreshold: fastThreshold,
        );

  @override
  Widget buildStackActions(BuildContext context, SlidableDelegateContext ctx) {
    return new Positioned.fill(
      child: new LayoutBuilder(builder: (context, constraints) {
        final double totalExtent =
            ctx.getMaxExtent(constraints) * ctx.state.totalActionsExtent;

        final animation = new Tween(
          begin: -totalExtent,
          end: 0.0,
        ).animate(ctx.state.actionsMoveAnimation);

        return new AnimatedBuilder(
            animation: ctx.state.actionsMoveAnimation,
            builder: (context, child) {
              return new Stack(
                children: <Widget>[
                  ctx.createPositioned(
                    position: animation.value,
                    extent: totalExtent,
                    child: new Flex(
                      direction: ctx.state.widget.direction,
                      children: ctx
                          .buildActions(context)
                          .map((a) => Expanded(child: a))
                          .toList(),
                    ),
                  ),
                ],
              );
            });
      }),
    );
  }
}

/// A delegate that creates slide actions which animate like drawers while the item is sliding.
class SlidableDrawerDelegate extends SlidableStackDelegate {
  const SlidableDrawerDelegate({
    double fastThreshold,
  }) : super(
          fastThreshold: fastThreshold,
        );

  @override
  Widget buildStackActions(BuildContext context, SlidableDelegateContext ctx) {
    return new Positioned.fill(
      child: new LayoutBuilder(builder: (context, constraints) {
        final state = ctx.state;
        final count = state.actionCount;
        final bool showActions = ctx.showActions;
        final Animation<double> actionsMoveAnimation =
            state.actionsMoveAnimation;
        final double actionExtent =
            ctx.getMaxExtent(constraints) * state.widget.actionExtentRatio;
        final SlideActionDelegate actionDelegate = state.actionDelegate;

        final animations = Iterable.generate(count).map((index) {
          return new Tween(
            begin: -actionExtent,
            end: (count - index - 1) * actionExtent,
          ).animate(actionsMoveAnimation);
        }).toList();

        return new AnimatedBuilder(
            animation: actionsMoveAnimation,
            builder: (context, child) {
              return new Stack(
                children: List.generate(count, (index) {
                  // For the main actions we have to reverse the order if we want the last item at the bottom of the stack.
                  int displayIndex = showActions ? count - index - 1 : index;
                  return ctx.createPositioned(
                    position: animations[index].value,
                    extent: actionExtent,
                    child: actionDelegate.build(context, displayIndex,
                        actionsMoveAnimation, SlidableRenderingMode.slide),
                  );
                }),
              );
            });
      }),
    );
  }
}

/// A controller that keep tracks of the active [SlidableState] and close
/// the previous one.
class SlidableController {
  SlidableController({
    this.onSlideAnimationChanged,
    this.onSlideIsOpenChanged,
  });

  final ValueChanged<Animation<double>> onSlideAnimationChanged;
  final ValueChanged<bool> onSlideIsOpenChanged;
  bool _isSlideOpen;

  Animation<double> _slideAnimation;

  SlidableState _activeState;
  SlidableState get activeState => _activeState;
  set activeState(SlidableState value) {
    _activeState?._flingAnimationControllers();

    _activeState = value;
    if (onSlideAnimationChanged != null) {
      _slideAnimation?.removeListener(_handleSlideIsOpenChanged);
      if (onSlideIsOpenChanged != null) {
        _slideAnimation = value?.overallMoveAnimation;
        _slideAnimation?.addListener(_handleSlideIsOpenChanged);
        if (_slideAnimation == null) {
          _isSlideOpen = false;
          onSlideIsOpenChanged(_isSlideOpen);
        }
      }
      onSlideAnimationChanged(value?.overallMoveAnimation);
    }
  }

  void _handleSlideIsOpenChanged() {
    if (onSlideIsOpenChanged != null && _slideAnimation != null) {
      final bool isOpen = _slideAnimation.value != 0.0;
      if (isOpen != _isSlideOpen) {
        _isSlideOpen = isOpen;
        onSlideIsOpenChanged(_isSlideOpen);
      }
    }
  }
}

/// A widget that can be slid in both direction of the specified axis.
///
/// If the direction is [Axis.horizontal], this widget can be slid to the left or to the right,
/// otherwise this widget can be slid up or slid down.
///
/// By sliding in one of these direction, slide actions will appear.
class Slidable extends StatefulWidget {
  /// Creates a widget that can be slid.
  ///
  /// The [actions] contains the slide actions that appears when the child has been dragged down or to the right.
  /// The [secondaryActions] contains the slide actions that appears when the child has been dragged up or to the left.
  ///
  /// The [delegate] and [closeOnScroll] arguments must not be null. The [actionExtentRatio]
  /// and [showAllActionsThreshold] arguments must be greater or equal than 0 and less or equal than 1.
  ///
  /// The [key] argument must not be null if the `slideToDismissDelegate`
  /// is provided because [Slidable]s are commonly
  /// used in lists and removed from the list when dismissed. Without keys, the
  /// default behavior is to sync widgets based on their index in the list,
  /// which means the item after the dismissed item would be synced with the
  /// state of the dismissed item. Using keys causes the widgets to sync
  /// according to their keys and avoids this pitfall.
  Slidable({
    Key key,
    @required Widget child,
    @required SlidableDelegate delegate,
    List<Widget> actions,
    List<Widget> secondaryActions,
    double showAllActionsThreshold = 0.5,
    double actionExtentRatio = _kActionsExtentRatio,
    Duration movementDuration = _kMovementDuration,
    Axis direction = Axis.horizontal,
    bool closeOnScroll = true,
    bool enabled = true,
    SlideToDismissDelegate slideToDismissDelegate,
    SlidableController controller,
  }) : this.builder(
          key: key,
          child: child,
          delegate: delegate,
          actionDelegate: new SlideActionListDelegate(actions: actions),
          secondaryActionDelegate:
              new SlideActionListDelegate(actions: secondaryActions),
          showAllActionsThreshold: showAllActionsThreshold,
          actionExtentRatio: actionExtentRatio,
          movementDuration: movementDuration,
          direction: direction,
          closeOnScroll: closeOnScroll,
          enabled: enabled,
          slideToDismissDelegate: slideToDismissDelegate,
          controller: controller,
        );

  /// Creates a widget that can be slid.
  ///
  /// The [actionDelegate] is a delegate that builds the slide actions that appears when the child has been dragged down or to the right.
  /// The [secondaryActionDelegate] is a delegate that builds the slide actions that appears when the child has been dragged up or to the left.
  ///
  /// The [delegate], [closeOnScroll] and [enabled] arguments must not be null. The [actionExtentRatio]
  /// and [showAllActionsThreshold] arguments must be greater or equal than 0 and less or equal than 1.
  ///
  /// The [key] argument must not be null if the `slideToDismissDelegate`
  /// is provided because [Slidable]s are commonly
  /// used in lists and removed from the list when dismissed. Without keys, the
  /// default behavior is to sync widgets based on their index in the list,
  /// which means the item after the dismissed item would be synced with the
  /// state of the dismissed item. Using keys causes the widgets to sync
  /// according to their keys and avoids this pitfall.
  Slidable.builder({
    Key key,
    @required this.child,
    @required this.delegate,
    this.actionDelegate,
    this.secondaryActionDelegate,
    this.showAllActionsThreshold = 0.5,
    this.actionExtentRatio = _kActionsExtentRatio,
    this.movementDuration = _kMovementDuration,
    this.direction = Axis.horizontal,
    this.closeOnScroll = true,
    this.enabled = true,
    this.slideToDismissDelegate,
    this.controller,
  })  : assert(delegate != null),
        assert(direction != null),
        assert(
            showAllActionsThreshold != null &&
                showAllActionsThreshold >= .0 &&
                showAllActionsThreshold <= 1.0,
            'showAllActionsThreshold must be between 0.0 and 1.0'),
        assert(
            actionExtentRatio != null &&
                actionExtentRatio >= .0 &&
                actionExtentRatio <= 1.0,
            'actionExtentRatio must be between 0.0 and 1.0'),
        assert(closeOnScroll != null),
        assert(enabled != null),
        assert(slideToDismissDelegate == null || key != null,
            'a key must be provided if slideToDismissDelegate is set'),
        super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  /// The controller that tracks the active [Slidable] and keep only one open.
  final SlidableController controller;

  /// A delegate that builds slide actions that appears when the child has been dragged
  /// down or to the right.
  final SlideActionDelegate actionDelegate;

  /// A delegate that builds slide actions that appears when the child has been dragged
  /// up or to the left.
  final SlideActionDelegate secondaryActionDelegate;

  /// A delegate that controls how the slide actions are animated;
  final SlidableDelegate delegate;

  /// A delegate that controls how to dismiss the item.
  final SlideToDismissDelegate slideToDismissDelegate;

  /// Relative ratio between one slide action and the extent of the child.
  final double actionExtentRatio;

  /// The direction in which this widget can be slid.
  final Axis direction;

  /// The offset threshold the item has to be dragged in order to show all actions
  /// in the slide direction.
  ///
  /// Represented as a fraction, e.g. if it is 0.4 (the default), then the item
  /// has to be dragged at least 40% of the slide actions extent towards one direction to show all actions.
  final double showAllActionsThreshold;

  /// Defines the duration for card to go to final position or to come back to original position if threshold not reached.
  final Duration movementDuration;

  /// Specifies to close this slidable after the closest [Scrollable]'s position changed.
  ///
  /// Defaults to true.
  final bool closeOnScroll;

  /// Whether this slidable is interactive.
  ///
  /// If false, the child will not slid to show slide actions.
  ///
  /// Defaults to true.
  final bool enabled;

  /// The state from the closest instance of this class that encloses the given context.
  static SlidableState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<SlidableState>());
  }

  @override
  SlidableState createState() => SlidableState();
}

/// A view of a [SlidableState].
abstract class SlidableStateView {
  Animation<double> get overallMoveAnimation;

  Animation<double> get actionsMoveAnimation;

  double get dragSign;

  /// The type of slide actions that are being shown.
  SlideActionType get actionType;

  int get actionCount;

  double get totalActionsExtent;

  /// The current actions that have to be shown.
  SlideActionDelegate get actionDelegate;

  bool get directionIsXAxis;

  Slidable get widget;

  SlidableRenderingMode get renderingMode;
}

class SlidableState extends State<Slidable>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<Slidable>
    implements SlidableStateView {
  @override
  void initState() {
    super.initState();
    _overallMoveController =
        new AnimationController(duration: widget.movementDuration, vsync: this)
          ..addStatusListener(_handleDismissStatusChanged);
    _actionsMoveController =
        new AnimationController(duration: widget.movementDuration, vsync: this)
          ..addStatusListener(_handleShowAllActionsStatusChanged);
  }

  AnimationController _overallMoveController;
  Animation<double> get overallMoveAnimation => _overallMoveController.view;

  AnimationController _actionsMoveController;
  Animation<double> get actionsMoveAnimation => _actionsMoveController.view;

  AnimationController _resizeController;
  Animation<double> _resizeAnimation;

  double _dragExtent = 0.0;
  double get dragSign => _dragExtent.sign == 0 ? 1.0 : _dragExtent.sign;

  SlidableRenderingMode _renderingMode = SlidableRenderingMode.none;
  SlidableRenderingMode get renderingMode => _renderingMode;

  ScrollPosition _scrollPosition;
  bool _dragUnderway = false;
  Size _sizePriorToCollapse;
  bool _dismissing = false;

  SlideActionType get actionType =>
      dragSign > 0 ? SlideActionType.primary : SlideActionType.secondary;

  int get actionCount => actionDelegate?.actionCount ?? 0;

  double get totalActionsExtent => widget.actionExtentRatio * (actionCount);

  double get dismissThreshold =>
      widget.slideToDismissDelegate.dismissThresholds[actionType] ??
      _kDismissThreshold;

  bool get dismissible =>
      widget.slideToDismissDelegate != null && dismissThreshold < 1.0;

  @override
  bool get wantKeepAlive =>
      !widget.closeOnScroll &&
      (_overallMoveController?.isAnimating == true ||
          _actionsMoveController?.isAnimating == true ||
          _resizeController?.isAnimating == true);

  /// The current actions that have to be shown.
  SlideActionDelegate get actionDelegate =>
      actionType == SlideActionType.primary
          ? widget.actionDelegate
          : widget.secondaryActionDelegate;

  bool get directionIsXAxis => widget.direction == Axis.horizontal;

  double get _overallDragAxisExtent {
    final Size size = context.size;
    return directionIsXAxis ? size.width : size.height;
  }

  double get _actionsDragAxisExtent {
    return _overallDragAxisExtent * totalActionsExtent;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _removeScrollingNotifierListener();
    _addScrollingNotifierListener();
  }

  @override
  void didUpdateWidget(Slidable oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.closeOnScroll != oldWidget.closeOnScroll) {
      _removeScrollingNotifierListener();
      _addScrollingNotifierListener();
    }
  }

  void _addScrollingNotifierListener() {
    if (widget.closeOnScroll) {
      _scrollPosition = Scrollable.of(context)?.position;
      if (_scrollPosition != null)
        _scrollPosition.isScrollingNotifier.addListener(_isScrollingListener);
    }
  }

  void _removeScrollingNotifierListener() {
    if (_scrollPosition != null) {
      _scrollPosition.isScrollingNotifier.removeListener(_isScrollingListener);
    }
  }

  @override
  void dispose() {
    _overallMoveController.dispose();
    _actionsMoveController.dispose();
    _resizeController?.dispose();
    _removeScrollingNotifierListener();
    widget.controller?._activeState = null;
    super.dispose();
  }

  void open() {
    _actionsMoveController.fling(velocity: 1.0);
    _overallMoveController.animateTo(
      totalActionsExtent,
      curve: Curves.easeIn,
      duration: widget.movementDuration,
    );
  }

  void close() {
    _flingAnimationControllers();
    widget.controller?.activeState = null;
  }

  void _flingAnimationControllers() {
    if (!_dismissing) {
      _actionsMoveController.fling(velocity: -1.0);
      _overallMoveController.fling(velocity: -1.0);
    }
  }

  void dismiss({SlideActionType actionType}) {
    if (dismissible) {
      _dismissing = true;
      actionType ??= this.actionType;
      if (actionType != this.actionType) {
        setState(() {
          _dragExtent = actionType == SlideActionType.primary ? 1.0 : -1.0;
        });
      }

      _overallMoveController.fling(velocity: 1.0);
    }
  }

  void _isScrollingListener() {
    if (!widget.closeOnScroll || _scrollPosition == null) return;

    // When a scroll starts close this.
    if (_scrollPosition.isScrollingNotifier.value) {
      close();
    }
  }

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;
    widget.controller?.activeState = this;
    _dragExtent = _actionsMoveController.value *
        _actionsDragAxisExtent *
        _dragExtent.sign;
    if (_overallMoveController.isAnimating) {
      _overallMoveController.stop();
    }

    if (_actionsMoveController.isAnimating) {
      _actionsMoveController.stop();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (widget.controller != null && widget.controller.activeState != this) {
      return;
    }

    final double delta = details.primaryDelta;
    _dragExtent += delta;
    setState(() {
      _overallMoveController.value = _dragExtent.abs() / _overallDragAxisExtent;
      _actionsMoveController.value = _dragExtent.abs() / _actionsDragAxisExtent;
      _renderingMode = _overallMoveController.value > totalActionsExtent
          ? SlidableRenderingMode.dismiss
          : SlidableRenderingMode.slide;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    if (widget.controller != null && widget.controller.activeState != this) {
      return;
    }

    _dragUnderway = false;
    final double velocity = details.primaryVelocity;
    final bool shouldOpen = velocity.sign == _dragExtent.sign;
    final bool fast = velocity.abs() > widget.delegate.fastThreshold;

    if (dismissible && overallMoveAnimation.value > totalActionsExtent) {
      // We are in a dismiss state.
      if (overallMoveAnimation.value >= dismissThreshold) {
        dismiss();
      } else {
        open();
      }
    } else if (actionsMoveAnimation.value >= widget.showAllActionsThreshold ||
        (shouldOpen && fast)) {
      open();
    } else {
      close();
    }
  }

  void _handleShowAllActionsStatusChanged(AnimationStatus status) {
    // Make sure to rebuild a last time, otherwise the slide action could
    // be scrambled.
    if (status == AnimationStatus.completed ||
        status == AnimationStatus.dismissed) {
      setState(() {});
    }

    updateKeepAlive();
  }

  void _handleDismissStatusChanged(AnimationStatus status) async {
    if (dismissible) {
      if (status == AnimationStatus.completed &&
          _overallMoveController.value == _overallMoveController.upperBound &&
          !_dragUnderway) {
        if (widget.slideToDismissDelegate.onWillDismiss == null ||
            await widget.slideToDismissDelegate.onWillDismiss(actionType)) {
          _startResizeAnimation();
        } else {
          _dismissing = false;
          if (widget.slideToDismissDelegate?.closeOnCanceled == true) {
            close();
          } else {
            open();
          }
        }
      }
      updateKeepAlive();
    }
  }

  void _handleDismiss() {
    widget.controller?.activeState = null;
    final SlideToDismissDelegate slideToDismissDelegate =
        widget.slideToDismissDelegate;
    if (slideToDismissDelegate.onDismissed != null) {
      assert(actionType != null);
      slideToDismissDelegate.onDismissed(actionType);
    }
  }

  void _startResizeAnimation() {
    assert(_overallMoveController != null);
    assert(_overallMoveController.isCompleted);
    assert(_resizeController == null);
    assert(_sizePriorToCollapse == null);
    final SlideToDismissDelegate slideToDismissDelegate =
        widget.slideToDismissDelegate;
    if (slideToDismissDelegate.resizeDuration == null) {
      _handleDismiss();
    } else {
      _resizeController = new AnimationController(
          duration: slideToDismissDelegate.resizeDuration, vsync: this)
        ..addListener(_handleResizeProgressChanged)
        ..addStatusListener((AnimationStatus status) => updateKeepAlive());
      _resizeController.forward();
      setState(() {
        _renderingMode = SlidableRenderingMode.resize;
        _sizePriorToCollapse = context.size;
        _resizeAnimation = new Tween<double>(begin: 1.0, end: 0.0).animate(
            new CurvedAnimation(
                parent: _resizeController, curve: _kResizeTimeCurve));
      });
    }
  }

  void _handleResizeProgressChanged() {
    final SlideToDismissDelegate slideToDismissDelegate =
        widget.slideToDismissDelegate;
    if (_resizeController.isCompleted) {
      _handleDismiss();
    } else {
      if (slideToDismissDelegate.onResize != null)
        slideToDismissDelegate.onResize();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.

    if (!widget.enabled ||
        ((widget.actionDelegate == null ||
                widget.actionDelegate.actionCount == 0) &&
            (widget.secondaryActionDelegate == null ||
                widget.secondaryActionDelegate.actionCount == 0))) {
      return widget.child;
    }

    Widget content = widget.child;

    if (actionType == SlideActionType.primary &&
            widget.actionDelegate != null &&
            widget.actionDelegate.actionCount > 0 ||
        actionType == SlideActionType.secondary &&
            widget.secondaryActionDelegate != null &&
            widget.secondaryActionDelegate.actionCount > 0) {
      if (dismissible) {
        content = widget.slideToDismissDelegate.buildActions(
          context,
          new SlidableDelegateContext(this),
          widget.delegate,
        );

        if (_resizeAnimation != null) {
          // we've been dragged aside, and are now resizing.
          assert(() {
            if (_resizeAnimation.status != AnimationStatus.forward) {
              assert(_resizeAnimation.status == AnimationStatus.completed);
              throw new FlutterError(
                  'A dismissed Slidable widget is still part of the tree.\n'
                  'Make sure to implement the onDismissed handler and to immediately remove the Slidable\n'
                  'widget from the application once that handler has fired.');
            }
            return true;
          }());

          return new SizeTransition(
              sizeFactor: _resizeAnimation,
              axis: directionIsXAxis ? Axis.vertical : Axis.horizontal,
              child: new SizedBox(
                width: _sizePriorToCollapse.width,
                height: _sizePriorToCollapse.height,
                child: content,
              ));
        }
      } else {
        content = widget.delegate.buildActions(
          context,
          new SlidableDelegateContext(this),
        );
      }
    }

    return new GestureDetector(
      onHorizontalDragStart: directionIsXAxis ? _handleDragStart : null,
      onHorizontalDragUpdate: directionIsXAxis ? _handleDragUpdate : null,
      onHorizontalDragEnd: directionIsXAxis ? _handleDragEnd : null,
      onVerticalDragStart: directionIsXAxis ? null : _handleDragStart,
      onVerticalDragUpdate: directionIsXAxis ? null : _handleDragUpdate,
      onVerticalDragEnd: directionIsXAxis ? null : _handleDragEnd,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}
