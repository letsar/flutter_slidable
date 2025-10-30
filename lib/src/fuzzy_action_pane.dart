part of 'slidable.dart';

class FuzzyActionPane extends ActionPane {
  FuzzyActionPane({Key? key, required FuzzyActionViewData viewData})
      : super(key: key, children: [], motion: FuzzyStretchMotion(viewData: viewData));

  @override
  _FuzzyActionPaneState createState() => _FuzzyActionPaneState();
}

class _FuzzyActionPaneState extends _ActionPaneState {
  @override
  void handleEndGestureChanged() {
    //final gesture = controller!.endGesture.value;
    final position = controller!.animation.value;

    if (position / widget.extentRatio < 0.1) controller!.close();
  }
}

class FuzzyStretchMotion extends StatelessWidget {
  late final FuzzyActionViewData viewData;

  FuzzyStretchMotion({required this.viewData});

  @override
  Widget build(BuildContext context) {
    final paneData = ActionPane.of(context);
    final controller = Slidable.of(context)!;

    return AnimatedBuilder(
      animation: controller.animation,
      builder: (BuildContext context, Widget? child) {
        final double value = controller.animation.value / paneData!.extentRatio;
        final int percent = normalizeRatio(value);
        return FractionallySizedBox(
          alignment: paneData.alignment,
          widthFactor: paneData.direction == Axis.horizontal ? value : 1,
          heightFactor: paneData.direction == Axis.horizontal ? 1 : value,
          child: viewData.viewBuilder == null
              ? SlidableFuzzyAction(
                  percent: percent,
                  onPress: (context, p) {viewData.onPress(context, p); controller.close();},
                  foregroundColor: viewData.foregroundColorBuilder == null
                      ? null
                      : viewData.foregroundColorBuilder!(context, percent),
                  backgroundColor: viewData.backgroundColorBuilder == null
                      ? null
                      : viewData.backgroundColorBuilder!(context, percent),
                  label: viewData.labelBuilder == null ? null : viewData.labelBuilder!(context, percent),
                  icon: viewData.iconBuilder == null ? null : viewData.iconBuilder!(context, percent),
                )
              : InkWell(
                  onTap: () { viewData.onPress(context, percent); controller.close();},
                  child: viewData.viewBuilder!(context, percent),
                ),
        );
      },
    );
  }

  int normalizeRatio(double ratio) {
    if (ratio <= 0.1) return 0;
    if (ratio > 1.0) return 100;
    //
    return (ratio * 1000 / 9 - 100 / 9).toInt();
  }
}

class SlidableFuzzyAction extends StatelessWidget {
  late final int percent;
  late final void Function(BuildContext, int) onPress;
  //
  final IconData? icon;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final String? label;

  SlidableFuzzyAction(
      {Key? key,
      required this.percent,
      this.icon,
      this.backgroundColor,
      this.foregroundColor,
      this.label,
      required this.onPress});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
        style: OutlinedButton.styleFrom(
            padding: EdgeInsets.zero,
            side: BorderSide.none,
            primary: foregroundColor,
            onSurface: foregroundColor,
            backgroundColor: backgroundColor,
            shape: const RoundedRectangleBorder()),
        onPressed: () => onPress(context, percent),
        child: icon == null
            ? Text(
                label ?? '',
                overflow: TextOverflow.ellipsis,
              )
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(icon!),
                  Text(
                    label ?? '',
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ));
  }
}

/// every builder takes the percent as parameter so that the view changes with the percent value change,
/// if the viewBuilder exists, other builder will be ignored
class FuzzyActionViewData {
  late final void Function(BuildContext context, int percent) onPress;
  //
  final Widget Function(BuildContext context, int percent)? viewBuilder;
  //
  final IconData Function(BuildContext context, int percent)? iconBuilder;
  final Color Function(BuildContext context, int percent)? backgroundColorBuilder;
  final Color Function(BuildContext context, int percent)? foregroundColorBuilder;
  final String Function(BuildContext context, int percent)? labelBuilder;

  FuzzyActionViewData(
      {required this.onPress,
      this.viewBuilder,
      this.iconBuilder,
      this.backgroundColorBuilder,
      this.foregroundColorBuilder,
      this.labelBuilder});
}
