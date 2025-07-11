import 'dart:convert';
import 'dart:developer';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cumbia_live_company/CallPage.dart';
import 'package:cumbia_live_company/Models/Shopify/shopify_product_model.dart';
import 'package:cumbia_live_company/add_new_event/newEvent.dart';
import 'package:cumbia_live_company/theme/theme.dart';
import 'package:cumbia_live_company/zego_config.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
// import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:video_player/video_player.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'Models/Constants.dart';
import 'Models/Structs.dart';
import 'package:file_picker/file_picker.dart';
import 'add_new_event/EventsPageOld.dart';
import 'common/color_constants.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key? key}) : super(key: key);

  @override
  _State createState() => _State();

}

class _State extends State<HomeScreen>{

  bool homeLoading=false;
  bool step3loading=false;
  String time='';

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

  int currentStepper = 1;
  String _videoFileName = "";
  Duration durationCount = Duration.zero;
  VideoPlayerController? _videoPlayController = null;
  Uint8List? fileBytes = null;
  DateTime? fromTime; // Track selected "From" time
  DateTime? toTime; // Track selected "To" time
  String? video_url = null;
  String? video_page_url = null;
  TextEditingController Video_url_controller = TextEditingController(text: '');

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

  var _pdfViewerController = PdfViewerController();

  final GlobalKey<SfPdfViewerState> _pdfViewerStateKey = GlobalKey();

  final TextEditingController urlController = TextEditingController();
  final TextEditingController vinculationID = TextEditingController();
  final TextEditingController vinculationSecretID = TextEditingController();

  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _db = FirebaseFirestore.instance;

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

  bool isAliasValid = false;

  String version = 'Unknown';

  // // Apply AppID and AppSign from ZEGO
  // final int appID = 1742640984;
  //
  // // Apply AppID and AppSign from ZEGO
  // final String appSign = 'a50d8be62818c3b2b8474be50db0aac534f07ce0d346d9dbd42192d8b909b428';
  //
  // // Specify test environment
  // final bool isTestEnv = true;
  //
  // // Specify a general scenario
  // final ZegoScenario scenario = ZegoScenario.Broadcast;

  List<PackageSuscriptionData> suscriptions = [];

  GeneralProductData allProducts = GeneralProductData( ecommercePlatform: '', wooProducts: [], shopProducts: []);

  void initState() {
    setState(() {
      homeLoading=false;
    });

    super.initState();

    getSuscriptions();

    getData();

    ZegoExpressEngine.getVersion().then((value) => print('SDK Version: $value'));

   // Create ZegoExpressEngine
   createEngine();
  }

  getSuscriptions() {
    var ref = _db.collection('suscriptions').snapshots();

    ref.listen((event) {
      if (event.docChanges.isEmpty) {
        print('No hay suscripciones');
      } else {
        var contador = 1;
        event.docChanges.forEach((eventCultural) async {
          var eventCulturalData = eventCultural.doc.data();
          var eventCulturalID = eventCultural.doc.id;

          var availableAct = PackageSuscriptionData.fromMap(eventCulturalData!);

          if (eventCultural.type == DocumentChangeType.added) {
            //print('Se está añadiendo doc a disponible');
            setState(() {
              suscriptions.add(availableAct);
              suscriptions..sort((a, b) {
                final positionA = a.position ?? 0; // Use 0 as the default value if position is null
                final positionB = b.position ?? 0;

                return positionA.compareTo(positionB);
              });
            });
          }
          if (eventCultural.type == DocumentChangeType.modified) {
            var index = suscriptions
                .indexWhere((element) => element.id == eventCulturalID);

            setState(() {
              suscriptions[index] = availableAct;
              suscriptions.sort((a, b) {
                final positionA = a.position ?? 0; // Use 0 as the default value if position is null
                final positionB = b.position ?? 0;

                return positionA.compareTo(positionB);
              });
            });
          }
          if (eventCultural.type == DocumentChangeType.removed) {
            //print('Se está eliminando doc de disponible');
            //allRequests.removeWhere((element) => element.id == reqID);
            setState(() {
              suscriptions
                  .removeWhere((element) => element.id == eventCulturalID);
              suscriptions.sort((a, b) {
                final positionA = a.position ?? 0; // Use 0 as the default value if position is null
                final positionB = b.position ?? 0;

                return positionA.compareTo(positionB);
              });
            });
          }

          if (contador == event.docChanges.length) {}

          contador = contador + 1;
        });
      }
    });
  }

  Future<void> createEngine() async {
    /*await ZegoExpressEngine.createEngineWithProfile(ZegoEngineProfile(
      appID,
      ZegoScenario.Default,
      appSign: null,
      enablePlatformView: true,
    ));*/
    /*Map<String,dynamic> profile = {
      'appID': appID,
      'scenario': 'General',
    };*/

    print("** wk zego engine start");

    ZegoEngineProfile profile = ZegoEngineProfile(ZegoConfig.instance.appID, ZegoConfig.instance.scenario,
        enablePlatformView: true, appSign: kIsWeb ? null : ZegoConfig.instance.appSign);
    ZegoExpressEngine.createEngineWithProfile(profile);
    print("** wk zego engine success done");
  }

  //Get data
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

              /// Uncomment these lines if needed
              // if (userInfo.sessionID?.isNotEmpty ?? false) {
              //   getSession();
              // }
              //
              // if (userInfo.subscriptionID?.isNotEmpty ?? false) {
              //   getSubscription(userInfo.subscriptionID!);
              // }
              this.companyInfo = companies.first;

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


  List<ShopifyProductModel> productsSelected = [];

  String addFiveSeconds(String inputTime) {
    // Split the input string into minutes and seconds
    List<String> parts = inputTime.split(':');
    int minutes = int.parse(parts[0]);
    int seconds = int.parse(parts[1]);

    // Add 5 seconds
    seconds += 5;

    // If seconds exceed 59, adjust minutes accordingly
    if (seconds >= 60) {
      minutes += 1;
      seconds -= 60;
    }

    // Format the result
    String formattedMinutes = minutes.toString().padLeft(2, '0');
    String formattedSeconds = seconds.toString().padLeft(2, '0');

    return '$formattedMinutes:$formattedSeconds';
  }

