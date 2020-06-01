## 0.5.5

- Using `context.dependOnInheritedWidgetOfExactType<T>()` instead of deprecated `context.inheritFromWidgetOfExactType(T)`;

## 0.5.4

### Added

- Ripple effect when tapping on the IconSlideAction (https://github.com/letsar/flutter_slidable/pull/89)
- Option to make the widget non-dismissible by dragging (https://github.com/letsar/flutter_slidable/pull/101)

## 0.5.3

### Fixed

- Fix SlidableDrawerActionPane when different than 2 actions (https://github.com/letsar/flutter_slidable/pull/74).

## 0.5.2

### Fixed

- Add check for null value in dismissal field, in getter for \_dismissThreshold (https://github.com/letsar/flutter_slidable/pull/71).

## 0.5.1

### Fixed

- Fix SlidableDrawerActionPane onTap issue (https://github.com/letsar/flutter_slidable/pull/73).

## 0.5.0

### Added

- `iconWidget` parameter for SlideAction which allows full customization of the
  displayed icon.

### Modified

- Change the SlidableDelegate to a widget. The field is renamed `actionPane`.
- Change the SlideToDismissDelegate to a SlidableDismissal widget that takes another widget as a child. The field is renamed `dismissal`.

## 0.4.9

### Fixed

- Fix the end extend of actions in dismiss animation (https://github.com/letsar/flutter_slidable/pull/38).

## 0.4.8

### Added

- onSlideAnimationChanged and onSlideIsOpenChanged on `SlidableController`.

## 0.4.7

### Fixed

- https://github.com/letsar/flutter_slidable/issues/31 (Issue with dismiss animation).

## 0.4.6

### Modified

- Reduce the possibilities for the https://github.com/flutter/flutter/issues/11895 issue to happen.

## 0.4.5

### Added

- The `foregroundColor` parameter on `IconSlideAction` class.

## 0.4.4

### Added

- The `closeOnCanceled` parameter on `SlideToDismissDelegate` classes.

## 0.4.3

### Fixed

- https://github.com/letsar/flutter_slidable/issues/23 (Issue with Drawer delegate when different action count).

## 0.4.2

### Fixed

- https://github.com/letsar/flutter_slidable/issues/22 and https://github.com/letsar/flutter_slidable/issues/24 (Issue with controller).

## 0.4.1

### Added

- The `SlidableController` class.
- The `controller` parameter on `Slidable` constructors to enable keeping only one `Slidable` open.

## 0.4.0

### Added

- The `SlidableRenderingMode` enum.
- The `SlideActionType` enum.
- The `SlideToDismissDelegate` classes.

### Modified

- Added a renderingMode parameter in the `SlideActionBuilder` signature.

## 0.3.2

### Added

- The `enabled` parameter on `Slidable` constructors to enable or disable the slide effect (enabled by default).

## 0.3.1

### Fixed

- https://github.com/letsar/flutter_slidable/issues/11 (slide action not rebuild after controller dismissed).

## 0.3.0

### Added

- The `closeOnTap` parameter on slide actions to close when a action has been tapped.
- The `closeOnScroll` parameter on `Slidable` to close when the nearest `Scrollable` starts to scroll.
- The static `Slidable.of` function.

### Changed

- The `dragExtent` field in `SlidableDelegateContext` has been changed to `dragSign`.

## 0.2.0

### Added

- `Slidable.builder` constructor.
- Vertical sliding.

## Changed

- The slide actions are now hosted in a `SlideActionDelegate` instead of `List<Widget>` inside the `Slidable` widget.
- The `leftActions` have been renamed to `actions`.
- The `rightActions` have been renamed to `secondaryActions`.

## 0.1.0

- Initial Open Source release.
