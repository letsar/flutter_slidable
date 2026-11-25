import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'controller.dart';

// INTERNAL USE
// ignore_for_file: public_member_api_docs

class SlidableGestureDetector extends StatefulWidget {
  const SlidableGestureDetector({
    super.key,
    this.enabled = true,
    required this.controller,
    required this.direction,
    required this.child,
    this.dragStartBehavior = DragStartBehavior.start,
  });

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
  late Offset startPosition;
  late Offset lastPosition;

  bool get directionIsXAxis {
    return widget.direction == Axis.horizontal;
  }

  @override
  Widget build(BuildContext context) {
    final canDragHorizontally = directionIsXAxis && widget.enabled;
    final canDragVertically = !directionIsXAxis && widget.enabled;
    return RawGestureDetector(
      gestures: <Type, GestureRecognizerFactory>{
        if (canDragHorizontally)
          _HorizontalDragGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<
                  _HorizontalDragGestureRecognizer>(
            () => _HorizontalDragGestureRecognizer(debugOwner: this),
            _configureRecognizer,
          ),
        if (canDragVertically)
          _VerticalDragGestureRecognizer: GestureRecognizerFactoryWithHandlers<
              _VerticalDragGestureRecognizer>(
            () => _VerticalDragGestureRecognizer(debugOwner: this),
            _configureRecognizer,
          ),
      },
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }

  void _configureRecognizer(DragGestureRecognizer instance) {
    instance
      ..onStart = handleDragStart
      ..onUpdate = handleDragUpdate
      ..onEnd = handleDragEnd
      ..dragStartBehavior = widget.dragStartBehavior
      ..gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
  }

  double get overallDragAxisExtent {
    final Size? size = context.size;
    return directionIsXAxis ? size!.width : size!.height;
  }

  void handleDragStart(DragStartDetails details) {
    startPosition = details.localPosition;
    lastPosition = startPosition;
    widget.controller.beginDrag();
    dragExtent = overallDragAxisExtent * widget.controller.movementRatio;
  }

  void handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta!;
    dragExtent += delta;
    lastPosition = details.localPosition;
    widget.controller.dragTo(dragExtent / overallDragAxisExtent);
  }

  void handleDragEnd(DragEndDetails details) {
    final delta = lastPosition - startPosition;
    final primaryDelta = directionIsXAxis ? delta.dx : delta.dy;
    final gestureDirection =
        primaryDelta >= 0 ? GestureDirection.opening : GestureDirection.closing;

    widget.controller.endDrag(
      details.primaryVelocity,
      gestureDirection,
    );
  }
}

/// Only accepts the drag when the movement is predominantly along the main
/// axis, so that diagonal scrolls are left to the enclosing [Scrollable].
///
/// The default drag recognizers only look at the main axis component of the
/// movement. When both the main and cross axis components exceed the touch slop
/// within the same pointer event (typically during a fast diagonal scroll),
/// the slidable would win the arena because it is deeper in the hit test.
mixin _DominantAxisDragGestureRecognizer on OneSequenceGestureRecognizer {
  Offset _globalOffset = Offset.zero;

  Axis get axis;

  bool get isMovingAlongAxis {
    final mainDistance = axis == Axis.horizontal
        ? _globalOffset.dx.abs()
        : _globalOffset.dy.abs();
    final crossDistance = axis == Axis.horizontal
        ? _globalOffset.dy.abs()
        : _globalOffset.dx.abs();
    return mainDistance > crossDistance;
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerMoveEvent) {
      _globalOffset += event.delta;
    } else if (event is PointerPanZoomUpdateEvent) {
      _globalOffset += event.panDelta;
    }
    super.handleEvent(event);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _globalOffset = Offset.zero;
    super.didStopTrackingLastPointer(pointer);
  }
}

class _HorizontalDragGestureRecognizer extends HorizontalDragGestureRecognizer
    with _DominantAxisDragGestureRecognizer {
  _HorizontalDragGestureRecognizer({super.debugOwner});

  @override
  Axis get axis => Axis.horizontal;

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    return isMovingAlongAxis &&
        super.hasSufficientGlobalDistanceToAccept(
          pointerDeviceKind,
          deviceTouchSlop,
        );
  }
}

class _VerticalDragGestureRecognizer extends VerticalDragGestureRecognizer
    with _DominantAxisDragGestureRecognizer {
  _VerticalDragGestureRecognizer({super.debugOwner});

  @override
  Axis get axis => Axis.vertical;

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    return isMovingAlongAxis &&
        super.hasSufficientGlobalDistanceToAccept(
          pointerDeviceKind,
          deviceTouchSlop,
        );
  }
}
