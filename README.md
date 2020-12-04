<!-- [![Build][github_action_badge]][github_action] -->
[![Pub][pub_badge]][pub]
<!-- [![Codecov][codecov_badge]][codecov] -->
[![BuyMeACoffee][buy_me_a_coffee_badge]][buy_me_a_coffee]


![Flutter Favorite][flutter_favorite_badge]
**Slidable is a [Flutter Favorite][flutter_favorite] package!**

# flutter_slidable

A Flutter implementation of slidable list item with directional slide actions that can be dismissed.

## Migration from 0.5.7
TODO

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


## Motions

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

<!-- Links -->
[github_action_badge]: https://github.com/letsar/flutter_slidable/workflows/Build/badge.svg
[github_action]: https://github.com/letsar/flutter_slidable/actions
[pub_badge]: https://img.shields.io/pub/v/flutter_slidable.svg
[pub]: https://pub.dartlang.org/packages/flutter_slidable
[codecov]: https://codecov.io/gh/letsar/flutter_slidable
[codecov_badge]: https://codecov.io/gh/letsar/flutter_slidable/branch/main/graph/badge.svg
[buy_me_a_coffee]: https://www.buymeacoffee.com/romainrastel
[buy_me_a_coffee_badge]: https://img.buymeacoffee.com/button-api/?text=Donate&emoji=&slug=romainrastel&button_colour=29b6f6&font_colour=000000&font_family=Cookie&outline_colour=000000&coffee_colour=FFDD00
[flutter_favorite_badge]: https://raw.githubusercontent.com/letsar/flutter_slidable/master/doc/images/flutter_favorite_badge.png
[flutter_favorite]: https://flutter.dev/docs/development/packages-and-plugins/favorites

[behind_motion]: packages/images/behind_motion.gif
[drawer_motion]: packages/images/drawer_motion.gif
[scroll_motion]: packages/images/scroll_motion.gif
[stretch_motion]: packages/images/stretch_motion.gif