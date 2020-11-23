import 'package:flutter/material.dart';

import 'slidable.dart';

typedef SlidableActionCallback = void Function(BuildContext context);

const int _kFlex = 1;
const Color _kBackgroundColor = Colors.white;
const bool _kAutoClose = true;

class SlidableAction extends StatelessWidget {
  const SlidableAction({
    Key key,
    this.flex = _kFlex,
    this.backgroundColor = _kBackgroundColor,
    this.foregroundColor,
    this.autoClose = _kAutoClose,
    @required this.onPressed,
    @required this.child,
  })  : assert(flex != null && flex > 0),
        assert(backgroundColor != null),
        assert(autoClose != null),
        assert(child != null),
        super(key: key);

  final int flex;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool autoClose;
  final SlidableActionCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final effectiveForegroundColor = foregroundColor ??
        (ThemeData.estimateBrightnessForColor(backgroundColor) ==
                Brightness.light
            ? Colors.black
            : Colors.white);

    return Expanded(
      flex: flex,
      child: SizedBox.expand(
        child: OutlinedButton(
          onPressed: () => _handleTap(context),
          style: OutlinedButton.styleFrom(
            backgroundColor: backgroundColor,
            primary: effectiveForegroundColor,
            onSurface: effectiveForegroundColor,
            shape: const RoundedRectangleBorder(),
            side: BorderSide.none,
          ),
          child: child,
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    onPressed?.call(context);
    if (autoClose) {
      Slidable.of(context)?.close();
    }
  }
}

class SlidableIconAction extends StatelessWidget {
  const SlidableIconAction({
    Key key,
    this.flex = _kFlex,
    this.backgroundColor = _kBackgroundColor,
    this.foregroundColor,
    this.autoClose = _kAutoClose,
    @required this.onPressed,
    this.icon,
    this.spacing = 4,
    this.label,
  })  : assert(flex != null && flex > 0),
        assert(backgroundColor != null),
        assert(autoClose != null),
        assert(icon != null || label != null),
        assert(spacing != null),
        super(key: key);

  final int flex;
  final Color backgroundColor;
  final Color foregroundColor;
  final bool autoClose;
  final SlidableActionCallback onPressed;
  final IconData icon;
  final double spacing;
  final String label;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];

    if (icon != null) {
      children.add(
        Flexible(
          child: Icon(icon),
        ),
      );
    }

    if (label != null) {
      if (children.isNotEmpty) {
        children.add(
          Flexible(
            child: SizedBox(height: spacing),
          ),
        );
      }

      children.add(
        Flexible(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }

    final child = children.length == 1
        ? children.first
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: children,
          );

    return SlidableAction(
      onPressed: onPressed,
      autoClose: autoClose,
      backgroundColor: backgroundColor,
      foregroundColor: foregroundColor,
      flex: flex,
      child: child,
    );
  }
}
