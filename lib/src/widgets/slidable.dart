import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const double _kActionsExtentRatio = 0.25;
const double _kFastThreshold = 2500.0;

typedef Widget SlidableActionBuilder(BuildContext context, int index, Animation<Offset> animation);

abstract class SlidableActionDelegate{
  const SlidableActionDelegate();

  /// Returns the child with the given index.
  ///
  /// Must not return null.
  Widget build(BuildContext context, int index, Animation<Offset> animation);

  /// Returns the number of actions this delegate will build.
  int get actionCount;
}

class SlidableActionBuilderDelegate extends SlidableActionDelegate{
  const SlidableActionBuilderDelegate({
    this.builder,
    this.actionCount,
}) ;

  final SlidableActionBuilder builder;

  final int actionCount;

  @override
  Widget build(BuildContext context, int index, Animation<Offset> animation) => builder(context, index, animation);
}

class SlidableActionListDelegate extends SlidableActionDelegate{
  const SlidableActionListDelegate({
    this.actions,
  }) : super();

  final List<Widget> actions;

  @override
  int get actionCount => actions?.length ?? 0;

  @override
  Widget build(BuildContext context, int index, Animation<Offset> animation) => actions[index];
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
    this.showLeftActions,
    this.dragExtent,
    this.controller,
  );

  final Slidable slidable;

  /// The current actions that have to be shown.
  SlidableActionDelegate get actionDelegate =>
      showLeftActions ? slidable.leftActionDelegate : slidable.rightActionDelegate;  
  
  int get actionCount => actionDelegate?.actionCount ?? 0;

  double get totalActionsWidth =>
      slidable.actionExtentRatio * (actionCount);

  /// Whether the left actions have to be shown.
  final bool showLeftActions;

  final double dragExtent;

  /// The animation controller which value depends on  `dragExtent`.
  final AnimationController controller;

  /// Builds the slide actions using the active [SlidableActionDelegate]'s builder.
  List<Widget> buildActions(BuildContext context, Animation<Offset> animation){
    return List.generate(actionCount, (int index) => actionDelegate.build(context, index, animation));
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
      end: new Offset(ctx.totalActionsWidth * ctx.dragExtent.sign, 0.0),
    ).animate(ctx.controller);

    if (ctx.controller.value != .0 && ctx.dragExtent != .0) {
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
      end: new Offset(ctx.totalActionsWidth * ctx.dragExtent.sign, 0.0),
    ).animate(ctx.controller);

    return new Positioned.fill(
      child: new LayoutBuilder(builder: (context, constraints) {
        return new AnimatedBuilder(
            animation: ctx.controller,
            builder: (context, child) {
              return new Stack(
                children: <Widget>[
                  new Positioned(
                    left: ctx.showLeftActions ? .0 : null,
                    right: ctx.showLeftActions ? null : .0,
                    top: .0,
                    bottom: .0,
                    width: constraints.maxWidth * animation.value.dx.abs(),
                    child: new Row(
                      children:                          
                          ctx.buildActions(context, animation).map((a) => Expanded(child: a)).toList(),
                    ),
                  )
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
            new Positioned(
              left: ctx.showLeftActions ? .0 : null,
              right: ctx.showLeftActions ? null : .0,
              top: .0,
              bottom: .0,
              width: constraints.maxWidth * ctx.totalActionsWidth,
              child: new Row(
                children: ctx.buildActions(context, null).map((a) => Expanded(child: a)).toList(),
              ),
            )
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
        final double totalWidth = constraints.maxWidth * ctx.totalActionsWidth;

        final animation = new Tween(
          begin: new Offset(-totalWidth, 0.0),
          end: Offset.zero,
        ).animate(ctx.controller);

        return new AnimatedBuilder(
            animation: ctx.controller,
            builder: (context, child) {
              return new Stack(
                children: <Widget>[
                  new Positioned(
                    left: ctx.showLeftActions ? animation.value.dx : null,
                    right: ctx.showLeftActions ? null : animation.value.dx,
                    top: .0,
                    bottom: .0,
                    width: totalWidth,
                    child: new Row(
                      children:
                          ctx.buildActions(context, animation).map((a) => Expanded(child: a)).toList(),
                    ),
                  )
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
        final double width = constraints.maxWidth;
        final double actionWidth = width * ctx.slidable.actionExtentRatio;

        final animations = Iterable.generate(count).map((index) {
          return new Tween(
            begin: new Offset(-actionWidth, 0.0),
            end: new Offset((count - index - 1) * actionWidth, 0.0),
          ).animate(ctx.controller);
        }).toList();

        return new AnimatedBuilder(
            animation: ctx.controller,
            builder: (context, child) {
              return new Stack(
                children: List.generate(ctx.actionCount, (index){
                  // For the left items we have to reverse the order if we want the last item at the bottom of the stack.
                  int displayIndex = ctx.showLeftActions ? ctx.actionCount - index - 1 : index;
                  return new Positioned(
                    left: ctx.showLeftActions
                        ? animations[index].value.dx
                        : null,
                    right: ctx.showLeftActions
                        ? null
                        : animations[index].value.dx,
                    top: .0,
                    bottom: .0,
                    width: actionWidth,
                    child: ctx.actionDelegate.build(context, displayIndex, animations[index]),
                  );
                }),
              );
            });
      }),
    );
  }
}

/// A widget that can be slide to the right or to the left.
/// By sliding in one of these direction, slide actions will appear.
class Slidable extends StatefulWidget {
  /// Creates a widget that can be dismissed.
  ///
  /// The [delegate] argument must not be null. The [actionExtentRatio]
  /// and [showAllActionsThreshold] arguments must be greater or equal than 0 and less or equal than 1.
  Slidable({
    Key key,
    @required Widget child,
    @required SlidableDelegate delegate,
    List<Widget> leftActions,
    List<Widget> rightActions,
    double showAllActionsThreshold = 0.5,
    double actionExtentRatio = _kActionsExtentRatio,
    Duration movementDuration: const Duration(milliseconds: 200),
  })  : this.builder(
    key : key,
      child : child,
      delegate : delegate,
      leftActionDelegate : new SlidableActionListDelegate(actions:  leftActions),
    rightActionDelegate : new SlidableActionListDelegate(actions:  rightActions),
    showAllActionsThreshold : showAllActionsThreshold,
    actionExtentRatio : actionExtentRatio,
    movementDuration  : movementDuration
  );

  Slidable.builder({
    Key key,
    @required this.child,
    @required this.delegate,
    this.leftActionDelegate,
    this.rightActionDelegate,
    this.showAllActionsThreshold = 0.5,
    this.actionExtentRatio = _kActionsExtentRatio,
    this.movementDuration: const Duration(milliseconds: 200),
  })  : assert(delegate != null),
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
        super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  final SlidableActionDelegate leftActionDelegate;

  final SlidableActionDelegate rightActionDelegate;

  final SlidableDelegate delegate;

  /// Relative ratio between one slide action and the extent of the child.
  final double actionExtentRatio;

  /// The offset threshold the item has to be dragged in order to show all actions
  /// in the slide direction.
  ///
  /// Represented as a fraction, e.g. if it is 0.4 (the default), then the item
  /// has to be dragged at least 40% of the slide actions extent towards one direction to show all actions.
  final double showAllActionsThreshold;

  /// Defines the duration for card to go to final position or to come back to original position if threshold not reached.
  final Duration movementDuration;

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

  void _handleShowAllActionsStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_dragUnderway && !_opening) {
      _dragExtent = .0;
      setState(() {});
    }
  }

  AnimationController _controller;
  double _dragExtent = 0.0;
  bool _dragUnderway = false;
  bool _opening = false;

  bool get _showLeftActions {
    return _dragExtent > 0;
  }

  /// The current actions that have to be shown.
  SlidableActionDelegate get actionDelegate =>
      _showLeftActions ? widget.leftActionDelegate : widget.rightActionDelegate;

  double get _overallDragAxisExtent =>
      context.size.width * widget.actionExtentRatio * (actionDelegate?.actionCount ?? 0);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;
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
    _dragUnderway = false;
    final double velocity = details.primaryVelocity;
    final bool open = velocity.sign == _dragExtent.sign;
    final bool fast = velocity.abs() > widget.delegate.fastThreshold;
    if (!open && fast) {
      _opening = false;
      _controller.animateTo(0.0);
    } else if (_controller.value >= widget.showAllActionsThreshold ||
        (open && fast)) {
      _opening = true;
      _controller.animateTo(1.0);
    } else {
      _opening = false;
      _controller.animateTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.

    if ((widget.leftActionDelegate == null || widget.leftActionDelegate.actionCount == 0) && (widget.rightActionDelegate == null || widget.rightActionDelegate.actionCount == 0)) {
      return widget.child;
    }

    Widget content = widget.child;

    if (_showLeftActions && widget.leftActionDelegate != null && widget.leftActionDelegate.actionCount > 0 ||
        !_showLeftActions && widget.rightActionDelegate != null && widget.rightActionDelegate.actionCount > 0) {
      content = widget.delegate.buildActions(
        context,
        new SlidableDelegateContext(
          widget,
          _showLeftActions,
          _dragExtent,
          _controller,
        ),
      );
    }

    return new GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }

  @override
  bool get wantKeepAlive => _opening;
}
