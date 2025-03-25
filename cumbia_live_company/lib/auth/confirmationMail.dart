import 'package:cumbia_live_company/auth/login.dart';
import 'package:cumbia_live_company/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

class ConfirmationMail extends StatefulWidget {
  ConfirmationMail({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<ConfirmationMail> {

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

  bool obscureText = true;



  void initState() {
    super.initState();

  }


  @override
  Widget build(BuildContext context) {
    FlutterNativeSplash.remove();
    var screenSizeHeight = MediaQuery.of(context).size.height;
    var screenSizeWidth = MediaQuery.of(context).size.width;
    fontDeclaration(screenSizeHeight, screenSizeWidth);
    if(screenSizeHeight >= screenSizeWidth){
      return MaterialApp(
        home: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/img/photo_1.png'),
                  fit: BoxFit.cover
              )
          ),
          child: Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Theme.of(context).focusColor.withOpacity(0.7),
              body: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/img/photo_1.png'),
                        fit: BoxFit.cover
                    )
                ),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        alignment: Alignment.center,
                        child: ListView(
                          padding: EdgeInsets.only(top: screenSizeHeight * 0.03, left: screenSizeWidth * 0.03, right: screenSizeWidth * 0.03, bottom: screenSizeHeight * 0.03,),
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          children: [
                            Icon(Icons.how_to_reg_outlined, size: screenSizeWidth * 0.3, color: Colors.white,),
                            Container(height: screenSizeHeight * 0.01,),
                            Text('Confirma tu mail para continuar,\nenviamos un correo de verificación',
                              style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                  fontSize: titleMobile, fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
                            Container(
                              height: screenSizeHeight * 0.06,
                            ),
                            Container(
                              padding: EdgeInsets.only(left: screenSizeWidth * 0.1, right: screenSizeWidth * 0.1),
                              child: GestureDetector(
                                onTap: (){
                                  signOut();
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015, left: screenSizeWidth * 0.015, right: screenSizeWidth * 0.015),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                                  ),
                                  child: Text('¡Ya confirmé mi correo!', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                      fontSize: contentTextMobile, fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
                                ),
                              ),
                            ),
                            Container(height: screenSizeHeight * 0.045,),
                            Container(
                              padding: EdgeInsets.only(left: screenSizeWidth * 0.1, right: screenSizeWidth * 0.1),
                              child: GestureDetector(
                                onTap: () async {
                                  sendNewEmailVerification();
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015, left: screenSizeWidth * 0.015, right: screenSizeWidth * 0.015),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                                  ),
                                  child: Text('Enviar correo de nuevo', style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                      fontSize: contentTextMobile, fontWeight: FontWeight.w400), textAlign: TextAlign.center,),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )
          ),
        ),
      );
    }
    else {
      return MaterialApp(
        home: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage('assets/img/photo_1.png'),
                  fit: BoxFit.cover
              )
          ),
          child: Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Theme.of(context).focusColor.withOpacity(0.7),
              body: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/img/photo_1.png'),
                        fit: BoxFit.cover
                    )
                ),
                child: Stack(
                  alignment: Alignment.topRight,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        alignment: Alignment.center,
                        child: ListView(
                          padding: EdgeInsets.only(top: screenSizeHeight * 0.03, left: screenSizeWidth * 0.04, right: screenSizeWidth * 0.04, bottom: screenSizeHeight * 0.03,),
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          children: [
                            Icon(Icons.how_to_reg_outlined, size: screenSizeHeight * 0.25, color: Colors.white,),
                            Container(height: screenSizeHeight * 0.03,),
                            Text('Confirma tu mail para continuar,\nenviamos un correo de verificación',
                              style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                  fontSize: screenSizeHeight * 0.06, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),

                            Container(
                              height: screenSizeHeight * 0.05,
                            ),
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () async {
                                    sendNewEmailVerification();
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015, left: screenSizeWidth * 0.015, right: screenSizeWidth * 0.015),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                                    ),
                                    child: Text('Enviar correo de nuevo', style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                        fontSize: contentTextWeb, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                                  ),
                                ),
                                Container(width: screenSizeWidth * 0.03,),
                                GestureDetector(
                                  onTap: (){
                                    signOut();
                                  },
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    alignment: Alignment.center,
                                    padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015, left: screenSizeWidth * 0.015, right: screenSizeWidth * 0.015),
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).secondaryHeaderColor,
                                        borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                                    ),
                                    child: Text('¡Ya confirmé mi correo!', style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                        fontSize: contentTextWeb, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
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
              )
          ),
        ),
      );
    }
  }

  sendNewEmailVerification() async {
    User? user = await FirebaseAuth.instance.currentUser;
    if (user != null) {
      dialogoCarga('Reenviando email de verificación...');
      user.sendEmailVerification().then((value) {

        Navigator.of(context, rootNavigator: true).pop('dialog');

      }).catchError((error) {
        //print('Este es el error al enviar email de verificación $error');
        Navigator.of(context, rootNavigator: true).pop('dialog');
        //Si hubo algún error al enviar una verificación de correo se le muestra una alerta al usuario para
        dialogMessage('assets/img/error.png', 'Lo sentimos', 'Hubo un error al enviar el correo de verificación');
      });
    } else {
      //do nothing
    }
  }

  //Función para cerrar sesión y enviar a iniciar sesión
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut().then((onValue) async  {
      print('Cerró sesión');
      Navigator.of(context).pushAndRemoveUntil((CupertinoPageRoute(builder: (context) => UserAuth())), (route) => false);

    });
  }

  void dialogoCarga(String title){
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return WillPopScope(
            onWillPop: (){Future<bool> avoidError = false as Future<bool>;
            return avoidError;},
            child: CupertinoAlertDialog(
                title: Text(title),
                content: Column(
                  children: <Widget>[
                    Container(height: 3,),
                    Text('Esto puede tardar unos segundos'),
                    Container(height: 10,),
                    CupertinoActivityIndicator()
                  ],
                )
            )
        );
      },
    );
  }

  dialogMessage(type, tittle, description){
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    if(width < height){
      //Mobile
      showDialog(
        context: context,
        builder: (_) {
          return AlertDialog(
            insetPadding: EdgeInsets.all(width * 0.05),
            backgroundColor: context.background,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(height * 0.03))
            ),
            title: Container(),
            content: Container(
                width: width * 0.45,
                child: ListView(
                  padding: EdgeInsets.only(top: 0),
                  physics: ScrollPhysics (),
                  shrinkWrap: true,
                  children: [
                    Container(
                        height: height * 0.12,
                        width: height * 0.12,
                        child: Image.asset(type,fit: BoxFit.contain)
                    ),
                    Container(
                      height: height * 0.018,
                    ),
                    Text(tittle, style: TextStyle(color: Theme.of(context).primaryColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                        fontSize: secondaryTextWeb, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                    Container(
                      height: height * 0.01,
                    ),
                    Text(description, style: TextStyle(color: Theme.of(context).primaryColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                        fontSize: secondaryTextWeb, fontWeight: FontWeight.w700),textAlign: TextAlign.center,),
                    Container(
                      height: height * 0.03,
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context, rootNavigator: true).pop('dialog');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: height * 0.015, bottom: height * 0.015),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight,
                            borderRadius: BorderRadius.all(Radius.circular(height * 0.03))
                        ),
                        child: Text('Aceptar', style: TextStyle(color: Theme.of(context).primaryColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                            fontSize: secondaryTextWeb, fontWeight: FontWeight.w700),),
                      ),
                    ),
                    Container(
                      height: height * 0.015,
                    ),
                  ],
                )
            ),
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
                borderRadius: BorderRadius.all(Radius.circular(height * 0.035))
            ),
            title: Container(),
            content: Container(
                width: height * 0.38,
                child: ListView(
                  padding: EdgeInsets.only(top: 0),
                  physics: ScrollPhysics (),
                  shrinkWrap: true,
                  children: [
                    Container(
                        height: height * 0.12,
                        width: height * 0.12,
                        child: Image.asset(type,fit: BoxFit.contain)
                    ),
                    Container(
                      height: height * 0.018,
                    ),
                    Text(tittle, style: TextStyle(color: Theme.of(context).primaryColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                        fontSize: secondaryTextWeb, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                    Container(
                      height: height * 0.01,
                    ),
                    Text(description, style: TextStyle(color: Theme.of(context).primaryColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                        fontSize: secondaryTextWeb, fontWeight: FontWeight.w700),textAlign: TextAlign.center,),
                    Container(
                      height: height * 0.03,
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context, rootNavigator: true).pop('dialog');
                      },
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        alignment: Alignment.center,
                        padding: EdgeInsets.only(top: height * 0.015, bottom: height * 0.015),
                        decoration: BoxDecoration(
                            color: Theme.of(context).primaryColorLight,
                            borderRadius: BorderRadius.all(Radius.circular(height * 0.03))
                        ),
                        child: Text('Aceptar', style: TextStyle(color: Theme.of(context).primaryColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                            fontSize: secondaryTextWeb, fontWeight: FontWeight.w700),),
                      ),
                    ),
                    Container(
                      height: height * 0.015,
                    ),
                  ],
                )
            ),
          );
        },
      );
    }
  }
}
