import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

class ImageUtil {
  const ImageUtil._();

  static Future<Uint8List?> getBytes(
    GlobalKey<State<StatefulWidget>> canvasGlobalKey,
  ) async {
    RenderRepaintBoundary boundary = canvasGlobalKey.currentContext
        ?.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List? pngBytes = byteData?.buffer.asUint8List();
    return pngBytes;
  }

  static Uint8List cropImg(Uint8List image, Offset min, Offset max) {
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
}
