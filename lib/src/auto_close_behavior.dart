import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/src/controller.dart';
import 'package:flutter_slidable/src/notifications.dart';

/// A widget that forces the [Slidable] widgets below it to close when another
/// [Slidable] widget with the same [groupTag] opens.
class SlidableAutoCloseBehavior extends StatelessWidget {
  /// Creates a [SlidableAutoCloseBehavior].
  const SlidableAutoCloseBehavior({
    Key? key,
    required this.child,
  }) : super(key: key);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlidableGroupBehavior<SlidableAutoCloseNotification>(
      child: child,
    );
  }
}

/// INTERNAL USE
class SlidableAutoCloseBehaviorListener extends StatelessWidget {
  /// INTERNAL USE
  const SlidableAutoCloseBehaviorListener({
    Key? key,
    required this.groupTag,
    required this.controller,
    required this.child,
  }) : super(key: key);

  /// {@macro slidable.groupTag}
  final Object? groupTag;

  /// {@macro slidable.controller}
  final SlidableController controller;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SlidableGroupBehaviorListener<SlidableAutoCloseNotification>(
      onNotification: (SlidableAutoCloseNotification notification) {
        if (groupTag == notification.groupTag &&
            notification.controller != controller &&
            !controller.closing) {
          controller.close();
        }
      },
      child: child,
    );
  }
}

/// A notification used to close other [Slidable] widgets with the same
/// [groupTag].
@immutable
class SlidableAutoCloseNotification {
  /// Creates a notification that can be used to close other [Slidable] widgets
  /// with the same [groupTag].
  const SlidableAutoCloseNotification({
    required this.groupTag,
    required this.controller,
  });

  /// {@macro slidable.groupTag}
  final Object? groupTag;

  /// {@template slidable.controller}
  /// The [SlidableController] associated.
  /// {@endtemplate}
  final SlidableController controller;
}

/// INTERNAL USE
class SlidableAutoCloseNotificationSender extends StatefulWidget {
  /// INTERNAL USE
  const SlidableAutoCloseNotificationSender({
    Key? key,
    required this.groupTag,
    required this.controller,
    required this.child,
  }) : super(key: key);

  /// {@macro slidable.groupTag}
  final Object? groupTag;

  /// {@macro slidable.controller}
  final SlidableController controller;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  _SlidableAutoCloseNotificationSenderState createState() =>
      _SlidableAutoCloseNotificationSenderState();
}

class _SlidableAutoCloseNotificationSenderState
    extends State<SlidableAutoCloseNotificationSender> {
  @override
  void initState() {
    super.initState();
    addListeners();
  }

  @override
  void didUpdateWidget(SlidableAutoCloseNotificationSender oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      removeListeners();
      addListeners();
    }
  }

  @override
  void dispose() {
    removeListeners();
    super.dispose();
  }

  void addListeners() {
    widget.controller.animation.addStatusListener(handleStatusChanged);
  }

  void removeListeners() {
    widget.controller.animation.addStatusListener(handleStatusChanged);
  }

  void handleStatusChanged(AnimationStatus status) {
    final moving =
        status == AnimationStatus.forward || status == AnimationStatus.reverse;
    if (moving && !widget.controller.closing) {
      SlidableGroupNotification.dispatch(
        context,
        SlidableAutoCloseNotification(
          groupTag: widget.groupTag,
          controller: widget.controller,
        ),
        assertParentExists: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
