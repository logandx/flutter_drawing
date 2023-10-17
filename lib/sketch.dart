import 'dart:typed_data';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Sketch extends Equatable {
  const Sketch({
    this.points = const [],
    this.color = Colors.black,
    this.strokeWidth = 2.0,
    this.strokeJoin = StrokeJoin.bevel,
    this.strokeCap = StrokeCap.round,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;

  @override
  List<Object?> get props {
    return [
      points,
      color,
      strokeWidth,
      strokeCap,
      strokeJoin,
    ];
  }
}

class SketchValue extends Equatable {
  const SketchValue({
    this.sketches = const [],
    this.color = Colors.black,
    this.strokeWidth = 2.0,
    this.sketch,
    this.imageBytes,
  });

  final List<Sketch> sketches;
  final Sketch? sketch;
  final Color color;
  final double strokeWidth;
  final Uint8List? imageBytes;

  bool get hasLine => sketch != null || sketches.isNotEmpty;

  SketchValue copyWith({
    List<Sketch>? sketches,
    Sketch? sketch,
    Color? color,
    double? strokeWidth,
    Uint8List? imageBytes,
  }) {
    return SketchValue(
      sketches: sketches ?? this.sketches,
      sketch: sketch ?? this.sketch,
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      imageBytes: imageBytes ?? this.imageBytes,
    );
  }

  @override
  List<Object?> get props => [
        sketches,
        sketch,
        color,
        strokeWidth,
        imageBytes,
      ];
}
