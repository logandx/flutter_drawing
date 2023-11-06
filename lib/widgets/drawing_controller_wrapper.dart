import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import '../controller/controller.dart';
import '../models/models.dart';

class DrawingControllerWrapper extends SingleChildStatefulWidget {
  const DrawingControllerWrapper({
    super.key,
    required this.controller,
    required this.currentLineNotifier,
    required this.linesNotifier,
  });
  final DrawingController controller;
  final ValueNotifier<Sketch?> currentLineNotifier;
  final ValueNotifier<List<Sketch>> linesNotifier;

  @override
  State<DrawingControllerWrapper> createState() =>
      _DrawingControllerWrapperState();
}

class _DrawingControllerWrapperState
    extends SingleChildState<DrawingControllerWrapper> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_controllerTick);
  }

  void _controllerTick() {
    if (!widget.controller.value.hasLine) {
      widget.currentLineNotifier.value = null;
      widget.linesNotifier.value = [];
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_controllerTick);
    super.dispose();
  }

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null);
    return ValueListenableBuilder<SketchValue>(
      valueListenable: widget.controller,
      builder: (context, value, _) => child!,
    );
  }
}
