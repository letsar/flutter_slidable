import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/src/controller.dart';
import 'package:flutter_slidable/src/notifications.dart';

/// A widget that forces the [Slidable] widgets below it to close when another
/// [Slidable] widget with the same [groupTag] opens.
class SlidableAutoCloseBehavior extends StatefulWidget {
  /// Creates a [SlidableAutoCloseBehavior].
  const SlidableAutoCloseBehavior({
    super.key,
    this.closeWhenOpened = true,
    this.closeWhenTapped = true,
    required this.child,
  });

  /// Indicates whether all the [Slidable] within the same group should be
  /// closed when one of the group is opened.
  ///
  /// Defaults to true.
  final bool closeWhenOpened;

  /// Indicates whether all the [Slidable] within the same group should be
  /// closed when one of the group is tapped while one is opened.
  ///
  /// Defaults to true.
  final bool closeWhenTapped;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  State<SlidableAutoCloseBehavior> createState() =>
      _SlidableAutoCloseBehaviorState();
}

class _SlidableAutoCloseBehaviorState extends State<SlidableAutoCloseBehavior> {
  final Map<Object?, int> openSlidables = {};

  @override
  Widget build(BuildContext context) {
    return _SlidableAutoCloseData(
      closeWhenOpened: widget.closeWhenOpened,
      closeWhenTapped: widget.closeWhenTapped,
      child: SlidableGroupBehavior<SlidableAutoCloseNotification>(
        child: SlidableGroupBehavior<SlidableAutoCloseBarrierNotification>(
          onNotification: (notification) {
            final key = notification.groupTag;
            final previousOpenForThatTag =
                openSlidables.putIfAbsent(key, () => 0);
            final openForThatTag =
                previousOpenForThatTag + (notification.enabled ? 1 : -1);
            openSlidables[key] = openForThatTag;
            if (openForThatTag == 0 || previousOpenForThatTag == 0) {
              return notification;
            }
            return null;
          },
          child: widget.child,
        ),
      ),
    );
  }
}

class _SlidableAutoCloseData extends InheritedWidget {
  const _SlidableAutoCloseData({
    required this.closeWhenOpened,
    required this.closeWhenTapped,
    required super.child,
  });

  final bool closeWhenOpened;
  final bool closeWhenTapped;

  @override
  bool updateShouldNotify(_SlidableAutoCloseData oldWidget) {
    return oldWidget.closeWhenOpened != closeWhenOpened ||
        oldWidget.closeWhenTapped != closeWhenTapped;
  }

  static _SlidableAutoCloseData? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<_SlidableAutoCloseData>();
  }
}

/// INTERNAL USE
class SlidableAutoCloseBehaviorInteractor extends StatelessWidget {
  /// INTERNAL USE
  const SlidableAutoCloseBehaviorInteractor({
    super.key,
    required this.groupTag,
    required this.controller,
    required this.child,
  });

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
    return SlidableAutoCloseInteractor(
      groupTag: groupTag,
      controller: controller,
      child: SlidableAutoCloseBarrierInteractor(
        groupTag: groupTag,
        controller: controller,
        child: child,
      ),
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
    this.closeSelf = false,
  });

  /// {@macro slidable.groupTag}
  final Object? groupTag;

  /// {@template slidable.controller}
  /// The [SlidableController] associated.
  /// {@endtemplate}
  final SlidableController controller;

  /// Whether the [Slidable] where this notification was sent should also close.
  final bool closeSelf;
}

/// INTERNAL USE
class SlidableAutoCloseInteractor extends StatelessWidget {
  /// INTERNAL USE
  const SlidableAutoCloseInteractor({
    super.key,
    required this.groupTag,
    required this.controller,
    required this.child,
  });

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
    return SlidableAutoCloseNotificationSender(
      groupTag: groupTag,
      controller: controller,
      child: SlidableAutoCloseBehaviorListener(
        groupTag: groupTag,
        controller: controller,
        child: child,
      ),
    );
  }
}

