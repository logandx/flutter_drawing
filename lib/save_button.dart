import 'dart:convert';
import 'dart:developer';

import 'image_util.dart';
import 'signature_controller.dart';
import 'sketch.dart';
import 'package:flutter/material.dart';

class SaveButton extends StatelessWidget {
  const SaveButton({
    super.key,
    required this.canvasGlobalKey,
    required this.controller,
    required this.onSignatureSaved,
  });
  final GlobalKey canvasGlobalKey;
  final SignatureController controller;
  final void Function(String base64String) onSignatureSaved;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SketchValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return ElevatedButton(
          onPressed: value.sketch == null || value.sketches.isEmpty
              ? null
              : () async {
                  final pngBytes = await ImageUtil.getBytes(canvasGlobalKey);
                  if (pngBytes == null) return;
                  final minOffset = controller.minOffset;
                  final maxOffset = controller.maxOffset;
                  if (minOffset != null && maxOffset != null) {
                    final result = ImageUtil.cropImg(
                      pngBytes,
                      minOffset,
                      maxOffset,
                    );
                    final base64String = base64Encode(result);
                    log(base64String);
                    onSignatureSaved.call(base64String);
                  }
                },
          child: const Text('Lưu'),
        );
      },
    );
  }
}
