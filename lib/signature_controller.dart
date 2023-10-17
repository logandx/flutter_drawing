import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_drawing_example/signature.dart';

import 'image_util.dart';
import 'sketch.dart';
import 'undo_redo_stack_wrapper.dart';

class SignatureController extends ValueNotifier<SketchValue>
    implements UndoRedoStackAdapter {
  SignatureController({
    SketchValue? value,
  }) : super(value ?? const SketchValue()) {
    _globalKey = GlobalKey<State<Signature>>();
  }
  late GlobalKey<State<Signature>> _globalKey;

  late ReceivePort appReceiver;
  late StreamSubscription appReceiverPortSub;

  GlobalKey<State<Signature>> get globalKey => _globalKey;

  @override
  void dispose() {
    appReceiverPortSub.cancel().then((value) => appReceiverPortSub);
    super.dispose();
  }

  void clear() {
    value = SketchValue(
      color: value.color,
      strokeWidth: value.strokeWidth,
      imageBytes: value.imageBytes,
    );
  }

  void setSketch(Sketch sketch) {
    if (value.sketch != sketch) {
      value = value.copyWith(sketch: sketch);
    }
  }

  void setSketches(List<Sketch> sketches) {
    if (value.sketches != sketches) {
      value = value.copyWith(sketches: sketches);
    }
  }

  void setColor(Color color) {
    if (value.color != color) {
      value = value.copyWith(color: color);
    }
  }

  void setStrokeWidth(double strokeWidth) {
    if (value.strokeWidth != strokeWidth) {
      value = value.copyWith(strokeWidth: strokeWidth);
    }
  }

  void save(Uint8List imageBytes) {
    if (value.imageBytes != imageBytes) {
      value = value.copyWith(imageBytes: imageBytes);
    }
  }

  Offset? get maxOffset {
    if (value.sketches.isEmpty) return null;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    for (var sketch in value.sketches) {
      for (var point in sketch.points) {
        if (point.dx > maxX) maxX = point.dx;
        if (point.dy > maxY) maxY = point.dy;
      }
    }
    return Offset(maxX, maxY);
  }

  Offset? get minOffset {
    if (value.sketches.isEmpty) return null;
    double minX = double.infinity;
    double minY = double.infinity;
    for (var sketch in value.sketches) {
      for (var point in sketch.points) {
        if (point.dx < minX) minX = point.dx;
        if (point.dy < minY) minY = point.dy;
      }
    }
    return Offset(minX, minY);
  }

  Future<Uint8List?> get imageBytes async {
    final bytes = await ImageUtil.getBytes(_globalKey);
    if (bytes == null) {
      return null;
    }
    value = value.copyWith(imageBytes: bytes);
    return bytes;
  }

  String? get imageBase64 {
    final bytes = value.imageBytes;
    if (bytes == null) {
      return null;
    }
    if (minOffset != null && maxOffset != null) {
      final result = ImageUtil.cropImg(
        imageBytes: bytes,
        maxOffset: maxOffset!,
        minOffset: minOffset!,
      );
      final base64String = base64Encode(result);
      return base64String;
    }
    return null;
  }

  Future<String?> convertToBase64() async {
    final pngBytes = await ImageUtil.getBytes(_globalKey);
    if (pngBytes == null) {
      return null;
    }
    if (minOffset != null && maxOffset != null) {
      final result = ImageUtil.cropImg(
        imageBytes: pngBytes,
        maxOffset: maxOffset!,
        minOffset: minOffset!,
      );
      final base64String = base64Encode(result);
      return base64String;
    }
    return null;
  }

  UndoRedoStackAdapter? _adapter;

  UndoRedoStackAdapter _debugAdapterNonNull() {
    assert(_adapter != null);
    return _adapter!;
  }

  @override
  void undo() {
    final adapter = _debugAdapterNonNull();
    return adapter.undo();
  }

  @override
  void redo() {
    final adapter = _debugAdapterNonNull();
    return adapter.redo();
  }

  @override
  ValueNotifier<bool> get canRedo {
    final adapter = _debugAdapterNonNull();
    return adapter.canRedo;
  }

  void register(UndoRedoStackAdapter value) {
    _adapter = value;
  }

  void unregister() {
    _adapter = null;
  }
}
