import 'package:cumbia_live_company/add_new_event/set_date_time_for_event/set_date_time_for_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NewEventScreen extends StatelessWidget {
  const NewEventScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          height: 1.0.sh,
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
                        child: Center(
                            child: Image.asset('assets/img/applogo.png')))
                  ],
                ),
              ),
              SizedBox(
                height: 145.h,
              ),
              Container(
                height: 120.h,
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
                                      child:
                                          Image.asset('assets/img/check.png'),
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
                                      child:
                                          Image.asset('assets/img/check.png'),
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
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [],
                      )
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: 200.h,
              ),
              Container(
                height: 220.h,
                width: 0.5.sw,
                // color: Colors.blueGrey,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 261.w,
                      height: 220.h,
                      decoration: BoxDecoration(
                        color: Color(0xFFF7F9FB),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                          bottomLeft: Radius.circular(24.r),
                          bottomRight: Radius.circular(24.r),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.h),
                            decoration: BoxDecoration(
                              color: Color(0xFF0D818C), // header color
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.r),
                                topRight: Radius.circular(24.r),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Nuevo evento',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28.sp,
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),

                          // Body
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.h),
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0x82000000),
                                      offset: Offset(0, 4),
                                      blurRadius: 4,
                                      spreadRadius: 0,
                                    ),
                                  ],
                                ),
                                height: 97.h,
                                width: 97.w,
                                child: CircleAvatar(
                                  radius: 30.sp,
                                  backgroundColor: Color(0xFF53A4AC),
                                  child: GestureDetector(
                                    child: Image.asset('assets/img/Vector.png'),
                                    onTap: () {
                                      // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const Datepickerscreen()));
                                      Navigator.of(context).push(
                                        PageRouteBuilder(
                                          pageBuilder: (context, animation,
                                                  secondaryAnimation) =>
                                              SetDateTimeForEventScreen(),
                                          transitionDuration: Duration.zero,
                                          reverseTransitionDuration:
                                              Duration.zero,
                                          transitionsBuilder: (context,
                                              animation,
                                              secondaryAnimation,
                                              child) {
                                            return child;
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 497.w,
                      height: 220.h,
                      decoration: BoxDecoration(
                        color: Color(0xFF15BECE),
                        // outer container color (optional)
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16.r),
                          topRight: Radius.circular(16.r),
                          bottomLeft: Radius.circular(24.r),
                          bottomRight: Radius.circular(24.r),
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16.h),
                            decoration: BoxDecoration(
                              color: Color(0xFFF15BECE),
                              // outer container color (optional)
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(24.r),
                                topRight: Radius.circular(24.r),
                              ),
                            ),
                            child: Center(
                              child: Container(
                                height: 40.h,
                                width: 177.w,
                                // color: Colors.red,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Image.asset(
                                        'assets/img/Group.png',
                                        height: 32.02.h,
                                        width: 32.81.w,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Image.asset(
                                        'assets/img/settings.png',
                                        height: 32.02.h,
                                        width: 32.02.w,
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {},
                                      child: Image.asset(
                                        'assets/img/document.png',
                                        height: 32.02.h,
                                        width: 25.98.w,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),

                          // Body
                          Container(
                            // color: Colors.red,
                            width: double.infinity,
                            height: 147.h,
                            decoration: BoxDecoration(
                                color: Color(0xFFF7F9FB),
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(24.r),
                                  bottomRight: Radius.circular(24.r),
                                )),
                            // padding: EdgeInsets.all(16.h),
                            child: Center(
                              child: Text(
                                "No has creado eventos aúnrr",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 32.sp,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
