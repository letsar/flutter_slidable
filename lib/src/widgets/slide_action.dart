import 'package:flutter/widgets.dart';

/// A basic slide action with a background color and a child that will
/// be center inside its area.
class SlideAction extends StatelessWidget {
  SlideAction({
    Key key,
    @required this.child,
    this.onTap,
    Color color,
    Decoration decoration,
  })  : assert(child != null),
        assert(decoration == null || decoration.debugAssertIsValid()),
        assert(
            color == null || decoration == null,
            'Cannot provide both a color and a decoration\n'
            'The color argument is just a shorthand for "decoration: new BoxDecoration(color: color)".'),
        decoration = decoration ??
            (color != null ? new BoxDecoration(color: color) : null),
        super(key: key);

  final Decoration decoration;

  final Widget child;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: decoration,
        child: new Center(
          child: child,
        ),
      ),
    );
  }
}
