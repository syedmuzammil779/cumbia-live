/*
import 'package:flutter/material.dart';
import 'package:zego_uikit_prebuilt_live_streaming/zego_uikit_prebuilt_live_streaming.dart';

class LiveStreamPage extends StatelessWidget {
  final String userID;
  final String liveID;
  final bool isHost;

  const LiveStreamPage({
    super.key,
    required this.userID,
    required this.liveID,
    required this.isHost,
  });

  @override
  Widget build(BuildContext context) {
    return ZegoUIKitPrebuiltLiveStreaming(
      appID: 1089943119, // Replace with your actual App ID
      appSign: '134d9896b0c94e3b147f311cb3df217ec821ec8c79ac389526606789cab040cd', // Replace with your App Sign
      userID: userID,
      userName: 'User_$userID',
      liveID: liveID,
      config: isHost
          ? ZegoUIKitPrebuiltLiveStreamingConfig.host()
          : ZegoUIKitPrebuiltLiveStreamingConfig.audience(),
    );
  }
}
*/
