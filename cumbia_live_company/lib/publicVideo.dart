import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cumbia_live_company/common/color_constants.dart';
import 'package:cumbia_live_company/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import 'Models/Shopify/shopify_product_model.dart';
import 'Models/Structs.dart';
import 'Models/WooCommerce/woo_commerce_product_model.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoId;

  VideoPlayerScreen({required this.videoId});

  @override
  _VideoPlayerScreenState createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {


  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;

  var _showImageAndButton = false;
  var products = [];
  var product_image = null;
  var product_name = null;
  var product_price = null;
  var product_id = null;
  //cart
  String companyId="";
  String storePlatform="";
  String webSite="";
  bool showCartView = false;
  List productsInCart = [];
  bool showProductView = false;
  FirebaseFirestore _db = FirebaseFirestore.instance;
  PageController controller = PageController(initialPage: 0, );
  int currentProduct = 0;

  @override
  void initState() {
    super.initState();
    _fetchVideoUrl();
  }

  void _fetchVideoUrl() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('tbl_uploaded_videos')
          .doc(widget.videoId) // Document ID
          .get();

      if (documentSnapshot.exists) {
        String videoUrl = documentSnapshot.get('video_path');
        companyId = documentSnapshot.get('company_id')[0].toString();
        storePlatform = documentSnapshot.get('storePlatform');
        webSite = documentSnapshot.get('webSite');
        products = documentSnapshot.get('products');
        await _initializeVideoPlayer(videoUrl);
      } else {
        print('Document does not exist');
      }
    } catch (error) {
      print('Error fetching video URL: $error');
    }
  }

  Future<void> _initializeVideoPlayer(String videoUrl) async {

    try {
      setState(() {
        loading = true;
      });
      _videoPlayerController = VideoPlayerController.networkUrl(Uri.parse(videoUrl),formatHint: VideoFormat.dash);
      await _videoPlayerController.initialize();
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        aspectRatio: _videoPlayerController.value.aspectRatio,
        autoPlay: false,
        looping: true,
      );
      _videoPlayerController.addListener(_videoPlayerListener);
      setState(() {
        loading = false;
      });

    } catch (error) {

      print("Error initializing video player: $error");
      setState(() {
        loading = false;
      });

    }
  }

  void _videoPlayerListener() {
   try
   {
    Duration currentTime = _videoPlayerController.value.position;
    bool productFound = false;
    for (Map<dynamic, dynamic> product in products) {
      Duration fromTime = _convertTimeStringToDuration(product['from']);
      Duration toTime = _convertTimeStringToDuration(product['to']);


      if (currentTime >= fromTime && currentTime <= toTime) {
        setState(() {
          _showImageAndButton = true;
          product_image = product["image"];
          product_name = product["title"];
          product_price = product["price"];
          product_id = product["id"];
        });
        productFound = true;
        break; // Exit loop once a product is found
      }
      else{
        setState(() {
          product_image = "";
          product_name = "";
          product_price = "";
          product_id = "";
        });
      }
    }

    // If no product's time range matches the current time, hide the image
    if (!productFound) {
      setState(() {
        _showImageAndButton = false;
      });
    }
   }catch(e){
     print("print exception:$e");
   }

  }

  Duration _convertTimeStringToDuration(String timeString) {
    List<String> timeComponents = timeString.split(':');
    int minutes = int.parse(timeComponents[0]);
    int seconds = int.parse(timeComponents[1]);
    return Duration(minutes: minutes, seconds: seconds);
  }

  Future<CompanyData?> getCompanyData() async {
    var com = await _db.collection('companies').doc(companyId).get();
    if (com.exists) {
      CompanyData str = CompanyData.fromMap(com.data()!);
      return str;
    } else {
      return null;
    }
  }


  bool loading=true;
  @override
  Widget build(BuildContext context) {

    var screenSizeHeight = MediaQuery.of(context).size.height;
    var screenSizeWidth = MediaQuery.of(context).size.width;
    var videoWidth = screenSizeWidth * 0.9;
    var videoHeight = videoWidth / 1.5;

    bool mobile=screenSizeHeight>screenSizeWidth?true:false;

    Future<String> generateURLToCart() async {

      if (productsInCart.isEmpty) {
        print('Cart is empty');
        return '';
      }

      // Map to keep track of product IDs and their quantities
      Map<String, int> productMap = {};

      // Count product quantities
      for (var product in productsInCart) {
        String productId = product['variant_id'].toString();
        if (productMap.containsKey(productId)) {
          productMap[productId] = productMap[productId]! + 1; // Increment quantity
        } else {
          productMap[productId] = 1; // Initialize quantity
        }
      }

      String fragmentIDS;
      if(storePlatform=="Shopify"){
        // Constructing the fragment with product IDs and quantities
         fragmentIDS = productMap.entries.map((entry) => '${entry.key}:${entry.value}').join(',');
      }else{
        fragmentIDS = productMap.entries.map((entry) => 'add-to-cart=${entry.key}&quantity=${entry.value}').join('&');
        fragmentIDS = "?$fragmentIDS";

      }

      print(webSite);
      String baseUrl =webSite;
      // Constructing the URL with product IDs and quantities
      String url = '$baseUrl/cart/$fragmentIDS';

      return url;
    }

    bool last=false;

    addToCartDialog(screenSizeWidth, screenSizeHeight) async {
      showAnimatedDialog(
        context: context,
        barrierColor: Colors.transparent,
        alignment: Alignment.center,
        builder: (BuildContext context) {
          return CustomDialogWidget(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.03))
              ),
              backgroundColor: Theme.of(context).primaryColorDark.withOpacity(0.65),
              content: SizedBox(
                width: screenSizeWidth * 0.1,
                height: screenSizeWidth * 0.1,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.02)),
                  ),
                  child: ListView(
                    padding: EdgeInsets.only(top: 0, left: screenSizeWidth * 0.03, right: screenSizeWidth * 0.03,),
                    shrinkWrap: true,
                    physics: ScrollPhysics(),
                    children: [
                      Text('Producto añadido\nal carrito', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                          fontSize: 14, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                    ],
                  ),
                ),
              )
          );
        },
        animationType: DialogTransitionType.fade,
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 500),
      );
      await Future.delayed(
          const Duration(milliseconds: 1500));
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }

    Widget cellsProducts(index, screenSizeWidth, screenSizeHeight,bool mobile){
      return Container(

        margin: EdgeInsets.only(top: screenSizeHeight * 0.1),
        padding: EdgeInsets.only(right: screenSizeWidth * 0.045, top: screenSizeHeight * 0.03, bottom: screenSizeHeight * 0.03),
        child: Container(
            padding: EdgeInsets.all(screenSizeHeight * 0.02),
            alignment: Alignment.center,
            height:  screenSizeHeight * 0.15,
            width: screenSizeHeight * 0.5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Theme.of(context).primaryColorDark.withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.all(Radius.circular(5)),
                      child: Container(
                        height: screenSizeHeight * 0.18,
                        width: screenSizeHeight * 0.18,
                        decoration: BoxDecoration(
                            image: products[index]["image"] == '' ? DecorationImage(
                              image: AssetImage('assets/img/placeholder.png'),
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                            ):DecorationImage(
                              image: NetworkImage(products[index]["image"]??""),
                              alignment: Alignment.center,
                              fit: BoxFit.cover,
                            )
                        ),
                      ),
                    ),
                    Container(width: screenSizeWidth * 0.01,),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('${products[index]['title']}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                              fontSize: screenSizeHeight * 0.018, fontWeight: FontWeight.w400), maxLines: 2,textAlign: TextAlign.left,),
                          Row(
                            children: [
                              Spacer(),
                              GestureDetector(

                                  onTap:(){
                                    setState(() {
                                      List<String> parts = "${products[index]['from']}".split(':');
                                      Duration duration = Duration(
                                        minutes: int.parse(parts[0]),
                                        seconds: int.parse(parts[1]),
                                      );
                                      _videoPlayerController.seekTo(duration);
                                    });
                                  },
                                  child: Image.asset("assets/img/icon.png",height: screenSizeHeight * 0.045,width: screenSizeHeight * 0.045,)
                              ),
                            ],
                          ),
                          // Text('${products[index]['id']}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                          //     fontSize: 10, fontWeight: FontWeight.w300), maxLines: 2, textAlign: TextAlign.left,),
                          Container(height: screenSizeHeight * 0.008,),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('\$${products[index]['price']}', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                  fontSize: screenSizeHeight * 0.018, fontWeight: FontWeight.w700), textAlign: TextAlign.left,),
                              Container(width: screenSizeWidth * 0.01,),
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    showProductView = false;
                                    currentProduct = 0;
                                    productsInCart.add(products[index]);
                                  });
                                  addToCartDialog(screenSizeWidth, screenSizeHeight);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: EdgeInsets.all(screenSizeHeight * 0.01),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).secondaryHeaderColor.withOpacity(0.4),
                                    borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01)),
                                  ),
                                  child: Icon(Icons.shopping_cart_rounded, color: context.background,size: screenSizeHeight * 0.02,),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                )
            )
        ),
      );
    }

    Widget cellsProductsBigSize(index, screenSizeWidth, screenSizeHeight){

      return Container(
        padding: EdgeInsets.only(right: screenSizeWidth * 0.045, top: screenSizeHeight * 0.03, bottom: screenSizeHeight * 0.03),
        child: Container(
            padding: EdgeInsets.all(screenSizeHeight * 0.02),
            alignment: Alignment.center,
            height:  screenSizeHeight * 0.15,
            width: screenSizeHeight * 0.55,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(5)),
              color: Theme.of(context).primaryColorDark.withOpacity(0.8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(5)),
                child: Column(
                  children: [
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          child: Container(
                            height: screenSizeHeight * 0.17,
                            width: screenSizeHeight * 0.17,
                            decoration: BoxDecoration(
                                image: products[index]["image"] == '' ? DecorationImage(
                                  image: AssetImage('assets/img/placeholder.png'),
                                  alignment: Alignment.center,
                                  fit: BoxFit.cover,
                                ):DecorationImage(
                                  image: NetworkImage(products[index]["image"]??""),
                                  alignment: Alignment.center,
                                  fit: BoxFit.cover,
                                )
                            ),
                          ),
                        ),
                        Container(width: screenSizeWidth * 0.01,),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text('${products[index]['title']}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                  fontSize: screenSizeWidth * 0.017, fontWeight: FontWeight.w400), maxLines: 2,textAlign: TextAlign.left,),

                              // Text('${products[index]['id']}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                              //     fontSize: 10, fontWeight: FontWeight.w300), maxLines: 2, textAlign: TextAlign.left,),
                              SizedBox(height: screenSizeHeight * 0.02,),
                              Row(
                                children: [
                                  Spacer(),
                                  GestureDetector(

                                      onTap:(){
                                        setState(() {
                                          List<String> parts = "${products[index]['from']}".split(':');
                                          Duration duration = Duration(
                                            minutes: int.parse(parts[0]),
                                            seconds: int.parse(parts[1]),
                                          );
                                          _videoPlayerController.seekTo(duration);
                                        });
                                      },
                                        child: Image.asset("assets/img/icon.png",height: screenSizeHeight * 0.05,width: screenSizeHeight * 0.05,)
                                      ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('\$${products[index]['price']}', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                            fontSize: screenSizeWidth * 0.014, fontWeight: FontWeight.w700), textAlign: TextAlign.left,),
                        Container(width: screenSizeWidth * 0.01,),
                        GestureDetector(
                          onTap: (){
                            setState(() {
                              showProductView = false;
                              currentProduct = 0;
                              productsInCart.add(products[index]);
                            });
                            addToCartDialog(screenSizeWidth, screenSizeHeight);
                          },
                          behavior: HitTestBehavior.opaque,
                          child:Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015,left: 10,right: 10),
                            decoration: BoxDecoration(
                                color: ColorConstants.primary,
                                borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                            ),
                            child: Text('Afiadir al carrlto', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                fontSize: screenSizeHeight * 0.013, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenSizeHeight * 0.005,),
                    Text('Producto 1 de 1', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                        fontSize: screenSizeHeight * 0.013, fontWeight: FontWeight.w400), maxLines: 2,textAlign: TextAlign.left,),
                  ],
                )
            )
        ),
      );
    }

    ScrollController _scrollController = ScrollController();
    return Scaffold(
      backgroundColor: Colors.white,
      body: loading?Center(child: CircularProgressIndicator()):Stack(
        children: [

          Container(
            child: Chewie( controller: _chewieController, ),
          ),
          Column(
            children: [
              Container(
                color: mobile?Colors.white:Colors.transparent,
                padding: EdgeInsets.only(top: videoHeight * 0.05, right: videoWidth * 0.05,
                    bottom: videoHeight * 0.05),
                alignment: Alignment.topRight,
                child: GestureDetector(
                    onTap: () async {
                      var url = await generateURLToCart();
                      if (url != null && url != '') {
                        Uri urlToPass = Uri.parse(url);
                        launchUrl(urlToPass);
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: SizedBox(
                        width: mobile?screenSizeWidth * 0.08:screenSizeWidth * 0.05,
                        height: mobile?screenSizeWidth * 0.08:screenSizeWidth * 0.05,
                        child: Badge(
                          alignment: AlignmentDirectional.center,
                          backgroundColor: Theme.of(context).primaryColor,
                          label: Text('${productsInCart.length}', style: TextStyle(color: Colors.white, fontSize: 14),),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorDark.withOpacity(0.4),
                              borderRadius: BorderRadius.all(Radius.circular(screenSizeWidth * 0.01)),
                            ),
                            child: Icon(Icons.shopping_cart_rounded, color: context.background,size: mobile?screenSizeWidth * 0.05:screenSizeWidth * 0.02,),
                          ),
                        )
                    )
                ),
              ),
              Spacer(),
              Container(
                padding: EdgeInsets.only(left: videoWidth * 0.03),
                height: mobile?(videoHeight * 0.35)*2:(videoHeight * 0.35),
                width: double.infinity,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.horizontal,
                  //todo lista de productos
                  itemCount:  products.length,
                  itemBuilder: (context, int index){
                    if (product_image==products[index]["image"]) {
                        if(index==0){
                        last=false;
                        _scrollController.animateTo(
                          0,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );
                      }else
                        if(mobile?index+1==products.length:index+2==products.length||index+1==products.length){
                          if(!last){
                            _scrollController.animateTo(
                              _scrollController.position.maxScrollExtent,
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                          last=true;
                        } else
                        {
                        _scrollController.animateTo(
                          mobile?videoWidth*0.75*index:videoWidth*0.375*index,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                        );

                      }
                      return cellsProductsBigSize(index, mobile?videoWidth*2:videoWidth, mobile?videoHeight*2:videoHeight);
                    } else {
                      return cellsProducts(index, mobile?videoWidth*2:videoWidth, mobile?videoHeight*2:videoHeight,mobile);
                    }
                  }
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

}
