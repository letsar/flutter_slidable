# Migration guide

## Migrating to 5.0.0

Starting with Flutter 3.47, the Material widgets have been decoupled from the
Flutter SDK and now live in the [`material_ui`](https://pub.dev/packages/material_ui)
package. Version 5.0.0 of `flutter_slidable` migrates to this package
([#548](https://github.com/letsar/flutter_slidable/issues/548)).

### What changed

* The minimum supported versions are now Flutter 3.47.0 and Dart 3.13.0.
* `flutter_slidable` depends on `material_ui` instead of
  `package:flutter/material.dart`.
* `SlidableAction` and `CustomSlidableAction` now read their theme (text
  style, button theme, visual density, etc.) from the `Theme` provided by
  `material_ui`.

The public API of `flutter_slidable` is unchanged: no constructor, parameter or
type has been renamed or removed.

### Why this is a breaking change

`material_ui` defines its own `Theme` and `ThemeData` classes, distinct from the
ones in `package:flutter/material.dart`. If your app still builds its
`MaterialApp` (or `Theme`) from `package:flutter/material.dart`, the built-in
actions no longer see your theme and fall back to the default Material theme.
There is no error, only a visual difference.

`MaterialUiCompatibilityBridge` does not help here: it only exposes a
`material_ui` theme to widgets that still use `package:flutter/material.dart`,
not the other way around.

### How to migrate

1. Upgrade to Flutter 3.47.0 or later.

2. Migrate your app to `material_ui`. The Flutter team provides a Dart fix that
   adds the dependency and rewrites the imports of
   `package:flutter/material.dart` to `package:material_ui/material_ui.dart`:

   ```sh
   dart fix --apply --code=migrate_design_widgets
   ```

   See the [`material_ui` migration guide](https://pub.dev/packages/material_ui#migrating-existing-code-to-this-package)
   for the details, including localizations.

3. Update `flutter_slidable` in your `pubspec.yaml`:

   ```yaml
   dependencies:
     flutter_slidable: ^5.0.0
   ```

4. Check that your slidable actions still look as expected. If you use
   `CustomSlidableAction` with children that import
   `package:flutter/material.dart`, migrate them as well so that they read the
   same theme.

### If you cannot migrate yet

Keep using the 4.x versions until your app is migrated to `material_ui`:

```yaml
dependencies:
  flutter_slidable: ^4.0.3
```

## Migrating from 0.6.0 to 1.0.0

See [this guide](https://github.com/letsar/flutter_slidable/wiki/Migration-from-version-0.6.0-to-version-1.0.0).
