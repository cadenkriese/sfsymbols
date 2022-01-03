import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart'
    show SynchronousFuture, describeIdentity;

class _FutureImageStreamCompleter extends ImageStreamCompleter {
  _FutureImageStreamCompleter({
    required Future<ui.Codec> codec,
    required this.futureScale,
    this.informationCollector,
  }) {
    codec.then<void>(_onCodecReady, onError: (dynamic error, StackTrace stack) {
      reportError(
        context: ErrorDescription('resolving a single-frame image stream'),
        exception: error,
        stack: stack,
        informationCollector: informationCollector,
        silent: true,
      );
    });
  }

  final Future<double> futureScale;
  final InformationCollector? informationCollector;

  Future<void> _onCodecReady(ui.Codec codec) async {
    try {
      ui.FrameInfo nextFrame = await codec.getNextFrame();
      double scale = await futureScale;
      setImage(ImageInfo(image: nextFrame.image, scale: scale));
    } catch (exception, stack) {
      reportError(
        context: ErrorDescription('resolving an image frame'),
        exception: exception,
        stack: stack,
        informationCollector: this.informationCollector,
        silent: true,
      );
    }
  }
}

/// Performs exactly like a [MemoryImage] but instead of taking in bytes it takes
/// in a future that represents bytes.
class _FutureMemoryImage extends ImageProvider<_FutureMemoryImage> {
  /// Constructor for FutureMemoryImage.  [_futureBytes] is the bytes that will
  /// be loaded into an image and [_futureScale] is the scale that will be applied to
  /// that image to account for high-resolution images.
  const _FutureMemoryImage(this._futureBytes, this._futureScale);

  final Future<Uint8List> _futureBytes;
  final Future<double> _futureScale;

  /// See [ImageProvider.obtainKey].
  @override
  Future<_FutureMemoryImage> obtainKey(ImageConfiguration configuration) {
    return SynchronousFuture<_FutureMemoryImage>(this);
  }

  /// See [ImageProvider.load].
  @override
  ImageStreamCompleter load(_FutureMemoryImage key, DecoderCallback decode) {
    return _FutureImageStreamCompleter(
      codec: _loadAsync(key, decode),
      futureScale: _futureScale,
    );
  }

  Future<ui.Codec> _loadAsync(
    _FutureMemoryImage key,
    DecoderCallback decode,
  ) async {
    assert(key == this);
    return _futureBytes.then((Uint8List bytes) {
      return decode(bytes);
    });
  }

  /// See [ImageProvider.operator==].
  @override
  bool operator ==(dynamic other) {
    if (other.runtimeType != runtimeType) return false;
    final _FutureMemoryImage typedOther = other;
    return _futureBytes == typedOther._futureBytes &&
        _futureScale == typedOther._futureScale;
  }

  /// See [ImageProvider.hashCode].
  @override
  int get hashCode => hashValues(_futureBytes.hashCode, _futureScale);

  /// See [ImageProvider.toString].
  @override
  String toString() =>
      '$runtimeType(${describeIdentity(_futureBytes)}, scale: $_futureScale)';
}

class SFSymbol extends StatelessWidget {
  static const MethodChannel _channel =
      MethodChannel('plugins.flutter.io/sfsymbols');

  //TODO semantics (default to icon name?)

  final String name;
  final Color? primaryColor;
  final Color? secondaryColor;
  final Color? tertiaryColor;
  final double? pointSize;
  final SymbolWeight? weight;
  final SymbolScale? scale;

  const SFSymbol(this.name,
      {this.primaryColor,
      this.secondaryColor,
      this.tertiaryColor,
      this.pointSize,
      this.weight,
      this.scale,
      Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final IconThemeData iconTheme = IconTheme.of(context);
    final Color? effectivePrimaryColor = primaryColor ?? iconTheme.color;
    // Note that icontheme.size is probably not the same as iOS pointSize.
    final double? effectivePointSize = pointSize ?? iconTheme.size;
    final SymbolWeight? effectiveWeight = weight ?? SymbolWeight.regular;
    final SymbolScale? effectiveScale = scale ?? SymbolScale.system;

    final List<double> colors = [
      effectivePrimaryColor!.red.toDouble(),
      effectivePrimaryColor.green.toDouble(),
      effectivePrimaryColor.blue.toDouble(),
      iconTheme.opacity!,
    ];

    if (secondaryColor != null) {
      colors.addAll([
        secondaryColor!.red.toDouble(),
        secondaryColor!.green.toDouble(),
        secondaryColor!.blue.toDouble(),
        iconTheme.opacity!,
      ]);
    }

    if (tertiaryColor != null) {
      colors.addAll([
        tertiaryColor!.red.toDouble(),
        tertiaryColor!.green.toDouble(),
        tertiaryColor!.blue.toDouble(),
        iconTheme.opacity!,
      ]);
    }

    return Image(
      image: _load(
        name,
        colors,
        effectivePointSize!,
        effectiveWeight!.index,
        effectiveScale!.index,
      ),
    );
  }

  /// Loads a system symbol. The equivalent would be:
  /// `[UIImage systemImageNamed:name]`.
  ///
  /// Throws an exception if the symbol can't be found.
  ///
  /// See [https://developer.apple.com/documentation/uikit/uiimage/1624146-imagenamed?language=objc]
  static ImageProvider _load(
    String name,
    List<double> colors,
    double pointSize,
    int weightIndex,
    int scaleIndex,
  ) {
    Future<Map?> loadInfo = _channel.invokeMapMethod('loadSymbol', [
      name,
      pointSize,
      weightIndex,
      scaleIndex,
      colors,
    ]);
    Completer<Uint8List> bytesCompleter = Completer<Uint8List>();
    Completer<double> scaleCompleter = Completer<double>();
    loadInfo.then((map) {
      if (map == null) {
        scaleCompleter.completeError(
          Exception("Symbol couldn't be found: $name"),
        );
        bytesCompleter.completeError(
          Exception("Symbol couldn't be found: $name"),
        );
        return;
      }
      scaleCompleter.complete(map["scale"]);
      bytesCompleter.complete(map["data"]);
    });
    return _FutureMemoryImage(bytesCompleter.future, scaleCompleter.future);
  }
}

enum SymbolWeight {
  ultralight,
  thin,
  light,
  regular,
  medium,
  semibold,
  bold,
  heavy,
  black,
}

enum SymbolScale {
  small,
  medium,
  large,
  system,
}
