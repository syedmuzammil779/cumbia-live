import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cumbia_live_company/Models/Structs.dart';
import 'package:cumbia_live_company/payback_page.dart';
import 'package:cumbia_live_company/streamVideo.dart';
import 'package:cumbia_live_company/zego_config.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'dart:html' as html;
import 'Models/Shopify/shopify_product_model.dart';

class CallPage extends StatefulWidget {
  const CallPage({Key? key, this.localUserID, this.localUserName, this.roomID,this.stream});

  final String? localUserID;
  final String? localUserName;
  final String? roomID;
  final StreamsData? stream;

  @override
  State<CallPage> createState() => _CallPageState();
}

class _CallPageState extends State<CallPage> {

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

  String? liveStreamId;
  String? liveRoomId;
  String? liveToken;

  fontDeclaration(screenSizeHeight, screenSizeWidth){
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

  Widget? localView;
  int? localViewID;
  Widget? remoteView;
  int? remoteViewID;

  String version = 'Unknown';

  // final int appID = 1742640984;
  // final String appSign = 'a50d8be62818c3b2b8474be50db0aac534f07ce0d346d9dbd42192d8b909b428';
  // final bool isTestEnv = true;
  // final ZegoScenario scenario = ZegoScenario.Broadcast;
  // final String serverSecret = '2928845bd6a3e237576eb8e9ec639dbd';
  String? StreamingID = '';

  FirebaseFirestore _db = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    StreamingID = widget.stream?.streamID;
    startListenEvent();
    openRoomFunction();
  }

  bool streamActivated = false;

