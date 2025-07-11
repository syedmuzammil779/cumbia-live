import 'dart:math' as math;
import 'package:cumbia_live_company/add_new_event/set_date_time_for_event/set_date_time_for_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MinuteSelector extends StatelessWidget {
  final TimeOfDay selectedTime;
  final Function(int minute) onMinuteSelected;

  const MinuteSelector({
    super.key,
    required this.selectedTime,
    required this.onMinuteSelected,
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

          // Line to selected minute
          CustomPaint(
            key: ValueKey('${selectedTime.minute}'),
            size: Size(301.w, 324.1330871582031.h),
            painter: LinePainter(hour: selectedTime.minute),
          ),

          // Outer circle: minutes 0–29
          ...List.generate(30, (i) => _buildMinuteDot(i, 120, i)),

          // Inner circle: minutes 30–59
          ...List.generate(30, (i) => _buildMinuteDot(i + 30, 75, i)),
        ],
      ),
    );
  }

  Widget _buildMinuteDot(int minute, double radius, int i) {
    final angle = (i / 30) * 2 * math.pi;
    final centerX = 301.w / 2;
    final centerY = 324.1330871582031.h / 2;
    final x = centerX + radius * math.cos(angle);
    final y = centerY + radius * math.sin(angle);
    final isSelected = selectedTime.minute == minute;

    return Positioned(
      left: x - 12,
      top: y - 12,
      child: GestureDetector(
        onTap: () => onMinuteSelected(minute),
        child: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? const Color(0xFF15BECE) : Colors.white,
          ),
          child: Center(
            child: Text(
              '$minute',
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
