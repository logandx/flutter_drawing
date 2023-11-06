import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import '../config/config.dart';
import '../controller/controller.dart';
import '../models/models.dart';
import '../painter/painter.dart';
import '../widgets/widgets.dart';

class DrawingScribbler extends StatefulWidget {
  const DrawingScribbler({
    super.key,
    this.controller,
    this.width,
    this.height,
    this.backgroundColor,
    this.clipBehavior = Clip.antiAlias,
    this.config = const DrawingConfig(),
    this.getByteCallback,
  });

  final DrawingController? controller;
  final double? width;
  final double? height;
  final Color? backgroundColor;
  final Clip clipBehavior;
  final DrawingConfig config;
  final void Function()? getByteCallback;

  @override
  State<DrawingScribbler> createState() => _DrawingScribblerState();
}

class _DrawingScribblerState extends State<DrawingScribbler> {
  final linesNotifier = ValueNotifier<List<Sketch>>([]);
  final currentLineNotifier = ValueNotifier<Sketch?>(null);

  late DrawingController controller;
  late double maxWidth;
  late double maxHeight;

  bool _isDrawing = false;

  int? activePointerId;

  @override
  void initState() {
    super.initState();
    _updateWidgetSize();
    controller = widget.controller ?? DrawingController();
    controller.addListener(() {
      if (linesNotifier.value.isNotEmpty) {
        widget.getByteCallback!.call();
      }
    });
  }

  @override
  void didUpdateWidget(covariant DrawingScribbler oldWidget) {
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

  void _startDraw(
    Offset point, {
    bool isDrawing = false,
  }) {
    if (isPointWithinBounds(point, maxWidth, maxHeight)) {
      currentLineNotifier.value = Sketch(
        points: [point],
        color: controller.value.color,
        strokeWidth: controller.value.strokeWidth,
      );
      _isDrawing = isDrawing;
    }
  }

  void _update(Offset offset) {
    if (isPointWithinBounds(offset, maxWidth, maxHeight)) {
      final points = currentLineNotifier.value?.points ?? [];
      final path = List<Offset>.from(points)..add(offset);

      currentLineNotifier.value = Sketch(
        points: path,
        color: controller.value.color,
        strokeWidth: controller.value.strokeWidth,
      );
    }
  }

  Future<void> _endDraw() async {
    if (currentLineNotifier.value != null &&
        currentLineNotifier.value!.points.isNotEmpty) {
      linesNotifier.value = List<Sketch>.from(linesNotifier.value)
        ..add(currentLineNotifier.value!);
      controller.setSketches(linesNotifier.value);
    }
  }

  void handleTouchEvent(PointerEvent event) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final Offset point = box.globalToLocal(event.position);
    if (widget.config.singleTouchOnly) {
      _handleSingleTouchEvent(event, point);
    } else {
      _handleMultiTouchesEvent(event, point);
    }
  }

  void _handleSingleTouchEvent(PointerEvent event, Offset point) {
    if (event is PointerDownEvent) {
      if (activePointerId == null) {
        activePointerId = event.pointer;
        _startDraw(point, isDrawing: true);
      }
    } else if (event is PointerMoveEvent) {
      if (activePointerId == event.pointer && _isDrawing) {
        _update(point);
      }
    } else if (event is PointerUpEvent) {
      if (activePointerId == event.pointer && _isDrawing) {
        _isDrawing = false;
        _endDraw();
      }
      activePointerId = null;
    }
  }

  void _handleMultiTouchesEvent(PointerEvent event, Offset point) {
    if (event is PointerDownEvent) {
      _startDraw(point, isDrawing: true);
    } else if (event is PointerMoveEvent) {
      _update(point);
    } else if (event is PointerUpEvent) {
      _endDraw();
    }
  }

  Widget buildCurrentPath() {
    final listenerWidget = ValueListenableBuilder<Sketch?>(
      valueListenable: currentLineNotifier,
      builder: (context, value, _) {
        return RepaintBoundary(
          child: SizedBox(
            width: maxWidth,
            height: maxHeight,
            child: CustomPaint(
              painter: DrawingPainter(
                sketches: value == null ? [] : [value],
              ),
            ),
          ),
        );
      },
    );
    return Listener(
      onPointerDown: handleTouchEvent,
      onPointerMove: handleTouchEvent,
      onPointerUp: handleTouchEvent,
      child: listenerWidget,
    );
  }

  Widget buildAllSketches() {
    return ValueListenableBuilder<List<Sketch>>(
      valueListenable: linesNotifier,
      builder: (context, value, _) {
        return Nested(
          children: [
            RepaintBoundaryWrapper(
              controller: controller,
            ),
          ],
          child: SizedBox(
            width: maxWidth,
            height: maxHeight,
            child: CustomPaint(
              painter: DrawingPainter(
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
        DrawingControllerWrapper(
          controller: controller,
          currentLineNotifier: currentLineNotifier,
          linesNotifier: linesNotifier,
        ),
      ],
      child: ClipRect(
        clipBehavior: widget.clipBehavior,
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
      ),
    );
  }
}
