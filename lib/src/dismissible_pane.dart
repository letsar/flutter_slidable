import 'package:flutter/widgets.dart';

// TODO: pas fini

const double _kDismissThreshold = 0.4;

/// Signature used by [DismissiblePane] to give the application an opportunity
/// to confirm or veto a dismiss gesture.
///
/// Used by [DismissiblePane.confirmDismiss].
typedef ConfirmDismissCallback = Future<bool> Function();

class DismissiblePane extends StatelessWidget {
  const DismissiblePane({
    Key key,
    this.dismissalDuration,
    this.resizeDuration,
    this.confirmDismiss,
    this.onDismissed,
    this.closeOnCancel,
    this.child,
  }) : super(key: key);

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
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
