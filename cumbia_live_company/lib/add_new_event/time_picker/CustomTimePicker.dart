import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'hour_selector.dart';
import 'minute_selector.dart';

class CustomTimePicker extends StatefulWidget {
  final TextEditingController hoursController;

  const CustomTimePicker({super.key, required this.hoursController});

  @override
  State<CustomTimePicker> createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  TimeOfDay? selectedTime;
  bool isHourSelected = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: isHourSelected ? 410.h : 390.h,
      width: double.infinity,
      child: Column(
        children: [
          // Time Display Header
          Container(
            width: double.infinity,
            color: const Color(0xFF30B0C7),
            padding: EdgeInsets.symmetric(vertical: 10.h),
            child: Center(
              child: Text(
                selectedTime != null
                    ? '${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}'
                    : '00:00',
                style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 24.sp),
              ),
            ),
          ),
          SizedBox(height: 10.h),

          if (!isHourSelected)
            HourSelector(
              selectedTime: selectedTime,
              onHourSelected: (hour) {
                setState(() {
                  selectedTime = TimeOfDay(hour: hour, minute: selectedTime?.minute ?? 0);
                  isHourSelected = true;
                });
              },
            )
          else
            MinuteSelector(
              selectedTime: selectedTime!,
              onMinuteSelected: (minute) {
                setState(() {
                  selectedTime = TimeOfDay(hour: selectedTime!.hour, minute: minute);
                  widget.hoursController.text =
                  "${selectedTime!.hour.toString().padLeft(2, '0')}:${selectedTime!.minute.toString().padLeft(2, '0')}";
                });
              },
            ),
        ],
      ),
    );
  }
}
