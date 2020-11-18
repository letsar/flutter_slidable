import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_slidable/src/slidable_controller.dart';

const _defaultExtentRatio = 0.5;

/// Data of the ambient [ActionPane] accessible from its children.
abstract class ActionPaneData {
  /// The total extent of this [ActionPane] relatively to the enclosing
  /// [Slidable] widget.
  ///
  /// Must be between 0 (excluded) and 1.
  double get extentRatio;

  /// The actions for this pane.
  List<Widget> get children;
}

/// An action pane.
class ActionPane extends StatefulWidget implements ActionPaneData {
  const ActionPane({
    Key key,
    this.extentRatio = _defaultExtentRatio,
    @required this.transition,
    this.dismissible,
    this.openThreshold,
    this.closeThreshold,
    this.children,
  })  : assert(extentRatio != null && extentRatio > 0 && extentRatio <= 1),
        assert(children != null),
        assert(
            openThreshold == null || (openThreshold > 0 && openThreshold < 1)),
        assert(closeThreshold == null ||
            (closeThreshold > 0 && closeThreshold < 1)),
        super(key: key);

  @override
  final double extentRatio;

  /// A widget which animates when the [Slidable] moves.
  final Widget transition;

  /// A widget which animates when the [Slidable] dismisses.
  final Widget dismissible;

  /// The fraction of the total extent from where the [Slidable] will
  /// automatically open when the drag end.
  ///
  /// Must be between 0 (excluded) and 1 (excluded).
  ///
  /// By default this value is half the [extentRatio].
  final double openThreshold;

  /// The fraction of the total extent from where the [Slidable] will
  /// automatically close when the drag end.
  ///
  /// Must be between 0 (excluded) and 1 (excluded).
  ///
  /// By default this value is half the [extentRatio].
  final double closeThreshold;

  @override
  final List<Widget> children;

  @override
  _ActionPaneState createState() => _ActionPaneState();

  /// The action pane's data from the closest instance of this class that
  /// encloses the given context.
  static ActionPaneData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ActionPaneScope>()
        ?.actionPaneData;
  }
}

class _ActionPaneState extends State<ActionPane>
    implements ActionPaneConfiguration {
  SlidableController controller;
  // EndGesture endGesture;
  // double ratio = 0;
  double openThreshold;
  double closeThreshold;
  bool showTransition;

  @override
  double get extentRatio => widget.extentRatio;

  @override
  void initState() {
    super.initState();
    controller = Slidable.of(context);
    controller.addListener(handleControllerChanges);
    controller.actionPaneConfiguration = this;
    showTransition = true;
    updateThresholds();
  }

  void updateThresholds() {
    openThreshold = widget.openThreshold ?? widget.extentRatio / 2;
    closeThreshold = widget.closeThreshold ?? widget.extentRatio / 2;
  }

  @override
  void didUpdateWidget(covariant ActionPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dismissible == null) {
      // In the case where the child was different than the transition, we get
      // it back.
      showTransition = true;
    }
    updateThresholds();
  }

  @override
  void dispose() {
    controller.removeListener(handleControllerChanges);
    controller.actionPaneConfiguration = null;
    super.dispose();
  }

  bool canChangeRatio(double ratio) {
    return widget.dismissible != null || ratio <= widget.extentRatio;
  }

  void handleControllerChanges() {
    // if (endGesture != controller.endGesture && controller.endGesture != null) {
    //   endGesture = controller.endGesture;
    //   handleEndGestureChanged();
    // }
    if (controller.lastChangedProperty ==
        SlidableControllerProperty.endGesture) {
      handleEndGestureChanged();
    }

    if (widget.dismissible != null) {
      if (controller.lastChangedProperty == SlidableControllerProperty.ratio) {
        handleRatioChanged();
      }
    }
  }

  void handleEndGestureChanged() {
    final gesture = controller.endGesture;
    final position = controller.animation.value;

    if (widget.dismissible != null && position > widget.extentRatio) {
      controller.dismissGesture = DismissGesture(gesture);
      return;
    }

    if (gesture is OpeningGesture ||
        gesture is StillGesture &&
            ((gesture.opening && position >= openThreshold) ||
                gesture.closing && position > closeThreshold)) {
      controller.open();

      return;
    }

    // Otherwise we close the the Slidable.
    controller.close();
  }

  void handleRatioChanged() {
    final show = controller.ratio <= widget.extentRatio;
    if (show != showTransition) {
      setState(() {
        showTransition = show;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = ActionPaneStyle.of(context);

    Widget child;

    if (showTransition) {
      final factor = widget.extentRatio;
      child = FractionallySizedBox(
        alignment: style.alignment,
        widthFactor: style.direction == Axis.horizontal ? factor : null,
        heightFactor: style.direction == Axis.horizontal ? null : factor,
        child: widget.transition,
      );
    } else {
      child = widget.dismissible;
    }

    return _ActionPaneScope(
      actionPaneData: widget,
      child: child,
    );
  }
}

class _ActionPaneScope extends InheritedWidget {
  const _ActionPaneScope({
    Key key,
    this.actionPaneData,
    Widget child,
  }) : super(key: key, child: child);

  final ActionPaneData actionPaneData;

  @override
  bool updateShouldNotify(covariant _ActionPaneScope oldWidget) {
    return oldWidget.actionPaneData != actionPaneData;
  }
}
