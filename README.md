# SF Symbols

A Flutter plugin to load and display SF Symbols.

Note that this plugin requires iOS 13.0 or later, and is not available on Android.

For some details on how iOS handles symbols, check out the [Apple Docs](https://developer.apple.com/documentation/uikit/uiimage/configuring_and_displaying_symbol_images_in_your_ui?language=objc).

## Usage

``` dart
// Import package
import 'package:sfsymbols/sfsymbols.dart';

Widget build(BuildContext context) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: SFSymbol('face.smiling', weight: SymbolWeight.bold),
      ),
      //..
    ),
  );
}
```
