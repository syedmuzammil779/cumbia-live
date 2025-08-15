import 'package:cumbia_live_company/Models/Stream/zegocloud_token.dart';
import 'package:cumbia_live_company/homeScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'key_center.dart';

class LivePage extends StatefulWidget {
  const LivePage({
    Key? key,
    required this.isHost,
    required this.localUserID,
    required this.localUserName,
    required this.roomID,
  }) : super(key: key);

  final bool isHost;
  final String localUserID;
  final String localUserName;
  final String roomID;

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  Widget? localView;
  int? localViewID;
  Widget? remoteView;
  int? remoteViewID;

  final TextEditingController _chatController = TextEditingController();

  @override
  void initState() {
    startListenEvent();
    loginRoom();
    super.initState();
  }

  @override
  void dispose() {
    stopListenEvent();
    logoutRoom();
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Preview Live Streaming")),
      body: Row(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                (widget.isHost ? localView : remoteView) ?? SizedBox.shrink(),
                Positioned(
                  bottom: MediaQuery.of(context).size.height / 20,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: SizedBox(
                      width: 300,
                      height: 100,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                          CupertinoPageRoute(builder: (context) => HomeScreen()),
                              (route) => false,
                        ),
                        child: Text(widget.isHost ? 'End Live' : 'Leave Live'),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Container(
            width: 300,
            color: Colors.grey.shade200,
            child: Column(
              children: [
                // Chat messages
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('rooms')
                        .doc(widget.roomID)
                        .collection('messages')
                        .orderBy('timestamp', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      return ListView.builder(
                        reverse: true,
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data = docs[index].data() as Map<String, dynamic>;
                          return ListTile(
                            title: Text(
                              data['userName'] ?? '',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(data['text'] ?? ''),
                          );
                        },
                      );
                    },
                  ),
                ),

                Divider(height: 1),

                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _chatController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          ),
                          onSubmitted: (_) => sendMessage(),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: sendMessage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Firestore send message
  Future<void> sendMessage() async {
    final text = _chatController.text.trim();
    if (text.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('rooms')
        .doc(widget.roomID)
        .collection('messages')
        .add({
      'userID': widget.localUserID,
      'userName': widget.localUserName,
      'text': text,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _chatController.clear();
  }

  Future<ZegoRoomLoginResult> loginRoom() async {
    final user = ZegoUser(widget.localUserID, widget.localUserName);
    final roomID = widget.roomID;
    ZegoRoomConfig roomConfig = ZegoRoomConfig.defaultConfig()..isUserStatusNotify = true;

    if (kIsWeb) {
      roomConfig.token = ZegoTokenUtils.generateToken(appID, serverSecret, widget.localUserID);
    }

    return ZegoExpressEngine.instance
        .loginRoom(roomID, user, config: roomConfig)
        .then((loginRoomResult) {
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
