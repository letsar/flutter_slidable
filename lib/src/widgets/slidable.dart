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

class _SlidableState extends State<Slidable> with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    _moveController =
        new AnimationController(duration: widget.movementDuration, vsync: this)
          ..addStatusListener(_handleShowAllActionsStatusChanged);
    //_updateMoveAnimation();
  }

  AnimationController _moveController;
  Animation<Offset> _moveAnimation;

  AnimationController _resizeController;
  Animation<double> _resizeAnimation;

  double _dragExtent = 0.0;
  bool _dragUnderway = false;
  Size _sizePriorToCollapse;

  bool get _isActive {
    return _dragUnderway || _moveController.isAnimating;
  }

  double get _overallDragAxisExtent {
    return context.size.width;
  }

  double get _actionExtent {
    return widget.actionExtent ?? context.size.height;
  }

  List<SlideAction> get _slideActions {
    return _dragExtent > 0 ? widget.leftActions : widget.rightActions;
  }

  double get _slideActionsExtent {
    final int count = _slideActions?.length ?? 0;
    return count * _actionExtent;
  }

  @override
  void dispose() {
    _moveController.dispose();
    _resizeController?.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    _dragUnderway = true;
    if (_moveController.isAnimating) {
      _dragExtent =
          _moveController.value * _overallDragAxisExtent * _dragExtent.sign;
      _moveController.stop();
    } else {
      _dragExtent = 0.0;
      _moveController.value = 0.0;
    }
    setState(() {
      _updateMoveAnimation();
    });
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isActive || _moveController.isAnimating) return;
    final double delta = details.primaryDelta;
    final double oldDragExtent = _dragExtent;
    _dragExtent += delta;
    if (oldDragExtent.sign != _dragExtent.sign) {
      setState(() {
        _updateMoveAnimation();
      });
    }
    if (!_moveController.isAnimating) {
      _moveController.value = _dragExtent.abs() / _overallDragAxisExtent;
    }
  }

  void _handleDragEnd(DragEndDetails details) {
    if (!_isActive || _moveController.isAnimating) return;
    _dragUnderway = false;

    final double flingVelocity = details.primaryVelocity;
    final double dragRatio = _dragExtent / _slideActionsExtent;

    if(dragRatio >= widget.showAllActionsThreshold){
      _moveController.fling();
    }else{
      _moveController.reverse();
    }

  }

  void _updateMoveAnimation() {
    final double end = _dragExtent.sign * _slideActionsExtent / _overallDragAxisExtent;
    _moveAnimation = new Tween<Offset>(
      begin: Offset.zero,
      end: new Offset(end, 0.0),
    ).animate(_moveController);
  }

  void _startResizeAnimation() {
    assert(_moveController != null);
    assert(_moveController.isCompleted);
    assert(_resizeController == null);
    assert(_sizePriorToCollapse == null);

    // TODO.
  }

  void _handleShowAllActionsStatusChanged(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_dragUnderway)
      _startResizeAnimation();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.leftActions == null &&
        widget.rightActions == null){
      return widget.child;
    }

    Widget content = widget.child;

    if(_dragExtent != 0.0) {
      content = new SlideTransition(
        position: _moveAnimation,
        child: content,
      );

      if (!_moveAnimation.isDismissed) {
        final List<Widget> children = <Widget>[];
        final List<SlideAction> slideActions =
        _dragExtent < 0 ? widget.rightActions : widget.leftActions;
        if (slideActions != null && slideActions.isNotEmpty) {
          children.add(new Positioned.fill(
              child: new ClipRect(
                clipper: new _SlidableClipper(
                  moveAnimation: _moveAnimation,
                ),
                child: new Row(
                  children: slideActions
                      .map(
                        (slideAction) =>
                    new Container(
                      color: slideAction.background,
                      child: slideAction,
                    ),
                  )
                      .toList(),
                ),
              )));
        }

        children.add(content);
        content = new Stack(children: children);
      }
    }

    return new GestureDetector(
      onHorizontalDragStart: _handleDragStart,
      onHorizontalDragUpdate: _handleDragUpdate,
      onHorizontalDragEnd: _handleDragEnd,
      behavior: HitTestBehavior.opaque,
      child: content,
    );
  }
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
    if (offset < 0)
      return new Rect.fromLTRB(
          size.width + offset, 0.0, size.width, size.height);
    return new Rect.fromLTRB(0.0, 0.0, offset, size.height);
  }

  @override
  Rect getApproximateClipRect(Size size) => getClip(size);

  @override
  bool shouldReclip(_SlidableClipper oldClipper) {
    return oldClipper.moveAnimation.value != moveAnimation.value;
  }
}
