import 'dart:math' as Math;

import 'package:cumbia_live_company/add_new_event/centered_view/upload_screen.dart';
import 'package:cumbia_live_company/add_new_event/time_picker/clock_time_picker_screen.dart';
import 'package:cumbia_live_company/controller/CreateLiveStreamUrlController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:intl/intl.dart';

class SetDateTimeForEventScreen extends StatefulWidget {
  const SetDateTimeForEventScreen({super.key});

  @override
  State<SetDateTimeForEventScreen> createState() =>
      _SetDateTimeForEventScreenState();
}

class _SetDateTimeForEventScreenState extends State<SetDateTimeForEventScreen> {
  CreateLiveStreamUrlController createLiveStreamUrlController = Get.put(CreateLiveStreamUrlController());

  TimeOfDay? selectedTime;
  int selectedMinute = 0;
  bool isSelectedhour = true;

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedTime) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  DateTime selectedDate = DateTime.now();
  bool isDateTabSelected = true; // Toggle between "DATA" and "HORA"

  String get formattedDate {
    return DateFormat('EEEE, MMMM d', 'es_ES').format(selectedDate);
  }

  void _changeMonth(bool forward) {
    setState(() {
      selectedDate = DateTime(
        selectedDate.year,
        selectedDate.month + (forward ? 1 : -1),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(selectedDate.year, selectedDate.month, 1);
    final int daysInMonth =
        DateUtils.getDaysInMonth(selectedDate.year, selectedDate.month);
    final int weekdayOfFirstDay = firstDayOfMonth.weekday % 7; // 0 = Sunday
    final int totalItems = 35;

    final startOffset = weekdayOfFirstDay;
    final DateTime startDate =
        firstDayOfMonth.subtract(Duration(days: startOffset));

    final dates = List.generate(totalItems, (index) {
      return startDate.add(Duration(days: index));
    });
    var fullTime = "$selectedTime : $selectedMinute";
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: 1.0.sw,
        child: Column(
          children: [
            Container(
              width: 1.0.sw,
              height: 117.h,
              color: Theme.of(context).focusColor,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                      height: 117.h,
                      width: 252.w,
                      // color: Colors.red,
                      child:
                          Center(child: Image.asset('assets/img/applogo.png')))
                ],
              ),
            ),
            SizedBox(
              height: 0.1.sh,
            ),
            Container(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 120.h,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 67.79.w / 2,
                                    backgroundColor: Color(0xFF15BECE),
                                    child: Image.asset('assets/img/check.png'),
                                  ),
                                  Container(
                                    width: 89.54.w,
                                    height: 3.2,
                                    color: Color(0xFF15BECE),
                                  ),
                                ],
                              ),
                              Text(
                                "Crear evento",
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 120.h,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 67.79.w / 2,
                                    backgroundColor: Color(0xFF15BECE),
                                    child: Image.asset('assets/img/check.png'),
                                  ),
                                  Container(
                                    width: 89.54.w,
                                    height: 3.2,
                                    color: Color(0xFF15BECE),
                                  ),
                                ],
                              ),
                              Text(
                                "Configurar día",
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 120.h,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Color(0xFF9CA3AF),
                                          width: 6,
                                        )),
                                    child: CircleAvatar(
                                      radius: 30.sp,
                                      backgroundColor: Colors.white,
                                      child: Center(
                                        child: Container(
                                          height: 23.02.h,
                                          width: 23.02.w,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFD1D5DB)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                      width: 89.54.w,
                                      height: 3.2,
                                      color: Color(0xFFD1D5DB)),
                                ],
                              ),
                              Text(
                                "Subir banner",
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 120.h,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Color(0xFF9CA3AF),
                                          width: 6,
                                        )),
                                    child: CircleAvatar(
                                      radius: 30.sp,
                                      backgroundColor: Colors.white,
                                      child: Center(
                                        child: Container(
                                          height: 23.02.h,
                                          width: 23.02.w,
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Color(0xFFD1D5DB)),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Container(
                                      width: 89.54.w,
                                      height: 3.2,
                                      color: Color(0xFFD1D5DB)),
                                ],
                              ),
                              Text(
                                "Seleccionar",
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 120.h,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Color(0xFFD1D5DB),
                                          width: 6,
                                        )),
                                    child: CircleAvatar(
                                      radius: 30.sp,
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "URL estática",
                                style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.3,
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Column(children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => isDateTabSelected = true),
                        child: Container(
                          height: 35.h,
                          width: 161.w,
                          color: Color(0xFF1F6977),
                          child: Center(
                            child: Text(
                              'DATA',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        onTap: () async {
                          setState(() => isDateTabSelected = false);
                        },
                        child: Container(
                          height: 35.h,
                          width: 161.w,
                          color: Color(0xFF3491A2),
                          child: Center(
                            child: Text(
                              'HORA',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                if (isDateTabSelected) ...[
                  Container(
                    width: double.infinity,
                    height: 62.h,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    color: const Color(0xFF30B0C7),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          selectedDate.year.toString(),
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 12.sp,
                            color: Colors.grey[200],
                          ),
                        ),
                        Text(
                          formattedDate,
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 14.sp,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 45.h,
                    color: const Color(0xFFF4F4F4),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          onPressed: () => _changeMonth(false),
                          icon: const Icon(Icons.chevron_left,
                              color: Color(0xFF1F6977)),
                        ),
                        Text(
                          DateFormat('MMMM yyyy', 'es_ES')
                              .format(selectedDate),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1F6977),
                          ),
                        ),
                        IconButton(
                          onPressed: () => _changeMonth(true),
                          icon: const Icon(Icons.chevron_right,
                              color: Color(0xFF1F6977)),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: ['Lu', 'Ma', 'Mi', 'Ju', 'Vi', 'Sa', 'Do']
                          .map((d) => Text(
                                d,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF30B0C7),
                                ),
                              ))
                          .toList(),
                    ),
                  ),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 7,
                    padding: EdgeInsets.zero,
                    children: dates.map((date) {
                      final now = DateTime.now();
                      final today =
                          DateTime(now.year, now.month, now.day);
                      final currentDate =
                          DateTime(date.year, date.month, date.day);
                      final isDisabled = currentDate.isBefore(today);
                      final isSelected = date.day == selectedDate.day &&
                          date.month == selectedDate.month &&
                          date.year == selectedDate.year;

                      final isInCurrentMonth =
                          date.month == selectedDate.month &&
                              date.year == selectedDate.year;

                      return GestureDetector(
                        onTap: isDisabled
                            ? null // disables tap
                            : () {
                                setState(() {
                                  selectedDate = date;
                                  isDateTabSelected = false;
                                });
                              },
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.teal
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(50),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '${date.day}',
                            style: TextStyle(
                              color: isDisabled
                                  ? Colors.grey[
                                      400] // faded color for disabled dates
                                  : isSelected
                                      ? Colors.white
                                      : isInCurrentMonth
                                          ? Colors.black
                                          : const Color(0xFF3491A2),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ] else ...[
                  ClockTimePicker(
                    selectedDate: selectedDate,
                    onTimeSelected: (_selectedData) {
                      setState(() {
                        selectedTime = TimeOfDay(hour: _selectedData.hour, minute: _selectedData.minute);
                      });
                    },
                  )
                ],
                Center(
                  child: Container(
                      height: 55.h,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              height: 48.h,
                              margin: EdgeInsets.only(right: 20.w),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Cancelar",
                                  style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F8DA3)),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  side: const BorderSide(
                                    color: Color(0xFF0F8DA3), // Border color
                                    width: 2, // Border width
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              height: 48.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  if (selectedTime == null) {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        backgroundColor: Colors.white,
                                        title: Text('Hora no seleccionada'),
                                        content: Text('Por favor selecciona una hora antes de continuar.'),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(),
                                            child: Text('OK'),
                                          ),
                                        ],
                                      ),
                                    );
                                    return;
                                  }

                                  // Combine selected date and time into a full DateTime
                                  final date = DateTime(
                                    selectedDate.year,
                                    selectedDate.month,
                                    selectedDate.day,
                                    selectedTime!.hour,
                                    selectedTime!.minute,
                                  );

                                  // Pass to controller
                                  createLiveStreamUrlController.setEventDate(date);

                                  // Navigate to UploadScreen
                                  Navigator.of(context).push(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => UploadScreen(),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
                                    ),
                                  );
                                },
                                child: Text(
                                  "Configurar día",
                                  style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color(0xFF0F8DA3),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8)),
                                  side: const BorderSide(
                                    color: Color(0xFF0F8DA3), // Border color
                                    width: 2, // Border width
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      )),
                )
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class LinePainter extends CustomPainter {
  final int hour;

  LinePainter({required this.hour});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    final angle = ((hour % 12) / 12) * 2 * Math.pi - Math.pi / 2;
    final radius = hour > 12 ? 75.0 : 120.0;

    final end = Offset(
      center.dx + radius * Math.cos(angle),
      center.dy + radius * Math.sin(angle),
    );

    final paint = Paint()
      ..color = const Color(0xFF30B0C7)
      ..strokeWidth = 2;

    canvas.drawLine(center, end, paint);
  }

  @override
  bool shouldRepaint(covariant LinePainter oldDelegate) {
    return oldDelegate.hour != hour;
  }
}

class LinePainterMinutes extends CustomPainter {
  final int minute;

  LinePainterMinutes({required this.minute});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final angle = (minute / 60) * 2 * Math.pi - Math.pi / 2;
    final radius = 120.0;

    final end = Offset(
      center.dx + radius * Math.cos(angle),
      center.dy + radius * Math.sin(angle),
    );

    final paint = Paint()
      ..color = const Color(0xFF30B0C7)
      ..strokeWidth = 2;

    canvas.drawLine(center, end, paint);
  }

  @override
  bool shouldRepaint(covariant LinePainterMinutes oldDelegate) {
    return oldDelegate.minute != minute;
  }
}
