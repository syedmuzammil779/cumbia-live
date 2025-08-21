import 'package:cumbia_live_company/add_new_event/centered_view/ProductsScreen.dart';
import 'package:cumbia_live_company/controller/CreateLiveStreamUrlController.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';

import 'dart:typed_data';

import 'package:get/get_core/src/get_main.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({super.key});

  @override
  State<UploadScreen> createState() => _UploadScreen();
}

class _UploadScreen extends State<UploadScreen> {
  CreateLiveStreamUrlController createLiveStreamUrlController = Get.put(CreateLiveStreamUrlController());

  Uint8List? myImage;

  @override
  void initState() {
    super.initState();
  }
  Future<void> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: true,
    );

    if (result != null && result.files.single.bytes != null) {
      final bytes = result.files.single.bytes!;

      setState(() {
        myImage = bytes;
      });

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        // Upload to Firebase
        final url = await createLiveStreamUrlController.uploadImageToFirebase(bytes);

        // Save URL to controller
        createLiveStreamUrlController.setBannerUrl(url);
      } catch (e) {
        print('Upload failed: $e');
        // Optional: show error dialog/snackbar
      } finally {
        // Dismiss the loading dialog
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }


  bool uploadStatus = false;

  @override
  Widget build(BuildContext context) {
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
                          child: Center(
                              child: Image.asset('assets/img/applogo.png')))
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                  height: 50.h,
                ),
                Container(
                    height: 470.h,
                    width: 443.w,
                    // color: Colors.red,
                    child: Container(
                      width: 497.w,
                      height: 387.h,
                      decoration: BoxDecoration(
                        // color: Color(0xFF15BECE), // outer container color (optional)
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
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(40)),
                                padding: EdgeInsets.all(4.w),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                        child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          uploadStatus = false;
                                        });
                                      },
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: (uploadStatus == false)
                                                ? Color(0xFF1F6977)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(40)),
                                        padding: EdgeInsets.all(4),
                                        child: Center(
                                            child: Text(
                                          "Nueva descarga",
                                          style: TextStyle(
                                              color: (uploadStatus == false)
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.sp),
                                        )),
                                      ),
                                    )),
                                    // SizedBox(width: 10.w,),
                                    Expanded(
                                        child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          uploadStatus = true;
                                        });
                                      },
                                      child: Container(
                                        padding: EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                            color: (uploadStatus == true)
                                                ? Color(0xFF1F6977)
                                                : Colors.transparent,
                                            borderRadius:
                                                BorderRadius.circular(40)),
                                        child: Center(
                                            child: Text(
                                          "Reciente",
                                          style: TextStyle(
                                              fontSize: 12.sp,
                                              color: (uploadStatus == true)
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontWeight: FontWeight.w600),
                                        )),
                                      ),
                                    ))
                                  ],
                                ),
                              ),
                            ),
                          ),
                          if (uploadStatus == false) ...[
                            Container(
                              // color: Colors.red,
                              width: double.infinity,
                              height: 387.h,
                              padding: EdgeInsets.all(30),
                              decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(24.r),
                                    bottomRight: Radius.circular(24.r),
                                  )),
                              // padding: EdgeInsets.all(16.h),
                              child: Center(
                                  child: GestureDetector(
                                onTap: () async {
                                  await pickImage();
                                },
                                child: myImage == null
                                    ? DottedBorder(
                                        borderType: BorderType.RRect,
                                        radius: Radius.circular(24),
                                        dashPattern: [8, 4],
                                        color: Color(0xFFE2E6EA),
                                        // You can change this to any color you need
                                        strokeWidth: 2,
                                        child: Container(
                                          width: 379,
                                          height: 323,
                                          child: Center(
                                            child: Container(
                                              height: 0.18.sh,
                                              width: 0.1.sw,
                                              // color: Colors.red,
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  GestureDetector(
                                                      onTap: () async {
                                                        await pickImage();
                                                      },
                                                      child: Image.asset(
                                                        ('assets/img/Frame.png'),
                                                        width: 80.w,
                                                        height: 80.h,
                                                        fit: BoxFit.contain,
                                                      )),
                                                  Center(
                                                    child: Text(
                                                      "Click to browse or",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14.sp,
                                                          color: Colors
                                                              .grey[500] // OR
                                                          ),
                                                    ),
                                                  ),
                                                  Text(
                                                      "drag and drop your files",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.w400,
                                                          fontSize: 14.sp,
                                                          color: Colors
                                                              .grey[500]) // OR
                                                      ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(12.r),
                                        child: Image.memory(
                                          myImage!,
                                          width: 370.w,
                                          height: 320.h,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                              )),
                            ),
                          ] else ...[
                            Container(
                              width: double.infinity,
                              height: 387.h,
                              decoration: BoxDecoration(
                                  color: Colors.grey[50],
                                  borderRadius: BorderRadius.only(
                                    bottomLeft: Radius.circular(24.r),
                                    bottomRight: Radius.circular(24.r),
                                  )),
                              child: Center(
                                child: Text(
                                  "No recent uploads....",
                                  style: TextStyle(
                                      fontSize: 25.sp,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey[500]),
                                ),
                              ),
                            )
                          ]
                        ],
                      ),
                    )),
                SizedBox(
                  height: 50.h,
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
                              style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF0F8DA3)),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              minimumSize: Size(271.w, 55.h),
                              side: const BorderSide(
                                color: Color(0xFF0F8DA3), // Border color
                                width: 2, // Border width
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Navigator.of(context).push(MaterialPageRoute(builder: (context) => ProductsScreen()));
                              if ((createLiveStreamUrlController.bannerUrl??"").isEmpty) {
                                Get.snackbar('Falta imagen', 'Por favor sube un banner');
                                return;
                              }
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation,
                                          secondaryAnimation) =>
                                      ProductsScreen(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                  transitionsBuilder: (context, animation,
                                      secondaryAnimation, child) {
                                    return child;
                                  },
                                ),
                              );
                            },
                            child: Text(
                              "Seleccionar productos",
                              style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0F8DA3),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
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
