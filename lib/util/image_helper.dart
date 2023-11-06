import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

class ImageHelper {
  const ImageHelper._();

  static Future<Uint8List?> getBytes(
    GlobalKey globalKey, {
    ui.ImageByteFormat format = ui.ImageByteFormat.png,
  }) async {
    final RenderRepaintBoundary boundary =
        globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
    final ui.Image image = await boundary.toImage();
    final ByteData? byteData = await image.toByteData(format: format);
    final Uint8List? bytes = byteData?.buffer.asUint8List();
    return bytes;
  }

  static Uint8List cropImg({
    required Uint8List imageBytes,
    required Offset minOffset,
    required Offset maxOffset,
    int extraSpace = 10,
  }) {
    final img.Image? imageBeforeResize = img.decodeImage(imageBytes);
    if (imageBeforeResize == null) {
      throw Exception('Failed to decode image');
    }

    final img.Image imageAfterCrop = img.copyCrop(
      imageBeforeResize,
      x: minOffset.dx.floor() - extraSpace,
      y: minOffset.dy.floor() - extraSpace,
      width: (maxOffset.dx - minOffset.dx).floor() + 2 * extraSpace,
      height: (maxOffset.dy - minOffset.dy).floor() + 2 * extraSpace,
    );

    final List<int> bytesImgAfterCrop = img.encodePng(imageAfterCrop);
    final Uint8List uInt8List = Uint8List.fromList(bytesImgAfterCrop);
    return uInt8List;
  }
}
