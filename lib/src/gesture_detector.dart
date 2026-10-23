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
  final Map<int, Offset> _pointerInitialPositions = <int, Offset>{};
  final Set<int> _dragActivePointers = <int>{};

  bool get isHorizontal;

  static Offset _getLocalPosition(PointerEvent event) {
    if (event is PointerPanZoomUpdateEvent) {
      return event.localPan;
    }
    return event.localPosition;
  }

  @override
  void addAllowedPointer(PointerDownEvent event) {
    _pointerInitialPositions[event.pointer] = event.localPosition;
    super.addAllowedPointer(event);
  }

  @override
  void addAllowedPointerPanZoom(PointerPanZoomStartEvent event) {
    _pointerInitialPositions[event.pointer] = Offset.zero;
    super.addAllowedPointerPanZoom(event);
  }

  @override
  void handleEvent(PointerEvent event) {
    if (event is PointerDownEvent) {
      _pointerInitialPositions[event.pointer] = event.localPosition;
    } else if (event is PointerPanZoomStartEvent) {
      _pointerInitialPositions[event.pointer] = Offset.zero;
    }

    if (!_dragActivePointers.contains(event.pointer)) {
      if (event is PointerMoveEvent || event is PointerPanZoomUpdateEvent) {
        final Offset? startPosition = _pointerInitialPositions[event.pointer];
        if (startPosition != null) {
          final Offset localPosition = _getLocalPosition(event);
          final Offset totalLocalDelta = event is PointerPanZoomUpdateEvent
              ? (event.localPan -
                  PointerEvent.transformPosition(event.transform, Offset.zero))
              : (localPosition - startPosition);
          final double primaryDelta = isHorizontal
              ? totalLocalDelta.dx.abs()
              : totalLocalDelta.dy.abs();
          final double crossDelta = isHorizontal
              ? totalLocalDelta.dy.abs()
              : totalLocalDelta.dx.abs();

          final Matrix4? localToGlobalTransform = event.transform == null
              ? null
              : Matrix4.tryInvert(event.transform!);

          final Offset untransformedEndPosition =
              event is PointerPanZoomUpdateEvent
                  ? event.localPosition + event.localPan
                  : localPosition;

          final Offset localCrossVector = isHorizontal
              ? Offset(0, totalLocalDelta.dy)
              : Offset(totalLocalDelta.dx, 0);

          final double globalCrossDistance =
              PointerEvent.transformDeltaViaPositions(
            transform: localToGlobalTransform,
            untransformedDelta: localCrossVector,
            untransformedEndPosition: untransformedEndPosition,
          ).distance;

          final double touchSlop = computeHitSlop(event.kind, gestureSettings);

          if (globalCrossDistance > touchSlop && crossDelta >= primaryDelta) {
            rejectGesture(event.pointer);
            return;
          }

          final Offset localPrimaryVector = isHorizontal
              ? Offset(totalLocalDelta.dx, 0)
              : Offset(0, totalLocalDelta.dy);

          final double globalPrimaryDistance =
              PointerEvent.transformDeltaViaPositions(
            transform: localToGlobalTransform,
            untransformedDelta: localPrimaryVector,
            untransformedEndPosition: untransformedEndPosition,
          ).distance;

          if (globalPrimaryDistance > touchSlop && primaryDelta > crossDelta) {
            _dragActivePointers.add(event.pointer);
          }
        }
      }
    }
    super.handleEvent(event);
  }

  @override
  void stopTrackingPointer(int pointer) {
    _pointerInitialPositions.remove(pointer);
    _dragActivePointers.remove(pointer);
    super.stopTrackingPointer(pointer);
  }

  @override
  void rejectGesture(int pointer) {
    _pointerInitialPositions.remove(pointer);
    _dragActivePointers.remove(pointer);
    super.rejectGesture(pointer);
  }

  @override
  void didStopTrackingLastPointer(int pointer) {
    _pointerInitialPositions.clear();
    _dragActivePointers.clear();
    super.didStopTrackingLastPointer(pointer);
  }

  @override
  void dispose() {
    _pointerInitialPositions.clear();
    _dragActivePointers.clear();
    super.dispose();
  }
}

class _SlidableHorizontalDragGestureRecognizer
    extends HorizontalDragGestureRecognizer
    with _SlidableDragGestureRecognizerMixin {
  _SlidableHorizontalDragGestureRecognizer({super.debugOwner});

  @override
  bool get isHorizontal => true;
}

class _SlidableVerticalDragGestureRecognizer
    extends VerticalDragGestureRecognizer
    with _SlidableDragGestureRecognizerMixin {
  _SlidableVerticalDragGestureRecognizer({super.debugOwner});

  @override
  bool get isHorizontal => false;
}
