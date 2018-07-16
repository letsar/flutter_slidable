import 'package:flutter/widgets.dart';

class SlideAction extends StatelessWidget {
  SlideAction({
    Key key,
    @required this.child,
    this.background,
  })  : assert(child != null),
        super(key: key);

  final Color background;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return new Center(
      child: child,
    );
  }
}
