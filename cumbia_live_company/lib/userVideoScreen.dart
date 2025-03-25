// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_animate/flutter_animate.dart';
// import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:zego_express_engine/zego_express_engine.dart';
//
// import 'Models/Shopify/shopify_product_model.dart';
// import 'Models/Stream/zegocloud_token.dart';
// import 'Models/Structs.dart';
// import 'Models/WooCommerce/woo_commerce_product_model.dart';
//
//
// class UserVideoScreen extends StatefulWidget {
//   const UserVideoScreen({Key? key,required this.stream});
//
//   final StreamsData stream;
//   @override
//   State<UserVideoScreen> createState() => _CallPageState();
// }
//
// class _CallPageState extends State<UserVideoScreen> {
//
//   double? titleMobile;
//   double? primaryTextMobile;
//   double? secondaryTextMobile;
//   double? contentTextMobile;
//   double? smallTextMobile;
//
//   double? titleWeb;
//   double? primaryTextWeb;
//   double? secondaryTextWeb;
//   double? contentTextWeb;
//   double? smallTextWeb;
//
//   fontDeclaration(screenSizeHeight, screenSizeWidth){
//     titleMobile = 24;
//     primaryTextMobile = 18;
//     secondaryTextMobile = 14;
//     contentTextMobile = 12;
//     smallTextMobile = 10;
//
//     titleWeb = 24;
//     primaryTextWeb = 18;
//     secondaryTextWeb = 14;
//     contentTextWeb = 12;
//     smallTextWeb = 10;
//   }
//
//   bool showProductView = false;
//   bool showCartView = false;
//
//   PageController controller = PageController(initialPage: 0, );
//   int currentProduct = 0;
//   //int totalProducts = 12;
//   List productsInCart = [];
//
//
//   Widget? localView;
//   int? localViewID;
//   Widget? remoteView;
//   int? remoteViewID;
//
//   String version = 'Unknown';
//
//   //var globalRoomID = '002';
//
//   // Apply AppID and AppSign from ZEGO
//   final int appID = 1871669861;
//
//   // Apply AppID and AppSign from ZEGO
//   final String appSign = '516426a1fac51a0bd16266d042ce8a85814a654fccbeb4fbda905cb3f3bfbd9f';
//
//   // Specify test environment
//   final bool isTestEnv = true;
//
//   // Specify a general scenario
//   final ZegoScenario scenario = ZegoScenario.Broadcast;
//
//   final String serverSecret = 'e4e772ea296ae5c3914f61e48b2db465';
//
//   String StreamingID = '';
//
//   FirebaseFirestore _db = FirebaseFirestore.instance;
//
//   @override
//   void initState() {
//     super.initState();
//
//     //StreamingID = '0001';
//
//
//     startListenEvent();
//
//     openRoomFunction();
//
//     getCompanyData();
//   }
//
//   Future<CompanyData?> getCompanyData() async {
//     var com = await _db.collection('companies').doc(widget.stream.businessID).get();
//     if (com.exists) {
//       CompanyData str = CompanyData.fromMap(com.data()!);
//       return str;
//     } else {
//       return null;
//     }
//   }
//
//
//   //Stream Methods
//   void startListenEvent() {
//     // Callback for updates on the status of other users in the room.
//     // Users can only receive callbacks when the isUserStatusNotify property of ZegoRoomConfig is set to `true` when logging in to the room (loginRoom).
//     ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, List<ZegoUser> userList) {
//       /*debugPrint(
//           'onRoomUserUpdate: roomID: $roomID, updateType: ${updateType.name}, userList: ${userList.map((e) => e.userID)}');*/
//     };
//     // Callback for updates on the status of the streams in the room.
//     ZegoExpressEngine.onRoomStreamUpdate = (roomID, updateType, List<ZegoStream> streamList, extendedData) {
//       debugPrint(
//           'onRoomStreamUpdate: roomID: $roomID, updateType: $updateType, streamList: ${streamList.map((e) => e.streamID)}, extendedData: $extendedData');
//       if (updateType == ZegoUpdateType.Add) {
//         for (final stream in streamList) {
//           StreamingID = stream.streamID;
//           print('Este es el valor de streamingID: $StreamingID');
//           startPlayStream(StreamingID);
//         }
//       } else {
//         for (final stream in streamList) {
//           print('Debe entrar aquí porque se debe detener el stream');
//           logoutRoom(stream.streamID);
//           //stopPlayStream(StreamingID);
//         }
//       }
//     };
//     // Callback for updates on the current user's room connection status.
//     ZegoExpressEngine.onRoomStateUpdate = (roomID, state, errorCode, extendedData) {
//       debugPrint(
//           'onRoomStateUpdate: roomID: $roomID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
//     };
//
//     // Callback for updates on the current user's stream publishing changes.
//     ZegoExpressEngine.onPublisherStateUpdate = (streamID, state, errorCode, extendedData) {
//       debugPrint(
//           'onPublisherStateUpdate: streamID: $streamID, state: ${state.name}, errorCode: $errorCode, extendedData: $extendedData');
//
//       startPlayStream(StreamingID);
//     };
//   }
//
//   void openRoomFunction() {
//
//     var fol = DateTime.now().millisecondsSinceEpoch;
//
//     var userID = 'User${fol.toString()}';
//     var localUsrName = 'Usuario ${fol.toString()}';
//     // The value of `userID` is generated locally and must be globally unique.
//     final user = ZegoUser(userID, localUsrName);
//
//     // The value of `roomID` is generated locally and must be globally unique.
//     final roomID = widget.stream.roomID;
//
//     // onRoomUserUpdate callback can be received when "isUserStatusNotify" parameter value is "true".
//     ZegoRoomConfig roomConfig = ZegoRoomConfig.defaultConfig()..isUserStatusNotify = true;
//
//     // var token = '';
//
//     if (kIsWeb) {
//       roomConfig.token = ZegoTokenUtils.generateToken(appID, serverSecret, userID);
//       //token = ZegoTokenUtils.generateToken(appID, serverSecret, widget.localUserID);
//     }
//     // log in to a room
//     // Users must log in to the same room to call each other.
//     ZegoExpressEngine.instance.loginRoom(roomID!, user, config: roomConfig).then((ZegoRoomLoginResult loginRoomResult) {
//       debugPrint('loginRoom: errorCode:${loginRoomResult.errorCode}, extendedData:${loginRoomResult.extendedData}');
//       if (loginRoomResult.errorCode == 0) {
//         print('Se inició sesión con éxito en roomID: ${roomID}');
//         //startPreview();
//         //startPublish();
//       } else {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text('loginRoom failed: ${loginRoomResult.errorCode}')));
//       }
//     });
//   }
//
//   Future<ZegoRoomLogoutResult> logoutRoom(String streamID) async {
//     stopPlayStream(streamID);
//
//     stopListenEvent();
//     //ZegoExpressEngine.destroyEngine();
//     return ZegoExpressEngine.instance.logoutRoom(widget.stream.roomID);
//   }
//
//   void stopListenEvent() {
//     ZegoExpressEngine.onRoomUserUpdate = null;
//     ZegoExpressEngine.onRoomStreamUpdate = null;
//     ZegoExpressEngine.onRoomStateUpdate = null;
//     ZegoExpressEngine.onPublisherStateUpdate = null;
//   }
//
//
//
//   Future<void> startPlayStream(String streamID) async {
//     // Start to play streams. Set the view for rendering the remote streams.
//     await ZegoExpressEngine.instance.createCanvasView((viewID) {
//       remoteViewID = viewID;
//       ZegoCanvas canvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
//       ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: canvas);
//     }).then((canvasViewWidget) {
//       setState(() => remoteView = canvasViewWidget);
//     });
//   }
//
//   Future<void> stopPlayStream(String streamID) async {
//     ZegoExpressEngine.instance.stopPlayingStream(streamID);
//     if (remoteViewID != null) {
//       ZegoExpressEngine.instance.destroyCanvasView(remoteViewID!);
//       setState(() {
//         remoteViewID = null;
//         remoteView = null;
//       });
//     }
//   }
//
//   Future<void> startPreview() async {
//
//     /*Map<String,dynamic> canvas = {
//       'view': 0,
//     };
//
//     int channel = 1345;
//
//     await ZegoExpressEngineWeb().startPreview(canvas, channel).then((canvasViewWidget) {
//       setState(() => localView = ZegoExpressEngineWeb().previewView);
//     });*/
//
//     //ZegoExpressEngine.instance.startPreview();
//     await ZegoExpressEngine.instance.createCanvasView((viewID) {
//       localViewID = viewID;
//       ZegoCanvas previewCanvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
//       ZegoExpressEngine.instance.startPreview(canvas: previewCanvas);
//     }).then((canvasViewWidget) {
//       setState(() => localView = canvasViewWidget);
//     });
//   }
//
//   Future<String> generateURLToCart() async {
//     String fragmentIDS = '';
//     if (productsInCart.isEmpty) {
//       print('Vacío y no manda a ningun lado');
//       return '';
//     }
//
//     String Function(dynamic) createFragment;
//
//     if (widget.stream.ecommercePlatform == 'WooCommerce') {
//       createFragment = (element) {
//         WooProduct prod = element;
//         return prod.variations?.isNotEmpty ?? false
//             ? '?add-to-cart=${prod.variations![0]}&quantity=1'
//             : '?add-to-cart=${prod.id}&quantity=1';
//       };
//     } else if (widget.stream.ecommercePlatform == 'Shopify') {
//       createFragment = (element) {
//         ShopifyProduct prod = element;
//         return '${prod.variants?[0].id}:1';
//       };
//     } else {
//       return '';
//     }
//
//     fragmentIDS = productsInCart.map((element) => createFragment(element)).join(widget.stream.ecommercePlatform == 'WooCommerce' ? '&' : ',');
//
//     var companyData = await getCompanyData();
//     String baseUrl = companyData?.webSite ?? '';
//
//     if (widget.stream.ecommercePlatform == 'WooCommerce') {
//       return '$baseUrl/$fragmentIDS';
//     } else if (widget.stream.ecommercePlatform == 'Shopify') {
//       return '$baseUrl/cart/$fragmentIDS';
//     } else {
//       return '';
//     }
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     var screenSizeHeight = MediaQuery.of(context).size.height;
//     var screenSizeWidth = MediaQuery.of(context).size.width;
//     var videoWidth = screenSizeWidth * 0.9;
//     var videoHeight = videoWidth / 1.5;
//     if (screenSizeHeight < videoHeight){
//       setState(() {
//         videoHeight = screenSizeHeight;
//         videoWidth = videoHeight * 1.5;
//       });
//     }
//     return Scaffold(
//       body: Container(
//         alignment: Alignment.center,
//         child: Stack(
//           alignment: Alignment.center,
//           children: [
//             SizedBox(
//               height: videoHeight,
//               width: videoWidth,
//               child: Stack(
//                 alignment: Alignment.bottomCenter,
//                 children: [
//                   remoteView ?? Container(
//                     color: Colors.black,
//                   ),
//                   Visibility(
//                     visible: showProductView == true ? false : showCartView == true ? false : true,
//                     child: Container(
//                       padding: EdgeInsets.only(left: videoWidth * 0.03),
//                       height: videoHeight * 0.25,
//                       width: videoWidth,
//                       child: ListView.builder(
//                         padding: EdgeInsets.only(top: 0),
//                         physics: ScrollPhysics(),
//                         shrinkWrap: true,
//                         scrollDirection: Axis.horizontal,
//                         //todo lista de productos
//                         itemCount: widget.stream.ecommercePlatform == 'WooCommerce' ? widget.stream.wooProducts.length == 0 ? 1 : widget.stream.wooProducts.length : widget.stream.ecommercePlatform == 'Shopify' ? widget.stream.shopProducts.length == 0 ? 1 : widget.stream.shopProducts.length : 0,
//                         itemBuilder: (context, int index) => cellsProducts(index, videoWidth, videoHeight),
//                       ),
//                     ),
//                   ),
//                   Visibility(
//                     //todo mostrar s hay productos en el carrito
//                     visible: productsInCart.length > 0 && showCartView == false ? true : false,
//                       child: Container(
//                         padding: EdgeInsets.only(top: videoHeight * 0.075, right: videoWidth * 0.03),
//                         alignment: Alignment.topRight,
//                         child: GestureDetector(
//                             onTap: () async {
//
//                               /*setState(() {
//                                 showCartView = true;
//                               });*/
//
//                               var url = await generateURLToCart();
//
//                               if (url != null && url != '') {
//                                 Uri urlToPass = Uri.parse(url);
//
//                                 launchUrl(urlToPass);
//                               }
//
//                               //print('URL: $url');
//                             },
//                             behavior: HitTestBehavior.opaque,
//                             child: SizedBox(
//                               width: videoHeight * 0.1,
//                               height: videoHeight * 0.1,
//                               child: Badge(
//                                 alignment: Alignment.center,
//                                 backgroundColor: Theme.of(context).primaryColor,
//                                 label: Text('${productsInCart.length}', style: TextStyle(color: Colors.white, fontSize: 14),),
//                                 child: Container(
//                                   alignment: Alignment.center,
//                                   decoration: BoxDecoration(
//                                     color: Theme.of(context).primaryColorDark.withOpacity(0.4),
//                                     borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01)),
//                                   ),
//                                   child: Icon(Icons.shopping_cart_rounded, color: context.background,),
//                                 ),
//                               )
//                             )
//                         ),
//                       )
//                   ),
//                 ],
//               ),
//             ),
//             Visibility(
//               visible: showProductView,
//               child: SizedBox(
//                 height: videoHeight,
//                 width: videoWidth,
//                 child: Animate(
//                     effects: [FadeEffect()],
//                     child: GestureDetector(
//                       behavior: HitTestBehavior.opaque,
//                       onTap: (){
//                         //todo modal alerta del producto
//                         setState(() {
//                           showProductView = false;
//                           currentProduct = 0;
//                         });
//                       },
//                       child: Container(
//                         padding: EdgeInsets.only(left: videoWidth * 0.05, bottom: videoHeight * 0.05),
//                         alignment: Alignment.bottomLeft,
//                         child: SizedBox(
//                           height: videoHeight * 0.55,
//                           width: videoWidth * 0.45,
//                           child: PageView.builder(
//                             allowImplicitScrolling: true,
//                             scrollDirection: Axis.horizontal,
//                             controller: controller,
//                             physics: ScrollPhysics (),
//                             onPageChanged: (position){
//                               setState(() {
//                                 currentProduct = position;
//                               });
//                             },
//                             itemCount: widget.stream.ecommercePlatform == 'WooCommerce' ? widget.stream.wooProducts.length == 0 ? 1 : widget.stream.wooProducts.length : widget.stream.ecommercePlatform == 'Shopify' ? widget.stream.shopProducts.length == 0 ? 1 : widget.stream.shopProducts.length : 0,
//                             itemBuilder: (context, index){
//                               if (widget.stream.ecommercePlatform == 'WooCommerce') {
//                                 return Container(
//                                   alignment: Alignment.center,
//                                   padding: EdgeInsets.only(top: videoHeight * 0.05, bottom: videoHeight * 0.05, left: videoWidth * 0.04, right:  videoWidth * 0.04),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.all(Radius.circular(5)),
//                                     color: Theme.of(context).primaryColorDark.withOpacity(0.8),
//                                   ),
//                                   child: ListView(
//                                     padding: EdgeInsets.only(top: 0),
//                                     physics: ScrollPhysics(),
//                                     shrinkWrap: true,
//                                     children: [
//                                       Row(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           SizedBox(
//                                             height: videoHeight * 0.2,
//                                             width: videoHeight * 0.2,
//                                             child: Container(
//                                               decoration: BoxDecoration(
//                                                 borderRadius: BorderRadius.all(Radius.circular(5)),
//                                                 color: Colors.grey,
//                                               ),
//                                               child: ClipRRect(
//                                                 borderRadius: BorderRadius.all(Radius.circular(5)),
//                                                 child: widget.stream.wooProducts[index].images?[0].src == null || widget.stream.wooProducts[index].images?[0].src == ''
//                                                     ?Image(
//                                                   // todo poner imagen del producto
//                                                   image:  AssetImage('assets/img/icon.png'),
//                                                   alignment: Alignment.center,
//                                                   fit: BoxFit.cover,
//                                                   loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//                                                     if (loadingProgress == null) return child;
//                                                     return Center(
//                                                       child: CircularProgressIndicator(
//                                                         value: loadingProgress.expectedTotalBytes != null
//                                                             ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                                                             : null,
//                                                       ),
//                                                     );
//                                                   },
//                                                 ):Image(
//                                                   // todo poner imagen del producto
//                                                   image:  NetworkImage(widget.stream.wooProducts[index].images?[0].src??""),
//                                                   alignment: Alignment.center,
//                                                   fit: BoxFit.cover,
//                                                   loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//                                                     if (loadingProgress == null) return child;
//                                                     return Center(
//                                                       child: CircularProgressIndicator(
//                                                         value: loadingProgress.expectedTotalBytes != null
//                                                             ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                                                             : null,
//                                                       ),
//                                                     );
//                                                   },
//                                                 ),
//                                               )
//                                             ),
//                                           ),
//                                           Container(width: videoWidth * 0.02,),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               mainAxisAlignment: MainAxisAlignment.start,
//                                               children: [
//                                                 Text('${widget.stream.wooProducts[index].name}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                                     fontSize: 14, fontWeight: FontWeight.w400), textAlign: TextAlign.left,),
//                                                 Container(height: videoHeight * 0.015,),
//                                                 Text('${widget.stream.wooProducts[index].categories?[0].name}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                                     fontSize: 12, fontWeight: FontWeight.w300), textAlign: TextAlign.left,),
//                                                 Container(height: videoHeight * 0.03,),
//                                               ],
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       Container(height: videoHeight * 0.05,),
//                                       Row(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             children: [
//                                               Text('Precio', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                                   fontSize: 14, fontWeight: FontWeight.w300), textAlign: TextAlign.left,),
//                                               Container(height: videoHeight * 0.01,),
//                                               Text('\$${widget.stream.wooProducts[index].price}', style: TextStyle(color: Theme.of(context).primaryColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                                   fontSize: 18, fontWeight: FontWeight.w700), textAlign: TextAlign.left,),
//                                             ],
//                                           ),
//                                           GestureDetector(
//                                             onTap: (){
//                                               setState(() {
//                                                 showProductView = false;
//                                                 currentProduct = 0;
//                                                 productsInCart.add(widget.stream.wooProducts[index]);
//                                               });
//                                               //todo añadir al carrito
//                                               addToCartDialog(videoWidth, videoHeight);
//                                             },
//                                             behavior: HitTestBehavior.opaque,
//                                             child: Container(
//                                               alignment: Alignment.center,
//                                               padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015, left: screenSizeWidth * 0.015, right: screenSizeWidth * 0.015),
//                                               decoration: BoxDecoration(
//                                                   color: Theme.of(context).secondaryHeaderColor,
//                                                   borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
//                                               ),
//                                               child: Text('Añadir al carrito', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                                   fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       Container(height: videoHeight * 0.05,),
//                                       //todo posición
//                                       Text('Producto ${currentProduct+1} de ${widget.stream.wooProducts.length}', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                           fontSize: 12, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
//                                     ],
//                                   ),
//                                 );
//                               } else if (widget.stream.ecommercePlatform == 'Shopify') {
//                                 return Container(
//                                   alignment: Alignment.center,
//                                   padding: EdgeInsets.only(top: videoHeight * 0.05, bottom: videoHeight * 0.05, left: videoWidth * 0.04, right:  videoWidth * 0.04),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.all(Radius.circular(5)),
//                                     color: Theme.of(context).primaryColorDark.withOpacity(0.8),
//                                   ),
//                                   child: ListView(
//                                     padding: EdgeInsets.only(top: 0),
//                                     physics: ScrollPhysics(),
//                                     shrinkWrap: true,
//                                     children: [
//                                       Row(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           SizedBox(
//                                             height: videoHeight * 0.2,
//                                             width: videoHeight * 0.2,
//                                             child: Container(
//                                               decoration: BoxDecoration(
//                                                 borderRadius: BorderRadius.all(Radius.circular(5)),
//                                                 color: Colors.grey,
//                                               ),
//                                               child: ClipRRect(
//                                                 borderRadius: BorderRadius.all(Radius.circular(5)),
//                                                 child: widget.stream.shopProducts[index].images!.isNotEmpty && widget.stream.shopProducts[index].images?[0].src != null && widget.stream.shopProducts[index].images?[0].src != ''
//                                                     ?Image(
//                                                   // todo poner imagen del producto
//                                                   image:  NetworkImage(widget.stream.shopProducts[index].images?[0].src??""),
//                                                   alignment: Alignment.center,
//                                                   fit: BoxFit.cover,
//                                                   loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//                                                     if (loadingProgress == null) return child;
//                                                     return Center(
//                                                       child: CircularProgressIndicator(
//                                                         value: loadingProgress.expectedTotalBytes != null
//                                                             ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                                                             : null,
//                                                       ),
//                                                     );
//                                                   },
//                                                 ):Image(
//                                                   // todo poner imagen del producto
//                                                   image:   AssetImage('assets/img/icon.png'),
//                                                   alignment: Alignment.center,
//                                                   fit: BoxFit.cover,
//                                                   loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//                                                     if (loadingProgress == null) return child;
//                                                     return Center(
//                                                       child: CircularProgressIndicator(
//                                                         value: loadingProgress.expectedTotalBytes != null
//                                                             ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                                                             : null,
//                                                       ),
//                                                     );
//                                                   },
//                                                 ),
//
//                                               )
//                                             ),
//                                           ),
//                                           Container(width: videoWidth * 0.02,),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               mainAxisAlignment: MainAxisAlignment.start,
//                                               children: [
//                                                 Text('${widget.stream.shopProducts[index].title}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                                     fontSize: 14, fontWeight: FontWeight.w400), textAlign: TextAlign.left,),
//                                                 Container(height: videoHeight * 0.015,),
//                                                 Text('${widget.stream.shopProducts[index].productType}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                                     fontSize: 12, fontWeight: FontWeight.w300), textAlign: TextAlign.left,),
//                                                 Container(height: videoHeight * 0.03,),
//                                               ],
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                       Container(height: videoHeight * 0.05,),
//                                       Row(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             children: [
//                                               Text('Precio', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                                   fontSize: 14, fontWeight: FontWeight.w300), textAlign: TextAlign.left,),
//                                               Container(height: videoHeight * 0.01,),
//                                               Text('\$${widget.stream.shopProducts[index].variants?[0].price}', style: TextStyle(color: Theme.of(context).primaryColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                                   fontSize: 18, fontWeight: FontWeight.w700), textAlign: TextAlign.left,),
//                                             ],
//                                           ),
//                                           GestureDetector(
//                                             onTap: (){
//                                               setState(() {
//                                                 showProductView = false;
//                                                 currentProduct = 0;
//                                                 productsInCart.add(widget.stream.shopProducts[index]);
//                                               });
//                                               //todo añadir al carrito
//                                               addToCartDialog(videoWidth, videoHeight);
//                                             },
//                                             behavior: HitTestBehavior.opaque,
//                                             child: Container(
//                                               alignment: Alignment.center,
//                                               padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015, left: screenSizeWidth * 0.015, right: screenSizeWidth * 0.015),
//                                               decoration: BoxDecoration(
//                                                   color: Theme.of(context).secondaryHeaderColor,
//                                                   borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
//                                               ),
//                                               child: Text('Añadir al carrito', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                                   fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       Container(height: videoHeight * 0.05,),
//                                       //todo posición
//                                       Text('Producto ${currentProduct+1} de ${widget.stream.shopProducts.length}', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                           fontSize: 12, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
//                                     ],
//                                   ),
//                                 );
//                               } else {
//                                 return Container(
//                                   alignment: Alignment.center,
//                                   padding: EdgeInsets.only(top: videoHeight * 0.05, bottom: videoHeight * 0.05, left: videoWidth * 0.04, right:  videoWidth * 0.04),
//                                   decoration: BoxDecoration(
//                                     borderRadius: BorderRadius.all(Radius.circular(5)),
//                                     color: Theme.of(context).primaryColorDark.withOpacity(0.8),
//                                   ),
//                                   child: ListView(
//                                     padding: EdgeInsets.only(top: 0),
//                                     physics: ScrollPhysics(),
//                                     shrinkWrap: true,
//                                     children: [
//                                       Row(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         mainAxisAlignment: MainAxisAlignment.center,
//                                         children: [
//                                           SizedBox(
//                                             height: videoHeight * 0.2,
//                                             width: videoHeight * 0.2,
//                                             child: Container(
//                                                 decoration: BoxDecoration(
//                                                   borderRadius: BorderRadius.all(Radius.circular(5)),
//                                                   color: Colors.grey,
//                                                 ),
//                                                 child: ClipRRect(
//                                                   borderRadius: BorderRadius.all(Radius.circular(5)),
//                                                   child:widget.stream.wooProducts[index].images!.isNotEmpty &&
//                                                       widget.stream.wooProducts[index].images?[0].src != null &&
//                                                       widget.stream.wooProducts[index].images?[0].src != ''
//                                                       ?Image(
//                                                     // todo poner imagen del producto
//                                                     image:  NetworkImage(widget.stream.wooProducts[index].images?[0].src??""),
//                                                     alignment: Alignment.center,
//                                                     fit: BoxFit.cover,
//                                                     loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//                                                       if (loadingProgress == null) return child;
//                                                       return Center(
//                                                         child: CircularProgressIndicator(
//                                                           value: loadingProgress.expectedTotalBytes != null
//                                                               ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                                                               : null,
//                                                         ),
//                                                       );
//                                                     },
//                                                   ):Image(
//                                                     // todo poner imagen del producto
//                                                     image:  AssetImage('assets/img/icon.png'),
//                                                     alignment: Alignment.center,
//                                                     fit: BoxFit.cover,
//                                                     loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
//                                                       if (loadingProgress == null) return child;
//                                                       return Center(
//                                                         child: CircularProgressIndicator(
//                                                           value: loadingProgress.expectedTotalBytes != null
//                                                               ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
//                                                               : null,
//                                                         ),
//                                                       );
//                                                     },
//                                                   ),
//
//                                                 )
//                                             ),
//                                           ),
//                                           Container(width: videoWidth * 0.02,),
//                                           Expanded(
//                                             child: Column(
//                                               crossAxisAlignment: CrossAxisAlignment.start,
//                                               mainAxisAlignment: MainAxisAlignment.start,
//                                               children: [
//                                                 Text('${widget.stream.wooProducts[index].name}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                                     fontSize: 14, fontWeight: FontWeight.w400), textAlign: TextAlign.left,),
//                                                 Container(height: videoHeight * 0.015,),
//                                                 Text('${widget.stream.wooProducts[index].categories?[0].name}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                                     fontSize: 12, fontWeight: FontWeight.w300), textAlign: TextAlign.left,),
//                                                 Container(height: videoHeight * 0.03,),
//                                               ],
//                                             ),
//                                           )
//                                         ],
//                                       ),
//                                       Container(height: videoHeight * 0.05,),
//                                       Row(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                                         children: [
//                                           Column(
//                                             crossAxisAlignment: CrossAxisAlignment.start,
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             children: [
//                                               Text('Precio', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                                   fontSize: 14, fontWeight: FontWeight.w300), textAlign: TextAlign.left,),
//                                               Container(height: videoHeight * 0.01,),
//                                               Text('\$${widget.stream.wooProducts[index].price}', style: TextStyle(color: Theme.of(context).primaryColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                                   fontSize: 18, fontWeight: FontWeight.w700), textAlign: TextAlign.left,),
//                                             ],
//                                           ),
//                                           GestureDetector(
//                                             onTap: (){
//                                               setState(() {
//                                                 showProductView = false;
//                                                 currentProduct = 0;
//                                                 productsInCart.add(widget.stream.wooProducts[index]);
//                                               });
//                                               //todo añadir al carrito
//                                               addToCartDialog(videoWidth, videoHeight);
//                                             },
//                                             behavior: HitTestBehavior.opaque,
//                                             child: Container(
//                                               alignment: Alignment.center,
//                                               padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015, left: screenSizeWidth * 0.015, right: screenSizeWidth * 0.015),
//                                               decoration: BoxDecoration(
//                                                   color: Theme.of(context).secondaryHeaderColor,
//                                                   borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
//                                               ),
//                                               child: Text('Añadir al carrito', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                                   fontSize: 10, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
//                                             ),
//                                           ),
//                                         ],
//                                       ),
//                                       Container(height: videoHeight * 0.05,),
//                                       //todo posición
//                                       Text('Producto ${currentProduct+1} de ${widget.stream.wooProducts.length}', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                           fontSize: 12, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
//                                     ],
//                                   ),
//                                 );
//                               }
//                             },
//                           ),
//                         ),
//                       ),
//                     )
//                 ),
//               )
//             ),
//             /*Visibility(
//                 visible: showCartView,
//                 child: SizedBox(
//                   height: videoHeight,
//                   width: videoWidth,
//                   child: Animate(
//                       effects: [FadeEffect()],
//                       child: GestureDetector(
//                         behavior: HitTestBehavior.opaque,
//                         onTap: (){
//                           //todo modal alerta del producto
//                           setState(() {
//                             showCartView = false;
//                           });
//                         },
//                         child: Container(
//                           padding: EdgeInsets.only(right: videoWidth * 0.05, top: videoHeight * 0.05),
//                           alignment: Alignment.topRight,
//                           child: SizedBox(
//                             height: videoHeight * 0.8,
//                             width: videoWidth * 0.45,
//                             child: ListView(
//                               padding: EdgeInsets.only(top: 0),
//                               physics: ScrollPhysics(),
//                               shrinkWrap: true,
//                               children: [
//                                 ListView.builder(
//                                   padding: EdgeInsets.only(top: 0),
//                                   physics: ScrollPhysics(),
//                                   shrinkWrap: true,
//                                   itemCount: productsInCart.length,
//                                   itemBuilder: (context, int index) => cellsProducts2(index, videoWidth, videoHeight),
//                                 ),
//                               ],
//                             )
//                           ),
//                         ),
//                       )
//                   ),
//                 )
//             ),*/
//           ],
//         )
//       ),
//     );
//   }
//
//   Widget cellsProducts(index, screenSizeWidth, screenSizeHeight){
//     if (widget.stream.ecommercePlatform == 'WooCommerce') {
//       return Container(
//         padding: EdgeInsets.only(right: screenSizeWidth * 0.045, top: screenSizeHeight * 0.03, bottom: screenSizeHeight * 0.03),
//         child: Container(
//             alignment: Alignment.center,
//             height: screenSizeHeight * 0.13,
//             width: screenSizeHeight * 0.45,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(5)),
//               color: Theme.of(context).primaryColorDark.withOpacity(0.8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.15),
//                   spreadRadius: 1,
//                   blurRadius: 4,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: GestureDetector(
//               behavior: HitTestBehavior.opaque,
//               onTap: ()async{
//                 //todo modal alerta del producto
//                 setState(() {
//                   showProductView = true;
//                 });
//                 await Future.delayed(
//                     const Duration(milliseconds: 100));
//                 controller.animateToPage(index,
//                     duration: const Duration(milliseconds: 500),
//                     curve: Curves.easeInOut);
//               },
//               child: ClipRRect(
//                 borderRadius: BorderRadius.all(Radius.circular(5)),
//                 child: Row(
//                   children: [
//                     ClipRRect(
//                       borderRadius: BorderRadius.all(Radius.circular(5)),
//                       child: Container(
//                         height: screenSizeHeight * 0.18,
//                         width: screenSizeHeight * 0.18,
//                         decoration: BoxDecoration(
//                             image: widget.stream.wooProducts[index].images?[0].src == '' ? DecorationImage(
//                               image: AssetImage('assets/img/placeholder.png'),
//                               alignment: Alignment.center,
//                               fit: BoxFit.cover,
//                             ):DecorationImage(
//                               image: NetworkImage(widget.stream.wooProducts[index].images?[0].src??""),
//                               alignment: Alignment.center,
//                               fit: BoxFit.cover,
//                             )
//                         ),
//                       ),
//                     ),
//                     Container(width: screenSizeWidth * 0.01,),
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Text('${widget.stream.wooProducts[index].name}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                               fontSize: 12, fontWeight: FontWeight.w400), maxLines: 2,textAlign: TextAlign.left,),
//                           Container(height: screenSizeHeight * 0.01,),
//                           Text('${widget.stream.wooProducts[index].type}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                               fontSize: 10, fontWeight: FontWeight.w300), maxLines: 2, textAlign: TextAlign.left,),
//                           Container(height: screenSizeHeight * 0.01,),
//                           Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Text('\$${widget.stream.wooProducts[index].price}', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                   fontSize: 14, fontWeight: FontWeight.w700), textAlign: TextAlign.left,),
//                               Container(width: screenSizeWidth * 0.01,),
//                               GestureDetector(
//                                 onTap: (){
//                                   setState(() {
//                                     showProductView = false;
//                                     currentProduct = 0;
//                                     productsInCart.add(widget.stream.shopProducts[index]);
//                                   });
//                                   addToCartDialog(screenSizeWidth, screenSizeHeight);
//                                 },
//                                 behavior: HitTestBehavior.opaque,
//                                 child: Container(
//                                   padding: EdgeInsets.all(5),
//                                   alignment: Alignment.center,
//                                   decoration: BoxDecoration(
//                                     color: Theme.of(context).secondaryHeaderColor.withOpacity(0.4),
//                                     borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01)),
//                                   ),
//                                   child: Icon(Icons.shopping_cart_rounded, color: context.background,),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 )
//               ),
//             )
//         ),
//       );
//     } else if (widget.stream.ecommercePlatform == 'Shopify') {
//       return Container(
//         padding: EdgeInsets.only(right: screenSizeWidth * 0.045, top: screenSizeHeight * 0.03, bottom: screenSizeHeight * 0.03),
//         child: Container(
//             alignment: Alignment.center,
//             height: screenSizeHeight * 0.13,
//             width: screenSizeHeight * 0.45,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(5)),
//               color: Theme.of(context).primaryColorDark.withOpacity(0.8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.15),
//                   spreadRadius: 1,
//                   blurRadius: 4,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: GestureDetector(
//               behavior: HitTestBehavior.opaque,
//               onTap: ()async{
//                 //todo modal alerta del producto
//
//                 setState(() {
//                   showProductView = true;
//                 });
//
//                 await Future.delayed(
//                     const Duration(milliseconds: 100));
//
//                 print('Haciendo tap en elemento: $index');
//                 controller.animateToPage(index,
//                     duration: const Duration(milliseconds: 500),
//                     curve: Curves.easeInOut);
//
//               },
//               child: ClipRRect(
//                 borderRadius: BorderRadius.all(Radius.circular(5)),
//                 child: Container(
//                   padding: EdgeInsets.only(left: screenSizeWidth * 0.005, right: screenSizeWidth * 0.005),
//                   child: Row(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     mainAxisAlignment: MainAxisAlignment.start,
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.all(Radius.circular(5)),
//                         child: Container(
//                           height: screenSizeHeight * 0.18,
//                           width: screenSizeHeight * 0.18,
//                           decoration: BoxDecoration(
//                               borderRadius: BorderRadius.all(Radius.circular(5)),
//                               image: widget.stream.shopProducts[index].images?[0].src == '' ? DecorationImage(
//                                 image: AssetImage('assets/img/loginBG.jpg'),
//                                 alignment: Alignment.center,
//                                 fit: BoxFit.cover,
//                               ):DecorationImage(
//                                 image: NetworkImage(widget.stream.shopProducts[index].images?[0].src??""),
//                                 alignment: Alignment.center,
//                                 fit: BoxFit.cover,
//                               )
//                           ),
//                         ),
//                       ),
//                       Container(width: screenSizeWidth * 0.01,),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text('${widget.stream.shopProducts[index].title}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                 fontSize: 12, fontWeight: FontWeight.w400), maxLines: 2,textAlign: TextAlign.left,),
//                             Container(height: screenSizeHeight * 0.01,),
//                             Text('${widget.stream.shopProducts[index].productType}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                 fontSize: 10, fontWeight: FontWeight.w300), maxLines: 2, textAlign: TextAlign.left,),
//                             Container(height: screenSizeHeight * 0.01,),
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('\$${widget.stream.shopProducts[index].variants?[0].price}', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                     fontSize: 14, fontWeight: FontWeight.w700), textAlign: TextAlign.left,),
//                                 Container(width: screenSizeWidth * 0.01,),
//                                 GestureDetector(
//                                   onTap: (){
//                                     setState(() {
//                                       showProductView = false;
//                                       currentProduct = 0;
//                                       productsInCart.add(widget.stream.shopProducts[index]);
//                                     });
//                                     addToCartDialog(screenSizeWidth, screenSizeHeight);
//                                   },
//                                   behavior: HitTestBehavior.opaque,
//                                   child: Container(
//                                     padding: EdgeInsets.all(5),
//                                     alignment: Alignment.center,
//                                     decoration: BoxDecoration(
//                                       color: Theme.of(context).secondaryHeaderColor.withOpacity(0.4),
//                                       borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01)),
//                                     ),
//                                     child: Icon(Icons.shopping_cart_rounded, color: context.background,),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       )
//                     ],
//                   ),
//                 ),
//               )
//             )
//         ),
//       );
//     } else {
//       return Container(
//         padding: EdgeInsets.only(right: screenSizeWidth * 0.045, top: screenSizeHeight * 0.03, bottom: screenSizeHeight * 0.03),
//         child: Container(
//             alignment: Alignment.center,
//             height: screenSizeHeight * 0.13,
//             width: screenSizeHeight * 0.45,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.all(Radius.circular(5)),
//               color: Theme.of(context).primaryColorDark.withOpacity(0.8),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.15),
//                   spreadRadius: 1,
//                   blurRadius: 4,
//                   offset: Offset(0, 4),
//                 ),
//               ],
//             ),
//             child: GestureDetector(
//               behavior: HitTestBehavior.opaque,
//               onTap: ()async{
//                 //todo modal alerta del producto
//                 setState(() {
//                   showProductView = true;
//                 });
//                 await Future.delayed(
//                     const Duration(milliseconds: 100));
//                 controller.animateToPage(index,
//                     duration: const Duration(milliseconds: 500),
//                     curve: Curves.easeInOut);
//               },
//               child: ClipRRect(
//                   borderRadius: BorderRadius.all(Radius.circular(5)),
//                   child: Row(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.all(Radius.circular(5)),
//                         child: Container(
//                           height: screenSizeHeight * 0.18,
//                           width: screenSizeHeight * 0.18,
//                           decoration: BoxDecoration(
//                               image: widget.stream.wooProducts[index].images?[0].src == '' ? DecorationImage(
//                                 image:  AssetImage('assets/img/placeholder.png'),
//                                 alignment: Alignment.center,
//                                 fit: BoxFit.cover,
//                               ):DecorationImage(
//                                 image:  NetworkImage(widget.stream.wooProducts[index].images?[0].src??""),
//                                 alignment: Alignment.center,
//                                 fit: BoxFit.cover,
//                               )
//                           ),
//                         ),
//                       ),
//                       Container(width: screenSizeWidth * 0.01,),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           mainAxisAlignment: MainAxisAlignment.center,
//                           children: [
//                             Text('${widget.stream.wooProducts[index].name}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                 fontSize: 12, fontWeight: FontWeight.w400), maxLines: 2,textAlign: TextAlign.left,),
//                             Container(height: screenSizeHeight * 0.01,),
//                             Text('${widget.stream.wooProducts[index].type}', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                 fontSize: 10, fontWeight: FontWeight.w300), maxLines: 2, textAlign: TextAlign.left,),
//                             Container(height: screenSizeHeight * 0.01,),
//                             Row(
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                               children: [
//                                 Text('\$${widget.stream.wooProducts[index].price}', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                                     fontSize: 14, fontWeight: FontWeight.w700), textAlign: TextAlign.left,),
//                                 Container(width: screenSizeWidth * 0.01,),
//                                 GestureDetector(
//                                   onTap: (){
//                                     setState(() {
//                                       showProductView = false;
//                                       currentProduct = 0;
//                                       productsInCart.add(widget.stream.shopProducts[index]);
//                                     });
//                                     addToCartDialog(screenSizeWidth, screenSizeHeight);
//                                   },
//                                   behavior: HitTestBehavior.opaque,
//                                   child: Container(
//                                     padding: EdgeInsets.all(5),
//                                     alignment: Alignment.center,
//                                     decoration: BoxDecoration(
//                                       color: Theme.of(context).secondaryHeaderColor.withOpacity(0.4),
//                                       borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01)),
//                                     ),
//                                     child: Icon(Icons.shopping_cart_rounded, color: context.background,),
//                                   ),
//                                 ),
//                               ],
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   )
//               ),
//             )
//         ),
//       );
//     }
//   }
//
//   addToCartDialog(screenSizeWidth, screenSizeHeight) async {
//     showAnimatedDialog(
//       context: context,
//       barrierColor: Colors.transparent,
//       alignment: Alignment.center,
//       builder: (BuildContext context) {
//         return CustomDialogWidget(
//           shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.03))
//           ),
//           backgroundColor: Theme.of(context).primaryColorDark.withOpacity(0.65),
//           content: SizedBox(
//             width: screenSizeWidth * 0.1,
//             height: screenSizeWidth * 0.1,
//             child: Container(
//               alignment: Alignment.center,
//               decoration: BoxDecoration(
//                 borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.02)),
//               ),
//               child: ListView(
//                 padding: EdgeInsets.only(top: 0, left: screenSizeWidth * 0.03, right: screenSizeWidth * 0.03,),
//                 shrinkWrap: true,
//                 physics: ScrollPhysics(),
//                 children: [
//                   Text('Producto añadido\nal carrito', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
//                       fontSize: 14, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
//                 ],
//               ),
//             ),
//           )
//         );
//       },
//       animationType: DialogTransitionType.fade,
//       curve: Curves.easeIn,
//       duration: Duration(milliseconds: 500),
//     );
//     await Future.delayed(
//         const Duration(milliseconds: 1500));
//     Navigator.of(context, rootNavigator: true).pop('dialog');
//   }
//
// }