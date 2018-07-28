import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

const double itemExtent = 100.0;
const double actionExtentRatio = 0.1;
SlideActionDelegate actionDelegate = SlideActionListDelegate(
  actions: <Widget>[
    SlideAction(
      child: const Text('a0'),
    ),
    SlideAction(
      child: const Text('a1'),
    ),
  ],
);
SlideActionDelegate secondaryActionDelegate = SlideActionListDelegate(
  actions: <Widget>[
    SlideAction(
      child: const Text('s0'),
    ),
    SlideAction(
      child: const Text('s1'),
    ),
  ],
);

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
            actionDelegate: actionDelegate,
            secondaryActionDelegate: secondaryActionDelegate,
            child: new Container(
              width: itemExtent,
              height: itemExtent,
              child: new Text(item.toString()),
            ),
          );
        }

        return new Container(
          padding: const EdgeInsets.all(10.0),
          child: new ListView(
            scrollDirection: scrollDirection,
            itemExtent: itemExtent,
            children: List
                .generate(5, (int index) => buildSlidableWidget(index))
                .toList(),
          ),
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
  int item, {
  @required AxisDirection gestureDirection,
  double endOffsetFactor = 0.5,
}) async {
  final Offset delta =
      getOffset(gestureDirection, endOffsetFactor * itemExtent);
  await tester.drag(find.text(item.toString()), delta);
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

void main() {
  setUp(() {});

  testWidgets(
      'Horizontal drag shows half of SlidableStrechDelegate, scrollDirection=vertical',
      (WidgetTester tester) async {
    await tester.pumpWidget(buildTest(const SlidableStrechDelegate(),
        scrollDirection: Axis.vertical));

    expect(find.text('a0'), findsNothing);
    expect(find.text('a1'), findsNothing);
    expect(find.text('s0'), findsNothing);
    expect(find.text('s1'), findsNothing);

    await dragElement(tester, 0, gestureDirection: AxisDirection.right);
    expect(find.text('a0'), findsOneWidget);
    expect(find.text('a1'), findsOneWidget);
    expect(find.text('s0'), findsNothing);
    expect(find.text('s1'), findsNothing);
  });
}
