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
  bool uploadStatus = false;
  GeneralProductData allProducts = GeneralProductData( ecommercePlatform: '', wooProducts: [], shopProducts: []);
  FirebaseFirestore _db = FirebaseFirestore.instance;
  double? titleMobile;
  double? primaryTextMobile;
  double? secondaryTextMobile;
  double? contentTextMobile;
  double? smallTextMobile;

  double? titleWeb;
  double? primaryTextWeb;
  double? secondaryTextWeb;
  double? contentTextWeb;
  double? smallTextWeb;

  @override
  void initState() {
    super.initState();
    getData();

  }

  @override
  Widget build(BuildContext context) {
    var screenSizeHeight = MediaQuery.of(context).size.height;
    var screenSizeWidth = MediaQuery.of(context).size.width;
    fontDeclaration(screenSizeHeight, screenSizeWidth);
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


  Users userInfo = Users(
      userUID: '',
      name: '',
      lastName: '',
      email: '',
      secundaryEmail: '',
      phoneNumber: '',
      nit: '',
      gender: '',
      profilePhoto: '',
      companiesID: [],
      role: '',
      status: '',
      isCompleteProfile: false);

  CompanyData companyInfo = CompanyData(
      createdBy: '',
      companyID: '',
      ecommerceID: '',
      streamPlatformID: '',
      name: '',
      alias: '',
      category: '',
      storePlatform: '',
      webSite: '',
      phoneNumber: '',
      email: '',
      status: '',
      isAvailable: false,
      photo: '',
      members: [],
      consumerKey: '',
      consumerSecret: '',
      accessToken: '');

  List<CompanyData> companies = [];

  //Get WooCommerceProducts
  Future<void> getWooCommerceProducts() async {
    dialogoCarga('Actualizando información...');
    String url = "${companyInfo.webSite}/wp-json/wc/v3/products?"
        "consumer_key=${companyInfo.consumerKey}&"
        "consumer_secret=${companyInfo.consumerSecret}";

    try {
      final Dio dio = Dio()
        ..options.connectTimeout = Duration(milliseconds: 30000)
        ..options.receiveTimeout = Duration(milliseconds: 30000)
        ..options.headers = {
          'Accept': 'application/json',
        };

      print("call getWooCommerceProducts: $url");

      final response = await dio.get(url);

      if (response.statusCode==200) {
        List data=response.data;
        for (var productData in data) {
          var product = ShopifyProductModel.fromWooCommerceJson(productData);

          allProducts.ecommercePlatform = 'Shopify';

          setState(() {
            final index = allProducts.shopProducts?.indexWhere((element) => element.id == product.id);
            if (index != null && index >= 0) {
              allProducts.shopProducts?[index] = product;
            } else {
              allProducts.shopProducts?.add(product);
            }
          });
        }
      } else {
        // print('Error: ${response.statusCode} - ${response.statusMessage}');
      }
    } catch (e) {
      if (e is DioError) {
        print('Dio error: ${e.message}');
        if (e.response != null) {
          print('Dio error response: ${e.response?.data}');
        } else {
          print('Dio error without response.');
        }
      } else {
        print('Unexpected error: $e');
      }
    }finally{
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }
  }


  //Get  ShopifyProducts
  // Future<void> getShopifyProducts(void Function(void Function()) modalState) async {
  //
  //   dialogoCarga('Actualizando información...');
  //   String url = "${companyInfo.webSite}/admin/api/2023-01/products.json";
  //   String token = companyInfo.accessToken ?? "";
  //
  //   Uri postURL = Uri.parse('$STRIPE_URL?endpoint=$url&token=$token');
  //
  //   try {
  //     print("Call post $postURL");
  //     final response = await http.post(postURL);
  //     log("Response"+response.body);
  //
  //     if (response.body != 'error') {
  //       var data = jsonDecode(response.body);
  //       List shopProducts = data['data']['products'];
  //
  //       for (var productData in shopProducts) {
  //         var product = ShopifyProductModel.fromJson(productData);
  //         allProducts.ecommercePlatform = 'Shopify';
  //
  //         modalState(() {
  //           final index = allProducts.shopProducts?.indexWhere((element) => element.id == product.id);
  //           if (index != null && index >= 0) {
  //             allProducts.shopProducts?[index] = product;
  //           } else {
  //             allProducts.shopProducts?.add(product);
  //           }
  //         });
  //         modalState(() { });
  //       }
  //     }
  //   } catch (e) {
  //     // Handle error
  //   }finally{
  //     Navigator.of(context, rootNavigator: true).pop('dialog');
  //   }
  // }

  Future<void> getShopifyProducts(void Function(void Function()) modalState) async {
    dialogoCarga('Actualizando información...');

    String url = "${companyInfo.webSite}/admin/api/2023-01/products.json";
    String token = companyInfo.accessToken ?? "";

    try {
      final Uri apiUrl = Uri.parse(
        "https://waseem-proxy-api-production.up.railway.app/fetch-store-data",
      );

      print("talha----Calling proxy: $apiUrl");

      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "url": url,
          "accessToken": token,
        }),
      );

      print("talha----Response: ${response.body}");

      if (response.statusCode == 200 && response.body != 'error') {
        var data = jsonDecode(response.body);
        List shopProducts = data['products'] ?? [];

        if (shopProducts.isNotEmpty) {
          // Ensure non-null list globally
          allProducts.shopProducts ??= [];

          for (var productData in shopProducts) {
            var product = ShopifyProductModel.fromJson(productData);

            final index = allProducts.shopProducts?.indexWhere((element) => element.id == product.id) ?? -1;
            if (index >= 0) {
              allProducts.shopProducts![index] = product; // Update existing
            } else {
              allProducts.shopProducts?.add(product);     // Add new
            }
          }

          modalState(() {
            allProducts.ecommercePlatform = 'Shopify';
            // allProducts.shopProducts = [];
          });
        } else {
          print("talha----No products found in Shopify response");
        }
      } else {
        print("talha----Error: ${response.statusCode}");
      }
    } catch (e) {
      print("talha----Error fetching Shopify products: $e");
    } finally {
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }
  }

  Widget productShowWidget(int index, double screenSizeWidth, double screenSizeHeight) {
    List<ShopifyProductModel> products = allProducts.shopProducts ?? [];
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

  fontDeclaration(screenSizeHeight, screenSizeWidth) {
    titleMobile = screenSizeWidth * 0.055;
    primaryTextMobile = screenSizeWidth * 0.042;
    secondaryTextMobile = screenSizeWidth * 0.036;
    contentTextMobile = screenSizeWidth * 0.03;
    smallTextMobile = screenSizeWidth * 0.026;

    titleWeb = screenSizeHeight * 0.05;
    primaryTextWeb = screenSizeHeight * 0.036;
    secondaryTextWeb = screenSizeHeight * 0.026;
    contentTextWeb = screenSizeHeight * 0.02;
    smallTextWeb = screenSizeHeight * 0.016;
  }
  void dialogoCarga(String title) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: () {
              Future<bool> avoidError = false as Future<bool>;
              return avoidError;
            },
            child: CupertinoAlertDialog(
                title: Text(title),
                content: Column(
                  children: <Widget>[
                    Container(
                      height: 3,
                    ),
                    Text('Esto puede tardar unos segundos'),
                    Container(
                      height: 10,
                    ),
                    CupertinoActivityIndicator()
                  ],
                )));
      },
    );
  }

  Widget showProductsView() {
    List<ShopifyProductModel>  products = allProducts.shopProducts??[];
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
                  fontSize: smallTextWeb,
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


  Future<void> validateStore(modalState) async{
    if (companyInfo.storePlatform == 'WooCommerce') {
      await getWooCommerceProducts();
    } else if (companyInfo.storePlatform == 'Shopify') {
      await getShopifyProducts(modalState);
    }
  }

  Future<void> getData() async {

    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Handle the case when the user is not signed in
      // signOut();
      return;
    }

    var userSnapshot = _db.collection('users').doc(user.uid).snapshots();

    userSnapshot.listen((userEvent) async {
      if (!userEvent.exists) {
        // Handle the case when user data does not exist
        // signOut();
        return;
      }

      Users userInfo = Users.fromMap(userEvent.data()!);
      companies.clear();

      if (userInfo.companiesID?.isNotEmpty ?? false) {
        for (var companyID in userInfo.companiesID!) {
          var companySnapshot = _db.collection('companies').doc(companyID).snapshots();

          companySnapshot.listen((event) {

            if (!event.exists) return;

            CompanyData companyInfo = CompanyData.fromMap(event.data()!);
            _updateCompaniesList(companyInfo);

            setState(() {
              this.userInfo = userInfo;
              this.companyInfo = companies.first;
              print("companyInfo.consumerKey---- ${companyInfo.consumerKey}");
              print("companyInfo.consumerSecret---- ${companyInfo.consumerSecret}");
              if ((companyInfo.consumerKey?.isNotEmpty ?? false) && (companyInfo.consumerSecret?.isNotEmpty ?? false)) {
                validateStore(setState);
              }
            });
          });
        }
      }
    });
  }

  void _updateCompaniesList(CompanyData companyInfo) {
    final index = companies.indexWhere((element) => element.companyID == companyInfo.companyID);

    if (index >= 0) {
      companies[index] = companyInfo;
    } else {
      companies.add(companyInfo);
    }
  }


  CreateLiveStreamUrlController createLiveStreamUrlController = Get.put(CreateLiveStreamUrlController());
  final List<ShopifyProduct> hardcodedProducts = [ // for now use dummy products because backend is not working
    ShopifyProduct(
      id: 8115812925611,
      title: "100 💎",
      imageUrl: "https://cdn.shopify.com/s/files/1/0668/5805/7905/files/3.png?v=1726441027",
      price: "1445.00",
    ),
    ShopifyProduct(
      id: 8115812925612,
      title: "1,000 💎",
      imageUrl: "https://cdn.shopify.com/s/files/1/0668/5805/7905/files/3.png?v=1726441027",
      price: "25.00",
    ),
    ShopifyProduct(
      id: 8115812925613,
      title: "2,000 💎",
      imageUrl: "https://cdn.shopify.com/s/files/1/0668/5805/7905/files/3.png?v=1726441027",
      price: "77.00",
    ),
    ShopifyProduct(
      id: 8115812925614,
      title: "4,000 💎",
      imageUrl: "https://cdn.shopify.com/s/files/1/0668/5805/7905/files/3.png?v=1726441027",
      price: "53.00",
    )
  ];

  void saveNewStreamData() async {

    var streamID = Uuid().v4();
    var roomID = Uuid().v4();

    StreamsData saveStream = StreamsData(
        streamID: streamID,
        roomID: roomID,
        createdBy: createLiveStreamUrlController.userInfo.userUID,
        businessID: createLiveStreamUrlController.companyInfo.companyID,
        status: 'En espera',
        ecommercePlatform: createLiveStreamUrlController.companyInfo.storePlatform);

    var refCompany = createLiveStreamUrlController.db.collection('streams').doc(streamID);

    refCompany
        .set(saveStream.createStream(createLiveStreamUrlController.productsSelected))
        .whenComplete(() async {
      final copyUrl = html.window.location.href + "#/liveStream/" + "${saveStream.streamID ?? ''}";
      print("** wk url: $copyUrl");
      Clipboard.setData(ClipboardData(text: copyUrl)).then((_) {
        print("Text copied to clipboard!");
      });
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => CallPage(
            localUserID: createLiveStreamUrlController.userInfo.userUID,
            localUserName: createLiveStreamUrlController.companyInfo.name,
            roomID: roomID,
            stream: saveStream,
          )));
    }).catchError((error) {
    });
  }

}
