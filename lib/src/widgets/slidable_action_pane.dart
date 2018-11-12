import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/src/widgets/slidable.dart';

class _SlidableStackActionPane extends StatelessWidget {
  _SlidableStackActionPane({
    Key key,
    @required this.state,
    @required this.child,
  })  : _animation = Tween<Offset>(
          begin: Offset.zero,
          end: SlidableHelpers.createOffset(
              state, state.totalActionsExtent * state.dragSign),
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

    return Container(
      child: Stack(
        children: <Widget>[
          child,
          SlideTransition(
            position: _animation,
            child: state.widget.child,
          ),
        ],
      ),
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
      end: state.totalActionsExtent * state.dragSign,
    ).animate(state.actionsMoveAnimation);

    return _SlidableStackActionPane(
      state: state,
      child: Positioned.fill(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedBuilder(
              animation: state.actionsMoveAnimation,
              builder: (context, child) {
                return Stack(
                  children: <Widget>[
                    SlidableHelpers.createPositioned(
                      state,
                      position: 0.0,
                      extent: SlidableHelpers.getMaxExtent(state, constraints) *
                          animation.value.abs(),
                      child: Flex(
                        direction: state.widget.direction,
                        children: SlidableHelpers.buildActions(context, state)
                            .map((a) => Expanded(child: a))
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            return AnimatedBuilder(
              animation: state.actionsMoveAnimation,
              builder: (context, child) {
                return Stack(
                  children: <Widget>[
                    SlidableHelpers.createPositioned(
                      state,
                      position: 0.0,
                      extent: SlidableHelpers.getMaxExtent(state, constraints) *
                          state.totalActionsExtent,
                      child: Flex(
                        direction: state.widget.direction,
                        children: SlidableHelpers.buildActions(context, state)
                            .map((a) => Expanded(child: a))
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
            );
          },
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

    return _SlidableStackActionPane(
      state: state,
      child: Positioned.fill(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double totalExtent =
                SlidableHelpers.getMaxExtent(state, constraints) *
                    state.totalActionsExtent;

            final animation = Tween<double>(
              begin: -totalExtent,
              end: 0.0,
            ).animate(state.actionsMoveAnimation);

            return AnimatedBuilder(
              animation: state.actionsMoveAnimation,
              builder: (context, child) {
                return Stack(
                  children: <Widget>[
                    SlidableHelpers.createPositioned(
                      state,
                      position: animation.value,
                      extent: totalExtent,
                      child: Flex(
                        direction: state.widget.direction,
                        children: SlidableHelpers.buildActions(context, state)
                            .map((a) => Expanded(child: a))
                            .toList(),
                      ),
                    ),
                  ],
                );
              },
            );
          },
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

    return _SlidableStackActionPane(
      state: state,
      child: Positioned.fill(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final count = state.actionCount;
            final bool showActions = state.showActions;
            final Animation<double> actionsMoveAnimation =
                state.actionsMoveAnimation;
            final double actionExtent =
                SlidableHelpers.getMaxExtent(state, constraints) *
                    state.widget.actionExtentRatio;
            final SlideActionDelegate actionDelegate = state.actionDelegate;

            final animations = Iterable.generate(count).map((index) {
              return Tween<double>(
                begin: -actionExtent,
                end: (count - index - 1) * actionExtent,
              ).animate(actionsMoveAnimation);
            }).toList();

            return AnimatedBuilder(
              animation: actionsMoveAnimation,
              builder: (context, child) {
                return Stack(
                  children: List.generate(
                    count,
                    (index) {
                      // For the main actions we have to reverse the order if we want the last item at the bottom of the stack.
                      int displayIndex =
                          showActions ? count - index - 1 : index;
                      return SlidableHelpers.createPositioned(
                        state,
                        position: animations[index].value,
                        extent: actionExtent,
                        child: actionDelegate.build(
                          context,
                          displayIndex,
                          actionsMoveAnimation,
                          SlidableRenderingMode.slide,
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
