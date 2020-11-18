import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/src/dismissible_pane_transition.dart';
import 'package:flutter_slidable/src/slidable.dart';
import 'package:flutter_slidable/src/slidable_controller.dart';

// TODO: pas fini

const double _kDismissThreshold = 0.75;
const Duration _kDismissalDuration = Duration(milliseconds: 300);
const Duration _kResizeDuration = Duration(milliseconds: 300);

/// Signature used by [DismissiblePane] to give the application an opportunity
/// to confirm or veto a dismiss gesture.
///
/// Used by [DismissiblePane.confirmDismiss].
typedef ConfirmDismissCallback = Future<bool> Function();

class DismissiblePane extends StatefulWidget {
  const DismissiblePane({
    Key key,
    @required this.onDismissed,
    this.dismissThreshold = _kDismissThreshold,
    this.dismissalDuration = _kDismissalDuration,
    this.resizeDuration = _kResizeDuration,
    this.confirmDismiss,
    this.closeOnCancel = false,
    this.transition = const DismissiblePaneTransition(),
  })  : assert(dismissThreshold != null),
        assert(dismissalDuration != null),
        assert(resizeDuration != null),
        assert(onDismissed != null),
        assert(closeOnCancel != null),
        assert(transition != null),
        super(key: key);

  final double dismissThreshold;

  final Duration dismissalDuration;

  /// The amount of time the widget will spend contracting before [onDismissed]
  /// is called.
  ///
  /// If null, the widget will not contract and [onDismissed] will be called
  /// immediately after the widget is dismissed.
  final Duration resizeDuration;
  final ConfirmDismissCallback confirmDismiss;
  final VoidCallback onDismissed;
  final bool closeOnCancel;
  final Widget transition;

  @override
  _DismissiblePaneState createState() => _DismissiblePaneState();
}

class _DismissiblePaneState extends State<DismissiblePane> {
  SlidableController controller;
  // DismissGesture dismissGesture;

  @override
  void initState() {
    super.initState();
    controller = Slidable.of(context);
    controller.addListener(handleControllerChanges);
  }

  @override
  void dispose() {
    controller.removeListener(handleControllerChanges);
    super.dispose();
  }

  void handleControllerChanges() {
    // if (dismissGesture != controller.dismissGesture &&
    //     controller.dismissGesture != null) {
    //   dismissGesture = controller.dismissGesture;
    //   handleDismissGestureChanged();
    // }
    if (controller.lastChangedProperty ==
        SlidableControllerProperty.dismissGesture) {
      handleDismissGestureChanged();
    }
  }

  Future<void> handleDismissGestureChanged() async {
    final endGesture = controller.dismissGesture.endGesture;
    final position = controller.animation.value;

    if (endGesture is OpeningGesture ||
        endGesture is StillGesture && position >= widget.dismissThreshold) {
      // TODO(team): sometimes we enter two times here.

      bool canDismiss = true;
      if (widget.confirmDismiss != null) {
        canDismiss = (await widget.confirmDismiss()) ?? false;
      }
      if (canDismiss) {
        controller.dismiss(
          ResizeRequest(widget.resizeDuration, widget.onDismissed),
          duration: widget.dismissalDuration,
        );
      } else if (widget.closeOnCancel) {
        controller.close();
      }
      return;
    }

    controller.open();
  }

  @override
  Widget build(BuildContext context) {
    return widget.transition;
  }
}
