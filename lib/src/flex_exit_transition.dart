import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:meta/meta.dart';

@internal
class FlexExitTransition extends MultiChildRenderObjectWidget {
  /// The direction to use as the main axis.
  final Axis direction;

  /// Indicates whether the children are shown from start to end.
  final bool startToEnd;

  /// The extent ratio of this widget in its parent when [mainAxisExtent]'s
  /// value is 0..
  final double initialExtentRatio;

  /// The animation that controls the main axis position of the children.
  final Animation<double> mainAxisExtent;

  @internal
  FlexExitTransition({
    super.key,
    required this.mainAxisExtent,
    required this.direction,
    required this.startToEnd,
    required this.initialExtentRatio,
    required super.children,
  });

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlexExitTransition(
      mainAxisExtent: mainAxisExtent,
      direction: direction,
      initialExtentRatio: initialExtentRatio,
      startToEnd: startToEnd,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    RenderFlexExitTransition renderObject,
  ) {
    renderObject
      ..mainAxisExtent = mainAxisExtent
      ..direction = direction
      ..initialExtentRatio = initialExtentRatio
      ..startToEnd = startToEnd;
  }
}

class _FlexExitTransitionParentData extends FlexParentData {}

@internal
class RenderFlexExitTransition extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _FlexExitTransitionParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            _FlexExitTransitionParentData> {
  Axis _direction;
  Axis get direction => _direction;
  set direction(Axis value) {
    if (_direction != value) {
      _direction = value;
      markNeedsLayout();
    }
  }

  bool _startToEnd;
  bool get startToEnd => _startToEnd;
  set startToEnd(bool value) {
    if (_startToEnd != value) {
      _startToEnd = value;
      markNeedsLayout();
    }
  }

  double? _initialExtentRatio;
  double get initialExtentRatio => _initialExtentRatio!;
  set initialExtentRatio(double value) {
    if (_initialExtentRatio != value) {
      _initialExtentRatio = value;
      markNeedsLayout();
    }
  }

  Animation<double> _mainAxisExtent;
  Animation<double> get mainAxisExtent => _mainAxisExtent;
  set mainAxisExtent(Animation<double> value) {
    if (_mainAxisExtent != value) {
      if (attached) {
        _mainAxisExtent.removeListener(markNeedsOffsets);
        value.addListener(markNeedsOffsets);
      }
      _mainAxisExtent = value;
      markNeedsOffsets();
    }
  }

  @internal
  RenderFlexExitTransition({
    List<RenderBox>? children,
    Axis direction = Axis.horizontal,
    required Animation<double> mainAxisExtent,
    double? initialExtentRatio,
    required bool startToEnd,
  })  : _direction = direction,
        _mainAxisExtent = mainAxisExtent,
        _initialExtentRatio = initialExtentRatio,
        _startToEnd = startToEnd {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _FlexExitTransitionParentData) {
      child.parentData = _FlexExitTransitionParentData();
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _mainAxisExtent.addListener(markNeedsOffsets);
  }

  @override
  void detach() {
    _mainAxisExtent.removeListener(markNeedsOffsets);
    super.detach();
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    final totalMainAxisExtent =
        _direction == Axis.horizontal ? size.width : size.height;
    final totalFlex = getTotalFlex();
    double totalMainAxisExtentSoFar = 0;

    RenderBox? child = startToEnd ? firstChild : lastChild;

    while (child != null) {
      final parentData = child.parentData as _FlexExitTransitionParentData?;
      final extentFactor = parentData!.flex! / totalFlex * initialExtentRatio;
      late BoxConstraints innerConstraints;
      double? initialMainAxisExtent;
      switch (_direction) {
        case Axis.horizontal:
          initialMainAxisExtent = constraints.maxWidth * extentFactor;
          final extent = Tween(
                  begin: initialMainAxisExtent,
                  end: totalMainAxisExtent - totalMainAxisExtentSoFar)
              .evaluate(_mainAxisExtent);
          final begin = startToEnd
              ? totalMainAxisExtentSoFar
              : totalMainAxisExtent - totalMainAxisExtentSoFar - extent;
          parentData.offset = Offset(begin, 0);
          innerConstraints = BoxConstraints.tightFor(
            height: constraints.maxHeight,
            width: extent,
          );
          break;
        case Axis.vertical:
          initialMainAxisExtent = constraints.maxHeight * extentFactor;
          final extent = Tween(
                  begin: initialMainAxisExtent,
                  end: totalMainAxisExtent - totalMainAxisExtentSoFar)
              .evaluate(_mainAxisExtent);
          final begin = startToEnd
              ? totalMainAxisExtentSoFar
              : totalMainAxisExtent - totalMainAxisExtentSoFar - extent;
          parentData.offset = Offset(0, begin);
          innerConstraints = BoxConstraints.tightFor(
            height: extent,
            width: constraints.maxWidth,
          );
          break;
      }

      totalMainAxisExtentSoFar += initialMainAxisExtent;

      child.layout(innerConstraints);
      final _FlexExitTransitionParentData childParentData =
          child.parentData! as _FlexExitTransitionParentData;
      child = startToEnd
          ? childParentData.nextSibling
          : childParentData.previousSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // The x, y parameters have the top left of the node's box as the origin.
    RenderBox? child = startToEnd ? firstChild : lastChild;
    while (child != null) {
      final childParentData =
          child.parentData as _FlexExitTransitionParentData?;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData!.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child!.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = startToEnd
          ? childParentData.nextSibling
          : childParentData.previousSibling;
    }

    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox? child = startToEnd ? lastChild : firstChild;
    while (child != null) {
      final childParentData =
          child.parentData as _FlexExitTransitionParentData?;
      context.paintChild(child, childParentData!.offset + offset);

      child = startToEnd
          ? childParentData.previousSibling
          : childParentData.nextSibling;
    }
  }

  void markNeedsOffsets() {
    markNeedsLayout();
  }

  int getTotalFlex() {
    int totalFlex = 0;
    visitChildren((child) {
      final parentData = child.parentData as _FlexExitTransitionParentData?;
      assert(() {
        if (parentData!.flex != null) {
          return true;
        } else {
          throw FlutterError.fromParts(
            [
              ErrorSummary(
                'FlexTransition only supports children with non-zero flex',
              ),
              ErrorDescription(
                'Only children wrapped into Flexible widgets with non-zero '
                'flex are supported',
              ),
            ],
          );
        }
      }());
      totalFlex += parentData!.flex!;
    });
    return totalFlex;
  }
}
