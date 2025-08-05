// Get your AppID, AppSign, and serverSecret from ZEGOCLOUD Console
// [My Projects -> AppID] : https://console.zegocloud.com/project
const appID = 1089943119;
const appSign = "134d9896b0c94e3b147f311cb3df217ec821ec8c79ac389526606789cab040cd";
const serverSecret = "7a85d6e41f72954c5f4d64b7acf62ec4";

/// The serverSecret is only required when you need to use this demo to build a Flutter web platform.
/// The web platform requires token authentication due to security issues. To enable you to quickly experience it,
/// this demo uses client-side code to generate tokens for authentication, which requires the use of serverSecret.
/// In a real project, you need to generate tokens on the server side and distribute them to the client,
/// so as to effectively protect the security of your app.
