import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class FlexEntranceTransition extends MultiChildRenderObjectWidget {
  FlexEntranceTransition({
    Key key,
    this.mainAxisPosition,
    this.direction,
    this.fromStart,
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

  /// The animation that controls the main axis position of the children.
  Animation<double> mainAxisPosition;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderFlexEntranceTransition(
      mainAxisPosition: mainAxisPosition,
      direction: direction,
      fromStart: fromStart,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, RenderFlexEntranceTransition renderObject) {
    renderObject
      ..mainAxisPosition = mainAxisPosition
      ..direction = direction
      ..fromStart = fromStart;
  }
}

class FlexDrawerParentData extends FlexParentData {
  Tween<double> mainAxisPosition;
}

class RenderFlexEntranceTransition extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, FlexDrawerParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, FlexDrawerParentData> {
  RenderFlexEntranceTransition({
    List<RenderBox> children,
    Axis direction = Axis.horizontal,
    Animation<double> mainAxisPosition,
    bool fromStart,
  })  : assert(direction != null),
        assert(mainAxisPosition != null),
        assert(fromStart != null),
        _direction = direction,
        _mainAxisPosition = mainAxisPosition,
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

  Animation<double> get mainAxisPosition => _mainAxisPosition;
  Animation<double> _mainAxisPosition;
  set mainAxisPosition(Animation<double> value) {
    assert(value != null);
    if (_mainAxisPosition != value) {
      if (attached) {
        _mainAxisPosition.removeListener(markNeedsOffsets);
        value.addListener(markNeedsOffsets);
      }
      _mainAxisPosition = value;
      markNeedsOffsets();
    }
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! FlexDrawerParentData) {
      child.parentData = FlexDrawerParentData();
    }
  }

  @override
  void attach(covariant PipelineOwner owner) {
    super.attach(owner);
    _mainAxisPosition.addListener(markNeedsOffsets);
  }

  @override
  void detach() {
    _mainAxisPosition.removeListener(markNeedsOffsets);
    super.detach();
  }

  void markNeedsOffsets() {
    updateOffsets();
    markNeedsPaint();
  }

  void updateOffsets() {
    visitChildren(updateChildOffsets);
  }

  void updateChildOffsets(RenderObject child) {
    final parentData = child.parentData as FlexDrawerParentData;
    final mainAxisPosition = parentData.mainAxisPosition.evaluate(
      _mainAxisPosition,
    );
    switch (_direction) {
      case Axis.horizontal:
        parentData.offset = Offset(mainAxisPosition, 0);
        break;
      case Axis.vertical:
        parentData.offset = Offset(0, mainAxisPosition);
        break;
    }
  }

  int getTotalFlex() {
    int totalFlex = 0;
    visitChildren((child) {
      final parentData = child.parentData as FlexDrawerParentData;
      assert(() {
        if (parentData.flex != null) {
          return true;
        } else {
          throw FlutterError.fromParts(
            [
              ErrorSummary(
                'DrawerTransition only supports children with non-zero flex',
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
    final totalFlex = getTotalFlex();
    double totalMainAxisExtent = 0;
    size = constraints.biggest;

    visitChildren((child) {
      final parentData = child.parentData as FlexDrawerParentData;
      final extentFactor = parentData.flex / totalFlex;
      BoxConstraints innerConstraints;
      double mainAxisExtent;
      double begin;
      switch (_direction) {
        case Axis.horizontal:
          mainAxisExtent = constraints.maxWidth * extentFactor;
          begin = fromStart ? -mainAxisExtent : size.width;
          innerConstraints = BoxConstraints.tightFor(
            height: constraints.maxHeight,
            width: mainAxisExtent,
          );
          break;
        case Axis.vertical:
          mainAxisExtent = constraints.maxHeight * extentFactor;
          begin = fromStart ? -mainAxisExtent : size.height;
          innerConstraints = BoxConstraints.tightFor(
            height: mainAxisExtent,
            width: constraints.maxWidth,
          );
          break;
      }
      parentData.mainAxisPosition = Tween(
        begin: begin,
        end: totalMainAxisExtent,
      );
      child.layout(innerConstraints);
      updateChildOffsets(child);
      totalMainAxisExtent += mainAxisExtent;
    });
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {@required Offset position}) {
    // The x, y parameters have the top left of the node's box as the origin.
    RenderBox child = fromStart ? firstChild : lastChild;
    while (child != null) {
      final childParentData = child.parentData as FlexDrawerParentData;
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
      final childParentData = child.parentData as FlexDrawerParentData;
      context.paintChild(child, childParentData.offset + offset);

      child = fromStart
          ? childParentData.previousSibling
          : childParentData.nextSibling;
    }
  }
}
