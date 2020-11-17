import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

const _defaultMovementDuration = Duration(milliseconds: 200);
const _defaultCurve = Curves.ease;

abstract class ActionPaneConfiguration {
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
class SlidableController with ChangeNotifier {
  SlidableController(TickerProvider vsync)
      : _animationController = AnimationController(vsync: vsync) {
    _animationController.addListener(notifyListeners);
  }

  final AnimationController _animationController;

  bool enableStartActionPane = false;
  bool enableEndActionPane = false;

  ActionPaneConfiguration actionPaneConfiguration;

  bool acceptRatio(double ratio) {
    return ratio == 0 ||
        ((ratio > 0 && enableStartActionPane) ||
                (ratio < 0 && enableEndActionPane)) &&
            (actionPaneConfiguration == null ||
                actionPaneConfiguration.canChangeRatio(ratio.abs()));
  }

  Animation<double> get animation => _animationController.view;

  EndGesture get endGesture => _endGesture;
  EndGesture _endGesture;
  @protected
  set endGesture(EndGesture value) {
    if (_endGesture != value) {
      _endGesture = value;
      notifyListeners();
    }
  }

  DismissGesture get dismissGesture => _dismissGesture;
  DismissGesture _dismissGesture;
  set dismissGesture(DismissGesture value) {
    if (_dismissGesture != value) {
      _dismissGesture = value;
      notifyListeners();
    }
  }

  double get sign => _animationController.value.sign * _sign;
  double _sign = 0;
  @protected
  set sign(double value) {
    if (_sign != value) {
      _sign = value;
      notifyListeners();
    }
  }

  ResizeRequest get resizeRequest => _resizeRequest;
  ResizeRequest _resizeRequest;
  set resizeRequest(ResizeRequest value) {
    if (_resizeRequest != value) {
      _resizeRequest = value;
      notifyListeners();
    }
  }

  /// The ratio between -1 and 1 representing the actual.
  ///
  /// When [ratio] is equals to 0, none of the action panels are visible.
  /// Within the interval [-1, 0[, the end action panel is visible.
  /// Within the interval ]0, 1], the start action panel is visible.
  double get ratio => _animationController.value * _sign;
  set ratio(double value) {
    if (ratio != value && acceptRatio(value)) {
      _sign = value.sign;
      _animationController.value = value.abs();
      notifyListeners();
    }
  }

  void handleEndGesture(double velocity, GestureDirection direction) {
    if (velocity == 0) {
      endGesture = StillGesture(direction);
    } else if (velocity.sign == sign) {
      endGesture = OpeningGesture(velocity);
    } else {
      endGesture = ClosingGesture(velocity.abs());
    }
  }

  TickerFuture close({
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) {
    return _animationController.animateTo(
      0,
      duration: duration,
      curve: curve,
    );
  }

  TickerFuture open({
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) {
    assert(actionPaneConfiguration != null);
    assert(duration != null);
    return openTo(
      actionPaneConfiguration.extentRatio,
      duration: duration,
      curve: curve,
    );
  }

  TickerFuture openTo(
    double ratio, {
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) {
    assert(ratio != null && ratio >= -1 && ratio <= 1);
    assert(duration != null);
    return _animationController.animateTo(
      ratio,
      duration: duration,
      curve: curve,
    );
  }

  void dismiss(
    ResizeRequest request, {
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) {
    resizeRequest = request;
    _animationController
        .animateTo(1, duration: _defaultMovementDuration, curve: curve)
        .then((_) => resizeRequest = null);
  }

  @override
  void dispose() {
    _animationController.removeListener(notifyListeners);
    _animationController.dispose();
    super.dispose();
  }
}
