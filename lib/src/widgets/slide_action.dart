import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/src/widgets/slidable.dart';

const bool _kCloseOnTap = true;

/// Abstract class for slide actions that can close after [onTap] occurred.
abstract class ClosableSlideAction extends StatelessWidget {
  /// Creates a slide that closes when a tap has occurred if [closeOnTap]
  /// is [true].
  ///
  /// The [closeOnTap] argument must not be null.
  const ClosableSlideAction({
    Key key,
    this.onTap,
    this.closeOnTap = _kCloseOnTap,
  })  : assert(closeOnTap != null),
        super(key: key);

  /// A tap has occurred.
  final VoidCallback onTap;

  /// Whether close this after tap occurred.
  ///
  /// Defaults to true.
  final bool closeOnTap;

  /// Calls [onTap] if not null and closes the closest [Slidable]
  /// that encloses the given context.
  void _handleCloseAfterTap(BuildContext context) {
    if (onTap != null) {
      onTap();
    }

    Slidable.of(context).close();
  }

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: !closeOnTap ? onTap : () => _handleCloseAfterTap(context),
      child: buildAction(context),
    );
  }

  Widget buildAction(BuildContext context);
}

/// A basic slide action with a background color and a child that will
/// be center inside its area.
class SlideAction extends ClosableSlideAction {
  /// Creates a slide action with a child.
  ///
  /// The `color` argument is a shorthand for `decoration: new
  /// BoxDecoration(color: color)`, which means you cannot supply both a `color`
  /// and a `decoration` argument. If you want to have both a `color` and a
  /// `decoration`, you can pass the color as the `color` argument to the
  /// `BoxDecoration`.
  ///
  /// The [closeOnTap] argument must not be null.
  SlideAction({
    Key key,
    @required this.child,
    VoidCallback onTap,
    Color color,
    Decoration decoration,
    bool closeOnTap = _kCloseOnTap,
  })  : assert(child != null),
        assert(decoration == null || decoration.debugAssertIsValid()),
        assert(
            color == null || decoration == null,
            'Cannot provide both a color and a decoration\n'
            'The color argument is just a shorthand for "decoration: new BoxDecoration(color: color)".'),
        decoration = decoration ??
            (color != null ? new BoxDecoration(color: color) : null),
        super(
          key: key,
          onTap: onTap,
          closeOnTap: closeOnTap,
        );

  final Decoration decoration;

  final Widget child;

  @override
  Widget buildAction(BuildContext context) {
    return Container(
      decoration: decoration,
      child: new Center(
        child: child,
      ),
    );
  }
}

/// A basic slide action with an icon, a caption and a background color.
class IconSlideAction extends ClosableSlideAction {
  /// Creates a slide action with an icon, a [caption] if set and a
  /// background color.
  ///
  /// The [closeOnTap] argument must not be null.
  const IconSlideAction({
    Key key,
    @required this.icon,
    this.sizeIcon,
    this.caption,
    Color color,
    this.foregroundColor,
    VoidCallback onTap,
    bool closeOnTap = _kCloseOnTap,
  })  : color = color ?? Colors.white,
        super(
          key: key,
          onTap: onTap,
          closeOnTap: closeOnTap,
        );

  final IconData icon;
  final double sizeIcon;
  final String caption;

  /// The background color.
  ///
  /// Defaults to true.
  final Color color;

  final Color foregroundColor;

  @override
  Widget buildAction(BuildContext context) {
    final Color estimatedColor =
        ThemeData.estimateBrightnessForColor(color) == Brightness.light
            ? Colors.black
            : Colors.white;
    final Text textWidget = new Text(
      caption ?? '',
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context)
          .primaryTextTheme
          .caption
          .copyWith(color: foregroundColor ?? estimatedColor),
    );
    return Container(
      color: color,
      child: new Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            new Flexible(
              child: new Icon(
                icon,
                size: sizeIcon,
                color: foregroundColor ?? estimatedColor,
              ),
            ),
            new Flexible(child: textWidget),
          ],
        ),
      ),
    );
  }
}
