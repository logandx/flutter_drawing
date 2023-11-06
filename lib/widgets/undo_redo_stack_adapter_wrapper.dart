import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import '../controller/controller.dart';
import '../models/models.dart';

class UndoRedoStackWrapper extends SingleChildStatefulWidget {
  const UndoRedoStackWrapper({
    Key? key,
    required this.linesNotifier,
    required this.currentLineNotifier,
    required this.controller,
  }) : super(key: key);

  final DrawingController controller;
  final ValueNotifier<List<Sketch>> linesNotifier;
  final ValueNotifier<Sketch?> currentLineNotifier;

  @override
  State<UndoRedoStackWrapper> createState() => _UndoRedoStackState();
}

class _UndoRedoStackState extends SingleChildState<UndoRedoStackWrapper>
    implements UndoRedoStackAdapter {
  late final List<Sketch> _redoStack = [];

  late int _sketchCount;

  late final ValueNotifier<bool> _canRedo = ValueNotifier<bool>(false);

  void _sketchesCountListener() {
    if (widget.linesNotifier.value.length > _sketchCount) {
      _redoStack.clear();
      _canRedo.value = false;
      _sketchCount = widget.linesNotifier.value.length;
    }
  }

  @override
  void initState() {
    super.initState();
    widget.controller.register(this);
    _sketchCount = widget.linesNotifier.value.length;
    widget.linesNotifier.addListener(_sketchesCountListener);
  }

  @override
  void didUpdateWidget(covariant UndoRedoStackWrapper oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.unregister();
      widget.controller.register(this);
    }
  }

  @override
  void dispose() {
    widget.controller.unregister();
    widget.linesNotifier.removeListener(_sketchesCountListener);
    super.dispose();
  }

  @override
  void undo() {
    final sketches = List<Sketch>.from(widget.linesNotifier.value);
    if (sketches.isNotEmpty) {
      _sketchCount--;
      _redoStack.add(sketches.removeLast());
      widget.linesNotifier.value = sketches;
      _canRedo.value = true;
      widget.currentLineNotifier.value = null;
    }
  }

  @override
  void redo() {
    if (_redoStack.isEmpty) return;
    final sketch = _redoStack.removeLast();
    _canRedo.value = _redoStack.isNotEmpty;
    _sketchCount++;
    widget.linesNotifier.value = [...widget.linesNotifier.value, sketch];
  }

  @override
  ValueNotifier<bool> get canRedo => _canRedo;

  @protected
  void clear() {
    _sketchCount = 0;
    widget.linesNotifier.value = [];
    _canRedo.value = false;
    widget.currentLineNotifier.value = null;
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
