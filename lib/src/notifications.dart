import 'dart:convert';

import 'package:flutter/widgets.dart';

import 'controller.dart';

typedef SlidableNotificationCallback = void Function(
  SlidableNotification notification,
);

@immutable
class SlidableNotification {
  const SlidableNotification({
    @required this.tag,
    @required this.ratio,
  });

  final Object tag;
  final double ratio;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (other.runtimeType != runtimeType) {
      return false;
    }
    return other is SlidableNotification &&
        other.tag == tag &&
        other.ratio == ratio;
  }

  @override
  int get hashCode => hashValues(tag, ratio);

  @override
  String toString() => 'SlidableNotification(tag: $tag, ratio: $ratio)';
}

class SlidableNotificationListener extends StatefulWidget {
  const SlidableNotificationListener({
    Key key,
    this.onNotification,
    this.autoClose = true,
    @required this.child,
  })  : assert(autoClose != null),
        assert(
          autoClose || onNotification != null,
          'Either autoClose or onNotification must be set.',
        ),
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
        lastOpenController.close(avoidReopening: false);
      }
      openControllers[notification.tag] = controller;
    }
    widget.onNotification?.call(notification);
  }

  void clearController(SlidableController controller, Object tag) {
    final lastOpenController = openControllers[tag];
    if (lastOpenController == controller) {
      openControllers.remove(tag);
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SlidableNotificationListenerScope(
      state: this,
      child: widget.child,
    );
  }
}

class _SlidableNotificationListenerScope extends InheritedWidget {
  const _SlidableNotificationListenerScope({
    Key key,
    @required this.state,
    @required Widget child,
  }) : super(key: key, child: child);

  final _SlidableNotificationListenerState state;

  @override
  bool updateShouldNotify(
      covariant _SlidableNotificationListenerScope oldWidget) {
    return oldWidget.state != state;
  }
}

class SlidableNotificationSender extends StatefulWidget {
  const SlidableNotificationSender({
    Key key,
    @required this.tag,
    @required this.controller,
    @required this.child,
  })  : assert(controller != null),
        assert(child != null),
        super(key: key);

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
        .dependOnInheritedWidgetOfExactType<
            _SlidableNotificationListenerScope>()
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
    if (controller.lastChangedProperty == SlidableControllerProperty.ratio) {
      final notification = SlidableNotification(
        tag: widget.tag,
        ratio: controller.ratio,
      );
      listenerState.sendNotification(controller, notification);
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
