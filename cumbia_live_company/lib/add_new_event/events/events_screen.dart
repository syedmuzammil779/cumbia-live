import 'package:cumbia_live_company/add_new_event/newEvent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class EventsScreen extends StatefulWidget {
  const EventsScreen({super.key});

  @override
  State<EventsScreen> createState() => _EventsScreenState();
}

class _EventsScreenState extends State<EventsScreen> {
  final PageController _pageController = PageController();
  int currentPage = 0;

  final List<String> texts = [
    "Junio 27 - Lanzamiento ",
    "Junio 28 - Lanzamiento ",
    "Junio 28 - Lanzamiento ",
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: SingleChildScrollView(
            child: Container(
          height: 1.0.sh,
          width: 1.0.sw,
          child: Column(children: [
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
                      child: Center(child: Image.asset('assets/img/applogo.png')))
                ],
              ),
            ),
            SizedBox(
              height: 145.h,
            ),
            Container(
              height: 104.h,
              // width: 1.0.sw,
              // color: Colors.red,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: 104.h,
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
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 104.h,
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
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 104.h,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
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
                                "Subir banner",
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 104.h,
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
                                "Seleccionar",
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
                              )
                            ],
                          ),
                        ),
                        Container(
                          height: 104.h,
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
                                ],
                              ),
                              Text(
                                "URL estática",
                                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
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
            SizedBox(
              height: 200.h,
            ),
            Container(
              height: 320.h,
              width: 0.55.sw,
              // color: Clors.red,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center
                  ,
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
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(16.h),
                        decoration: BoxDecoration(
                          color: Color(0xFF0D818C),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(24.r),
                            topRight: Radius.circular(24.r),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Nuevo evento',
                            style: TextStyle(color: Colors.white, fontSize: 28.sp, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ),
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
                                  // Navigator.of(context).push(
                                  //   // MaterialPageRoute(builder: (context) => const Datepickerscreen()),
                                  // );
                                  Navigator.of(context).pushReplacement(
                                    PageRouteBuilder(
                                      pageBuilder: (context, animation, secondaryAnimation) => NewEventScreen(),
                                      transitionDuration: Duration.zero,
                                      reverseTransitionDuration: Duration.zero,
                                      transitionsBuilder: (context, animation, secondaryAnimation, child) {
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

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 45.h,),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        GestureDetector(
                            onTap: () {
                              if (_pageController.hasClients && currentPage > 0) {
                                _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                              }
                            },
                            child: Container(
                              // width: double.infinity,
                              padding: EdgeInsets.all(3),
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
                                  height: 67.h,
                                  width: 67.w,
                                  child: CircleAvatar(
                                    radius: 30.sp,
                                    backgroundColor: Color(0xFF53A4AC),
                                    child: Icon(Icons.arrow_back_ios_new_outlined,color: Colors.white,),
                                  ),
                                ),
                              ),
                            )),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.3,
                          height: 220.h,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Color(0x3327590F),
                                offset: Offset(0, 2),
                                blurRadius: 48,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: PageView.builder(
                            controller: _pageController,
                            itemCount: texts.length,
                            physics: NeverScrollableScrollPhysics(),
                            onPageChanged: (index) {
                              setState(() {
                                currentPage = index;
                              });
                            },
                            itemBuilder: (context, index) {
                              return Container(
                                decoration: BoxDecoration(
                                  color: Color(0xFF15BECE),
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
                                    Container(
                                      width: double.infinity,
                                      padding: EdgeInsets.all(16.h),
                                      decoration: BoxDecoration(
                                        color: Color(0xFF15BECE),
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(24.r),
                                          topRight: Radius.circular(24.r),
                                        ),
                                      ),
                                      child: Center(
                                        child: Container(
                                          height: 40.h,
                                          width: 177.w,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.center,
                                            children: [
                                              Image.asset('assets/img/Group.png', height: 32.02.h, width: 32.81.w),
                                              Image.asset('assets/img/settings.png', height: 32.02.h, width: 32.02.w),
                                              Image.asset('assets/img/document.png', height: 32.02.h, width: 25.98.w),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: double.infinity,
                                      height: 148.h,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFF7F9FB),
                                        borderRadius: BorderRadius.only(
                                          bottomLeft: Radius.circular(24.r),
                                          bottomRight: Radius.circular(24.r),
                                        ),
                                      ),
                                      child: Center(
                                        child: Column(
                                          children: [
                                            Text(
                                              texts[index],
                                              style: TextStyle(
                                                fontWeight: FontWeight.w600,
                                                fontSize: 36.sp,
                                                color: Colors.black,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                            Text(
                                              "2025-06-27 - 21:11",
                                              style: TextStyle(
                                                fontWeight: FontWeight.w300,
                                                fontSize: 32.sp,
                                                color: Colors.black,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        GestureDetector(
                            onTap: () {
                              if (_pageController.hasClients && currentPage < texts.length - 1) {
                                _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.easeInOut);
                              }
                            },
                            child: Container(
                              // width: double.infinity,
                              padding: EdgeInsets.all(3.h),
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
                                  height: 67.h,
                                  width: 67.w,
                                  child: CircleAvatar(
                                    radius: 30.sp,
                                    backgroundColor: Color(0xFF53A4AC),
                                    child: Icon(Icons.arrow_forward_ios_outlined,color: Colors.white,),
                                  ),
                                ),
                              ),
                            ))

                      ],
                    ),
                    SizedBox(height: 30.h),
                    SmoothPageIndicator(
                      controller: _pageController,
                      count: texts.length,
                      effect: WormEffect(
                        dotHeight: 20.h,
                        dotWidth: 20.w,
                        activeDotColor: Color(0xFF15BECE),
                        dotColor: Colors.grey.shade300,
                      ),
                    )
                  ],
                ),
              ]),
            ),
          ]),
        )));
  }
}
