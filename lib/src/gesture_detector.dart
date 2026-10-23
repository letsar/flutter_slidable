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

    final gestures = <Type, GestureRecognizerFactory>{};

    if (canDragHorizontally) {
      gestures[_SlidableHorizontalDragGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<
              _SlidableHorizontalDragGestureRecognizer>(
        () => _SlidableHorizontalDragGestureRecognizer(debugOwner: this),
        (_SlidableHorizontalDragGestureRecognizer instance) {
          instance
            ..onStart = handleDragStart
            ..onUpdate = handleDragUpdate
            ..onEnd = handleDragEnd
            ..dragStartBehavior = widget.dragStartBehavior
            ..gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
        },
      );
    }

    if (canDragVertically) {
      gestures[_SlidableVerticalDragGestureRecognizer] =
          GestureRecognizerFactoryWithHandlers<
              _SlidableVerticalDragGestureRecognizer>(
        () => _SlidableVerticalDragGestureRecognizer(debugOwner: this),
        (_SlidableVerticalDragGestureRecognizer instance) {
          instance
            ..onStart = handleDragStart
            ..onUpdate = handleDragUpdate
            ..onEnd = handleDragEnd
            ..dragStartBehavior = widget.dragStartBehavior
            ..gestureSettings = MediaQuery.maybeGestureSettingsOf(context);
        },
      );
    }

    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: gestures,
      child: widget.child,
    );
  }

  double get overallDragAxisExtent {
    final Size? size = context.size;
    return directionIsXAxis ? size!.width : size!.height;
  }

  void handleDragStart(DragStartDetails details) {
    startPosition = details.localPosition;
    lastPosition = startPosition;
    dragExtent = dragExtent.sign *
        overallDragAxisExtent *
        widget.controller.ratio *
        widget.controller.direction.value;
  }

  void handleDragUpdate(DragUpdateDetails details) {
    final delta = details.primaryDelta!;
    dragExtent += delta;
    lastPosition = details.localPosition;
    widget.controller.ratio = dragExtent / overallDragAxisExtent;
  }

  void handleDragEnd(DragEndDetails details) {
    final delta = lastPosition - startPosition;
    final primaryDelta = directionIsXAxis ? delta.dx : delta.dy;
    final gestureDirection =
        primaryDelta >= 0 ? GestureDirection.opening : GestureDirection.closing;

    widget.controller.dispatchEndGesture(
      details.primaryVelocity,
      gestureDirection,
    );
  }
}

mixin _SlidableDragGestureRecognizerMixin on OneSequenceGestureRecognizer {
  final Map<int, Offset> _pointerOffsets = <int, Offset>{};
  bool _dragStarted = false;
  bool _canAcceptGesture = true;

  bool get isHorizontal;

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _pointerOffsets[event.pointer] = event.position;
    _dragStarted = false;
    _canAcceptGesture = true;
    super.addAllowedPointer(event);
  }

  @override
  void addAllowedPointerPanZoom(PointerPanZoomStartEvent event) {
    _pointerOffsets[event.pointer] = Offset.zero;
    _dragStarted = false;
    _canAcceptGesture = true;
    super.addAllowedPointerPanZoom(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (!_dragStarted) {
      if (event is PointerMoveEvent || event is PointerPanZoomUpdateEvent) {
        final Offset? startPosition = _pointerOffsets[event.pointer];
        if (startPosition != null) {
          final Offset totalOffset = event is PointerMoveEvent
              ? event.position - startPosition
              : (event as PointerPanZoomUpdateEvent).pan - startPosition;
          final double primaryAxisDelta =
              isHorizontal ? totalOffset.dx.abs() : totalOffset.dy.abs();
          final double crossAxisDelta =
              isHorizontal ? totalOffset.dy.abs() : totalOffset.dx.abs();

          final double touchSlop = computeHitSlop(event.kind, gestureSettings);
          if (crossAxisDelta > touchSlop &&
              crossAxisDelta >= primaryAxisDelta) {
            _canAcceptGesture = false;
            resolvePointer(event.pointer, GestureDisposition.rejected);
            stopTrackingPointer(event.pointer);
            return;
          }

          if (primaryAxisDelta > touchSlop &&
              primaryAxisDelta > crossAxisDelta) {
            _dragStarted = true;
          }
        }
      }
    }
    super.handleEvent(event);
  }

  @override
  void rejectGesture(int pointer) {
    _pointerOffsets.remove(pointer);
    super.rejectGesture(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _pointerOffsets.clear();
    _dragStarted = false;
    _canAcceptGesture = true;
    super.didStopTrackingLastPointer(pointer);
  }

  @override
  void dispose() {
    _pointerOffsets.clear();
    super.dispose();
  }
}

class _SlidableHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer
    with _SlidableDragGestureRecognizerMixin {
  _SlidableHorizontalDragGestureRecognizer({super.debugOwner});

  @override
  bool get isHorizontal => true;

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    if (!_canAcceptGesture) {
      return false;
    }
    return super.hasSufficientGlobalDistanceToAccept(
      pointerDeviceKind,
      deviceTouchSlop,
    );
  }
}

class _SlidableVerticalDragGestureRecognizer
    extends VerticalDragGestureRecognizer
    with _SlidableDragGestureRecognizerMixin {
  _SlidableVerticalDragGestureRecognizer({super.debugOwner});

  @override
  bool get isHorizontal => false;

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    if (!_canAcceptGesture) {
      return false;
    }
    return super.hasSufficientGlobalDistanceToAccept(
      pointerDeviceKind,
      deviceTouchSlop,
    );
  }
}
