import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

const _defaultMovementDuration = Duration(milliseconds: 200);
const _defaultCurve = Curves.ease;

/// The different kinds of action panes.
enum ActionPaneType {
  /// The end action pane is shown.
  end,

  /// No action pane is shown.
  none,

  /// The start action pane is shown.
  start,
}

/// Represents how the ratio should changes.
abstract class RatioConfigurator {
  /// Whether the given [ratio] is accepted.
  bool canChangeRatio(double ratio);

  /// The total extent ratio of this configurator.
  double get extentRatio;
}

/// The direction of a gesture in the context of [Slidable].
enum GestureDirection {
  /// The direction in which the user want to show the action pane.
  opening,

  /// The direction in which the user want to hide the action pane.
  closing,
}

/// A request made to resize a [Slidable] after a dismiss.
@immutable
class ResizeRequest {
  /// Creates a [ResizeRequest].
  const ResizeRequest(this.duration, this.onDismissed);

  /// The duration of the resize.
  final Duration duration;

  /// The callback to execute when the resize finishes.
  final VoidCallback onDismissed;
}

/// Represents an intention to dismiss a [Slidable].
@immutable
class DismissGesture {
  /// Creates a [DismissGesture].
  const DismissGesture(this.endGesture);

  /// The [EndGesture] provoking this one.
  final EndGesture endGesture;
}

/// Represents the end of a gesture on [Slidable].
@immutable
class EndGesture {
  /// Creates an [EndGesture].
  const EndGesture(this.velocity);

  /// The velocity of the gesture.
  final double velocity;
}

/// Represents a gesture used explicitly to open a [Slidable].
class OpeningGesture extends EndGesture {
  /// Creates an [OpeningGesture].
  const OpeningGesture(double velocity) : super(velocity);
}

/// Represents a gesture used explicitly to close a [Slidable].
class ClosingGesture extends EndGesture {
  /// Creates a [ClosingGesture].
  const ClosingGesture(double velocity) : super(velocity);
}

/// Represents an end gesture without velocity.
class StillGesture extends EndGesture {
  /// Creates a [StillGesture].
  const StillGesture(this.direction) : super(0);

  /// The direction in which the user dragged the [Slidable].
  final GestureDirection direction;

  /// Whether the user was in the process to open the [Slidable].
  bool get opening => direction == GestureDirection.opening;

  /// Whether the user was in the process to close the [Slidable].
  bool get closing => direction == GestureDirection.closing;
}

/// Represents a way to control a slidable from outside.
class SlidableController {
  /// Creates a [SlidableController].
  SlidableController(TickerProvider vsync)
      : _animationController = AnimationController(vsync: vsync),
        endGesture = ValueNotifier(null),
        dismissGesture = ValueNotifier(null),
        resizeRequest = ValueNotifier(null),
        actionPaneType = ValueNotifier(ActionPaneType.none);

  final AnimationController _animationController;

  /// Whether the start action pane is enabled.
  bool enableStartActionPane = true;

  /// Whether the end action pane is enabled.
  bool enableEndActionPane = true;

  /// The extent ratio of the start action pane.
  double get startActionPaneExtentRatio => _startActionPaneExtentRatio;
  double _startActionPaneExtentRatio;
  set startActionPaneExtentRatio(double value) {
    if (_startActionPaneExtentRatio != value &&
        value != null &&
        value >= 0 &&
        value <= 1) {
      _startActionPaneExtentRatio = value;
    }
  }

  /// The extent ratio of the end action pane.
  double get endActionPaneExtentRatio => _endActionPaneExtentRatio;
  double _endActionPaneExtentRatio;
  set endActionPaneExtentRatio(double value) {
    if (_endActionPaneExtentRatio != value &&
        value != null &&
        value >= 0 &&
        value <= 1) {
      _endActionPaneExtentRatio = value;
    }
  }

  /// The current action pane configurator.
  RatioConfigurator actionPaneConfigurator;

  /// The value of the ratio over time.
  Animation<double> get animation => _animationController.view;

  /// Track the end gestures.
  final ValueNotifier<EndGesture> endGesture;

  /// Track the dismiss gestures.
  final ValueNotifier<DismissGesture> dismissGesture;

  /// Track the resize requests.
  final ValueNotifier<ResizeRequest> resizeRequest;

