import 'package:cumbia_live_company/publicVideo.dart';
import 'package:cumbia_live_company/streamVideo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

import 'add_new_event/live_stream_url/live/live_page.dart';
import 'auth/confirmationMail.dart';
import 'auth/login.dart';
import 'homeScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Removes the "#" from Flutter Web URLs
  usePathUrlStrategy();

  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: "AIzaSyBP3WztkkefjompqD1wUnJ-gI2VtQif1QY",
      authDomain: "cumbia-live-308fe.firebaseapp.com",
      projectId: "cumbia-live-308fe",
      storageBucket: "cumbia-live-308fe.appspot.com",
      messagingSenderId: "875024983152",
      appId: "1:875024983152:web:ebaa2ffba4ce717b98c0b5",
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(1728, 1117),
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: ThemeData(
            dialogBackgroundColor: Colors.white,
            primaryColor: const Color(0xff17BDCE),
            secondaryHeaderColor: const Color(0xff0D8DA3),
            primaryColorLight: const Color(0xffFF6C57),
            primaryColorDark: const Color(0xff010707),
            dividerColor: const Color(0xff4C5C66),
            focusColor: const Color(0xff001D2B),
            scaffoldBackgroundColor: const Color(0xffE2F4F7),
            appBarTheme: const AppBarTheme(color: Color(0xffE2F4F7)),
          ),
          darkTheme: ThemeData(
            dialogBackgroundColor: Colors.white,
            primaryColor: const Color(0xff17BDCE),
            secondaryHeaderColor: const Color(0xff0D8DA3),
            primaryColorLight: const Color(0xffFF6C57),
            primaryColorDark: const Color(0xff010707),
            dividerColor: const Color(0xff4C5C66),
            focusColor: const Color(0xff001D2B),
            scaffoldBackgroundColor: const Color(0xffE2F4F7),
            appBarTheme: const AppBarTheme(color: Color(0xffE2F4F7)),
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('es', 'MX'),
          ],
          title: 'Bienvenido a Cumbia Live',
          initialRoute: '/home',
          onGenerateRoute: (settings) {
            final String? path = settings.name?.replaceFirst('/', '');
            print("Navigating to: $path");

            switch (path) {
              case 'home':
                return MaterialPageRoute(
                  builder: (_) => FutureBuilder<User?>(
                    future: _getCurrentUser(),
                    builder: (context, AsyncSnapshot<User?> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data?.emailVerified == true) {
                          return HomeScreen();
                        } else {
                          return ConfirmationMail();
                        }
                      } else {
                        return UserAuth();
                      }
                    },
                  ),
                );

              default:
                if (path != null && path.startsWith('livestream/')) {
                  final videoId = path.replaceFirst('livestream/', '');
                  return MaterialPageRoute(
                    // builder: (_) => StreamVideoPlayerScreen(videoId: videoId),
                    builder: (_) => LivePage(
                      isHost: false,
                      localUserID: "localUserID",
                      localUserName: "localUserName",
                      roomID: videoId,
                    ),
                  );
                } else if (path != null && path.startsWith('publicvideo/')) {
                  final videoId = path.replaceFirst('publicvideo/', '');
                  return MaterialPageRoute(
                    builder: (_) => VideoPlayerScreen(videoId: videoId),
                  );
                } else {
                  return MaterialPageRoute(
                    builder: (_) => const Scaffold(
                      body: Center(child: Text('Invalid Route')),
                    ),
                  );
                }
            }
          },
        );
      },
    );
  }

  static Future<User?> _getCurrentUser() async {
    return FirebaseAuth.instance.currentUser;
  }
}
