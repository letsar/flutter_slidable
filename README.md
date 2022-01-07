<!-- [![Build][github_action_badge]][github_action] -->
[![Pub][pub_badge]][pub] [![BuyMeACoffee][buy_me_a_coffee_badge]][buy_me_a_coffee]

[<img src="https://raw.githubusercontent.com/letsar/flutter_slidable/assets/flutter_favorite.png" width="100" />][flutter_favorite] **Slidable is a [Flutter Favorite][flutter_favorite] package!**


# flutter_slidable

A Flutter implementation of slidable list item with directional slide actions that can be dismissed.

## Sponsors

Our top sponsors are shown below! [[Become a Sponsor](https://github.com/sponsors/letsar)]

<table>    
    <tbody>
        <tr>
            <td align="center">
                <a href="https://getstream.io/chat/flutter/tutorial/?utm_source=https://github.com/letsar/flutter_slidable&utm_medium=github&utm_content=developer&utm_term=flutter" target="_blank"><img width="250px" src="https://stream-blog.s3.amazonaws.com/blog/wp-content/uploads/fc148f0fc75d02841d017bb36e14e388/Stream-logo-with-background-.png"/></a><br/><span><a href="https://getstream.io/chat/flutter/tutorial/?utm_source=PubDev&utm_medium=Github_Repo_Content_Ad&utm_content=Developer&utm_campaign=PubDev_Jan2022_FlutterChat&utm_term=slidable" target="_blank">Try the Flutter Chat Tutorial &nbsp💬</a></span>
            </td>            
        </tr>
    </tbody>
</table>

## Migration from 0.6.0

You can read this small guide to migrate from the 0.6 to the 1.0 version: https://github.com/letsar/flutter_slidable/wiki/Migration-from-version-0.6.0-to-version-1.0.0

## Features

* Accepts start (left/top) and end (right/bottom) action panes.
* Can be dismissed.
* 4 built-in action panes.
* 2 built-in slide action widgets.
* 1 built-in dismiss animation.
* You can easily create custom layouts and animations.
* You can use a builder to create your slide actions if you want special effects during animation.
* Closes when a slide action has been tapped (overridable).
* Closes when the nearest `Scrollable` starts to scroll (overridable).
* Option to disable the slide effect easily.

## Install

In the `pubspec.yaml` of your flutter project, add the following dependency:

```yaml
dependencies:
  flutter_slidable: <latest_version>
```

In your library add the following import:

```dart
import 'package:flutter_slidable/flutter_slidable.dart';
```

## Getting started

Example:

```dart
Slidable(
  // Specify a key if the Slidable is dismissible.
  key: const ValueKey(0),

  // The start action pane is the one at the left or the top side.
  startActionPane: ActionPane(
    // A motion is a widget used to control how the pane animates.
    motion: const ScrollMotion(),

    // A pane can dismiss the Slidable.
    dismissible: DismissiblePane(onDismissed: () {}),

    // All actions are defined in the children parameter.
    children: const [
      // A SlidableAction can have an icon and/or a label.
      SlidableAction(
        onPressed: doNothing,
        backgroundColor: Color(0xFFFE4A49),
        foregroundColor: Colors.white,
        icon: Icons.delete,
        label: 'Delete',
      ),
      SlidableAction(
        onPressed: doNothing,
        backgroundColor: Color(0xFF21B7CA),
        foregroundColor: Colors.white,
        icon: Icons.share,
        label: 'Share',
      ),
    ],
  ),

  // The end action pane is the one at the right or the bottom side.
  endActionPane: const ActionPane(
    motion: ScrollMotion(),
    children: [
      SlidableAction(
        // An action can be bigger than the others.
        flex: 2,
        onPressed: doNothing,
        backgroundColor: Color(0xFF7BC043),
        foregroundColor: Colors.white,
        icon: Icons.archive,
        label: 'Archive',
      ),
      SlidableAction(
        onPressed: doNothing,
        backgroundColor: Color(0xFF0392CF),
        foregroundColor: Colors.white,
        icon: Icons.save,
        label: 'Save',
      ),
    ],
  ),

  // The child of the Slidable is what the user sees when the
  // component is not dragged.
  child: const ListTile(title: Text('Slide me')),
),
```

## Motions

Any `ActionPane` has a motion parameter which allow you to define how the pane animates when the user drag the `Slidable`.

### Behind Motion

The actions appear as if they where behind the `Slidable`:

![Behind Motion][behind_motion]

### Drawer Motion

Animate the actions as if they were drawers, when the `Slidable` is moving:

![Drawer Motion][drawer_motion]

### Scroll Motion

The actions follow the `Slidable` while it's moving:

![Scroll Motion][scroll_motion]

### Stretch Motion

Animate the actions as if they were streched while the `Slidable` is moving:

![Stretch Motion][stretch_motion]

## FAQ

You can read the FAQ here: https://github.com/letsar/flutter_slidable/wiki/FAQ

## Sponsoring

I'm working on my packages on my free-time, but I don't have as much time as I would. If this package or any other package I created is helping you, please consider to sponsor me so that I can take time to read the issues, fix bugs, merge pull requests and add features to these packages.

## Contributions

Feel free to contribute to this project.

If you find a bug or want a feature, but don't know how to fix/implement it, please fill an [issue][issue].  
If you fixed a bug or implemented a feature, please send a [pull request][pr].

<!-- Links -->
[github_action_badge]: https://github.com/letsar/flutter_slidable/workflows/Build/badge.svg
[github_action]: https://github.com/letsar/flutter_slidable/actions
[pub_badge]: https://img.shields.io/pub/v/flutter_slidable.svg
[pub]: https://pub.dartlang.org/packages/flutter_slidable
[codecov]: https://codecov.io/gh/letsar/flutter_slidable
[codecov_badge]: https://codecov.io/gh/letsar/flutter_slidable/branch/main/graph/badge.svg
[buy_me_a_coffee]: https://www.buymeacoffee.com/romainrastel
[buy_me_a_coffee_badge]: https://img.buymeacoffee.com/button-api/?text=Donate&emoji=&slug=romainrastel&button_colour=29b6f6&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00
[flutter_favorite_badge]: https://raw.githubusercontent.com/letsar/flutter_slidable/assets/flutter_favorite.png
[flutter_favorite]: https://flutter.dev/docs/development/packages-and-plugins/favorites
[behind_motion]: https://raw.githubusercontent.com/letsar/flutter_slidable/assets/behind_motion.gif
[drawer_motion]: https://raw.githubusercontent.com/letsar/flutter_slidable/assets/drawer_motion.gif
[scroll_motion]: https://raw.githubusercontent.com/letsar/flutter_slidable/assets/scroll_motion.gif
[stretch_motion]: https://raw.githubusercontent.com/letsar/flutter_slidable/assets/stretch_motion.gif
[issue]: https://github.com/letsar/flutter_slidable/issues
[pr]: https://github.com/letsar/flutter_slidable/pulls
