import 'package:flutter/material.dart';
import 'package:flutter_drawing_example/signature_controller.dart';
import 'package:nested/nested.dart';

class ConvertToBase64Wrapper extends SingleChildStatelessWidget {
  const ConvertToBase64Wrapper({
    super.key,
    required this.controller,
  });
  final SignatureController controller;

  @override
  Widget buildWithChild(BuildContext context, Widget? child) {
    assert(child != null);
    return RepaintBoundary(
      key: controller.globalKey,
      child: child!,
    );
  }
}
