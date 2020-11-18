import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/src/dismissal_transition.dart';
import 'package:flutter_slidable/src/slidable_controller.dart';
import 'package:flutter_slidable/src/slidable_scroll_configurator.dart';

/// Represents a group of slidables where only one of them can be open at the
/// same time.
class SlidableGroup {}

class Slidable extends StatefulWidget {
  const Slidable({
    Key key,
    this.enabled = true,
    this.closeOnScroll = true,
    this.startActionPane,
    this.endActionPane,
    this.direction,
    @required this.child,
    this.dragStartBehavior = DragStartBehavior.down,
  })  : assert(enabled != null),
        assert(closeOnScroll != null),
        assert(dragStartBehavior != null),
        super(key: key);

  /// Whether this slidable is interactive.
  ///
  /// If false, the child will not slid to show actions.
  ///
  /// Defaults to true.
  final bool enabled;

  /// Specifies to close this [Slidable] after the closest [Scrollable]'s
  /// position changed.
  ///
  /// Defaults to true.
  final bool closeOnScroll;

  final Widget startActionPane;
  final Widget endActionPane;
  final Axis direction;
  final Widget child;

  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], the drag gesture used to dismiss a
  /// dismissible will begin upon the detection of a drag gesture. If set to
  /// [DragStartBehavior.down] it will begin when a down event is first detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///  * [DragGestureRecognizer.dragStartBehavior], which gives an example for the different behaviors.
  final DragStartBehavior dragStartBehavior;

  @override
  _SlidableState createState() => _SlidableState();

  static SlidableController of(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<_SlidableControllerScope>()
        ?.widget as _SlidableControllerScope;
    return scope?.controller;
  }
}

class _SlidableState extends State<Slidable>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  SlidableController controller;
  Animation<Offset> moveAnimation;

  // double sign = 0;

// TODO.
  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    controller = SlidableController(this)..addListener(handleControllerChanges);
    updateController();
    updateMoveAnimation();
  }

  @override
  void didUpdateWidget(covariant Slidable oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateController();
  }

  @override
  void dispose() {
    controller.removeListener(handleControllerChanges);
    controller.dispose();
    super.dispose();
  }

  void updateController() {
    controller
      ..enableStartActionPane = widget.startActionPane != null
      ..enableEndActionPane = widget.endActionPane != null;
  }

  void handleControllerChanges() {
    // if (sign != controller.sign) {
    //   sign = controller.sign;
    //   handleRatioSignChanged();
    // }
    if (controller.lastChangedProperty == SlidableControllerProperty.sign) {
      handleRatioSignChanged();
    }
  }

  void handleRatioSignChanged() {
    setState(() {
      updateMoveAnimation();
    });
  }

  void handleDismissing() {
    if (controller.resizeRequest != null) {
      setState(() {});
    }
  }

  void updateMoveAnimation() {
    final double end = controller.sign;
    moveAnimation = controller.animation.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: widget.direction == Axis.horizontal
            ? Offset(end, 0)
            : Offset(0, end),
      ),
    );
  }

  Widget get actionPane {
    if (controller.ratio > 0) {
      return widget.startActionPane;
    } else if (controller.ratio < 0) {
      return widget.endActionPane;
    } else {
      return null;
    }
  }

  Alignment get actionPaneAlignment {
    if (widget.direction == Axis.horizontal) {
      return Alignment(controller.sign * -1, 0);
    } else {
      return Alignment(0, controller.sign * -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // See AutomaticKeepAliveClientMixin.

    Widget content = SlideTransition(
      position: moveAnimation,
      child: widget.child,
    );

    content = Stack(
      children: <Widget>[
        if (actionPane != null)
          Positioned.fill(
            child: ClipRect(
              clipper: SlidableClipper(
                axis: widget.direction,
                controller: controller,
              ),
              child: actionPane,
            ),
          ),
        content,
      ],
    );

    return SlidableGestureDetector(
      enabled: widget.enabled,
      controller: controller,
      direction: widget.direction,
      dragStartBehavior: widget.dragStartBehavior,
      child: SlidableScrollConfigurator(
        controller: controller,
        closeOnScroll: widget.closeOnScroll,
        child: DismissalTransition(
          axis: flipAxis(widget.direction),
          controller: controller,
          child: ActionPaneStyle(
            alignment: actionPaneAlignment,
            direction: widget.direction,
            fromStart: controller.ratio > 0,
            child: _SlidableControllerScope(
              controller: controller,
              child: content,
            ),
          ),
        ),
      ),
    );
  }
}

class _SlidableControllerScope extends InheritedWidget {
  const _SlidableControllerScope({
    Key key,
    @required this.controller,
    Widget child,
  }) : super(key: key, child: child);

  final SlidableController controller;

  @override
  bool updateShouldNotify(_SlidableControllerScope old) {
    return controller != old.controller;
  }
}

class ActionPaneStyle extends InheritedWidget {
  const ActionPaneStyle({
    Key key,
    @required this.alignment,
    @required this.direction,
    @required this.fromStart,
    Widget child,
  }) : super(key: key, child: child);

  final Alignment alignment;
  final Axis direction;
  final bool fromStart;

  @override
  bool updateShouldNotify(ActionPaneStyle old) {
    return alignment != old.alignment ||
        direction != old.direction ||
        fromStart != old.fromStart;
  }

  static ActionPaneStyle of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ActionPaneStyle>();
  }
}