  /// Track the type of the action pane.
  final ValueNotifier<ActionPaneType> actionPaneType;

  /// Whether this [close()] method has been called and not finished.
  bool get closing => _closing;
  bool _closing = false;

  bool _acceptRatio(double ratio) {
    return !_closing &&
        (ratio == 0 ||
            ((ratio > 0 && enableStartActionPane) ||
                    (ratio < 0 && enableEndActionPane)) &&
                (actionPaneConfigurator == null ||
                    actionPaneConfigurator.canChangeRatio(ratio.abs())));
  }

  /// The current ratio of the full size of the [Slidable] that is already
  /// dragged.
  ///
  /// This is between -1 and 1.
  /// Between -1 (inclusive) and 0(exclusive), the action pane is
  /// [ActionPaneType.end].
  /// Between 0 (exclusive) and 1 (inclusive), the action pane is
  /// [ActionPaneType.start].
  double get ratio =>
      _animationController.value * actionPaneType.value.toSign();
  set ratio(double value) {
    if (_acceptRatio(value) && value != ratio) {
      final index = value.sign.toInt() + 1;
      actionPaneType.value = ActionPaneType.values[index];
      _animationController.value = value.abs();
    }
  }

  /// Dispatches a new [EndGesture] determined by the given [velocity] and
  /// [direction].
  void dispatchEndGesture(double velocity, GestureDirection direction) {
    if (velocity == 0 || velocity == null) {
      endGesture.value = StillGesture(direction);
    } else if (velocity.sign == actionPaneType.value.toSign()) {
      endGesture.value = OpeningGesture(velocity);
    } else {
      endGesture.value = ClosingGesture(velocity.abs());
    }
  }

  /// Closes the [Slidable].
  Future<void> close({
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) async {
    _closing = true;
    await _animationController.animateBack(
      0,
      duration: duration,
      curve: curve,
    );
    _closing = false;
  }

  /// Opens the current [ActionPane].
  Future<void> openCurrentActionPane({
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) async {
    assert(actionPaneConfigurator != null);
    assert(duration != null);

    return openTo(
      actionPaneConfigurator.extentRatio,
      duration: duration,
      curve: curve,
    );
  }

  /// Opens the [Slidable.startActionPane].
  Future<void> openStartActionPane({
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) async {
    assert(duration != null);

    if (actionPaneType.value != ActionPaneType.start) {
      actionPaneType.value = ActionPaneType.start;
      ratio = 0;
    }

    return openTo(
      startActionPaneExtentRatio,
      duration: duration,
      curve: curve,
    );
  }

  /// Opens the [Slidable.endActionPane].
  Future<void> openEndActionPane({
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) async {
    assert(duration != null);

    if (actionPaneType.value != ActionPaneType.end) {
      actionPaneType.value = ActionPaneType.end;
      ratio = 0;
    }

    return openTo(
      -endActionPaneExtentRatio,
      duration: duration,
      curve: curve,
    );
  }

  /// Opens the [Slidable] to the given [ratio].
  Future<void> openTo(
    double ratio, {
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) async {
    assert(ratio != null && ratio >= -1 && ratio <= 1);
    assert(duration != null);

    if (_closing) {
      return;
    }

    // Edge case: to be able to correctly set the sign when the value is zero,
    // we have to manually set the ratio to a tiny amount.
    if (_animationController.value == 0) {
      this.ratio = 0.05 * ratio.sign;
    }
    return _animationController.animateTo(
      ratio.abs(),
      duration: duration,
      curve: curve,
    );
  }

  /// Dismisses the [Slidable].
  Future<void> dismiss(
    ResizeRequest request, {
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) async {
    await _animationController.animateTo(
      1,
      duration: _defaultMovementDuration,
      curve: curve,
    );
    resizeRequest.value = request;
  }

  /// Disposes the controller.
  void dispose() {
    _animationController.stop();
    _animationController.dispose();
  }
}

/// Extensions for [ActionPaneType].
extension ActionPaneTypeX on ActionPaneType {
  /// Transforms this [ActionPaneType] to a sign.
  double toSign() {
    switch (this) {
      case ActionPaneType.start:
        return 1;
      case ActionPaneType.end:
        return -1;
      default:
        return 0;
    }
  }
}
