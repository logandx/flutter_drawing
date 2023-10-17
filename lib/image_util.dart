import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image/image.dart' as img;

class ImageUtil {
  const ImageUtil._();

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

class ScreenshotController {
  late GlobalKey _containerKey;

  ScreenshotController() {
    _containerKey = GlobalKey();
  }

  Future<Uint8List?> capture({
    double? pixelRatio,
    Duration delay = const Duration(milliseconds: 20),
  }) {
    //Delay is required. See Issue https://github.com/flutter/flutter/issues/22308
    return Future.delayed(delay, () async {
      try {
        ui.Image? image = await captureAsUiImage(
          delay: Duration.zero,
          pixelRatio: pixelRatio,
        );
        ByteData? byteData =
            await image?.toByteData(format: ui.ImageByteFormat.png);
        image?.dispose();

        Uint8List? pngBytes = byteData?.buffer.asUint8List();

        return pngBytes;
      } on Exception {
        rethrow;
      }
    });
  }

  Future<ui.Image?> captureAsUiImage({
    double? pixelRatio = 1,
    Duration delay = const Duration(milliseconds: 20),
  }) {
    return Future.delayed(delay, () async {
      try {
        final findRenderObject =
            _containerKey.currentContext?.findRenderObject();
        if (findRenderObject == null) {
          return null;
        }
        RenderRepaintBoundary boundary =
            findRenderObject as RenderRepaintBoundary;
        BuildContext? context = _containerKey.currentContext;
        if (pixelRatio == null) {
          if (context != null) {
            pixelRatio = pixelRatio ?? MediaQuery.of(context).devicePixelRatio;
          }
        }
        ui.Image image = await boundary.toImage(pixelRatio: pixelRatio ?? 1);
        return image;
      } on Exception {
        rethrow;
      }
    });
  }
}
