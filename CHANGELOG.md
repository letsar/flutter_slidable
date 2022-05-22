## 1.3.0
### Added
* Padding and BorderRadius to SlidableAction.

## 1.2.1
### Fixed
* Build warning

## 1.2.0
### Added
* A way to automatically close other Slidables within the same group by tapping on them.
* Add a dragDismissible parameter on ActionPane.
### Fixed
* The RTL issue (#244).

## 1.1.0
### Changed
* Created a totally different notification system in order to be more flexible.
* Deprecated SlidableNotificationListener in favor of SlidableAutoCloseBehavior.

## 1.0.0
Same as 1.0.0-dev.9. This is just for making it clear that it's now stable.

## 1.0.0-dev.9
### Fixed
* Fixes an issue where we click on the Slidable instead of dragging it (https://github.com/letsar/flutter_slidable/pull/235).

## 1.0.0-dev.8
### Fixed
* Fixes an issue where the Dismissible animation stopped in middle when the gesture was too fast.

## 1.0.0-dev.7
### Fixed
* Fixes an issue where the Slidable animation stopped in middle when the gesture was too fast.

## 1.0.0-dev.6
### Fixed
* Fixes an issue preventing the actionPaneType to be updated when it animates (https://github.com/letsar/flutter_slidable/issues/226).

## 1.0.0-dev.5
### Fixed
* Fixes an issue preventing the Slidable to reach the extentRatio manually (https://github.com/letsar/flutter_slidable/issues/225).

## 1.0.0-dev.4
### Added
* ResizeRequest is now available, and the SlidableController.dismiss method can be used from outside.

## 1.0.0-dev.3
### Fixed
* Fixes Dismissal issue with endActionPane (https://github.com/letsar/flutter_slidable/issues/216).

## 1.0.0-dev.2
### Changed
* Flutter Favorite package logo

## 1.0.0-dev.1
### Changed
* Complete package rewriting in order to be more flexible and simple to use.

## 0.6.0
### Added
* Null Safety Support

## 0.5.7
### Fixed
* Formatting issues

## 0.5.6
### Fixed
* Color issue in SlideAction

## 0.5.5
### Fixed
* Static Analysis issues

## 0.5.4
### Added
* Ripple effect when tapping on the IconSlideAction (https://github.com/letsar/flutter_slidable/pull/89)
* Option to make the widget non-dismissible by dragging (https://github.com/letsar/flutter_slidable/pull/101)

## 0.5.3
### Fixed
* Fix SlidableDrawerActionPane when different than 2 actions (https://github.com/letsar/flutter_slidable/pull/74).

## 0.5.2
### Fixed
* Add check for null value in dismissal field, in getter for _dismissThreshold (https://github.com/letsar/flutter_slidable/pull/71).

## 0.5.1
### Fixed
* Fix SlidableDrawerActionPane onTap issue (https://github.com/letsar/flutter_slidable/pull/73).

## 0.5.0
### Added
* `iconWidget` parameter for SlideAction which allows full customization of the
  displayed icon.

### Modified
* Change the SlidableDelegate to a widget. The field is renamed `actionPane`.
* Change the SlideToDismissDelegate to a SlidableDismissal widget that takes another widget as a child. The field is renamed `dismissal`.

## 0.4.9
### Fixed
* Fix the end extend of actions in dismiss animation (https://github.com/letsar/flutter_slidable/pull/38).

## 0.4.8
### Added
* onSlideAnimationChanged and onSlideIsOpenChanged on `SlidableController`.

## 0.4.7
### Fixed
* https://github.com/letsar/flutter_slidable/issues/31 (Issue with dismiss animation).

## 0.4.6
### Modified
* Reduce the possibilities for the https://github.com/flutter/flutter/issues/11895 issue to happen.

## 0.4.5
### Added
* The `foregroundColor` parameter on `IconSlideAction` class.

## 0.4.4
### Added
* The `closeOnCanceled` parameter on `SlideToDismissDelegate` classes.

## 0.4.3
### Fixed
* https://github.com/letsar/flutter_slidable/issues/23 (Issue with Drawer delegate when different action count).

## 0.4.2
### Fixed
* https://github.com/letsar/flutter_slidable/issues/22 and https://github.com/letsar/flutter_slidable/issues/24 (Issue with controller).

## 0.4.1
### Added
* The `SlidableController` class.
* The `controller` parameter on `Slidable` constructors to enable keeping only one `Slidable` open.

## 0.4.0
### Added
* The `SlidableRenderingMode` enum.
* The `SlideActionType` enum.
* The `SlideToDismissDelegate` classes.

### Modified
* Added a renderingMode parameter in the `SlideActionBuilder` signature.

## 0.3.2
### Added
* The `enabled` parameter on `Slidable` constructors to enable or disable the slide effect (enabled by default). 

## 0.3.1
### Fixed
* https://github.com/letsar/flutter_slidable/issues/11 (slide action not rebuild after controller dismissed).

## 0.3.0
### Added
* The `closeOnTap` parameter on slide actions to close when a action has been tapped.
* The `closeOnScroll` parameter on `Slidable` to close when the nearest `Scrollable` starts to scroll.
* The static `Slidable.of` function.

### Changed
* The `dragExtent` field in `SlidableDelegateContext` has been changed to `dragSign`. 

## 0.2.0
### Added
* `Slidable.builder` constructor.
* Vertical sliding.

## Changed
* The slide actions are now hosted in a `SlideActionDelegate` instead of `List<Widget>` inside the `Slidable` widget.
* The `leftActions` have been renamed to `actions`.
* The `rightActions` have been renamed to `secondaryActions`.

## 0.1.0
* Initial Open Source release.