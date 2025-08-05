import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:zego_express_engine/zego_express_engine.dart' show ZegoScenario;

class ZegoConfig {
  static final ZegoConfig instance = ZegoConfig._internal();
  ZegoConfig._internal();

  int appID = 1089943119;
  String appSign = "a50d8be62818c3b2b8474be50db0aac534f07ce0d346d9dbd42192d8b909b428"; // Not used for Web
  final String serverSecret = '2928845bd6a3e237576eb8e9ec639dbd';
  ZegoScenario scenario = ZegoScenario.Broadcast;
  bool enablePlatformView = false;

  bool isPreviewMirror = true;
  bool isPublishMirror = false;
  bool enableHardwareEncoder = false;


  Future<String?> fetchToken(String userID) async {
    String url = "https://streaming-token-api-production.up.railway.app/generate-token/$userID";
    // String proxy = "https://cors-anywhere.herokuapp.com/";
    // String apiUrl = "https://streaming-token-api-production.up.railway.app/generate-token/publisher_123123321";
    // String url = "$proxy$apiUrl";

    print("🌐 Sending GET request to: $url");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
        },
      );

      print("📩 Response received: ${response.statusCode}");
      print("📄 Response body: ${response.body}");

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        return data["token"];
      } else {
        print("🚨 API Error: ${response.statusCode}, ${response.body}");
        return null;
      }
    } catch (e) {
      print("🚨 Error Fetching Token: $e");
      return null;
    }
  }


}
