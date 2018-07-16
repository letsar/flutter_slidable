import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/src/widgets/slide_action.dart';

enum SlidableActionsShowMode {
  /// The actions are displayed behind the item.
  behind,

  // The actions are scrolled.
  scroll,

  // The actions are strechted until they have reached their final sizes.
  stretch,
}

/// A widget that can be slide to the right or to the left.
/// By sliding in one of these direction, slide actions will appear.
class Slidable extends StatefulWidget {
  /// Creates a widget that can be dismissed.
  ///
  /// The [key] argument must not be null because [Slidable]s are commonly
  /// used in lists and removed from the list when dismissed. Without keys, the
  /// default behavior is to sync widgets based on their index in the list,
  /// which means the item after the dismissed item would be synced with the
  /// state of the dismissed item. Using keys causes the widgets to sync
  /// according to their keys and avoids this pitfall.
  Slidable({
    @required Key key,
    @required this.child,
    this.leftActions,
    this.rightActions,
    this.actionsShowMode = SlidableActionsShowMode.behind,
    this.actionExtent,
    this.showAllActionsThreshold = 0.5,
    this.movementDuration: const Duration(milliseconds: 200),
  })  : assert(actionsShowMode != null),
        assert(actionExtent == null || actionExtent > 0),
        super(key: key);

  /// The widget below this widget in the tree.
  final Widget child;

  final List<SlideAction> leftActions;

  final List<SlideAction> rightActions;

  final SlidableActionsShowMode actionsShowMode;

  final double actionExtent;

  /// The offset threshold the item has to be dragged in order to show all actions
  /// in the slide direction.
  ///
  /// Represented as a fraction, e.g. if it is 0.4 (the default), then the item
  /// has to be dragged at least 40% of the slide actions extent towards one direction to show all actions.
  final double showAllActionsThreshold;

  /// Defines the duration for card to go to final position or to come back to original position if threshold not reached.
  final Duration movementDuration;

  @override
  _SlidableState createState() => _SlidableState();
}

class _SlidableState extends State<Slidable> with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<Slidable> {
  @override
  void initState() {
    super.initState();
    _controller = new AnimationController(duration: widget.movementDuration, vsync: this)
      ..addStatusListener(_handleShowAllActionsStatusChanged);
  }

