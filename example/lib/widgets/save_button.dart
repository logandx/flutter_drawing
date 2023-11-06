import 'dart:typed_data';

import 'package:flutter/material.dart';

import 'package:flutter_drawing/flutter_drawing.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.controller,
    required this.onSaved,
  });
  final DrawingController controller;
  final void Function(Uint8List imageBytes)? onSaved;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SketchValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return ElevatedButton(
          onPressed: value.sketches.isEmpty || value.sketch == null
              ? null
              : () async {
                  final result = await controller.imageBytes;
                  if (result == null) return;
                  onSaved?.call(result);
                },
          child: const Text('Lưu'),
        );
      },
    );
  }
}
