import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'line_painter.dart';

class HourSelector extends StatelessWidget {
  final TimeOfDay? selectedTime;
  final Function(int hour) onHourSelected;

  const HourSelector({
    super.key,
    required this.selectedTime,
    required this.onHourSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 324.1330871582031.h,
      width: 301.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center Dot
          Container(
            width: 20.w,
            height: 20.h,
            decoration: const BoxDecoration(
              color: Color(0xFF30B0C7),
              shape: BoxShape.circle,
            ),
          ),

          // Line to selected hour
          if (selectedTime != null)
            CustomPaint(
              key: ValueKey('${selectedTime!.hour}'),
              size: Size(301.w, 324.1330871582031.h),
              painter: LinePainter(hour: selectedTime!.hour),
            ),

          // Outer ring (1–12)
          ...List.generate(12, (i) {
            final hour = i + 1;
            return _buildHourDot(hour, 120, i);
          }),

          // Inner ring (13–24)
          ...List.generate(12, (i) {
            final hour = i + 13;
            return _buildHourDot(hour, 75, i);
          }),
        ],
      ),
    );
  }

  Widget _buildHourDot(int hour, double radius, int i) {
    final angle = (i / 12) * 2 * math.pi;
    final centerX = 301.w / 2;
    final centerY = 324.1330871582031.h / 2;
    final x = centerX + radius * math.cos(angle);
    final y = centerY + radius * math.sin(angle);
    final isSelected = selectedTime?.hour == hour;

    return Positioned(
      left: x - 12,
      top: y - 12,
      child: GestureDetector(
        onTap: () => onHourSelected(hour),
        child: Container(
          height: 40.h,
          width: 40.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? const Color(0xFF15BECE) : Colors.white,
          ),
          child: Center(
            child: Text(
              '$hour',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF1F6977) : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
