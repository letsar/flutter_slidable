import 'package:flutter/widgets.dart';

// INTERNAL USE
// ignore_for_file: public_member_api_docs

class ActionPaneConfiguration extends InheritedWidget {
  const ActionPaneConfiguration({
    Key key,
    @required this.alignment,
    @required this.direction,
    @required this.isStartActionPane,
    Widget child,
  }) : super(key: key, child: child);

  final Alignment alignment;
  final Axis direction;
  final bool isStartActionPane;

  @override
  bool updateShouldNotify(ActionPaneConfiguration oldWidget) {
    return alignment != oldWidget.alignment ||
        direction != oldWidget.direction ||
        isStartActionPane != oldWidget.isStartActionPane;
  }

  static ActionPaneConfiguration of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ActionPaneConfiguration>();
  }
}
