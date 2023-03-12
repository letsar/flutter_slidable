import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class ActionPaneConfiguration extends InheritedWidget {
  static ActionPaneConfiguration? of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<ActionPaneConfiguration>();

  final Alignment alignment;
  final Axis direction;
  final bool isStartActionPane;

  const ActionPaneConfiguration({
    super.key,
    required this.alignment,
    required this.direction,
    required this.isStartActionPane,
    required super.child,
  });

  @override
  bool updateShouldNotify(ActionPaneConfiguration oldWidget) {
    return alignment != oldWidget.alignment ||
        direction != oldWidget.direction ||
        isStartActionPane != oldWidget.isStartActionPane;
  }
}
