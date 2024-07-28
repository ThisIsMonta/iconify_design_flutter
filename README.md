<!--
This README describes the package. If you publish this package to pub.dev,
this README's contents appear on the landing page for your package.

For information about how to write a good package README, see the guide for
[writing package pages](https://dart.dev/guides/libraries/writing-package-pages).

For general information about developing packages, see the Dart guide for
[creating packages](https://dart.dev/guides/libraries/create-library-packages)
and the Flutter guide for
[developing packages and plugins](https://flutter.dev/developing-packages).
-->

# Iconify Design

A Flutter package that allows you to use icons from the [Iconify.design](https://iconify.design/) API with ease. This package provides a widget called IconifyIcon that takes an icon string and optionally allows you to specify the size and color of the icon.

### Installation
Add the following to your `pubspec.yaml` file:

```yaml
dependencies:
  iconify_design: ^1.0.0
```
Then run:
```sh
flutter pub get
```
### Usage

```dart
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:flutter/material.dart';
```
### Example
Here is an example of how to use the `IconifyIcon` widget:

```dart
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Iconify Flutter Example'),
        ),
        body: Center(
          child: IconifyIcon(
            icon: 'mdi:home',
            size: 48.0,
            color: Colors.blue,
          ),
        ),
      ),
    );
  }
}
```

### Parameters
The `IconifyIcon` widget has the following parameters:
1. **icon**: The icon string (e.g., **'mdi:home'**, **'iconoir:fill-color-solid'**, etc.).
2. **size (optional)**: The size of the icon. Default is 24.0.
3. **color (optional)**: The color of the icon. Default is **Black**.

### Contribution

Feel free to open issues or submit pull requests to help improve this package.

### License

This project is licensed under the MIT License - see the [LICENSE](https://github.com/ThisIsMonta/iconify_design_flutter/blob/main/LICENSE) file for details.

### Support

Don't forget to support (if you can).

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://buymeacoffee.com/monta.sghaier)

### Maintainers

* [Montassar sghaier](https://github.com/ThisIsMonta)