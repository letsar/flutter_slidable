import 'package:flutter/gestures.dart';
import 'package:flutter_slidable/src/widgets/slidable_action_pane.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:test/test.dart' show fail;
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

const double itemExtent = 100.0;
const double actionExtentRatio = 0.2;
const int a0 = 0;
const int a1 = 1;
const int s0 = 10;
const int s1 = 11;
const List<int> allActions = const <int>[a0, a1, s0, s1];
const List<AxisDirection> axisDirections = const <AxisDirection>[
  AxisDirection.right,
  AxisDirection.left,
  AxisDirection.down,
  AxisDirection.up
];

const Size screenSize = const Size(800.0, 600.0);

SlideActionDelegate _buildActionDelegate(int index) {
  return SlideActionListDelegate(
    actions: <Widget>[
      SlideAction(
        key: ValueKey(getSlideActionBaseKey(index) + a0),
        child: const Text('a0'),
      ),
      SlideAction(
        key: ValueKey(getSlideActionBaseKey(index) + a1),
        child: const Text('a1'),
      ),
    ],
  );
}

SlideActionDelegate _buildSecondaryActionDelegate(int index) {
  return SlideActionListDelegate(
    actions: <Widget>[
      SlideAction(
        key: ValueKey(getSlideActionBaseKey(index) + s0),
        child: const Text('s0'),
      ),
      SlideAction(
        key: ValueKey(getSlideActionBaseKey(index) + s1),
        child: const Text('s1'),
      ),
    ],
  );
}

Widget buildTest(
  Widget actionPane, {
  TextDirection textDirection = TextDirection.ltr,
  Axis scrollDirection = Axis.vertical,
}) {
  Widget buildSlidableWidget(int item) {
    return Slidable.builder(
      key: ValueKey(item),
      actionPane: actionPane,
      enabled: item != 3,
      direction: flipAxis(scrollDirection),
      actionExtentRatio: actionExtentRatio,
      actionDelegate: _buildActionDelegate(item),
      secondaryActionDelegate: _buildSecondaryActionDelegate(item),
      child: Container(
        width:
            scrollDirection == Axis.horizontal ? itemExtent : screenSize.width,
        height:
            scrollDirection == Axis.horizontal ? screenSize.height : itemExtent,
        child: Text('item $item'),
      ),
    );
  }

  return Directionality(
    textDirection: textDirection,
    child: ListView(
      scrollDirection: scrollDirection,
      itemExtent: itemExtent,
      children:
          List.generate(5, (int index) => buildSlidableWidget(index)).toList(),
    ),
  );
}

Offset getOffset(AxisDirection gestureDirection, double value) {
  switch (gestureDirection) {
    case AxisDirection.left:
      return Offset(-value, 0.0);
    case AxisDirection.right:
      return Offset(value, 0.0);
    case AxisDirection.up:
      return Offset(0.0, -value);
    case AxisDirection.down:
      return Offset(0.0, value);
    default:
      fail('unsupported gestureDirection');
  }
}

Future<Null> flingElement(
  WidgetTester tester,
  Finder finder, {
  required AxisDirection gestureDirection,
  double initialOffsetFactor = 0.0,
}) async {
  final double itemExtent =
      axisDirectionToAxis(gestureDirection) == Axis.horizontal
          ? screenSize.width
          : screenSize.height;
  final Offset delta =
      getOffset(gestureDirection, initialOffsetFactor * itemExtent);
  await tester.fling(finder, delta, 1000.0);
}

Future<Null> dragElement(
  WidgetTester tester,
  Finder finder, {
  required AxisDirection gestureDirection,
  double endOffsetFactor = 0,
}) async {
  final double itemExtent =
      axisDirectionToAxis(gestureDirection) == Axis.horizontal
          ? screenSize.width
          : screenSize.height;

  // Strange behavior, for horizontal sliding, the dragStart is called only
  // after kDragSlopDefault offset.
  // This is maybe an issue in flutter test.
  final correction = axisDirectionToAxis(gestureDirection) == Axis.horizontal
      ? kDragSlopDefault
      : 0;
  final Offset delta =
      getOffset(gestureDirection, endOffsetFactor * itemExtent + correction);
  await tester.drag(finder, delta);
}

Future<Null> dragItem(
  WidgetTester tester,
  int item, {
  required AxisDirection gestureDirection,
  double endOffsetFactor = 0,
}) async {
  await dragElement(
    tester,
    find.text('item $item'),
    gestureDirection: gestureDirection,
    endOffsetFactor: endOffsetFactor,
  );
  await tester.pump(); // start the slide.
}

Future<Null> flingItem(
  WidgetTester tester,
  int item, {
  required AxisDirection gestureDirection,
  double initialOffsetFactor = 0.0,
}) async {
  await flingElement(tester, find.text('item $item'),
      gestureDirection: gestureDirection,
      initialOffsetFactor: initialOffsetFactor);
  await tester.pump(); // start the slide.
  await tester.pump(
      const Duration(seconds: 1)); // finish the slide and start shrinking...
  await tester.pump();
}

