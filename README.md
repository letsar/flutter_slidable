# flutter_slidable

A Flutter implementation of slidable list item with directional slide actions that can be dismissed.

[![Pub](https://img.shields.io/pub/v/flutter_slidable.svg)](https://pub.dartlang.org/packages/flutter_slidable)
[![Donate](https://img.shields.io/badge/Donate-PayPal-green.svg)](https://www.paypal.com/cgi-bin/webscr?cmd=_s-xclick&hosted_button_id=QTT34M25RDNL6)

![Flutter Favorite](https://raw.githubusercontent.com/letsar/flutter_slidable/master/doc/images/flutter_favorite_badge.png)
**Slidable is now a [Flutter Favorite](https://flutter.dev/docs/development/packages-and-plugins/favorites) package!**

![Overview](https://raw.githubusercontent.com/letsar/flutter_slidable/master/doc/images/slidable_overview.gif)

## Features

* Accepts primary (left/top) and secondary (right/bottom) widget lists as slide actions.
* Can be dismissed.
* 4 built-in action panes.
* 2 built-in slide action widgets.
* 1 built-in dismiss animation.
* You can easily create custom layouts and animations.
* You can use a builder to create your slide actions if you want special effects during animation.
* Closes when a slide action has been tapped (overridable).
* Closes when the nearest `Scrollable` starts to scroll (overridable).
* Option to disable the slide effect easily.

## Getting started

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  ...
  flutter_slidable: "^0.5.5"
```

In your library add the following import:

```dart
import 'package:flutter_slidable/flutter_slidable.dart';
```

For help getting started with Flutter, view the online [documentation](https://flutter.io/).

### Constructors

You can create a `Slidable` in two different ways:

* By calling the `Slidable` constructor and passing a list of slide actions.
* By calling the `Slidable.builder` constructor and passing slide action builders, if you want special effects during the animation.

A `Slidable` needs multiple things:

* Slide actions (see below for details). They can be any widget. For convenience, this package has 2 built-in side action widgets.
* A slide action pane widget. This is what controls the layout and the animation of the slide menu.
* An extent ratio between a slide action extent and the item extent.
* A child.

The `actions` contains the slide actions that appear when the child has been dragged down or to the right.
The `secondaryActions` contains the slide actions that appear when the child has been dragged up or to the left.

A `direction` parameter lets you choose if you want actions to appear when you slide horizontally (default) or vertically.

```dart
Slidable(
  actionPane: SlidableDrawerActionPane(),
  actionExtentRatio: 0.25,
  child: Container(
    color: Colors.white,
    child: ListTile(
      leading: CircleAvatar(
        backgroundColor: Colors.indigoAccent,
        child: Text('$3'),
        foregroundColor: Colors.white,
      ),
      title: Text('Tile n°$3'),
      subtitle: Text('SlidableDrawerDelegate'),
    ),
  ),
  actions: <Widget>[
    IconSlideAction(
      caption: 'Archive',
      color: Colors.blue,
      icon: Icons.archive,
      onTap: () => _showSnackBar('Archive'),
    ),
    IconSlideAction(
      caption: 'Share',
      color: Colors.indigo,
      icon: Icons.share,
      onTap: () => _showSnackBar('Share'),
    ),
  ],
  secondaryActions: <Widget>[
    IconSlideAction(
      caption: 'More',
      color: Colors.black45,
      icon: Icons.more_horiz,
      onTap: () => _showSnackBar('More'),
    ),
    IconSlideAction(
      caption: 'Delete',
      color: Colors.red,
      icon: Icons.delete,
      onTap: () => _showSnackBar('Delete'),
    ),
  ],
);
```

### Built-in slide actions

This package comes with 2 kinds of slide actions:

* `SlideAction`, which is the most flexible. You can choose a background color, or any decoration, and it takes any widget as a child.
* `IconSlideAction`, which requires an icon. It can have a background color and a caption below the icon.

### Built-in action panes

This package comes with 4 kinds of action panes:

#### SlidableBehindActionPane

The slide actions stay behind the item while it's sliding:

![Overview](https://raw.githubusercontent.com/letsar/flutter_slidable/master/doc/images/slidable_behind.gif)

#### SlidableScrollActionPane

The slide actions follow the item while it's sliding:

![Overview](https://raw.githubusercontent.com/letsar/flutter_slidable/master/doc/images/slidable_scroll.gif)

#### SlidableDrawerActionPane

The slide actions animate like drawers while the item is sliding:

![Overview](https://raw.githubusercontent.com/letsar/flutter_slidable/master/doc/images/slidable_drawer.gif)

#### SlidableStrechActionPane

The slide actions stretch while the item is sliding:

![Overview](https://raw.githubusercontent.com/letsar/flutter_slidable/master/doc/images/slidable_stretch.gif)

### FAQ

#### How to prevent my slide action to close after it has been tapped?

By default, `SlideAction` and `IconSlideAction` close on tap.
To prevent this, you can pass in `false` to the `closeOnTap` constructor parameter.

#### How to prevent my Slidable to close after my list has scrolled?

By default, a `Slidable` closes when the nearest `Scrollable` widget starts to scroll.
To prevent this, you can pass in `false` to the `closeOnScroll` constructor parameter.

#### How can I dismiss my Slidable?

In order to make your `Slidable` dismissible, you have to set the `dismissal` parameter of the `Slidable` constructor and provide a child.
You can set any widget as a child of `SlidableDismissal`. For the moment there is only one built-in: `SlidableDrawerDismissal`.

The `actionType` passed to the `onDismissed` callback let you know which action has been dismissed.

When a `Slidable` is dismissible, the `key` parameter must not be null.

Example:

``` dart
dismissal: SlidableDismissal(
  child: SlidableDrawerDismissal(),
  onDismissed: (actionType) {
    _showSnackBar(
        context,
        actionType == SlideActionType.primary
            ? 'Dismiss Archive'
            : 'Dimiss Delete');
    setState(() {
      items.removeAt(index);
    });
  },
),
```

#### How can I prevent to dismiss one side but not the other?

If you only want one side to be dismissible, you can set the associated threshold to 1.0 or more.
For example, if you don't want the first primary action to be dismissed, you will set the following thresholds on the `dismissal`:

``` dart
dismissThresholds: <SlideActionType, double>{
  SlideActionType.primary: 1.0
},
```  

#### How to let the user cancel a dismissal?

You can let the user confirm the dismissal by setting the `onWillDismiss` callback on the `dismissal`.

Example:

```dart
dismissal: SlidableDismissal(
  child: SlidableDrawerDismissal(),
  onWillDismiss: (actionType) {
          return showDialog<bool>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text('Delete'),
                content: Text('Item will be deleted'),
                actions: <Widget>[
                  FlatButton(
                    child: Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  FlatButton(
                    child: Text('Ok'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              );
            },
          );
        },
        ...
        ),
```

#### How to let keep only one `Slidable` open?

You have to set the `controller` parameter of the `Slidable` constructors to a `SlidableController` instance:

```dart
final SlidableController slidableController = SlidableController();
...
Slidable(
      key: Key(item.title),
      controller: slidableController,
      ...
      );
```

#### How can I animate an external widget at the same time as the active Slidable?

You have to set the callbacks of a `SlidableController` instance:
The `onSlideAnimationChanged` let you get the animation of the current Slidable.
The `onSlideIsOpenChanged` let you know when the current Slidable opens and closes.

```dart
final SlidableController slidableController = SlidableController(
  onSlideAnimationChanged: handleSlideAnimationChanged,
  onSlideIsOpenChanged: handleSlideIsOpenChanged,
  );
...
  void handleSlideAnimationChanged(Animation<double> slideAnimation) {
    setState(() {
      _rotationAnimation = slideAnimation;
    });
  }

  void handleSlideIsOpenChanged(bool isOpen) {
    setState(() {
      _fabColor = isOpen ? Colors.green : Colors.blue;
    });
  }
```

#### How can I open the Slidable programmatically?

You can open or close the `Slidable` programmatically by calling the `open` or `close` method of the `SlidableState`.
The easiest way get the `SlidableState` from a child is to call `Slidable.of(context)`.

The `open` method has an optional parameter called `actionType` that let you choose which action pane to open.

#### How can I dismiss the Slidable programmatically?

Similar to opening or closing, you can dismiss the `Slidable` programmatically by calling the `dismiss` method of the `SlidableState`.

If you want to use the `dismiss` method without allowing your user to slide to dismiss, you can set the `dragDismissible` parameter of the `SlidableDismissal` constructor to `false`.

## Sponsoring

I'm working on my packages on my free-time, but I don't have as much time as I would. If this package or any other package I created is helping you, please consider to sponsor me. By doing so, I will prioritize your issues or your pull-requests before the others. 

## Changelog

Please see the [Changelog](https://github.com/letsar/flutter_slidable/blob/master/CHANGELOG.md) page to know what's recently changed.

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue](https://github.com/letsar/flutter_slidable/issues).  
If you fixed a bug or implemented a feature, please send a [pull request](https://github.com/letsar/flutter_slidable/pulls).
