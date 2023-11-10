part of 'slidable.dart';

const _defaultExtentRatio = 0.5;

/// Data of the ambient [ActionPane] accessible from its children.
@immutable
class ActionPaneData {
  /// Creates an [ActionPaneData].
  const ActionPaneData({
    required this.extentRatio,
    required this.alignment,
    required this.direction,
    required this.fromStart,
    required this.children,
  });

  /// The total extent of this [ActionPane] relatively to the enclosing
  /// [Slidable] widget.
  ///
  /// Must be between 0 (excluded) and 1.
  final double extentRatio;

  /// The alignment used by the current action pane to position itself.
  final Alignment alignment;

  /// The axis in which the slidable can slide.
  final Axis direction;

  /// Whether the current action pane is the start one.
  final bool fromStart;

  /// The actions for this pane.
  final List<Widget> children;
}

/// An action pane.
class ActionPane extends StatefulWidget {
  /// Creates an [ActionPane].
  ///
  /// The [extentRatio] argument must not be null and must be between 0
  /// (exclusive) and 1 (inclusive).
  /// The [openThreshold] argument must be null or between 0 and 1
  /// (both exclusives).
  /// The [closeThreshold] argument must be null or between 0 and 1
  /// (both exclusives).
  /// The [children] argument must not be null.
  const ActionPane({
    Key? key,
    this.extentRatio = _defaultExtentRatio,
    required this.motion,
    this.dismissible,
    this.dragDismissible = true,
    this.openThreshold,
    this.closeThreshold,
    this.fromStart,
    required this.children,
  })  : assert(extentRatio > 0 && extentRatio <= 1),
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

  /// A widget which animates when the [Slidable] moves.
  final Widget motion;

  /// A widget which controls how the [Slidable] dismisses.
  final Widget? dismissible;

  /// Indicates whether the [Slidable] can be dismissed by dragging.
  ///
  /// Defaults to true.
  final bool dragDismissible;

  /// The fraction of the total extent from where the [Slidable] will
  /// automatically open when the drag end.
  ///
  /// Must be between 0 (excluded) and 1 (excluded).
  ///
  /// By default this value is half the [extentRatio].
  final double? openThreshold;

  /// The fraction of the total extent from where the [Slidable] will
  /// automatically close when the drag end.
  ///
  /// Must be between 0 (excluded) and 1 (excluded).
  ///
  /// By default this value is half the [extentRatio].
  final double? closeThreshold;

  /// The actions for this pane.
  final List<Widget> children;

  /// The actions for this pane.
  final bool? fromStart;

  @override
  _ActionPaneState createState() => _ActionPaneState();

  /// The action pane's data from the closest instance of this class that
  /// encloses the given context.
  static ActionPaneData? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ActionPaneScope>()
        ?.actionPaneData;
  }
}

class _ActionPaneState extends State<ActionPane> implements RatioConfigurator {
  SlidableController? controller;
  late double openThreshold;
  late double closeThreshold;
  bool showMotion = true;

  @override
  double get extentRatio => widget.extentRatio;

  @override
  void initState() {
    super.initState();
    controller = Slidable.of(context);
    controller!.endGesture.addListener(handleEndGestureChanged);

    if (widget.dismissible != null) {
      controller!.animation.addListener(handleRatioChanged);
    }
    updateThresholds();
    controller!.actionPaneConfigurator = this;
  }

  void updateThresholds() {
    openThreshold = widget.openThreshold ?? widget.extentRatio / 2;
    closeThreshold = widget.closeThreshold ?? widget.extentRatio / 2;
  }

  @override
  void didUpdateWidget(covariant ActionPane oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.dismissible != null) {
      controller!.animation.removeListener(handleRatioChanged);
    }
    if (widget.dismissible == null) {
      // In the case where the child was different than the motion, we get
      // it back.
      showMotion = true;
    } else {
      controller!.animation.addListener(handleRatioChanged);
    }
    updateThresholds();
  }

  @override
  void dispose() {
    controller!.endGesture.removeListener(handleEndGestureChanged);
    controller!.animation.removeListener(handleRatioChanged);
    controller!.actionPaneConfigurator = null;
    super.dispose();
  }

  @override
  double normalizeRatio(double ratio) {
    if (widget.dismissible != null && widget.dragDismissible) {
      return ratio;
    }

    final absoluteRatio = ratio.abs().clamp(0.0, widget.extentRatio);
    if (ratio < 0) {
      return -absoluteRatio;
    }
    return absoluteRatio;
  }

  @override
  void handleEndGestureChanged() {
    final gesture = controller!.endGesture.value;
    final position = controller!.animation.value;

    if (widget.dismissible != null &&
        widget.dragDismissible &&
        position > widget.extentRatio) {
      if (controller!.isDismissibleReady) {
        controller!.dismissGesture.value = DismissGesture(gesture);
      } else {
        // If the dismissible is not ready, the animation will stop.
        // So we prefere to open the action pane instead.
        controller!.openCurrentActionPane();
      }
      return;
    }

    if ((gesture is OpeningGesture && openThreshold <= extentRatio) ||
        gesture is StillGesture &&
            ((gesture.opening && position >= openThreshold) ||
                gesture.closing && position > closeThreshold)) {
      controller!.openCurrentActionPane();
      return;
    }

    // Otherwise we close the the Slidable.
    controller!.close();
  }

  void handleRatioChanged() {
    final show = controller!.ratio.abs() <= widget.extentRatio &&
        !controller!.isDismissibleReady;
    if (show != showMotion) {
      setState(() {
        showMotion = show;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = ActionPaneConfiguration.of(context)!;

    Widget? child;

    if (showMotion) {
      final factor = widget.extentRatio;
      child = FractionallySizedBox(
        alignment: config.alignment,
        widthFactor: config.direction == Axis.horizontal ? factor : null,
        heightFactor: config.direction == Axis.horizontal ? null : factor,
        child: widget.motion,
      );
    } else {
      child = widget.dismissible;
    }

    return _ActionPaneScope(
      actionPaneData: ActionPaneData(
        alignment: config.alignment,
        direction: config.direction,
        fromStart: widget.fromStart ?? config.isStartActionPane,
        extentRatio: widget.extentRatio,
        children: widget.children,
      ),
      child: child!,
    );
  }
}

class _ActionPaneScope extends InheritedWidget {
  const _ActionPaneScope({
    Key? key,
    this.actionPaneData,
    required Widget child,
  }) : super(key: key, child: child);

  final ActionPaneData? actionPaneData;

  @override
  bool updateShouldNotify(covariant _ActionPaneScope oldWidget) {
    return oldWidget.actionPaneData != actionPaneData;
  }
}
