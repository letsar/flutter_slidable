import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

const _defaultMovementDuration = Duration(milliseconds: 200);
const _defaultCurve = Curves.ease;

enum ActionPaneType {
  end,
  none,
  start,
}

abstract class ActionPaneConfigurator {
  bool canChangeRatio(double ratio);
  double get extentRatio;
}

enum GestureDirection {
  opening,
  closing,
}

@immutable
class ResizeRequest {
  const ResizeRequest(this.duration, this.onDismissed);

  final Duration duration;
  final VoidCallback onDismissed;
}

@immutable
class DismissGesture {
  DismissGesture(this.endGesture);
  final EndGesture endGesture;
}

@immutable
class EndGesture {
  EndGesture(this.velocity);
  final double velocity;
}

class OpeningGesture extends EndGesture {
  OpeningGesture(double velocity) : super(velocity);
}

class ClosingGesture extends EndGesture {
  ClosingGesture(double velocity) : super(velocity);
}

class StillGesture extends EndGesture {
  StillGesture(this.direction) : super(0);

  final GestureDirection direction;
  bool get opening => direction == GestureDirection.opening;
  bool get closing => direction == GestureDirection.closing;
}

/// Represents a way to control a slidable from outside.
class SlidableController {
  SlidableController(TickerProvider vsync)
      : _animationController = AnimationController(vsync: vsync),
        endGesture = ValueNotifier(null),
        dismissGesture = ValueNotifier(null),
        resizeRequest = ValueNotifier(null),
        actionPaneType = ValueNotifier(ActionPaneType.none);

  final AnimationController _animationController;

  bool enableStartActionPane = true;
  bool enableEndActionPane = true;

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

  ActionPaneConfigurator actionPaneConfiguration;

  Animation<double> get animation => _animationController.view;

  final ValueNotifier<EndGesture> endGesture;
  final ValueNotifier<DismissGesture> dismissGesture;
  final ValueNotifier<ResizeRequest> resizeRequest;
  final ValueNotifier<ActionPaneType> actionPaneType;

  bool get closing => _closing;
  bool _closing = false;

  bool acceptRatio(double ratio) {
    return !_closing &&
        (ratio == 0 ||
            ((ratio > 0 && enableStartActionPane) ||
                    (ratio < 0 && enableEndActionPane)) &&
                (actionPaneConfiguration == null ||
                    actionPaneConfiguration.canChangeRatio(ratio.abs())));
  }

  double get ratio =>
      _animationController.value * actionPaneType.value.toSign();
  set ratio(double value) {
    if (acceptRatio(value) && value != ratio) {
      final index = value.sign.toInt() + 1;
      actionPaneType.value = ActionPaneType.values[index];
      _animationController.value = value.abs();
    }
  }

  void handleEndGesture(double velocity, GestureDirection direction) {
    if (velocity == 0 || velocity == null) {
      endGesture.value = StillGesture(direction);
    } else if (velocity.sign == actionPaneType.value.toSign()) {
      endGesture.value = OpeningGesture(velocity);
    } else {
      endGesture.value = ClosingGesture(velocity.abs());
    }
  }

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

  Future<void> openCurrentActionPane({
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) async {
    assert(actionPaneConfiguration != null);
    assert(duration != null);

    return openTo(
      actionPaneConfiguration.extentRatio,
      duration: duration,
      curve: curve,
    );
  }

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

  void dispose() {
    _animationController.stop();
    _animationController.dispose();
  }
}

extension ActionPaneTypeX on ActionPaneType {
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
