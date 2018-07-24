import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const double _kActionsExtentRatio = 0.25;
const double _kFastThreshold = 2500.0;

/// Signature for the builder callback used to create slide actions.
typedef Widget SlideActionBuilder(
    BuildContext context, int index, Animation<double> animation);

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
  Widget build(BuildContext context, int index, Animation<double> animation);

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
///    of slidable action.
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
  Widget build(BuildContext context, int index, Animation<double> animation) =>
      builder(context, index, animation);
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
  Widget build(BuildContext context, int index, Animation<double> animation) =>
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
    this.slidable,
    this.showActions,
    this.dragSign,
    this.controller,
  );

  final Slidable slidable;

  /// The current actions that have to be shown.
  SlideActionDelegate get actionDelegate =>
      showActions ? slidable.actionDelegate : slidable.secondaryActionDelegate;

  bool get directionIsXAxis => slidable.direction == Axis.horizontal;

  int get actionCount => actionDelegate?.actionCount ?? 0;

  double get totalActionsExtent => slidable.actionExtentRatio * (actionCount);

  /// Whether the actions have to be shown.
  final bool showActions;

  final double dragSign;

  /// The animation controller which value depends on  `dragExtent`.
  final AnimationController controller;

  /// Builds the slide actions using the active [SlideActionDelegate]'s builder.
  List<Widget> buildActions(BuildContext context) {
    return List.generate(actionCount,
        (int index) => actionDelegate.build(context, index, controller.view));
  }

  Offset createOffset(double value) {
    return directionIsXAxis ? new Offset(value, 0.0) : new Offset(0.0, value);
  }

  double getMaxExtent(BoxConstraints constraints) {
    return directionIsXAxis ? constraints.maxWidth : constraints.maxHeight;
  }

  Positioned createPositioned({Widget child, double extent, double position}) {
    return new Positioned(
      left: directionIsXAxis ? (showActions ? position : null) : 0.0,
      right: directionIsXAxis ? (showActions ? null : position) : 0.0,
      top: directionIsXAxis ? 0.0 : (showActions ? position : null),
      bottom: directionIsXAxis ? 0.0 : (showActions ? null : position),
      width: directionIsXAxis ? extent : null,
      height: directionIsXAxis ? null : extent,
      child: child,
    );
  }

  double getAnimationValue(Animation<Offset> animation) {
    return directionIsXAxis ? animation.value.dx : animation.value.dy;
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
      end: ctx.createOffset(ctx.totalActionsExtent * ctx.dragSign),
    ).animate(ctx.controller);

    if (ctx.controller.value != .0) {
      return new Container(
        child: new Stack(
          children: <Widget>[
            buildStackActions(
              context,
              ctx,
            ),
            new SlideTransition(
              position: animation,
              child: ctx.slidable.child,
            ),
          ],
        ),
      );
    } else {
      return ctx.slidable.child;
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
      begin: Offset.zero,
      end: ctx.createOffset(ctx.totalActionsExtent * ctx.dragSign),
    ).animate(ctx.controller);

    return new Positioned.fill(
      child: new LayoutBuilder(builder: (context, constraints) {
        return new AnimatedBuilder(
            animation: ctx.controller,
            builder: (context, child) {
              return new Stack(
                children: <Widget>[
                  ctx.createPositioned(
                    position: 0.0,
                    extent: ctx.getMaxExtent(constraints) *
                        ctx.getAnimationValue(animation).abs(),
                    child: new Flex(
                      direction: ctx.slidable.direction,
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
              extent: ctx.getMaxExtent(constraints) * ctx.totalActionsExtent,
              child: new Flex(
                direction: ctx.slidable.direction,
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
            ctx.getMaxExtent(constraints) * ctx.totalActionsExtent;

        final animation = new Tween(
          begin: ctx.createOffset(-totalExtent),
          end: Offset.zero,
        ).animate(ctx.controller);

        return new AnimatedBuilder(
            animation: ctx.controller,
            builder: (context, child) {
              return new Stack(
                children: <Widget>[
                  ctx.createPositioned(
                    position: ctx.getAnimationValue(animation),
                    extent: totalExtent,
                    child: new Flex(
                      direction: ctx.slidable.direction,
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
        final count = ctx.actionCount;
        final double actionExtent =
            ctx.getMaxExtent(constraints) * ctx.slidable.actionExtentRatio;

        final animations = Iterable.generate(count).map((index) {
          return new Tween(
            begin: ctx.createOffset(-actionExtent),
            end: ctx.createOffset((count - index - 1) * actionExtent),
          ).animate(ctx.controller);
        }).toList();

        return new AnimatedBuilder(
            animation: ctx.controller,
            builder: (context, child) {
              return new Stack(
                children: List.generate(ctx.actionCount, (index) {
                  // For the main actions we have to reverse the order if we want the last item at the bottom of the stack.
                  int displayIndex =
                      ctx.showActions ? ctx.actionCount - index - 1 : index;
                  return ctx.createPositioned(
                    position: ctx.getAnimationValue(animations[index]),
                    extent: actionExtent,
                    child: ctx.actionDelegate
                        .build(context, displayIndex, ctx.controller.view),
                  );
                }),
              );
            });
      }),
    );
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
  Slidable({
    Key key,
    @required Widget child,
    @required SlidableDelegate delegate,
    List<Widget> actions,
    List<Widget> secondaryActions,
    double showAllActionsThreshold = 0.5,
    double actionExtentRatio = _kActionsExtentRatio,
    Duration movementDuration = const Duration(milliseconds: 200),
    Axis direction = Axis.horizontal,
    bool closeOnScroll = true,
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
        );

  /// Creates a widget that can be slid.
  ///
  /// The [actionDelegate] is a delegate that builds the slide actions that appears when the child has been dragged down or to the right.
  /// The [secondaryActionDelegate] is a delegate that builds the slide actions that appears when the child has been dragged up or to the left.
  ///
  /// The [delegate] and [closeOnScroll] arguments must not be null. The [actionExtentRatio]
  /// and [showAllActionsThreshold] arguments must be greater or equal than 0 and less or equal than 1.
  Slidable.builder({
    Key key,
    @required this.child,
    @required this.delegate,
    this.actionDelegate,
    this.secondaryActionDelegate,
    this.showAllActionsThreshold = 0.5,
    this.actionExtentRatio = _kActionsExtentRatio,
    this.movementDuration = const Duration(milliseconds: 200),
    this.direction = Axis.horizontal,
    this.closeOnScroll = true,
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
        super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  /// A delegate that builds slide actions that appears when the child has been dragged
  /// down or to the right.
  final SlideActionDelegate actionDelegate;

  /// A delegate that builds slide actions that appears when the child has been dragged
  /// up or to the left.
  final SlideActionDelegate secondaryActionDelegate;

  /// A delegate that controls how the slide actions are animated;
  final SlidableDelegate delegate;

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

  /// The state from the closest instance of this class that encloses the given context.
  static SlidableState of(BuildContext context) {
    return context.ancestorStateOfType(const TypeMatcher<SlidableState>());
  }

  @override
  SlidableState createState() => SlidableState();
}

class SlidableState extends State<Slidable>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<Slidable> {
  @override
  void initState() {
    super.initState();
    _controller =
        new AnimationController(duration: widget.movementDuration, vsync: this)
          ..addStatusListener(_handleShowAllActionsStatusChanged);
  }

  AnimationController _controller;

  double _dragExtent = 0.0;

  ScrollPosition _scrollPosition;

  bool get _showActions {
    return _dragExtent > 0;
  }

  @override
  bool get wantKeepAlive =>
      _controller != null &&
      (_controller.isAnimating || _controller.isCompleted);

  /// The current actions that have to be shown.
  SlideActionDelegate get actionDelegate =>
      _showActions ? widget.actionDelegate : widget.secondaryActionDelegate;

  bool get _directionIsXAxis {
    return widget.direction == Axis.horizontal;
  }

  double get _overallDragAxisExtent {
    return (_directionIsXAxis ? context.size.width : context.size.height) *
        widget.actionExtentRatio *
        (actionDelegate?.actionCount ?? 0);
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
    _controller.dispose();
    _removeScrollingNotifierListener();
    super.dispose();
  }

  void open() {
    _controller.fling(velocity: 1.0);
  }

  void close() {
    _controller.fling(velocity: -1.0);
  }

  void _isScrollingListener() {
    if (!widget.closeOnScroll || _scrollPosition == null) return;

    // When a scroll starts close this.
    if (_scrollPosition.isScrollingNotifier.value) {
      close();
    }
  }

  void _handleDragStart(DragStartDetails details) {
    _dragExtent = _controller.value * _overallDragAxisExtent * _dragExtent.sign;
    if (_controller.isAnimating) {
      _controller.stop();
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final double delta = details.primaryDelta;
    _dragExtent += delta;
    setState(() {
      _controller.value = _dragExtent.abs() / _overallDragAxisExtent;
    });
  }

  void _handleDragEnd(DragEndDetails details) {
    final double velocity = details.primaryVelocity;
    final bool shouldOpen = velocity.sign == _dragExtent.sign;
    final bool fast = velocity.abs() > widget.delegate.fastThreshold;
    if (_controller.value >= widget.showAllActionsThreshold ||
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

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.

    if ((widget.actionDelegate == null ||
            widget.actionDelegate.actionCount == 0) &&
        (widget.secondaryActionDelegate == null ||
            widget.secondaryActionDelegate.actionCount == 0)) {
      return widget.child;
    }

    Widget content = widget.child;

    if (_showActions &&
            widget.actionDelegate != null &&
            widget.actionDelegate.actionCount > 0 ||
        !_showActions &&
            widget.secondaryActionDelegate != null &&
            widget.secondaryActionDelegate.actionCount > 0) {
      content = widget.delegate.buildActions(
        context,
        new SlidableDelegateContext(
          widget,
          _showActions,
          _dragExtent.sign,
          _controller,
        ),
      );
    }

    return new GestureDetector(
      onHorizontalDragStart: _directionIsXAxis ? _handleDragStart : null,
      onHorizontalDragUpdate: _directionIsXAxis ? _handleDragUpdate : null,
      onHorizontalDragEnd: _directionIsXAxis ? _handleDragEnd : null,
      onVerticalDragStart: _directionIsXAxis ? null : _handleDragStart,
      onVerticalDragUpdate: _directionIsXAxis ? null : _handleDragUpdate,
      onVerticalDragEnd: _directionIsXAxis ? null : _handleDragEnd,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
}
