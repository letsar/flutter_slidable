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

/// The direction of a gesture in the context of [Slidable].
enum GestureDirection {
  /// The direction in which the user want to show the action pane.
  opening,

  /// The direction in which the user want to hide the action pane.
  closing,
}

/// Represents how the ratio should changes.
abstract class RatioConfigurator {
  /// The total extent ratio of this configurator.
  double get extentRatio;

  /// Makes sure the given [ratio] is between the bounds.
  double normalizeRatio(double ratio);

  /// A method to call when the end gesture changed.
  void handleEndGestureChanged();
}

/// A request made to resize a [Slidable] after a dismiss.
@immutable
class ResizeRequest {
  /// The duration of the resize.
  final Duration duration;

  /// The callback to execute when the resize finishes.
  final VoidCallback onDismissed;

  /// Creates a [ResizeRequest].
  const ResizeRequest(this.duration, this.onDismissed);
}

/// Represents an intention to dismiss a [Slidable].
@immutable
class DismissGesture {
  /// The [EndGesture] provoking this one.
  final EndGesture? endGesture;

  /// Creates a [DismissGesture].
  const DismissGesture(this.endGesture);
}

/// Represents the end of a gesture on [Slidable].
@immutable
class EndGesture {
  /// The velocity of the gesture.
  final double velocity;

  /// Creates an [EndGesture].
  const EndGesture(this.velocity);
}

/// Represents a gesture used explicitly to open a [Slidable].
class OpeningGesture extends EndGesture {
  /// Creates an [OpeningGesture].
  const OpeningGesture(super.velocity);
}

/// Represents a gesture used explicitly to close a [Slidable].
class ClosingGesture extends EndGesture {
  /// Creates a [ClosingGesture].
  const ClosingGesture(super.velocity);
}

/// Represents an end gesture without velocity.
class StillGesture extends EndGesture {
  /// The direction in which the user dragged the [Slidable].
  final GestureDirection direction;

  /// Whether the user was in the process to open the [Slidable].
  bool get opening => direction == GestureDirection.opening;

  /// Whether the user was in the process to close the [Slidable].
  bool get closing => direction == GestureDirection.closing;

  /// Creates a [StillGesture].
  const StillGesture(this.direction) : super(0);
}

/// Represents a way to control a slidable from outside.
class SlidableController {
  /// Track the end gestures.
  final ValueNotifier<EndGesture?> endGesture;

  /// Track the resize requests.
  final ValueNotifier<ResizeRequest?> resizeRequest;

  /// Track the type of the action pane.
  final ValueNotifier<ActionPaneType> actionPaneType;

  /// Track the direction in which the slidable moves.
  ///
  /// -1 means that the slidable is moving to the left.
  ///  0 means that the slidable is not moving.
  ///  1 means that the slidable is moving to the right.
  final ValueNotifier<int> direction;

  final AnimationController _animationController;
  final _ValueNotifier<DismissGesture?> _dismissGesture;

  /// Whether the start action pane is enabled.
  bool enableStartActionPane = true;

  /// Whether the end action pane is enabled.
  bool enableEndActionPane = true;

  /// Whether the start action pane is at the left (if horizontal).
  /// Defaults to true.
  bool isLeftToRight = true;

  bool _replayEndGesture = false;

  /// Whether the positive action pane is enabled.
  bool get enablePositiveActionPane =>
      isLeftToRight ? enableStartActionPane : enableEndActionPane;

  /// Whether the negative action pane is enabled.
  bool get enableNegativeActionPane =>
      isLeftToRight ? enableEndActionPane : enableStartActionPane;

  double _startActionPaneExtentRatio = 0;

  /// The extent ratio of the start action pane.
  double get startActionPaneExtentRatio => _startActionPaneExtentRatio;

  set startActionPaneExtentRatio(double value) {
    if (_startActionPaneExtentRatio != value && value >= 0 && value <= 1) {
      _startActionPaneExtentRatio = value;
    }
  }

  double _endActionPaneExtentRatio = 0;

  /// The extent ratio of the end action pane.
  double get endActionPaneExtentRatio => _endActionPaneExtentRatio;

