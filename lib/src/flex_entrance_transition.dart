import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

// INTERNAL USE
// ignore_for_file: public_member_api_docs

class FlexEntranceTransition extends MultiChildRenderObjectWidget {
  FlexEntranceTransition({
    Key key,
    @required this.mainAxisPosition,
    @required this.direction,
    @required this.startToEnd,
    @required List<Widget> children,
  })  : assert(mainAxisPosition != null),
        assert(direction != null),
        assert(startToEnd != null),
        super(key: key, children: children);

  /// The direction to use as the main axis.
  final Axis direction;

  /// Indicates whether the children are shown from start to end.
  final bool startToEnd;

  /// The animation that controls the main axis position of the children.
  final Animation<double> mainAxisPosition;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderFlexEntranceTransition(
      mainAxisPosition: mainAxisPosition,
      direction: direction,
      startToEnd: startToEnd,
    );
  }

  @override
  void updateRenderObject(
      BuildContext context, _RenderFlexEntranceTransition renderObject) {
    renderObject
      ..mainAxisPosition = mainAxisPosition
      ..direction = direction
      ..startToEnd = startToEnd;
  }
}

class _FlexEntranceTransitionParentData extends FlexParentData {
  Tween<double> mainAxisPosition;
}

class _RenderFlexEntranceTransition extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox,
            _FlexEntranceTransitionParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox,
            _FlexEntranceTransitionParentData> {
  _RenderFlexEntranceTransition({
    List<RenderBox> children,
    Axis direction = Axis.horizontal,
    Animation<double> mainAxisPosition,
    bool startToEnd,
  })  : assert(direction != null),
        assert(mainAxisPosition != null),
        assert(startToEnd != null),
        _direction = direction,
        _mainAxisPosition = mainAxisPosition,
        _startToEnd = startToEnd {
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

  bool get startToEnd => _startToEnd;
  bool _startToEnd;
  set startToEnd(bool value) {
    assert(value != null);
    if (_startToEnd != value) {
      _startToEnd = value;
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
    if (child.parentData is! _FlexEntranceTransitionParentData) {
      child.parentData = _FlexEntranceTransitionParentData();
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
    final parentData = child.parentData as _FlexEntranceTransitionParentData;
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
      final parentData = child.parentData as _FlexEntranceTransitionParentData;
      assert(() {
        if (parentData.flex != null) {
          return true;
        } else {
          throw FlutterError.fromParts(
            [
              ErrorSummary(
                'DrawerMotion only supports children with non-zero flex',
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
      final parentData = child.parentData as _FlexEntranceTransitionParentData;
      final extentFactor = parentData.flex / totalFlex;
      BoxConstraints innerConstraints;
      double mainAxisExtent;
      double begin;
      switch (_direction) {
        case Axis.horizontal:
          mainAxisExtent = constraints.maxWidth * extentFactor;
          begin = startToEnd ? -mainAxisExtent : size.width;
          innerConstraints = BoxConstraints.tightFor(
            height: constraints.maxHeight,
            width: mainAxisExtent,
          );
          break;
        case Axis.vertical:
          mainAxisExtent = constraints.maxHeight * extentFactor;
          begin = startToEnd ? -mainAxisExtent : size.height;
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
    RenderBox child = startToEnd ? firstChild : lastChild;
    while (child != null) {
      final childParentData =
          child.parentData as _FlexEntranceTransitionParentData;
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
      child = startToEnd
          ? childParentData.nextSibling
          : childParentData.previousSibling;
    }

    return false;
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    RenderBox child = startToEnd ? lastChild : firstChild;
    while (child != null) {
      final childParentData =
          child.parentData as _FlexEntranceTransitionParentData;
      context.paintChild(child, childParentData.offset + offset);

      child = startToEnd
          ? childParentData.previousSibling
          : childParentData.nextSibling;
    }
  }
}
