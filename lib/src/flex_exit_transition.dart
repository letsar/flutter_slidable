import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FlexExitTransition extends MultiChildRenderObjectWidget {
  FlexExitTransition({
    Key key,
    this.mainAxisExtent,
    this.direction,
    this.fromStart,
    this.initialExtentRatio,
    List<Widget> children,
  }) : super(key: key, children: children);

  /// The direction to use as the main axis.
  ///
  /// If you know the axis in advance, then consider using a [Row] (if it's
  /// horizontal) or [Column] (if it's vertical) instead of a [Flex], since that
  /// will be less verbose. (For [Row] and [Column] this property is fixed to
  /// the appropriate axis.)
  final Axis direction;

  final bool fromStart;

  final double initialExtentRatio;

  /// The animation that controls the main axis position of the children.
  Animation<double> mainAxisExtent;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlexExitTransition(
      mainAxisExtent: mainAxisExtent,
      direction: direction,
      initialExtentRatio: initialExtentRatio,
      fromStart: fromStart,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderFlexExitTransition renderObject) {
    renderObject
      ..mainAxisExtent = mainAxisExtent
      ..direction = direction
      ..initialExtentRatio = initialExtentRatio
      ..fromStart = fromStart;
  }
}

class FlexExitTransitionParentData extends FlexParentData {}

class RenderFlexExitTransition extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexExitTransitionParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            FlexExitTransitionParentData> {
  RenderFlexExitTransition({
    List<RenderBox> children,
    Axis direction = Axis.horizontal,
    Animation<double> mainAxisExtent,
    double initialExtentRatio,
    bool fromStart,
  })  : assert(direction != null),
        assert(mainAxisExtent != null),
        assert(fromStart != null),
        _direction = direction,
        _mainAxisExtent = mainAxisExtent,
        _initialExtentRatio = initialExtentRatio,
        _fromStart = fromStart {
    addAll(children);
  }

  /// The direction to use as the main axis.
  Axis get direction => _direction;
  Axis _direction;
  set direction(Axis value) {
    assert(value != null);
    if (_direction != value) {
      _direction = value;
      markNeedsLayout();
    }
  }

  bool get fromStart => _fromStart;
  bool _fromStart;
  set fromStart(bool value) {
    assert(value != null);
    if (_fromStart != value) {
      _fromStart = value;
      markNeedsLayout();
    }
  }

  double get initialExtentRatio => _initialExtentRatio;
  double _initialExtentRatio;
  set initialExtentRatio(double value) {
    assert(value != null);
    if (_initialExtentRatio != value) {
      _initialExtentRatio = value;
      markNeedsLayout();
    }
  }

  Animation<double> get mainAxisExtent => _mainAxisExtent;
  Animation<double> _mainAxisExtent;
  set mainAxisExtent(Animation<double> value) {
    assert(value != null);
    if (_mainAxisExtent != value) {
      if (attached) {
        _mainAxisExtent.removeListener(markNeedsOffsets);
        value.addListener(markNeedsOffsets);
      }
      _mainAxisExtent = value;
      markNeedsOffsets();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FlexExitTransitionParentData) {
      child.parentData = FlexExitTransitionParentData();
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

  void markNeedsOffsets() {
    markNeedsLayout();
  }

  int getTotalFlex() {
    int totalFlex = 0;
    visitChildren((child) {
      final parentData = child.parentData as FlexExitTransitionParentData;
      assert(() {
        if (parentData.flex != null) {
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
      totalFlex += parentData.flex;
    });
    return totalFlex;
  }

  @override
  void performLayout() {
    size = constraints.biggest;
    final totalMainAxisExtent =
        _direction == Axis.horizontal ? size.width : size.height;
    final totalFlex = getTotalFlex();
    double totalMainAxisExtentSoFar = 0;

    visitChildren((child) {
      final parentData = child.parentData as FlexExitTransitionParentData;
      final extentFactor = parentData.flex / totalFlex * initialExtentRatio;
      BoxConstraints innerConstraints;
      double initialMainAxisExtent;
      switch (_direction) {
        case Axis.horizontal:
          parentData.offset = Offset(totalMainAxisExtentSoFar, 0);
          initialMainAxisExtent = constraints.maxWidth * extentFactor;
          innerConstraints = BoxConstraints.tightFor(
            height: constraints.maxHeight,
            width: Tween(
                    begin: initialMainAxisExtent,
                    end: totalMainAxisExtent - totalMainAxisExtentSoFar)
                .evaluate(_mainAxisExtent),
          );
          break;
        case Axis.vertical:
          parentData.offset = Offset(0, totalMainAxisExtentSoFar);
          initialMainAxisExtent = constraints.maxHeight * extentFactor;
          innerConstraints = BoxConstraints.tightFor(
            height: Tween(
                    begin: initialMainAxisExtent,
                    end: totalMainAxisExtent - totalMainAxisExtentSoFar)
                .evaluate(_mainAxisExtent),
            width: constraints.maxWidth,
          );
          break;
      }

      totalMainAxisExtentSoFar += initialMainAxisExtent;

      child.layout(innerConstraints);
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {@required Offset position}) {
    // The x, y parameters have the top left of the node's box as the origin.
    RenderBox child = fromStart ? firstChild : lastChild;
    while (child != null) {
      final childParentData = child.parentData as FlexExitTransitionParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: childParentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - childParentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
      child = fromStart
          ? childParentData.nextSibling
          : childParentData.previousSibling;
    }

    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox child = fromStart ? lastChild : firstChild;
    while (child != null) {
      final childParentData = child.parentData as FlexExitTransitionParentData;
      context.paintChild(child, childParentData.offset + offset);

      child = fromStart
          ? childParentData.previousSibling
          : childParentData.nextSibling;
    }
  }
}
