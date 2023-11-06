import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_drawing/flutter_drawing.dart';

import 'clear_button.dart';
import 'color_picker.dart';
import 'save_button.dart';
import 'stroke_width_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = DrawingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: DrawingScribbler(
              config: const DrawingConfig(singleTouchOnly: true),
              backgroundColor: Colors.amber,
              controller: _controller,
            ),
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
            controller: _controller,
            onSaved: (value) {
              _controller.save(value);
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ValueListenableBuilder<SketchValue>(
                valueListenable: _controller,
                builder: (context, value, child) => ElevatedButton(
                    onPressed: value.sketch == null || value.sketches.isEmpty
                        ? null
                        : () {
                            _controller.undo();
                          },
                    child: const Text('Undo')),
              ),
              ElevatedButton(
                  onPressed: () {
                    log(_controller.canRedo.value.toString());
                    _controller.redo();
                  },
                  child: const Text('Redo')),
            ],
          )
        ],
      ),
    );
  }
}
