import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

const double itemExtent = 100.0;
const double actionExtentRatio = 0.2;
const Size screenSize = const Size(800.0, 600.0);

SlideActionDelegate _buildActionDelegate(int index) {
  return SlideActionListDelegate(
    actions: <Widget>[
      SlideAction(
        key: new ValueKey((index + 1) * 100 + 0),
        child: const Text('a0'),
      ),
      SlideAction(
        key: new ValueKey((index + 1) * 100 + 1),
        child: const Text('a1'),
      ),
    ],
  );
}

SlideActionDelegate _buildSecondaryActionDelegate(int index) {
  return SlideActionListDelegate(
    actions: <Widget>[
      SlideAction(
        key: new ValueKey((index + 1) * 100 + 10),
        child: const Text('s0'),
      ),
      SlideAction(
        key: new ValueKey((index + 1) * 100 + 11),
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
            actionExtentRatio: actionExtentRatio,
            actionDelegate: _buildActionDelegate(item),
            secondaryActionDelegate: _buildSecondaryActionDelegate(item),
            child: new Container(
              width: itemExtent,
              height: itemExtent,
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
    find.text(item.toString()),
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

void checkActions(
    {List<int> visible = const <int>[], List<int> hidden = const <int>[]}) {
  for (int key in visible) {
    expect(find.byKey(new ValueKey(key)), findsOneWidget);
  }
  for (int key in hidden) {
    expect(find.byKey(new ValueKey(key)), findsNothing);
  }
}

void checkAction(
    {@required int key,
    @required WidgetTester tester,
    @required AxisDirection gestureDirection,
    @required double edge,
    @required double extent}) {
  Finder finder = find.byKey(new ValueKey(key));
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

void main() {
  setUp(() {});

  testWidgets(
      'Horizontal drag shows half of SlidableStrechDelegate, '
      'scrollDirection=vertical, gestureDirection=right',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTest(const SlidableStrechDelegate(),
        scrollDirection: Axis.vertical));

    final int index = 0;
    final int a0 = (index + 1) * 100 + 0;
    final int a1 = (index + 1) * 100 + 1;
    final int s0 = (index + 1) * 100 + 10;
    final int s1 = (index + 1) * 100 + 11;

    checkActions(hidden: <int>[a0, a1, s0, s1]);

    final AxisDirection gestureDirection = AxisDirection.right;
    await dragItem(tester, index,
        gestureDirection: gestureDirection, endOffsetFactor: 0.2);
    checkActions(visible: <int>[a0, a1], hidden: <int>[s0, s1]);

    checkAction(
        key: a0,
        tester: tester,
        gestureDirection: gestureDirection,
        edge: 10.0,
        extent: 10.0);

    checkAction(
        key: a1,
        tester: tester,
        gestureDirection: gestureDirection,
        edge: 20.0,
        extent: 10.0);
  });

  testWidgets(
      'Horizontal drag shows half of SlidableStrechDelegate, '
      'scrollDirection=vertical, gestureDirection=left',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTest(const SlidableStrechDelegate(),
        scrollDirection: Axis.vertical));

    final int index = 0;
    final int a0 = (index + 1) * 100 + 0;
    final int a1 = (index + 1) * 100 + 1;
    final int s0 = (index + 1) * 100 + 10;
    final int s1 = (index + 1) * 100 + 11;

    checkActions(hidden: <int>[a0, a1, s0, s1]);

    final AxisDirection gestureDirection = AxisDirection.left;
    await dragItem(tester, index,
        gestureDirection: gestureDirection, endOffsetFactor: 0.2);
    checkActions(hidden: <int>[a0, a1], visible: <int>[s0, s1]);

    checkAction(
        key: s0,
        tester: tester,
        gestureDirection: gestureDirection,
        edge: 20.0,
        extent: 10.0);

    checkAction(
        key: s1,
        tester: tester,
        gestureDirection: gestureDirection,
        edge: 10.0,
        extent: 10.0);
  });

  testWidgets(
      'Horizontal drag shows half of SlidableStrechDelegate, '
          'scrollDirection=horizontal, gestureDirection=up',
          (WidgetTester tester) async {
        await tester.pumpWidget(buildTest(const SlidableStrechDelegate(),
            scrollDirection: Axis.horizontal));

        final int index = 0;
        final int a0 = (index + 1) * 100 + 0;
        final int a1 = (index + 1) * 100 + 1;
        final int s0 = (index + 1) * 100 + 10;
        final int s1 = (index + 1) * 100 + 11;

        checkActions(hidden: <int>[a0, a1, s0, s1]);

        final AxisDirection gestureDirection = AxisDirection.up;
        await dragItem(tester, index,
            gestureDirection: gestureDirection, endOffsetFactor: 0.2);
        checkActions(visible: <int>[a0, a1], hidden: <int>[s0, s1]);

        checkAction(
            key: a0,
            tester: tester,
            gestureDirection: gestureDirection,
            edge: 10.0,
            extent: 10.0);

        checkAction(
            key: a1,
            tester: tester,
            gestureDirection: gestureDirection,
            edge: 20.0,
            extent: 10.0);
      });
}
