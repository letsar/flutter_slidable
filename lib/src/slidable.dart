import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'action_pane_configuration.dart';
import 'controller.dart';
import 'dismissal.dart';
import 'gesture_detector.dart';
import 'notifications.dart';
import 'scrolling_behavior.dart';

part 'action_pane.dart';

/// A widget which can be dragged to reveal contextual actions.
class Slidable extends StatefulWidget {
  /// Creates a [Slidable].
  ///
  /// The [enabled], [closeOnScroll], [direction], [dragStartBehavior],
  /// [useTextDirection] and [child] arguments must not be null.
  const Slidable({
    Key? key,
    this.groupTag,
    this.enabled = true,
    this.closeOnScroll = true,
    this.startActionPane,
    this.endActionPane,
    this.direction = Axis.horizontal,
    this.dragStartBehavior = DragStartBehavior.down,
    this.useTextDirection = true,
    required this.child,
  }) : super(key: key);

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

  /// The tag shared by all the [Slidable]s of the same group.
  ///
  /// This is used by [SlidableNotificationListener] to keep only one [Slidable]
  /// of the same group, open.
  final Object? groupTag;

  /// A widget which is shown when the user drags the [Slidable] to the right or
  /// to the bottom.
  ///
  /// When [direction] is [Axis.horizontal] and [useTextDirection] is true, the
  /// [startActionPane] is determined by the ambient [TextDirection].
  final ActionPane? startActionPane;

  /// A widget which is shown when the user drags the [Slidable] to the left or
  /// to the top.
  ///
  /// When [direction] is [Axis.horizontal] and [useTextDirection] is true, the
  /// [startActionPane] is determined by the ambient [TextDirection].
  final ActionPane? endActionPane;

  /// The direction in which this [Slidable] can be dragged.
  ///
  /// Defaults to [Axis.horizontal].
  final Axis direction;

  /// Whether the ambient [TextDirection] should be used to determine how
  /// [startActionPane] and [endActionPane] should be revealed.
  ///
  /// If [direction] is [Axis.vertical], this has no effect.
  /// If [direction] is [Axis.horizontal], then [startActionPane] is revealed
  /// when the users drags to the reading direction (and in the inverse of the
  /// reading direction for [endActionPane]).
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

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  _SlidableState createState() => _SlidableState();

  /// The closest instance of the [SlidableController] which controls this
  /// [Slidable] that encloses the given context.
  ///
  /// {@tool snippet}
  /// Typical usage is as follows:
  ///
  /// ```dart
  /// SlidableController controller = Slidable.of(context);
  /// ```
  /// {@end-tool}
  static SlidableController? of(BuildContext context) {
    final scope = context
        .getElementForInheritedWidgetOfExactType<_SlidableControllerScope>()
        ?.widget as _SlidableControllerScope?;
    return scope?.controller;
  }
}

class _SlidableState extends State<Slidable>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  SlidableController? controller;
  late Animation<Offset> moveAnimation;
  late bool keepPanesOrder;

  @override
  bool get wantKeepAlive => !widget.closeOnScroll;

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
    controller!.actionPaneType.removeListener(handleActionPanelTypeChanged);
    controller!.dispose();
    super.dispose();
  }

  void updateController() {
    controller!
      ..enableStartActionPane = widget.startActionPane != null
      ..startActionPaneExtentRatio = startActionPane?.extentRatio ?? 0;

    controller!
      ..enableEndActionPane = widget.endActionPane != null
      ..endActionPaneExtentRatio = endActionPane?.extentRatio ?? 0;
  }

  void updateIsLeftToRight() {
    final textDirection = Directionality.of(context);
    keepPanesOrder = widget.direction == Axis.vertical ||
        !widget.useTextDirection ||
        textDirection == TextDirection.ltr;
  }

  void handleActionPanelTypeChanged() {
    setState(() {
      updateMoveAnimation();
    });
  }

  void handleDismissing() {
    if (controller!.resizeRequest.value != null) {
      setState(() {});
    }
  }

  void updateMoveAnimation() {
    final double end = controller!.actionPaneType.value.toSign();
    moveAnimation = controller!.animation.drive(
      Tween<Offset>(
        begin: Offset.zero,
        end: widget.direction == Axis.horizontal
            ? Offset(end, 0)
            : Offset(0, end),
      ),
    );
  }

  Widget? get actionPane {
    switch (controller!.actionPaneType.value) {
      case ActionPaneType.start:
        return startActionPane;
      case ActionPaneType.end:
        return endActionPane;
      default:
        return null;
    }
  }

  ActionPane? get startActionPane =>
      keepPanesOrder ? widget.startActionPane : widget.endActionPane;
  ActionPane? get endActionPane =>
      keepPanesOrder ? widget.endActionPane : widget.startActionPane;

  Alignment get actionPaneAlignment {
    final sign = controller!.actionPaneType.value.toSign();
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
              clipper: _SlidableClipper(
                axis: widget.direction,
                controller: controller!,
              ),
              child: actionPane,
            ),
          ),
        content,
      ],
    );

    return SlidableGestureDetector(
      enabled: widget.enabled,
      controller: controller!,
      direction: widget.direction,
      dragStartBehavior: widget.dragStartBehavior,
      child: SlidableNotificationSender(
        tag: widget.groupTag,
        controller: controller!,
        child: SlidableScrollingBehavior(
          controller: controller!,
          closeOnScroll: widget.closeOnScroll,
          child: SlidableDismissal(
            axis: flipAxis(widget.direction),
            controller: controller!,
            child: ActionPaneConfiguration(
              alignment: actionPaneAlignment,
              direction: widget.direction,
              isStartActionPane:
                  controller!.actionPaneType.value == ActionPaneType.start,
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
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  final SlidableController? controller;

  @override
  bool updateShouldNotify(_SlidableControllerScope old) {
    return controller != old.controller;
  }
}

class _SlidableClipper extends CustomClipper<Rect> {
  _SlidableClipper({
    required this.axis,
    required this.controller,
  }) : super(reclip: controller.animation);

  final Axis axis;
  final SlidableController controller;

  @override
  Rect getClip(Size size) {
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
  }

  @override
  Rect getApproximateClipRect(Size size) => getClip(size);

  @override
  bool shouldReclip(_SlidableClipper oldClipper) {
    return oldClipper.axis != axis;
  }
}
