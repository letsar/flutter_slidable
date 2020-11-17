import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_slidable/src/slidable_controller.dart';

const _defaultExtentRatio = 0.5;

class ActionPane extends StatefulWidget {
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

  /// The total extent of this [ActionPane] relatively to the enclosing
  /// [Slidable] widget.
  ///
  /// Must be between 0 (excluded) and 1.
  final double extentRatio;

  // Penser à pouvoir faire des widgets 80/20.
  // ActionSlide avec int en paramètre => Flexible

  final Widget transition;
  final Widget dismissible;

  final List<Widget> children;

  final double openThreshold;
  final double closeThreshold;

  @override
  _ActionPaneState createState() => _ActionPaneState();

  static ActionPane of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ActionPaneScope>()
        ?.actionPane;
  }
}

class _ActionPaneState extends State<ActionPane>
    implements ActionPaneConfiguration {
  SlidableController controller;
  EndGesture endGesture;
  double ratio = 0;
  double openThreshold;
  double closeThreshold;
  bool showTransition;

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
    if (endGesture != controller.endGesture) {
      endGesture = controller.endGesture;
      handleEndGestureChanged();
    }

    if (widget.dismissible != null) {
      if (ratio != controller.ratio) {
        ratio = controller.ratio;
        handleRatioChanged();
      }
    }
  }

  void handleEndGestureChanged() {
    // indicate it to the panes ?
    final gesture = endGesture;
    final position = controller.animation.value;

    if (widget.dismissible != null && position > widget.extentRatio) {
      controller.dismissGesture = DismissGesture(endGesture);
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
    final show = ratio <= widget.extentRatio;
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
      actionPane: widget,
      child: child,
    );
  }
}

class _ActionPaneScope extends InheritedWidget {
  _ActionPaneScope({
    Key key,
    this.actionPane,
    Widget child,
  }) : super(key: key, child: child);

  final ActionPane actionPane;

  @override
  bool updateShouldNotify(covariant _ActionPaneScope oldWidget) {
    return oldWidget.actionPane != actionPane;
  }
}