/// INTERNAL USE
class SlidableAutoCloseBehaviorListener extends StatelessWidget {
  /// INTERNAL USE
  const SlidableAutoCloseBehaviorListener({
    super.key,
    required this.groupTag,
    required this.controller,
    required this.child,
  });

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
            (notification.closeSelf || notification.controller != controller) &&
            !controller.closing) {
          controller.close();
        }
      },
      child: child,
    );
  }
}

/// INTERNAL USE
class SlidableAutoCloseNotificationSender extends StatelessWidget {
  /// INTERNAL USE
  const SlidableAutoCloseNotificationSender({
    super.key,
    required this.groupTag,
    required this.controller,
    required this.child,
  });

  /// {@macro slidable.groupTag}
  final Object? groupTag;

  /// {@macro slidable.controller}
  final SlidableController controller;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  void _handleStatusChanged(BuildContext context, AnimationStatus status) {
    final moving =
        status == AnimationStatus.forward || status == AnimationStatus.reverse;
    if (moving && !controller.closing) {
      SlidableGroupNotification.dispatch(
        context,
        SlidableAutoCloseNotification(
          groupTag: groupTag,
          controller: controller,
        ),
        assertParentExists: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _SlidableNotificationSender(
      controller: controller,
      onStatusChanged: (status) => _handleStatusChanged(context, status),
      enabled: _SlidableAutoCloseData.of(context)?.closeWhenOpened ?? false,
      child: child,
    );
  }
}

/// A notification used to indicate if a barrier should be pub on [Slidable]
@immutable
class SlidableAutoCloseBarrierNotification {
  /// Creates a notification to activate/deactivate the barrier on [Slidable]
  /// widgets.
  const SlidableAutoCloseBarrierNotification({
    required this.groupTag,
    required this.controller,
    this.enabled = false,
  });

  /// {@macro slidable.groupTag}
  final Object? groupTag;

  /// {@template slidable.controller}
  /// The [SlidableController] associated.
  /// {@endtemplate}
  final SlidableController controller;

  /// Whether the barrier is enabled.
  final bool enabled;
}

/// INTERNAL USE
class SlidableAutoCloseBarrierInteractor extends StatelessWidget {
  /// INTERNAL USE
  const SlidableAutoCloseBarrierInteractor({
    super.key,
    required this.groupTag,
    required this.controller,
    required this.child,
  });

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
    return SlidableAutoCloseBarrierNotificationSender(
      groupTag: groupTag,
      controller: controller,
      child: SlidableAutoCloseBarrierBehaviorListener(
        groupTag: groupTag,
        controller: controller,
        child: child,
      ),
    );
  }
}

/// INTERNAL USE
class SlidableAutoCloseBarrierNotificationSender extends StatefulWidget {
  /// INTERNAL USE
  const SlidableAutoCloseBarrierNotificationSender({
    super.key,
    required this.groupTag,
    required this.controller,
    required this.child,
  });

  /// {@macro slidable.groupTag}
  final Object? groupTag;

