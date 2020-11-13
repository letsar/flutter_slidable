import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_slidable/src/action_pane_transition.dart';
import 'package:flutter_slidable/src/slidable_controller.dart';
import 'package:flutter_slidable/src/sliding_details.dart';

const _defaultExtentRatio = 0.5;

class ActionPane extends StatefulWidget {
  const ActionPane({
    Key key,
    this.extentRatio = _defaultExtentRatio,
    @required this.transition,
    this.children,
  })  : assert(extentRatio != null && extentRatio > 0 && extentRatio <= 1),
        assert(children != null),
        super(key: key);

  /// The total extent of this [ActionPane] relatively to the enclosing
  /// [Slidable] widget.
  ///
  /// Must be between 0 (excluded) and 1.
  final double extentRatio;

  // Penser à pouvoir faire des widgets 80/20.
  // ActionSlide avec int en paramètre => Flexible

  final Widget transition;

  final List<Widget> children;

  @override
  _ActionPaneState createState() => _ActionPaneState();

  static ActionPane of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ActionPaneScope>()
        ?.actionPane;
  }
}

class _ActionPaneState extends State<ActionPane> {
  SlidableController controller;
  // SlidingDetails slidingDetails;
  EndGesture endGesture;
  double ratio = 0;

  @override
  void initState() {
    super.initState();
    controller = Slidable.of(context);
    controller.addListener(handleControllerChanges);
  }

  @override
  void dispose() {
    controller.removeListener(handleControllerChanges);
    super.dispose();
  }

  void handleControllerChanges() {
    // if (slidingDetails != controller.slidingDetails) {
    //   slidingDetails = controller.slidingDetails;
    //   handleSlidingDetailsChanged();
    // }
    if (endGesture != controller.endGesture) {
      endGesture = controller.endGesture;
      handleEndGestureChanged();
    }
  }

  // void handleSlidingDetailsChanged() {
  //   // indicate it to the panes ?
  //   if (!slidingDetails.active) {
  //     if (slidingDetails.shouldOpen) {
  //       controller.openTo(0.5);
  //     } else if (controller.ratio.abs() > 0.5) {
  //       // controller.dismiss(DismissRequest(Duration(milliseconds: 300), null));
  //     } else {
  //       controller.close();
  //     }
  //   }
  // }

  void handleEndGestureChanged() {
    // indicate it to the panes ?
    if (endGesture is ForwardGesture) {
      controller.openTo(0.5);
    } else if (endGesture is ReverseGesture) {
      controller.close();
    } else if (endGesture is StillGesture) {
      if (controller.ratio.abs() < 0.25) {
        controller.close();
      } else {
        controller.openTo(0.5);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = ActionPaneStyle.of(context);
    return _ActionPaneScope(
      actionPane: widget,
      child: FractionallySizedBox(
        alignment: style.alignment,
        widthFactor:
            style.direction == Axis.horizontal ? widget.extentRatio : null,
        heightFactor:
            style.direction == Axis.horizontal ? null : widget.extentRatio,
        child: widget.transition,
      ),
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

// class ActionPane extends StatefulWidget {
//   const ActionPane({
//     Key key,
//     @required this.child,
//   }) : super(key: key);

//   final Widget child;

//   @override
//   _ActionPaneState createState() => _ActionPaneState();
// }

// class _ActionPaneState extends State<ActionPane> {
//   SlidableController controller;
//   SlidingDetails slidingDetails;
//   double ratio = 0;

//   @override
//   void initState() {
//     super.initState();
//     controller = Slidable.of(context);
//     controller.addListener(handleControllerChanges);
//   }

//   @override
//   void dispose() {
//     controller.removeListener(handleControllerChanges);
//     super.dispose();
//   }

//   void handleControllerChanges() {
//     if (slidingDetails != controller.slidingDetails) {
//       slidingDetails = controller.slidingDetails;
//       handleSlidingDetailsChanged();
//     }
//   }

//   void handleRatioChanged() {}

//   void handleRatioSignChanged() {}

//   void handleSlidingDetailsChanged() {
//     // indicate it to the panes ?
//     if (!slidingDetails.active) {
//       if (slidingDetails.shouldOpen) {
//         controller.openTo(0.5);
//       } else if (controller.ratio.abs() > 0.5) {
//         controller.dismiss(DismissRequest(Duration(milliseconds: 300), null));
//       } else {
//         controller.close();
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return widget.child;
//   }
// }
