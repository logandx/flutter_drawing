import 'package:flutter/material.dart';
import 'package:nested/nested.dart';

import '../controller/controller.dart';

class RepaintBoundaryWrapper extends SingleChildStatelessWidget {
  const RepaintBoundaryWrapper({
    super.key,
    required this.controller,
  });
  final DrawingController controller;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null);
    return RepaintBoundary(
      key: controller.globalKey,
      child: child!,
    );
  }
}
