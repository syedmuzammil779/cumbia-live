import 'dart:convert';
import 'dart:developer';
import 'dart:html' as html;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cumbia_live_company/CallPage.dart';
import 'package:cumbia_live_company/Models/Constants.dart';
import 'package:cumbia_live_company/Models/Shopify/shopify_product_model.dart';
import 'package:cumbia_live_company/Models/Structs.dart';
import 'package:cumbia_live_company/add_new_event/centered_view/upload_screen.dart';
import 'package:cumbia_live_company/add_new_event/live_stream_url/live_stream_url_screen.dart';
import 'package:cumbia_live_company/add_new_event/live_stream_url/model/ShopifyProduct.dart';
import 'package:cumbia_live_company/controller/CreateLiveStreamUrlController.dart';
import 'package:cumbia_live_company/controller/ProductsController.dart';
import 'package:cumbia_live_company/homeScreen.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreen();
}

class _ProductsScreen extends State<ProductsScreen> {

  ProductsController productsController = Get.put(ProductsController());

  @override
  void initState() {
    super.initState();
    productsController.getData();
  }

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
                showProductsView(),
                // SizedBox(
                //   height: 50.h,
                // ),
                // Container(
                //   height: 470.h,
                //   width: 443.w,
                // ),
                // SizedBox(
                //   height: 50.h,
                // ),
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
                             setState(() {
                               Navigator.pop(context);
                             });
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
                              // saveNewStreamData();
                              Navigator.of(context).push(
                                PageRouteBuilder(
                                  pageBuilder: (context, animation, secondaryAnimation) => UrlScreen(),
                                  transitionDuration: Duration.zero,
                                  reverseTransitionDuration: Duration.zero,
                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                    return child;
                                  },
                                ),
                              );
                            },
                            child: Text(
                              "Generar script",
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

  Widget showProductsView() {
    List<ShopifyProductModel>  products = productsController.allProducts.value.shopProducts??[];
    var screenSizeHeight = MediaQuery.of(context).size.height;
    var screenSizeWidth = MediaQuery.of(context).size.width;
    return Container(
        height: MediaQuery.of(context).size.height * 0.5,
        child: ListView(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).size.height * 0.045,
            left: MediaQuery.of(context).size.width * 0.05,
            right: MediaQuery.of(context).size.width * 0.05,
          ),
          physics: ScrollPhysics(),
          shrinkWrap: true,
          children: [
            Text(
              'Selecciona los productos que se mostrarán en el Stream',
              style: TextStyle(
                  color: Theme.of(context).primaryColor,
                  fontStyle: FontStyle.normal,
                  fontFamily: 'Gotham',
                  decoration: TextDecoration.none,
                  fontSize: 18,
                  fontWeight: FontWeight.w700),
              textAlign: TextAlign.center,
            ),
            Container(
              height: MediaQuery.of(context).size.height * 0.03,
            ),
            Visibility(
              visible: products.length == 0 ? false : true,
              child: GridView.builder(
                padding: EdgeInsets.only(right: 100, left: 100),
                physics: ScrollPhysics(),
                shrinkWrap: true,
                gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisSpacing: 30,
                  mainAxisSpacing: 30,
                  childAspectRatio: 1.2,
                  crossAxisCount: 4,
                ),
                itemCount: products.length == 0 ? 1 : products.length,
                itemBuilder: (context, int index) =>
                    productShowWidget(index, MediaQuery.of(context).size.width, MediaQuery.of(context).size.height),
              ),
            ),
            Visibility(
                visible: products.length == 0 ? true : false,
                child: CupertinoActivityIndicator()),
          ],
        ));
  }

  Widget productShowWidget(int index, double screenSizeWidth, double screenSizeHeight) {
    List<ShopifyProductModel> products = productsController.allProducts.value.shopProducts ?? [];
    print("shopProducts----- ${products.length}");

    return Container(
      width: screenSizeWidth * 0.7,
      margin: EdgeInsets.zero, // no extra space
      padding: EdgeInsets.zero, // no extra space
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(screenSizeHeight * 0.02),
      ),
      child: GestureDetector(
        onTap: () {
          if (createLiveStreamUrlController.productsSelected.contains(products[index])) {
            var support = createLiveStreamUrlController.productsSelected.indexOf(products[index]);
            setState(() {
              createLiveStreamUrlController.productsSelected.removeAt(support);
            });
          } else {
            setState(() {
              createLiveStreamUrlController.productsSelected.add(products[index]);
            });
          }
          createLiveStreamUrlController.update();
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min, // prevent column from stretching vertically
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(20),
                    topLeft: Radius.circular(20),
                  ),
                  child: SizedBox(
                    height: 100,
                    width: double.infinity,
                    child: products[index].image?.src == ''
                        ? Image.asset('assets/img/photo_1.png', fit: BoxFit.cover)
                        : Image.network(products[index].image?.src ?? "", fit: BoxFit.cover),
                  ),
                ),
                Visibility(
                  visible: createLiveStreamUrlController.productsSelected.contains(products[index]),
                  child: Icon(
                    Icons.check_circle,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            ),
            Text(
              '${products[index].title}',
              style: TextStyle(
                color: Colors.red,
                fontFamily: 'Gotham',
                decoration: TextDecoration.none,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              'Shopify',
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontFamily: 'Gotham',
                decoration: TextDecoration.none,
                fontSize: 18,
                fontWeight: FontWeight.w300,
              ),
            ),
            Text(
              '\$${products[index].price}',
              style: TextStyle(
                color: Theme.of(context).secondaryHeaderColor,
                fontFamily: 'Gotham',
                decoration: TextDecoration.none,
                fontSize: 15,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  CreateLiveStreamUrlController createLiveStreamUrlController = Get.put(CreateLiveStreamUrlController());

}
