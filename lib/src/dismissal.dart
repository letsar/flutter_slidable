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

    return SizeTransition(
      sizeFactor: resizeAnimation,
      axis: widget.axis,
      child: widget.child,
    );
  }
}
