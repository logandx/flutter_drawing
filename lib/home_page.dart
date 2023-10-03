import 'dart:developer';

import 'package:flutter/material.dart';

import 'clear_button.dart';
import 'color_picker.dart';
import 'save_button.dart';
import 'signature.dart';
import 'signature_controller.dart';
import 'stroke_width_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = SignatureController();
  final canvasGlobalKey = GlobalKey();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('App Bar'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Spacer(),
            Signature(
              canvasGlobalKey: canvasGlobalKey,
              backgroundColor: Colors.amber,
              width: 300,
              height: 230,
              controller: _controller,
            ),
            const SizedBox(height: 8),
            ClearButton(
              onClear: () {
                _controller.clear();
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                ColorPickerWidget(
                  controller: _controller,
                  onColorChanged: (value) {
                    _controller.setColor(value);
                  },
                ),
                StrokeWidthWidget(
                  controller: _controller,
                  onStrokeWidthChanged: (value) {
                    _controller.setStrokeWidth(value);
                  },
                )
              ],
            ),
            SaveButton(
              canvasGlobalKey: canvasGlobalKey,
              controller: _controller,
              onSignatureSaved: (value) {
                log(value);
              },
            ),
          ],
        ),
      ),
    );
  }
}
