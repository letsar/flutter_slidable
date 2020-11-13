import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class SlidableStack extends MultiChildRenderObjectWidget {
  SlidableStack({
    Key key,
    this.alignment,
    Widget actionPane,
    Widget child,
  }) : super(
          key: key,
          children: [
            if (actionPane != null) actionPane,
            child,
          ],
        );

  final AlignmentGeometry alignment;

  @override
  RenderSlidableStack createRenderObject(BuildContext context) {
    return RenderSlidableStack(alignment: alignment);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderSlidableStack renderObject,
  ) {
    renderObject..alignment = alignment;
  }
}

class SlidableStackParentData extends ContainerBoxParentData<RenderBox> {}

class RenderSlidableStack extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SlidableStackParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SlidableStackParentData> {
  RenderSlidableStack({
    List<RenderBox> children,
    AlignmentGeometry alignment = AlignmentDirectional.topStart,
  })  : assert(alignment != null),
        _alignment = alignment {
    addAll(children);
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SlidableStackParentData)
      child.parentData = SlidableStackParentData();
  }

  AlignmentGeometry get alignment => _alignment;
  AlignmentGeometry _alignment;
  set alignment(AlignmentGeometry value) {
    assert(value != null);
    if (_alignment == value) {
      return;
    }
    _alignment = value;
    markNeedsLayout();
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    return lastChild.getMinIntrinsicWidth(height);
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    return lastChild.getMaxIntrinsicWidth(height);
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    return lastChild.getMinIntrinsicHeight(width);
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    return lastChild.getMaxIntrinsicHeight(width);
  }

  @override
  double computeDistanceToActualBaseline(TextBaseline baseline) {
    return defaultComputeDistanceToHighestActualBaseline(baseline);
  }

  @override
  void performLayout() {
    // The last child is our 'child'.
    lastChild.layout(constraints, parentUsesSize: true);
    size = constraints.constrain(lastChild.size);

    // The first child is the action pane.
    if (childCount == 2) {
      firstChild.layout(BoxConstraints.loose(size));
      final parentData = firstChild.parentData as SlidableStackParentData;
      // parentData.offset =
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {@required Offset position}) {
    return defaultHitTestChildren(result, position: position);
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    defaultPaint(context, offset);
  }
}
