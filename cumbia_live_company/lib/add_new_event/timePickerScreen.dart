import 'package:flutter/material.dart';

class CustomDialTimePicker extends StatefulWidget {
  final TimeOfDay initialTime;
  final ValueChanged<TimeOfDay> onTimeChanged;
  final bool use24HourFormat;

  const CustomDialTimePicker({
    super.key,
    required this.initialTime,
    required this.onTimeChanged,
    this.use24HourFormat = true,
  });

  @override
  State<CustomDialTimePicker> createState() => _CustomDialTimePickerState();
}

class _CustomDialTimePickerState extends State<CustomDialTimePicker> {
  late TimeOfDay selectedTime;

  @override
  void initState() {
    super.initState();
    selectedTime = widget.initialTime;
  }

  void _handleTimeChanged(TimeOfDay newTime) {
    setState(() {
      selectedTime = newTime;
    });
    widget.onTimeChanged(newTime);
  }

  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: widget.use24HourFormat),
      child: Theme(
        data: Theme.of(context).copyWith(
          timePickerTheme: TimePickerThemeData(
            backgroundColor: Colors.white,
            dialHandColor: Color(0xFF0F8DA3),
            dialBackgroundColor: Color(0xFFE0F7FA),
            hourMinuteTextColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected) ? Colors.white : Colors.black),
            hourMinuteColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected) ? Color(0xFF0F8DA3) : Colors.grey.shade200),
            dayPeriodTextColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected) ? Colors.white : Colors.black),
            dayPeriodColor: MaterialStateColor.resolveWith((states) =>
            states.contains(MaterialState.selected) ? Color(0xFF0F8DA3) : Colors.grey.shade300),
          ),
        ),
        child: TimePickerDialog(
          initialEntryMode: TimePickerEntryMode.dial,
          initialTime: selectedTime,

        ),
      ),
    );
  }
}
