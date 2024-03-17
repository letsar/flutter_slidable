import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import 'controller.dart';

// INTERNAL USE
// ignore_for_file: public_member_api_docs

class SlidableGestureListener extends StatefulWidget {
  const SlidableGestureListener({
    Key? key,
    this.enabled = true,
    required this.controller,
    required this.direction,
    required this.child,
    this.dragStartBehavior = DragStartBehavior.start,
  }) : super(key: key);

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
  _SlidableGestureListenerState createState() =>
      _SlidableGestureListenerState();
}

class _SlidableGestureListenerState extends State<SlidableGestureListener> {
  double dragExtent = 0;
  late Offset startPosition;
  late Offset lastPosition;
  DateTime? startTime;
  DateTime? endTime;

  late DateTime lastTime;
  double? lastVelocity;

  bool get directionIsXAxis {
    return widget.direction == Axis.horizontal;
  }

  @override
  Widget build(BuildContext context) {
    final canDrag = widget.enabled;
    return Listener(
      onPointerDown: canDrag ? handlePointerDown : null,
      onPointerMove: canDrag ? handlePointerMove : null,
      onPointerUp: canDrag ? handlePointerUp : null,
      behavior: HitTestBehavior.opaque,
      child: widget.child,
    );
  }

  double get overallDragAxisExtent {
    final Size? size = context.size;
    return directionIsXAxis ? size!.width : size!.height;
  }

  void handlePointerDown(PointerDownEvent event) {
    startTime = DateTime.now();
    startPosition = event.localPosition;
    lastPosition = startPosition;
    dragExtent = dragExtent.sign *
        overallDragAxisExtent *
        widget.controller.ratio *
        widget.controller.direction.value;

    lastTime = DateTime.now();
  }

  void handlePointerMove(PointerMoveEvent event) {
    final delta = directionIsXAxis ? event.delta.dx : event.delta.dy;
    dragExtent += delta;
    lastPosition = event.localPosition;
    widget.controller.ratio = dragExtent / overallDragAxisExtent;

    final now = DateTime.now();
    final deltaTime =
        now.difference(lastTime).inMilliseconds / 1000.0; // 秒単位で変化量を計算
    lastVelocity = delta / deltaTime;
    lastTime = now;
  }

  void handlePointerUp(PointerUpEvent event) {
    endTime = DateTime.now();
    final delta = lastPosition - startPosition;
    final primaryDelta = directionIsXAxis ? delta.dx : delta.dy;
    final gestureDirection =
        primaryDelta >= 0 ? GestureDirection.opening : GestureDirection.closing;

    widget.controller.dispatchEndGesture(
      currentVelocity(),
      gestureDirection,
    );
    lastVelocity = null;
  }

  double? currentVelocity() {
    if (lastVelocity == null) {
      return null;
    }
    if (lastVelocity!.abs() < 20) {
      lastVelocity = null;
      return null;
    }

    print('lastVelocity: $lastVelocity');
    return lastVelocity;
  }
}
