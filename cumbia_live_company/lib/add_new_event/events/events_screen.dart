import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cumbia_live_company/add_new_event/live_stream_url/live/live_page.dart';
import 'package:cumbia_live_company/add_new_event/model/Event.dart';
import 'package:cumbia_live_company/add_new_event/newEvent.dart';
import 'package:cumbia_live_company/add_new_event/set_date_time_for_event/set_date_time_for_event_screen.dart';
import 'package:cumbia_live_company/common/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  List<Event> events = [];
  bool isLoading = true;

  // final List<String> texts = [
  //   "Junio 27 - Lanzamiento ",
  //   "Junio 28 - Lanzamiento ",
  //   "Junio 28 - Lanzamiento ",
  // ];

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () async {
      await fetchEvents();
    });
  }

  Future<void> fetchEvents() async {
    print('[fetchEvents] Start fetching events...');
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('events')
          .orderBy('eventDateTime')
          .get();

      print(
          '[fetchEvents] Fetched ${snapshot.docs.length} documents from Firestore.');

      final list = snapshot.docs.map((doc) {
        print('[fetchEvents] Mapping document with ID: ${doc.id}');
        return Event.fromDoc(doc);
      }).toList();

      print('[fetchEvents] Mapped ${list.length} events.');
      print('[fetchEvents] events before setState: $events');

      setState(() {
        if (list.isNotEmpty) {
          events = list;
          print('[fetchEvents] events updated in state.');
        } else {
          print('[fetchEvents] Fetched event list is empty.');
        }
        isLoading = false;
      });

      print('[fetchEvents] events after setState: ${events.length}');
    } catch (e, stack) {
      print('[fetchEvents] Error fetching events: $e');
      print(stack);
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatEventDate(DateTime date) {
    return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
  }

  Future<DateTime?> _pickDateTime({DateTime? initialDate}) async {
    DateTime? date = await showDatePicker(
      context: context,
      initialDate: initialDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (date == null) return null;

    TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate ?? DateTime.now()),
    );
    if (time == null) return null;

    return DateTime(date.year, date.month, date.day, time.hour, time.minute);
  }

  Future<void> _editEventDate(Event event) async {
    final pickedDate = await _pickDateTime(initialDate: event.eventDateTime);
    if (pickedDate == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('events')
          .doc(event.id)
          .update({'eventDateTime': pickedDate.toIso8601String()});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Event updated')),
      );

      setState(() {});
    } catch (e) {
      debugPrint('Error updating event: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update event: $e')),
      );
    }
  }

  void _showEventOptionsDialog(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Opciones de eventos"),
        content: const Text("Elija una acción para este evento"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _editEventDate(event);  // call your edit function
            },
            child: const Text("Editar fecha"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // close dialog
              _confirmDeleteEvent(context, event); // confirm deletion
            },
            child: const Text("Eliminar evento", style: TextStyle(color: Colors.red),),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteEvent(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text("Eliminar evento"),
        content: const Text("¿Estás seguro que deseas eliminar este evento?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteEvent(event);
            },
            child: const Text("Borrar", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteEvent(Event event) async {
  try {
    await FirebaseFirestore.instance.collection('events').doc(event.id).delete();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Evento eliminado')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('No se pudo eliminar el evento: $e')),
    );
  }
}

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
                      child:
                          Center(child: Image.asset('assets/img/applogo.png')))
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 145.h, bottom: 200.h),
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
            Container(
              height: 320.h,
              width: 0.55.sw,
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context).push(
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                    SetDateTimeForEventScreen(),
                            transitionDuration: Duration.zero,
                            reverseTransitionDuration: Duration.zero,
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return child;
                            },
                          ),
                        );
                      },
                      child: Container(
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
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 28.sp,
                                      fontWeight: FontWeight.w600),
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
                                    child: Image.asset('assets/img/Vector.png'),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          height: 45.h,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            GestureDetector(
                                onTap: () {
                                  if (_pageController.hasClients &&
                                      currentPage > 0) {
                                    _pageController.previousPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
                                  }
                                },
                                child: Container(
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
                                        child: Icon(
                                          Icons.arrow_back_ios_new_outlined,
                                          color: Colors.white,
                                        ),
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
                              child: isLoading
                                  ? Center(child: CircularProgressIndicator())
                                  : events.isEmpty
                                      ? Container(
                                          height: 220.h,
                                          decoration: BoxDecoration(
                                            color: Color(0xFF15BECE),
                                            borderRadius:
                                                BorderRadius.circular(24.r),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: double.infinity,
                                                padding: EdgeInsets.all(16.h),
                                                decoration: BoxDecoration(
                                                  color: Color(0xFF15BECE),
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              24.r)),
                                                ),
                                                child: Center(
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceEvenly,
                                                    children: [
                                                      Image.asset(
                                                          'assets/img/Group.png',
                                                          height: 32.02.h,
                                                          width: 32.81.w),
                                                      Image.asset(
                                                          'assets/img/settings.png',
                                                          height: 32.02.h,
                                                          width: 32.02.w),
                                                      Image.asset(
                                                          'assets/img/document.png',
                                                          height: 32.02.h,
                                                          width: 25.98.w),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  width: double.infinity,
                                                  decoration: BoxDecoration(
                                                    color: Color(0xFFF7F9FB),
                                                    borderRadius:
                                                        BorderRadius.vertical(
                                                            bottom:
                                                                Radius.circular(
                                                                    24.r)),
                                                  ),
                                                  child: Center(
                                                    child: Text(
                                                      "No has creado eventos aún",
                                                      style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w600,
                                                        fontSize: 28.sp,
                                                        color: Colors.grey,
                                                      ),
                                                      textAlign:
                                                          TextAlign.center,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        )
                                      : PageView.builder(
                                          controller: _pageController,
                                          itemCount: events.length,
                                          physics:
                                              NeverScrollableScrollPhysics(),
                                          onPageChanged: (index) {
                                            setState(() {
                                              currentPage = index;
                                            });
                                          },
                                          itemBuilder: (context, index) {
                                            final event = events[index];
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: Color(0xFF15BECE),
                                                borderRadius:
                                                    BorderRadius.circular(24.r),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    padding:
                                                        EdgeInsets.all(16.h),
                                                    decoration: BoxDecoration(
                                                      color: Color(0xFF15BECE),
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius
                                                                  .circular(
                                                                      24.r)),
                                                    ),
                                                    child: Center(
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceEvenly,
                                                        children: [
                                                          GestureDetector(
                                                            onTap: () {
                                                              final streamLink = events[index].streamLink??"";
                                                              final uri = Uri.parse(streamLink);
                                                              final roomId = uri.pathSegments.isNotEmpty ? uri.pathSegments.last : '';
                                                              Navigator.push(
                                                                context,
                                                                MaterialPageRoute(
                                                                  builder: (context) => LivePage(
                                                                    isHost: true,
                                                                    localUserID: "localUserID",
                                                                    localUserName: "localUserName",
                                                                    roomID: roomId,
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                            child: Image.asset(
                                                                'assets/img/Group.png',
                                                                height: 32.02.h,
                                                                width: 32.81.w),
                                                          ),
                                                          GestureDetector(
                                                            onTap: (){
                                                              _showEventOptionsDialog(context, events[index]);
                                                            },
                                                            child: Image.asset(
                                                                'assets/img/settings.png',
                                                                height: 32.02.h,
                                                                width: 32.02.w),
                                                          ),
                                                          GestureDetector(
                                                            onTap: (){
                                                              Clipboard.setData(ClipboardData(text: "${events[index].streamLink}"));
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
                                                            child: Image.asset(
                                                                'assets/img/document.png',
                                                                height: 32.02.h,
                                                                width: 25.98.w),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Container(
                                                      width: double.infinity,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            Color(0xFFF7F9FB),
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                bottom: Radius
                                                                    .circular(
                                                                        24.r)),
                                                      ),
                                                      child: Center(
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Text(
                                                              event.title,
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontSize: 28.sp,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                            ),
                                                            SizedBox(
                                                                height: 8.h),
                                                            Text(
                                                              formatEventDate(
                                                                  event.eventDateTime ??
                                                                      DateTime
                                                                          .now()),
                                                              style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w300,
                                                                fontSize: 20.sp,
                                                                color: Colors
                                                                    .black,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
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
                                  if (_pageController.hasClients &&
                                      currentPage < events.length - 1) {
                                    _pageController.nextPage(
                                        duration: Duration(milliseconds: 300),
                                        curve: Curves.easeInOut);
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
                                        child: Icon(
                                          Icons.arrow_forward_ios_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ))
                          ],
                        ),
                        SizedBox(height: 30.h),
                        SmoothPageIndicator(
                          controller: _pageController,
                          count: events.length,
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
