import 'package:flutter/material.dart';

import 'sketch.dart';

class SignatureController extends ValueNotifier<SketchValue> {
  SignatureController({SketchValue? value}) : super(value ?? const SketchValue());

  void clear() {
    value = SketchValue(
      sketch: null,
      sketches: const [],
      color: value.color,
      strokeWidth: value.strokeWidth,
    );
  }

  void setSketch(Sketch sketch) {
    if (value.sketch != sketch) {
      value = SketchValue(
        color: value.color,
        sketch: sketch,
        sketches: value.sketches,
        strokeWidth: value.strokeWidth,
      );
    }
  }

  void setSketches(List<Sketch> sketches) {
    value = SketchValue(
      color: value.color,
      sketch: value.sketch,
      sketches: sketches,
      strokeWidth: value.strokeWidth,
    );
  }

  void setColor(Color color) {
    if (value.color != color) {
      value = SketchValue(
        color: color,
        sketch: value.sketch,
        sketches: value.sketches,
        strokeWidth: value.strokeWidth,
      );
    }
  }

  void setStrokeWidth(double strokeWidth) {
    if (value.strokeWidth != strokeWidth) {
      value = SketchValue(
        strokeWidth: strokeWidth,
        sketch: value.sketch,
        sketches: value.sketches,
        color: value.color,
      );
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


}
