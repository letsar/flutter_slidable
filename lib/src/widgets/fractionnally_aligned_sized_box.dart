import 'package:flutter/widgets.dart';

class FractionallyAlignedSizedBox extends StatelessWidget {
  FractionallyAlignedSizedBox({
    Key key,
    @required this.child,
    this.leftFactor,
    this.topFactor,
    this.rightFactor,
    this.bottomFactor,
    this.widthFactor,
    this.heightFactor,
  })  : assert(
            leftFactor == null || rightFactor == null || widthFactor == null),
        assert(
            topFactor == null || bottomFactor == null || heightFactor == null),
        assert(widthFactor == null || widthFactor >= 0.0),
        assert(heightFactor == null || heightFactor >= 0.0),
        super(key: key);

  final double leftFactor;
  final double topFactor;
  final double rightFactor;
  final double bottomFactor;
  final double widthFactor;
  final double heightFactor;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    double dx = 0;
    double dy = 0;
    double width = widthFactor;
    double height = heightFactor;

    if (widthFactor == null) {
      final left = leftFactor ?? 0;
      final right = rightFactor ?? 0;
      width = 1 - left - right;

      if (width != 1) {
        dx = left / (1.0 - width);
      }
    }

    if (heightFactor == null) {
      final top = topFactor ?? 0;
      final bottom = bottomFactor ?? 0;
      height = 1 - top - bottom;
      if (height != 1) {
        dy = top / (1.0 - height);
      }
    }

    if (widthFactor != null && widthFactor != 1) {
      if (leftFactor != null) {
        dx = leftFactor / (1 - widthFactor);
      } else if (leftFactor == null && rightFactor != null) {
        dx = (1 - widthFactor - rightFactor) / (1 - widthFactor);
      }
    }

    if (heightFactor != null && heightFactor != 1) {
      if (topFactor != null) {
        dy = topFactor / (1 - heightFactor);
      } else if (topFactor == null && bottomFactor != null) {
        dy = (1 - heightFactor - bottomFactor) / (1 - heightFactor);
      }
    }

    return Align(
      alignment: FractionalOffset(
        dx,
        dy,
      ),
      child: FractionallySizedBox(
        widthFactor: width,
        heightFactor: height,
        child: child,
      ),
    );
  }
}