/// Internal use.
class SlidableGestureDetector extends StatefulWidget {
  const SlidableGestureDetector({
    Key key,
    this.enabled = true,
    @required this.controller,
    @required this.direction,
    @required this.child,
    this.dragStartBehavior = DragStartBehavior.start,
  })  : assert(enabled != null),
        assert(controller != null),
        assert(child != null),
        assert(dragStartBehavior != null),
        super(key: key);

  final SlidableController controller;
  final Widget child;
  final Axis direction;
  final bool enabled;

  /// Determines the way that drag start behavior is handled.
  ///
  /// If set to [DragStartBehavior.start], the drag gesture used to dismiss a
  /// dismissible will begin upon the detection of a drag gesture. If set to
  /// [DragStartBehavior.down] it will begin when a down event is first detected.
  ///
  /// In general, setting this to [DragStartBehavior.start] will make drag
  /// animation smoother and setting it to [DragStartBehavior.down] will make
  /// drag behavior feel slightly more reactive.
  ///
  /// By default, the drag start behavior is [DragStartBehavior.start].
  ///
  /// See also:
  ///
  ///  * [DragGestureRecognizer.dragStartBehavior], which gives an example for the different behaviors.
  final DragStartBehavior dragStartBehavior;

  @override
  _SlidableGestureDetectorState createState() =>
      _SlidableGestureDetectorState();
}

class _SlidableGestureDetectorState extends State<SlidableGestureDetector> {
  double dragExtent = 0;
  Offset startPosition;
  Offset lastPosition;

  bool get directionIsXAxis {
    return widget.direction == Axis.horizontal;
  }

  @override
  Widget build(BuildContext context) {
    final canDragHorizontally = directionIsXAxis && widget.enabled;
    final canDragVertically = !directionIsXAxis && widget.enabled;
    return GestureDetector(
      onHorizontalDragStart: canDragHorizontally ? handleDragStart : null,
      onHorizontalDragUpdate: canDragHorizontally ? handleDragUpdate : null,
      onHorizontalDragEnd: canDragHorizontally ? handleDragEnd : null,
      onVerticalDragStart: canDragVertically ? handleDragStart : null,
      onVerticalDragUpdate: canDragVertically ? handleDragUpdate : null,
      onVerticalDragEnd: canDragVertically ? handleDragEnd : null,
      behavior: HitTestBehavior.opaque,
      dragStartBehavior: widget.dragStartBehavior,
      child: widget.child,
    );
  }

  double get overallDragAxisExtent {
    final Size size = context.size;
    return directionIsXAxis ? size.width : size.height;
  }

  void handleDragStart(DragStartDetails details) {
    startPosition = details.localPosition;
    dragExtent =
        dragExtent.sign * overallDragAxisExtent * widget.controller.ratio.abs();
  }

  void handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta;
    dragExtent += delta;
    lastPosition = details.localPosition;
    widget.controller.ratio = dragExtent / overallDragAxisExtent;
  }

  void handleDragEnd(DragEndDetails details) {
    final delta = lastPosition - startPosition;
    final primaryDelta = directionIsXAxis ? delta.dx : delta.dy;
    final gestureDirection =
        primaryDelta >= 0 ? GestureDirection.opening : GestureDirection.closing;

    widget.controller.handleEndGesture(
      details.primaryVelocity,
      gestureDirection,
    );
  }
}

class SlidableClipper extends CustomClipper<Rect> {
  SlidableClipper({
    @required this.axis,
    @required this.controller,
  })  : assert(axis != null),
        assert(controller != null),
        super(reclip: controller);

  final Axis axis;
  final SlidableController controller;

  @override
  Rect getClip(Size size) {
    assert(axis != null);
    switch (axis) {
      case Axis.horizontal:
        final double offset = controller.ratio * size.width;
        if (offset < 0) {
          return Rect.fromLTRB(size.width + offset, 0, size.width, size.height);
        }
        return Rect.fromLTRB(0, 0, offset, size.height);
      case Axis.vertical:
        final double offset = controller.ratio * size.height;
        if (offset < 0) {
          return Rect.fromLTRB(
              0, size.height + offset, size.width, size.height);
        }
        return Rect.fromLTRB(0, 0, size.width, offset);
    }
    return null;
  }

  @override
  Rect getApproximateClipRect(Size size) => getClip(size);

  @override
  bool shouldReclip(SlidableClipper oldClipper) {
    return oldClipper.axis != axis ||
        oldClipper.controller.ratio != controller.ratio;
  }
}
