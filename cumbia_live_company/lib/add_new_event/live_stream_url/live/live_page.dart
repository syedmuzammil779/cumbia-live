import 'package:cumbia_live_company/Models/Shopify/shopify_product_model.dart';
import 'package:cumbia_live_company/Models/Stream/zegocloud_token.dart';
import 'package:cumbia_live_company/controller/ProductsController.dart';
import 'package:cumbia_live_company/homeScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../Models/WooCommerce/woo_commerce_product_model.dart';
import 'key_center.dart';

class LivePage extends StatefulWidget {
  final bool isHost;
  final String localUserID;
  final String localUserName;
  final String roomID;
  final List<String> selectedProductIds;

  const LivePage({Key? key, required this.isHost, required this.localUserID, required this.localUserName, required this.roomID, required this.selectedProductIds,}) : super(key: key);

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  Widget? localView;
  int? localViewID;
  Widget? remoteView;
  int? remoteViewID;
  String? _userName;
  bool cartDetails = false;
  bool cartAdded = false;
  int num = 1;

  int step = 0; // 0 = cart, 1 = form, 2 = payment

  List<ShopifyProductModel> selectedProducts = [];
  bool isLoadingProducts = true;

  @override
  void initState() {
    super.initState();
    startListenEvent();
    loginRoom();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final allProducts = Get.find<ProductsController>().allProducts.value.shopProducts ?? [];

      final filtered = allProducts
          .where((p) => widget.selectedProductIds.contains(p.id))
          .toList();

      print("allProducts fetching products: $allProducts");
      print("allProducts fetching filtered: $filtered");
      setState(() {
        selectedProducts = filtered;
        isLoadingProducts = false;
      });
    } catch (e) {
      print("Error fetching products: $e");
      setState(() => isLoadingProducts = false);
    }
  }


  int? _selectedIndex;
  final TextEditingController _chatController = TextEditingController();

  bool showAllProducts = false;

  // List<Map<String, dynamic>> products = [
  //   {"name": "Chef Knife", "description": "High-quality stainless steel knife for precise cutting.", "price": 300.99, "image": "https://picsum.photos/200/140?1"},
  //   {"name": "Wireless Earbuds", "description": "Noise-cancelling earbuds with long battery life.", "price": 39.99, "image": "https://picsum.photos/200/140?2"},
  //   {"name": "Running Shoes", "description": "Lightweight and comfortable", "price": 79.99, "image": "https://picsum.photos/200/140?3"},
  // ];

  @override
  void dispose() {
    stopListenEvent();
    logoutRoom();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isAnySelected = _selectedIndex != null;
    return Scaffold(
      appBar: AppBar(title: const Text("Vista previa del streaming en vivo")),
      body: Container(
        height:  MediaQuery.of(context).size.height * 0.8,
        margin: EdgeInsets.only(left: 20),
        child: Row(
          children: [
            Expanded(
              flex: 6,
              child: Stack(
                children: [
                  Container(child: (widget.isHost ? localView : remoteView)) ,
                  Positioned(
                    bottom: 0,
                    right: 0,
                    left: 0,
                    child: Container(
                      width: 1.0.sw,
                      height: 200,
                      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: showAllProducts ? selectedProducts.length : 0,
                              itemBuilder: (context, index) {
                                final product = selectedProducts[index];
                                final bool isSelected = _selectedIndex == index;

                                return GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTap: () {
                                    setState(() {
                                      _selectedIndex = isSelected && cartDetails == false ? null : index;
                                    });
                                  },
                                  child: Container(
                                    margin: EdgeInsets.only(right: 15.w),
                                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.w),
                                    width: isSelected && cartDetails == false ? 0.3.sw : 360.w,
                                    height: isSelected && cartDetails == false ? 0.45.sh : 250.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF001D2B).withOpacity(0.7),
                                      borderRadius: BorderRadius.circular(12.r),
                                      border: Border.all(
                                        color: isSelected ? Colors.lightBlueAccent : Colors.transparent,
                                        width: isSelected ? 1.5 : 0,
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 120.w,
                                              height: 120.h,
                                              color: Colors.red,
                                              // decoration: BoxDecoration(
                                              //   borderRadius: BorderRadius.circular(8),
                                              //   image: (product.images != null && product.images!.isNotEmpty)
                                              //       ? DecorationImage(
                                              //     image: NetworkImage(product.images!.first.src ?? ""),
                                              //     fit: BoxFit.cover,
                                              //   )
                                              //       : const DecorationImage(
                                              //     image: AssetImage('assets/img/bgPhoneNew.png'),
                                              //     fit: BoxFit.cover,
                                              //   ),
                                              //
                                              // ),
                                            ),
                                            SizedBox(width: 4.w),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    product.title ?? "No Title",
                                                    style: TextStyle(
                                                      fontSize: 23.sp,
                                                      color: Colors.white,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  Text(
                                                    product.status ?? "No Description",
                                                    style: TextStyle(
                                                      fontSize: 16.sp,
                                                      color: Colors.grey,
                                                    ),
                                                    maxLines: 3,
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                  if (!isSelected)
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                      children: [
                                                        Row(
                                                          children: [
                                                            Text(
                                                              product.price ?? "0",
                                                              style: TextStyle(
                                                                fontSize: 24.sp,
                                                                color: Colors.white,
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                            ),
                                                            const Text(
                                                              " COP",
                                                              style: TextStyle(color: Colors.lightBlue),
                                                            ),
                                                          ],
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                          },
                                                          child: Container(
                                                            height: 50.h,
                                                            width: 50.w,
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(8),
                                                              color: const Color(0xFF15BECE),
                                                            ),
                                                            child: const Icon(
                                                              Icons.shopping_cart_rounded,
                                                              color: Colors.white,
                                                              size: 28,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),

                          Align(
                            alignment: Alignment.bottomRight,
                            child: Container(
                              height: 40.h,
                              width: 40.w,
                              decoration:
                              BoxDecoration(
                                  color: const Color(0xFF001D2B).withOpacity(0.6),
                                  borderRadius: BorderRadius.circular(6.r)

                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                alignment: Alignment.center,
                                icon: Icon(
                                  showAllProducts ? Icons.keyboard_arrow_down : Icons.keyboard_arrow_up,
                                  color: Colors.white,
                                  size: 30.sp,
                                ),
                                onPressed: () {
                                  setState(() {
                                    showAllProducts = !showAllProducts;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(top: 50),
                    child: Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          step == 0 ? Container(
                            height: cartDetails == true ? 0.6.sh : 0,
                            width: 0.2.sw,
                            decoration: BoxDecoration(color: const Color(0xFF001D2B).withOpacity(0.7), borderRadius: BorderRadius.circular(12.r)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.w),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Carrito de compras  ",
                                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade400),
                                          ),
                                          Icon(
                                            Icons.shopping_cart,
                                            color: Colors.grey.shade400,
                                            size: 16.sp,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),

                                // Cart items
                                Expanded(
                                  child: ListView(
                                    children: [
                                      Container(
                                        margin: EdgeInsets.only(bottom: 10.h),
                                        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.w),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12.r),
                                          child: Column(
                                            children: [
                                              // Top section
                                              Container(
                                                color: Color(0xFF0D8DA3),
                                                padding: EdgeInsets.all(8.w),
                                                child: Row(
                                                  children: [
                                                    Container(
                                                      height: 40.h,
                                                      width: 40.h,
                                                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(6)),
                                                    ),
                                                    SizedBox(width: 10.w),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text("Sartén antiadherente",
                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                                                          Row(
                                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                            children: [
                                                              Text("Azul/Grande", style: TextStyle(color: Colors.white70, fontSize: 12.sp)),
                                                              Container(
                                                                width: 100.w,
                                                                color: Colors.black12,
                                                                child: Row(
                                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                  children: [
                                                                    GestureDetector(
                                                                      onTap: () {
                                                                        setState(() {
                                                                          num--;
                                                                        });
                                                                      },
                                                                      child: Container(
                                                                        height: 30.h,
                                                                        width: 30.w,
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(7),
                                                                          color: Colors.black26,
                                                                        ),
                                                                        child: Icon(Icons.remove_circle, color: Colors.white, size: 18.sp),
                                                                      ),
                                                                    ),
                                                                    Padding(
                                                                      padding: EdgeInsets.symmetric(horizontal: 6.w),
                                                                      child: Text(num.toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                                    ),
                                                                    GestureDetector(
                                                                      onTap: () {
                                                                        setState(() {
                                                                          num++;
                                                                        });
                                                                      },
                                                                      child: Container(
                                                                        height: 30.h,
                                                                        width: 30.w,
                                                                        decoration: BoxDecoration(
                                                                          borderRadius: BorderRadius.circular(7),
                                                                          color: Colors.black26,
                                                                        ),
                                                                        child: Icon(Icons.add_circle, color: Colors.white, size: 18.sp),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          SizedBox(height: 6.h),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              // Bottom section
                                              Container(
                                                color: Colors.black26,
                                                width: double.infinity,
                                                padding: EdgeInsets.all(8.w),
                                                child: Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      "precio",
                                                      style: TextStyle(color: Colors.white),
                                                    ),
                                                    Text("300.000 COP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),

        // Second Item
                                    ],
                                  ),
                                ),

                                // Subtotal + Checkout
                                Container(
                                  height: 120.h,
                                  margin: EdgeInsets.only(top: 8.h),
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF001D2B),
                                    border: Border.all(
                                      color: Color(0xFF0D8DA3),
                                      width: 1, // border thickness
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.r),
                                      topRight: Radius.circular(12.r),
                                      bottomRight: Radius.circular(12.r),
                                      bottomLeft: Radius.circular(12.r),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("SubTotal", style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                                          Text("600.000 COP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF0D8DA3),
                                          minimumSize: Size(0.3.sw, 60.h),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            step = 1;
                                          });
                                        },
                                        child: Text("Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                              : step == 1
                              ? Container(
                            height: cartDetails == true ? 0.6.sh : 0,
                            width: 0.2.sw,
                            decoration: BoxDecoration(
                              color: const Color(0xFF001D2B).withOpacity(0.7),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.w),
                                      child: Text(
                                        "Informacion para envio",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.grey.shade400,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),

                                // Form fields
                                Expanded(
                                  child: Column(
                                    children: [
                                      // Pais
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.w),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Pais", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade300)),
                                            TextFormField(
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h), // height control
                                                border:
                                                OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.grey)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.lightBlue)),
                                                enabledBorder:
                                                OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.grey)),
                                                hintText: 'Pais',
                                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp, fontFamily: 'Tajawal'),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please fill it';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Ciudad
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.w),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Ciudad", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade300)),
                                            TextFormField(
                                              keyboardType: TextInputType.text,
                                              decoration: InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
                                                border:
                                                OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.grey)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.lightBlue)),
                                                enabledBorder:
                                                OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.grey)),
                                                hintText: 'Ciudad',
                                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp, fontFamily: 'Tajawal'),
                                              ),
                                              validator: (value) {
                                                if (value == null || value.isEmpty) {
                                                  return 'Please fill it';
                                                }
                                                return null;
                                              },
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Direccion (Dropdown)
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.w),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Direccion", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade300)),
                                            Theme(
                                              data: Theme.of(context).copyWith(
                                                highlightColor: Colors.transparent,
                                                focusColor: Colors.transparent,
                                                hoverColor: Colors.transparent,
                                              ),
                                              child: DropdownButtonFormField<String>(
                                                dropdownColor: Colors.white,
                                                style: TextStyle(color: Colors.black, fontSize: 14.sp, fontFamily: 'Tajawal'),
                                                decoration: InputDecoration(
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
                                                  border:
                                                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.grey)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.lightBlue)),
                                                  enabledBorder:
                                                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.grey)),
                                                  hintText: 'Direccions',
                                                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp, fontFamily: 'Tajawal'),
                                                ),
                                                items: ["Madrid", "Barcelona", "Valencia", "Sevilla"]
                                                    .map((city) => DropdownMenuItem<String>(
                                                  value: city,
                                                  child: Text(city, style: TextStyle(color: Colors.black)),
                                                ))
                                                    .toList(),
                                                onChanged: (value) {},
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please select a city';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),

                                      // Detalles
                                      Container(
                                        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.w),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Detalles (opcional)", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade300)),
                                            TextFormField(
                                              keyboardType: TextInputType.multiline,
                                              minLines: 3,
                                              maxLines: null,
                                              decoration: InputDecoration(
                                                fillColor: Colors.white,
                                                filled: true,
                                                contentPadding: EdgeInsets.all(14.w),
                                                border:
                                                OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.grey)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.lightBlue)),
                                                enabledBorder:
                                                OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.grey)),
                                                hintText: 'Detalles',
                                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp, fontFamily: 'Tajawal'),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Subtotal + Checkout
                                Container(
                                  height: 120.h,
                                  margin: EdgeInsets.only(top: 8.h),
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF001D2B),
                                    border: Border.all(color: const Color(0xFF0D8DA3), width: 1),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("SubTotal", style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                                          Text("600.000 COP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: const Color(0xFF0D8DA3),
                                          minimumSize: Size(0.3.sw, 60.h),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            step = 2;
                                          });
                                        },
                                        child: Text("Continuar con Checkout", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                              : step == 2
                              ? Container(
                            height: cartDetails == true ? 0.6.sh : 0,
                            width: 0.2.sw,
                            decoration: BoxDecoration(color: const Color(0xFF001D2B).withOpacity(0.7), borderRadius: BorderRadius.circular(12.r)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Header
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.w),
                                      child: Row(
                                        children: [
                                          Text(
                                            "Carrito de compras  ",
                                            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade400),
                                          ),
                                          Icon(
                                            Icons.credit_card,
                                            color: Colors.grey.shade400,
                                            size: 16.sp,
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12.h),

                                // Cart items
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.w),

                                    child: Column(
                                      children: [
                                        Container(
                                          height: 220.h,
                                          width: double.infinity,
                                          color: Colors.lightBlue,
                                          child: Center(
                                            child: Text("Add card image here"),
                                          ),
                                        ),
                                        SizedBox(height: 10.h,),

                                        Container(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Numero de tajeta", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade300)),
                                              TextFormField(
                                                keyboardType: TextInputType.text,
                                                decoration: InputDecoration(
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h), // height control
                                                  border:
                                                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.grey)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.lightBlue)),
                                                  enabledBorder:
                                                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.grey)),
                                                  hintText: 'Numero de tajeta',
                                                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp, fontFamily: 'Tajawal'),
                                                ),
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please fill it';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10.h,),

                                        Container(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text("Nombre del dueno", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade300)),
                                              TextFormField(
                                                keyboardType: TextInputType.text,
                                                decoration: InputDecoration(
                                                  fillColor: Colors.white,
                                                  filled: true,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h), // height control
                                                  border:
                                                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.grey)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.lightBlue)),
                                                  enabledBorder:
                                                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.sp), borderSide: const BorderSide(color: Colors.grey)),
                                                  hintText: 'Escribe aquí la fecha de vencimiento',
                                                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp, fontFamily: 'Tajawal'),
                                                ),
                                                validator: (value) {
                                                  if (value == null || value.isEmpty) {
                                                    return 'Please fill it';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(height: 10.h,),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,

                                                children: [
                                                  Text("Fecha de vencimiento", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade300)),


                                                  TextFormField(
                                                    keyboardType: TextInputType.number,
                                                    inputFormatters: [
                                                      FilteringTextInputFormatter.digitsOnly,
                                                      LengthLimitingTextInputFormatter(4),
                                                      ExpiryDateTextFormatter(),
                                                    ],
                                                    decoration: InputDecoration(
                                                      fillColor: Colors.white,
                                                      filled: true,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
                                                      border: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8.sp),
                                                        borderSide: const BorderSide(color: Colors.grey),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8.sp),
                                                        borderSide: const BorderSide(color: Colors.lightBlue),
                                                      ),
                                                      enabledBorder: OutlineInputBorder(
                                                        borderRadius: BorderRadius.circular(8.sp),
                                                        borderSide: const BorderSide(color: Colors.grey),
                                                      ),
                                                      hintText: "Escribe la fecha",
                                                      hintStyle: TextStyle(
                                                        color: Colors.grey,
                                                        fontSize: 14.sp,
                                                        fontFamily: 'Tajawal',
                                                      ),
                                                    ),
                                                  ),

                                                ],
                                              ),
                                            ),
                                            SizedBox(width: 30.w,),
                                            Expanded(
                                              flex: 1,
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,

                                                children: [
                                                  Text("CCV", style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey.shade300)),

                                                  TextFormField(
                                                    keyboardType: TextInputType.number,
                                                    decoration: InputDecoration(
                                                      fillColor: Colors.white,
                                                      filled: true,
                                                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 18.h),
                                                      border: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(8.sp),
                                                          borderSide: const BorderSide(color: Colors.grey)),
                                                      focusedBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(8.sp),
                                                          borderSide: const BorderSide(color: Colors.lightBlue)),
                                                      enabledBorder: OutlineInputBorder(
                                                          borderRadius: BorderRadius.circular(8.sp),
                                                          borderSide: const BorderSide(color: Colors.grey)),
                                                      hintText: 'Escribe el código',
                                                      hintStyle: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 14.sp,
                                                          fontFamily: 'Tajawal'),
                                                    ),
                                                    validator: (value) {
                                                      if (value == null || value.isEmpty) {
                                                        return 'Required';
                                                      }
                                                      return null;
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        )

                                      ],

                                    ),
                                  ),
                                ),

                                // Subtotal + Checkout
                                Container(
                                  height: 120.h,
                                  margin: EdgeInsets.only(top: 8.h),
                                  padding: EdgeInsets.all(12.w),
                                  decoration: BoxDecoration(
                                    color: Color(0xFF001D2B),
                                    border: Border.all(
                                      color: Color(0xFF0D8DA3),
                                      width: 1, // border thickness
                                    ),
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12.r),
                                      topRight: Radius.circular(12.r),
                                      bottomRight: Radius.circular(12.r),
                                      bottomLeft: Radius.circular(12.r),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text("SubTotal", style: TextStyle(color: Colors.white, fontSize: 13.sp, fontWeight: FontWeight.bold)),
                                          Text("600.000 COP", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                                        ],
                                      ),
                                      SizedBox(height: 10.h),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Color(0xFF0D8DA3),
                                          minimumSize: Size(0.3.sw, 60.h),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            step = 0;
                                          });
                                        },
                                        child: Text("Confirmar compra", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                              : SizedBox.shrink()
                        ],
                      ),
                    ),
                  ),
                  Container(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 60.h,
                          width: double.infinity,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Container(
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    // Your cart container
                                    Container(
                                      decoration: BoxDecoration(
                                        color: cartDetails == false
                                            ? const Color(0xFF001D2B).withOpacity(0.7)
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12.r),
                                      ),
                                      child: IconButton(
                                        onPressed: () {
                                          setState(() {
                                            cartDetails = true;
                                          });
                                        },
                                        icon: cartDetails == false
                                            ? Icon(
                                          Icons.shopping_cart,
                                          size: 30.sp,
                                          color: cartAdded == true ? Colors.white : Colors.grey,
                                        )
                                            : GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              cartDetails = false;
                                            });
                                          },
                                          child: Icon(
                                            Icons.close_outlined,
                                            size: 30.sp,
                                          ),
                                        ),
                                      ),
                                    ),

                                    cartAdded  == true && cartDetails == false?
                                    Positioned(
                                      right: -8, // adjust to fit exactly on corner
                                      top: -8,
                                      child: Container(
                                        padding: EdgeInsets.all(6.w),
                                        decoration: const BoxDecoration(
                                          color: Colors.lightBlue,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Text(
                                          "1", // cart item count here
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ):SizedBox.shrink()
                                  ],
                                ),
                              )

                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              flex: 2,
              child: Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 20),
                      height: 400.h,
                      width: 400.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).focusColor, width: 1),
                        borderRadius: BorderRadius.circular(14),
                        color: Colors.white,
                      ),
                      child: Column(
                        children: [
                          Container(
                            child: Center(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: const [
                                  Text("    Kelly Chat   ", style: TextStyle(color: Colors.white)),
                                  Icon(Icons.messenger, color: Colors.white),
                                ],
                              ),
                            ),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12),
                                topRight: Radius.circular(12),
                              ),
                              color: Theme.of(context).focusColor,
                            ),
                            height: 40.h,
                          ),
                          Expanded(
                            child: StreamBuilder<QuerySnapshot>(
                              stream: FirebaseFirestore.instance
                                  .collection('rooms')
                                  .doc("${widget.roomID}_$_userName")
                                  .collection('messages')
                                  .orderBy('timestamp', descending: true)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const Center(child: CircularProgressIndicator());
                                }

                                final docs = snapshot.data!.docs;

                                return ListView.builder(
                                  reverse: true,
                                  itemCount: docs.length,
                                  itemBuilder: (context, index) {
                                    final data = docs[index].data() as Map<String, dynamic>;
                                    return Container(
                                      margin: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                                      child: Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(6),
                                          border: Border.all(color: Colors.grey.shade300, width: 1),
                                        ),
                                        child: Container(
                                          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 15.h),
                                          child: Row(
                                          children: [
                                            Icon(Icons.person, size: 28.sp),
                                            Column(
                                              children: [
                                                Text(
                                                  data['userName'] ?? '',
                                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                                                ),
                                                Text(
                                                  data['text'] ?? '',
                                                  style: TextStyle(fontSize: 14.sp, color: Colors.grey[700]),
                                                )
                                              ],
                                            )

                                          ],),
                                        )
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 12.w),
                      child: Row(
                        children: [
                          SizedBox(width: 10.w),
                          SizedBox(
                            width: 250.w,
                            height: 50.h,
                            child: TextField(
                              controller: _chatController,
                              style: const TextStyle(fontSize: 16),
                              decoration: const InputDecoration(
                                hintText: 'Type a message...',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                              ),
                              onSubmitted: (_) => sendMessage(),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Container(
                            height: 50.h,
                            width: 50.w,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: const Color(0xFF15BECE),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.send, size: 28),
                              onPressed: (){
                                sendMessage();
                              },
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage() async {
    if (_userName == null) {
      String? enteredName = await _askForName();
      if (enteredName == null || enteredName.trim().isEmpty) return;
      setState(() {
        _userName = enteredName.trim();
      });
    }

    if (_chatController.text.trim().isEmpty) return;

    await FirebaseFirestore.instance.collection('rooms').doc("${widget.roomID}_$_userName").collection('messages').add({
      'userName': _userName,
      'text': _chatController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });

    _chatController.clear();
  }

  Future<String?> _askForName() async {
    TextEditingController nameController = TextEditingController();

    return await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: const [
              SizedBox(width: 8),
              Text("Enter Your Name"),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Please provide your name so others know who you are in the chat.",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  hintText: "Your name",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
            ],
          ),
          actionsPadding: const EdgeInsets.only(right: 12, bottom: 8),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15BECE),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                if (nameController.text.trim().isNotEmpty) {
                  Navigator.of(context).pop(nameController.text.trim());
                }
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  "Continue",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<ZegoRoomLoginResult> loginRoom() async {
    final user = ZegoUser(widget.localUserID, widget.localUserName);
    final roomID = widget.roomID;
    ZegoRoomConfig roomConfig = ZegoRoomConfig.defaultConfig()..isUserStatusNotify = true;

    if (kIsWeb) {
      roomConfig.token = ZegoTokenUtils.generateToken(appID, serverSecret, widget.localUserID);
    }

    return ZegoExpressEngine.instance.loginRoom(roomID, user, config: roomConfig).then((loginRoomResult) {
      debugPrint('loginRoom: errorCode:${loginRoomResult.errorCode}');
      if (loginRoomResult.errorCode == 0 && widget.isHost) {
        startPreview();
        startPublish();
      } else if (loginRoomResult.errorCode != 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('loginRoom failed: ${loginRoomResult.errorCode}')),
        );
      }
      return loginRoomResult;
    });
  }

  Future<ZegoRoomLogoutResult> logoutRoom() async {
    stopPreview();
    stopPublish();
    return ZegoExpressEngine.instance.logoutRoom(widget.roomID);
  }

  void startListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, userList) {
      debugPrint('onRoomUserUpdate: $roomID ${updateType.name}');
    };

    ZegoExpressEngine.onRoomStreamUpdate = (roomID, updateType, streamList, extendedData) {
      debugPrint('onRoomStreamUpdate: $roomID $updateType');
      if (updateType == ZegoUpdateType.Add) {
        for (final stream in streamList) {
          startPlayStream(stream.streamID);
        }
      } else {
        for (final stream in streamList) {
          stopPlayStream(stream.streamID);
        }
      }
    };

    ZegoExpressEngine.onRoomStateUpdate = (roomID, state, errorCode, extendedData) {
      debugPrint('onRoomStateUpdate: $roomID ${state.name}');
    };

    ZegoExpressEngine.onPublisherStateUpdate = (streamID, state, errorCode, extendedData) {
      debugPrint('onPublisherStateUpdate: $streamID ${state.name}');
    };
  }

  void stopListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate = null;
    ZegoExpressEngine.onRoomStreamUpdate = null;
    ZegoExpressEngine.onRoomStateUpdate = null;
    ZegoExpressEngine.onPublisherStateUpdate = null;
  }

  Future<void> startPreview() async {
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      localViewID = viewID;
      ZegoCanvas previewCanvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoExpressEngine.instance.setVideoMirrorMode(ZegoVideoMirrorMode.BothMirror);
      ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
    }).then((canvasViewWidget) {
      setState(() => localView = canvasViewWidget);
    });
  }

  Future<void> stopPreview() async {
    ZegoExpressEngine.instance.stopPreview();
    if (localViewID != null) {
      await ZegoExpressEngine.instance.destroyCanvasView(localViewID!);
      setState(() {
        localViewID = null;
        localView = null;
      });
    }
  }

  Future<void> startPublish() async {
    String streamID = '${widget.roomID}_${widget.localUserID}_call';
    return ZegoExpressEngine.instance.startPublishingStream(streamID);
  }

  Future<void> stopPublish() async {
    return ZegoExpressEngine.instance.stopPublishingStream();
  }

  Future<void> startPlayStream(String streamID) async {
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      remoteViewID = viewID;
      ZegoCanvas canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
      ZegoPlayerConfig config = ZegoPlayerConfig.defaultConfig();
      config.resourceMode = ZegoStreamResourceMode.Default;
      ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas, config: config);
    }).then((canvasViewWidget) {
      setState(() => remoteView = canvasViewWidget);
    });
  }

  Future<void> stopPlayStream(String streamID) async {
    ZegoExpressEngine.instance.stopPlayingStream(streamID);
    if (remoteViewID != null) {
      ZegoExpressEngine.instance.destroyCanvasView(remoteViewID!);
      setState(() {
        remoteViewID = null;
        remoteView = null;
      });
    }
  }
}
class ExpiryDateTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text.replaceAll('/', '');

    if (text.length > 2) {
      text = text.substring(0, 2) + '/' + text.substring(2);
    }

    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

