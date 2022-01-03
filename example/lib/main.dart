// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:sfsymbols/sfsymbols.dart';

void main() => runApp(MyApp());

/// Main widget for the example app.
class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData.dark(),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SF Symbols'),
        ),
        body: Center(
          child: SFSymbol(
            'face.smiling',
            weight: SymbolWeight.bold,
          ),
        ),
      ),
    );
  }
}
