import 'package:flutter/material.dart';

import 'signature_painter.dart';

import 'signature_controller_wrapper.dart';
import 'sketch.dart';
import 'signature_controller.dart';
import 'package:nested/nested.dart';

class Signature extends StatefulWidget {
  const Signature({
    Key? key,
    this.controller,
    required this.width,
    required this.height,
    this.backgroundColor,
    required this.canvasGlobalKey,
  }) : super(key: key);

  final SignatureController? controller;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final GlobalKey canvasGlobalKey;

  @override
  State<Signature> createState() => _SignatureState();
}

class _SignatureState extends State<Signature> {
  final linesNotifier = ValueNotifier<List<Sketch>>([]);
  final currentLineNotifier = ValueNotifier<Sketch?>(null);

  late SignatureController controller;
  late double maxWidth;
  late double maxHeight;

  @override
  void initState() {
    super.initState();
    _updateWidgetSize();
    controller = widget.controller ?? SignatureController();
  }

  @override
  void didUpdateWidget(covariant Signature oldWidget) {
    super.didUpdateWidget(oldWidget);
    _updateWidgetSize();
  }

  void _updateWidgetSize() {
    maxWidth = widget.width ?? double.infinity;
    maxHeight = widget.height ?? double.infinity;
  }

  bool isPointWithinBounds(Offset point, double maxWidth, double maxHeight) {
    return point.dx >= 0 &&
        point.dx <= maxWidth &&
        point.dy >= 0 &&
        point.dy <= maxHeight;
  }

  void onPanStart(DragStartDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset point = box.globalToLocal(details.globalPosition);
    print(controller.value.color);
    if (isPointWithinBounds(point, maxWidth, maxHeight)) {
      currentLineNotifier.value = Sketch(
        points: [point],
        color: controller.value.color,
        strokeWidth: controller.value.strokeWidth,
      );
      controller.setSketch(currentLineNotifier.value!);
    }
  }

  void onPanUpdate(DragUpdateDetails details) {
    RenderBox box = context.findRenderObject() as RenderBox;
    Offset offset = box.globalToLocal(details.globalPosition);

    if (isPointWithinBounds(offset, maxWidth, maxHeight)) {
      final points = currentLineNotifier.value?.points ?? [];
      final path = List<Offset>.from(points)..add(offset);

      currentLineNotifier.value = Sketch(
        points: path,
        color: controller.value.color,
        strokeWidth: controller.value.strokeWidth,
      );
      controller.setSketch(currentLineNotifier.value!);
    }
  }

  void onPanEnd(DragEndDetails details) {
    if (currentLineNotifier.value != null &&
        currentLineNotifier.value!.points.isNotEmpty) {
      linesNotifier.value = List<Sketch>.from(linesNotifier.value)
        ..add(currentLineNotifier.value!);
      controller.setSketches(linesNotifier.value);
    }
  }

  Widget buildCurrentPath() {
    return GestureDetector(
      onPanStart: onPanStart,
      onPanUpdate: onPanUpdate,
      onPanEnd: onPanEnd,
      child: ValueListenableBuilder<Sketch?>(
        valueListenable: currentLineNotifier,
        builder: (context, value, _) {
          return RepaintBoundary(
            child: SizedBox(
              width: maxWidth,
              height: maxHeight,
              child: CustomPaint(
                painter: SignaturePainter(
                  sketches: value == null ? [] : [value],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buildAllSketches() {
    return ValueListenableBuilder<List<Sketch>>(
      valueListenable: linesNotifier,
      builder: (context, value, _) {
        return RepaintBoundary(
          key: widget.canvasGlobalKey,
          child: SizedBox(
            width: maxWidth,
            height: maxHeight,
            child: CustomPaint(
              painter: SignaturePainter(
                sketches: value,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Nested(
      children: [
        SignatureControllerWrapper(
          controller: controller,
          currentLineNotifier: currentLineNotifier,
          linesNotifier: linesNotifier,
        ),
      ],
      child: Container(
        color: widget.backgroundColor,
        width: maxWidth,
        height: maxHeight,
        child: Stack(
          children: [
            buildAllSketches(),
            buildCurrentPath(),
          ],
        ),
      ),
    );
  }
}
