import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cumbia_live_company/common/color_constants.dart';
import 'package:cumbia_live_company/theme/theme.dart';
import 'package:cumbia_live_company/zego_config.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

import 'Models/Shopify/shopify_product_model.dart';
import 'Models/Structs.dart';
import 'Models/WooCommerce/woo_commerce_product_model.dart';

class StreamVideoPlayerScreen extends StatefulWidget {
  final String videoId;

  StreamVideoPlayerScreen({required this.videoId});

  @override
  _StreamVideoPlayerScreenState createState() => _StreamVideoPlayerScreenState();
}

class _StreamVideoPlayerScreenState extends State<StreamVideoPlayerScreen> {


  Widget? remoteView;
  int? remoteViewID;

  String roomID = '';
  String streamID = '';
  String? tokenGenerated;
  List<String> arrayStatus = [];

  @override
  void initState() {
    super.initState();
    createZegoEngine();
  }

  void createZegoEngine() async {
    print("** wk zego engine start");

    ZegoEngineProfile profile = ZegoEngineProfile(ZegoConfig.instance.appID, ZegoConfig.instance.scenario,
        enablePlatformView: true, appSign: kIsWeb ? null : ZegoConfig.instance.appSign);
    ZegoExpressEngine.createEngineWithProfile(profile);
    print("** wk zego engine success done");

    setState(() {
      arrayStatus.add('zego engine created done');
    });

    Future.delayed(Duration(seconds: 4), () {
      _fetchVideoUrl();
    });
  }

  void _fetchVideoUrl() async {
    try {

      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection('streams')
          .doc(widget.videoId) // Document ID
          .get();

      if (documentSnapshot.exists) {
        print("** wk document: $documentSnapshot");

        // String videoUrl = documentSnapshot.get('video_path');
        // companyId = documentSnapshot.get('company_id')[0].toString();
        // storePlatform = documentSnapshot.get('storePlatform');
        // webSite = documentSnapshot.get('webSite');
        // products = documentSnapshot.get('products');
        // await _initializeVideoPlayer(videoUrl);
        roomID = documentSnapshot.get('roomID');
        streamID = documentSnapshot.get('streamID');
        setState(() {
          arrayStatus.add('RoomId: $roomID');
          arrayStatus.add('StreamId: $streamID');
        });
        print('** wk roomID: $roomID');
        print('** wk streamID: $streamID');

        loginRoomAndPlayStream();

      } else {
        print('Document does not exist');
      }
    } catch (error) {
      print('Error fetching video URL: $error');
    }
  }

  Future<void> loginRoomAndPlayStream() async {

    //static viewer token

    // ZegoUser user = ZegoUser("viewer_123123321", 'LiveViewer');
    // final token = '04AAAAAGfcSdYADN1xZyiuBoTGTZvRUQC6AaumrV1LmRc9lRgc2su4lF+mGyBD/1EEFENfY2Z0P0kz1GFT+GWFNd/0QKQAhN1QaQ6Q2drbCcxmmy+AyNBtaUbPhIRoQs5ZUEcj4wLihPA9qcuHyzRsfQ+6qyShmgCO3Kn+M2qEDy4O2uDvPTD6g0Cxg9UPbDx46QZKMB2WITR13lBJMbC09vGMINHcKvZrlVPtwCjZl5IkLTdlbVPRKhjbyXWm/WC2W6MPbcZP7NA/IIlQZn2BmMKyKAQ==';

    ZegoUser user = ZegoUser("viewer_${DateTime.now().millisecondsSinceEpoch}", 'LiveViewer');
    setState(() {
      arrayStatus.add('zego user created: ${user.userID}');
    });
    String? token = await ZegoConfig.instance.fetchToken(user.userID);

    setState(() {
      arrayStatus.add('token success: $token');
    });

    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();
    config.token = token.toString();
    ZegoExpressEngine.instance.loginRoom(roomID.toString(), user, config: config);

    setState(() {
      arrayStatus.add('Room login success');
    });

    Future.delayed(Duration(seconds: 2), () {
      startPlayingStream();
    });
  }

  Future<void> startPlayingStream() async {
    setState(() {
      arrayStatus.add('start play stream 0');
    });
    if (streamID.isNotEmpty) {
      await ZegoExpressEngine.instance.createCanvasView((viewID) {
        setState(() {
          arrayStatus.add('start play stream viewId: $viewID');
        });
        debugPrint("✅ Stream viewId: $viewID");
        remoteViewID = viewID;
        ZegoCanvas playCanvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
        debugPrint("✅ Stream playCanvas: $viewID");

        // Start playing the stream
        Future.delayed(Duration(seconds: 1), () {
          ZegoExpressEngine.instance.startPlayingStream(streamID, canvas: playCanvas);
          debugPrint("✅ Stream startPlayingStream: ${playCanvas.viewMode}");
          setState(() {
            arrayStatus.add('start play stream success: ${playCanvas.viewMode}');
          });
        });

      }).then((canvasViewWidget) {
        setState(() {
          arrayStatus.add('play stream then 10: ${canvasViewWidget}');
        });

        debugPrint("✅ Stream canvasViewWidget done");
        setState(() {
          setState(() {
            arrayStatus.add('remote view before: $remoteView');
          });
          remoteView = canvasViewWidget;
          setState(() {
            arrayStatus.add('remote view after: $remoteView');
          });
          debugPrint("✅ Stream remoteView canvas done");
          // setState(() {
          //   remoteView = canvasViewWidget;
          // });
        });
      });
    } else {
      setState(() {
        arrayStatus.add('🚨 Stream ID is empty. Cannot play the stream.');
      });
      debugPrint("🚨 Stream ID is empty. Cannot play the stream.");
    }
  }

  Future<void> stopPlayingStream() async {
    if (streamID.isNotEmpty) {
      await ZegoExpressEngine.instance.stopPlayingStream(streamID);
    }
  }

  @override
  void dispose() {
    stopPlayingStream();
    ZegoExpressEngine.instance.logoutRoom(roomID);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            remoteView ?? const Text("Waiting for the live stream to start..."),

            ListView.builder(
              itemCount: arrayStatus.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(arrayStatus[index], style: TextStyle(fontSize: 20, color: Colors.blue),),
                );
              },
            )
          ],
        )
    );
  }
}
