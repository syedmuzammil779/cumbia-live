import 'dart:math';
import 'package:flutter/material.dart';

class ClockTimePicker extends StatefulWidget {
  final int? initialHour;
  final int? initialMinute;
  final DateTime? selectedDate;
  final void Function(DateTime selectedTime)? onTimeSelected;

  const ClockTimePicker({
    super.key,
    this.initialHour,
    this.initialMinute,
    this.selectedDate,
    this.onTimeSelected,
  });

  @override
  State<ClockTimePicker> createState() => _ClockTimePickerState();
}

class _ClockTimePickerState extends State<ClockTimePicker> {
  int? selectedHour;
  int? selectedMinute;
  bool showMinutes = false;

  void _onHourTap(int hour) {
    setState(() {
      selectedHour = hour;
      showMinutes = true;
    });
  }

  void _onMinuteTap(int minute) {
    setState(() {
      selectedMinute = minute;
    });
    if (selectedHour != null) {
      final now = DateTime.now();
      final selectedDateTime = DateTime(
        widget.selectedDate?.year??now.year,
        widget.selectedDate?.month??now.month,
        widget.selectedDate?.day??now.day,
        selectedHour!,
        minute,
      );
      widget.onTimeSelected?.call(selectedDateTime);    }
  }

  void _resetToHourSelection() {
    setState(() {
      showMinutes = false;
      selectedMinute = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    const double radius = 120;
    const double numberSize = 30;
    return Padding(
      padding: const EdgeInsets.all(6),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- Time Display ---
            Text(
              "${(selectedHour ?? '--').toString().padLeft(2, '0')}:${(selectedMinute ?? '--').toString().padLeft(2, '0')}",
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
            // const SizedBox(height: 30),

            // --- Conditional Hour / Minute Picker ---
            if (!showMinutes) ...[
              const Text("Seleccionar hora", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              SizedBox(
                width: radius * 2,
                height: radius * 2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (selectedHour != null)
                      CustomPaint(
                        size: Size(radius * 2, radius * 2),
                        painter: ClockHandPainter(selectedHour!, isHour: true),
                      ),
                    ...List.generate(24, (index) {
                      final bool isOuter = index >= 12;
                      final double angle = (index % 12) * pi / 6 - pi / 2;
                      final double r = isOuter ? radius * 0.85 : radius * 0.6;
                      final double x = radius + r * cos(angle) - numberSize / 2;
                      final double y = radius + r * sin(angle) - numberSize / 2;

                      return Positioned(
                        left: x,
                        top: y,
                        child: GestureDetector(
                          onTap: () => _onHourTap(index),
                          child: Container(
                            width: numberSize,
                            height: numberSize,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selectedHour == index ? Colors.cyan : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              index.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: selectedHour == index ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ] else ...[
              const Text("Seleccionar minuto", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 10),
              SizedBox(
                width: radius * 2,
                height: radius * 2,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (selectedMinute != null)
                      CustomPaint(
                        size: Size(radius * 2, radius * 2),
                        painter: ClockHandPainter(selectedMinute!, isHour: false),
                      ),
                    ...List.generate(12, (i) {
                      final int minute = i * 5;
                      final double angle = i * pi / 6 - pi / 2;
                      final double r = radius * 0.9;
                      final double x = radius + r * cos(angle) - numberSize / 2;
                      final double y = radius + r * sin(angle) - numberSize / 2;

                      return Positioned(
                        left: x,
                        top: y,
                        child: GestureDetector(
                          onTap: () => _onMinuteTap(minute),
                          child: Container(
                            width: numberSize,
                            height: numberSize,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: selectedMinute == minute ? Colors.orange : Colors.transparent,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              minute.toString().padLeft(2, '0'),
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: selectedMinute == minute ? Colors.white : Colors.black,
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Reset Button
              TextButton.icon(
                onPressed: _resetToHourSelection,
                icon: const Icon(Icons.refresh),
                label: const Text("Reset Hour"),
              )
            ],
          ],
        ),
      ),
    );
  }
}


class ClockHandPainter extends CustomPainter {
  final int value;
  final bool isHour;

  ClockHandPainter(this.value, {this.isHour = true});

  @override
  void paint(Canvas canvas, Size size) {
    final double radius = size.width / 2;
    final Offset center = Offset(radius, radius);

    final angle = (value % (isHour ? 12 : 60)) *
        2 *
        pi /
        (isHour ? 12 : 60) -
        pi / 2;

    final bool isOuter = isHour && value >= 12;
    final double handLength = isHour
        ? radius * (isOuter ? 0.85 : 0.6)
        : radius * 0.95;

    final Paint handPaint = Paint()
      ..color = isHour ? Colors.cyan : Colors.orange
      ..strokeWidth = isHour ? 4 : 2
      ..strokeCap = StrokeCap.round;

    final Offset handEnd = Offset(
      center.dx + handLength * cos(angle),
      center.dy + handLength * sin(angle),
    );

    canvas.drawLine(center, handEnd, handPaint);
    canvas.drawCircle(handEnd, 5, handPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
