import 'package:cumbia_live_company/add_new_event/events/events_screen.dart';
import 'package:cumbia_live_company/controller/CreateLiveStreamUrlController.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:uuid/uuid.dart';
import 'dart:html' as html;

class UrlScreen extends StatefulWidget {
  const UrlScreen({super.key});

  @override
  State<UrlScreen> createState() => _UrlScreen();
}

class _UrlScreen extends State<UrlScreen> {

  final roomID = Uuid().v4().replaceAll('-', '').substring(0, 8);
  @override
  Widget build(BuildContext context) {
    // String liveStreamUrl = "https://cumbialive.com/livestream/$roomID";
    final String baseUrl = html.window.location.origin;
    final String liveStreamUrl = "$baseUrl/livestream/$roomID";
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
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
                          child: Center(child: Image.asset('assets/img/applogo.png')))
                    ],
                  ),
                ),
                SizedBox(
                  height: 0.1.sh,
                ),
                Container(
                  height: 120.h,
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
                                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
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
                                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
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
                                    "Seleccionar",
                                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600),
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
                Container(
                  height: 470.h,
                  width: 713.w,
                  // color: Colors.blue,
                  child: Column(
                    children: [
                      SizedBox(
                        height: 151.h,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w),
                        width: double.infinity,
                        height: 50.h,
                        // color: Colors.red,
                        child: Text(
                          "Tu script está listo para usar, por favor pégalo en tu sitio web",
                          style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w700, color: Color(0xFF0F8DA3)),
                        ),
                      ),
                      SizedBox(
                        height: 110.h,
                      ),
                      Center(
                        child: Container(
                          height: 70.h,
                          // color: Colors.red,
                          child: Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(text: liveStreamUrl));
                                  final overlay = Overlay.of(context);
                                  final overlayEntry = OverlayEntry(
                                    builder: (context) => Positioned(
                                      top: MediaQuery.of(context).size.height * 0.4, // adjust position
                                      left: MediaQuery.of(context).size.width * 0.5 - 50,
                                      child: Material(
                                        color: Colors.transparent,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: Colors.black87,
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: const Text(
                                            "Copied!",
                                            style: TextStyle(color: Colors.white, fontSize: 14),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                  overlay.insert(overlayEntry);
                                  Future.delayed(const Duration(seconds: 2), () {
                                    overlayEntry.remove();
                                  });
                                },
                                child: Container(
                                  height: 62.h,
                                  width: 62.w,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Color(0xFF53A4AC),
                                  ),
                                  child: Image.asset(
                                    'assets/img/document.png',
                                    height: 32.02.h,
                                    width: 25.98.w,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 10.w,
                              ),
                              Expanded(child: Container(
                                padding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                                decoration: BoxDecoration(borderRadius: BorderRadius.circular(31.17), color: Color(0xFF15BECE)),
                                child: Center(
                                  child: Text(
                                    liveStreamUrl,
                                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 22.sp, color: Colors.white),
                                  ),
                                ),
                              ))
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 0.15.sh,
                ),
                Center(
                  child: Container(
                      height: 55.h,
                      width: 0.4.sw,
                      // color: Colors.red,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text(
                              "Cancelar",
                              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Color(0xFF0F8DA3)),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              minimumSize: Size(271.w, 55.h),
                              side: const BorderSide(
                                color: Color(0xFF0F8DA3), // Border color
                                width: 2, // Border width
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Navigator.of(context).push(MaterialPageRoute(builder: (context) => SlidingTimerScreen()));
                              CreateLiveStreamUrlController createLiveStreamUrlController = Get.put(CreateLiveStreamUrlController());
                              createLiveStreamUrlController.setStreamLink(liveStreamUrl);
                              createLiveStreamUrlController.createEvent(context: context);
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => EventsScreen(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return child;
                                  },
                                ),
                              );
                            },
                            child: Text(
                              "Guardar evento ",
                              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0F8DA3),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              minimumSize: Size(271.w, 55.h),
                              side: const BorderSide(
                                color: Color(0xFF0F8DA3), // Border color
                                width: 2, // Border width
                              ),
                            ),
                          )
                        ],
                      )),
                )
              ],
            )));
  }


}
