import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cumbia_live_company/auth/confirmationMail.dart';
import 'package:cumbia_live_company/theme/theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_dialog_updated/flutter_animated_dialog.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:uuid/uuid.dart';
// import 'package:flutter_animated_dialog/flutter_animated_dialog.dart';
import '../ErrorCodes/CodeErrors.dart';
import '../Models/Structs.dart';
import '../homeScreen.dart';

class UserAuth extends StatefulWidget {
  UserAuth({Key? key}) : super(key: key);

  @override
  _State createState() => _State();
}

class _State extends State<UserAuth> {

  // final TextEditingController mail = TextEditingController();
  // final TextEditingController password = TextEditingController();
  // final TextEditingController password2 = TextEditingController();

  final TextEditingController mail = TextEditingController(text: "pardo1197@gmail.com");
  // final TextEditingController mail = TextEditingController(text: "Correodelasflores@gmail.com");
  final TextEditingController password = TextEditingController(text: "Futbol21");
  final TextEditingController password2 = TextEditingController(text: "Futbol21");

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

    titleWeb = screenSizeHeight * 0.042;
    primaryTextWeb = screenSizeHeight * 0.0275;
    secondaryTextWeb = screenSizeHeight * 0.0245;
    contentTextWeb = screenSizeHeight * 0.02;
    smallTextWeb = screenSizeHeight * 0.016;
  }

  FirebaseAuth _auth = FirebaseAuth.instance;

  FirebaseFirestore _db = FirebaseFirestore.instance;

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
                  image: AssetImage('assets/img/photo_2.png'),
                  fit: BoxFit.cover
              )
          ),
          child: Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Theme.of(context).focusColor.withOpacity(0.7),
              body: Container(
                alignment: Alignment.topCenter,
                child: ListView(
                  padding: EdgeInsets.only(top: screenSizeHeight * 0.1, bottom: 0),
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  children: [
                    Container(
                      height: screenSizeHeight * 0.15,
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/img/logowhite.png'),
                              fit: BoxFit.contain
                          )
                      ),
                    ),
                    Container(height: screenSizeHeight * 0.05,),
                    Text('Iniciar sesión',
                      style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                          fontSize: primaryTextMobile, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                    Container(height: screenSizeHeight * 0.045,),
                    ListView(
                      padding: EdgeInsets.only(top: 0, left: screenSizeWidth * 0.05, right: screenSizeWidth * 0.03, bottom: screenSizeHeight * 0.05,),
                      shrinkWrap: true,
                      physics: ScrollPhysics(),
                      children: [
                        Text('Correo',
                          style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                              fontSize: contentTextMobile, fontWeight: FontWeight.w400), textAlign: TextAlign.left,),
                        Container(
                          height: screenSizeHeight * 0.01,
                        ),
                        Material(
                          color: Colors.transparent,
                          shadowColor: Theme.of(context).focusColor.withOpacity(0.5),
                          elevation: 20,
                          child: TextField(
                            controller: mail,
                            onChanged: (text) {
                              if (text.isNotEmpty) {

                              }
                            },
                            onSubmitted: (text) async {

                            },
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                fontSize: contentTextMobile, fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.text_fields, color: Theme.of(context).secondaryHeaderColor,),
                              hintStyle:  TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                  fontSize: contentTextMobile, fontWeight: FontWeight.w300),
                              hintText: 'Tu correo...',
                            ),
                          ),
                        ),
                        Container(
                          height: screenSizeHeight * 0.03,
                        ),
                        Text('Contraseña',
                          style: TextStyle(color: Colors.white, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                              fontSize: contentTextMobile, fontWeight: FontWeight.w400), textAlign: TextAlign.left,),
                        Container(
                          height: screenSizeHeight * 0.01,
                        ),
                        Material(
                          color: Colors.transparent,
                          shadowColor: Theme.of(context).focusColor.withOpacity(0.5),
                          elevation: 20,
                          child: TextField(
                            controller: password,
                            onChanged: (text) {
                              if (text.isNotEmpty) {

                              }
                            },
                            onSubmitted: (text) async {

                            },
                            textCapitalization: TextCapitalization.none,
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                            style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                fontSize: contentTextMobile, fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.text_fields, color: Theme.of(context).secondaryHeaderColor,),
                              hintStyle:  TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                  fontSize: contentTextMobile, fontWeight: FontWeight.w300),
                              hintText: 'Tu contraseña',
                            ),
                          ),
                        ),
                        Container(
                          height: screenSizeHeight * 0.03,
                        ),
                        GestureDetector(
                          onTap: (){
                            validateFields(screenSizeWidth, screenSizeHeight);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015),
                            decoration: BoxDecoration(
                                color: Theme.of(context).secondaryHeaderColor,
                                borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                            ),
                            child: Text('¡Iniciar sesión!', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                fontSize: contentTextMobile, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                          ),
                        ),
                        Container(
                          height: screenSizeHeight * 0.145,
                        ),
                        Text('¿No tienes una cuenta y quieres hacer Stream?', style: TextStyle(color: Theme.of(context).primaryColorLight, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                            fontSize: smallTextMobile, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                        Container(
                          height: screenSizeHeight * 0.015,
                        ),
                        GestureDetector(
                          onTap: (){
                            //Navigator.of(context).push(CupertinoPageRoute(builder: (context) => CreateAccount()));
                            createAccount(screenSizeHeight, screenSizeWidth);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015),
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                            ),
                            child: Text('Crear una nueva cuenta', style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                fontSize: contentTextMobile, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ),
        ),
      );
    }
    else {
      return MaterialApp(
        home: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.white
          ),
          child: Scaffold(
              extendBodyBehindAppBar: true,
              backgroundColor: Colors.white,
              body: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 3,
                    child: Container(
                      alignment: Alignment.topCenter,
                      child: ListView(
                        padding: EdgeInsets.only(top: screenSizeHeight * 0.1, bottom: 0),
                        shrinkWrap: true,
                        physics: ScrollPhysics(),
                        children: [
                          Container(
                            height: screenSizeHeight * 0.15,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                    image: AssetImage('assets/img/logo.png'),
                                    fit: BoxFit.contain
                                )
                            ),
                          ),
                          Container(height: screenSizeHeight * 0.05,),
                          Text('Iniciar sesión',
                            style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                fontSize: primaryTextWeb, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                          Container(height: screenSizeHeight * 0.045,),
                          ListView(
                            padding: EdgeInsets.only(top: 0, left: screenSizeWidth * 0.03, right: screenSizeWidth * 0.03, bottom: screenSizeHeight * 0.03,),
                            shrinkWrap: true,
                            physics: ScrollPhysics(),
                            children: [
                              Text('Correo',
                                style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                    fontSize: contentTextWeb, fontWeight: FontWeight.w400), textAlign: TextAlign.left,),
                              Container(
                                height: screenSizeHeight * 0.01,
                              ),
                              Material(
                                color: Colors.transparent,
                                shadowColor: Theme.of(context).focusColor.withOpacity(0.5),
                                elevation: 20,
                                child: TextField(
                                  controller: mail,
                                  onChanged: (text) {
                                    if (text.isNotEmpty) {

                                    }
                                  },
                                  onSubmitted: (text) async {

                                  },
                                  textCapitalization: TextCapitalization.none,
                                  keyboardType: TextInputType.emailAddress,
                                  style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                      fontSize: contentTextWeb, fontWeight: FontWeight.w300),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: Icon(Icons.text_fields, color: Theme.of(context).secondaryHeaderColor,),
                                    hintStyle:  TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                        fontSize: contentTextWeb, fontWeight: FontWeight.w300),
                                    hintText: 'Tu correo...',
                                  ),
                                ),
                              ),
                              Container(
                                height: screenSizeHeight * 0.03,
                              ),
                              Text('Contraseña',
                                style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                    fontSize: contentTextWeb, fontWeight: FontWeight.w400), textAlign: TextAlign.left,),
                              Container(
                                height: screenSizeHeight * 0.01,
                              ),
                              Material(
                                color: Colors.transparent,
                                shadowColor: Theme.of(context).focusColor.withOpacity(0.5),
                                elevation: 20,
                                child: TextField(
                                  controller: password,
                                  onChanged: (text) {
                                    if (text.isNotEmpty) {

                                    }
                                  },
                                  onSubmitted: (text) async {

                                  },
                                  textCapitalization: TextCapitalization.none,
                                  obscureText: true,
                                  keyboardType: TextInputType.visiblePassword,
                                  style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                      fontSize: contentTextWeb, fontWeight: FontWeight.w300),
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                                    enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                                    focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                                    filled: true,
                                    fillColor: Colors.white,
                                    prefixIcon: Icon(Icons.text_fields, color: Theme.of(context).secondaryHeaderColor,),
                                    hintStyle:  TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                        fontSize: contentTextWeb, fontWeight: FontWeight.w300),
                                    hintText: 'Tu contraseña',
                                  ),
                                ),
                              ),
                              Container(
                                height: screenSizeHeight * 0.03,
                              ),
                              GestureDetector(
                                onTap: (){
                                  validateFields(screenSizeWidth, screenSizeHeight);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015),
                                  decoration: BoxDecoration(
                                      color: Theme.of(context).secondaryHeaderColor,
                                      borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                                  ),
                                  child: Text('¡Iniciar sesión!', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                      fontSize: contentTextWeb, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                                ),
                              ),
                              Container(
                                height: screenSizeHeight * 0.15,
                              ),
                              Text('¿No tienes una cuenta y quieres hacer Stream?', style: TextStyle(color: Theme.of(context).primaryColorLight, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                  fontSize: smallTextWeb, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                              Container(
                                height: screenSizeHeight * 0.015,
                              ),
                              GestureDetector(
                                onTap: (){
                                  //Navigator.of(context).push(CupertinoPageRoute(builder: (context) => CreateAccount()));
                                  createAccount(screenSizeHeight, screenSizeWidth);
                                },
                                behavior: HitTestBehavior.opaque,
                                child: Container(
                                  alignment: Alignment.center,
                                  padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015),
                                  decoration: BoxDecoration(
                                      border: Border.all(color: Theme.of(context).focusColor),
                                      borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                                  ),
                                  child: Text('Crear una nueva cuenta', style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                      fontSize: contentTextWeb, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 7,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage('assets/img/photo_2.png'),
                              fit: BoxFit.cover
                          )
                      ),
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Theme.of(context).focusColor.withOpacity(0.7)
                        ),
                        child: Text('Impulsa las ventas de tu\nE-commerce y conecta con tu\naudiencia en tiempo real', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                            fontSize: screenSizeHeight * 0.06, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                      ),
                    ),
                  ),
                ],
              )
          ),
        ),
      );
    }
  }

  createAccount(screenSizeHeight, screenSizeWidth){
    if(screenSizeHeight >= screenSizeWidth){
      showModalBottomSheet(
        //expand: true,
          context: context,
          backgroundColor: context.background,
          builder: (context) => StatefulBuilder(
            builder: (context, modalState){
              return Container(
                  height: screenSizeHeight * 0.75,
                  child: Material(
                    child: ListView(
                      padding: EdgeInsets.only(top: screenSizeHeight * 0.045, left: screenSizeWidth * 0.05, right: screenSizeWidth * 0.05, bottom: screenSizeHeight * 0.045),
                      physics: ScrollPhysics (),
                      shrinkWrap: true,
                      children: [
                        Container(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: (){
                              Navigator.pop(context);
                            },
                            behavior: HitTestBehavior.opaque,
                            child: Icon(Icons.close, color: Theme.of(context).primaryColorLight,),
                          ),
                        ),
                        Text('Crear nueva cuenta', style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                            fontSize: titleMobile, fontWeight: FontWeight.w500), textAlign: TextAlign.center,),
                        Container(
                          height: screenSizeHeight * 0.03,
                        ),
                        Text('Correo',
                          style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                              fontSize: contentTextMobile, fontWeight: FontWeight.w400), textAlign: TextAlign.left,),
                        Container(
                          height: screenSizeHeight * 0.01,
                        ),
                        Material(
                          color: Colors.transparent,
                          shadowColor: Theme.of(context).focusColor.withOpacity(0.5),
                          elevation: 20,
                          child: TextField(
                            controller: mail,
                            onChanged: (text) {
                              if (text.isNotEmpty) {

                              }
                            },
                            onSubmitted: (text) async {

                            },
                            textCapitalization: TextCapitalization.none,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                fontSize: contentTextMobile, fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.text_fields, color: Theme.of(context).secondaryHeaderColor,),
                              hintStyle:  TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                  fontSize: contentTextMobile, fontWeight: FontWeight.w300),
                              hintText: 'Tu correo...',
                            ),
                          ),
                        ),
                        Container(
                          height: screenSizeHeight * 0.045,
                        ),
                        Text('Contraseña',
                          style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                              fontSize: contentTextMobile, fontWeight: FontWeight.w400), textAlign: TextAlign.left,),
                        Container(
                          height: screenSizeHeight * 0.01,
                        ),
                        Material(
                          color: Colors.transparent,
                          shadowColor: Theme.of(context).focusColor.withOpacity(0.5),
                          elevation: 20,
                          child: TextField(
                            controller: password,
                            onChanged: (text) {
                              if (text.isNotEmpty) {

                              }
                            },
                            onSubmitted: (text) async {

                            },
                            textCapitalization: TextCapitalization.none,
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                            style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                fontSize: contentTextMobile, fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.text_fields, color: Theme.of(context).secondaryHeaderColor,),
                              hintStyle:  TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                  fontSize: contentTextMobile, fontWeight: FontWeight.w300),
                              hintText: 'Tu contraseña',
                            ),
                          ),
                        ),
                        Container(
                          height: screenSizeHeight * 0.045,
                        ),
                        Text('Confirmar contraseña',
                          style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                              fontSize: contentTextMobile, fontWeight: FontWeight.w400), textAlign: TextAlign.left,),
                        Container(
                          height: screenSizeHeight * 0.01,
                        ),
                        Material(
                          color: Colors.transparent,
                          shadowColor: Theme.of(context).focusColor.withOpacity(0.5),
                          elevation: 20,
                          child: TextField(
                            controller: password2,
                            onChanged: (text) {
                              if (text.isNotEmpty) {

                              }
                            },
                            onSubmitted: (text) async {

                            },
                            textCapitalization: TextCapitalization.none,
                            obscureText: true,
                            keyboardType: TextInputType.visiblePassword,
                            style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                fontSize: contentTextMobile, fontWeight: FontWeight.w300),
                            decoration: InputDecoration(
                              border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                              filled: true,
                              fillColor: Colors.white,
                              prefixIcon: Icon(Icons.text_fields, color: Theme.of(context).secondaryHeaderColor,),
                              hintStyle:  TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                  fontSize: contentTextMobile, fontWeight: FontWeight.w300),
                              hintText: 'Confirmar tu contraseña',
                            ),
                          ),
                        ),
                        Container(
                          height: screenSizeHeight * 0.06,
                        ),
                        GestureDetector(
                          onTap: (){
                            validateFields2(screenSizeWidth, screenSizeHeight);
                          },
                          behavior: HitTestBehavior.opaque,
                          child: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015),
                            decoration: BoxDecoration(
                                color: Theme.of(context).secondaryHeaderColor,
                                borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                            ),
                            child: Text('¡Entrar!', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                                fontSize: contentTextMobile, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                          ),
                        )
                      ],
                    ),
                  )
              );
            },
          )
      );
    } else {
      showAnimatedDialog(
        context: context,
        barrierDismissible: true,
        alignment: Alignment.center,
        builder: (BuildContext context) {
          return CustomDialogWidget(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.03))
            ),
            title: Text('Crear nueva cuenta', style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                fontSize: secondaryTextWeb, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
            backgroundColor: Colors.white,
            content: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.02)),
              ),
              width: screenSizeWidth * 0.4,
              child: ListView(
                padding: EdgeInsets.only(top: 0, left: screenSizeWidth * 0.03, right: screenSizeWidth * 0.03, bottom: screenSizeHeight * 0.03,),
                shrinkWrap: true,
                physics: ScrollPhysics(),
                children: [
                  Container(
                    height: screenSizeHeight * 0.03,
                  ),
                  Text('Correo',
                    style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                        fontSize: contentTextWeb, fontWeight: FontWeight.w400), textAlign: TextAlign.left,),
                  Container(
                    height: screenSizeHeight * 0.01,
                  ),
                  Material(
                    color: Colors.transparent,
                    shadowColor: Theme.of(context).focusColor.withOpacity(0.5),
                    elevation: 20,
                    child: TextField(
                      controller: mail,
                      onChanged: (text) {
                        if (text.isNotEmpty) {

                        }
                      },
                      onSubmitted: (text) async {

                      },
                      textCapitalization: TextCapitalization.none,
                      keyboardType: TextInputType.emailAddress,
                      style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                          fontSize: contentTextWeb, fontWeight: FontWeight.w300),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.text_fields, color: Theme.of(context).secondaryHeaderColor,),
                        hintStyle:  TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                            fontSize: contentTextWeb, fontWeight: FontWeight.w300),
                        hintText: 'Tu correo...',
                      ),
                    ),
                  ),
                  Container(
                    height: screenSizeHeight * 0.045,
                  ),
                  Text('Contraseña',
                    style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                        fontSize: contentTextWeb, fontWeight: FontWeight.w400), textAlign: TextAlign.left,),
                  Container(
                    height: screenSizeHeight * 0.01,
                  ),
                  Material(
                    color: Colors.transparent,
                    shadowColor: Theme.of(context).focusColor.withOpacity(0.5),
                    elevation: 20,
                    child: TextField(
                      controller: password,
                      onChanged: (text) {
                        if (text.isNotEmpty) {

                        }
                      },
                      onSubmitted: (text) async {

                      },
                      textCapitalization: TextCapitalization.none,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                          fontSize: contentTextWeb, fontWeight: FontWeight.w300),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.text_fields, color: Theme.of(context).secondaryHeaderColor,),
                        hintStyle:  TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                            fontSize: contentTextWeb, fontWeight: FontWeight.w300),
                        hintText: 'Tu contraseña',
                      ),
                    ),
                  ),
                  Container(
                    height: screenSizeHeight * 0.045,
                  ),
                  Text('Confirmar contraseña',
                    style: TextStyle(color: Theme.of(context).focusColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                        fontSize: contentTextWeb, fontWeight: FontWeight.w400), textAlign: TextAlign.left,),
                  Container(
                    height: screenSizeHeight * 0.01,
                  ),
                  Material(
                    color: Colors.transparent,
                    shadowColor: Theme.of(context).focusColor.withOpacity(0.5),
                    elevation: 20,
                    child: TextField(
                      controller: password2,
                      onChanged: (text) {
                        if (text.isNotEmpty) {

                        }
                      },
                      onSubmitted: (text) async {

                      },
                      textCapitalization: TextCapitalization.none,
                      obscureText: true,
                      keyboardType: TextInputType.visiblePassword,
                      style: TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                          fontSize: contentTextWeb, fontWeight: FontWeight.w300),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(16)), borderSide: BorderSide(width: 0.5, color: Theme.of(context).secondaryHeaderColor)),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: Icon(Icons.text_fields, color: Theme.of(context).secondaryHeaderColor,),
                        hintStyle:  TextStyle(color: Theme.of(context).secondaryHeaderColor, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                            fontSize: contentTextWeb, fontWeight: FontWeight.w300),
                        hintText: 'Confirmar tu contraseña',
                      ),
                    ),
                  ),
                  Container(
                    height: screenSizeHeight * 0.06,
                  ),
                  GestureDetector(
                    onTap: (){
                      validateFields2(screenSizeWidth, screenSizeHeight);
                    },
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      alignment: Alignment.center,
                      padding: EdgeInsets.only(top: screenSizeHeight * 0.015, bottom: screenSizeHeight * 0.015),
                      decoration: BoxDecoration(
                          color: Theme.of(context).secondaryHeaderColor,
                          borderRadius: BorderRadius.all(Radius.circular(screenSizeHeight * 0.01))
                      ),
                      child: Text('¡Entrar!', style: TextStyle(color: context.background, fontStyle: FontStyle.normal, fontFamily: 'Gotham', decoration: TextDecoration.none,
                          fontSize: contentTextWeb, fontWeight: FontWeight.w700), textAlign: TextAlign.center,),
                    ),
                  )
                ],
              ),
            ),
          );
        },
        animationType: DialogTransitionType.slideFromBottomFade,
        curve: Curves.easeIn,
        duration: Duration(milliseconds: 800),
      );
    }
  }

  validateFields(width, height) {
    if (mail.text.isEmpty || password.text.isEmpty) {
      dialogMessage('assets/img/error.png', 'Lo sentimos', 'Por favor completa todos los campos para iniciar sesión');
    } else {
      //print('Todos los campos tienen información');
      dialogoCarga('Iniciando sesión');
      signInWithEmailAndPassword(mail.text, password.text, width, height);
    }
  }

  validateFields2(width, height) {
    if (mail.text.isEmpty || password.text.isEmpty) {
      dialogMessage('assets/img/error.png', 'Lo sentimos', 'Por favor completa todos los campos para el registro');
    } else {
      //print('Todos los campos tienen información');
      validatePassword(width, height);
    }
  }

  validatePassword(width, height) {
    //String a utilizar para validación
    //"^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$"
    String regex = r'^(?=.*[A-Za-z])(?=.*\d)[A-Za-z\d]{6,}$';
    RegExp pattern = RegExp(regex);
    if (password.text == password2.text) {
      //print('La contraseña es la misma y pasa a enviar confirmación de correo');
      if (pattern.hasMatch(password.text)) {
        //print('La contraseña cumple con el criterio');
        dialogoCarga('Creando cuenta');
        signUpWithEmailAndPassword(mail.text, password.text, width, height);
      } else {
        dialogMessage('assets/img/error.png', 'Lo sentimos', 'La contraseña debe tener al menos 6 caracteres, 1 letra y 1 número');
      }
    } else {
      dialogMessage('assets/img/error.png', 'Lo sentimos', 'Los campos de contraseña no coinciden');
    }
  }

  Future<void> signUpWithEmailAndPassword(String email, String password, width, height) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;
      //print('Cuenta se está creando');
      //Esta acción envía un link que verifique el correo que se está introduciendo para crearse una cuenta
      user?.sendEmailVerification().then((value) {
        Navigator.of(context, rootNavigator: true).pop('dialog');
        //Aquí se habrá enviado con éxito la verificación de correo
        //Se navegará a la pantalla de inicio de sesión para que vuelva a iniciar sesión una vez se encuentre verificada su cuenta de correo

        updateDataForNewUser(user);

        Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ConfirmationMail()));

      }).catchError((error) {
        //print('Este es el error al enviar email de verificación $error');
        Navigator.of(context, rootNavigator: true).pop('dialog');
        //Si hubo algún error al enviar una verificación de correo se le muestra una alerta al usuario para
        dialogMessage('assets/img/error.png', 'Lo sentimos', 'Hubo un error al enviar el correo de verificación');
      });

    } on FirebaseAuthException catch  (e) {

      Navigator.of(context, rootNavigator: true).pop('dialog');
      dialogMessage('assets/img/error.png', 'Lo sentimos', ErrorCodes.genSignUpErrorMessage(e.code));
    }
  }


  Users userInfo = Users(userUID: '',name:'',lastName: '',email: '',secundaryEmail: '',phoneNumber: '',nit: '',gender: '',
      profilePhoto: '',companiesID: [],role: 'seller',status: '',isCompleteProfile: false);

  CompanyData companyInfo = CompanyData(createdBy: '', companyID: '',ecommerceID: '',streamPlatformID: '',name: '',alias: '',category: '',
      storePlatform: '',webSite: '',phoneNumber: '',email: '',status: 'Aprobado',isAvailable: false,photo: '',members: []);

  void updateDataForNewUser(User user) async {

    var _checkUser = await _db.collection('users').doc(user.uid).get();

    if (_checkUser.exists) {
      //Algo salió mal
    } else {
      DocumentReference ref = _db.collection('users').doc(user.uid);

      userInfo.email = user.email == null ? '' : user.email;
      userInfo.secundaryEmail = user.email == null ? '' : user.email;
      userInfo.userUID = user.uid;

      var companyID = Uuid().v4();

      companyInfo.createdBy = user.uid;
      companyInfo.email = user.email == null ? '' : user.email;
      companyInfo.companyID = companyID;


      return ref.set(userInfo.toCreate(companyID), SetOptions(merge: true)).whenComplete(() {
        DocumentReference refBusiness = _db.collection('companies').doc(companyID);
        refBusiness.set(companyInfo.toCreateData(user.uid)).whenComplete(() {
          print('Creación exitosa de compañía');

          createFirstMember(companyID, userInfo);

          //Navigator.of(context).pushAndRemoveUntil((CupertinoPageRoute(builder: (context) => HomeScreen())), (route) => false);
          //sendWelcomeMail(user.email);

        }).catchError((error) {
          //Hubo error al crear negocio
          print('Error: $error');
        });
      });
    }
  }

  createFirstMember(String companyID, Users? user) async {
    var memberID = Uuid().v4();

    Member newMember = Member(id: memberID??"",email: user?.email??"",role: 'CEO',uid: user?.userUID??"",);

    var ref = _db.collection('companies').doc(companyID).collection('members');

    ref.doc(memberID).set(newMember.createMember()).whenComplete(() {
      print('Creación exitosa de miembro owner');
    }).catchError((error) {
      //Hubo error al crear negocio
      print('Error: $error');
    });
  }

  //Función para iniciar sesión con correo y contraseña
  Future<void> signInWithEmailAndPassword(String email, String password, width, height) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      if (user!.emailVerified) {
        print('Usuario verificado');
        Navigator.of(context, rootNavigator: true).pop('dialog');
        updateUserData(user,width, height);

      } else {
        print('Usuario No verificado');
        Navigator.of(context, rootNavigator: true).pop('dialog');
        Navigator.of(context).push(CupertinoPageRoute(builder: (context) => ConfirmationMail()));
        //sendNewEmailVerification(user, width, height);
        //Si el usuario sigue sin verificar su cuenta. Mostrarle alerta sobre que aún no verifica su cuenta
      }


    } on FirebaseAuthException catch  (e) {
      //En esta sección se manejarán los errores al iniciar sesión y mostrará una alerta de intentar más tarde o contactar
      //con el equipo
      //print('Este es el error $error');
      Navigator.of(context, rootNavigator: true).pop('dialog');
      dialogMessage('assets/img/error.png', 'Lo sentimos', ErrorCodes.genLogInErrorMessage(e.code));
    }
  }

  void updateUserData(User user, width, height) async {

    var _checkUser = await _db.collection('users').doc(user.uid).get();

    if (_checkUser.exists) {
      var data = _checkUser.data();
      var role = data?['role'];

      print('Role usuario: $role');

      if (role == 'admin') {
        signOut();
        dialogMessage('assets/img/error.png', 'Lo sentimos', 'Estás intentando entrar al portal de tiendas con una cuenta administrativa. Por favor entra en el portal administrativo para poder iniciar sesión');
      } else if (role == 'seller'){

        createLastSession(user);
        Navigator.of(context).pushAndRemoveUntil((CupertinoPageRoute(builder: (context) => HomeScreen())), (route) => false);

      } else {
        signOut();
        dialogMessage('assets/img/error.png', 'Lo sentimos', 'Este usuario tiene permisos de $role por lo que no puede iniciar sesión.');
      }

    } else {
      //Do nothing
      signOut();
      dialogMessage('assets/img/error.png', 'Lo sentimos', 'Este usuario ha sido borrado o dado de baja de la plataforma. Por favor contacte al equipo técnico de Cumbia-Live para más información');
    }
  }

  createLastSession(User user) async {
    var userRef = _db.collection('users').doc(user.uid);
    var sessionRef = _db.collection('sessions');

    var id = Uuid().v4();

    Sessions userSession = Sessions(id: id,uid: user.uid);

    userRef.update({
      'lastSession': FieldValue.serverTimestamp()
    }).whenComplete(() async {

      sessionRef.doc(id).set(userSession.toMap()).whenComplete(() async {
        print('Se creó sesión con éxito');

      }).catchError((error) {
        print('Hubo error al crear sesión: ${error}');
      });

    }).catchError((error) {
      print('Hubo error al actualizar sesión: ${error}');
    });

  }

  //Función para cerrar sesión
  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut().then((onValue) async  {
      print('Cerró sesión');
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
