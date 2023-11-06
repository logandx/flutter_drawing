import 'package:flutter/material.dart';
import 'package:flutter_drawing/flutter_drawing.dart';

enum StrokeWidthEnum {
  tiny(2.0),
  small(4.0),
  medium(8.0);

  final double strokeWidth;
  const StrokeWidthEnum(this.strokeWidth);
}

class StrokeWidthWidget extends StatefulWidget {
  const StrokeWidthWidget({
    super.key,
    required this.controller,
    required this.onStrokeWidthChanged,
  });
  final DrawingController controller;
  final void Function(double value) onStrokeWidthChanged;
  @override
  State<StrokeWidthWidget> createState() => _StrokeWidthWidgetState();
}

class _StrokeWidthWidgetState extends State<StrokeWidthWidget> {
  late double currentStrokeWidth;

  @override
  void initState() {
    super.initState();
    currentStrokeWidth = widget.controller.value.strokeWidth;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Nét bút'),
        const SizedBox(width: 12),
        ...List.generate(
          StrokeWidthEnum.values.length,
          (index) {
            final strokeWidth = StrokeWidthEnum.values[index].strokeWidth;
            return GestureDetector(
              onTap: () {
                setState(() {
                  currentStrokeWidth = strokeWidth;
                });
                widget.onStrokeWidthChanged.call(strokeWidth);
              },
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: currentStrokeWidth == strokeWidth
                        ? Colors.blue
                        : Colors.transparent,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: StrokeWidthEnum.values.reversed
                            .elementAt(index)
                            .strokeWidth *
                        1.4,
                  ),
                  decoration: const BoxDecoration(
                    color: Colors.black,
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
