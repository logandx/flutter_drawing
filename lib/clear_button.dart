import 'package:flutter/material.dart';

class ClearButton extends StatelessWidget {
  const ClearButton({super.key, required this.onClear});

  final VoidCallback? onClear;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        onClear?.call();
      },
      child: const Text('Vẽ lại'),
    );
  }
}
