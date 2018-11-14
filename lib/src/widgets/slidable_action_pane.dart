import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/src/widgets/slidable.dart';

class _SlidableStackActionPane extends StatelessWidget {
  _SlidableStackActionPane({
    Key key,
    @required this.state,
    @required this.child,
  })  : _animation = Tween<Offset>(
          begin: Offset.zero,
          end: state.createOffset(state.totalActionsExtent * state.actionSign),
        ).animate(state.actionsMoveAnimation),
        super(key: key);

  final Widget child;
  final SlidableState state;
  final Animation<Offset> _animation;

  @override
  Widget build(BuildContext context) {
    if (state.actionsMoveAnimation.isDismissed) {
      return state.widget.child;
    }

    return Stack(
      children: <Widget>[
        child,
        SlideTransition(
          position: _animation,
          child: state.widget.child,
        ),
      ],
    );
  }
}

/// An action pane that creates actions which stretch while the item is sliding.
class SlidableStrechActionPane extends StatelessWidget {
  const SlidableStrechActionPane({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SlidableState state = Slidable.of(context);

    final animation = Tween<double>(
      begin: 0.0,
      end: state.totalActionsExtent,
    ).animate(state.actionsMoveAnimation);

    return _SlidableStackActionPane(
      state: state,
      child: Positioned.fill(
        child: AnimatedBuilder(
          animation: state.actionsMoveAnimation,
          builder: (context, child) {
            return FractionallySizedBox(
              alignment: state.alignment,
              widthFactor: state.directionIsXAxis ? animation.value : null,
              heightFactor: state.directionIsXAxis ? null : animation.value,
              child: Flex(
                direction: state.widget.direction,
                children: state
                    .buildActions(context)
                    .map((a) => Expanded(child: a))
                    .toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// An action pane that creates actions which stay behind the item while it's sliding.
class SlidableBehindActionPane extends StatelessWidget {
  const SlidableBehindActionPane({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SlidableState state = Slidable.of(context);

    return _SlidableStackActionPane(
      state: state,
      child: Positioned.fill(
        child: FractionallySizedBox(
          alignment: state.alignment,
          widthFactor: state.actionPaneWidthFactor,
          heightFactor: state.actionPaneHeightFactor,
          child: Flex(
            direction: state.widget.direction,
            children: state
                .buildActions(context)
                .map((a) => Expanded(child: a))
                .toList(),
          ),
        ),
      ),
    );
  }
}

/// An action pane that creates actions which follow the item while it's sliding.
class SlidableScrollActionPane extends StatelessWidget {
  const SlidableScrollActionPane({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SlidableState state = Slidable.of(context);

    final alignment = state.alignment;
    final animation = Tween<Offset>(
      begin: Offset(alignment.x, alignment.y),
      end: Offset.zero,
    ).animate(state.actionsMoveAnimation);

    return _SlidableStackActionPane(
      state: state,
      child: Positioned.fill(
        child: FractionallySizedBox(
          alignment: state.alignment,
          widthFactor: state.actionPaneWidthFactor,
          heightFactor: state.actionPaneHeightFactor,
          child: SlideTransition(
            position: animation,
            child: Flex(
              direction: state.widget.direction,
              children: state
                  .buildActions(context)
                  .map((a) => Expanded(child: a))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

/// An action pane that creates actions which animate like drawers while the item is sliding.
class SlidableDrawerActionPane extends StatelessWidget {
  const SlidableDrawerActionPane({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final SlidableState state = Slidable.of(context);

    final alignment = state.alignment;
    final startOffset = Offset(alignment.x, alignment.y);
    final animations = Iterable.generate(state.actionCount).map((index) {
      return Tween<Offset>(
        begin: startOffset,
        end: startOffset * (index - 1.0),
      ).animate(state.actionsMoveAnimation);
    }).toList();

    return _SlidableStackActionPane(
      state: state,
      child: Positioned.fill(
        child: Stack(
          alignment: state.alignment,
          children: List.generate(
            state.actionCount,
            (index) {
              int displayIndex =
                  state.showActions ? state.actionCount - index - 1 : index;
              return FractionallySizedBox(
                alignment: state.alignment,
                widthFactor: state.directionIsXAxis
                    ? state.widget.actionExtentRatio
                    : null,
                heightFactor: state.directionIsXAxis
                    ? null
                    : state.widget.actionExtentRatio,
                child: SlideTransition(
                  position: animations[index],
                  child: state.actionDelegate.build(
                    context,
                    displayIndex,
                    state.actionsMoveAnimation,
                    SlidableRenderingMode.slide,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