  /// {@macro slidable.controller}
  final SlidableController controller;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  State<SlidableAutoCloseBarrierNotificationSender> createState() =>
      _SlidableAutoCloseBarrierNotificationSenderState();
}

class _SlidableAutoCloseBarrierNotificationSenderState
    extends State<SlidableAutoCloseBarrierNotificationSender> {
  SlidableGroupNotificationDispatcher? dispatcher;

  void _handleStatusChanged(AnimationStatus status) {
    //TODO(romain): There is a bug if more than one try to open at the same time.
    final willBarrierBeEnabled = status != AnimationStatus.dismissed;
    final barrierEnabled = dispatcher != null;
    if (willBarrierBeEnabled != barrierEnabled) {
      dispatcher = SlidableGroupNotification.createDispatcher<
          SlidableAutoCloseBarrierNotification>(
        context,
        assertParentExists: false,
      );
      dispatchSlidableAutoCloseBarrierNotification(
        enabled: willBarrierBeEnabled,
      );
      if (!willBarrierBeEnabled) {
        // We can set the dispatcher to null because we won't need it anymore.
        dispatcher = null;
      }
    }
  }

  void dispatchSlidableAutoCloseBarrierNotification({required bool enabled}) {
    final notification = SlidableAutoCloseBarrierNotification(
      groupTag: widget.groupTag,
      controller: widget.controller,
      enabled: enabled,
    );
    dispatcher?.dispatch(notification);
  }

  @override
  void dispose() {
    if (dispatcher != null) {
      // If we still have a dispatcher, it means that this widget was disposed
      // while the barrier was still enabled for this group.
      // We need to release the barrier.

      // In Flutter 3, [SchedulerBinding.instance] is not nullable, but since
      // we want to support Flutter 2, this is a simple way to do it without
      // having a build warning.
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final SchedulerBinding? schedulerBinding = SchedulerBinding.instance;
      schedulerBinding?.addPostFrameCallback((Duration _) {
        // We call it in the next frame to avoid to rebuild a widget that is
        // already rebuilding.
        dispatchSlidableAutoCloseBarrierNotification(enabled: false);
      });
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _SlidableNotificationSender(
      controller: widget.controller,
      onStatusChanged: _handleStatusChanged,
      enabled: _SlidableAutoCloseData.of(context)?.closeWhenTapped ?? false,
      child: widget.child,
    );
  }
}

/// INTERNAL USE
class SlidableAutoCloseBarrierBehaviorListener extends StatefulWidget {
  /// INTERNAL USE
  const SlidableAutoCloseBarrierBehaviorListener({
    super.key,
    required this.groupTag,
    required this.controller,
    required this.child,
  });

  /// {@macro slidable.groupTag}
  final Object? groupTag;

  /// {@macro slidable.controller}
  final SlidableController controller;

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget child;

  @override
  _SlidableAutoCloseBarrierBehaviorListenerState createState() =>
      _SlidableAutoCloseBarrierBehaviorListenerState();
}

class _SlidableAutoCloseBarrierBehaviorListenerState
    extends State<SlidableAutoCloseBarrierBehaviorListener> {
  bool absorbing = false;

  void handleOnTap() {
    if (!widget.controller.closing) {
      SlidableGroupNotification.dispatch(
        context,
        SlidableAutoCloseNotification(
          groupTag: widget.groupTag,
          controller: widget.controller,
          closeSelf: true,
        ),
        assertParentExists: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlidableGroupBehaviorListener<SlidableAutoCloseBarrierNotification>(
      onNotification: (SlidableAutoCloseBarrierNotification notification) {
        if (widget.groupTag == notification.groupTag) {
          if (mounted) {
            setState(() {
              absorbing = notification.enabled;
            });
          }
        }
      },
      child: GestureDetector(
        onTap: absorbing ? handleOnTap : null,
        child: AbsorbPointer(
          absorbing: absorbing,
          child: widget.child,
        ),
      ),
    );
  }
}

/// INTERNAL USE
class _SlidableNotificationSender extends StatefulWidget {
  /// INTERNAL USE
  const _SlidableNotificationSender({
    required this.controller,
    required this.onStatusChanged,
    required this.enabled,
    required this.child,
  });

  final SlidableController controller;

  final AnimationStatusListener onStatusChanged;

  final Widget child;

  final bool enabled;

  @override
  _SlidableNotificationSenderState createState() =>
      _SlidableNotificationSenderState();
}

class _SlidableNotificationSenderState
    extends State<_SlidableNotificationSender> {
  @override
  void initState() {
    super.initState();
    addListeners(widget);
  }

  @override
  void didUpdateWidget(_SlidableNotificationSender oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller ||
        oldWidget.onStatusChanged != widget.onStatusChanged) {
      removeListeners(oldWidget);
      addListeners(widget);
    }
  }

  @override
  void dispose() {
    removeListeners(widget);
    super.dispose();
  }

  void handleStatusChanged(AnimationStatus status) {
    if (widget.enabled) {
      widget.onStatusChanged(status);
    }
  }

  void addListeners(_SlidableNotificationSender widget) {
    widget.controller.animation.addStatusListener(handleStatusChanged);
  }

  void removeListeners(_SlidableNotificationSender widget) {
    widget.controller.animation.addStatusListener(handleStatusChanged);
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
