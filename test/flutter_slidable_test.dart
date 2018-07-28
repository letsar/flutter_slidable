import 'package:flutter_test/flutter_test.dart';
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
        key: new ValueKey(getSlideActionBaseKey(index) + a0),
        child: const Text('a0'),
      ),
      SlideAction(
        key: new ValueKey(getSlideActionBaseKey(index) + a1),
        child: const Text('a1'),
      ),
    ],
  );
}

SlideActionDelegate _buildSecondaryActionDelegate(int index) {
  return SlideActionListDelegate(
    actions: <Widget>[
      SlideAction(
        key: new ValueKey(getSlideActionBaseKey(index) + s0),
        child: const Text('s0'),
      ),
      SlideAction(
        key: new ValueKey(getSlideActionBaseKey(index) + s1),
        child: const Text('s1'),
      ),
    ],
  );
}

Widget buildTest(
  SlidableDelegate delegate, {
  TextDirection textDirection = TextDirection.ltr,
  Axis scrollDirection = Axis.vertical,
}) {
  return new Directionality(
    textDirection: textDirection,
    child: new StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) {
        Widget buildSlidableWidget(int item) {
          return new Slidable.builder(
            key: new ValueKey(item),
            delegate: delegate,
            direction: flipAxis(scrollDirection),
            actionExtentRatio: actionExtentRatio,
            actionDelegate: _buildActionDelegate(item),
            secondaryActionDelegate: _buildSecondaryActionDelegate(item),
            child: new Container(
              width: scrollDirection == Axis.horizontal
                  ? itemExtent
                  : screenSize.width,
              height: scrollDirection == Axis.horizontal
                  ? screenSize.height
                  : itemExtent,
              child: new Text(item.toString()),
            ),
          );
        }

        return new ListView(
          scrollDirection: scrollDirection,
          itemExtent: itemExtent,
          children: List
              .generate(5, (int index) => buildSlidableWidget(index))
              .toList(),
        );
      },
    ),
  );
}

Offset getOffset(AxisDirection gestureDirection, double value) {
  switch (gestureDirection) {
    case AxisDirection.left:
      return new Offset(-value, 0.0);
    case AxisDirection.right:
      return new Offset(value, 0.0);
    case AxisDirection.up:
      return new Offset(0.0, -value);
    case AxisDirection.down:
      return new Offset(0.0, value);
    default:
      fail('unsupported gestureDirection');
  }
}

Future<Null> flingElement(
  WidgetTester tester,
  Finder finder, {
  @required AxisDirection gestureDirection,
  double initialOffsetFactor = 0.0,
}) async {
  final Offset delta = getOffset(gestureDirection, -300.0);
  await tester.fling(finder, delta, 1000.0,
      initialOffset: delta * initialOffsetFactor);
}

Future<Null> dragElement(
  WidgetTester tester,
  Finder finder, {
  @required AxisDirection gestureDirection,
  double endOffsetFactor,
}) async {
  final Offset delta =
      getOffset(gestureDirection, endOffsetFactor * itemExtent);
  await tester.drag(finder, delta);
}

Future<Null> dragItem(
  WidgetTester tester,
  int item, {
  @required AxisDirection gestureDirection,
  double endOffsetFactor,
}) async {
  await dragElement(
    tester,
    find.widgetWithText(Container, item.toString()),
    gestureDirection: gestureDirection,
    endOffsetFactor: endOffsetFactor,
  );
  await tester.pump(); // start the slide.
}

Future<Null> flingElementFromZero(WidgetTester tester, Finder finder,
    {@required AxisDirection gestureDirection}) async {
  // This is a special case where we drag in one direction, then fling back so
  // that at the point of release, we're at exactly the point at which we
  // started, but with velocity. This is needed to check a boundary condition
  // in the flinging behavior.
  await flingElement(tester, finder,
      gestureDirection: gestureDirection, initialOffsetFactor: -1.0);
}

int getSlideActionBaseKey(int index) {
  return (index + 1) * 100;
}

void checkActions(int index,
    {List<int> visible = const <int>[], List<int> hidden = const <int>[]}) {
  for (int key in visible) {
    expect(find.byKey(new ValueKey(getSlideActionBaseKey(index) + key)),
        findsOneWidget);
  }
  for (int key in hidden) {
    expect(find.byKey(new ValueKey(getSlideActionBaseKey(index) + key)),
        findsNothing);
  }
}

void checkAction(
    {@required int index,
    @required int key,
    @required WidgetTester tester,
    @required AxisDirection gestureDirection,
    @required double edge,
    @required double extent}) {
  Finder finder = find.byKey(new ValueKey(getSlideActionBaseKey(index) + key));
  double actualEdge;
  double actualExtent;
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
  expect(actualEdge.roundToDouble(), edge.roundToDouble());
  expect(actualExtent.roundToDouble(), extent.roundToDouble());
}

typedef List<_CheckActionValues> SlidableDelegateTestMethod(
    AxisDirection direction);

void testSlidableDelegate(
    SlidableDelegate delegate,
    SlidableDelegateTestMethod slidableDelegateTestMethod,
    double endOffsetFactor) {
  final int index = 0;

  axisDirections.forEach((direction) {
    testSlidableDelegateScenario(
      delegate,
      index,
      endOffsetFactor,
      slidableDelegateTestMethod,
      direction,
    );
  });
}

List<_CheckActionValues> getSlidableStrechDelegateHalfValues(
    AxisDirection direction) {
  final double extent = 10.0;

  switch (direction) {
    case AxisDirection.right:
      return <_CheckActionValues>[
        new _CheckActionValues(a0, 10.0, extent),
        new _CheckActionValues(a1, 20.0, extent),
      ];
    case AxisDirection.left:
      return <_CheckActionValues>[
        new _CheckActionValues(s0, 20.0, extent),
        new _CheckActionValues(s1, 10.0, extent),
      ];
    case AxisDirection.down:
      return <_CheckActionValues>[
        new _CheckActionValues(a0, 10.0, extent),
        new _CheckActionValues(a1, 20.0, extent),
      ];
    case AxisDirection.up:
      return <_CheckActionValues>[
        new _CheckActionValues(s0, 20.0, extent),
        new _CheckActionValues(s1, 10.0, extent),
      ];
    default:
      return null;
  }
}

void testSlidableDelegateScenario(
    SlidableDelegate delegate,
    int index,
    double endOffsetFactor,
    SlidableDelegateTestMethod slidableDelegateTestMethod,
    AxisDirection direction) {
  final List<_CheckActionValues> values = slidableDelegateTestMethod(direction);

  Axis scrollDirection = flipAxis(axisDirectionToAxis(direction));
  testWidgets(
      'Drag shows half of ${delegate.runtimeType}, scrollDirection=$scrollDirection, '
      'gestureDirection=$direction', (WidgetTester tester) async {
    await tester.pumpWidget(buildTest(const SlidableStrechDelegate(),
        scrollDirection: scrollDirection));

    checkActions(index, hidden: allActions);

    await dragItem(tester, index,
        gestureDirection: direction, endOffsetFactor: endOffsetFactor);
    checkActions(
      index,
      visible: values.map((v) => v.key).toList(),
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
        edge: v.edge,
        extent: v.extent,
      );
    });
  });
}

class _CheckActionValues {
  const _CheckActionValues(this.key, this.edge, this.extent);

  final int key;
  final double extent;
  final double edge;
}

void main() {
  setUp(() {});

  testSlidableDelegate(const SlidableStrechDelegate(),
      getSlidableStrechDelegateHalfValues, actionExtentRatio);
}
