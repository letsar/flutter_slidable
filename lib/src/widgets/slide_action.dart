import 'package:flutter/material.dart';
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

/// A basic slide action with an icon, a caption and a background color.
class IconSlideAction extends StatelessWidget {
  const IconSlideAction({
    Key key,
    @required this.icon,
    this.caption,
    Color color,
    this.onTap,
  })  : color = color ?? Colors.white,
        super(key: key);

  final IconData icon;
  final String caption;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color foregroundColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light
            ? Colors.black
            : Colors.white;
    final Text textWidget = new Text(
      caption ?? '',
      overflow: TextOverflow.ellipsis,
      style: Theme
          .of(context)
          .primaryTextTheme
          .caption
          .copyWith(color: foregroundColor),
    );
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: color,
        child: new Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              new Flexible(
                child: new Icon(
                  icon,
                  color: foregroundColor,
                ),
              ),
              new Flexible(child: textWidget),
            ],
          ),
        ),
      ),
    );
  }
}
