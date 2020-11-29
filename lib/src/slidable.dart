import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'action_pane.dart';
import 'controller.dart';
import 'dismissal_transition.dart';
import 'gesture_detector.dart';
import 'notifications.dart';
import 'scrolling_behavior.dart';

class Slidable extends StatefulWidget {
  const Slidable({
    Key key,
    this.tag,
    this.enabled = true,
    this.closeOnScroll = true,
    this.startActionPane,
    this.endActionPane,
    this.direction = Axis.horizontal,
    this.dragStartBehavior = DragStartBehavior.down,
    this.useTextDirection = true,
    @required this.child,
  })  : assert(enabled != null),
        assert(closeOnScroll != null),
        assert(direction != null),
        assert(dragStartBehavior != null),
        assert(useTextDirection != null),
        assert(child != null),
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

  final ActionPane startActionPane;
  final ActionPane endActionPane;
  final Axis direction;
  final Widget child;
  final Object tag;
  final bool useTextDirection;

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
  bool keepPanesOrder;

// TODO.
  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    controller = SlidableController(this)
      ..actionPaneType.addListener(handleActionPanelTypeChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateIsLeftToRight();
    updateController();
    updateMoveAnimation();
  }

  @override
  void didUpdateWidget(covariant Slidable oldWidget) {
    super.didUpdateWidget(oldWidget);
    updateIsLeftToRight();
    updateController();
  }

  @override
  void dispose() {
    controller.actionPaneType.removeListener(handleActionPanelTypeChanged);
    controller.dispose();
    super.dispose();
  }

  void updateController() {
    if (startActionPane != null) {
      controller
        ..enableStartActionPane = true
        ..startActionPaneExtentRatio = startActionPane.extentRatio;
    }

    if (endActionPane != null) {
      controller
        ..enableEndActionPane = true
        ..endActionPaneExtentRatio = endActionPane.extentRatio;
    }
  }

  void updateIsLeftToRight() {
    final textDirection = Directionality.of(context);
    keepPanesOrder = widget.direction == Axis.vertical ||
        !widget.useTextDirection ||
        textDirection == null ||
        textDirection == TextDirection.ltr;
  }

  void handleActionPanelTypeChanged() {
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
    final double end = controller.actionPaneType.value.toSign();
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
    switch (controller.actionPaneType.value) {
      case ActionPaneType.start:
        return startActionPane;
      case ActionPaneType.end:
        return endActionPane;
      default:
        return null;
    }
  }

  ActionPane get startActionPane =>
      keepPanesOrder ? widget.startActionPane : widget.endActionPane;
  ActionPane get endActionPane =>
      keepPanesOrder ? widget.endActionPane : widget.startActionPane;

  Alignment get actionPaneAlignment {
    final sign = controller.actionPaneType.value.toSign();
    if (widget.direction == Axis.horizontal) {
      return Alignment(-sign, 0);
    } else {
      return Alignment(0, -sign);
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
      child: SlidableNotificationSender(
        tag: widget.tag,
        controller: controller,
        child: SlidableScrollingBehavior(
          controller: controller,
          closeOnScroll: widget.closeOnScroll,
          child: DismissalTransition(
            axis: flipAxis(widget.direction),
            controller: controller,
            child: ActionPaneConfiguration(
              alignment: actionPaneAlignment,
              direction: widget.direction,
              isStartActionPane:
                  controller.actionPaneType.value == ActionPaneType.start,
              child: _SlidableControllerScope(
                controller: controller,
                child: content,
              ),
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

class ActionPaneConfiguration extends InheritedWidget {
  const ActionPaneConfiguration({
    Key key,
    @required this.alignment,
    @required this.direction,
    @required this.isStartActionPane,
    Widget child,
  }) : super(key: key, child: child);

  final Alignment alignment;
  final Axis direction;
  final bool isStartActionPane;

  @override
  bool updateShouldNotify(ActionPaneConfiguration old) {
    return alignment != old.alignment ||
        direction != old.direction ||
        isStartActionPane != old.isStartActionPane;
  }

  static ActionPaneConfiguration of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ActionPaneConfiguration>();
  }
}

class SlidableClipper extends CustomClipper<Rect> {
  SlidableClipper({
    @required this.axis,
    @required this.controller,
  })  : assert(axis != null),
        assert(controller != null),
        super(reclip: controller.animation);

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
            0,
            size.height + offset,
            size.width,
            size.height,
          );
        }
        return Rect.fromLTRB(0, 0, size.width, offset);
    }
    return null;
  }

  @override
  Rect getApproximateClipRect(Size size) => getClip(size);

  @override
  bool shouldReclip(SlidableClipper oldClipper) {
    return oldClipper.axis != axis;
  }
}
