import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/src/slidable_controller.dart';

typedef SlidableNotificationCallback = void Function(
  SlidableNotification notification,
);

class SlidableNotification {
  SlidableNotification({
    @required this.tag,
    @required this.ratio,
  });

  final Object tag;
  final double ratio;
}

class SlidableNotificationListener extends StatefulWidget {
  const SlidableNotificationListener({
    Key key,
    @required this.onNotification,
    this.autoClose = true,
    @required this.child,
  })  : assert(onNotification != null),
        assert(autoClose != null),
        assert(child != null),
        super(key: key);

  final Widget child;
  final SlidableNotificationCallback onNotification;
  final bool autoClose;

  @override
  _SlidableNotificationListenerState createState() =>
      _SlidableNotificationListenerState();
}

class _SlidableNotificationListenerState
    extends State<SlidableNotificationListener> {
  final Map<Object, SlidableController> openControllers =
      <Object, SlidableController>{};

  void sendNotification(
    SlidableController controller,
    SlidableNotification notification,
  ) {
    if (widget.autoClose &&
        controller.animation.status == AnimationStatus.forward) {
      // Automatically close the last controller saved with the same tag.
      final lastOpenController = openControllers[notification.tag];
      if (lastOpenController != null && lastOpenController != controller) {
        lastOpenController.close();
      }
      openControllers[notification.tag] = controller;
    }
    widget.onNotification(notification);
  }

  void clearController(SlidableController controller, Object tag) {
    final lastOpenController = openControllers[tag];
    if (lastOpenController == controller) {
      openControllers.remove(tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlidableNotificationListenerScope(
      state: this,
      child: widget.child,
    );
  }
}

class SlidableNotificationListenerScope extends InheritedWidget {
  const SlidableNotificationListenerScope({
    Key key,
    @required this.state,
    @required Widget child,
  }) : super(key: key, child: child);

  final _SlidableNotificationListenerState state;

  @override
  bool updateShouldNotify(
      covariant SlidableNotificationListenerScope oldWidget) {
    return oldWidget.state != state;
  }
}

class SlidableNotificationSender extends StatefulWidget {
  const SlidableNotificationSender({
    Key key,
    @required this.tag,
    @required this.controller,
    @required this.child,
  }) : super(key: key);

  final Object tag;
  final SlidableController controller;
  final Widget child;

  @override
  _SlidableNotificationSenderState createState() =>
      _SlidableNotificationSenderState();
}

class _SlidableNotificationSenderState
    extends State<SlidableNotificationSender> {
  _SlidableNotificationListenerState listenerState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final state = context
        .dependOnInheritedWidgetOfExactType<SlidableNotificationListenerScope>()
        ?.state;
    if (state != listenerState) {
      if (state == null) {
        widget.controller.removeListener(handleControllerChanged);
      } else if (listenerState == null) {
        widget.controller.addListener(handleControllerChanged);
      }
      listenerState = state;
    }
  }

  @override
  void dispose() {
    if (listenerState != null) {
      widget.controller.removeListener(handleControllerChanged);
      listenerState.clearController(widget.controller, widget.tag);
    }
    super.dispose();
  }

  void handleControllerChanged() {
    final controller = widget.controller;
    final notification = SlidableNotification(
      tag: widget.tag,
      ratio: controller.ratio,
    );
    listenerState.sendNotification(controller, notification);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
