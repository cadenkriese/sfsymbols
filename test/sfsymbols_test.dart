// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sfsymbols/sfsymbols.dart';

void main() {
  const MethodChannel channel = MethodChannel('plugins.flutter.io/sfsymbols');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('loadImage', () {
    // expect(SFSymbols.load(name: "foobar"), '42');
  });
}
