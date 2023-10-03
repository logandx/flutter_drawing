import 'package:flutter/material.dart';

import 'signature_controller.dart';

enum ColorEnum {
  blue(Colors.blue),
  red(Colors.red),
  black(Colors.black);

  final Color color;
  const ColorEnum(this.color);
}

class ColorPickerWidget extends StatefulWidget {
  const ColorPickerWidget({
    super.key,
    required this.controller,
    required this.onColorChanged,
  });

  final SignatureController controller;
  final void Function(Color value) onColorChanged;

  @override
  State<ColorPickerWidget> createState() => _ColorPickerWidgetState();
}

class _ColorPickerWidgetState extends State<ColorPickerWidget> {
  late Color currentColor;

  @override
  void initState() {
    super.initState();
    currentColor = widget.controller.value.color;
  }

  @override
  Widget build(BuildContext context) {
    
    return Row(
      children: [
        const Text('Màu'),
        const SizedBox(width: 12),
        ...List.generate(
          ColorEnum.values.length,
          (index) {
            final color = ColorEnum.values[index].color;
            return GestureDetector(
              onTap: () {
                setState(() {
                  currentColor = color;
                });
                widget.onColorChanged.call(currentColor);
              },
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: currentColor == color
                        ? currentColor
                        : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
