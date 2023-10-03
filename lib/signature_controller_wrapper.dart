import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import 'signature_controller.dart';
import 'sketch.dart';

class SignatureControllerWrapper extends SingleChildStatefulWidget {
  const SignatureControllerWrapper({super.key, 
    required this.controller,
    required this.currentLineNotifier,
    required this.linesNotifier,
  });
  final SignatureController controller;
  final ValueNotifier<Sketch?> currentLineNotifier;
  final ValueNotifier<List<Sketch>> linesNotifier;

  @override
  State<SignatureControllerWrapper> createState() => _MyWidgetState();
}

class _MyWidgetState extends SingleChildState<SignatureControllerWrapper> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(onHandleController);
  }

  void onHandleController() {
    if (widget.controller.value.sketch == null &&
        widget.controller.value.sketches.isEmpty) {
      widget.currentLineNotifier.value = null;
      widget.linesNotifier.value = [];
    }
    setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(onHandleController);
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
