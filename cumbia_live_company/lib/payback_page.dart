import 'package:cumbia_live_company/zego_config.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';

class PaybackPage extends StatefulWidget {
  final String roomID;
  final String streamID;
  // final String liveToken;

  const PaybackPage({Key? key, required this.roomID, required this.streamID}) : super(key: key);

  @override
  _PaybackPageState createState() => _PaybackPageState();
}

class _PaybackPageState extends State<PaybackPage> {
  Widget? remoteView;
  int? remoteViewID;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(seconds: 4), () {
      loginRoomAndPlayStream();
    });
  }

  Future<void> loginRoomAndPlayStream() async {
    //static viewer token

    // ZegoUser user = ZegoUser("viewer_123123321", 'LiveViewer');
    // final token = '04AAAAAGfcSdYADN1xZyiuBoTGTZvRUQC6AaumrV1LmRc9lRgc2su4lF+mGyBD/1EEFENfY2Z0P0kz1GFT+GWFNd/0QKQAhN1QaQ6Q2drbCcxmmy+AyNBtaUbPhIRoQs5ZUEcj4wLihPA9qcuHyzRsfQ+6qyShmgCO3Kn+M2qEDy4O2uDvPTD6g0Cxg9UPbDx46QZKMB2WITR13lBJMbC09vGMINHcKvZrlVPtwCjZl5IkLTdlbVPRKhjbyXWm/WC2W6MPbcZP7NA/IIlQZn2BmMKyKAQ==';

    ZegoUser user = ZegoUser("viewer_${DateTime.now().millisecondsSinceEpoch}", 'LiveViewer');
    String? token = await ZegoConfig.instance.fetchToken(user.userID);

    ZegoRoomConfig config = ZegoRoomConfig.defaultConfig();

    print("** wk token: ${token}");
    config.token = token.toString();
    ZegoExpressEngine.instance.loginRoom(widget.roomID.toString(), user, config: config);
    startPlayingStream();
  }

  Future<void> startPlayingStream() async {
    if (widget.streamID.isNotEmpty) {
      await ZegoExpressEngine.instance.createCanvasView((viewID) {
        debugPrint("✅ Stream viewId: $viewID");
        remoteViewID = viewID;
        ZegoCanvas playCanvas = ZegoCanvas(viewID, viewMode: ZegoViewMode.AspectFill);
        debugPrint("✅ Stream playCanvas: $viewID");

        // Start playing the stream
        ZegoExpressEngine.instance.startPlayingStream(widget.streamID, canvas: playCanvas);
        debugPrint("✅ Stream startPlayingStream: ${playCanvas.viewMode}");
        setState(() {

        });
      }).then((canvasViewWidget) {
        debugPrint("✅ Stream canvasViewWidget done");
        setState(() {
          remoteView = canvasViewWidget;
          debugPrint("✅ Stream remoteView canvas done");
          setState(() {
            remoteView = canvasViewWidget;
          });
        });
      });
    } else {
      debugPrint("🚨 Stream ID is empty. Cannot play the stream.");
    }
  }

  Future<void> stopPlayingStream() async {
    if (widget.streamID.isNotEmpty) {
      await ZegoExpressEngine.instance.stopPlayingStream(widget.streamID);
    }
  }

  @override
  void dispose() {
    stopPlayingStream();
    ZegoExpressEngine.instance.logoutRoom(widget.roomID);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return remoteView ?? const Text("Waiting for the live stream to start...");
  }
}