int getSlideActionBaseKey(int index) {
  return (index + 1) * 100;
}

void checkActions(int index,
    {List<int> visible = const <int>[], List<int> hidden = const <int>[]}) {
  for (int key in visible) {
    expect(find.byKey(ValueKey(getSlideActionBaseKey(index) + key)),
        findsOneWidget);
  }
  for (int key in hidden) {
    expect(
        find.byKey(ValueKey(getSlideActionBaseKey(index) + key)), findsNothing);
  }
}

void checkAction({
  required int index,
  required int key,
  required WidgetTester tester,
  required AxisDirection gestureDirection,
  required double edgeRatio,
  required double extentRatio,
}) {
  Finder finder = find.byKey(ValueKey(getSlideActionBaseKey(index) + key));
  double actualEdge;
  double actualExtent;
  final double fullExtent =
      axisDirectionToAxis(gestureDirection) == Axis.horizontal
          ? screenSize.width
          : screenSize.height;
  double expectedEdge = fullExtent * edgeRatio;
  double expectedExtent = fullExtent * extentRatio;

  switch (gestureDirection) {
    case AxisDirection.left:
      actualEdge = screenSize.width - tester.getTopLeft(finder).dx;
      actualExtent = tester.getSize(finder).width;
      break;
    case AxisDirection.right:
      actualEdge = tester.getTopRight(finder).dx;
      actualExtent = tester.getSize(finder).width;
      break;
    case AxisDirection.up:
      actualEdge = screenSize.height - tester.getTopRight(finder).dy;
      actualExtent = tester.getSize(finder).height;
      break;
    case AxisDirection.down:
      actualEdge = tester.getBottomRight(finder).dy;
      actualExtent = tester.getSize(finder).height;
      break;
    default:
      fail('unsupported gestureDirection');
  }
  expect(actualEdge.roundToDouble(), expectedEdge.roundToDouble(),
      reason: 'edges are not'
          ' equal');
  expect(actualExtent.roundToDouble(), expectedExtent.roundToDouble(),
      reason: 'exten'
          'ts are not equal');
}

typedef List<_CheckActionValues>? SlidableDelegateTestMethod(
    AxisDirection direction);

void testSlidableDelegate(
    Widget actionPane,
    SlidableDelegateTestMethod slidableDelegateTestMethod,
    double endOffsetFactor) {
  final int index = 0;

  axisDirections.forEach((direction) {
    testSlidableDelegateScenario(
      actionPane,
      index,
      endOffsetFactor,
      slidableDelegateTestMethod,
      direction,
    );
  });
}

List<_CheckActionValues>? getSlidableStrechDelegateHalfValues(
    AxisDirection direction) {
  final double extentRatio = actionExtentRatio / 2;

  switch (direction) {
    case AxisDirection.right:
      return <_CheckActionValues>[
        _CheckActionValues(a0, .1, extentRatio),
        _CheckActionValues(a1, .2, extentRatio),
      ];
    case AxisDirection.left:
      return <_CheckActionValues>[
        _CheckActionValues(s0, .2, extentRatio),
        _CheckActionValues(s1, .1, extentRatio),
      ];
    case AxisDirection.down:
      return <_CheckActionValues>[
        _CheckActionValues(a0, .1, extentRatio),
        _CheckActionValues(a1, .2, extentRatio),
      ];
    case AxisDirection.up:
      return <_CheckActionValues>[
        _CheckActionValues(s0, .2, extentRatio),
        _CheckActionValues(s1, .1, extentRatio),
      ];
    default:
      return null;
  }
}

List<_CheckActionValues>? getSlidableBehindDelegateHalfValues(
    AxisDirection direction) {
  // All the actions are entirely built.
  final double extentRatio = actionExtentRatio;

  switch (direction) {
    case AxisDirection.right:
      return <_CheckActionValues>[
        _CheckActionValues(a0, actionExtentRatio, extentRatio),
        _CheckActionValues(a1, actionExtentRatio * 2, extentRatio),
      ];
    case AxisDirection.left:
      return <_CheckActionValues>[
        _CheckActionValues(s0, actionExtentRatio * 2, extentRatio),
        _CheckActionValues(s1, actionExtentRatio, extentRatio),
      ];
    case AxisDirection.down:
      return <_CheckActionValues>[
        _CheckActionValues(a0, actionExtentRatio, extentRatio),
        _CheckActionValues(a1, actionExtentRatio * 2, extentRatio),
      ];
    case AxisDirection.up:
      return <_CheckActionValues>[
        _CheckActionValues(s0, actionExtentRatio * 2, extentRatio),
        _CheckActionValues(s1, actionExtentRatio, extentRatio),
      ];
    default:
      return null;
  }
}

