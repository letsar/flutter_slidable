import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/src/sliding_details.dart';

const _defaultMovementDuration = Duration(milliseconds: 200);
const _defaultCurve = Curves.ease;

@immutable
class DismissRequest {
  const DismissRequest(this.duration, this.onDismissed);

  final Duration duration;
  final VoidCallback onDismissed;
}

@immutable
class EndGesture {
  EndGesture(this.velocity);
  final double velocity;
}

class ForwardGesture extends EndGesture {
  ForwardGesture(double velocity) : super(velocity);
}

class ReverseGesture extends EndGesture {
  ReverseGesture(double velocity) : super(velocity);
}

class StillGesture extends EndGesture {
  StillGesture() : super(0);
}

/// Represents a way to control a slidable from outside.
class SlidableController with ChangeNotifier {
  SlidableController(TickerProvider vsync)
      : _animationController = AnimationController(vsync: vsync) {
    _animationController.addListener(notifyListeners);
  }

  final AnimationController _animationController;

  bool enableActionPane = false;
  bool enableSecondaryActionPane = false;

  bool acceptRatio(double ratio) {
    return ratio == 0 ||
        (ratio > 0 && enableActionPane) ||
        (ratio < 0 && enableSecondaryActionPane);
  }

  Animation<double> get animation => _animationController.view;

  // SlidingDetails get slidingDetails => _slidingDetails;
  // SlidingDetails _slidingDetails;
  // set slidingDetails(SlidingDetails value) {
  //   if (_slidingDetails != value) {
  //     _slidingDetails = value;
  //     notifyListeners();
  //   }
  // }

  EndGesture get endGesture => _endGesture;
  EndGesture _endGesture;
  @protected
  set endGesture(EndGesture value) {
    if (_endGesture != value) {
      _endGesture = value;
      notifyListeners();
    }
  }

  double get sign => _sign;
  double _sign = 0;
  @protected
  set sign(double value) {
    if (_sign != value) {
      _sign = value;
      notifyListeners();
    }
  }

  DismissRequest get dismissRequest => _dismissRequest;
  DismissRequest _dismissRequest;
  set dismissRequest(DismissRequest value) {
    if (_dismissRequest != value) {
      _dismissRequest = value;
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
      // print(value);
      _sign = value.sign;
      _animationController.value = value.abs();
      notifyListeners();
    }
  }

  void handleEndGesture(double velocity) {
    if (velocity == 0) {
      endGesture = StillGesture();
    } else if (velocity.sign == sign) {
      endGesture = ForwardGesture(velocity);
    } else {
      endGesture = ReverseGesture(velocity.abs());
    }
  }

  void close({
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) {
    _animationController.animateTo(0, duration: duration, curve: curve);
  }

  void openTo(
    double ratio, {
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) {
    assert(ratio != null && ratio >= -1 && ratio <= 1);
    assert(duration != null);
    _animationController.animateTo(ratio, duration: duration, curve: curve);
  }

  void dismiss(
    DismissRequest dismissRequest, {
    Duration duration = _defaultMovementDuration,
    Curve curve = _defaultCurve,
  }) {
    this.dismissRequest = dismissRequest;
    _animationController
        .animateTo(1, duration: _defaultMovementDuration, curve: curve)
        .then((_) => this.dismissRequest = null);
  }

  @override
  void dispose() {
    _animationController.removeListener(notifyListeners);
    _animationController.dispose();
    super.dispose();
  }
}