  set endActionPaneExtentRatio(double value) {
    if (_endActionPaneExtentRatio != value && value >= 0 && value <= 1) {
      _endActionPaneExtentRatio = value;
    }
  }

  RatioConfigurator? _actionPaneConfigurator;

  /// The current action pane configurator.
  RatioConfigurator? get actionPaneConfigurator => _actionPaneConfigurator;

  set actionPaneConfigurator(RatioConfigurator? value) {
    if (_actionPaneConfigurator != value) {
      _actionPaneConfigurator = value;
      if (_replayEndGesture && value != null) {
        _replayEndGesture = false;
        value.handleEndGestureChanged();
      }
    }
  }

  /// The value of the ratio over time.
  Animation<double> get animation => _animationController.view;

  /// Track the dismiss gestures.
  ValueNotifier<DismissGesture?> get dismissGesture => _dismissGesture;

  /// Indicates whether the dismissible registered to gestures.
  bool get isDismissibleReady => _dismissGesture._hasListeners;

  bool _closing = false;

  /// Whether this [close()] method has been called and not finished.
  bool get closing => _closing;

  /// Creates a [SlidableController].
  SlidableController(TickerProvider vsync)
      : _animationController = AnimationController(vsync: vsync),
        endGesture = ValueNotifier(null),
        _dismissGesture = _ValueNotifier(null),
        resizeRequest = ValueNotifier(null),
        actionPaneType = ValueNotifier(ActionPaneType.none),
        direction = ValueNotifier(0) {
    direction.addListener(_onDirectionChanged);
  }

  /// The current ratio of the full size of the [Slidable] that is already
  /// dragged.
  ///
  /// This is between -1 and 1.
  /// Between -1 (inclusive) and 0(exclusive), the action pane is
  /// [ActionPaneType.end].
  /// Between 0 (exclusive) and 1 (inclusive), the action pane is
  /// [ActionPaneType.start].
  double get ratio => _animationController.value * direction.value;
  set ratio(double value) {
    final newRatio = (actionPaneConfigurator?.normalizeRatio(value)) ?? value;
    if (_acceptRatio(newRatio) && newRatio != ratio) {
      direction.value = newRatio.sign.toInt();
      _animationController.value = newRatio.abs();
    }
  }

  /// Dispatches a new [EndGesture] determined by the given [velocity] and
  /// [direction].
  void dispatchEndGesture(double? velocity, GestureDirection direction) {
    if (velocity == 0 || velocity == null) {
      endGesture.value = StillGesture(direction);
    } else if (velocity.sign == this.direction.value) {
      endGesture.value = OpeningGesture(velocity);
    } else {
      endGesture.value = ClosingGesture(velocity.abs());
    }

    // If the movement is too fast, the actionPaneConfigurator may still be
    // null. So we have to replay the end gesture when it will not be null.
    if (actionPaneConfigurator == null) {
      _replayEndGesture = true;
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
    direction.value = 0;
    _closing = false;
  }

  /// Opens the current [ActionPane].
  Future<void> openCurrentActionPane({
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) async {
    return openTo(
      actionPaneConfigurator!.extentRatio,
      duration: duration,
      curve: curve,
    );
  }

  /// Opens the [Slidable.startActionPane].
  Future<void> openStartActionPane({
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) async {
    if (actionPaneType.value != ActionPaneType.start) {
      direction.value = isLeftToRight ? 1 : -1;
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
    if (actionPaneType.value != ActionPaneType.end) {
      direction.value = isLeftToRight ? -1 : 1;
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
    assert(ratio >= -1 && ratio <= 1);

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
    direction.removeListener(_onDirectionChanged);
    direction.dispose();
  }

  bool _acceptRatio(double ratio) {
    return !_closing &&
        (ratio == 0 ||
            ((ratio > 0 && enablePositiveActionPane) ||
                (ratio < 0 && enableNegativeActionPane)));
  }

  void _onDirectionChanged() {
    final mulitiplier = isLeftToRight ? 1 : -1;
    final index = (direction.value * mulitiplier) + 1;
    actionPaneType.value = ActionPaneType.values[index];
  }
}

class _ValueNotifier<T> extends ValueNotifier<T> {
  bool get _hasListeners => hasListeners;

  _ValueNotifier(super.value);
}
