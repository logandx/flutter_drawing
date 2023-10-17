import 'dart:typed_data';

import 'signature_controller.dart';
import 'sketch.dart';
import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.controller,
    required this.onSignatureSaved,
  });
  final SignatureController controller;
  final void Function(Uint8List imageBytes)? onSignatureSaved;

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
                  onSignatureSaved?.call(result);
                },
          child: const Text('Lưu'),
        );
      },
    );
  }
}
