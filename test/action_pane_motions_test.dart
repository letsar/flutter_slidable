// // ignore_fo_file: avoid_redundant_argument_values
//
// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/src/action_pane_motions.dart';
// import 'package:flutter_slidable/src/slidable.dart';
// import 'package:flutter_test/flutter_test.dart';
//
// // ignore_for_file: avoid_redundant_argument_values
//
// void main() {
//   group('BehindMotion', () {
//     testMotionForAllModes(
//       motion: const BehindMotion(),
//       startCenters: [12.5, 62.5],
//       endCenters: [112.5, 162.5],
//     );
//   });
//
//   group('ScrollMotion', () {
//     testMotionForAllModes(
//       motion: const ScrollMotion(),
//       startCenters: [-37.5, 12.5],
//       endCenters: [162.5, 212.5],
//     );
//   });
//
//   group('StretchMotion', () {
//     testMotionForAllModes(
//       motion: const StretchMotion(),
//       startCenters: [6.25, 31.25],
//       endCenters: [156.25, 181.25],
//     );
//   });
//
//   group('DrawerMotion', () {
//     testMotionForAllModes(
//       motion: const DrawerMotion(),
//       startCenters: [0, 12.5],
//       endCenters: [162.5, 200],
//     );
//   });
// }
//
// void testMotionForAllModes({
//   required Widget motion,
//   required List<double> startCenters,
//   required List<double> endCenters,
// }) {
//   const directions = Axis.values;
//   final isStartValues = [true, false];
//   for (final direction in directions) {
//     for (final isStart in isStartValues) {
//       final pane = isStart ? 'start' : 'end';
//       final centers = isStart ? startCenters : endCenters;
//       testWidgets('control check in $direction for ${pane}ActionPane',
//           (tester) async {
//         await testMotion(
//           tester: tester,
//           motion: motion,
//           isStart: isStart,
//           direction: direction,
//           centers: centers,
//         );
//       });
//     }
//   }
// }
//
// Future<void> testMotion({
//   required WidgetTester tester,
//   required Widget motion,
//   required bool isStart,
//   required Axis direction,
//   required List<double> centers,
// }) async {
//   const key1 = ValueKey(1);
//   const key2 = ValueKey(2);
//
//   final findKey1 = find.byKey(key1);
//   final findKey2 = find.byKey(key2);
//   final findSlidable = find.byType(Slidable);
//   final isHorizontal = direction == Axis.horizontal;
//
//   double getCenter(Finder finder) {
//     if (isHorizontal) {
//       return tester.getCenter(finder).dx;
//     } else {
//       return tester.getCenter(finder).dy;
//     }
//   }
//
//   final pane = ActionPane(
//     motion: motion,
//     children: const [
//       Expanded(flex: 1, child: SizedBox.expand(key: key1)),
//       Expanded(flex: 3, child: SizedBox.expand(key: key2)),
//     ],
//   );
//
//   final startActionPane = isStart ? pane : null;
//   final endActionPane = isStart ? null : pane;
//
//   const double extent = 200;
//   final double height = isHorizontal ? 100 : extent;
//   final double width = isHorizontal ? extent : 100;
//   Offset drag = Offset(isStart ? 50 : -50, 0);
//   if (!isHorizontal) {
//     drag = Offset(0, isStart ? 50 : -50);
//   }
//
//   await tester.pumpWidget(
//     Align(
//       alignment: Alignment.topLeft,
//       child: SizedBox(
//         height: height,
//         width: width,
//         child: Directionality(
//           textDirection: TextDirection.ltr,
//           child: Slidable(
//             direction: direction,
//             startActionPane: startActionPane,
//             endActionPane: endActionPane,
//             child: const SizedBox.expand(),
//           ),
//         ),
//       ),
//     ),
//   );
//
//   await tester.dragAndHold(findSlidable, drag);
//
//   double centerKey1 = centers[0];
//   double centerKey2 = centers[1];
//
//   expect(getCenter(findKey1), moreOrLessEquals(centerKey1));
//   expect(getCenter(findKey2), moreOrLessEquals(centerKey2));
//
//   await tester.dragAndHold(findSlidable, drag);
//
//   centerKey1 = 12.5;
//   centerKey2 = 62.5;
//
//   if (!isStart) {
//     centerKey1 = extent / 2 + centerKey1;
//     centerKey2 = extent / 2 + centerKey2;
//   }
//
//   expect(getCenter(findKey1), moreOrLessEquals(centerKey1));
//   expect(getCenter(findKey2), moreOrLessEquals(centerKey2));
// }
//
// extension on WidgetTester {
//   Future<void> dragAndHold(Finder finder, Offset offset) async {
//     final gesture = await startGesture(getCenter(finder));
//     await gesture.moveBy(offset);
//     await pump();
//   }
// }
