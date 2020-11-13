import 'package:flutter/material.dart';
import 'package:flutter_slidable/src/slidable_controller.dart';

class DismissalTransition extends StatefulWidget {
  const DismissalTransition({
    Key key,
    @required this.axis,
    @required this.child,
    @required this.controller,
  })  : assert(axis != null),
        assert(controller != null),
        assert(child != null),
        super(key: key);

  final Axis axis;
  final Widget child;
  final SlidableController controller;

  @override
  _DismissalTransitionState createState() => _DismissalTransitionState();
}

class _DismissalTransitionState extends State<DismissalTransition>
    with SingleTickerProviderStateMixin {
  Size sizePriorToCollapse;
  AnimationController animationController;
  Animation<double> resizeAnimation;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(vsync: this);
    resizeAnimation = animationController.drive(Tween(begin: 1, end: 0));
    widget.controller.animation
        .addStatusListener(handleSlidableAnimationStatusChanged);
  }

  @override
  void didUpdateWidget(covariant DismissalTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller.animation != widget.controller.animation) {
      oldWidget.controller.animation
          .removeStatusListener(handleSlidableAnimationStatusChanged);
      widget.controller.animation
          .addStatusListener(handleSlidableAnimationStatusChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.animation
        .removeStatusListener(handleSlidableAnimationStatusChanged);
    animationController.dispose();
    super.dispose();
  }

  void handleSlidableAnimationStatusChanged(AnimationStatus status) {
    final dismissRequest = widget.controller.dismissRequest;
    if (status == AnimationStatus.completed && dismissRequest != null) {
      animationController.duration = dismissRequest.duration;
      animationController.forward(from: 0).then((_) {
        sizePriorToCollapse = null;
        dismissRequest.onDismissed?.call();
      });
      setState(() {
        sizePriorToCollapse = context.size;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget result = widget.child;

    if (sizePriorToCollapse != null) {
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

      result = SizeTransition(
        sizeFactor: resizeAnimation,
        axis: widget.axis,
        child: SizedBox(
          width: sizePriorToCollapse.width,
          height: sizePriorToCollapse.height,
          child: result,
        ),
      );
    }

    return result;
  }
}