  @override
  void dispose() {
    stopListenEvent();
    logoutRoom();
    stopPlayStream(StreamingID);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var screenSizeHeight = MediaQuery.of(context).size.height;
    var screenSizeWidth = MediaQuery.of(context).size.width;
    fontDeclaration(screenSizeHeight, screenSizeWidth);
    return Scaffold(
      appBar: AppBar(
        title: Text(streamActivated ? '¡Estás en Stream!' : '¡Estás en el modo preview!',
          style: TextStyle(
              color: Theme.of(context).primaryColor,
              fontStyle: FontStyle.normal,
              fontFamily: 'Gotham',
              decoration: TextDecoration.none,
              fontSize: secondaryTextMobile,
              fontWeight: FontWeight.w700
          ),
          textAlign: TextAlign.center,
        ),
        backgroundColor: Colors.white,
        leading: GestureDetector(
          onTap: (){
            stopListenEvent();
            logoutRoom();
            stopPlayStream(StreamingID);
            Navigator.pop(context);
          },
          behavior: HitTestBehavior.opaque,
          child: Icon(Icons.arrow_back_ios, color: Theme.of(context).primaryColor,),
        ),
      ),
      body: Stack(
        children: [
          localView ?? Container(),

          // if (liveStreamId != null)
          //   Stack(
          //     children: [
          //       Container(
          //         height: 400,
          //         width: 400,
          //         color: Colors.red,
          //         // child: PlaybackPage(streamID: liveStreamId, roomID: liveRoomId ?? ''),// PlaybackPage(streamID: liveStreamId),
          //         child: PaybackPage(roomID: liveRoomId.toString(), streamID: liveStreamId.toString()),
          //       ),
          //
          //       ElevatedButton(onPressed: (){
          //         final copyUrl = html.window.location.href + "#/liveStream/" + "${widget.stream?.streamID ?? ''}";
          //         html.window.open(copyUrl, "_blank");
          //       }, child: Container(height: 40, width: 80, color: Colors.blue, child: Text("preview"),))
          //     ],
          //   )
        ],
      ),
      floatingActionButton: Container(
        color: Colors.transparent,
        child: FractionallySizedBox(
          heightFactor: 0.065,
          widthFactor: 0.5,
          child: GestureDetector(
            onTap: (){
              if(streamActivated){
                stopListenEvent();
                logoutRoom();
                stopPlayStream(StreamingID);
                Navigator.pop(context);
              } else {
                setState(() {
                  startPublish();
                  streamActivated = true;
                });
              }
            },
            behavior: HitTestBehavior.opaque,
            child: Container(
              alignment: Alignment.center,
              padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015),
              decoration: BoxDecoration(
                  color: streamActivated ? Theme.of(context).primaryColorLight : Theme.of(context).primaryColor,
                  borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
              ),
              child: Text(
                streamActivated ? 'Detener stream' : 'Iniciar Stream',
                style: TextStyle(
                    color: Colors.white,
                    fontStyle: FontStyle.normal,
                    fontFamily: 'Gotham',
                    decoration: TextDecoration.none,
                    fontSize: secondaryTextWeb,
                    fontWeight: FontWeight.w700
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void startListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate = (roomID, updateType, List<ZegoUser> userList) {
      debugPrint('onRoomUserUpdate: roomID: $roomID, updateType: ${updateType.name}, userList: ${userList.map((e) => e.userID)}');
    };
  }

  void openRoomFunction() {
    loginRoom();
  }

  void loginRoom() async {


    // ZegoUser user = ZegoUser("publisher_123123321", 'LivePublisher');
    // final token = '04AAAAAGfcSa0ADI8mrU4Th21/khHqmgC9H2z8jYiTbWutkoJE5IqRebD3240KD18hi7pyduFwJ1xfZYdkYeLR9qx+SS756GyU5OoJIr5OxhLD0jReTvFzLl26j0ykbM3SvDCuv6ByKmZbjnBsb8AMMmWjZ1Fr+vyA+wXsqT2LCCIOLgaENyNIVkPxJZ2cBfHqprHx2JkB/N8siVFHp9KEkqIvdrw49zqNp9/M39N0HVmYWpbyp/JUlczBDedvBphc7vL/r+tiDxO4a/aHmjFefsJhOof+AQ==';

    ZegoUser user = ZegoUser("publisher_${DateTime.now().millisecondsSinceEpoch}", 'LivePublisher');
    String? token = await ZegoConfig.instance.fetchToken(user.userID);
    if (token == null) {
      print("** wk token is not valid");
      return;
    }

    print("** wk token: ${token}");

    if (kIsWeb) {
      ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();

      print("** wk token: ${token}");
      config.token = token.toString();
      print("** wk roomID: ${widget.roomID}");
      ZegoExpressEngine.instance.loginRoom(widget.roomID.toString(), user, config: config);
      startPreview();
    } else {
      ZegoExpressEngine.instance.loginRoom(widget.roomID.toString(), user);
    }
  }

  Future<void> startPreview() async {
    await ZegoExpressEngine.instance.createCanvasView((viewID) {
      localViewID = viewID;
      ZegoCanvas previewCanvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
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

  void startPublish() {
    print("** wk start publish 0");
    ZegoExpressEngine.instance.startPublishingStream(StreamingID!);
    print("** wk start publish 1");
    liveStreamId = StreamingID;
    print("** wk start publish 2");
    saveStatusStream('Reproduciendo'); // Save the live stream status in Firestore
    print("** wk start publish done");
  }

  Future<void> stopPublish() async {
    await ZegoExpressEngine.instance.stopPublishingStream();
  }

  Future<void> stopPlayStream(String? streamID) async {
    ZegoExpressEngine.instance.stopPlayingStream(streamID!);
  }

  Future<ZegoRoomLogoutResult> logoutRoom() async {
    stopPublish();
    stopPreview();
    stopPlayStream(StreamingID);
    return ZegoExpressEngine.instance.logoutRoom(widget.roomID);
  }

  void stopListenEvent() {
    ZegoExpressEngine.onRoomUserUpdate = null;
  }

  void saveStatusStream(String status) async {
    await _db.collection('streams').doc(widget.stream?.streamID).update({'status': status});
  }
}