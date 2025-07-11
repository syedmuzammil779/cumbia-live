import 'package:cumbia_live_company/publicVideo.dart';
import 'package:cumbia_live_company/streamVideo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'auth/confirmationMail.dart';
import 'auth/login.dart';
import 'homeScreen.dart';
//Cuenta ZEGO CLOUD y GMAIL
//Correo: jh9343405@gmail.com
//Contraseña: Phantom96

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: FirebaseOptions(
        apiKey: "AIzaSyBP3WztkkefjompqD1wUnJ-gI2VtQif1QY",
        authDomain: "cumbia-live-308fe.firebaseapp.com",
        projectId: "cumbia-live-308fe",
        storageBucket: "cumbia-live-308fe.appspot.com",
        messagingSenderId: "875024983152",
        appId: "1:875024983152:web:ebaa2ffba4ce717b98c0b5"),
  );
  //usePathUrlStrategy();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(1728, 1117),
        splitScreenMode: true,
      builder: (context, child) {
          return MaterialApp(
          themeMode: ThemeMode.system,
          theme: ThemeData(
            dialogBackgroundColor: Colors.white,
            primaryColor: Color(0xff17BDCE),
            secondaryHeaderColor: Color(0xff0D8DA3),
            primaryColorLight: Color(0xffFF6C57),
            primaryColorDark: Color(0xff010707),
            dividerColor: Color(0xff4C5C66),
            focusColor: Color(0xff001D2B),
            scaffoldBackgroundColor: Color(0xffE2F4F7),
            appBarTheme: AppBarTheme(color: Color(0xffE2F4F7)),
            // backgroundColor: Color(0xffE2F4F7),
          ),
          darkTheme: ThemeData(
            dialogBackgroundColor: Colors.white,
            primaryColor: Color(0xff17BDCE),
            secondaryHeaderColor: Color(0xff0D8DA3),
            primaryColorLight: Color(0xffFF6C57),
            primaryColorDark: Color(0xff010707),
            dividerColor: Color(0xff4C5C66),
            focusColor: Color(0xff001D2B),
            scaffoldBackgroundColor: Color(0xffE2F4F7),
            appBarTheme: AppBarTheme(color: Color(0xffE2F4F7)),
            // backgroundColor: Color(0xffE2F4F7),
          ),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: [
            const Locale('es', 'MX'),
          ],
          title: 'Bienvenido a Cumbia Live',
          initialRoute: '/home',
          // initialRoute: 'liveStream/6c20cf4b-3220-4a91-b6b2-36ce382ed943',
          // initialRoute: 'QbH3GdCHmmkEO4FUnUps',
          onGenerateRoute: (settings) {
            print("** wk settingurl: $settings");
            // showSnackbar(context, settings.name);
            switch (settings.name) {
              case '/home':
                return MaterialPageRoute(
                  builder: (_) => FutureBuilder<User?>(
                    future: _getCurrentUserName(),
                    builder: (context, AsyncSnapshot<User?> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data?.emailVerified == true) {
                          // return UrlScreen();
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
              // Route for video page with dynamic ID
                return MaterialPageRoute(builder: (_) {
                  // Extract the ID from the route name
                  final String? id = settings.name;
                  if (id != null) {
                    if (id.contains('liveStream/')) {
                      return StreamVideoPlayerScreen(videoId:id.replaceAll('liveStream/', ''));
                    } else {
                      return VideoPlayerScreen(videoId:id.replaceAll('/', ''));
                    }
                  } else {
                    // Handle invalid routes
                    return Scaffold(
                      body: Center(
                        child: Text('Invalid Route'),
                      ),
                    );
                  }
                });
            }
          },
        );
      }
    );
  }

  Future<User?> _getCurrentUserName() async {
    User? user = await FirebaseAuth.instance.currentUser;
    return user;
  }
}
