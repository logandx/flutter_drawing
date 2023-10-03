import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'signature_controller.dart';
import 'sketch.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

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

  Future<Uint8List?> getBytes(
    GlobalKey<State<StatefulWidget>> canvasGlobalKey,
  ) async {
    RenderRepaintBoundary boundary = canvasGlobalKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }

  Uint8List cropImg(Uint8List image, Offset min, Offset max) {
    final img.Image? imageBeforeResize = img.decodePng(image);
    final img.Image imageAfterResize = img.copyCrop(
      imageBeforeResize!,
      x: min.dx.floor() - 10,
      y: min.dy.floor() - 10,
      width: (max.dx - min.dx).floor() + 20,
      height: (max.dy - min.dy).floor() + 20,
    );
    final List<int> bytesImgAfterResize = img.encodePng(imageAfterResize);
    final uInt8List = Uint8List.fromList(bytesImgAfterResize);
    return uInt8List;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<SketchValue>(
      valueListenable: controller,
      builder: (context, value, child) {
        return ElevatedButton(
          onPressed: value.sketch == null || value.sketches.isEmpty
              ? null
              : () async {
                  final pngBytes = await getBytes(canvasGlobalKey);
                  if (pngBytes != null) {
                    final firstOffset = controller.minOffset;
                    final lastOffset = controller.maxOffset;
                    if (firstOffset != null && lastOffset != null) {
                      final result = cropImg(pngBytes, firstOffset, lastOffset);
                      final base64String = base64Encode(result);
                      log(base64String);
                      onSignatureSaved.call(base64String);
                    }
                  }
                },
          child: const Text('Lưu'),
        );
      },
    );
  }
}
