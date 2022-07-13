import 'dart:math' as math;

import 'package:flutter/widgets.dart';

import 'controller.dart';

// INTERNAL USE
// ignore_for_file: public_member_api_docs

class SlidableDismissal extends StatefulWidget {
  const SlidableDismissal({
    Key? key,
    required this.axis,
    required this.controller,
    required this.child,
  }) : super(key: key);

  final Axis axis;
  final Widget child;
  final SlidableController controller;

  @override
  _SlidableDismissalState createState() => _SlidableDismissalState();
}

class _SlidableDismissalState extends State<SlidableDismissal>
    with SingleTickerProviderStateMixin {
  bool resized = false;
  late AnimationController animationController;
  late Animation<double> resizeAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(vsync: this);
    resizeAnimation = animationController.drive(Tween(begin: 1, end: 0));
    widget.controller.resizeRequest.addListener(handleResizeRequestChanged);
  }

  @override
  void didUpdateWidget(covariant SlidableDismissal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.resizeRequest
          .removeListener(handleResizeRequestChanged);
      widget.controller.resizeRequest.addListener(handleResizeRequestChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.resizeRequest.removeListener(handleResizeRequestChanged);
    animationController.dispose();
    super.dispose();
  }

  void handleResizeRequestChanged() {
    final resizeRequest = widget.controller.resizeRequest.value;

    if (widget.controller.animation.status == AnimationStatus.completed) {
      animationController.duration = resizeRequest!.duration;
      animationController.forward(from: 0).then((_) {
        resizeRequest.onDismissed.call();
      });
      setState(() {
        resized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (resized) {
      assert(() {
        if (resizeAnimation.status != AnimationStatus.forward) {
          assert(resizeAnimation.status == AnimationStatus.completed);
          throw FlutterError.fromParts(
            <DiagnosticsNode>[
              ErrorSummary(
                'A dismissed Slidable widget is still part of the tree.',
              ),
              ErrorHint(
                'Make sure to implement the onDismissed handle of the '
                'ActionPane and to immediately remove the Slidable widget from '
                'the application once that handler has fired.',
              )
            ],
          );
        }
        return true;
      }());
    }

    return _SizeTransition(
      sizeFactor: resizeAnimation,
      axis: widget.axis,
      child: widget.child,
    );
  }
}

/// We use a custom SizeTransition to not clip when the sizeFactor is 1.
class _SizeTransition extends AnimatedWidget {
  /// Creates a size transition.
  ///
  /// The [axis], [sizeFactor], and [axisAlignment] arguments must not be null.
  /// The [axis] argument defaults to [Axis.vertical]. The [axisAlignment]
  /// defaults to 0.0, which centers the child along the main axis during the
  /// transition.
  const _SizeTransition({
    Key? key,
    this.axis = Axis.vertical,
    required Animation<double> sizeFactor,
    this.child,
  }) : super(key: key, listenable: sizeFactor);

  /// [Axis.horizontal] if [sizeFactor] modifies the width, otherwise
  /// [Axis.vertical].
  final Axis axis;

  /// The animation that controls the (clipped) size of the child.
  ///
  /// The width or height (depending on the [axis] value) of this widget will be
  /// its intrinsic width or height multiplied by [sizeFactor]'s value at the
  /// current point in the animation.
  ///
  /// If the value of [sizeFactor] is less than one, the child will be clipped
  /// in the appropriate axis.
  Animation<double> get sizeFactor => listenable as Animation<double>;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final value = math.max<double>(sizeFactor.value, 0);
    final AlignmentDirectional alignment;
    if (axis == Axis.vertical) {
      alignment = const AlignmentDirectional(-1, 0);
    } else {
      alignment = const AlignmentDirectional(0, -1);
    }
    return ClipRect(
//       clipBehavior: value == 1 ? Clip.none : Clip.hardEdge,
            clipBehavior: Clip.hardEdge,
      child: Align(
        alignment: alignment,
        heightFactor: axis == Axis.vertical ? value : null,
        widthFactor: axis == Axis.horizontal ? value : null,
        child: child,
      ),
    );
  }
}