  void _handleShowAllActionsStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_dragUnderway &&!_opening) {
              _dragExtent =.0;
    }
  }

  AnimationController _controller;
  Animation<Offset> _animation;

  double _dragExtent = 0.0;
  bool _dragUnderway = false;
  bool _opening = false;
  double _actionExtent;

  bool get _isActive {
    return _dragUnderway || _controller.isAnimating;
  }

  bool get _showLeftActions {
    return _dragExtent > 0;
  }

  double get _overallDragAxisExtent {
    return context.size.width;
  }

  List<SlideAction> get _slideActions {
    return _showLeftActions ? widget.leftActions : widget.rightActions;
  }

  double get _slideActionsExtent {
    final int count = _slideActions?.length ?? 0;
    return count * _actionExtent;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    final double overallDragAxisExtent = context.size.width;
    _dragUnderway = true;
    _actionExtent = widget.actionExtent ?? overallDragAxisExtent;

    if (_controller.isAnimating) {
      _dragExtent =
          _controller.value * overallDragAxisExtent * _dragExtent.sign;
      _controller.stop();
    } else {
     // _dragExtent = 0.0;
      _controller.value = 0.0;
    }
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    final double delta = details.primaryDelta;
    _dragExtent += delta;
    setState(() {
      _controller.value = _dragExtent.abs() / context.size.width;
    });
//    if (!_isActive || _controller.isAnimating) return;
//    final double delta = details.primaryDelta;
//    final double oldDragExtent = _dragExtent;
//    _dragExtent += delta;
//    if (oldDragExtent.sign != _dragExtent.sign) {
//      setState(() {
//        _updateMoveAnimation();
//      });
//    }
//    if (!_controller.isAnimating) {
//      _controller.value = _dragExtent.abs() / _overallDragAxisExtent;
//    }
  }

  void _handleDragEnd(DragEndDetails details) {
    _dragUnderway = false;
    final double velocity = details.primaryVelocity;
    final bool open = velocity.sign == _dragExtent.sign;
    final bool fast = velocity.abs() > 2500;
    if(!open && fast) {
      _opening = false;
      _controller.animateTo(0.0);
    }else if(_controller.value >= widget.showAllActionsThreshold || (open && fast)){
      _opening = true;
      _controller.animateTo(1.0);
    }else{
      _opening = false;
      _controller.animateTo(0.0);
    }
  }

  void _updateMoveAnimation() {
    final double end = _dragExtent.sign * _slideActionsExtent / _overallDragAxisExtent;
    _animation = new Tween<Offset>(
      begin: Offset.zero,
      end: new Offset(end, 0.0),
    ).animate(_controller);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.

    if (widget.leftActions == null && widget.rightActions == null) {
      return widget.child;
    }

    final animation =
        new Tween(
            begin: Offset.zero,
            end: Offset(0.3 * _dragExtent.sign, 0.0),
        ).animate(new CurveTween(curve: Curves.decelerate).animate(_controller));

    Widget content = widget.child;

    if(animation.value.dx != .0 && _dragExtent != .0) {
      content = new Stack(
        children: <Widget>[
          new SlideTransition(
            position: animation,
            child: widget.child,
          ),
          new Positioned.fill(child: new LayoutBuilder(builder: (context, constraints) {
            return new AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return new Stack(
                    children: <Widget>[
                      new Positioned(
                        left: _showLeftActions ? .0 : null,
                        right: _showLeftActions ? null : .0,
                        top: .0,
                        bottom: .0,
                        width: constraints.maxWidth * animation.value.dx * _dragExtent.sign,
                        child: new Row(
                          children: _slideActions
                              .map(
                                (slideAction) =>
                                Expanded(
                                  child: new Container(
                                    //width: _actionExtent,
                                    color: slideAction.background,
                                    child: slideAction,
                                  ),
                                ),
                          )
                              .toList(),
                        ),
                      )
                    ],
                  );
                });
          })),
        ],
      );
    }

//    if(_dragExtent != 0.0) {
//      content = new SlideTransition(
//        position: _animation,
//        child: content,
//      );
//
//      final bool showLeftActions = _showLeftActions;
//
//      if (!_animation.isDismissed) {
//        final List<Widget> children = <Widget>[];
//        final List<SlideAction> slideActions =
//        _dragExtent < 0 ? widget.rightActions : widget.leftActions;
//        if (slideActions != null && slideActions.isNotEmpty) {
//          children.add(new Positioned(
//              left: showLeftActions ? 0.0 : null,
//              right: showLeftActions ? null : 0.0,
//              width: _slideActionsExtent,
//              top: 0.0,
//              bottom: 0.0,
//              child: new ClipRect(
//                clipper: new _SlidableClipper(
//                  moveAnimation: _animation,
//                ),
//                child: new Row(
//                  children: slideActions
//                      .map(
//                        (slideAction) =>
//                    new Container(
//                      width: _actionExtent,
//                      color: slideAction.background,
//                      child: slideAction,
//                    ),
//                  )
//                      .toList(),
//                ),
//              )));
//        }
//
//        children.add(content);
//        content = new Stack(children: children);
//      }
//    }

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

class _SlidableClipper extends CustomClipper<Rect> {
  _SlidableClipper({
    @required this.moveAnimation,
  })  : assert(moveAnimation != null),
        super(reclip: moveAnimation);

  final Animation<Offset> moveAnimation;

  @override
  Rect getClip(Size size) {
    final double offset = moveAnimation.value.dx * size.width;
    if (offset < 0) return new Rect.fromLTRB(size.width + offset, 0.0, size.width, size.height);
    return new Rect.fromLTRB(0.0, 0.0, offset, size.height);
  }

  @override
  Rect getApproximateClipRect(Size size) => getClip(size);

  @override
  bool shouldReclip(_SlidableClipper oldClipper) {
    return oldClipper.moveAnimation.value != moveAnimation.value;
  }
}