  @override
  Widget build(BuildContext context) {
    var screenSizeHeight = MediaQuery.of(context).size.height;
    var screenSizeWidth = MediaQuery.of(context).size.width;
    fontDeclaration(screenSizeHeight, screenSizeWidth);
    if (screenSizeHeight >= screenSizeWidth) {
      return MaterialApp(
        home: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).focusColor,
              Theme.of(context).focusColor,
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor,
            ],
          )),
          child: Container(

              alignment: Alignment.center,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(

                        padding: EdgeInsets.only(
                          top: screenSizeHeight * 0.035,
                          left: screenSizeWidth * 0.05,
                          right: screenSizeWidth * 0.05,
                          bottom: screenSizeHeight * 0.035,
                        ),
                        color: Theme.of(context).focusColor,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Bienvenido de nuevo, ${userInfo.name}\n¡Es momento de hacer Stream!',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Gotham',
                                    decoration: TextDecoration.none,
                                    fontSize: primaryTextMobile,
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              height: screenSizeHeight * 0.15,
                              width: screenSizeWidth * 0.2,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/img/logowhite.png'),
                                      fit: BoxFit.contain)),
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                    flex: 8,
                    child: ListView(
                      padding: EdgeInsets.only(
                        top: screenSizeHeight * 0.03,
                        left: screenSizeWidth * 0.05,
                        right: screenSizeWidth * 0.05,
                        bottom: screenSizeHeight * 0.05,
                      ),
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      children: [
                        Container(
                          padding: EdgeInsets.only(
                            left: screenSizeWidth * 0.05,
                            right: screenSizeWidth * 0.05,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  validatePassToStream(screenSizeHeight, screenSizeWidth, context);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: screenSizeHeight * 0.025,
                                      bottom: screenSizeHeight * 0.025,
                                      left: screenSizeWidth * 0.045,
                                      right: screenSizeWidth * 0.045),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            screenSizeHeight * 0.02)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.play_circle_filled_outlined,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        size: screenSizeWidth * 0.08,
                                      ),
                                      Container(
                                        width: screenSizeWidth * 0.01,
                                      ),
                                      Text(
                                        'Iniciar un\nLiveStream',
                                        style: TextStyle(
                                            color: Theme.of(context).focusColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: secondaryTextMobile,
                                            fontWeight: FontWeight.w400),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: screenSizeWidth * 0.03,
                              ),
                              GestureDetector(
                                onTap: () {
                                  dialogMenu(screenSizeHeight, screenSizeWidth);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: screenSizeHeight * 0.025,
                                      bottom: screenSizeHeight * 0.025,
                                      left: screenSizeWidth * 0.045,
                                      right: screenSizeWidth * 0.045),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            screenSizeHeight * 0.02)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.manage_accounts_outlined,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        size: screenSizeWidth * 0.08,
                                      ),
                                      Container(
                                        width: screenSizeWidth * 0.01,
                                      ),
                                      Text(
                                        'Configurar\nmi cuenta',
                                        style: TextStyle(
                                            color: Theme.of(context).focusColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: secondaryTextMobile,
                                            fontWeight: FontWeight.w400),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: screenSizeHeight * 0.03,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                            left: screenSizeWidth * 0.05,
                            right: screenSizeWidth * 0.05,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  dialogPricing(
                                      screenSizeHeight, screenSizeWidth);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: screenSizeHeight * 0.025,
                                      bottom: screenSizeHeight * 0.025,
                                      left: screenSizeWidth * 0.045,
                                      right: screenSizeWidth * 0.045),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            screenSizeHeight * 0.02)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.credit_card_outlined,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        size: screenSizeWidth * 0.08,
                                      ),
                                      Container(
                                        width: screenSizeWidth * 0.01,
                                      ),
                                      Text(
                                        'Mi\nsuscripción',
                                        style: TextStyle(
                                            color: Theme.of(context).focusColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: secondaryTextMobile,
                                            fontWeight: FontWeight.w400),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                width: screenSizeWidth * 0.03,
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: screenSizeHeight * 0.05,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              top: screenSizeHeight * 0.045,
                              bottom: screenSizeHeight * 0.045,
                              left: screenSizeWidth * 0.03,
                              right: screenSizeWidth * 0.03),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                                Radius.circular(screenSizeHeight * 0.02)),
                          ),
                          child: ListView(
                            padding: EdgeInsets.only(top: 0),
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            children: [
                              Text(
                                '¡Completa tu perfil para empezar a hacer Streams!',
                                style: TextStyle(
                                    color: Theme.of(context).focusColor,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Gotham',
                                    decoration: TextDecoration.none,
                                    fontSize: primaryTextMobile,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.left,
                              ),
                              Container(
                                height: screenSizeHeight * 0.01,
                              ),
                              Text(
                                'La siguiente información es requerida para que podamos habilitar tu cuenta y puedas iniciar una transmisión',
                                style: TextStyle(
                                    color: Theme.of(context).focusColor,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Gotham',
                                    decoration: TextDecoration.none,
                                    fontSize: contentTextMobile,
                                    fontWeight: FontWeight.w300),
                                textAlign: TextAlign.left,
                              ),
                              Container(
                                height: screenSizeHeight * 0.03,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      dialogUserInfoValues(
                                          screenSizeHeight, screenSizeWidth);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: screenSizeHeight * 0.025,
                                          bottom: screenSizeHeight * 0.025,
                                          left: screenSizeWidth * 0.03,
                                          right: screenSizeWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).focusColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenSizeHeight * 0.02)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.account_circle_outlined,
                                            color: Colors.white,
                                            size: screenSizeHeight * 0.06,
                                          ),
                                          Container(
                                            width: screenSizeWidth * 0.015,
                                          ),
                                          Text(
                                            'Información\nde usuario',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: 'Gotham',
                                                decoration: TextDecoration.none,
                                                fontSize: contentTextWeb,
                                                fontWeight: FontWeight.w400),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: screenSizeWidth * 0.045,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      dialogCompanyInfoValues(
                                          screenSizeHeight, screenSizeWidth);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: screenSizeHeight * 0.025,
                                          bottom: screenSizeHeight * 0.025,
                                          left: screenSizeWidth * 0.03,
                                          right: screenSizeWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).focusColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenSizeHeight * 0.02)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.business_outlined,
                                            color: Colors.white,
                                            size: screenSizeHeight * 0.06,
                                          ),
                                          Container(
                                            width: screenSizeWidth * 0.015,
                                          ),
                                          Text(
                                            'Información\nde empresa',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: 'Gotham',
                                                decoration: TextDecoration.none,
                                                fontSize: contentTextWeb,
                                                fontWeight: FontWeight.w400),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: screenSizeHeight * 0.03,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      dialogContactInfoValues(
                                          screenSizeHeight, screenSizeWidth);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: screenSizeHeight * 0.025,
                                          bottom: screenSizeHeight * 0.025,
                                          left: screenSizeWidth * 0.03,
                                          right: screenSizeWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).focusColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenSizeHeight * 0.02)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.contact_page_outlined,
                                            color: Colors.white,
                                            size: screenSizeHeight * 0.06,
                                          ),
                                          Container(
                                            width: screenSizeWidth * 0.015,
                                          ),
                                          Text(
                                            'Información\nde contacto',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: 'Gotham',
                                                decoration: TextDecoration.none,
                                                fontSize: contentTextWeb,
                                                fontWeight: FontWeight.w400),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: screenSizeWidth * 0.045,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      dialogToConnectWeb(screenSizeHeight, screenSizeWidth);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: screenSizeHeight * 0.025,
                                          bottom: screenSizeHeight * 0.025,
                                          left: screenSizeWidth * 0.03,
                                          right: screenSizeWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).focusColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenSizeHeight * 0.02)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.desktop_windows_outlined,
                                            color: Colors.white,
                                            size: screenSizeHeight * 0.06,
                                          ),
                                          Container(
                                            width: screenSizeWidth * 0.015,
                                          ),
                                          Text(
                                            'Vinculación\nEcommerce',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: 'Gotham',
                                                decoration: TextDecoration.none,
                                                fontSize: contentTextWeb,
                                                fontWeight: FontWeight.w400),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: screenSizeHeight * 0.03,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      dialogPricing(
                                          screenSizeHeight, screenSizeWidth);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: screenSizeHeight * 0.025,
                                          bottom: screenSizeHeight * 0.025,
                                          left: screenSizeWidth * 0.03,
                                          right: screenSizeWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).focusColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenSizeHeight * 0.02)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.payment_outlined,
                                            color: Colors.white,
                                            size: screenSizeHeight * 0.06,
                                          ),
                                          Container(
                                            width: screenSizeWidth * 0.015,
                                          ),
                                          Text(
                                            'Suscripción\nCumbiaLive',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: 'Gotham',
                                                decoration: TextDecoration.none,
                                                fontSize: contentTextWeb,
                                                fontWeight: FontWeight.w400),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    width: screenSizeWidth * 0.045,
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      dialogToPrivacy(
                                          screenSizeHeight, screenSizeWidth);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: screenSizeHeight * 0.025,
                                          bottom: screenSizeHeight * 0.025,
                                          left: screenSizeWidth * 0.03,
                                          right: screenSizeWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).focusColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenSizeHeight * 0.02)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.policy_outlined,
                                            color: Colors.white,
                                            size: screenSizeHeight * 0.06,
                                          ),
                                          Container(
                                            width: screenSizeWidth * 0.015,
                                          ),
                                          Text(
                                            'Términos y\ncondiciones',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: 'Gotham',
                                                decoration: TextDecoration.none,
                                                fontSize: contentTextWeb,
                                                fontWeight: FontWeight.w400),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: screenSizeHeight * 0.1,
                        ),
                        /*Text('Tus Streams anteriores',
                          style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                              fontSize: titleMobile, fontWeight: FontWeight.w400), textAlign: TextAlign.left,),
                        Container(height: screenSizeHeight * 0.045,),
                        GridView.builder(
                          padding: EdgeInsets.only(top: 0),
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            childAspectRatio: 1.3,
                            crossAxisSpacing: screenSizeWidth * 0.025,
                            mainAxisSpacing: screenSizeWidth * 0.025,
                            crossAxisCount: 2,
                          ),
                          itemCount: 8,
                          itemBuilder: (context, int index) => cellsWeb(index, screenSizeWidth, screenSizeHeight),
                        ),*/
                      ],
                    ),
                  )
                ],
              )),
        ),
      );
    } else {
      return MaterialApp(
        home: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).focusColor,
              Theme.of(context).focusColor,
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor,
              Theme.of(context).primaryColor,
            ],
          )),
          child: homeLoading?CircularProgressIndicator():Container(
              alignment: Alignment.center,
              child: Column(
                children: [
                  Expanded(
                    flex: 2,
                    child: Container(
                        padding: EdgeInsets.only(
                          top: screenSizeHeight * 0.035,
                          left: screenSizeWidth * 0.05,
                          right: screenSizeWidth * 0.05,
                          bottom: screenSizeHeight * 0.035,
                        ),
                        color:
                        Theme.of(context).focusColor,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Bienvenido de nuevo, ${userInfo.name}\n¡Es momento de hacer Stream!',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Gotham',
                                    decoration: TextDecoration.none,
                                    fontSize: titleWeb,
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.left,
                              ),
                            ),
                            Container(
                              height: screenSizeHeight * 0.15,
                              width: screenSizeWidth * 0.1,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage(
                                          'assets/img/logowhite.png'),
                                      fit: BoxFit.contain)),
                            ),
                          ],
                        )),
                  ),
                  Expanded(
                    flex: 8,
                    child: ListView(
                      padding: EdgeInsets.only(
                        top: screenSizeHeight * 0.05,
                        left: screenSizeWidth * 0.05,
                        right: screenSizeWidth * 0.3,
                        bottom: screenSizeHeight * 0.05,
                      ),
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  validatePassToStream(screenSizeHeight, screenSizeWidth, context);
                                  print("you clicked me");
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  margin: EdgeInsets.only(right: 20),
                                  padding: EdgeInsets.only(
                                      top: screenSizeHeight * 0.025,
                                      bottom: screenSizeHeight * 0.025,
                                      left: screenSizeWidth * 0.02,
                                      right: screenSizeWidth * 0.02),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(screenSizeHeight * 0.02)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.play_circle_filled_outlined,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        size: screenSizeHeight * 0.06,
                                      ),
                                      Container(
                                        width: screenSizeWidth * 0.01,
                                      ),
                                      Text(
                                        'Iniciar un\nLiveStream',
                                        style: TextStyle(
                                            color: Theme.of(context).focusColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: secondaryTextWeb,
                                            fontWeight: FontWeight.w400),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  if(allProducts.shopProducts==[]||allProducts.wooProducts==[]){
                                    print("** wk click subir video 0");
                                    dialogToConnectWeb(screenSizeHeight, screenSizeWidth);
                                  }else{
                                    print("** wk click subir video 1");
                                    dialogToOpenVideoUploadSection(screenSizeHeight, screenSizeWidth);
                                  }
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  margin: EdgeInsets.only(right: 20),
                                  padding: EdgeInsets.only(
                                      top: screenSizeHeight * 0.025,
                                      bottom: screenSizeHeight * 0.025,
                                      left: screenSizeWidth * 0.02,
                                      right: screenSizeWidth * 0.02
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(screenSizeHeight * 0.02)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.upload_file,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        size: screenSizeHeight * 0.06,
                                      ),
                                      Container(
                                        width: screenSizeWidth * 0.01,
                                      ),
                                      Text(
                                        'Subir \t\nvideo',
                                        style: TextStyle(
                                            color: Theme.of(context).focusColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: secondaryTextWeb,
                                            fontWeight: FontWeight.w400),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  dialogMenu(screenSizeHeight, screenSizeWidth);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  margin: EdgeInsets.only(right: 20),
                                  padding: EdgeInsets.only(
                                      top: screenSizeHeight * 0.025,
                                      bottom: screenSizeHeight * 0.025,
                                      left: screenSizeWidth * 0.02,
                                      right: screenSizeWidth * 0.02),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(screenSizeHeight * 0.02)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.manage_accounts_outlined,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        size: screenSizeHeight * 0.06,
                                      ),
                                      Container(
                                        width: screenSizeWidth * 0.01,
                                      ),
                                      Text(
                                        'Configurar\nmi cuenta',
                                        style: TextStyle(
                                            color: Theme.of(context).focusColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: secondaryTextWeb,
                                            fontWeight: FontWeight.w400),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  dialogPricing(
                                      screenSizeHeight, screenSizeWidth);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  margin: EdgeInsets.only(right: 20),
                                  padding: EdgeInsets.only(
                                      top: screenSizeHeight * 0.025,
                                      bottom: screenSizeHeight * 0.025,
                                      left: screenSizeWidth * 0.02,
                                      right: screenSizeWidth * 0.02),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(screenSizeHeight * 0.02)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.credit_card_outlined,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        size: screenSizeHeight * 0.06,
                                      ),
                                      Container(
                                        width: screenSizeWidth * 0.01,
                                      ),
                                      Text(
                                        'Mi\nsuscripción',
                                        style: TextStyle(
                                            color: Theme.of(context).focusColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: secondaryTextWeb,
                                            fontWeight: FontWeight.w400),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: screenSizeHeight * 0.05,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              top: screenSizeHeight * 0.045,
                              bottom: screenSizeHeight * 0.045,
                              left: screenSizeWidth * 0.02,
                              right: screenSizeWidth * 0.02),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.all(
                                Radius.circular(screenSizeHeight * 0.02)),
                          ),
                          child: ListView(
                            padding: EdgeInsets.only(top: 0),
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            children: [
                              Text(
                                '¡Completa tu perfil para empezar a hacer Streams!',
                                style: TextStyle(
                                    color: Theme.of(context).focusColor,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Gotham',
                                    decoration: TextDecoration.none,
                                    fontSize: primaryTextWeb,
                                    fontWeight: FontWeight.w400),
                                textAlign: TextAlign.left,
                              ),
                              Container(
                                height: screenSizeHeight * 0.01,
                              ),
                              Text(
                                'La siguiente información es requerida para que podamos habilitar tu cuenta y puedas iniciar una transmisión',
                                style: TextStyle(
                                    color: Theme.of(context).focusColor,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Gotham',
                                    decoration: TextDecoration.none,
                                    fontSize: contentTextWeb,
                                    fontWeight: FontWeight.w300),
                                textAlign: TextAlign.left,
                              ),
                              Container(
                                height: screenSizeHeight * 0.03,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      dialogUserInfoValues(
                                          screenSizeHeight, screenSizeWidth);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: screenSizeHeight * 0.025,
                                          bottom: screenSizeHeight * 0.025,
                                          left: screenSizeWidth * 0.03,
                                          right: screenSizeWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).focusColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenSizeHeight * 0.02)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.account_circle_outlined,
                                            color: Colors.white,
                                            size: screenSizeHeight * 0.06,
                                          ),
                                          Container(
                                            width: screenSizeWidth * 0.015,
                                          ),
                                          Text(
                                            'Información\nde usuario',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: 'Gotham',
                                                decoration: TextDecoration.none,
                                                fontSize: contentTextWeb,
                                                fontWeight: FontWeight.w400),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      dialogCompanyInfoValues(
                                          screenSizeHeight, screenSizeWidth);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: screenSizeHeight * 0.025,
                                          bottom: screenSizeHeight * 0.025,
                                          left: screenSizeWidth * 0.03,
                                          right: screenSizeWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).focusColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenSizeHeight * 0.02)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.business_outlined,
                                            color: Colors.white,
                                            size: screenSizeHeight * 0.06,
                                          ),
                                          Container(
                                            width: screenSizeWidth * 0.015,
                                          ),
                                          Text(
                                            'Información\nde empresa',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: 'Gotham',
                                                decoration: TextDecoration.none,
                                                fontSize: contentTextWeb,
                                                fontWeight: FontWeight.w400),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      dialogContactInfoValues(
                                          screenSizeHeight, screenSizeWidth);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: screenSizeHeight * 0.025,
                                          bottom: screenSizeHeight * 0.025,
                                          left: screenSizeWidth * 0.03,
                                          right: screenSizeWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).focusColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenSizeHeight * 0.02)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.contact_page_outlined,
                                            color: Colors.white,
                                            size: screenSizeHeight * 0.06,
                                          ),
                                          Container(
                                            width: screenSizeWidth * 0.015,
                                          ),
                                          Text(
                                            'Información\nde contacto',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: 'Gotham',
                                                decoration: TextDecoration.none,
                                                fontSize: contentTextWeb,
                                                fontWeight: FontWeight.w400),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                height: screenSizeHeight * 0.03,
                              ),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      dialogToConnectWeb(screenSizeHeight, screenSizeWidth);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: screenSizeHeight * 0.025,
                                          bottom: screenSizeHeight * 0.025,
                                          left: screenSizeWidth * 0.03,
                                          right: screenSizeWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).focusColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenSizeHeight * 0.02)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.desktop_windows_outlined,
                                            color: Colors.white,
                                            size: screenSizeHeight * 0.06,
                                          ),
                                          Container(
                                            width: screenSizeWidth * 0.015,
                                          ),
                                          Text(
                                            'Vinculación\nEcommerce',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: 'Gotham',
                                                decoration: TextDecoration.none,
                                                fontSize: contentTextWeb,
                                                fontWeight: FontWeight.w400),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      //todo suscripción cumbia
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: screenSizeHeight * 0.025,
                                          bottom: screenSizeHeight * 0.025,
                                          left: screenSizeWidth * 0.03,
                                          right: screenSizeWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).focusColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenSizeHeight * 0.02)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.payment_outlined,
                                            color: Colors.white,
                                            size: screenSizeHeight * 0.06,
                                          ),
                                          Container(
                                            width: screenSizeWidth * 0.015,
                                          ),
                                          Text(
                                            'Suscripción\nCumbiaLive',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: 'Gotham',
                                                decoration: TextDecoration.none,
                                                fontSize: contentTextWeb,
                                                fontWeight: FontWeight.w400),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      dialogToPrivacy(
                                          screenSizeHeight, screenSizeWidth);
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          top: screenSizeHeight * 0.025,
                                          bottom: screenSizeHeight * 0.025,
                                          left: screenSizeWidth * 0.03,
                                          right: screenSizeWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).focusColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenSizeHeight * 0.02)),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.policy_outlined,
                                            color: Colors.white,
                                            size: screenSizeHeight * 0.06,
                                          ),
                                          Container(
                                            width: screenSizeWidth * 0.015,
                                          ),
                                          Text(
                                            'Términos y\ncondiciones',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: 'Gotham',
                                                decoration: TextDecoration.none,
                                                fontSize: contentTextWeb,
                                                fontWeight: FontWeight.w400),
                                            textAlign: TextAlign.left,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          height: screenSizeHeight * 0.1,
                        ),
                        /*Text('Tus Streams anteriores',
                        style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                            fontSize: titleWeb, fontWeight: FontWeight.w400), textAlign: TextAlign.left,),
                      Container(height: screenSizeHeight * 0.045,),
                      GridView.builder(
                        padding: EdgeInsets.only(top: 0),
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          childAspectRatio: 1.3,
                          crossAxisSpacing: screenSizeHeight * 0.025,
                          mainAxisSpacing: screenSizeHeight * 0.025,
                          crossAxisCount: 3,
                        ),
                        itemCount: 8,
                        itemBuilder: (context, int index) => cellsWeb(index, screenSizeWidth, screenSizeHeight),
                      ),*/
                      ],
                    ),
                  )
                ],
              )),
        ),
      );
    }
  }

  Widget cellsWeb(index, screenSizeWidth, screenSizeHeight) {
    return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.all(Radius.circular(screenSizeHeight * 0.02)),
          border: Border.all(color: Theme.of(context).primaryColor),
          color: Colors.white,
        ),
        child: Column(
          children: [
            Expanded(
                flex: 4,
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(screenSizeHeight * 0.02),
                      topLeft: Radius.circular(screenSizeHeight * 0.02)),
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/img/photo_1.png'),
                            fit: BoxFit.cover)),
                  ),
                )),
            Expanded(
              flex: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Nombre del Stream',
                      style: TextStyle(
                          color: Theme.of(context).focusColor,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Gotham',
                          decoration: TextDecoration.none,
                          fontSize: contentTextWeb,
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Hace 2 días',
                      style: TextStyle(
                          color: Theme.of(context).focusColor,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Gotham',
                          decoration: TextDecoration.none,
                          fontSize: smallTextWeb,
                          fontWeight: FontWeight.w300),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ));
  }

  //usuario
  final TextEditingController name = TextEditingController();
  final TextEditingController lastName = TextEditingController();
  final TextEditingController phone = TextEditingController();
  final TextEditingController mail = TextEditingController();
  final TextEditingController NIT = TextEditingController();

  //tienda
  final TextEditingController companyName = TextEditingController();
  final TextEditingController userName = TextEditingController();
  String category = 'Turismo';
  String virtualStore = 'WooCommerce';
  final TextEditingController webPage = TextEditingController();

  //información de contacto
  final TextEditingController businessPhone = TextEditingController();
  final TextEditingController businessMail = TextEditingController();
  String linkType = 'Instagram';
  final TextEditingController link = TextEditingController();

  aditionalInformation(screenSizeWidth, screenSizeHeight) {
    companyInfo.category =
        companyInfo.category == '' ? 'Turismo' : companyInfo.category;
    companyInfo.storePlatform = companyInfo.storePlatform == ''
        ? 'WooCommerce'
        : companyInfo.storePlatform;
    category = (companyInfo.category == '' ? 'Turismo' : companyInfo.category)!;
    virtualStore = (companyInfo.storePlatform == ''
        ? 'WooCommerce'
        : companyInfo.storePlatform)!;
    userInfo.secundaryEmail = userInfo.secundaryEmail == ''
        ? userInfo.email
        : userInfo.secundaryEmail;
    companyInfo.email =
        companyInfo.email == '' ? userInfo.email : companyInfo.email;
    isAliasValid = companyInfo.alias == '' ? false : true;

    if (screenSizeWidth < screenSizeHeight) {
      showModalBottomSheet(
          //expand: true,
          context: context,
          backgroundColor: context.background,
          builder: (context) => StatefulBuilder(
                builder: (context, modalState) {
                  return Container(
                      height: screenSizeHeight * 0.9,
                      child: Material(
                        child: ListView(
                          padding: EdgeInsets.only(
                              top: screenSizeHeight * 0.045,
                              left: screenSizeWidth * 0.05,
                              right: screenSizeWidth * 0.05,
                              bottom: screenSizeHeight * 0.045),
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Icon(
                                  Icons.close,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                              ),
                            ),
                            Text(
                              'Información adicional',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: titleMobile,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              height: screenSizeHeight * 0.015,
                            ),
                            Text(
                              'Requerimos de la siguiente información para vincular tu página web con Cumbia',
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextMobile,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              height: screenSizeHeight * 0.05,
                            ),
                            Text(
                              'Información personal',
                              style: TextStyle(
                                  color: Theme.of(context).dividerColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: secondaryTextMobile,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.015,
                            ),
                            Container(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(screenSizeHeight * 0.02)),
                                  color: Colors.white,
                                ),
                                child: ListView(
                                  padding: EdgeInsets.only(
                                    top: screenSizeHeight * 0.03,
                                    left: screenSizeWidth * 0.04,
                                    right: screenSizeWidth * 0.04,
                                    bottom: screenSizeHeight * 0.03,
                                  ),
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: ListView(
                                            shrinkWrap: true,
                                            physics: ScrollPhysics(),
                                            children: [
                                              Text(
                                                'Nombre',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextMobile,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                textAlign: TextAlign.left,
                                              ),
                                              Container(
                                                height: screenSizeHeight * 0.01,
                                              ),
                                              TextField(
                                                controller: name,
                                                onChanged: (text) {
                                                  if (text.isNotEmpty) {
                                                    userInfo.name = text;
                                                  } else if (text.length == 0) {
                                                    userInfo.name = '';
                                                  }
                                                },
                                                onSubmitted: (text) async {},
                                                textCapitalization:
                                                    TextCapitalization.none,
                                                keyboardType:
                                                    TextInputType.text,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextMobile,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                      borderSide: BorderSide(
                                                          width: 0.5,
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor)),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                      borderSide: BorderSide(
                                                          width: 0.5,
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                      borderSide: BorderSide(
                                                          width: 0.5,
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor)),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  prefixIcon: Icon(
                                                    Icons.text_fields,
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                  ),
                                                  hintStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      fontFamily: 'Gotham',
                                                      decoration:
                                                          TextDecoration.none,
                                                      fontSize:
                                                          contentTextMobile,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                  hintText: userInfo.name == ''
                                                      ? 'Tu nombre'
                                                      : userInfo.name,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: screenSizeWidth * 0.03,
                                        ),
                                        Expanded(
                                          child: ListView(
                                            shrinkWrap: true,
                                            physics: ScrollPhysics(),
                                            children: [
                                              Text(
                                                'Apellido',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextMobile,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                textAlign: TextAlign.left,
                                              ),
                                              Container(
                                                height: screenSizeHeight * 0.01,
                                              ),
                                              TextField(
                                                controller: lastName,
                                                onChanged: (text) {
                                                  if (text.isNotEmpty) {
                                                    userInfo.lastName = text;
                                                  } else if (text.length == 0) {
                                                    userInfo.lastName = '';
                                                  }
                                                },
                                                onSubmitted: (text) async {},
                                                textCapitalization:
                                                    TextCapitalization.none,
                                                keyboardType:
                                                    TextInputType.text,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextMobile,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                      borderSide: BorderSide(
                                                          width: 0.5,
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor)),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                      borderSide: BorderSide(
                                                          width: 0.5,
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                      borderSide: BorderSide(
                                                          width: 0.5,
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor)),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  prefixIcon: Icon(
                                                    Icons.text_fields,
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                  ),
                                                  hintStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      fontFamily: 'Gotham',
                                                      decoration:
                                                          TextDecoration.none,
                                                      fontSize:
                                                          contentTextMobile,
                                                      fontWeight:
                                                          FontWeight.w400),
                                                  hintText:
                                                      userInfo.lastName == ''
                                                          ? 'Tus apellidos'
                                                          : userInfo.lastName,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'Celular',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    Text(
                                      'Esta información no será visible para los usuarios, lo usaremos para contactarte desde Cumbia',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: smallTextMobile,
                                          fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.015,
                                    ),
                                    TextField(
                                      controller: phone,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          userInfo.phoneNumber = text;
                                        } else if (text.length == 0) {
                                          userInfo.phoneNumber = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextMobile,
                                            fontWeight: FontWeight.w400),
                                        hintText: userInfo.phoneNumber == ''
                                            ? 'Tu número'
                                            : userInfo.phoneNumber,
                                      ),
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'Correo',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    Text(
                                      'Esta información no será visible para los usuarios, lo usaremos para contactarte desde Cumbia',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: smallTextMobile,
                                          fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.015,
                                    ),
                                    TextField(
                                      controller: mail,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          userInfo.secundaryEmail = text;
                                        } else if (text.length == 0) {
                                          userInfo.secundaryEmail = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.emailAddress,
                                      //enabled: false,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextMobile,
                                            fontWeight: FontWeight.w400),
                                        hintText: userInfo.secundaryEmail == ''
                                            ? 'Correo del usuario'
                                            : userInfo.secundaryEmail,
                                      ),
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'NIT',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    TextField(
                                      controller: NIT,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          userInfo.nit = text;
                                        } else if (text.length == 0) {
                                          userInfo.nit = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextMobile,
                                            fontWeight: FontWeight.w400),
                                        hintText: userInfo.nit == ''
                                            ? 'Tu NIT'
                                            : userInfo.nit,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            //          //
                            Container(
                              height: screenSizeHeight * 0.05,
                            ),
                            Text(
                              'Información de empresa',
                              style: TextStyle(
                                  color: Theme.of(context).dividerColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: secondaryTextMobile,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.01,
                            ),
                            Text(
                              'Esta información será visible para los usuarios',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: smallTextMobile,
                                  fontWeight: FontWeight.w300),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.015,
                            ),
                            Container(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(screenSizeHeight * 0.02)),
                                  color: Colors.white,
                                ),
                                child: ListView(
                                  padding: EdgeInsets.only(
                                    top: screenSizeHeight * 0.03,
                                    left: screenSizeWidth * 0.04,
                                    right: screenSizeWidth * 0.04,
                                    bottom: screenSizeHeight * 0.03,
                                  ),
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  children: [
                                    Text(
                                      'Nombre de la empresa',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    TextField(
                                      controller: companyName,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          companyInfo.name = text;
                                        } else if (text.length == 0) {
                                          companyInfo.name = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextMobile,
                                            fontWeight: FontWeight.w400),
                                        hintText: companyInfo.name == ''
                                            ? 'Nombre de la empresa'
                                            : companyInfo.name,
                                      ),
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'Nombre de usuario',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    Text(
                                      'Con este nombre los usuarios podrán encontrar tu tienda facilmente',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: smallTextMobile,
                                          fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 10,
                                          child: TextField(
                                            controller: userName,
                                            onChanged: (text) {
                                              if (text.isNotEmpty) {
                                                modalState(() {
                                                  isAliasValid = false;
                                                  companyInfo.alias = text;
                                                });
                                              } else if (text.length == 0) {
                                                modalState(() {
                                                  isAliasValid = false;
                                                  companyInfo.alias = '';
                                                });
                                              }
                                            },
                                            onSubmitted: (text) async {
                                              if (text.isNotEmpty) {}
                                            },
                                            textCapitalization:
                                                TextCapitalization.none,
                                            keyboardType: TextInputType.text,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: 'Gotham',
                                                decoration: TextDecoration.none,
                                                fontSize: contentTextMobile,
                                                fontWeight: FontWeight.w400),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(16)),
                                                  borderSide: BorderSide(
                                                      width: 0.5,
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(16)),
                                                  borderSide: BorderSide(
                                                      width: 0.5,
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(16)),
                                                  borderSide: BorderSide(
                                                      width: 0.5,
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor)),
                                              filled: true,
                                              fillColor: Colors.white,
                                              prefixIcon: Icon(
                                                Icons.text_fields,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                              ),
                                              hintStyle: TextStyle(
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: contentTextMobile,
                                                  fontWeight: FontWeight.w400),
                                              hintText: companyInfo.alias == ''
                                                  ? 'Nombre de usuario'
                                                  : companyInfo.alias,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (userName.text.isNotEmpty) {
                                                var alias = userName.text;
                                                var exist =
                                                    await verifyExistingAlias(
                                                        alias);
                                                modalState(() {
                                                  isAliasValid = exist == true
                                                      ? true
                                                      : false;
                                                  companyInfo.alias =
                                                      exist == true
                                                          ? alias
                                                          : '';
                                                });
                                              }
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: Icon(
                                              isAliasValid != false
                                                  ? Icons.verified
                                                  : Icons.report_outlined,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'Categoría de la tienda',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    DropdownButton<String>(
                                      iconEnabledColor: Theme.of(context)
                                          .secondaryHeaderColor,
                                      alignment: Alignment.center,
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w300),
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                          child: Text('Turismo'),
                                          value: 'Turismo',
                                        ),
                                        DropdownMenuItem(
                                          child: Text('Alimentos y bebidas'),
                                          value: 'Alimentos y bebidas',
                                        ),
                                      ],
                                      onChanged: (change) {
                                        modalState(() {
                                          category = change??"";
                                        });
                                        companyInfo.category = change;
                                      },
                                      value: category,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'Plataforma de la tienda virtual',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    DropdownButton<String>(
                                      iconEnabledColor: Theme.of(context)
                                          .secondaryHeaderColor,
                                      alignment: Alignment.center,
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w300),
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                          child: Text('WooCommerce'),
                                          value: 'WooCommerce',
                                        ),
                                        DropdownMenuItem(
                                          child: Text('Shopify'),
                                          value: 'Shopify',
                                        ),
                                      ],
                                      onChanged: (change) {
                                        modalState(() {
                                          virtualStore = change??"";
                                        });
                                        companyInfo.storePlatform = change;
                                      },
                                      value: virtualStore,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'Página web',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    TextField(
                                      controller: webPage,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          companyInfo.webSite = text;
                                        } else if (text.length == 0) {
                                          companyInfo.webSite = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.url,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextMobile,
                                            fontWeight: FontWeight.w400),
                                        hintText: companyInfo.webSite == ''
                                            ? 'Página web'
                                            : companyInfo.webSite,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Container(
                              height: screenSizeHeight * 0.05,
                            ),
                            Text(
                              'Información de contacto',
                              style: TextStyle(
                                  color: Theme.of(context).dividerColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: secondaryTextMobile,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.01,
                            ),
                            Text(
                              'Esta información será visible para los usuarios',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: smallTextMobile,
                                  fontWeight: FontWeight.w300),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.015,
                            ),
                            Container(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(screenSizeHeight * 0.02)),
                                  color: Colors.white,
                                ),
                                child: ListView(
                                  padding: EdgeInsets.only(
                                    top: screenSizeHeight * 0.03,
                                    left: screenSizeWidth * 0.04,
                                    right: screenSizeWidth * 0.04,
                                    bottom: screenSizeHeight * 0.03,
                                  ),
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  children: [
                                    Text(
                                      'Celular de contacto',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    TextField(
                                      controller: businessPhone,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          companyInfo.phoneNumber = text;
                                        } else if (text.length == 0) {
                                          companyInfo.phoneNumber = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.phone,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextMobile,
                                            fontWeight: FontWeight.w400),
                                        hintText: companyInfo.phoneNumber == ''
                                            ? 'Celular'
                                            : companyInfo.phoneNumber,
                                      ),
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'Correo de contacto',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    TextField(
                                      controller: businessMail,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          companyInfo.email = text;
                                        } else if (text.length == 0) {
                                          companyInfo.email = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextMobile,
                                            fontWeight: FontWeight.w400),
                                        hintText: companyInfo.email == ''
                                            ? 'Correo'
                                            : companyInfo.email,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            Container(
                              height: screenSizeHeight * 0.045,
                            ),
                            GestureDetector(
                              onTap: () {
                                validateFieldsToSave();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    top: screenSizeHeight * 0.015,
                                    bottom: screenSizeHeight * 0.015),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            screenSizeHeight * 0.01))),
                                child: Text(
                                  'Guardar información',
                                  style: TextStyle(
                                      color: context.background,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Gotham',
                                      decoration: TextDecoration.none,
                                      fontSize: secondaryTextMobile,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ));
                },
              ));
    } else {
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            backgroundColor: context.background,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))),
            title: Container(),
            content: StatefulBuilder(
              builder: (context, modalState) {
                return Container(
                    height: screenSizeHeight * 0.75,
                    width: screenSizeWidth * 0.5,
                    child: Material(
                      color: context.background,
                      child: ListView(
                        padding: EdgeInsets.only(
                            top: screenSizeHeight * 0.03,
                            left: screenSizeHeight * 0.05,
                            right: screenSizeHeight * 0.05,
                            bottom: screenSizeHeight * 0.045
                        ),
                        physics: ScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          Container(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Icon(
                                Icons.close,
                                color: Theme.of(context).primaryColorLight,
                              ),
                            ),
                          ),

                          Text(
                            'Información adicional',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: titleWeb,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            height: screenSizeHeight * 0.015,
                          ),
                          Text(
                            'Requerimos de la siguiente información para vincular tu página web con Cumbia',
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: contentTextWeb,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            height: screenSizeHeight * 0.05,
                          ),
                          Text(
                            'Información personal',
                            style: TextStyle(
                                color: Theme.of(context).dividerColor,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: secondaryTextWeb,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.left,
                          ),
                          Container(
                            height: screenSizeHeight * 0.015,
                          ),
                          Container(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(screenSizeHeight * 0.02)),
                                color: Colors.white,
                              ),
                              child: ListView(
                                padding: EdgeInsets.only(
                                  top: screenSizeHeight * 0.03,
                                  left: screenSizeHeight * 0.04,
                                  right: screenSizeHeight * 0.04,
                                  bottom: screenSizeHeight * 0.03,
                                ),
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                children: [
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: ListView(
                                          shrinkWrap: true,
                                          physics: ScrollPhysics(),
                                          children: [
                                            Text(
                                              'Nombre',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: contentTextWeb,
                                                  fontWeight: FontWeight.w400),
                                              textAlign: TextAlign.left,
                                            ),
                                            Container(
                                              height: screenSizeHeight * 0.01,
                                            ),
                                            TextField(
                                              controller: name,
                                              onChanged: (text) {
                                                if (text.isNotEmpty) {
                                                  userInfo.name = text;
                                                } else if (text.length == 0) {
                                                  userInfo.name = '';
                                                }
                                              },
                                              onSubmitted: (text) async {},
                                              textCapitalization:
                                                  TextCapitalization.none,
                                              keyboardType: TextInputType.text,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: contentTextWeb,
                                                  fontWeight: FontWeight.w400),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                16)),
                                                    borderSide: BorderSide(
                                                        width: 0.5,
                                                        color: Theme.of(context)
                                                            .secondaryHeaderColor)),
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                16)),
                                                    borderSide: BorderSide(
                                                        width: 0.5,
                                                        color: Theme.of(context)
                                                            .secondaryHeaderColor)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                16)),
                                                    borderSide: BorderSide(
                                                        width: 0.5,
                                                        color: Theme.of(context)
                                                            .secondaryHeaderColor)),
                                                filled: true,
                                                fillColor: Colors.white,
                                                prefixIcon: Icon(
                                                  Icons.text_fields,
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor,
                                                ),
                                                hintStyle: TextStyle(
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextWeb,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                hintText: userInfo.name == ''
                                                    ? 'Tu nombre'
                                                    : userInfo.name,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Container(
                                        width: screenSizeWidth * 0.03,
                                      ),
                                      Expanded(
                                        child: ListView(
                                          shrinkWrap: true,
                                          physics: ScrollPhysics(),
                                          children: [
                                            Text(
                                              'Apellido',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .primaryColor,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: contentTextWeb,
                                                  fontWeight: FontWeight.w400),
                                              textAlign: TextAlign.left,
                                            ),
                                            Container(
                                              height: screenSizeHeight * 0.01,
                                            ),
                                            TextField(
                                              controller: lastName,
                                              onChanged: (text) {
                                                if (text.isNotEmpty) {
                                                  userInfo.lastName = text;
                                                } else if (text.length == 0) {
                                                  userInfo.lastName = '';
                                                }
                                              },
                                              onSubmitted: (text) async {},
                                              textCapitalization:
                                                  TextCapitalization.none,
                                              keyboardType: TextInputType.text,
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: contentTextWeb,
                                                  fontWeight: FontWeight.w400),
                                              decoration: InputDecoration(
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                16)),
                                                    borderSide: BorderSide(
                                                        width: 0.5,
                                                        color: Theme.of(context)
                                                            .secondaryHeaderColor)),
                                                enabledBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                16)),
                                                    borderSide: BorderSide(
                                                        width: 0.5,
                                                        color: Theme.of(context)
                                                            .secondaryHeaderColor)),
                                                focusedBorder: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
                                                                16)),
                                                    borderSide: BorderSide(
                                                        width: 0.5,
                                                        color: Theme.of(context)
                                                            .secondaryHeaderColor)),
                                                filled: true,
                                                fillColor: Colors.white,
                                                prefixIcon: Icon(
                                                  Icons.text_fields,
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor,
                                                ),
                                                hintStyle: TextStyle(
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextWeb,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                hintText:
                                                    userInfo.lastName == ''
                                                        ? 'Tus apellidos'
                                                        : userInfo.lastName,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.045,
                                  ),
                                  Text(
                                    'Celular',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.left,
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.01,
                                  ),
                                  Text(
                                    'Esta información no será visible para los usuarios, lo usaremos para contactarte desde Cumbia',
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: smallTextWeb,
                                        fontWeight: FontWeight.w300),
                                    textAlign: TextAlign.left,
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.015,
                                  ),
                                  TextField(
                                    controller: phone,
                                    onChanged: (text) {
                                      if (text.isNotEmpty) {
                                        userInfo.phoneNumber = text;
                                      } else if (text.length == 0) {
                                        userInfo.phoneNumber = '';
                                      }
                                    },
                                    onSubmitted: (text) async {},
                                    textCapitalization: TextCapitalization.none,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: Icon(
                                        Icons.text_fields,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                      hintStyle: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextWeb,
                                          fontWeight: FontWeight.w400),
                                      hintText: userInfo.phoneNumber == ''
                                          ? 'Tu número'
                                          : userInfo.phoneNumber,
                                    ),
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.045,
                                  ),
                                  Text(
                                    'Correo',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.left,
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.01,
                                  ),
                                  Text(
                                    'Esta información no será visible para los usuarios, lo usaremos para contactarte desde Cumbia',
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: smallTextWeb,
                                        fontWeight: FontWeight.w300),
                                    textAlign: TextAlign.left,
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.015,
                                  ),
                                  TextField(
                                    controller: mail,
                                    onChanged: (text) {
                                      if (text.isNotEmpty) {
                                        userInfo.secundaryEmail = text;
                                      } else if (text.length == 0) {
                                        userInfo.secundaryEmail = '';
                                      }
                                    },
                                    onSubmitted: (text) async {},
                                    textCapitalization: TextCapitalization.none,
                                    keyboardType: TextInputType.emailAddress,
                                    //enabled: false,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: Icon(
                                        Icons.text_fields,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                      hintStyle: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextWeb,
                                          fontWeight: FontWeight.w400),
                                      hintText: userInfo.secundaryEmail == ''
                                          ? 'Correo del usuario'
                                          : userInfo.secundaryEmail,
                                    ),
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.045,
                                  ),
                                  Text(
                                    'NIT',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.left,
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.01,
                                  ),
                                  TextField(
                                    controller: NIT,
                                    onChanged: (text) {
                                      if (text.isNotEmpty) {
                                        userInfo.nit = text;
                                      } else if (text.length == 0) {
                                        userInfo.nit = '';
                                      }
                                    },
                                    onSubmitted: (text) async {},
                                    textCapitalization: TextCapitalization.none,
                                    keyboardType: TextInputType.number,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: Icon(
                                        Icons.text_fields,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                      hintStyle: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextWeb,
                                          fontWeight: FontWeight.w400),
                                      hintText: userInfo.nit == ''
                                          ? 'Tu NIT'
                                          : userInfo.nit,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: screenSizeHeight * 0.05,
                          ),
                          Text(
                            'Información de empresa',
                            style: TextStyle(
                                color: Theme.of(context).dividerColor,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: secondaryTextWeb,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.left,
                          ),
                          Container(
                            height: screenSizeHeight * 0.01,
                          ),
                          Text(
                            'Esta información será visible para los usuarios',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: smallTextWeb,
                                fontWeight: FontWeight.w300),
                            textAlign: TextAlign.left,
                          ),
                          Container(
                            height: screenSizeHeight * 0.015,
                          ),
                          Container(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(screenSizeHeight * 0.02)),
                                color: Colors.white,
                              ),
                              child: ListView(
                                padding: EdgeInsets.only(
                                  top: screenSizeHeight * 0.03,
                                  left: screenSizeWidth * 0.04,
                                  right: screenSizeWidth * 0.04,
                                  bottom: screenSizeHeight * 0.03,
                                ),
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                children: [
                                  Text(
                                    'Nombre de la empresa',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.left,
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.01,
                                  ),
                                  TextField(
                                    controller: companyName,
                                    onChanged: (text) {
                                      if (text.isNotEmpty) {
                                        companyInfo.name = text;
                                      } else if (text.length == 0) {
                                        companyInfo.name = '';
                                      }
                                    },
                                    onSubmitted: (text) async {},
                                    textCapitalization: TextCapitalization.none,
                                    keyboardType: TextInputType.text,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: Icon(
                                        Icons.text_fields,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                      hintStyle: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextWeb,
                                          fontWeight: FontWeight.w400),
                                      hintText: companyInfo.name == ''
                                          ? 'Nombre de la empresa'
                                          : companyInfo.name,
                                    ),
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.045,
                                  ),
                                  Text(
                                    'Nombre de usuario',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.left,
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.01,
                                  ),
                                  Text(
                                    'Con este nombre los usuarios podrán encontrar tu tienda facilmente',
                                    style: TextStyle(
                                        color:
                                            Theme.of(context).primaryColorDark,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: smallTextWeb,
                                        fontWeight: FontWeight.w300),
                                    textAlign: TextAlign.left,
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.01,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 10,
                                        child: TextField(
                                          controller: userName,
                                          onChanged: (text) {
                                            if (text.isNotEmpty) {
                                              modalState(() {
                                                isAliasValid = false;
                                                companyInfo.alias = text;
                                              });
                                            } else if (text.length == 0) {
                                              modalState(() {
                                                isAliasValid = false;
                                                companyInfo.alias = '';
                                              });
                                            }
                                          },
                                          onSubmitted: (text) async {},
                                          textCapitalization:
                                              TextCapitalization.none,
                                          keyboardType: TextInputType.text,
                                          style: TextStyle(
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                              fontStyle: FontStyle.normal,
                                              fontFamily: 'Gotham',
                                              decoration: TextDecoration.none,
                                              fontSize: contentTextWeb,
                                              fontWeight: FontWeight.w400),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(16)),
                                                borderSide: BorderSide(
                                                    width: 0.5,
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor)),
                                            enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(16)),
                                                borderSide: BorderSide(
                                                    width: 0.5,
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor)),
                                            focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(16)),
                                                borderSide: BorderSide(
                                                    width: 0.5,
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor)),
                                            filled: true,
                                            fillColor: Colors.white,
                                            prefixIcon: Icon(
                                              Icons.text_fields,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                            ),
                                            hintStyle: TextStyle(
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: 'Gotham',
                                                decoration: TextDecoration.none,
                                                fontSize: contentTextWeb,
                                                fontWeight: FontWeight.w400),
                                            hintText: companyInfo.alias == ''
                                                ? 'Nombre de usuario'
                                                : companyInfo.alias,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 1,
                                        child: GestureDetector(
                                          onTap: () async {
                                            if (userName.text.isNotEmpty) {
                                              var alias = userName.text;
                                              var exist =
                                                  await verifyExistingAlias(
                                                      alias);
                                              modalState(() {
                                                isAliasValid = exist == true
                                                    ? true
                                                    : false;
                                                companyInfo.alias =
                                                    exist == true ? alias : '';
                                              });
                                            }
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Icon(
                                            isAliasValid != false
                                                ? Icons.verified
                                                : Icons.report_outlined,
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.045,
                                  ),
                                  Text(
                                    'Categoría de la tienda',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.left,
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.01,
                                  ),
                                  DropdownButton<String>(
                                    iconEnabledColor:
                                        Theme.of(context).secondaryHeaderColor,
                                    alignment: Alignment.center,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w300),
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                        child: Text('Turismo'),
                                        value: 'Turismo',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Alimentos y bebidas'),
                                        value: 'Alimentos y bebidas',
                                      ),
                                    ],
                                    onChanged: (change) {
                                      modalState(() {
                                        category = change??"";
                                      });
                                      companyInfo.category = change;
                                    },
                                    value: category,
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.045,
                                  ),
                                  Text(
                                    'Plataforma de la tienda virtual',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.left,
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.01,
                                  ),
                                  DropdownButton<String>(
                                    iconEnabledColor:
                                        Theme.of(context).secondaryHeaderColor,
                                    alignment: Alignment.center,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w300),
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(
                                        child: Text('WooCommerce'),
                                        value: 'WooCommerce',
                                      ),
                                      DropdownMenuItem(
                                        child: Text('Shopify'),
                                        value: 'Shopify',
                                      ),
                                    ],
                                    onChanged: (change) {
                                      modalState(() {
                                        virtualStore = change??"";
                                      });
                                      companyInfo.storePlatform = change;
                                    },
                                    value: virtualStore,
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.045,
                                  ),
                                  Text(
                                    'Página web',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.left,
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.01,
                                  ),
                                  TextField(
                                    controller: webPage,
                                    onChanged: (text) {
                                      if (text.isNotEmpty) {
                                        companyInfo.webSite = text;
                                      } else if (text.length == 0) {
                                        companyInfo.webSite = '';
                                      }
                                    },
                                    onSubmitted: (text) async {},
                                    textCapitalization: TextCapitalization.none,
                                    keyboardType: TextInputType.url,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: Icon(
                                        Icons.text_fields,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                      hintStyle: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextWeb,
                                          fontWeight: FontWeight.w400),
                                      hintText: companyInfo.webSite == ''
                                          ? 'Página web'
                                          : companyInfo.webSite,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: screenSizeHeight * 0.05,
                          ),
                          Text(
                            'Información de contacto',
                            style: TextStyle(
                                color: Theme.of(context).dividerColor,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: secondaryTextWeb,
                                fontWeight: FontWeight.w700),
                            textAlign: TextAlign.left,
                          ),
                          Container(
                            height: screenSizeHeight * 0.01,
                          ),
                          Text(
                            'Esta información será visible para los usuarios',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: smallTextWeb,
                                fontWeight: FontWeight.w300),
                            textAlign: TextAlign.left,
                          ),
                          Container(
                            height: screenSizeHeight * 0.015,
                          ),
                          Container(
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(screenSizeHeight * 0.02)),
                                color: Colors.white,
                              ),
                              child: ListView(
                                padding: EdgeInsets.only(
                                  top: screenSizeHeight * 0.03,
                                  left: screenSizeWidth * 0.04,
                                  right: screenSizeWidth * 0.04,
                                  bottom: screenSizeHeight * 0.03,
                                ),
                                shrinkWrap: true,
                                physics: ScrollPhysics(),
                                children: [
                                  Text(
                                    'Celular de contacto',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.left,
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.01,
                                  ),
                                  TextField(
                                    controller: businessPhone,
                                    onChanged: (text) {
                                      if (text.isNotEmpty) {
                                        companyInfo.phoneNumber = text;
                                      } else if (text.length == 0) {
                                        companyInfo.phoneNumber = '';
                                      }
                                    },
                                    onSubmitted: (text) async {},
                                    textCapitalization: TextCapitalization.none,
                                    keyboardType: TextInputType.phone,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: Icon(
                                        Icons.text_fields,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                      hintStyle: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextWeb,
                                          fontWeight: FontWeight.w400),
                                      hintText: companyInfo.phoneNumber == ''
                                          ? 'Celular'
                                          : companyInfo.phoneNumber,
                                    ),
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.045,
                                  ),
                                  Text(
                                    'Correo de contacto',
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    textAlign: TextAlign.left,
                                  ),
                                  Container(
                                    height: screenSizeHeight * 0.01,
                                  ),
                                  TextField(
                                    controller: businessMail,
                                    onChanged: (text) {
                                      if (text.isNotEmpty) {
                                        companyInfo.email = text;
                                      } else if (text.length == 0) {
                                        companyInfo.email = '';
                                      }
                                    },
                                    onSubmitted: (text) async {},
                                    textCapitalization: TextCapitalization.none,
                                    keyboardType: TextInputType.emailAddress,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w400),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: Icon(
                                        Icons.text_fields,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                      hintStyle: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextWeb,
                                          fontWeight: FontWeight.w400),
                                      hintText: companyInfo.email == ''
                                          ? 'Correo'
                                          : companyInfo.email,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Container(
                            height: screenSizeHeight * 0.045,
                          ),
                          GestureDetector(
                            onTap: () {
                              validateFieldsToSave();
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              alignment: Alignment.center,
                              padding: EdgeInsets.only(
                                  top: screenSizeHeight * 0.015,
                                  bottom: screenSizeHeight * 0.015),
                              decoration: BoxDecoration(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          screenSizeHeight * 0.01))),
                              child: Text(
                                'Guardar información',
                                style: TextStyle(
                                    color: context.background,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Gotham',
                                    decoration: TextDecoration.none,
                                    fontSize: secondaryTextWeb,
                                    fontWeight: FontWeight.w700),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ));
              },
            ),
          );
        },
      );
    }
  }

  Future<bool> verifyExistingAlias(String alias) async {
    var ref = await _db
        .collection('companies')
        .where('alias', isEqualTo: alias)
        .get();

    if (ref.docs.isEmpty) {
      //do nothing
      return true;
    } else {
      //var election = ref.docs.first.data();
      //Users usr = Users.fromMap(election);
      return false;
    }
  }

  validatePassToStream(screenSizeHeight, screenSizeWidth, BuildContext context) async {
    productsSelected.clear();
    print(":companyInfo.webSite--- ${companyInfo.webSite} storePlatform- ${companyInfo.storePlatform}");
    if (companyInfo.webSite == '' || companyInfo.storePlatform == '') {
      dialogToStart(screenSizeHeight, screenSizeWidth);
    } else {
      // dialogToStartProducts(screenSizeHeight, screenSizeWidth, context);
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => NewEventScreen(),
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return child;
          },
        ),
      );
      // Navigator.of(context).push(
      //   PageRouteBuilder(
      //     pageBuilder: (context, animation, secondaryAnimation) => EventsPage(),
      //     transitionDuration: Duration.zero,
      //     reverseTransitionDuration: Duration.zero,
      //     transitionsBuilder: (context, animation, secondaryAnimation, child) {
      //       return child;
      //     },
      //   ),
      // );
    }
  }

  // mostrar si no completo el perfiln
  dialogToStart(screenSizeHeight, screenSizeWidth) {
    if (screenSizeHeight >= screenSizeWidth) {
      showModalBottomSheet(
          //expand: true,
          context: context,
          backgroundColor: context.background,
          builder: (context) => StatefulBuilder(
                builder: (context, modalState) {
                  return Container(
                      height: screenSizeHeight * 0.5,
                      child: Material(
                        child: ListView(
                          padding: EdgeInsets.only(
                              top: screenSizeHeight * 0.045,
                              left: screenSizeWidth * 0.05,
                              right: screenSizeWidth * 0.05,
                              bottom: screenSizeHeight * 0.045),
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Container(
                              height: screenSizeHeight * 0.15,
                              width: screenSizeWidth * 0.1,
                              decoration: BoxDecoration(
                                  image: DecorationImage(
                                      image: AssetImage('assets/img/icon.png'),
                                      fit: BoxFit.contain)),
                            ),
                            Container(
                              height: screenSizeHeight * 0.03,
                            ),
                            Text(
                              'Termina de configurar tu perfil',
                              style: TextStyle(
                                  color: Theme.of(context).focusColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: secondaryTextMobile,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              height: screenSizeHeight * 0.015,
                            ),
                            Text(
                              'Completa de configurar tu cuenta para poder realizar tu primer Live Streaming',
                              style: TextStyle(
                                  color: Theme.of(context).focusColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextMobile,
                                  fontWeight: FontWeight.w300),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              height: screenSizeHeight * 0.06,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    top: screenSizeHeight * 0.015,
                                    bottom: screenSizeHeight * 0.015),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            screenSizeHeight * 0.01))),
                                child: Text(
                                  '¡Aceptar!',
                                  style: TextStyle(
                                      color: context.background,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Gotham',
                                      decoration: TextDecoration.none,
                                      fontSize: contentTextMobile,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        ),
                      ));
                },
              ));
    } else {
      showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        alignment: Alignment.center,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(screenSizeHeight * 0.03))),
            /*title: Text('Crear nueva cuenta', style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                fontSize: secondaryTextWeb, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),*/
            backgroundColor: Colors.white,
            child: Container(
              padding: EdgeInsets.all(screenSizeHeight * 0.03),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(screenSizeHeight * 0.02)),
              ),
              width: screenSizeWidth * 0.35,
              child: ListView(
                padding: EdgeInsets.only(
                  top: 0,
                  left: screenSizeWidth * 0.03,
                  right: screenSizeWidth * 0.03,
                  bottom: screenSizeHeight * 0.03,
                ),
                shrinkWrap: true,
                physics: ScrollPhysics(),
                children: [
                  Container(
                    height: screenSizeHeight * 0.03,
                  ),
                  Container(
                    height: screenSizeHeight * 0.15,
                    width: screenSizeWidth * 0.1,
                    decoration: BoxDecoration(
                        image: DecorationImage(
                            image: AssetImage('assets/img/icon.png'),
                            fit: BoxFit.contain)),
                  ),
                  Container(
                    height: screenSizeHeight * 0.03,
                  ),
                  Text(
                    'Termina de configurar tu perfil',
                    style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontStyle: FontStyle.normal,
                        fontFamily: 'Gotham',
                        decoration: TextDecoration.none,
                        fontSize: secondaryTextWeb,
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    height: screenSizeHeight * 0.015,
                  ),
                  Text(
                    'Completa de configurar tu cuenta para poder realizar tu primer Live Streaming',
                    style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontStyle: FontStyle.normal,
                        fontFamily: 'Gotham',
                        decoration: TextDecoration.none,
                        fontSize: contentTextWeb,
                        fontWeight: FontWeight.w300),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    height: screenSizeHeight * 0.06,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(
                          top: screenSizeHeight * 0.015,
                          bottom: screenSizeHeight * 0.015),
                      decoration: BoxDecoration(
                          color: Theme.of(context).secondaryHeaderColor,
                          borderRadius: BorderRadius.all(
                              Radius.circular(screenSizeHeight * 0.01))),
                      child: Text(
                        '¡Aceptar!',
                        style: TextStyle(
                            color: context.background,
                            fontStyle: FontStyle.normal,
                            fontFamily: 'Gotham',
                            decoration: TextDecoration.none,
                            fontSize: contentTextWeb,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 200),
      );
    }
  }

  // dialogo de productos previos al stream
  dialogToStartProducts(screenSizeHeight, screenSizeWidth, BuildContext context) {
    var products = [];
    if (allProducts.ecommercePlatform == 'WooCommerce') {
      products = allProducts.wooProducts??[];
      print("allProducts---WooCommerce- $products");
    } else if (allProducts.ecommercePlatform == 'Shopify') {
      products = allProducts.shopProducts??[];
      print("allProducts---Shopify- $products");
    }
    if (screenSizeHeight >= screenSizeWidth) {
      showModalBottomSheet(context: context,backgroundColor: context.background,builder: (context) => StatefulBuilder(
                builder: (context, modalState) {
                  return Container(
                      height: screenSizeHeight * 0.95,
                      child: Material(
                        child: ListView(
                          padding: EdgeInsets.only(
                            top: screenSizeHeight * 0.045,
                            left: screenSizeWidth * 0.05,
                            right: screenSizeWidth * 0.05,
                          ),
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Icon(
                                  Icons.close,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                              ),
                            ),
                            Text(
                              'Selecciona los productos que se mostrarán en el Stream',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: titleMobile,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              height: screenSizeHeight * 0.03,
                            ),
                            /*Visibility(
                          visible: allProducts.length == 0 ? false : true,
                          child: ListView.builder(
                            padding: EdgeInsets.only(top: 0),
                            physics: ScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: allProducts.length == 0 ? 1: allProducts.length,
                            itemBuilder: (context, int index) => cellsProducts2(index, screenSizeWidth, screenSizeHeight, modalState),
                          ),
                        ),*/
                            Visibility(
                              visible: products.length == 0 ? false : true,
                              child: GridView.builder(
                                padding: EdgeInsets.only(top: 0),
                                physics: ScrollPhysics(),
                                shrinkWrap: true,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  childAspectRatio: 0.7,
                                  crossAxisSpacing: screenSizeHeight * 0.05,
                                  mainAxisSpacing: screenSizeHeight * 0.1,
                                  crossAxisCount: 2,
                                ),
                                itemCount:
                                    products.length == 0 ? 1 : products.length,
                                itemBuilder: (context, int index) =>
                                    productShowWidget(index, screenSizeWidth,
                                        screenSizeHeight, modalState),
                              ),
                            ),
                            Visibility(
                                visible: products.length == 0 ? true : false,
                                child: CupertinoActivityIndicator()),
                            Container(
                              height: screenSizeHeight * 0.03,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                //var roomID = Uuid().v4();
                                //var roomID = '002';
                                // if (userInfo.plan?.status == 'Activo') {
                                  saveNewStreamData();
                                // } else {
                                //   dialogMessage(
                                //       'assets/img/error.png',
                                //       'Lo sentimos',
                                //       'No puede generar un stream si no cuenta con una suscripción activa');
                                // }
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    top: screenSizeHeight * 0.015,
                                    bottom: screenSizeHeight * 0.015),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            screenSizeHeight * 0.01))),
                                child: Text(
                                  '¡Iniciar Stream!',
                                  style: TextStyle(
                                      color: context.background,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Gotham',
                                      decoration: TextDecoration.none,
                                      fontSize: contentTextMobile,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Container(
                              height: screenSizeHeight * 0.015,
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    top: screenSizeHeight * 0.015,
                                    bottom: screenSizeHeight * 0.015),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                        color: Theme.of(context).primaryColor),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            screenSizeHeight * 0.01))),
                                child: Text(
                                  'Cancelar',
                                  style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Gotham',
                                      decoration: TextDecoration.none,
                                      fontSize: contentTextMobile,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Container(
                              height: screenSizeHeight * 0.03,
                            ),
                          ],
                        ),
                      ));
                },
              ));
    } else {
      showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        alignment: Alignment.center,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, modalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(screenSizeHeight * 0.02),
              ),
              backgroundColor: Colors.white,
              child: Container(
                width: screenSizeWidth * 0.7,
                padding: EdgeInsets.all(screenSizeHeight * 0.03),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(screenSizeHeight * 0.02),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Selecciona los productos que aparecerán en el Stream',
                      style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontFamily: 'Gotham',
                        fontSize: primaryTextWeb,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.none,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    SizedBox(height: screenSizeHeight * 0.03),

                    // Product Grid or Loader
                    if (products.isNotEmpty)
                      Flexible(
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.zero,
                          itemCount: products.length,
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            crossAxisSpacing: screenSizeHeight * 0.04,
                            mainAxisSpacing: screenSizeHeight * 0.03,
                            childAspectRatio: 0.7,
                          ),
                          itemBuilder: (context, index) => productShowWidget(
                            index,
                            screenSizeWidth,
                            screenSizeHeight,
                            modalState,
                          ),
                        ),
                      )
                    else
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: screenSizeHeight * 0.04),
                        child: CupertinoActivityIndicator(),
                      ),

                    SizedBox(height: screenSizeHeight * 0.03),

                    // Action Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildDialogButton(
                          context: context,
                          text: 'Cancelar',
                          width: screenSizeWidth * 0.2,
                          bgColor: Colors.white,
                          textColor: Theme.of(context).primaryColor,
                          borderColor: Theme.of(context).primaryColor,
                          onTap: () => Navigator.pop(context),
                        ),
                        SizedBox(width: screenSizeWidth * 0.045),
                        _buildDialogButton(
                          context: context,
                          text: '¡Iniciar Stream!',
                          width: screenSizeWidth * 0.2,
                          bgColor: Theme.of(context).secondaryHeaderColor,
                          textColor: context.background,
                          onTap: () {
                            Navigator.pop(context);
                            saveNewStreamData();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          });
        },
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 200),
      );
    }
  }

  Widget _buildDialogButton({
    required BuildContext context,
    required String text,
    required double width,
    required Color bgColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        alignment: Alignment.center,
        width: width,
        padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height * 0.015),
        decoration: BoxDecoration(
          color: bgColor,
          border: borderColor != null ? Border.all(color: borderColor) : null,
          borderRadius: BorderRadius.circular(MediaQuery.of(context).size.height * 0.01),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontFamily: 'Gotham',
            fontSize: contentTextWeb,
            fontWeight: FontWeight.w700,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }

  saveNewStreamData() async {
    /*print('Total de productos seleccionados: ${productsSelected.length}');
    productsSelected.forEach((element) {
      if (companyInfo.storePlatform == 'WooCommerce') {
        WooProduct prod = element;
        print('Está seleccionado el producto: ${prod.toJson()}');
      } else if (companyInfo.storePlatform == 'Shopify') {
        ShopifyProduct prod = element;
        print('Está seleccionado el producto: ${prod.toJson()}');
      }
    });*/

    var streamID = Uuid().v4();
    var roomID = Uuid().v4();

    StreamsData saveStream = StreamsData(
        streamID: streamID,
        roomID: roomID,
        createdBy: userInfo.userUID,
        businessID: companyInfo.companyID,
        status: 'En espera',
        ecommercePlatform: companyInfo.storePlatform);

    var refCompany = _db.collection('streams').doc(streamID);
    // await _db.collection('streams').doc(widget.stream?.streamID).update({'status': status});
    // final copyUrl = html.window.location.href + "" + streamId;



    refCompany
        .set(saveStream.createStream(productsSelected))
        .whenComplete(() async {
          final copyUrl = html.window.location.href + "#/liveStream/" + "${saveStream.streamID ?? ''}";
        print("** wk url: $copyUrl");
        Clipboard.setData(ClipboardData(text: copyUrl)).then((_) {
          print("Text copied to clipboard!");
        });
      Navigator.of(context).push(CupertinoPageRoute(
          builder: (context) => CallPage(
                localUserID: userInfo.userUID,
                localUserName: companyInfo.name,
                roomID: roomID,
                stream: saveStream,
              )));
    }).catchError((error) {
      //Hubo error al crear negocio

      dialogMessage('assets/img/error.png', 'Lo sentimos',
          'Ocurrió un error al generar información de stream. Inténtelo de nuevo más tarde');
    });
  }

  dialogToPrivacy(screenSizeHeight, screenSizeWidth) {
    bool? accepted = false;

    accepted = companyInfo.acceptTermsAndConditions;

    if (screenSizeHeight >= screenSizeWidth) {
      showModalBottomSheet(
          //expand: true,
          context: context,
          backgroundColor: context.background,
          builder: (context) => StatefulBuilder(
                builder: (context, modalState) {
                  return Container(
                      height: screenSizeHeight * 0.95,
                      child: Material(
                        child: ListView(
                          padding: EdgeInsets.only(
                            top: screenSizeHeight * 0.045,
                            left: screenSizeWidth * 0.05,
                            right: screenSizeWidth * 0.05,
                          ),
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Icon(
                                  Icons.close,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                              ),
                            ),
                            Text(
                              'Política de privacidad de CumbiaLive',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: titleMobile,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              height: screenSizeHeight * 0.03,
                            ),
                            Container(
                              height: screenSizeHeight * 0.6,
                              //todo enlace de la policita de privacida
                              child: SfPdfViewer.asset(
                                'assets/pdf/privacy.pdf',
                                pageLayoutMode: PdfPageLayoutMode.continuous,
                                scrollDirection: PdfScrollDirection.vertical,
                                controller: _pdfViewerController,
                                enableDoubleTapZooming: false,
                                key: _pdfViewerStateKey,
                              ),
                            ),
                            Container(
                              height: screenSizeHeight * 0.03,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    'Confirmo estar de acuerdo con los términso y condiciones y la política de privacidad',
                                    style: TextStyle(
                                        color: Theme.of(context).focusColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextMobile,
                                        fontWeight: FontWeight.w300),
                                    textAlign: TextAlign.left,
                                  ),
                                ),
                                Container(
                                  width: screenSizeWidth * 0.015,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    if (accepted == false) {
                                      modalState(() {
                                        accepted = true;
                                      });
                                    } else {
                                      modalState(() {
                                        accepted = false;
                                      });
                                    }
                                    saveChangesInAcceptancePrivacyPolicy(
                                        accepted!);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Icon(
                                    accepted == false
                                        ? Icons.check_box_outline_blank
                                        : Icons.check_box,
                                    color: accepted == false
                                        ? Theme.of(context).primaryColorDark
                                        : Theme.of(context)
                                            .secondaryHeaderColor,
                                    size: screenSizeWidth * 0.04,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ));
                },
              ));
    } else {
      showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        alignment: Alignment.center,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, modalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(screenSizeHeight * 0.02))),
              backgroundColor: Colors.white,
              child: Container(
                padding: EdgeInsets.all(screenSizeHeight * 0.03),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(screenSizeHeight * 0.02)),
                ),
                width: screenSizeWidth * 0.7,
                child: ListView(
                  padding: EdgeInsets.only(
                    top: 0,
                  ),
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: [
                    Text(
                      'Política de privacidad de CumbiaLive',
                      style: TextStyle(
                          color: Theme.of(context).focusColor,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Gotham',
                          decoration: TextDecoration.none,
                          fontSize: primaryTextWeb,
                          fontWeight: FontWeight.w400),
                      textAlign: TextAlign.left,
                    ),
                    Container(
                      height: screenSizeHeight * 0.015,
                    ),
                    Container(
                      height: screenSizeHeight * 0.7,
                      //todo enlace de la policita de privacida
                      child: SfPdfViewer.asset(
                        'assets/pdf/privacy.pdf',
                        pageLayoutMode: PdfPageLayoutMode.continuous,
                        scrollDirection: PdfScrollDirection.vertical,
                        controller: _pdfViewerController,
                        enableDoubleTapZooming: false,
                        key: _pdfViewerStateKey,
                      ),
                    ),
                    Container(
                      height: screenSizeHeight * 0.015,
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Confirmo estar de acuerdo con los términso y condiciones y la política de privacidad',
                          style: TextStyle(
                              color: Theme.of(context).focusColor,
                              fontStyle: FontStyle.normal,
                              fontFamily: 'Gotham',
                              decoration: TextDecoration.none,
                              fontSize: contentTextWeb,
                              fontWeight: FontWeight.w300),
                          textAlign: TextAlign.left,
                        ),
                        GestureDetector(
                          onTap: () {
                            if (accepted == false) {
                              modalState(() {
                                accepted = true;
                              });
                            } else {
                              modalState(() {
                                accepted = false;
                              });
                            }
                            saveChangesInAcceptancePrivacyPolicy(accepted!);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Icon(
                            accepted == false
                                ? Icons.check_box_outline_blank
                                : Icons.check_box,
                            color: accepted == false
                                ? Theme.of(context).primaryColorDark
                                : Theme.of(context).secondaryHeaderColor,
                            size: screenSizeHeight * 0.04,
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          });
        },
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 200),
      );
    }
  }

  saveChangesInAcceptancePrivacyPolicy(bool isAccepted) async {
    var refCompany = _db.collection('companies').doc(companyInfo.companyID);

    refCompany
        .update({
          'acceptTermsAndConditions': isAccepted,
        })
        .whenComplete(() async {})
        .catchError((error) {
          //Hubo error al crear negocio
        });
  }

  var userPlatformSelected = 'WooCommerce';
  //List<String> userProducts = [];

  dialogToConnectWeb(screenSizeHeight, screenSizeWidth) {
    userPlatformSelected = (companyInfo.storePlatform == ''
        ? 'WooCommerce'
        : companyInfo.storePlatform)!;
    var products = [];
    if (allProducts.ecommercePlatform == 'WooCommerce') {
      products = allProducts.wooProducts??[];
    } else if (allProducts.ecommercePlatform == 'Shopify') {
      products = allProducts.shopProducts??[];
    }
    final RegExp urlRegExp = RegExp(
      r"^(https?|ftp)://[^\s/$.?#].[^\s]*$",
      caseSensitive: false,
    );
    bool isButtonDisable=true;
    urlController.text='';
    vinculationID.text='';
    vinculationSecretID.text='';
    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      alignment: Alignment.center,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, modalState) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                    Radius.circular(screenSizeHeight * 0.02))),
            backgroundColor: Colors.white,
            child: Container(
              padding: EdgeInsets.all(screenSizeHeight * 0.03),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(
                    Radius.circular(screenSizeHeight * 0.02)),
              ),
              width: screenSizeWidth * 0.5,
              child: ListView(
                padding: EdgeInsets.only(
                  top: 0,
                ),
                shrinkWrap: true,
                physics: ScrollPhysics(),
                children: [
                  Text(
                    'Vinculación de tu Ecommerce',
                    style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontStyle: FontStyle.normal,
                        fontFamily: 'Gotham',
                        decoration: TextDecoration.none,
                        fontSize: primaryTextWeb,
                        fontWeight: FontWeight.w400),
                    textAlign: TextAlign.left,
                  ),
                  Container(
                    height: screenSizeHeight * 0.01,
                  ),
                  Text(
                    'Vincula tu página de Ecommerce para que puedas iniciar a trasmitir en CumbiaLive',
                    style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontStyle: FontStyle.normal,
                        fontFamily: 'Gotham',
                        decoration: TextDecoration.none,
                        fontSize: contentTextWeb,
                        fontWeight: FontWeight.w300),
                    textAlign: TextAlign.left,
                  ),
                  Container(
                    height: screenSizeHeight * 0.015,
                  ),
                  DropdownButton<String>(
                    iconEnabledColor: Theme.of(context).secondaryHeaderColor,
                    alignment: Alignment.center,
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontStyle: FontStyle.normal,
                        fontFamily: 'Gotham',
                        decoration: TextDecoration.none,
                        fontSize: contentTextWeb,
                        fontWeight: FontWeight.w300),
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(
                        child: Text('WooCommerce'),
                        value: 'WooCommerce',
                      ),
                      DropdownMenuItem(
                        child: Text('Shopify'),
                        value: 'Shopify',
                      ),
                    ],
                    onChanged: (change) {
                      modalState(() {
                        vinculationID.text='';
                        vinculationSecretID.text='';
                        urlController.text='';
                        userPlatformSelected = change??"";
                      });
                    },
                    value: userPlatformSelected,
                  ),
                  Container( height: screenSizeHeight * 0.015 ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 8,
                        child: TextField(
                          controller: urlController,
                          onChanged: (text) {
                            modalState(() {
                              if (userPlatformSelected == 'WooCommerce'){
                                if(!urlRegExp.hasMatch(urlController.text)||urlController.text==''||vinculationID.text==''||vinculationSecretID.text==''){
                                  isButtonDisable=true;
                                }else{
                                  isButtonDisable=false;
                                }
                              }else{
                                if(!urlRegExp.hasMatch(urlController.text)||urlController.text==''||vinculationID.text==''){
                                  isButtonDisable=true;
                                }else{
                                  isButtonDisable=false;
                                }
                              }
                            });
                          },
                          onSubmitted: (text) async {},
                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.url,
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontStyle: FontStyle.normal,
                              fontFamily: 'Gotham',
                              decoration: TextDecoration.none,
                              fontSize: contentTextWeb,
                              fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(
                                width: 0.5,
                                color: Theme.of(context)
                                    .secondaryHeaderColor)),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(
                              Icons.text_fields,
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                            hintStyle: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: contentTextWeb,
                                fontWeight: FontWeight.w300),
                                // hintText:"Introduzca la URL de su web",
                                hintText:companyInfo.storePlatform==userPlatformSelected? companyInfo.webSite==''?'Introduzca la URL de su web':companyInfo.webSite:'Introduzca la URL de su web',
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              Clipboard.getData(Clipboard.kTextPlain)
                                  .then((value) {
                                modalState(() {
                                  urlController.text = value?.text??"";
                                });
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Icon(
                              Icons.paste,
                              color: Theme.of(context).secondaryHeaderColor,
                              size: screenSizeHeight * 0.05,
                            ),
                          )),
                    ],
                  ),
                  Container(
                    height: screenSizeHeight * 0.015,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 8,
                        child: TextField(
                          controller: vinculationID,
                          onChanged: (text) {

                            modalState(() {
                              if (userPlatformSelected == 'WooCommerce'){
                                if(!urlRegExp.hasMatch(urlController.text)||urlController.text==''||vinculationID.text==''||vinculationSecretID.text==''){
                                  isButtonDisable=true;
                                }else{
                                  isButtonDisable=false;
                                }
                              }else{
                                if(!urlRegExp.hasMatch(urlController.text)||urlController.text==''||vinculationID.text==''){
                                  isButtonDisable=true;
                                }else{
                                  isButtonDisable=false;
                                }
                              }
                            });

                          },
                          onSubmitted: (text) async {},
                          textCapitalization: TextCapitalization.none,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                              color: Theme.of(context).secondaryHeaderColor,
                              fontStyle: FontStyle.normal,
                              fontFamily: 'Gotham',
                              decoration: TextDecoration.none,
                              fontSize: contentTextWeb,
                              fontWeight: FontWeight.w300),
                          decoration: InputDecoration(
                            border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(
                                width: 0.5,
                                color: Theme.of(context)
                                    .secondaryHeaderColor)),
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: Icon(
                              Icons.text_fields,
                              color: Theme.of(context).secondaryHeaderColor,
                            ),
                            hintStyle: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: contentTextWeb,
                                fontWeight: FontWeight.w300),
                            hintText: userPlatformSelected == 'WooCommerce'&& companyInfo.storePlatform=="WooCommerce"
                                ? companyInfo.consumerKey!=''?companyInfo.consumerKey:'Introduce tu Client ID de $userPlatformSelected'
                                : companyInfo.accessToken!=''&&companyInfo.storePlatform=="Shopify"&& userPlatformSelected == 'Shopify'?companyInfo.accessToken:'Introduce tu Access Token de $userPlatformSelected',
                            //hintText: companyInfo.consumerKey == '' ? userPlatformSelected == 'WooCommerce' ? 'Introduce tu Client ID de $userPlatformSelected' : 'Introduce tu Access Token de $userPlatformSelected' : companyInfo.consumerKey,
                          ),
                        ),
                      ),
                      Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () {
                              Clipboard.getData(Clipboard.kTextPlain)
                                  .then((value) {
                                modalState(() {
                                  vinculationID.text = value?.text??"";
                                });
                              });
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Icon(
                              Icons.paste,
                              color: Theme.of(context).secondaryHeaderColor,
                              size: screenSizeHeight * 0.05,
                            ),
                          )),
                    ],
                  ),
                  Visibility(
                    visible: userPlatformSelected == 'WooCommerce' ? true : false,
                    child: Container(
                      height: screenSizeHeight * 0.015,
                    ),
                  ),
                  Visibility(
                    visible:
                    userPlatformSelected == 'WooCommerce' ? true : false,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          flex: 8,
                          child: TextField(
                            controller: vinculationSecretID,
                            onChanged: (text) {
                              modalState(() {
                                if (userPlatformSelected == 'WooCommerce'){
                                  if(!urlRegExp.hasMatch(urlController.text)||urlController.text==''||vinculationID.text==''||vinculationSecretID.text==''){
                                    isButtonDisable=true;
                                  }else{
                                    isButtonDisable=false;
                                  }
                                }else{
                                  if(!urlRegExp.hasMatch(urlController.text)||urlController.text==''||vinculationID.text==''){
                                    isButtonDisable=true;
                                  }else{
                                    isButtonDisable=false;
                                  }
                                }
                              });

                            },
                            onSubmitted: (text) async {},
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: contentTextWeb,
                                fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                                  borderSide: BorderSide(
                                      width: 0.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.all(Radius.circular(16)),
                                  borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                  BorderRadius.all(Radius.circular(16)),
                                  borderSide: BorderSide(
                                      width: 0.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.text_fields,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                              hintStyle: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w300),
                                  hintText: userPlatformSelected == 'WooCommerce'&& companyInfo.storePlatform=="WooCommerce"?
                                  companyInfo.consumerSecret!=''?companyInfo.consumerSecret:'Introduce tu Secret Client ID de $userPlatformSelected':"Introduce tu Secret Client ID de $userPlatformSelected",
                              //     : companyInfo.consumerSecret,
                            ),
                          ),
                        ),
                        Expanded(
                            flex: 1,
                            child: GestureDetector(
                              onTap: () {
                                Clipboard.getData(Clipboard.kTextPlain).then((value) {
                                  modalState(() {
                                    vinculationSecretID.text = value?.text??"";
                                  });
                                });
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Icon(
                                Icons.paste,
                                color: Theme.of(context).secondaryHeaderColor,
                                size: screenSizeHeight * 0.05,
                              ),
                            )),
                      ],
                    ),
                  ),
                  Container(
                    height: screenSizeHeight * 0.015,
                  ),
                  GestureDetector(
                    onTap: () async{
                      if(!isButtonDisable){

                      companyInfo.webSite =urlController.text;
                      companyInfo.consumerSecret =vinculationSecretID.text;

                      allProducts.wooProducts?.clear();
                      allProducts.shopProducts?.clear();
                      companyInfo.storePlatform=userPlatformSelected;
                        if (userPlatformSelected == 'WooCommerce') {
                          companyInfo.consumerKey =vinculationID.text;
                          await validateFieldsToSaveStoreIDS(modalState);
                          products = [];
                          if (allProducts.ecommercePlatform == 'WooCommerce') {
                            products = allProducts.wooProducts??[];
                          } else if (allProducts.ecommercePlatform == 'Shopify') {
                            products = allProducts.shopProducts??[];
                          }
                          log('Home WooCommerce');
                          modalState(() { });
                        } else if (userPlatformSelected == 'Shopify') {
                          companyInfo.accessToken =vinculationID.text;
                          await validateFieldsToSaveShopifyIDS(modalState);
                          products = [];
                          if (allProducts.ecommercePlatform == 'WooCommerce') {
                            products = allProducts.wooProducts??[];
                          } else if (allProducts.ecommercePlatform == 'Shopify') {
                            products = allProducts.shopProducts??[];
                          }
                          log('home Shopify');
                          modalState(() { });
                        }
                      }
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(
                          top: screenSizeHeight * 0.015,
                          bottom: screenSizeHeight * 0.015),
                      decoration: BoxDecoration(
                          color: isButtonDisable ?Colors.grey:Theme.of(context).secondaryHeaderColor,
                          borderRadius: BorderRadius.all(
                              Radius.circular(screenSizeHeight * 0.01))),
                      child: Text(
                        '¡Enlazar!',
                        style: TextStyle(
                            color: context.background,
                            fontStyle: FontStyle.normal,
                            fontFamily: 'Gotham',
                            decoration: TextDecoration.none,
                            fontSize: contentTextWeb,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  Container(
                    height: screenSizeHeight * 0.045,
                  ),
                  Visibility(
                    visible :userPlatformSelected != companyInfo.storePlatform|| products.length == 0 || allProducts == null ? false : true,
                    child: ListView.builder(
                      padding: EdgeInsets.only(top: 0),
                      physics: ScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: products.length == 0 ? 1 : products.length,
                      itemBuilder: (context, int index) => cellsProducts(
                          index, screenSizeWidth, screenSizeHeight),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
      },
      animationType: DialogTransitionType.fadeScale,
      curve: Curves.easeIn,
      duration: Duration(milliseconds: 200),
    );
  }

  Widget cellsProducts(index, screenSizeWidth, screenSizeHeight) {
    var products = [];
    if (allProducts.ecommercePlatform == 'WooCommerce') {
      products = allProducts.wooProducts??[];
    } else if (allProducts.ecommercePlatform == 'Shopify') {
      products = allProducts.shopProducts??[];
    }
    return Container(
      alignment: Alignment.center,
      child: ListView(
        padding: EdgeInsets.only(top: 0),
        physics: ScrollPhysics(),
        shrinkWrap: true,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  '${allProducts.shopProducts?[index].title}',
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontStyle: FontStyle.normal,
                      fontFamily: 'Gotham',
                      decoration: TextDecoration.none,
                      fontSize: contentTextWeb,
                      fontWeight: FontWeight.w400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.start,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '${allProducts.shopProducts?[index].productType}',
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontStyle: FontStyle.normal,
                      fontFamily: 'Gotham',
                      decoration: TextDecoration.none,
                      fontSize: smallTextWeb,
                      fontWeight: FontWeight.w400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  '\$${allProducts.shopProducts?[index].price}',
                  style: TextStyle(
                      color: Theme.of(context).secondaryHeaderColor,
                      fontStyle: FontStyle.normal,
                      fontFamily: 'Gotham',
                      decoration: TextDecoration.none,
                      fontSize: contentTextWeb,
                      fontWeight: FontWeight.w400),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          Container(
            height: screenSizeHeight * 0.01,
          ),
          Divider(),
          Container(
            height: screenSizeHeight * 0.01,
          ),
        ],
      ),
    );
  }

  Widget productShowWidget(index, screenSizeWidth, screenSizeHeight, modalState) {
    List<ShopifyProductModel>  products = allProducts.shopProducts??[];
    return Container(
      child: GestureDetector(
        onTap: () {
          if (productsSelected.contains(products[index])) {
            var support =
            productsSelected.indexOf(products[index]);
            modalState(() {
              productsSelected.removeAt(support);
            });
          } else {
            modalState(() {
              products[index].from=null;
              productsSelected.add(products[index]);
            });
          }
        },
        behavior: HitTestBehavior.opaque,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.topRight,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topRight:
                        Radius.circular(screenSizeHeight * 0.02),
                        topLeft:
                        Radius.circular(screenSizeHeight * 0.02)),
                    child: Container(
                      height: screenSizeHeight * 0.20,
                      decoration: BoxDecoration(
                        image: products[index].images == ''?DecorationImage(image:AssetImage('assets/img/photo_1.png'), fit: BoxFit.cover):
                        DecorationImage(image:NetworkImage(products[index].images??""), fit: BoxFit.cover),
                      ),
                    ),
                  ),
                  Visibility(
                    visible: productsSelected.contains(products[index]),
                    child: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: screenSizeHeight * 0.015,
            ),
            Text(
              '${products[index].title}',
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontStyle: FontStyle.normal,
                  fontFamily: 'Gotham',
                  decoration: TextDecoration.none,
                  fontSize: contentTextWeb,
                  fontWeight: FontWeight.w400),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.left,
            ),
            Text(
              '${products[index].productType??""}',
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontStyle: FontStyle.normal,
                  fontFamily: 'Gotham',
                  decoration: TextDecoration.none,
                  fontSize: contentTextWeb,
                  fontWeight: FontWeight.w300),
              textAlign: TextAlign.center,
            ),
            Text(
              '\$${products[index].price}',
              style: TextStyle(
                  color: Theme.of(context).secondaryHeaderColor,
                  fontStyle: FontStyle.normal,
                  fontFamily: 'Gotham',
                  decoration: TextDecoration.none,
                  fontSize: smallTextWeb,
                  fontWeight: FontWeight.w400),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  bool _compareTimes(String enteredTime, String videoDuration) {
    // Convert entered time and video duration to seconds
    List<String> enteredParts = enteredTime.split(':');
    int enteredSeconds = int.parse(enteredParts[0]) * 60 + int.parse(enteredParts[1]);

    List<String> videoParts = videoDuration.split(':');
    int videoSeconds = int.parse(videoParts[0]) * 60 + int.parse(videoParts[1]);

    // Compare the times
    return enteredSeconds <= videoSeconds;
  }

  Duration duration = const Duration(hours: 0, minutes: 0,seconds: 0);

  Widget cellsProductsWithTime( index, screenSizeWidth, screenSizeHeight, modalState) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.topRight,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(screenSizeHeight * 0.02),
                    topLeft: Radius.circular(screenSizeHeight * 0.02),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      image: productsSelected[index].images==""?
                      DecorationImage(
                        image: AssetImage('assets/img/photo_1.png'),
                        fit: BoxFit.cover,
                      ):DecorationImage(
                        image: NetworkImage(productsSelected[index].images??""),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: screenSizeHeight * 0.015,
          ),
          Text(
            '${productsSelected[index].title}',
            style: TextStyle(
              color: Theme.of(context).secondaryHeaderColor,
              fontStyle: FontStyle.normal,
              fontFamily: 'Gotham',
              decoration: TextDecoration.none,
              fontSize: contentTextWeb,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.left,
          ),
          Text(
            '${productsSelected[index].productType??""}',
            style: TextStyle(
              color: Theme.of(context).secondaryHeaderColor,
              fontStyle: FontStyle.normal,
              fontFamily: 'Gotham',
              decoration: TextDecoration.none,
              fontSize: contentTextWeb,
              fontWeight: FontWeight.w400,
            ),
            textAlign: TextAlign.center,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed:
                    () {
                  _showDialog(
                      CupertinoTimerPicker(
                        secondInterval: 1,
                        mode: CupertinoTimerPickerMode.hms,
                        initialTimerDuration: const Duration(hours: 0, minutes: 0,seconds: 0),
                        onTimerDurationChanged: (Duration newDuration) {
                          duration = newDuration;
                          // setState(() => duration = newDuration);
                        },
                      ),
                          () {
                        String enteredTime = '${(duration.inHours * 60 + duration.inMinutes.remainder(60)).toString().padLeft(2, '0')}:${duration.inSeconds.remainder(60).toString().padLeft(2, '0')}';
                        Navigator.of(context).pop();
                        if (_compareTimes(enteredTime, time))
                        {
                          modalState(() {
                            productsSelected[index].from = enteredTime;
                            productsSelected[index].to=addFiveSeconds(enteredTime);
                          });
                        }
                        else
                        {
                          // Show error if entered time is greater than video duration
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Mensaje de alerta'),
                                content: Text('El tiempo introducido supera la duración del vídeo.'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      }
                      ,context,screenSizeHeight);
                  // showDialog(
                  //   context: context,
                  //   builder: (BuildContext context) {
                  //     TextEditingController _controller = TextEditingController();
                  //     return AlertDialog(
                  //       title: Text('Entrar a partir do tempo'),
                  //       content: TextFormField(
                  //         controller: _controller,
                  //         decoration: InputDecoration(hintText: 'MM:SS'),
                  //         keyboardType: TextInputType.datetime,
                  //       ),
                  //       actions: <Widget>[
                  //         TextButton(
                  //           onPressed: () {
                  //             Navigator.of(context).pop();
                  //           },
                  //           child: Text('Cancelar'),
                  //         ),
                  //         TextButton(
                  //           onPressed: () {
                  //             String enteredTime = _controller.text;
                  //             // Validate and process the entered time as needed
                  //             if (_isTimeValid(enteredTime)) {
                  //               // Compare entered time with video duration
                  //
                  //               if (_compareTimes(enteredTime, time)) {
                  //                 modalState(() {
                  //                   productsSelected[index].from = enteredTime;
                  //                   productsSelected[index].to=addFiveSeconds(enteredTime);
                  //                 });
                  //                 Navigator.of(context).pop();
                  //               } else {
                  //                 // Show error if entered time is greater than video duration
                  //                 showDialog(
                  //                   context: context,
                  //                   builder: (BuildContext context) {
                  //                     return AlertDialog(
                  //                       title: Text('Erro'),
                  //                       content: Text('O tempo introduzido excede a duração do vídeo.'),
                  //                       actions: <Widget>[
                  //                         TextButton(
                  //                           onPressed: () {
                  //                             Navigator.of(context).pop();
                  //                           },
                  //                           child: Text('OK'),
                  //                         ),
                  //                       ],
                  //                     );
                  //                   },
                  //                 );
                  //               }
                  //             } else {
                  //               // Show error if entered time format is invalid
                  //               showDialog(
                  //                 context: context,
                  //                 builder: (BuildContext context) {
                  //                   return AlertDialog(
                  //                     title: Text('Error'),
                  //                     content: Text('Invalid time format. Please enter time in MM:SS format.'),
                  //                     actions: <Widget>[
                  //                       TextButton(
                  //                         onPressed: () {
                  //                           Navigator.of(context).pop();
                  //                         },
                  //                         child: Text('OK'),
                  //                       ),
                  //                     ],
                  //                   );
                  //                 },
                  //               );
                  //             }
                  //           },
                  //           child: Text('OK'),
                  //         ),
                  //       ],
                  //     );
                  //   },
                  // );
                },
                child: Text(productsSelected[index].from == null ? 'From' : productsSelected[index].from),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDialog(Widget child,Function() onPressed ,BuildContext context,screenSizeHeight,) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => Container(
        height: 320, // Increase the height to accommodate the "Done" button
        padding: const EdgeInsets.only(top: 6.0),
        margin: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: Scaffold(
          //top: false,
          body: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    child: Container(
                      color: Colors.transparent,
                      padding: const EdgeInsets.only(left:12.0,top:12),
                      child: Container(
                        alignment: Alignment.center,
                        padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 15),
                        decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                        ),
                        child: Text('Cancelar', style:
                        TextStyle(
                            color: context.background,
                            fontStyle: FontStyle.normal,
                            fontFamily: 'Gotham',
                            decoration: TextDecoration.none,
                            fontSize: screenSizeHeight * 0.02,
                            fontWeight: FontWeight.w700
                        ),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    ),
                    onTap: () {
                      Navigator.pop(context); // Dismiss the popup
                    },
                  ),
                  GestureDetector(
                    child: AbsorbPointer(
                      child: Container(
                        color: Colors.transparent,
                        padding: const EdgeInsets.only(right:12.0,top:12),
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 15),
                          decoration: BoxDecoration(
                              color: Theme.of(context).secondaryHeaderColor,
                              borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                          ),
                          child: Text('Hecho', style:
                          TextStyle(
                              color: context.background,
                              fontStyle: FontStyle.normal,
                              fontFamily: 'Gotham',
                              decoration: TextDecoration.none,
                              fontSize: screenSizeHeight * 0.02,
                              fontWeight: FontWeight.w700
                          ),
                            textAlign: TextAlign.center,
                          ),
                        ),

                      ),
                    ),
                    onTap: onPressed
                  ),
                ],
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Future<void> validateFieldsToSaveStoreIDS(modalState) async {
    List<String> values = [];
    if (companyInfo.webSite?.replaceAll(" ", "") == '' ) {
      values.add('Web Url');
      return;
    } else if (companyInfo.storePlatform == '') {
      values.add('Tienda de Ecommerce');
      return;
    } else
    if (companyInfo.consumerKey == '') {
      values.add('Clave del cliente');
      return;
    } else
    if (companyInfo.consumerSecret == '') {
      values.add('Clave secreta del cliente');
      return;
    }

    var stringVal = '';
    values.forEach((element) {
      var index = values.indexOf(element);
      if (index == 0) {
        stringVal = '$element';
      } else {
        stringVal = stringVal + ',$element';
      }
    });

    if (companyInfo.webSite?.replaceAll(" ", "") == ''  ||  companyInfo.storePlatform == '' || companyInfo.consumerKey == '' || companyInfo.consumerSecret == '') {
      dialogMessage('assets/img/error.png', 'Lo sentimos', 'Por favor rellena los campos: $stringVal');
    } else {
      await saveStoreIDS(modalState);
    }
  }

  Future<void> saveStoreIDS(modalState) async {
    dialogoCarga('Actualizando información...');

    var refCompany = _db.collection('companies').doc(companyInfo.companyID);

    refCompany.update(companyInfo.storePlatform == 'WooCommerce' ? companyInfo.toUpdateStore() : companyInfo.toUpdateShopifyStore()).whenComplete(() async {
      Navigator.of(context, rootNavigator: true).pop('dialog');
     await validateStore(modalState);
    }).catchError((error) {
      dialogMessage('assets/img/error.png', 'Lo sentimos', 'Ocurrió un error al guardar la información del usuario. Inténtelo de nuevo más tarde');
    });
  }

  Future<void> validateFieldsToSaveShopifyIDS(modalState) async {
    List<String> values = [];
    if (companyInfo.webSite == '' ) {
      values.add('Web Url');
    }
    if (companyInfo.storePlatform == '') {
      values.add('Tienda de Ecommerce');
    }
    if (companyInfo.accessToken == '') {
      values.add('Access Token del cliente');
    }

    var stringVal = '';
    values.forEach((element) {
      var index = values.indexOf(element);
      if (index == 0) {
        stringVal = '$element';
      } else {
        stringVal = stringVal + ',$element';
      }
    });

    if (companyInfo.webSite == '' || companyInfo.storePlatform == '' || companyInfo.accessToken == '') {
      dialogMessage('assets/img/error.png', 'Lo sentimos', 'Por favor rellena los campos: $stringVal');
    } else {
      //validateCompanyFieldsToSave();
      await saveStoreIDS(modalState);
    }
  }

  Future<void> validateStore(modalState) async{

    if (companyInfo.storePlatform == 'WooCommerce') {
      await getWooCommerceProducts(modalState);

    } else if (companyInfo.storePlatform == 'Shopify') {
      await getShopifyProducts(modalState);
    }
    setState(() {
      homeLoading=false;
    });

  }

  //Get WooCommerceProducts
  Future<void> getWooCommerceProducts(void Function(void Function()) modalState) async {
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

          modalState(() {
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
  Future<void> getShopifyProducts(void Function(void Function()) modalState) async {

    dialogoCarga('Actualizando información...');
    String url = "${companyInfo.webSite}/admin/api/2023-01/products.json";
    String token = companyInfo.accessToken ?? "";

    Uri postURL = Uri.parse('$STRIPE_URL?endpoint=$url&token=$token');

    try {
      print("Call post $postURL");
      final response = await http.post(postURL);
      log("Response"+response.body);

      if (response.body != 'error') {
        var data = jsonDecode(response.body);
        List shopProducts = data['data']['products'];

        for (var productData in shopProducts) {
          var product = ShopifyProductModel.fromJson(productData);
          allProducts.ecommercePlatform = 'Shopify';

          modalState(() {
            final index = allProducts.shopProducts?.indexWhere((element) => element.id == product.id);
            if (index != null && index >= 0) {
              allProducts.shopProducts?[index] = product;
            } else {
              allProducts.shopProducts?.add(product);
            }
          });
          modalState(() { });
        }
      }
    } catch (e) {
      // Handle error
    }finally{
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }
  }


  dialogMenu(screenSizeHeight, screenSizeWidth) {
    if (screenSizeHeight >= screenSizeWidth) {
      showModalBottomSheet(
          //expand: true,
          context: context,
          backgroundColor: context.background,
          builder: (context) => StatefulBuilder(
                builder: (context, modalState) {
                  return Container(
                      height: screenSizeHeight * 0.55,
                      child: Material(
                        child: ListView(
                          padding: EdgeInsets.only(
                              top: screenSizeHeight * 0.045,
                              left: screenSizeWidth * 0.05,
                              right: screenSizeWidth * 0.05,
                              bottom: screenSizeHeight * 0.045),
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Text(
                              'Configurar mi cuenta',
                              style: TextStyle(
                                  color: Theme.of(context).focusColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: secondaryTextMobile,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              height: screenSizeHeight * 0.03,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    dialogUserInfoValues(
                                        screenSizeHeight, screenSizeWidth);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: screenSizeHeight * 0.025,
                                        bottom: screenSizeHeight * 0.025,
                                        left: screenSizeWidth * 0.03,
                                        right: screenSizeWidth * 0.03),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).focusColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              screenSizeHeight * 0.02)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.account_circle_outlined,
                                          color: Colors.white,
                                          size: screenSizeHeight * 0.06,
                                        ),
                                        Container(
                                          width: screenSizeWidth * 0.015,
                                        ),
                                        Text(
                                          'Información\nde usuario',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontStyle: FontStyle.normal,
                                              fontFamily: 'Gotham',
                                              decoration: TextDecoration.none,
                                              fontSize: contentTextWeb,
                                              fontWeight: FontWeight.w400),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: screenSizeWidth * 0.045,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    dialogCompanyInfoValues(
                                        screenSizeHeight, screenSizeWidth);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: screenSizeHeight * 0.025,
                                        bottom: screenSizeHeight * 0.025,
                                        left: screenSizeWidth * 0.03,
                                        right: screenSizeWidth * 0.03),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).focusColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              screenSizeHeight * 0.02)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.business_outlined,
                                          color: Colors.white,
                                          size: screenSizeHeight * 0.06,
                                        ),
                                        Container(
                                          width: screenSizeWidth * 0.015,
                                        ),
                                        Text(
                                          'Información\nde empresa',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontStyle: FontStyle.normal,
                                              fontFamily: 'Gotham',
                                              decoration: TextDecoration.none,
                                              fontSize: contentTextWeb,
                                              fontWeight: FontWeight.w400),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: screenSizeHeight * 0.03,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    dialogContactInfoValues(
                                        screenSizeHeight, screenSizeWidth);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: screenSizeHeight * 0.025,
                                        bottom: screenSizeHeight * 0.025,
                                        left: screenSizeWidth * 0.03,
                                        right: screenSizeWidth * 0.03),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).focusColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              screenSizeHeight * 0.02)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.contact_page_outlined,
                                          color: Colors.white,
                                          size: screenSizeHeight * 0.06,
                                        ),
                                        Container(
                                          width: screenSizeWidth * 0.015,
                                        ),
                                        Text(
                                          'Información\nde contacto',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontStyle: FontStyle.normal,
                                              fontFamily: 'Gotham',
                                              decoration: TextDecoration.none,
                                              fontSize: contentTextWeb,
                                              fontWeight: FontWeight.w400),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: screenSizeWidth * 0.045,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    dialogToConnectWeb(screenSizeHeight, screenSizeWidth);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: screenSizeHeight * 0.025,
                                        bottom: screenSizeHeight * 0.025,
                                        left: screenSizeWidth * 0.03,
                                        right: screenSizeWidth * 0.03),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).focusColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              screenSizeHeight * 0.02)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.desktop_windows_outlined,
                                          color: Colors.white,
                                          size: screenSizeHeight * 0.06,
                                        ),
                                        Container(
                                          width: screenSizeWidth * 0.015,
                                        ),
                                        Text(
                                          'Vinculación\nEcommerce',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontStyle: FontStyle.normal,
                                              fontFamily: 'Gotham',
                                              decoration: TextDecoration.none,
                                              fontSize: contentTextWeb,
                                              fontWeight: FontWeight.w400),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: screenSizeHeight * 0.03,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    //todo suscripción cumbia
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: screenSizeHeight * 0.025,
                                        bottom: screenSizeHeight * 0.025,
                                        left: screenSizeWidth * 0.03,
                                        right: screenSizeWidth * 0.03),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).focusColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              screenSizeHeight * 0.02)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.payment_outlined,
                                          color: Colors.white,
                                          size: screenSizeHeight * 0.06,
                                        ),
                                        Container(
                                          width: screenSizeWidth * 0.015,
                                        ),
                                        Text(
                                          'Suscripción\nCumbiaLive',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontStyle: FontStyle.normal,
                                              fontFamily: 'Gotham',
                                              decoration: TextDecoration.none,
                                              fontSize: contentTextWeb,
                                              fontWeight: FontWeight.w400),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Container(
                                  width: screenSizeWidth * 0.045,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    dialogToPrivacy(
                                        screenSizeHeight, screenSizeWidth);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: EdgeInsets.only(
                                        top: screenSizeHeight * 0.025,
                                        bottom: screenSizeHeight * 0.025,
                                        left: screenSizeWidth * 0.03,
                                        right: screenSizeWidth * 0.03),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).focusColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(
                                              screenSizeHeight * 0.02)),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.policy_outlined,
                                          color: Colors.white,
                                          size: screenSizeHeight * 0.06,
                                        ),
                                        Container(
                                          width: screenSizeWidth * 0.015,
                                        ),
                                        Text(
                                          'Términos y\ncondiciones',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontStyle: FontStyle.normal,
                                              fontFamily: 'Gotham',
                                              decoration: TextDecoration.none,
                                              fontSize: contentTextWeb,
                                              fontWeight: FontWeight.w400),
                                          textAlign: TextAlign.left,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ));
                },
              ));
    } else {
      showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        alignment: Alignment.center,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(screenSizeHeight * 0.03))),
            // title: Text(
            //   'Configurar mi cuenta',
            //   style: TextStyle(
            //       color: Theme.of(context).focusColor,
            //       fontStyle: FontStyle.normal,
            //       fontFamily: 'Gotham',
            //       decoration: TextDecoration.none,
            //       fontSize: secondaryTextWeb,
            //       fontWeight: FontWeight.w700),
            //   textAlign: TextAlign.center,
            // ),
            backgroundColor: Colors.white,
            child: Container(
              padding: EdgeInsets.all(screenSizeHeight * 0.03),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(screenSizeHeight * 0.02)),
              ),
              width: screenSizeWidth * 0.65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: screenSizeHeight * 0.06,),
                  Text(
                    'Configurar mi cuenta',
                    style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontStyle: FontStyle.normal,
                        fontFamily: 'Gotham',
                        decoration: TextDecoration.none,
                        fontSize: secondaryTextWeb,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  Container(height: screenSizeHeight * 0.06,),
                  Expanded(
                    child: Center(
                      child: ListView(
                        padding: EdgeInsets.only(
                          top: 0,
                          left: screenSizeWidth * 0.015,
                          right: screenSizeWidth * 0.015,
                          bottom: screenSizeHeight * 0.03,
                        ),
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  dialogUserInfoValues(
                                      screenSizeHeight, screenSizeWidth);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: screenSizeHeight * 0.025,
                                      bottom: screenSizeHeight * 0.025,
                                      left: screenSizeWidth * 0.03,
                                      right: screenSizeWidth * 0.03),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).focusColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(screenSizeHeight * 0.02)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.account_circle_outlined,
                                        color: Colors.white,
                                        size: screenSizeHeight * 0.06,
                                      ),
                                      Container(
                                        width: screenSizeWidth * 0.015,
                                      ),
                                      Text(
                                        'Información\nde usuario',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextWeb,
                                            fontWeight: FontWeight.w400),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  dialogCompanyInfoValues(
                                      screenSizeHeight, screenSizeWidth);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: screenSizeHeight * 0.025,
                                      bottom: screenSizeHeight * 0.025,
                                      left: screenSizeWidth * 0.03,
                                      right: screenSizeWidth * 0.03),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).focusColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(screenSizeHeight * 0.02)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.business_outlined,
                                        color: Colors.white,
                                        size: screenSizeHeight * 0.06,
                                      ),
                                      Container(
                                        width: screenSizeWidth * 0.015,
                                      ),
                                      Text(
                                        'Información\nde empresa',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextWeb,
                                            fontWeight: FontWeight.w400),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  dialogContactInfoValues(
                                      screenSizeHeight, screenSizeWidth);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: screenSizeHeight * 0.025,
                                      bottom: screenSizeHeight * 0.025,
                                      left: screenSizeWidth * 0.03,
                                      right: screenSizeWidth * 0.03),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).focusColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(screenSizeHeight * 0.02)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.contact_page_outlined,
                                        color: Colors.white,
                                        size: screenSizeHeight * 0.06,
                                      ),
                                      Container(
                                        width: screenSizeWidth * 0.015,
                                      ),
                                      Text(
                                        'Información\nde contacto',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextWeb,
                                            fontWeight: FontWeight.w400),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: screenSizeHeight * 0.03,
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  dialogToConnectWeb(screenSizeHeight, screenSizeWidth);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: screenSizeHeight * 0.025,
                                      bottom: screenSizeHeight * 0.025,
                                      left: screenSizeWidth * 0.03,
                                      right: screenSizeWidth * 0.03),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).focusColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(screenSizeHeight * 0.02)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.desktop_windows_outlined,
                                        color: Colors.white,
                                        size: screenSizeHeight * 0.06,
                                      ),
                                      Container(
                                        width: screenSizeWidth * 0.015,
                                      ),
                                      Text(
                                        'Vinculación\nEcommerce',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextWeb,
                                            fontWeight: FontWeight.w400),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  //todo suscripción cumbia
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: screenSizeHeight * 0.025,
                                      bottom: screenSizeHeight * 0.025,
                                      left: screenSizeWidth * 0.03,
                                      right: screenSizeWidth * 0.03),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).focusColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(screenSizeHeight * 0.02)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.payment_outlined,
                                        color: Colors.white,
                                        size: screenSizeHeight * 0.06,
                                      ),
                                      Container(
                                        width: screenSizeWidth * 0.015,
                                      ),
                                      Text(
                                        'Suscripción\nCumbiaLive',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextWeb,
                                            fontWeight: FontWeight.w400),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  dialogToPrivacy(screenSizeHeight, screenSizeWidth);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  padding: EdgeInsets.only(
                                      top: screenSizeHeight * 0.025,
                                      bottom: screenSizeHeight * 0.025,
                                      left: screenSizeWidth * 0.03,
                                      right: screenSizeWidth * 0.03),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).focusColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(screenSizeHeight * 0.02)),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.policy_outlined,
                                        color: Colors.white,
                                        size: screenSizeHeight * 0.06,
                                      ),
                                      Container(
                                        width: screenSizeWidth * 0.015,
                                      ),
                                      Text(
                                        'Términos y\ncondiciones',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextWeb,
                                            fontWeight: FontWeight.w400),
                                        textAlign: TextAlign.left,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 200),
      );
    }
  }

  dialogPricing(screenSizeHeight, screenSizeWidth) {
    if (screenSizeHeight >= screenSizeWidth) {
      showModalBottomSheet(
          //expand: true,
          context: context,
          backgroundColor: context.background,
          builder: (context) => StatefulBuilder(
                builder: (context, modalState) {
                  return Container(
                      height: screenSizeHeight * 0.9,
                      child: Material(
                          child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: ListView(
                              padding: EdgeInsets.only(
                                  top: screenSizeHeight * 0.045,
                                  left: screenSizeWidth * 0.05,
                                  right: screenSizeWidth * 0.05,
                                  bottom: screenSizeHeight * 0.045),
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              children: [
                                Text(
                                  'Mi suscripción de Cumbia',
                                  style: TextStyle(
                                      color: Theme.of(context).focusColor,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Gotham',
                                      decoration: TextDecoration.none,
                                      fontSize: secondaryTextMobile,
                                      fontWeight: FontWeight.w400),
                                  textAlign: TextAlign.center,
                                ),
                                Container(
                                  height: screenSizeHeight * 0.03,
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            flex: 8,
                            child: ListView(
                              padding: EdgeInsets.only(
                                  top: screenSizeHeight * 0.045,
                                  left: screenSizeWidth * 0.05,
                                  right: screenSizeWidth * 0.05,
                                  bottom: screenSizeHeight * 0.045),
                              physics: ScrollPhysics(),
                              shrinkWrap: true,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    checkOutStripe(suscriptions[0]);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(
                                          top: screenSizeHeight * 0.025,
                                          bottom: screenSizeHeight * 0.04,
                                          left: screenSizeWidth * 0.03,
                                          right: screenSizeWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenSizeHeight * 0.02)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${suscriptions[0].title}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: secondaryTextWeb,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                textAlign: TextAlign.center,
                                              ),
                                              Container(
                                                height:
                                                    screenSizeHeight * 0.015,
                                              ),
                                              Text(
                                                '\$${suscriptions[0].price}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize:
                                                        screenSizeHeight * 0.07,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                textAlign: TextAlign.center,
                                              ),
                                              Container(
                                                height: screenSizeHeight * 0.03,
                                              ),
                                              Text(
                                                'Conecta cualquier página web\nbásicas a CumbiaLive',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextWeb,
                                                    fontWeight:
                                                        FontWeight.w300),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: screenSizeHeight * 0.06,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              checkOutStripe(suscriptions[0]);
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.only(
                                                  top: screenSizeHeight * 0.015,
                                                  bottom:
                                                      screenSizeHeight * 0.015,
                                                  left: screenSizeWidth * 0.015,
                                                  right:
                                                      screenSizeWidth * 0.015),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              screenSizeHeight *
                                                                  0.01))),
                                              child: Text(
                                                'Adquirir este plan',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .focusColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextWeb,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                                Container(
                                  height: screenSizeHeight * 0.045,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    checkOutStripe(suscriptions[1]);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(
                                          top: screenSizeHeight * 0.025,
                                          bottom: screenSizeHeight * 0.04,
                                          left: screenSizeWidth * 0.03,
                                          right: screenSizeWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenSizeHeight * 0.02)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${suscriptions[1].title}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: secondaryTextWeb,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                textAlign: TextAlign.center,
                                              ),
                                              Container(
                                                height:
                                                    screenSizeHeight * 0.015,
                                              ),
                                              Text(
                                                '\$${suscriptions[1].price}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize:
                                                        screenSizeHeight * 0.07,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                textAlign: TextAlign.center,
                                              ),
                                              Container(
                                                height: screenSizeHeight * 0.03,
                                              ),
                                              Text(
                                                'Conecta tu comercio de\nShopify, Woocommerce y\nTiendanube',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextWeb,
                                                    fontWeight:
                                                        FontWeight.w300),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: screenSizeHeight * 0.06,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              checkOutStripe(suscriptions[1]);
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.only(
                                                  top: screenSizeHeight * 0.015,
                                                  bottom:
                                                      screenSizeHeight * 0.015,
                                                  left: screenSizeWidth * 0.015,
                                                  right:
                                                      screenSizeWidth * 0.015),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              screenSizeHeight *
                                                                  0.01))),
                                              child: Text(
                                                'Adquirir este plan',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .focusColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextWeb,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                                Container(
                                  height: screenSizeHeight * 0.045,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    checkOutStripe(suscriptions[2]);
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                      alignment: Alignment.center,
                                      padding: EdgeInsets.only(
                                          top: screenSizeHeight * 0.025,
                                          bottom: screenSizeHeight * 0.04,
                                          left: screenSizeWidth * 0.03,
                                          right: screenSizeWidth * 0.03),
                                      decoration: BoxDecoration(
                                        color:
                                            Theme.of(context).primaryColorLight,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                screenSizeHeight * 0.02)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${suscriptions[2].title}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: secondaryTextWeb,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                textAlign: TextAlign.center,
                                              ),
                                              Container(
                                                height:
                                                    screenSizeHeight * 0.015,
                                              ),
                                              Text(
                                                '\$${suscriptions[2].price}',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize:
                                                        screenSizeHeight * 0.07,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                textAlign: TextAlign.center,
                                              ),
                                              Container(
                                                height: screenSizeHeight * 0.03,
                                              ),
                                              Text(
                                                'Conecta tu comercio de\nShopify, Woocommerce CMS,\nTiendanube o cualquier\ndesarrollo web',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextWeb,
                                                    fontWeight:
                                                        FontWeight.w300),
                                                textAlign: TextAlign.center,
                                              ),
                                            ],
                                          ),
                                          Container(
                                            height: screenSizeHeight * 0.06,
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              checkOutStripe(suscriptions[2]);
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: Container(
                                              alignment: Alignment.center,
                                              padding: EdgeInsets.only(
                                                  top: screenSizeHeight * 0.015,
                                                  bottom:
                                                      screenSizeHeight * 0.015,
                                                  left: screenSizeWidth * 0.015,
                                                  right:
                                                      screenSizeWidth * 0.015),
                                              decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              screenSizeHeight *
                                                                  0.01))),
                                              child: Text(
                                                'Adquirir este plan',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .focusColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextWeb,
                                                    fontWeight:
                                                        FontWeight.w700),
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )),
                                ),
                              ],
                            ),
                          ),
                        ],
                      )));
                },
              ));
    } else {
      showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        alignment: Alignment.center,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(screenSizeHeight * 0.03))),
            // title: Text(
            //   'Mi suscripción de Cumbia',
            //   style: TextStyle(
            //       color: Theme.of(context).focusColor,
            //       fontStyle: FontStyle.normal,
            //       fontFamily: 'Gotham',
            //       decoration: TextDecoration.none,
            //       fontSize: secondaryTextWeb,
            //       fontWeight: FontWeight.w700),
            //   textAlign: TextAlign.center,
            // ),
            backgroundColor: Colors.white,
            child: Container(
              padding: EdgeInsets.all(screenSizeHeight * 0.03),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(screenSizeHeight * 0.02)),
              ),
              width: screenSizeWidth * 0.8,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(height: screenSizeHeight * 0.06,),
                  Text(
                    'Mi suscripción de Cumbia',
                    style: TextStyle(
                        color: Theme.of(context).focusColor,
                        fontStyle: FontStyle.normal,
                        fontFamily: 'Gotham',
                        decoration: TextDecoration.none,
                        fontSize: secondaryTextWeb,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  Container(height: screenSizeHeight * 0.06,),
                  Expanded(
                    child: Center(
                      child: ListView(
                        padding: EdgeInsets.only(
                          top: 0,
                          left: screenSizeWidth * 0.015,
                          right: screenSizeWidth * 0.015,
                          bottom: screenSizeHeight * 0.03,
                        ),
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  checkOutStripe(suscriptions[0]);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                    height: screenSizeHeight * 0.6,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(
                                        top: screenSizeHeight * 0.025,
                                        bottom: screenSizeHeight * 0.04,
                                        left: screenSizeWidth * 0.03,
                                        right: screenSizeWidth * 0.03),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(screenSizeHeight * 0.02)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${suscriptions[0].title}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration: TextDecoration.none,
                                                  fontSize: secondaryTextWeb,
                                                  fontWeight: FontWeight.w400),
                                              textAlign: TextAlign.center,
                                            ),
                                            Container(
                                              height: screenSizeHeight * 0.015,
                                            ),
                                            Text(
                                              '\$${suscriptions[0].price}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration: TextDecoration.none,
                                                  fontSize: screenSizeHeight * 0.07,
                                                  fontWeight: FontWeight.w700),
                                              textAlign: TextAlign.center,
                                            ),
                                            Container(
                                              height: screenSizeHeight * 0.03,
                                            ),
                                            Text(
                                              'Conecta cualquier página web\nbásicas a CumbiaLive',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration: TextDecoration.none,
                                                  fontSize: contentTextWeb,
                                                  fontWeight: FontWeight.w300),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            checkOutStripe(suscriptions[0]);
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                top: screenSizeHeight * 0.015,
                                                bottom: screenSizeHeight * 0.015,
                                                left: screenSizeWidth * 0.015,
                                                right: screenSizeWidth * 0.015),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        screenSizeHeight * 0.01))),
                                            child: Text(
                                              'Adquirir este plan',
                                              style: TextStyle(
                                                  color: Theme.of(context).focusColor,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration: TextDecoration.none,
                                                  fontSize: contentTextWeb,
                                                  fontWeight: FontWeight.w700),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                              GestureDetector(
                                onTap: () {
                                  checkOutStripe(suscriptions[1]);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                    height: screenSizeHeight * 0.6,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(
                                        top: screenSizeHeight * 0.025,
                                        bottom: screenSizeHeight * 0.04,
                                        left: screenSizeWidth * 0.03,
                                        right: screenSizeWidth * 0.03),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(screenSizeHeight * 0.02)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${suscriptions[1].title}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration: TextDecoration.none,
                                                  fontSize: secondaryTextWeb,
                                                  fontWeight: FontWeight.w400),
                                              textAlign: TextAlign.center,
                                            ),
                                            Container(
                                              height: screenSizeHeight * 0.015,
                                            ),
                                            Text(
                                              '\$${suscriptions[1].price}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration: TextDecoration.none,
                                                  fontSize: screenSizeHeight * 0.07,
                                                  fontWeight: FontWeight.w700),
                                              textAlign: TextAlign.center,
                                            ),
                                            Container(
                                              height: screenSizeHeight * 0.03,
                                            ),
                                            Text(
                                              'Conecta tu comercio de\nShopify, Woocommerce y\nTiendanube',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration: TextDecoration.none,
                                                  fontSize: contentTextWeb,
                                                  fontWeight: FontWeight.w300),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            checkOutStripe(suscriptions[1]);
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                top: screenSizeHeight * 0.015,
                                                bottom: screenSizeHeight * 0.015,
                                                left: screenSizeWidth * 0.015,
                                                right: screenSizeWidth * 0.015),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        screenSizeHeight * 0.01))),
                                            child: Text(
                                              'Adquirir este plan',
                                              style: TextStyle(
                                                  color: Theme.of(context).focusColor,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration: TextDecoration.none,
                                                  fontSize: contentTextWeb,
                                                  fontWeight: FontWeight.w700),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                              GestureDetector(
                                onTap: () {
                                  checkOutStripe(suscriptions[2]);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                    height: screenSizeHeight * 0.6,
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(
                                        top: screenSizeHeight * 0.025,
                                        bottom: screenSizeHeight * 0.04,
                                        left: screenSizeWidth * 0.03,
                                        right: screenSizeWidth * 0.03),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColorLight,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(screenSizeHeight * 0.02)),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            Text(
                                              '${suscriptions[2].title}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration: TextDecoration.none,
                                                  fontSize: secondaryTextWeb,
                                                  fontWeight: FontWeight.w400),
                                              textAlign: TextAlign.center,
                                            ),
                                            Container(
                                              height: screenSizeHeight * 0.015,
                                            ),
                                            Text(
                                              '\$${suscriptions[2].price}',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration: TextDecoration.none,
                                                  fontSize: screenSizeHeight * 0.07,
                                                  fontWeight: FontWeight.w700),
                                              textAlign: TextAlign.center,
                                            ),
                                            Container(
                                              height: screenSizeHeight * 0.03,
                                            ),
                                            Text(
                                              'Conecta tu comercio de\nShopify, Woocommerce CMS,\nTiendanube o cualquier\ndesarrollo web',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration: TextDecoration.none,
                                                  fontSize: contentTextWeb,
                                                  fontWeight: FontWeight.w300),
                                              textAlign: TextAlign.center,
                                            ),
                                          ],
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            checkOutStripe(suscriptions[2]);
                                          },
                                          behavior: HitTestBehavior.opaque,
                                          child: Container(
                                            alignment: Alignment.center,
                                            padding: EdgeInsets.only(
                                                top: screenSizeHeight * 0.015,
                                                bottom: screenSizeHeight * 0.015,
                                                left: screenSizeWidth * 0.015,
                                                right: screenSizeWidth * 0.015),
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(
                                                        screenSizeHeight * 0.01))),
                                            child: Text(
                                              'Adquirir este plan',
                                              style: TextStyle(
                                                  color: Theme.of(context).focusColor,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration: TextDecoration.none,
                                                  fontSize: contentTextWeb,
                                                  fontWeight: FontWeight.w700),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 200),
      );
    }
  }

  checkOutStripe(PackageSuscriptionData selection) async {
    if (userInfo.plan?.status == 'Activo') {
      dialogMessage('assets/img/error.png', 'Error',
          'Debido a que ya cuentas con una suscripción activa no es posible comprar otra suscripción. Inténtelo una vez que acabe el periodo de suscripción de su paquete.');
    } else {
      String? idPrice = selection.priceIDStripe;
      var amount = (selection.price)! * 100;
      var currency = selection.currency?.toLowerCase();

      print('ID price: $idPrice');
      print('Currency: $currency');
      print('amount: $amount');

      dialogoCarga('Pagando suscripción');

      var stringURL = '$STRIPE_CHEKOUT?idPrice=$idPrice&amount=$amount';
      Uri postURL = Uri.parse(stringURL);

      /*
    var headers = {
      'Access-Control-Allow-Origin': '*',
    };*/

      final http.Response response = await http.post(postURL);

      if (response.body != null && response.body != 'error') {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        final data = jsonDecode(response.body);

        print('Data de sesión: $data');

        var urlCheckOut = data['subscriptionInformation']['url'];
        print('urlCheckOut: $urlCheckOut');

        Uri urlToPass = Uri.parse(urlCheckOut);

        print('urlToPass: $urlToPass');

        var session = data['subscriptionInformation']['id'];

        addPlan(session, selection);

        launchUrl(urlToPass);
      } else {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        dialogMessage('assets/img/error.png', 'Lo sentimos',
            'Hubo un error con la solicitud. Inténtelo de nuevo más tarde o contacte al equipo técnico de Cumbia-Live');
      }
    }
  }

  addPlan(String sessionID, PackageSuscriptionData specPlan) {
    /*
      'id':id,
      'productID':productID,
      'createdAt':FieldValue.serverTimestamp(),
     */

    var productFavorite = _db.collection('users').doc(userInfo.userUID);

    productFavorite.update({
      'sessionID': sessionID,
      'planData': specPlan.toMap('En proceso'),
    }).whenComplete(() async {
      print('Se añadió correctamente plan');
      Navigator.of(context, rootNavigator: true).pop('dialog');
    }).catchError((error) {
      //Hubo error al cargar usuario
      print('Este es el error: $error');
      Navigator.of(context, rootNavigator: true).pop('dialog');
      dialogMessage('assets/img/error.png', 'Lo sentimos',
          'Hubo un error al realizar la contratación del plan');
    });
  }

  // Fubtion to go to customer portal
  Future<void> goPortal() async {
    final url = '$STRIPE_CUSTOMER_PORTAL?customer=${userInfo.customerStripe}';
    final response = await http.post(Uri.parse(url));

    if (response.body != null && response.body != 'error') {
      final data = jsonDecode(response.body);
      final portalUrl = data['portalUrl'];

      if (!await launchUrl(Uri.parse(portalUrl))) {
        throw 'Could not launch $portalUrl';
      }
    } else {
      print('Error launching customer portal');
    }
  }

  Future<void> getSession() async {
    final url = '$STRIPE_RETRIEVE_CHECKOUT?sessionID=${userInfo.sessionID}';
    print("call  post $url");
    final response = await http.post(Uri.parse(url));
    print(response.body);

    if (response.body != null && response.body != 'error') {
      final data = jsonDecode(response.body);
      final dataSession = data['sessionData'];

      print('Data retrieved session: $data');

      final customerID = dataSession['customer'];
      final subscriptionID = dataSession['subscription'];

      saveCustomerStripe(customerID, subscriptionID);
    } else {
      print('Error retrieving session');
    }
  }

  Future<void> getSubscription(String subscriptionID) async {
    final url = '$STRIPE_RETRIEVE_SUBSCRIPTION?subscriptionID=$subscriptionID';
    final response = await http.post(Uri.parse(url));

    if (response.body != null && response.body != 'error') {
      final data = jsonDecode(response.body);
      final dataSubscription = data['subscriptionData'];

      print('Data retrieved subscription: $dataSubscription');

      final status = dataSubscription['status'];
      updateSubsStatus(status);
    } else {
      print('Error retrieving subscription');
    }
  }


  saveCustomerStripe(String customerID, String subscripID) {
    var productFavorite = _db.collection('users').doc(userInfo.userUID);

    if (userInfo.customerStripe == '' || userInfo.subscriptionID == '') {
      productFavorite.update({
        'customerStripe': customerID,
        'subscriptionID': subscripID,
        'planData.status': 'Activo',
      }).whenComplete(() async {
        // Navigator.of(context, rootNavigator: true).pop('dialog');
        print('Se añadió correctamente customerID');
      }).catchError((error) {
        //Navigator.of(context, rootNavigator: true).pop('dialog');
        //Hubo error al cargar usuario
        print('Este es el error: $error');
        //dialogMessage('img/error.png', 'Lo sentimos', 'Ocurrió un error al contratar el plan. Inténtelo más tarde', width, height);
      });
    }
  }

  updateSubsStatus(String status) {
    var productFavorite = _db.collection('users').doc(userInfo.userUID);

    if (status != 'active') {
      productFavorite.update({
        'planData.status': '$status',
        'subscriptionID': '',
      }).whenComplete(() async {
        // Navigator.of(context, rootNavigator: true).pop('dialog');
        print('Se actualizó correctamente status de subs');
      }).catchError((error) {
        //Navigator.of(context, rootNavigator: true).pop('dialog');
        //Hubo error al cargar usuario
        print('Este es el error: $error');
        //dialogMessage('img/error.png', 'Lo sentimos', 'Ocurrió un error al contratar el plan. Inténtelo más tarde', width, height);
      });
    }
  }

  //Funciones con métodos para comprar suscripción

  //: 1.- Genera token de aceptación
  pay001(PackageSuscriptionData selection) async {
    dialogoCarga('Realizando pago');

    var stringURL = '$WOMPI_URL';
    //var stringURL = '$STRIPE_URL2';
    Uri postURL = Uri.parse(stringURL);
    final http.Response response = await http.post(postURL);

    if (response.body != null && response.body != 'error') {
      Map<String, dynamic> data = jsonDecode(response.body);

      //print('Data de acceptanceToken: $data');

      if (data.containsKey('data')) {
        //print('Data de acceptanceToken: $data');
        var acceptance_token =
            data['data']['data']['presigned_acceptance']['acceptance_token'];

        getting_card_token(selection, acceptance_token);
      } else {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        print('Hubo un error: ${data['Error']}');
        dialogMessage('assets/img/error.png', 'Lo sentimos',
            'Hubo un error con la solicitud. Inténtelo de nuevo más tarde o contacte al equipo técnico de Cumbia-Live');
      }
    } else {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      dialogMessage('assets/img/error.png', 'Lo sentimos',
          'Hubo un error con la solicitud. Inténtelo de nuevo más tarde o contacte al equipo técnico de Cumbia-Live');
    }
  }

  //: 2.- Tokenización de tarjeta
  getting_card_token( PackageSuscriptionData selection, String acceptance_token ) async {
    var data = {
      "number": "4242424242424242",
      "exp_month": "12",
      "exp_year": "25",
      "cvc": "123",
      "card_holder": "Andres Martinez"
    };

    var stringURL =
        '$WOMPI_CARD_TOKEN?data=$data&number=${data['number']}&exp_month=${data['exp_month']}&exp_year=${data['exp_year']}&cvc=${data['cvc']}&card_holder=${data['card_holder']}';
    //var stringURL = '$STRIPE_URL2';
    Uri postURL = Uri.parse(stringURL);
    final http.Response response = await http.post(postURL);

    if (response.body != null && response.body != 'error') {
      Map<String, dynamic> data = jsonDecode(response.body);

      //print('Data de acceptanceToken: $data');

      if (data.containsKey('data')) {
        //print('Data de acceptanceToken: $data');
        //print('Accep_token: ${acceptance_token}');
        //print('Data tarjeta: ${data}');

        if (data['data']['status'] == 'CREATED') {
          var cardData = data['data'];
          //TODO: Crear fuente de pago
          generating_payment_source(selection, acceptance_token, cardData);
        } else {
          Navigator.of(context, rootNavigator: true).pop('dialog');
          dialogMessage('assets/img/error.png', 'Lo sentimos',
              'Hubo un error al generar token de tarjeta. Inténtelo de nuevo más tarde');
        }
      } else {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        print('Hubo un error: ${data['Error']}');
        dialogMessage('assets/img/error.png', 'Lo sentimos',
            'Hubo un error con la solicitud. Inténtelo de nuevo más tarde o contacte al equipo técnico de Cumbia-Live');
      }
    } else {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      dialogMessage('assets/img/error.png', 'Lo sentimos',
          'Hubo un error con la solicitud. Inténtelo de nuevo más tarde o contacte al equipo técnico de Cumbia-Live');
    }
  }

  //: 3.- Generación de fuente de pago
  generating_payment_source(PackageSuscriptionData selection, String acceptance_token, cardData) async {
    var token = cardData['data']['id'];

    print('Token de tarjeta generada: $token');

    var customer_email = userInfo.email;

    var stringURL =
        '$WOMPI_PAYMENT_SOURCE?cardToken=${token}&customer_email=${customer_email}&acceptance_token=${acceptance_token}';
    //var stringURL = '$STRIPE_URL2';
    Uri postURL = Uri.parse(stringURL);
    final http.Response response = await http.post(postURL);

    if (response.body != null && response.body != 'error') {
      Map<String, dynamic> data = jsonDecode(response.body);

      //print('Data de acceptanceToken: $data');

      if (data.containsKey('data')) {
        //print('Data de acceptanceToken: $data');
        //print('Accep_token: ${acceptance_token}');
        //print('Data tarjeta: ${cardData}');
        //print('Data de fuente de pago: $data');

        var payment_source_data = data['data'];
        //TODO: Crear transacción
        creating_transaction(
            selection, acceptance_token, cardData, payment_source_data);
      } else {
        print('Hubo un error: ${data['Error']}');
        Navigator.of(context, rootNavigator: true).pop('dialog');
        dialogMessage('assets/img/error.png', 'Lo sentimos',
            'Hubo un error con la solicitud. Inténtelo de nuevo más tarde o contacte al equipo técnico de Cumbia-Live');
      }
    } else {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      dialogMessage('assets/img/error.png', 'Lo sentimos',
          'Hubo un error con la solicitud. Inténtelo de nuevo más tarde o contacte al equipo técnico de Cumbia-Live');
    }
  }

  //: 4.- Creando transacción con fuente de pago (Se detiene actualmente proceso)
  creating_transaction(PackageSuscriptionData selection, String acceptance_token, cardData, payment_source_data) async {
    int referenceID = DateTime.now().millisecondsSinceEpoch;

    double amount = selection.price! * 100;

    String? customer_email = userInfo.email;

    int payment_source_id = payment_source_data['data']['id'];

    print('Fuente de pago: $payment_source_id');

    var stringURL =
        '$WOMPI_CREATE_TRANSACTION?amount_in_cents=${amount}&customer_email=${customer_email}&reference=${referenceID.toString()}&payment_source_id=${payment_source_id}';
    //var stringURL = '$STRIPE_URL2';
    Uri postURL = Uri.parse(stringURL);
    final http.Response response = await http.post(postURL);

    if (response.body != null && response.body != 'error') {
      Map<String, dynamic> data = jsonDecode(response.body);

      print('Data de transacción: $data');

      if (data.containsKey('data')) {
        //print('Data de acceptanceToken: $data');

        var transactionData = data['data'];

        print('Accep_token: ${acceptance_token}');
        print('Data tarjeta: ${cardData}');
        print('Data de fuente de pago: $payment_source_data');
        print('Data de transacción recién generada: $transactionData');

        //TODO: Buscar transacción y validar estatus
        checking_status_transaction(selection, acceptance_token, cardData,
            payment_source_data, transactionData);
      } else {
        print('Hubo un error: ${data['Error']}');
        Navigator.of(context, rootNavigator: true).pop('dialog');
        dialogMessage('assets/img/error.png', 'Lo sentimos',
            'Hubo un error con la solicitud. Inténtelo de nuevo más tarde o contacte al equipo técnico de Cumbia-Live');
      }
    } else {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      dialogMessage('assets/img/error.png', 'Lo sentimos',
          'Hubo un error con la solicitud. Inténtelo de nuevo más tarde o contacte al equipo técnico de Cumbia-Live');
    }
  }

  //: 5.- Verificando status de transacción
  checking_status_transaction(PackageSuscriptionData selection, String acceptance_token, cardData, payment_source_data, transactionData) async {
    var transactionID = transactionData['data']['id'];

    print('transactionID: $transactionID');

    var stringURL = '$WOMPI_CHECK_TRANSACTION?transactionID=${transactionID}';
    //var stringURL = '$STRIPE_URL2';
    Uri postURL = Uri.parse(stringURL);
    final http.Response response = await http.post(postURL);

    if (response.body != null && response.body != 'error') {
      Map<String, dynamic> data = jsonDecode(response.body);

      //print('Data de acceptanceToken: $data');

      if (data.containsKey('data')) {
        //print('Data de acceptanceToken: $data');

        var transactionData = data['data'];

        print('Accep_token: ${acceptance_token}');
        print('Data tarjeta: ${cardData}');
        print('Data de fuente de pago: $payment_source_data');
        print('Data de transacción recién generada: $transactionData');

        if (data['status'] == 'APPROVED') {
          //Pago realizado con éxito

          Navigator.of(context, rootNavigator: true).pop('dialog');
          dialogMessage('assets/img/aprobado.png', '¡Listo!',
              'El pago fue realizado con éxito. Ahora podrás gozar de los beneficios del plan');

          savingSuscriptionPurchase(selection, acceptance_token, cardData,
              payment_source_data, transactionData);

          //TODO: Guardar en base de datos transacción realizada y fuente de pago
        } else if (data['status'] == 'DECLINED') {
          //Pago rechazado
          Navigator.of(context, rootNavigator: true).pop('dialog');
          dialogMessage('assets/img/error.png', 'Lo sentimos',
              'El pago fue rechazado. Intente pagar con otro método de pago');
        } else if (data['status'] == 'VOIDED') {
          //Pago anulado
          Navigator.of(context, rootNavigator: true).pop('dialog');
          dialogMessage('assets/img/error.png', 'Lo sentimos',
              'El pago fue anulado. Intente pagar con otro método de pago');
        } else {
          //Hubo un error con el banco
          Navigator.of(context, rootNavigator: true).pop('dialog');
          dialogMessage('assets/img/error.png', 'Lo sentimos',
              'No se pudo procesar el pago debido a un problema con tu banco. Por favor contacta a tu banco y notifica el problema');
        }
      } else {
        print('Hubo un error: ${data['Error']}');
        Navigator.of(context, rootNavigator: true).pop('dialog');
        dialogMessage('assets/img/error.png', 'Lo sentimos',
            'Hubo un error con la solicitud. Inténtelo de nuevo más tarde o contacte al equipo técnico de Cumbia-Live');
      }
    } else {
      Navigator.of(context, rootNavigator: true).pop('dialog');
      dialogMessage('assets/img/error.png', 'Lo sentimos',
          'Hubo un error con la solicitud. Inténtelo de nuevo más tarde o contacte al equipo técnico de Cumbia-Live');
    }
  }

  //: 6.- Guardando datos de transacción
  savingSuscriptionPurchase(
      PackageSuscriptionData selection,
      String acceptance_token,
      cardData,
      payment_source_data,
      transactionData) async {
    var transactionID = transactionData['data']['id'];

    var ref = _db.collection('purchases').doc(transactionID);

    ref.set({
      'createdBy': userInfo.userUID,
      'businessID': companyInfo.companyID,
      'payment_source_data': payment_source_data,
      'transactionData': transactionData,
      'createdAt': FieldValue.serverTimestamp(),
    }).whenComplete(() async {
      print('Se guardó con éxito compra de suscription');

      var ref = _db.collection('companies').doc(companyInfo.companyID);

      ref.update(selection.toMap('APPROVED')).whenComplete(() async {
        print('Se actualizó con éxito compra de suscription en compañía');
      }).catchError((error) {
        //Hubo error al crear negocio
      });
    }).catchError((error) {
      //Hubo error al crear negocio
    });
  }

  //Alertas de info de usuario y métodos de guardado
  dialogUserInfoValues(screenSizeHeight, screenSizeWidth) {
    //companyInfo.category = companyInfo.category == '' ? 'Turismo': companyInfo.category;
    //companyInfo.storePlatform = companyInfo.storePlatform == '' ? 'WooCommerce': companyInfo.storePlatform;
    //category = companyInfo.category == '' ? 'Turismo': companyInfo.category;
    //virtualStore = companyInfo.storePlatform == '' ? 'WooCommerce': companyInfo.storePlatform;
    userInfo.secundaryEmail = userInfo.secundaryEmail == ''
        ? userInfo.email
        : userInfo.secundaryEmail;
    //companyInfo.email = companyInfo.email == '' ? userInfo.email : companyInfo.email;
    //isAliasValid = companyInfo.alias == '' ? false: true;

    if (screenSizeHeight >= screenSizeWidth) {
      showModalBottomSheet(
          //expand: true,
          context: context,
          backgroundColor: context.background,
          builder: (context) => StatefulBuilder(
                builder: (context, modalState) {
                  return Container(
                      height: screenSizeHeight * 0.9,
                      child: Material(
                        child: ListView(
                          padding: EdgeInsets.only(
                              top: screenSizeHeight * 0.045,
                              left: screenSizeWidth * 0.05,
                              right: screenSizeWidth * 0.05,
                              bottom: screenSizeHeight * 0.045),
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Icon(
                                  Icons.close,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                              ),
                            ),
                            Text(
                              'Información adicional',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: titleMobile,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              height: screenSizeHeight * 0.015,
                            ),
                            Text(
                              'Requerimos de la siguiente información para vincular tu página web con Cumbia',
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextMobile,
                                  fontWeight: FontWeight.w300),
                              textAlign: TextAlign.center,
                            ),
                            Container(
                              height: screenSizeHeight * 0.05,
                            ),
                            Text(
                              'Información personal',
                              style: TextStyle(
                                  color: Theme.of(context).dividerColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: secondaryTextMobile,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.015,
                            ),
                            Container(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(screenSizeHeight * 0.02)),
                                  color: Colors.white,
                                ),
                                child: ListView(
                                  padding: EdgeInsets.only(
                                    top: screenSizeHeight * 0.03,
                                    left: screenSizeWidth * 0.04,
                                    right: screenSizeWidth * 0.04,
                                    bottom: screenSizeHeight * 0.03,
                                  ),
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: ListView(
                                            shrinkWrap: true,
                                            physics: ScrollPhysics(),
                                            children: [
                                              Text(
                                                'Nombre',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextMobile,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                textAlign: TextAlign.left,
                                              ),
                                              Container(
                                                height: screenSizeHeight * 0.01,
                                              ),
                                              TextField(
                                                controller: name,
                                                onChanged: (text) {
                                                  if (text.isNotEmpty) {
                                                    userInfo.name = text;
                                                  } else if (text.length == 0) {
                                                    userInfo.name = '';
                                                  }
                                                },
                                                onSubmitted: (text) async {},
                                                textCapitalization:
                                                    TextCapitalization.none,
                                                keyboardType:
                                                    TextInputType.text,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextMobile,
                                                    fontWeight:
                                                        FontWeight.w300),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                      borderSide: BorderSide(
                                                          width: 0.5,
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor)),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                      borderSide: BorderSide(
                                                          width: 0.5,
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                      borderSide: BorderSide(
                                                          width: 0.5,
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor)),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  prefixIcon: Icon(
                                                    Icons.text_fields,
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                  ),
                                                  hintStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      fontFamily: 'Gotham',
                                                      decoration:
                                                          TextDecoration.none,
                                                      fontSize:
                                                          contentTextMobile,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                  hintText: userInfo.name == ''
                                                      ? 'Tu nombre'
                                                      : userInfo.name,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          width: screenSizeWidth * 0.03,
                                        ),
                                        Expanded(
                                          child: ListView(
                                            shrinkWrap: true,
                                            physics: ScrollPhysics(),
                                            children: [
                                              Text(
                                                'Apellido',
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .primaryColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextMobile,
                                                    fontWeight:
                                                        FontWeight.w400),
                                                textAlign: TextAlign.left,
                                              ),
                                              Container(
                                                height: screenSizeHeight * 0.01,
                                              ),
                                              TextField(
                                                controller: lastName,
                                                onChanged: (text) {
                                                  if (text.isNotEmpty) {
                                                    userInfo.lastName = text;
                                                  } else if (text.length == 0) {
                                                    userInfo.lastName = '';
                                                  }
                                                },
                                                onSubmitted: (text) async {},
                                                textCapitalization:
                                                    TextCapitalization.none,
                                                keyboardType:
                                                    TextInputType.text,
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                    fontStyle: FontStyle.normal,
                                                    fontFamily: 'Gotham',
                                                    decoration:
                                                        TextDecoration.none,
                                                    fontSize: contentTextMobile,
                                                    fontWeight:
                                                        FontWeight.w300),
                                                decoration: InputDecoration(
                                                  border: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                      borderSide: BorderSide(
                                                          width: 0.5,
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor)),
                                                  enabledBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                      borderSide: BorderSide(
                                                          width: 0.5,
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor)),
                                                  focusedBorder: OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  16)),
                                                      borderSide: BorderSide(
                                                          width: 0.5,
                                                          color: Theme.of(
                                                                  context)
                                                              .secondaryHeaderColor)),
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  prefixIcon: Icon(
                                                    Icons.text_fields,
                                                    color: Theme.of(context)
                                                        .secondaryHeaderColor,
                                                  ),
                                                  hintStyle: TextStyle(
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor,
                                                      fontStyle:
                                                          FontStyle.normal,
                                                      fontFamily: 'Gotham',
                                                      decoration:
                                                          TextDecoration.none,
                                                      fontSize:
                                                          contentTextMobile,
                                                      fontWeight:
                                                          FontWeight.w300),
                                                  hintText:
                                                      userInfo.lastName == ''
                                                          ? 'Tus apellidos'
                                                          : userInfo.lastName,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'Celular',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    Text(
                                      'Esta información no será visible para los usuarios, lo usaremos para contactarte desde Cumbia',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: smallTextMobile,
                                          fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.015,
                                    ),
                                    TextField(
                                      controller: phone,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          userInfo.phoneNumber = text;
                                        } else if (text.length == 0) {
                                          userInfo.phoneNumber = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w300),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextMobile,
                                            fontWeight: FontWeight.w300),
                                        hintText: userInfo.phoneNumber == ''
                                            ? 'Tu número'
                                            : userInfo.phoneNumber,
                                      ),
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'Correo',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    Text(
                                      'Esta información no será visible para los usuarios, lo usaremos para contactarte desde Cumbia',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: smallTextMobile,
                                          fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.015,
                                    ),
                                    TextField(
                                      controller: mail,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          userInfo.secundaryEmail = text;
                                        } else if (text.length == 0) {
                                          userInfo.secundaryEmail = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.emailAddress,
                                      //enabled: false,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w300),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextMobile,
                                            fontWeight: FontWeight.w300),
                                        hintText: userInfo.secundaryEmail == ''
                                            ? 'Correo del usuario'
                                            : userInfo.secundaryEmail,
                                      ),
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'NIT',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    TextField(
                                      controller: NIT,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          userInfo.nit = text;
                                        } else if (text.length == 0) {
                                          userInfo.nit = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.number,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w300),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextMobile,
                                            fontWeight: FontWeight.w300),
                                        hintText: userInfo.nit == ''
                                            ? 'Tu NIT'
                                            : userInfo.nit,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: screenSizeHeight * 0.06,
                            ),
                            GestureDetector(
                              onTap: () {
                                validateFieldsToSave();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    top: screenSizeHeight * 0.015,
                                    bottom: screenSizeHeight * 0.015),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            screenSizeHeight * 0.01))),
                                child: Text(
                                  '¡Aceptar!',
                                  style: TextStyle(
                                      color: context.background,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Gotham',
                                      decoration: TextDecoration.none,
                                      fontSize: contentTextMobile,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        ),
                      ));
                },
              ));
    } else {
      showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        alignment: Alignment.center,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(screenSizeHeight * 0.03))),
            backgroundColor: Colors.white,
            child: Container(
              padding: EdgeInsets.all(screenSizeHeight * 0.03),
              decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(screenSizeHeight * 0.02)),
              ),
              width: screenSizeWidth * 0.5,
              child: ListView(
                padding: EdgeInsets.only(
                  top: 0,
                  left: screenSizeWidth * 0.03,
                  right: screenSizeWidth * 0.03,
                  bottom: screenSizeHeight * 0.03,
                ),
                shrinkWrap: true,
                physics: ScrollPhysics(),
                children: [
                  Container(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Icon(
                        Icons.close,
                        color: Theme.of(context).primaryColorLight,
                      ),
                    ),
                  ),
                  Text(
                    'Información adicional',
                    style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontStyle: FontStyle.normal,
                        fontFamily: 'Gotham',
                        decoration: TextDecoration.none,
                        fontSize: titleWeb,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    height: screenSizeHeight * 0.015,
                  ),
                  Text(
                    'Requerimos de la siguiente información para vincular tu página web con Cumbia',
                    style: TextStyle(
                        color: Theme.of(context).secondaryHeaderColor,
                        fontStyle: FontStyle.normal,
                        fontFamily: 'Gotham',
                        decoration: TextDecoration.none,
                        fontSize: contentTextWeb,
                        fontWeight: FontWeight.w300),
                    textAlign: TextAlign.center,
                  ),
                  Container(
                    height: screenSizeHeight * 0.05,
                  ),
                  Text(
                    'Información personal',
                    style: TextStyle(
                        color: Theme.of(context).dividerColor,
                        fontStyle: FontStyle.normal,
                        fontFamily: 'Gotham',
                        decoration: TextDecoration.none,
                        fontSize: secondaryTextWeb,
                        fontWeight: FontWeight.w700),
                    textAlign: TextAlign.left,
                  ),
                  Container(
                    height: screenSizeHeight * 0.015,
                  ),
                  Container(
                    child: Container(
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(screenSizeHeight * 0.02)),
                        color: Colors.white,
                      ),
                      child: ListView(
                        padding: EdgeInsets.only(
                          top: screenSizeHeight * 0.03,
                          left: screenSizeHeight * 0.04,
                          right: screenSizeHeight * 0.04,
                          bottom: screenSizeHeight * 0.03,
                        ),
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Expanded(
                                child: ListView(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  children: [
                                    Text(
                                      'Nombre',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextWeb,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    TextField(
                                      controller: name,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          userInfo.name = text;
                                        } else if (text.length == 0) {
                                          userInfo.name = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextWeb,
                                          fontWeight: FontWeight.w300),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextWeb,
                                            fontWeight: FontWeight.w300),
                                        hintText: userInfo.name == ''
                                            ? 'Tu nombre'
                                            : userInfo.name,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: screenSizeWidth * 0.03,
                              ),
                              Expanded(
                                child: ListView(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  children: [
                                    Text(
                                      'Apellido',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextWeb,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    TextField(
                                      controller: lastName,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          userInfo.lastName = text;
                                        } else if (text.length == 0) {
                                          userInfo.lastName = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextWeb,
                                          fontWeight: FontWeight.w300),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextWeb,
                                            fontWeight: FontWeight.w300),
                                        hintText: userInfo.lastName == ''
                                            ? 'Tus apellidos'
                                            : userInfo.lastName,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Container(
                            height: screenSizeHeight * 0.045,
                          ),
                          Text(
                            'Celular',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: contentTextWeb,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.left,
                          ),
                          Container(
                            height: screenSizeHeight * 0.01,
                          ),
                          Text(
                            'Esta información no será visible para los usuarios, lo usaremos para contactarte desde Cumbia',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: smallTextWeb,
                                fontWeight: FontWeight.w300),
                            textAlign: TextAlign.left,
                          ),
                          Container(
                            height: screenSizeHeight * 0.015,
                          ),
                          TextField(
                            controller: phone,
                            onChanged: (text) {
                              if (text.isNotEmpty) {
                                userInfo.phoneNumber = text;
                              } else if (text.length == 0) {
                                userInfo.phoneNumber = '';
                              }
                            },
                            onSubmitted: (text) async {},
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: contentTextWeb,
                                fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                  borderSide: BorderSide(
                                      width: 0.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                  borderSide: BorderSide(
                                      width: 0.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                  borderSide: BorderSide(
                                      width: 0.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.text_fields,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                              hintStyle: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w300),
                              hintText: userInfo.phoneNumber == ''
                                  ? 'Tu número'
                                  : userInfo.phoneNumber,
                            ),
                          ),
                          Container(
                            height: screenSizeHeight * 0.045,
                          ),
                          Text(
                            'Correo',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: contentTextWeb,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.left,
                          ),
                          Container(
                            height: screenSizeHeight * 0.01,
                          ),
                          Text(
                            'Esta información no será visible para los usuarios, lo usaremos para contactarte desde Cumbia',
                            style: TextStyle(
                                color: Theme.of(context).primaryColorDark,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: smallTextWeb,
                                fontWeight: FontWeight.w300),
                            textAlign: TextAlign.left,
                          ),
                          Container(
                            height: screenSizeHeight * 0.015,
                          ),
                          TextField(
                            controller: mail,
                            onChanged: (text) {
                              if (text.isNotEmpty) {
                                userInfo.secundaryEmail = text;
                              } else if (text.length == 0) {
                                userInfo.secundaryEmail = '';
                              }
                            },
                            onSubmitted: (text) async {},
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.emailAddress,
                            //enabled: false,
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: contentTextWeb,
                                fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                  borderSide: BorderSide(
                                      width: 0.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                  borderSide: BorderSide(
                                      width: 0.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                  borderSide: BorderSide(
                                      width: 0.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.text_fields,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                              hintStyle: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w300),
                              hintText: userInfo.secundaryEmail == ''
                                  ? 'Correo del usuario'
                                  : userInfo.secundaryEmail,
                            ),
                          ),
                          Container(
                            height: screenSizeHeight * 0.045,
                          ),
                          Text(
                            'NIT',
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: contentTextWeb,
                                fontWeight: FontWeight.w400),
                            textAlign: TextAlign.left,
                          ),
                          Container(
                            height: screenSizeHeight * 0.01,
                          ),
                          TextField(
                            controller: NIT,
                            onChanged: (text) {
                              if (text.isNotEmpty) {
                                userInfo.nit = text;
                              } else if (text.length == 0) {
                                userInfo.nit = '';
                              }
                            },
                            onSubmitted: (text) async {},
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.number,
                            style: TextStyle(
                                color: Theme.of(context).secondaryHeaderColor,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: contentTextWeb,
                                fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                  borderSide: BorderSide(
                                      width: 0.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                  borderSide: BorderSide(
                                      width: 0.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(16)),
                                  borderSide: BorderSide(
                                      width: 0.5,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor)),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(
                                Icons.text_fields,
                                color: Theme.of(context).secondaryHeaderColor,
                              ),
                              hintStyle: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w300),
                              hintText:
                                  userInfo.nit == '' ? 'Tu NIT' : userInfo.nit,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    height: screenSizeHeight * 0.06,
                  ),
                  GestureDetector(
                    onTap: () {
                      validateFieldsToSave();
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(
                          top: screenSizeHeight * 0.015,
                          bottom: screenSizeHeight * 0.015),
                      decoration: BoxDecoration(
                          color: Theme.of(context).secondaryHeaderColor,
                          borderRadius: BorderRadius.all(
                              Radius.circular(screenSizeHeight * 0.01))),
                      child: Text(
                        '¡Aceptar!',
                        style: TextStyle(
                            color: context.background,
                            fontStyle: FontStyle.normal,
                            fontFamily: 'Gotham',
                            decoration: TextDecoration.none,
                            fontSize: contentTextWeb,
                            fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 200),
      );
    }
  }

  validateFieldsToSave() async {
    List<String> values = [];
    if (userInfo.name == '') {
      values.add('Nombre de usuario');
    }
    if (userInfo.lastName == '') {
      values.add('Apellidos de usuario');
    }
    if (userInfo.phoneNumber == '') {
      values.add('Teléfono de usuario');
    }
    if (userInfo.secundaryEmail == '') {
      values.add('Correo electrónico');
    }
    if (userInfo.nit == '') {
      values.add('NIT');
    }

    var stringVal = '';
    values.forEach((element) {
      var index = values.indexOf(element);
      if (index == 0) {
        stringVal = '$element';
      } else {
        stringVal = stringVal + ',$element';
      }
    });

    if (userInfo.name == '' ||
        userInfo.lastName == '' ||
        userInfo.phoneNumber == '' ||
        userInfo.secundaryEmail == '' ||
        userInfo.nit == '') {
      dialogMessage('assets/img/error.png', 'Lo sentimos',
          'Por favor rellena los campos: $stringVal');
    } else {
      //validateCompanyFieldsToSave();
      saveUserInfo();
    }
  }

  saveUserInfo() async {
    dialogoCarga('Actualizando información...');

    Users userData = userInfo;

    var ref = _db.collection('users').doc(userData.userUID);

    ref.update(userData.toRegister()).whenComplete(() async {
      Navigator.of(context, rootNavigator: true).pop('dialog');

      Navigator.of(context, rootNavigator: true).pop('dialog');
    }).catchError((error) {
      //Hubo error al crear negocio

      dialogMessage('assets/img/error.png', 'Lo sentimos',
          'Ocurrió un error al guardar la información del usuario. Inténtelo de nuevo más tarde');
    });
  }

  //Alerta de info de compañía y métodos de guardado
  dialogCompanyInfoValues(screenSizeHeight, screenSizeWidth) {
    companyInfo.category =
        companyInfo.category == '' ? 'Turismo' : companyInfo.category;
    companyInfo.storePlatform = companyInfo.storePlatform == ''
        ? 'WooCommerce'
        : companyInfo.storePlatform;
    category = (companyInfo.category == '' ? 'Turismo' : companyInfo.category)!;
    virtualStore = (companyInfo.storePlatform == ''
        ? 'WooCommerce'
        : companyInfo.storePlatform)!;
    //userInfo.secundaryEmail = userInfo.secundaryEmail == '' ? userInfo.email : userInfo.secundaryEmail;
    //companyInfo.email = companyInfo.email == '' ? userInfo.email : companyInfo.email;
    isAliasValid = companyInfo.alias == '' ? false : true;

    if (screenSizeHeight >= screenSizeWidth) {
      showModalBottomSheet(
          //expand: true,
          context: context,
          backgroundColor: context.background,
          builder: (context) => StatefulBuilder(
                builder: (context, modalState) {
                  return Container(
                      height: screenSizeHeight * 0.9,
                      child: Material(
                        child: ListView(
                          padding: EdgeInsets.only(
                              top: screenSizeHeight * 0.045,
                              left: screenSizeWidth * 0.05,
                              right: screenSizeWidth * 0.05,
                              bottom: screenSizeHeight * 0.045),
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Icon(
                                  Icons.close,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                              ),
                            ),
                            Text(
                              'Información de empresa',
                              style: TextStyle(
                                  color: Theme.of(context).dividerColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: secondaryTextMobile,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.01,
                            ),
                            Text(
                              'Esta información será visible para los usuarios',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: smallTextMobile,
                                  fontWeight: FontWeight.w300),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.015,
                            ),
                            Container(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(screenSizeHeight * 0.02)),
                                  color: Colors.white,
                                ),
                                child: ListView(
                                  padding: EdgeInsets.only(
                                    top: screenSizeHeight * 0.03,
                                    left: screenSizeWidth * 0.04,
                                    right: screenSizeWidth * 0.04,
                                    bottom: screenSizeHeight * 0.03,
                                  ),
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  children: [
                                    Text(
                                      'Nombre de la empresa',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    TextField(
                                      controller: companyName,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          companyInfo.name = text;
                                        } else if (text.length == 0) {
                                          companyInfo.name = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.text,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w300),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextMobile,
                                            fontWeight: FontWeight.w300),
                                        hintText: companyInfo.name == ''
                                            ? 'Nombre de la empresa'
                                            : companyInfo.name,
                                      ),
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'Nombre de usuario',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    Text(
                                      'Con este nombre los usuarios podrán encontrar tu tienda facilmente',
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .primaryColorDark,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: smallTextMobile,
                                          fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    Row(
                                      children: [
                                        Expanded(
                                          flex: 10,
                                          child: TextField(
                                            controller: userName,
                                            onChanged: (text) {
                                              if (text.isNotEmpty) {
                                                modalState(() {
                                                  isAliasValid = false;
                                                  companyInfo.alias = text;
                                                });
                                              } else if (text.length == 0) {
                                                modalState(() {
                                                  isAliasValid = false;
                                                  companyInfo.alias = '';
                                                });
                                              }
                                            },
                                            onSubmitted: (text) async {
                                              if (text.isNotEmpty) {}
                                            },
                                            textCapitalization:
                                                TextCapitalization.none,
                                            keyboardType: TextInputType.text,
                                            style: TextStyle(
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                                fontStyle: FontStyle.normal,
                                                fontFamily: 'Gotham',
                                                decoration: TextDecoration.none,
                                                fontSize: contentTextMobile,
                                                fontWeight: FontWeight.w300),
                                            decoration: InputDecoration(
                                              border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(16)),
                                                  borderSide: BorderSide(
                                                      width: 0.5,
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor)),
                                              enabledBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(16)),
                                                  borderSide: BorderSide(
                                                      width: 0.5,
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor)),
                                              focusedBorder: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(16)),
                                                  borderSide: BorderSide(
                                                      width: 0.5,
                                                      color: Theme.of(context)
                                                          .secondaryHeaderColor)),
                                              filled: true,
                                              fillColor: Colors.white,
                                              prefixIcon: Icon(
                                                Icons.text_fields,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor,
                                              ),
                                              hintStyle: TextStyle(
                                                  color: Theme.of(context)
                                                      .secondaryHeaderColor,
                                                  fontStyle: FontStyle.normal,
                                                  fontFamily: 'Gotham',
                                                  decoration:
                                                      TextDecoration.none,
                                                  fontSize: contentTextMobile,
                                                  fontWeight: FontWeight.w300),
                                              hintText: companyInfo.alias == ''
                                                  ? 'Nombre de usuario'
                                                  : companyInfo.alias,
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: GestureDetector(
                                            onTap: () async {
                                              if (userName.text.isNotEmpty) {
                                                var alias = userName.text;
                                                var exist =
                                                    await verifyExistingAlias(
                                                        alias);
                                                modalState(() {
                                                  isAliasValid = exist == true
                                                      ? true
                                                      : false;
                                                  companyInfo.alias =
                                                      exist == true
                                                          ? alias
                                                          : '';
                                                });
                                              }
                                            },
                                            behavior: HitTestBehavior.opaque,
                                            child: Icon(
                                              isAliasValid != false
                                                  ? Icons.verified
                                                  : Icons.report_outlined,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'Categoría de la tienda',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    DropdownButton<String>(
                                      iconEnabledColor: Theme.of(context)
                                          .secondaryHeaderColor,
                                      alignment: Alignment.center,
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w300),
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                          child: Text('Turismo'),
                                          value: 'Turismo',
                                        ),
                                        DropdownMenuItem(
                                          child: Text('Alimentos y bebidas'),
                                          value: 'Alimentos y bebidas',
                                        ),
                                      ],
                                      onChanged: (change) {
                                        modalState(() {
                                          category = change??"";
                                        });
                                        companyInfo.category = change;
                                      },
                                      value: category,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'Plataforma de la tienda virtual',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w300),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    DropdownButton<String>(
                                      iconEnabledColor: Theme.of(context)
                                          .secondaryHeaderColor,
                                      alignment: Alignment.center,
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w300),
                                      isExpanded: true,
                                      items: const [
                                        DropdownMenuItem(
                                          child: Text('WooCommerce'),
                                          value: 'WooCommerce',
                                        ),
                                        DropdownMenuItem(
                                          child: Text('Shopify'),
                                          value: 'Shopify',
                                        ),
                                      ],
                                      onChanged: (change) {
                                        modalState(() {
                                          virtualStore = change??"";
                                        });
                                        companyInfo.storePlatform = change;
                                      },
                                      value: virtualStore,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'Página web',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    TextField(
                                      controller: webPage,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          companyInfo.webSite = text;
                                        } else if (text.length == 0) {
                                          companyInfo.webSite = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.url,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w300),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextMobile,
                                            fontWeight: FontWeight.w300),
                                        hintText: companyInfo.webSite == ''
                                            ? 'Página web'
                                            : companyInfo.webSite,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: screenSizeHeight * 0.06,
                            ),
                            GestureDetector(
                              onTap: () {
                                validateCompanyFieldsToSave();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    top: screenSizeHeight * 0.015,
                                    bottom: screenSizeHeight * 0.015),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            screenSizeHeight * 0.01))),
                                child: Text(
                                  '¡Aceptar!',
                                  style: TextStyle(
                                      color: context.background,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Gotham',
                                      decoration: TextDecoration.none,
                                      fontSize: contentTextMobile,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        ),
                      ));
                },
              ));
    } else {
      showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        alignment: Alignment.center,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, modalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(screenSizeHeight * 0.03))),
              backgroundColor: Colors.white,
              child: Container(
                padding: EdgeInsets.all(screenSizeHeight * 0.03),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(screenSizeHeight * 0.02)),
                ),
                width: screenSizeWidth * 0.5,
                child: ListView(
                  padding: EdgeInsets.only(
                    top: 0,
                    left: screenSizeWidth * 0.03,
                    right: screenSizeWidth * 0.03,
                    bottom: screenSizeHeight * 0.03,
                  ),
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          Icons.close,
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                    ),
                    Text(
                      'Información de empresa',
                      style: TextStyle(
                          color: Theme.of(context).dividerColor,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Gotham',
                          decoration: TextDecoration.none,
                          fontSize: secondaryTextWeb,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.left,
                    ),
                    Container(
                      height: screenSizeHeight * 0.01,
                    ),
                    Text(
                      'Esta información será visible para los usuarios',
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Gotham',
                          decoration: TextDecoration.none,
                          fontSize: smallTextWeb,
                          fontWeight: FontWeight.w300),
                      textAlign: TextAlign.left,
                    ),
                    Container(
                      height: screenSizeHeight * 0.015,
                    ),
                    Container(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(screenSizeHeight * 0.02)),
                          color: Colors.white,
                        ),
                        child: ListView(
                          padding: EdgeInsets.only(
                            top: screenSizeHeight * 0.03,
                            left: screenSizeWidth * 0.04,
                            right: screenSizeWidth * 0.04,
                            bottom: screenSizeHeight * 0.03,
                          ),
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          children: [
                            Text(
                              'Nombre de la empresa',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.01,
                            ),
                            TextField(
                              controller: companyName,
                              onChanged: (text) {
                                if (text.isNotEmpty) {
                                  companyInfo.name = text;
                                } else if (text.length == 0) {
                                  companyInfo.name = '';
                                }
                              },
                              onSubmitted: (text) async {},
                              textCapitalization: TextCapitalization.none,
                              keyboardType: TextInputType.text,
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w300),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                        width: 0.5,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                        width: 0.5,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                        width: 0.5,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(
                                  Icons.text_fields,
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                                hintStyle: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Gotham',
                                    decoration: TextDecoration.none,
                                    fontSize: contentTextWeb,
                                    fontWeight: FontWeight.w300),
                                hintText: companyInfo.name == ''
                                    ? 'Nombre de la empresa'
                                    : companyInfo.name,
                              ),
                            ),
                            Container(
                              height: screenSizeHeight * 0.045,
                            ),
                            Text(
                              'Nombre de usuario',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.01,
                            ),
                            Text(
                              'Con este nombre los usuarios podrán encontrar tu tienda facilmente',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: smallTextWeb,
                                  fontWeight: FontWeight.w300),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.01,
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 10,
                                  child: TextField(
                                    controller: userName,
                                    onChanged: (text) {
                                      if (text.isNotEmpty) {
                                        modalState(() {
                                          isAliasValid = false;
                                          companyInfo.alias = text;
                                        });
                                      } else if (text.length == 0) {
                                        modalState(() {
                                          isAliasValid = false;
                                          companyInfo.alias = '';
                                        });
                                      }
                                    },
                                    onSubmitted: (text) async {},
                                    textCapitalization: TextCapitalization.none,
                                    keyboardType: TextInputType.text,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: contentTextWeb,
                                        fontWeight: FontWeight.w300),
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      enabledBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      focusedBorder: OutlineInputBorder(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(16)),
                                          borderSide: BorderSide(
                                              width: 0.5,
                                              color: Theme.of(context)
                                                  .secondaryHeaderColor)),
                                      filled: true,
                                      fillColor: Colors.white,
                                      prefixIcon: Icon(
                                        Icons.text_fields,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor,
                                      ),
                                      hintStyle: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextWeb,
                                          fontWeight: FontWeight.w300),
                                      hintText: companyInfo.alias == ''
                                          ? 'Nombre de usuario'
                                          : companyInfo.alias,
                                    ),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: GestureDetector(
                                    onTap: () async {
                                      if (userName.text.isNotEmpty) {
                                        var alias = userName.text;
                                        var exist =
                                            await verifyExistingAlias(alias);
                                        modalState(() {
                                          isAliasValid =
                                              exist == true ? true : false;
                                          companyInfo.alias =
                                              exist == true ? alias : '';
                                        });
                                      }
                                    },
                                    behavior: HitTestBehavior.opaque,
                                    child: Icon(
                                      isAliasValid != false
                                          ? Icons.verified
                                          : Icons.report_outlined,
                                      color: Theme.of(context)
                                          .secondaryHeaderColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: screenSizeHeight * 0.045,
                            ),
                            Text(
                              'Categoría de la tienda',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.01,
                            ),
                            DropdownButton<String>(
                              iconEnabledColor:
                                  Theme.of(context).secondaryHeaderColor,
                              alignment: Alignment.center,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w300),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  child: Text('Turismo'),
                                  value: 'Turismo',
                                ),
                                DropdownMenuItem(
                                  child: Text('Alimentos y bebidas'),
                                  value: 'Alimentos y bebidas',
                                ),
                              ],
                              onChanged: (change) {
                                modalState(() {
                                  category = change??"";
                                });
                                companyInfo.category = change;
                              },
                              value: category,
                            ),
                            Container(
                              height: screenSizeHeight * 0.045,
                            ),
                            Text(
                              'Plataforma de la tienda virtual',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.01,
                            ),
                            DropdownButton<String>(
                              iconEnabledColor:
                                  Theme.of(context).secondaryHeaderColor,
                              alignment: Alignment.center,
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w300),
                              isExpanded: true,
                              items: const [
                                DropdownMenuItem(
                                  child: Text('WooCommerce'),
                                  value: 'WooCommerce',
                                ),
                                DropdownMenuItem(
                                  child: Text('Shopify'),
                                  value: 'Shopify',
                                ),
                              ],
                              onChanged: (change) {
                                modalState(() {
                                  virtualStore = change??"";
                                });
                                companyInfo.storePlatform = change;
                              },
                              value: virtualStore,
                            ),
                            Container(
                              height: screenSizeHeight * 0.045,
                            ),
                            Text(
                              'Página web',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.01,
                            ),
                            TextField(
                              controller: webPage,
                              onChanged: (text) {
                                if (text.isNotEmpty) {
                                  companyInfo.webSite = text;
                                } else if (text.length == 0) {
                                  companyInfo.webSite = '';
                                }
                              },
                              onSubmitted: (text) async {},
                              textCapitalization: TextCapitalization.none,
                              keyboardType: TextInputType.url,
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w300),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                        width: 0.5,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                        width: 0.5,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                        width: 0.5,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(
                                  Icons.text_fields,
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                                hintStyle: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Gotham',
                                    decoration: TextDecoration.none,
                                    fontSize: contentTextWeb,
                                    fontWeight: FontWeight.w300),
                                hintText: companyInfo.webSite == ''
                                    ? 'Página web'
                                    : companyInfo.webSite,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: screenSizeHeight * 0.06,
                    ),
                    GestureDetector(
                      onTap: () {
                        validateCompanyFieldsToSave();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            top: screenSizeHeight * 0.015,
                            bottom: screenSizeHeight * 0.015),
                        decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.all(
                                Radius.circular(screenSizeHeight * 0.01))),
                        child: Text(
                          '¡Aceptar!',
                          style: TextStyle(
                              color: context.background,
                              fontStyle: FontStyle.normal,
                              fontFamily: 'Gotham',
                              decoration: TextDecoration.none,
                              fontSize: contentTextWeb,
                              fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        },
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 200),
      );
    }
  }

  validateCompanyFieldsToSave() async {
    List<String> values = [];

    if (companyInfo.name == '') {
      values.add('Nombre de empresa');
    }
    if (companyInfo.alias == '') {
      values.add('Usuario de empresa');
    }
    if (companyInfo.category == '') {
      values.add('Categoría de tienda');
    }
    if (companyInfo.storePlatform == '') {
      values.add('Plataforma de tienda virtual');
    }
    if (companyInfo.webSite == '') {
      values.add('Página web');
    }
    /*
    if (companyInfo.phoneNumber == '') {
      values.add('Teléfono de contacto de empresa');
    }
    if (companyInfo.email == '') {
      values.add('Correo electróico de contacto de empresa');
    }*/

    var stringVal = '';
    values.forEach((element) {
      var index = values.indexOf(element);
      if (index == 0) {
        stringVal = '$element';
      } else {
        stringVal = stringVal + ',$element';
      }
    });

    if (companyInfo.name == '' ||
        companyInfo.alias == '' ||
        companyInfo.category == '' ||
        companyInfo.storePlatform == '' ||
        companyInfo.webSite == '') {
      //companyInfo.phoneNumber == '' || companyInfo.email == ''
      dialogMessage('assets/img/error.png', 'Lo sentimos',
          'Por favor rellena los campos: $stringVal');
    } else {
      validateAliasValid();
    }
  }

  validateAliasValid() {
    if (isAliasValid == true) {
      saveCompanyInfo();
    } else {
      dialogMessage('assets/img/error.png', 'Lo sentimos',
          'Por favor confirma que el alias que escogiste para tu empresa sea verificado');
    }
  }

  saveCompanyInfo() async {
    dialogoCarga('Actualizando información...');

    CompanyData companyData = companyInfo;

    var refCompany = _db.collection('companies').doc(companyData.companyID);

    refCompany.update(companyData.toRegister()).whenComplete(() async {
      Navigator.of(context, rootNavigator: true).pop('dialog');

      Navigator.of(context, rootNavigator: true).pop('dialog');
    }).catchError((error) {
      //Hubo error al crear negocio

      dialogMessage('assets/img/error.png', 'Lo sentimos',
          'Ocurrió un error al guardar la información de la empresa. Inténtelo de nuevo más tarde');
    });
  }

  //Alerta de info de contacto y métodos de guardado
  dialogContactInfoValues(screenSizeHeight, screenSizeWidth) {
    //companyInfo.category = companyInfo.category == '' ? 'Turismo': companyInfo.category;
    //companyInfo.storePlatform = companyInfo.storePlatform == '' ? 'WooCommerce': companyInfo.storePlatform;
    //category = companyInfo.category == '' ? 'Turismo': companyInfo.category;
    //virtualStore = companyInfo.storePlatform == '' ? 'WooCommerce': companyInfo.storePlatform;
    //userInfo.secundaryEmail = userInfo.secundaryEmail == '' ? userInfo.email : userInfo.secundaryEmail;
    companyInfo.email =
        companyInfo.email == '' ? userInfo.email : companyInfo.email;
    //isAliasValid = companyInfo.alias == '' ? false: true;

    if (screenSizeHeight >= screenSizeWidth) {
      showModalBottomSheet(
          //expand: true,
          context: context,
          backgroundColor: context.background,
          builder: (context) => StatefulBuilder(
                builder: (context, modalState) {
                  return Container(
                      height: screenSizeHeight * 0.7,
                      child: Material(
                        child: ListView(
                          padding: EdgeInsets.only(
                              top: screenSizeHeight * 0.045,
                              left: screenSizeWidth * 0.05,
                              right: screenSizeWidth * 0.05,
                              bottom: screenSizeHeight * 0.045),
                          physics: ScrollPhysics(),
                          shrinkWrap: true,
                          children: [
                            Container(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.pop(context);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Icon(
                                  Icons.close,
                                  color: Theme.of(context).primaryColorLight,
                                ),
                              ),
                            ),
                            Text(
                              'Información de contacto',
                              style: TextStyle(
                                  color: Theme.of(context).dividerColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: secondaryTextMobile,
                                  fontWeight: FontWeight.w700),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.01,
                            ),
                            Text(
                              'Esta información será visible para los usuarios',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColorDark,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: smallTextMobile,
                                  fontWeight: FontWeight.w300),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.015,
                            ),
                            Container(
                              child: Container(
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(screenSizeHeight * 0.02)),
                                  color: Colors.white,
                                ),
                                child: ListView(
                                  padding: EdgeInsets.only(
                                    top: screenSizeHeight * 0.03,
                                    left: screenSizeWidth * 0.04,
                                    right: screenSizeWidth * 0.04,
                                    bottom: screenSizeHeight * 0.03,
                                  ),
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  children: [
                                    Text(
                                      'Celular de contacto',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    TextField(
                                      controller: businessPhone,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          companyInfo.phoneNumber = text;
                                        } else if (text.length == 0) {
                                          companyInfo.phoneNumber = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.phone,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w300),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextMobile,
                                            fontWeight: FontWeight.w300),
                                        hintText: companyInfo.phoneNumber == ''
                                            ? 'Celular'
                                            : companyInfo.phoneNumber,
                                      ),
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.045,
                                    ),
                                    Text(
                                      'Correo de contacto',
                                      style: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w400),
                                      textAlign: TextAlign.left,
                                    ),
                                    Container(
                                      height: screenSizeHeight * 0.01,
                                    ),
                                    TextField(
                                      controller: businessMail,
                                      onChanged: (text) {
                                        if (text.isNotEmpty) {
                                          companyInfo.email = text;
                                        } else if (text.length == 0) {
                                          companyInfo.email = '';
                                        }
                                      },
                                      onSubmitted: (text) async {},
                                      textCapitalization:
                                          TextCapitalization.none,
                                      keyboardType: TextInputType.emailAddress,
                                      style: TextStyle(
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                          fontStyle: FontStyle.normal,
                                          fontFamily: 'Gotham',
                                          decoration: TextDecoration.none,
                                          fontSize: contentTextMobile,
                                          fontWeight: FontWeight.w300),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(16)),
                                            borderSide: BorderSide(
                                                width: 0.5,
                                                color: Theme.of(context)
                                                    .secondaryHeaderColor)),
                                        filled: true,
                                        fillColor: Colors.white,
                                        prefixIcon: Icon(
                                          Icons.text_fields,
                                          color: Theme.of(context)
                                              .secondaryHeaderColor,
                                        ),
                                        hintStyle: TextStyle(
                                            color: Theme.of(context)
                                                .secondaryHeaderColor,
                                            fontStyle: FontStyle.normal,
                                            fontFamily: 'Gotham',
                                            decoration: TextDecoration.none,
                                            fontSize: contentTextMobile,
                                            fontWeight: FontWeight.w300),
                                        hintText: companyInfo.email == ''
                                            ? 'Correo'
                                            : companyInfo.email,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: screenSizeHeight * 0.06,
                            ),
                            GestureDetector(
                              onTap: () {
                                validateContactFieldsToSave();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(
                                    top: screenSizeHeight * 0.015,
                                    bottom: screenSizeHeight * 0.015),
                                decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            screenSizeHeight * 0.01))),
                                child: Text(
                                  '¡Aceptar!',
                                  style: TextStyle(
                                      color: context.background,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Gotham',
                                      decoration: TextDecoration.none,
                                      fontSize: contentTextMobile,
                                      fontWeight: FontWeight.w700),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        ),
                      ));
                },
              ));
    } else {
      showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        alignment: Alignment.center,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (context, modalState) {
            return Dialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                      Radius.circular(screenSizeHeight * 0.03))),
              backgroundColor: Colors.white,
              child: Container(
                padding: EdgeInsets.all(screenSizeHeight * 0.03),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(
                      Radius.circular(screenSizeHeight * 0.02)),
                ),
                width: screenSizeWidth * 0.5,
                child: ListView(
                  padding: EdgeInsets.only(
                    top: 0,
                    left: screenSizeWidth * 0.03,
                    right: screenSizeWidth * 0.03,
                    bottom: screenSizeHeight * 0.03,
                  ),
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: [
                    Container(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        behavior: HitTestBehavior.opaque,
                        child: Icon(
                          Icons.close,
                          color: Theme.of(context).primaryColorLight,
                        ),
                      ),
                    ),
                    Text(
                      'Información de contacto',
                      style: TextStyle(
                          color: Theme.of(context).dividerColor,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Gotham',
                          decoration: TextDecoration.none,
                          fontSize: secondaryTextWeb,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.left,
                    ),
                    Container(
                      height: screenSizeHeight * 0.01,
                    ),
                    Text(
                      'Esta información será visible para los usuarios',
                      style: TextStyle(
                          color: Theme.of(context).primaryColorDark,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Gotham',
                          decoration: TextDecoration.none,
                          fontSize: smallTextWeb,
                          fontWeight: FontWeight.w300),
                      textAlign: TextAlign.left,
                    ),
                    Container(
                      height: screenSizeHeight * 0.015,
                    ),
                    Container(
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(screenSizeHeight * 0.02)),
                          color: Colors.white,
                        ),
                        child: ListView(
                          padding: EdgeInsets.only(
                            top: screenSizeHeight * 0.03,
                            left: screenSizeWidth * 0.04,
                            right: screenSizeWidth * 0.04,
                            bottom: screenSizeHeight * 0.03,
                          ),
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          children: [
                            Text(
                              'Celular de contacto',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.01,
                            ),
                            TextField(
                              controller: businessPhone,
                              onChanged: (text) {
                                if (text.isNotEmpty) {
                                  companyInfo.phoneNumber = text;
                                } else if (text.length == 0) {
                                  companyInfo.phoneNumber = '';
                                }
                              },
                              onSubmitted: (text) async {},
                              textCapitalization: TextCapitalization.none,
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w300),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                        width: 0.5,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                        width: 0.5,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                        width: 0.5,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(
                                  Icons.text_fields,
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                                hintStyle: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Gotham',
                                    decoration: TextDecoration.none,
                                    fontSize: contentTextWeb,
                                    fontWeight: FontWeight.w300),
                                hintText: companyInfo.phoneNumber == ''
                                    ? 'Celular'
                                    : companyInfo.phoneNumber,
                              ),
                            ),
                            Container(
                              height: screenSizeHeight * 0.045,
                            ),
                            Text(
                              'Correo de contacto',
                              style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w400),
                              textAlign: TextAlign.left,
                            ),
                            Container(
                              height: screenSizeHeight * 0.01,
                            ),
                            TextField(
                              controller: businessMail,
                              onChanged: (text) {
                                if (text.isNotEmpty) {
                                  companyInfo.email = text;
                                } else if (text.length == 0) {
                                  companyInfo.email = '';
                                }
                              },
                              onSubmitted: (text) async {},
                              textCapitalization: TextCapitalization.none,
                              keyboardType: TextInputType.emailAddress,
                              style: TextStyle(
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontStyle: FontStyle.normal,
                                  fontFamily: 'Gotham',
                                  decoration: TextDecoration.none,
                                  fontSize: contentTextWeb,
                                  fontWeight: FontWeight.w300),
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                        width: 0.5,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                        width: 0.5,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(16)),
                                    borderSide: BorderSide(
                                        width: 0.5,
                                        color: Theme.of(context)
                                            .secondaryHeaderColor)),
                                filled: true,
                                fillColor: Colors.white,
                                prefixIcon: Icon(
                                  Icons.text_fields,
                                  color: Theme.of(context).secondaryHeaderColor,
                                ),
                                hintStyle: TextStyle(
                                    color:
                                        Theme.of(context).secondaryHeaderColor,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Gotham',
                                    decoration: TextDecoration.none,
                                    fontSize: contentTextWeb,
                                    fontWeight: FontWeight.w300),
                                hintText: companyInfo.email == ''
                                    ? 'Correo'
                                    : companyInfo.email,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: screenSizeHeight * 0.06,
                    ),
                    GestureDetector(
                      onTap: () {
                        validateContactFieldsToSave();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            top: screenSizeHeight * 0.015,
                            bottom: screenSizeHeight * 0.015),
                        decoration: BoxDecoration(
                            color: Theme.of(context).secondaryHeaderColor,
                            borderRadius: BorderRadius.all(
                                Radius.circular(screenSizeHeight * 0.01))),
                        child: Text(
                          '¡Aceptar!',
                          style: TextStyle(
                              color: context.background,
                              fontStyle: FontStyle.normal,
                              fontFamily: 'Gotham',
                              decoration: TextDecoration.none,
                              fontSize: contentTextWeb,
                              fontWeight: FontWeight.w700),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    )
                  ],
                ),
              ),
            );
          });
        },
        animationType: DialogTransitionType.fadeScale,
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 200),
      );
    }
  }

  validateContactFieldsToSave() async {
    List<String> values = [];

    /*
    if (companyInfo.name == '') {
      values.add('Nombre de empresa');
    }
    if (companyInfo.alias == '') {
      values.add('Usuario de empresa');
    }
    if (companyInfo.category == '') {
      values.add('Categoría de tienda');
    }
    if (companyInfo.storePlatform == '') {
      values.add('Plataforma de tienda virtual');
    }
    if (companyInfo.webSite == '') {
      values.add('Página web');
    }*/

    if (companyInfo.phoneNumber == '') {
      values.add('Teléfono de contacto de empresa');
    }
    if (companyInfo.email == '') {
      values.add('Correo electróico de contacto de empresa');
    }

    var stringVal = '';
    values.forEach((element) {
      var index = values.indexOf(element);
      if (index == 0) {
        stringVal = '$element';
      } else {
        stringVal = stringVal + ',$element';
      }
    });

    if (companyInfo.phoneNumber == '' || companyInfo.email == '') {
      //companyInfo.name == '' || companyInfo.alias == '' || companyInfo.category == ''
      //         || companyInfo.storePlatform == '' || companyInfo.webSite == ''
      dialogMessage('assets/img/error.png', 'Lo sentimos',
          'Por favor rellena los campos: $stringVal');
    } else {
      saveContactInfo();
    }
  }

  saveContactInfo() async {
    dialogoCarga('Actualizando información...');

    CompanyData companyData = companyInfo;

    var refCompany = _db.collection('companies').doc(companyData.companyID);

    refCompany.update(companyData.toCreateContactInfo()).whenComplete(() async {
      Navigator.of(context, rootNavigator: true).pop('dialog');

      Navigator.of(context, rootNavigator: true).pop('dialog');
    }).catchError((error) {
      //Hubo error al crear negocio

      dialogMessage('assets/img/error.png', 'Lo sentimos',
          'Ocurrió un error al guardar la información de contacto de la empresa. Inténtelo de nuevo más tarde');
    });
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

  dialogMessage(type, tittle, description) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    if (width < height) {
      //Mobile
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            insetPadding: EdgeInsets.all(width * 0.05),
            backgroundColor: context.background,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(height * 0.03))),
            title: Container(),
            content: Container(
                width: width * 0.45,
                child: ListView(
                  padding: EdgeInsets.only(top: 0),
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Container(
                        height: height * 0.12,
                        width: height * 0.12,
                        child: Image.asset(type, fit: BoxFit.contain)),
                    Container(
                      height: height * 0.018,
                    ),
                    Text(
                      tittle,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Gotham',
                          decoration: TextDecoration.none,
                          fontSize: secondaryTextWeb,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      height: height * 0.01,
                    ),
                    Text(
                      description,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Gotham',
                          decoration: TextDecoration.none,
                          fontSize: secondaryTextWeb,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      height: height * 0.03,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            top: height * 0.015, bottom: height * 0.015),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight,
                            borderRadius: BorderRadius.all(
                                Radius.circular(height * 0.03))),
                        child: Text(
                          'Aceptar',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontStyle: FontStyle.normal,
                              fontFamily: 'Gotham',
                              decoration: TextDecoration.none,
                              fontSize: secondaryTextWeb,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    Container(
                      height: height * 0.015,
                    ),
                  ],
                )),
          );
        },
      );
    } else {
      //Web
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            insetPadding: EdgeInsets.all(width * 0.05),
            backgroundColor: context.background,
            shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.all(Radius.circular(height * 0.035))),
            title: Container(),
            content: Container(
                width: height * 0.38,
                child: ListView(
                  padding: EdgeInsets.only(top: 0),
                  physics: ScrollPhysics(),
                  shrinkWrap: true,
                  children: [
                    Container(
                        height: height * 0.12,
                        width: height * 0.12,
                        child: Image.asset(type, fit: BoxFit.contain)),
                    Container(
                      height: height * 0.018,
                    ),
                    Text(
                      tittle,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Gotham',
                          decoration: TextDecoration.none,
                          fontSize: secondaryTextWeb,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      height: height * 0.01,
                    ),
                    Text(
                      description,
                      style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontStyle: FontStyle.normal,
                          fontFamily: 'Gotham',
                          decoration: TextDecoration.none,
                          fontSize: secondaryTextWeb,
                          fontWeight: FontWeight.w700),
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      height: height * 0.03,
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.of(context, rootNavigator: true)
                            .pop('dialog');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(
                            top: height * 0.015, bottom: height * 0.015),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight,
                            borderRadius: BorderRadius.all(
                                Radius.circular(height * 0.03))),
                        child: Text(
                          'Aceptar',
                          style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontStyle: FontStyle.normal,
                              fontFamily: 'Gotham',
                              decoration: TextDecoration.none,
                              fontSize: secondaryTextWeb,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                    Container(
                      height: height * 0.015,
                    ),
                  ],
                )),
          );
        },
      );
    }
  }

  // dialogo de productos previos al stream
  dialogToOpenVideoUploadSection(screenSizeHeight, screenSizeWidth) {

    TextEditingController controller = TextEditingController();
    var products = [];
    bool loading=false;
    _videoFileName="";
    productsSelected.clear();
    Video_url_controller.text="";
    String _formatDuration(int durationInSeconds) {
      int minutes = (durationInSeconds / 60).truncate();
      int seconds = durationInSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
    void getVideoDuration(Uint8List videoBytes) {
      String base64Video = base64Encode(videoBytes);
      String blobUrl = 'data:video/mp4;base64,$base64Video';

      html.VideoElement video = html.VideoElement();
      video.src = blobUrl;
      video.onLoadedData.listen((_) {
        String duration = _formatDuration(video.duration.toInt());
        time=duration;
        print('Video duration: $duration');
        // Do whatever you need with the duration here
      });
    }

    TextStyle stepperTextStyle=TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none, fontSize: screenSizeHeight * 0.025, fontWeight: FontWeight.w700);
    List<ShopifyProductModel>? searchProducts;
    if (allProducts.ecommercePlatform == 'WooCommerce') {
      products = allProducts.wooProducts??[];
    } else if (allProducts.ecommercePlatform == 'Shopify') {
      products = allProducts.shopProducts??[];
      searchProducts=allProducts.shopProducts??[];
      setState(() {});
    }

    showAnimatedDialog(
      context: context,
      barrierDismissible: true,
      alignment: Alignment.center,
      builder: (BuildContext context) {

        currentStepper = 0;
        double progress=0.0;

        return StatefulBuilder(builder: (context, modalState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.02))),
            backgroundColor: Colors.white,
            child: Container(
              padding: EdgeInsets.all(screenSizeHeight * 0.03),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01)),
              ),
              width: screenSizeWidth * 0.7,
              height: screenSizeHeight * 0.8,
              child: StatefulBuilder(builder: (context, StateSetter setState) {
                return Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(width:20),
                        GestureDetector(
                            onTap: (){
                              setState(() {
                                currentStepper=0;
                              });
                            },
                            child: Column(
                              children: [
                                Image.asset(currentStepper>=0?"assets/img/checkmark.png":"assets/img/dot.png",color: currentStepper>=0?ColorConstants.primary:Colors.grey,height: screenSizeHeight * 0.1,width: screenSizeHeight * 0.1),
                              ],
                            )),
                        Expanded(
                          child: Container(
                              height: 5,
                              color:Colors.grey
                          ),
                        ),
                        GestureDetector(
                            onTap: (){
                              if ( _videoFileName == "") {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Selecione o vídeo!')),
                                );
                              }else{
                                setState(() {
                                  currentStepper=1;
                                });
                              }

                            },
                            child: Column(
                              children: [
                                Image.asset(currentStepper>=1?"assets/img/checkmark.png":"assets/img/dot.png",color: currentStepper>=1?ColorConstants.primary:Colors.grey,height: screenSizeHeight * 0.1,width: screenSizeHeight * 0.1),
                              ],
                            )),
                        Expanded(
                          child: Container(
                              height: 5,
                              color:Colors.grey
                          ),
                        ),
                        GestureDetector(
                            onTap: (){
                              if(productsSelected.isEmpty){
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Selecione o product!')),
                                );
                              }else{
                                setState(() {
                                  currentStepper=2;
                                });
                              }
                            },
                            child: Column(
                              children: [
                                Image.asset(currentStepper>=2?"assets/img/checkmark.png":"assets/img/dot.png",color: currentStepper>=2?ColorConstants.primary:Colors.grey,height: screenSizeHeight * 0.1,width: screenSizeHeight * 0.1),
                              ],
                            )),
                        Expanded(
                          child: Container(
                              height: 5,
                              color:Colors.grey
                          ),
                        ),
                        GestureDetector(
                            onTap: (){
                              productsSelected.forEach((element) {
                                if(element.from==null){
                                  print(element.price);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text('Acrescentar tempo para todos os vídeos.')),
                                  );
                                  return;
                                }
                              });
                              setState(() {
                                currentStepper=3;
                              });
                            },
                            child: Column(
                              children: [
                                Image.asset(currentStepper>=3?"assets/img/checkmark.png":"assets/img/dot.png",color: currentStepper>=3?ColorConstants.primary:Colors.grey,height: screenSizeHeight * 0.1,width: screenSizeHeight * 0.1),

                              ],
                            )),
                        SizedBox(width:50),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Cargar vídeo', style: stepperTextStyle, textAlign: TextAlign.center,),
                        Text('Etiquetar Productos', style: stepperTextStyle, textAlign: TextAlign.center,),
                        Text('Configurar Hora', style: stepperTextStyle, textAlign: TextAlign.center,),
                        Text('Enlace De Video', style: stepperTextStyle, textAlign: TextAlign.center,),

                      ],
                    ),
                    currentStepper==0?
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(height: screenSizeHeight*0.13),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              elevation: 0,
                              side: const BorderSide(
                                width: 1.0,
                                color: Colors.transparent,
                              )),
                          onPressed: () async {

                            FilePickerResult? result = await FilePicker.platform.pickFiles( type: FileType.video, allowCompression: true );
                            setState((){
                              loading=true;
                            });
                            if (result != null && result.files.isNotEmpty) {
                              Uint8List videoBytes = result.files.single.bytes!;
                              getVideoDuration(videoBytes);
                            }
                            modalState(() {
                              _videoFileName = result!.files.first.name;
                              fileBytes = result.files.first.bytes;
                            });

                            final now = DateTime.now().microsecondsSinceEpoch.toString();
                            final storageRef = FirebaseStorage.instance.ref();
                            final imageRef = storageRef.child("uploads/" + _videoFileName + now + ".mp4");
                            UploadTask uploadTask = imageRef.putData(fileBytes!);
                            uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
                              progress = snapshot.bytesTransferred / snapshot.totalBytes;
                              // Now 'progress' contains the upload progress as a value between 0.0 and 1.0
                              // You can use this value to update the UI, such as showing a progress bar.

                              setState(() {
                                // Update your UI here with the current upload progress.
                                // For example, you might update a progress bar.
                              });
                            });
                            uploadTask.whenComplete(() async {
                              video_url = await imageRef.getDownloadURL();
                              setState((){
                                loading=false;
                              });

                            }).catchError((onError) {
                              modalState(() {});
                              print(onError);
                            });

                            // VideoPlayerController controller = await VideoPlayerController.file( File(result!.files.single.path!))
                            //   ..initialize();
                            // time=_formatDuration(controller.value.duration);

                          },
                          child: Icon(
                            Icons.cloud_upload_outlined,
                            color: Theme.of(context).secondaryHeaderColor,
                            size: screenSizeHeight * 0.15,
                          ),
                        ),
                        Text(
                          'Cargar vídeo',
                          style: TextStyle(
                            fontSize: screenSizeHeight * 0.025,
                            fontWeight: FontWeight.w700,
                            color: Theme.of(context).secondaryHeaderColor,
                          ),
                        ),
                        SizedBox(height: 20),
                        loading?Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Cargando vídeos... ${(progress*100).toInt()}%",
                              style: TextStyle(fontSize: screenSizeHeight * 0.018),
                            ),
                            // SizedBox(width:20),
                            // Container(height:35,width:35,child: CircularProgressIndicator(color: Colors.black54)),
                          ],
                        ):Visibility(
                          visible: !_videoFileName.isEmpty, // Hide if myText is empty
                          child: Text(
                            _videoFileName,
                            style: TextStyle(fontSize: screenSizeHeight * 0.018),
                          ),
                        ),
                        SizedBox(height: screenSizeHeight*0.14),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: (){
                                Navigator.pop(context);
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015),
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                                ),
                                child: Text(' Anterior ', style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                    fontSize: screenSizeHeight * 0.025, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                              ),
                            ),
                            Spacer(flex: 4,),
                            Expanded(
                              child: GestureDetector(
                                onTap: ()async {
                                  if(!loading){
                                    if (currentStepper == 0 && _videoFileName == "") {

                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Mensaje de alerta'),
                                            content: Text('Selecione o vídeo!'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                      setState(() {});
                                    }else
                                    {
                                      currentStepper < 3 ? currentStepper++ : null;
                                    }
                                    setState(() {

                                    });
                                  }
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.symmetric(vertical: screenSizeHeight * 0.015),
                                  decoration: BoxDecoration(
                                      color:loading?Colors.grey:Theme.of(context).secondaryHeaderColor,
                                      borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                                  ),
                                  child: Text('Siguiente', style: TextStyle(
                                      color: context.background,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Gotham',
                                      decoration: TextDecoration.none,
                                      fontSize: screenSizeHeight * 0.025,
                                      fontWeight: FontWeight.w700
                                  ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ):
                    currentStepper==1?
                    Container(
                      width: screenSizeWidth * 0.7,
                      height: screenSizeHeight * 0.589,
                      child: Column(
                        children: [
                          Expanded(
                            child: Visibility(
                              visible: products.length == 0 ? false : true,
                              child: SingleChildScrollView(
                                child: GridView.builder(
                                  padding: EdgeInsets.only(top: 10),
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                    childAspectRatio: 0.7,
                                    crossAxisSpacing: screenSizeHeight * 0.05,
                                    mainAxisSpacing: screenSizeHeight * 0.1,
                                    crossAxisCount: 5,
                                  ),
                                  itemCount: products.length,
                                  itemBuilder: (context, int index) => productShowWidget(
                                      index,
                                      screenSizeWidth,
                                      screenSizeHeight,
                                      modalState
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    currentStepper -= 1;
                                  });
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                                  ),
                                  child: Text(' Anterior ', style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                      fontSize: screenSizeHeight * 0.025, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                                ),

                              ),
                              Spacer(flex: 4,),
                              Expanded(
                                child: GestureDetector(
                                  onTap: ()async {
                                    if (currentStepper == 1 && productsSelected.isEmpty) {
                                      showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text('Mensaje de alerta'),
                                            content: Text('Seleccione un producto'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context).pop();
                                                },
                                                child: Text('OK'),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    } else
                                    {
                                      currentStepper < 3 ? currentStepper++ : null;
                                    }
                                    setState(() {});
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).secondaryHeaderColor,
                                        borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                                    ),
                                    child: Text('Siguiente', style: TextStyle(
                                        color: context.background,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: screenSizeHeight * 0.025,
                                        fontWeight: FontWeight.w700
                                    ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ):
                    currentStepper==2?
                    Container(
                      width: screenSizeWidth * 0.7,
                      height: screenSizeHeight * 0.589,
                      child: Column(
                        children: [
                          productsSelected.length!=0?Expanded(
                            child: GridView.builder(
                              padding: EdgeInsets.only(top: 10),
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                childAspectRatio: 0.7,
                                crossAxisSpacing: screenSizeHeight * 0.05,
                                mainAxisSpacing: screenSizeHeight * 0.1,
                                crossAxisCount: 5,
                              ),
                              itemCount: productsSelected.length == 0 ? 1 : productsSelected.length,
                              itemBuilder: (context, int index) => cellsProductsWithTime(index, screenSizeWidth, screenSizeHeight, modalState),
                            ),
                          ):SizedBox(),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: (){
                                  setState(() {
                                    currentStepper -= 1;
                                  });
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                                  ),
                                  child: Text(' Anterior ', style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                      fontSize: screenSizeHeight * 0.025, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                                ),

                              ),
                              Spacer(flex: 4,),
                              Expanded(
                                child: GestureDetector(
                                  onTap: ()async {
                                    productsSelected.forEach((element) {
                                      if(element.from==null){
                                        print(element.price);
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(
                                              content: Text('Añade tiempo a todos los vídeos.')),
                                        );
                                        return;
                                      }
                                    });
                                    // if (currentStepper == 0 && _videoFileName == "") {
                                    //
                                    //   showDialog(
                                    //     context: context,
                                    //     builder: (BuildContext context) {
                                    //       return AlertDialog(
                                    //         title: Text('Erro'),
                                    //         content: Text('Selecione o vídeo!'),
                                    //         actions: [
                                    //           TextButton(
                                    //             onPressed: () {
                                    //               Navigator.of(context).pop();
                                    //             },
                                    //             child: Text('OK'),
                                    //           ),
                                    //         ],
                                    //       );
                                    //     },
                                    //   );
                                    //   setState(() {});
                                    // }else
                                    // if (currentStepper == 1 && productsSelected.isEmpty) {
                                    //   showDialog(
                                    //     context: context,
                                    //     builder: (BuildContext context) {
                                    //       return AlertDialog(
                                    //         title: Text('Erro'),
                                    //         content: Text('Selecione o produto!'),
                                    //         actions: [
                                    //           TextButton(
                                    //             onPressed: () {
                                    //               Navigator.of(context).pop();
                                    //             },
                                    //             child: Text('OK'),
                                    //           ),
                                    //         ],
                                    //       );
                                    //     },
                                    //   );
                                    //   setState(() {
                                    //
                                    //   });
                                    // } else
                                    // {
                                    // if (currentStepper == 3) {
                                    setState(() {step3loading=true;});
                                    User? user = FirebaseAuth.instance.currentUser;
                                    var docRef = await FirebaseFirestore.instance.collection('tbl_uploaded_videos').doc();
                                    // Convert the List<dynamic> to a List<Map<String, dynamic>>
                                    List<Map<String, dynamic>> productsData = productsSelected.map<Map<String, dynamic>>((product) => {
                                      'id': product.id,
                                      'title': product.title,
                                      'variant_id': product.variantId,
                                      'image': product.images,
                                      'price': product.price,
                                      'from': product.from,
                                      'to': product.to,
                                    }).toList();
                                    await docRef.set({
                                      'user_id': user?.uid??"",
                                      "video_name": _videoFileName,
                                      'company_id':userInfo.companiesID,
                                      "video_path": video_url,
                                      "storePlatform": companyInfo.storePlatform,
                                      "webSite": companyInfo.webSite,
                                      "products": productsData,
                                    });
                                    Video_url_controller.text = html.window.location.href+"" + docRef.id;
                                    currentStepper++;
                                    setState(() {step3loading=false;});
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).secondaryHeaderColor,
                                        borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                                    ),
                                    child: step3loading?CircularProgressIndicator( color: Colors.white, ):Text('Siguiente', style: TextStyle(
                                        color: context.background,
                                        fontStyle: FontStyle.normal,
                                        fontFamily: 'Gotham',
                                        decoration: TextDecoration.none,
                                        fontSize: screenSizeHeight * 0.025,
                                        fontWeight: FontWeight.w700
                                    ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ):
                    Column(
                      children: [
                        Center(
                          child: Text(''),
                        ),
                        SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: Video_url_controller,
                                readOnly: true,
                                decoration: InputDecoration(
                                  labelText: 'URL',
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            GestureDetector(
                              onTap: (){
                                Clipboard.setData(ClipboardData(
                                    text: Video_url_controller.text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text('Copiado al portapapeles')),
                                );
                              },
                              child: Container(
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(horizontal: screenSizeHeight * 0.015, vertical: screenSizeHeight * 0.02),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).secondaryHeaderColor,
                                    borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                                ),
                                child: Text('Copiar URL', style: TextStyle(
                                    color: context.background,
                                    fontStyle: FontStyle.normal,
                                    fontFamily: 'Gotham',
                                    decoration: TextDecoration.none,
                                    fontSize: screenSizeHeight*0.016,
                                    fontWeight: FontWeight.w700
                                ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          ],
                        ),
                        SizedBox(height:50),
                        GestureDetector(
                          onTap:(){
                            Clipboard.setData(ClipboardData(
                                text: "<iframe src=\"${Video_url_controller.text}\" title=\"description\"></iframe>"));

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text('Copiado en el portapapeles')),
                            );
                          },
                          child: Container(
                            width: 300,
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: screenSizeHeight * 0.015, vertical: screenSizeHeight * 0.02),
                            decoration: BoxDecoration(
                                color: Theme.of(context).secondaryHeaderColor,
                                borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                            ),
                            child: Text('Copie el código del script', style: TextStyle(
                                color: context.background,
                                fontStyle: FontStyle.normal,
                                fontFamily: 'Gotham',
                                decoration: TextDecoration.none,
                                fontSize: screenSizeHeight*0.016,
                                fontWeight: FontWeight.w700
                            ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height:screenSizeHeight * 0.2),
                        Row(
                          children: [
                            Spacer(flex: 4,),
                            Expanded(
                              child: GestureDetector(
                                onTap: ()async {
                                  Navigator.pop(context);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                                  ),
                                  child: Text('Fechar', style:
                                  TextStyle(
                                      color: context.background,
                                      fontStyle: FontStyle.normal,
                                      fontFamily: 'Gotham',
                                      decoration: TextDecoration.none,
                                      fontSize: screenSizeHeight * 0.025,
                                      fontWeight: FontWeight.w700
                                  ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                  ],
                );
              }
              ),
            ),
          );
        });
      },
      animationType: DialogTransitionType.fadeScale,
      curve: Curves.easeIn,
      duration: Duration(milliseconds: 200),
    );
  }

}