List<_CheckActionValues>? getSlidableScrollDelegateHalfValues(
    AxisDirection direction) {
  final double extentRatio = actionExtentRatio;

  switch (direction) {
    case AxisDirection.right:
      return <_CheckActionValues>[
        _CheckActionValues(a0, .0, extentRatio),
        _CheckActionValues(a1, actionExtentRatio, extentRatio),
      ];
    case AxisDirection.left:
      return <_CheckActionValues>[
        _CheckActionValues(s0, actionExtentRatio, extentRatio),
        _CheckActionValues(s1, .0, extentRatio),
      ];
    case AxisDirection.down:
      return <_CheckActionValues>[
        _CheckActionValues(a0, .0, extentRatio),
        _CheckActionValues(a1, actionExtentRatio, extentRatio),
      ];
    case AxisDirection.up:
      return <_CheckActionValues>[
        _CheckActionValues(s0, actionExtentRatio, extentRatio),
        _CheckActionValues(s1, .0, extentRatio),
      ];
    default:
      return null;
  }
}

List<_CheckActionValues>? getSlidableDrawerDelegateHalfValues(
    AxisDirection direction) {
  final double extentRatio = actionExtentRatio;

  switch (direction) {
    case AxisDirection.right:
      return <_CheckActionValues>[
        _CheckActionValues(a0, actionExtentRatio / 2, extentRatio),
        _CheckActionValues(a1, actionExtentRatio, extentRatio),
      ];
    case AxisDirection.left:
      return <_CheckActionValues>[
        _CheckActionValues(s0, actionExtentRatio, extentRatio),
        _CheckActionValues(s1, actionExtentRatio / 2, extentRatio),
      ];
    case AxisDirection.down:
      return <_CheckActionValues>[
        _CheckActionValues(a0, actionExtentRatio / 2, extentRatio),
        _CheckActionValues(a1, actionExtentRatio, extentRatio),
      ];
    case AxisDirection.up:
      return <_CheckActionValues>[
        _CheckActionValues(s0, actionExtentRatio, extentRatio),
        _CheckActionValues(s1, actionExtentRatio / 2, extentRatio),
      ];
    default:
      return null;
  }
}

void testSlidableDelegateScenario(
    Widget actionPane,
    int index,
    double endOffsetFactor,
    SlidableDelegateTestMethod slidableDelegateTestMethod,
    AxisDirection direction) {
  final List<_CheckActionValues>? values = slidableDelegateTestMethod(direction);

  Axis scrollDirection = flipAxis(axisDirectionToAxis(direction));
  testWidgets(
      'Drag shows half of ${actionPane.runtimeType}, scrollDirection=$scrollDirection, '
      'gestureDirection=$direction', (WidgetTester tester) async {
    await tester
        .pumpWidget(buildTest(actionPane, scrollDirection: scrollDirection));

    checkActions(index, hidden: allActions);

    await dragItem(
      tester,
      index,
      gestureDirection: direction,
      endOffsetFactor: endOffsetFactor,
    );

    checkActions(
      index,
      visible: values!.map((v) => v.key).toList(),
      hidden: allActions
          .where((i) => !values.map((v) => v.key).contains(i))
          .toList(),
    );

    values.forEach((v) {
      checkAction(
        index: index,
        key: v.key,
        tester: tester,
        gestureDirection: direction,
        edgeRatio: v.edgeRatio,
        extentRatio: v.extentRatio,
      );
    });

    await flingItem(
      tester,
      index,
      gestureDirection: flipAxisDirection(direction),
      initialOffsetFactor: endOffsetFactor,
    );

    checkActions(index, hidden: allActions);
  });
}

class _CheckActionValues {
  const _CheckActionValues(this.key, this.edgeRatio, this.extentRatio);

  final int key;
  final double extentRatio;
  final double edgeRatio;
}

void main() {
  setUp(() {});

  // Tests all delegates dragging half of total action extents.
  testSlidableDelegate(const SlidableStrechActionPane(),
      getSlidableStrechDelegateHalfValues, actionExtentRatio);
  testSlidableDelegate(const SlidableBehindActionPane(),
      getSlidableBehindDelegateHalfValues, actionExtentRatio);
  testSlidableDelegate(const SlidableScrollActionPane(),
      getSlidableScrollDelegateHalfValues, actionExtentRatio);
  testSlidableDelegate(const SlidableDrawerActionPane(),
      getSlidableDrawerDelegateHalfValues, actionExtentRatio);

  testWidgets('Cannot slide if slidable disabled', (WidgetTester tester) async {
    await tester.pumpWidget(buildTest(const SlidableBehindActionPane()));

    checkActions(3, hidden: allActions);

    await dragItem(tester, 3,
        gestureDirection: AxisDirection.left, endOffsetFactor: 0.2);

    checkActions(3, hidden: allActions);
  });

  testWidgets('Close slidables when scroll', (WidgetTester tester) async {
    await tester.pumpWidget(buildTest(const SlidableBehindActionPane()));

    final int index = 1;
    checkActions(index, hidden: allActions);

    await dragItem(tester, index,
        gestureDirection: AxisDirection.right, endOffsetFactor: 0.2);

    checkActions(index, visible: <int>[a0, a1]);

    await flingItem(
      tester,
      index,
      gestureDirection: AxisDirection.up,
      initialOffsetFactor: 0.2,
    );

    checkActions(index, hidden: allActions);
  });
}
