import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../models/models.dart';
import '../util/util.dart';
import 'adapter/adapter.dart';

class DrawingController extends ValueNotifier<SketchValue>
    implements UndoRedoStackAdapter {
  DrawingController({
    SketchValue? value,
  }) : super(value ?? const SketchValue()) {
    _globalKey = GlobalKey();
  }
  late GlobalKey _globalKey;

  GlobalKey get globalKey => _globalKey;

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
    final bytes = await ImageHelper.getBytes(_globalKey);
    if (bytes == null) {
      return null;
    }
    if (minOffset == null || maxOffset == null) {
      return null;
    }
    final croppedImageBytes = ImageHelper.cropImg(
      imageBytes: bytes,
      maxOffset: maxOffset!,
      minOffset: minOffset!,
    );
    value = value.copyWith(imageBytes: croppedImageBytes);
    return croppedImageBytes;
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
