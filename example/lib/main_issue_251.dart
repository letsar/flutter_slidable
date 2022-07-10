// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
//
// void main() => runApp(const MyApp());
//
// class MyApp extends StatelessWidget {
//   const MyApp({
//     Key? key,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Slidable Example',
//       home: Scaffold(
//         body: ListView(
//           children: const [
//             ListItem(
//               title: 'ERIC',
//               subtitle: 'Subtitle 1',
//             ),
//             ListItem(
//               title: 'ERIC',
//               subtitle: 'Subtitle 2',
//             ),
//             ListItem(
//               title: 'ERIC',
//               subtitle: 'Subtitle 3',
//             ),
//             ListItem(
//               title: 'ERIC',
//               subtitle: 'Subtitle 4',
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class ListItem extends StatefulWidget {
//   const ListItem({
//     Key? key,
//     required this.title,
//     required this.subtitle,
//   }) : super(key: key);
//
//   final String title;
//   final String subtitle;
//
//   @override
//   State<ListItem> createState() => _ListItemState();
// }
//
// class _ListItemState extends State<ListItem> {
//   final colorNotifier = ValueNotifier<Color>(Colors.grey);
//
//   @override
//   void initState() {
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 50,
//       child: Slidable(
//         startActionPane: ActionPane(
//           closeThreshold: 0.5,
//           openThreshold: 0.6,
//           extentRatio: 0.5,
//           motion: const BehindMotion(),
//           children: [RememberedArea(colorNotifier: colorNotifier)],
//         ),
//         child: Row(
//           children: [
//             Hint(colorNotifier: colorNotifier),
//             Expanded(
//               child: Item(
//                 title: widget.title,
//                 subtitle: widget.subtitle,
//               ),
//             )
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// class RememberedArea extends StatefulWidget {
//   RememberedArea({
//     Key? key,
//     required this.colorNotifier,
//     ColorTween? colorTween,
//   })  : colorTween = colorTween ??
//             ColorTween(
//               begin: Colors.yellow,
//               end: Colors.green,
//             ),
//         super(key: key);
//
//   final ColorTween colorTween;
//   final ValueNotifier<Color> colorNotifier;
//
//   @override
//   State<RememberedArea> createState() => _RememberedAreaState();
// }
//
// class _RememberedAreaState extends State<RememberedArea> {
//   double maxValue = 0;
//   late final animation = Slidable.of(context)!.animation;
//
//   @override
//   void initState() {
//     super.initState();
//     animation.addListener(handleValueChanged);
//     animation.addStatusListener(handleStatusChanged);
//   }
//
//   double get colorValue => animation.value * 2;
//   Color get color => widget.colorTween.lerp(colorValue)!;
//
//   void handleValueChanged() {
//     if (colorValue > maxValue) {
//       maxValue = colorValue;
//       widget.colorNotifier.value = color;
//     }
//   }
//
//   void handleStatusChanged(AnimationStatus status) {
//     if (status == AnimationStatus.dismissed) {
//       maxValue = 0;
//     }
//   }
//
//   @override
//   void dispose() {
//     animation.removeListener(handleValueChanged);
//     animation.removeStatusListener(handleStatusChanged);
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: animation,
//       builder: (context, child) {
//         return Expanded(
//           child: SizedBox.expand(
//             child: ColoredBox(color: color),
//           ),
//         );
//       },
//     );
//   }
// }
//
// class Hint extends StatelessWidget {
//   const Hint({
//     Key? key,
//     required this.colorNotifier,
//   }) : super(key: key);
//
//   final ValueNotifier<Color> colorNotifier;
//
//   @override
//   Widget build(BuildContext context) {
//     return ValueListenableBuilder<Color>(
//       valueListenable: colorNotifier,
//       builder: (context, color, child) {
//         return Container(width: 8, color: color);
//       },
//     );
//   }
// }
//
// class Item extends StatelessWidget {
//   const Item({
//     Key? key,
//     required this.title,
//     required this.subtitle,
//   }) : super(key: key);
//
//   final String title;
//   final String subtitle;
//
//   @override
//   Widget build(BuildContext context) {
//     final textTheme = Theme.of(context).textTheme;
//     return Padding(
//       padding: const EdgeInsets.only(left: 8),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(child: Text(title, style: textTheme.bodyText1)),
//           Expanded(child: Text(subtitle, style: textTheme.bodyText2)),
//         ],
//       ),
//     );
//   }
// }
