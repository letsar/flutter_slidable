// import 'package:meta/meta.dart';

// @immutable
// class SlidingDetails {
//   const SlidingDetails({
//     this.active,
//     this.velocity,
//   });

//   final bool active;
//   final double velocity;

//   SlidingDetails copyWith({
//     bool active,
//     bool shouldOpen,
//     double velocity,
//   }) {
//     return SlidingDetails(
//       active: active ?? this.active,
//       velocity: velocity ?? this.velocity,
//     );
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) {
//       return true;
//     }

//     return other is SlidingDetails &&
//         other.active == active &&
//         other.velocity == velocity;
//   }

//   @override
//   int get hashCode => active.hashCode ^ shouldOpen.hashCode ^ velocity.hashCode;

//   @override
//   String toString() =>
//       'SlidingDetails(active: $active, shouldOpen: $shouldOpen, velocity: $velocity)';
// }
