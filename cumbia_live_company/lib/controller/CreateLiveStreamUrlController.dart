import 'dart:typed_data';

import 'package:cumbia_live_company/Models/Shopify/shopify_product_model.dart';
import 'package:cumbia_live_company/Models/Structs.dart';
import 'package:cumbia_live_company/add_new_event/live_stream_url/model/ShopifyProduct.dart';
import 'package:cumbia_live_company/add_new_event/model/Event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/material.dart';

class CreateLiveStreamUrlController extends GetxController {
  final FirebaseFirestore db = FirebaseFirestore.instance;

  List<ShopifyProductModel> productsSelected = [];
  List<ShopifyProduct> shopifyProductSelected = [];
  String? streamLink;
  String? bannerUrl;
  DateTime? eventDate;

  Users userInfo = Users(
    userUID: '',
    name: '',
    lastName: '',
    email: '',
    secundaryEmail: '',
    phoneNumber: '',
    nit: '',
    gender: '',
    profilePhoto: '',
    companiesID: [],
    role: '',
    status: '',
    isCompleteProfile: false,
  );

  CompanyData companyInfo = CompanyData(
    createdBy: '',
    companyID: '',
    ecommerceID: '',
    streamPlatformID: '',
    name: '',
    alias: '',
    category: '',
    storePlatform: '',
    webSite: '',
    phoneNumber: '',
    email: '',
    status: '',
    isAvailable: false,
    photo: '',
    members: [],
    consumerKey: '',
    consumerSecret: '',
    accessToken: '',
  );

  /// Setters
  void setUserInfo(Users user) {
    userInfo = user;
    update();
  }

  void setCompanyInfo(CompanyData company) {
    companyInfo = company;
    update();
  }

  void setStreamLink(String link) {
    streamLink = link;
    update();
  }

  void setBannerUrl(String url) {
    bannerUrl = url;
    update();
  }

  void setEventDate(DateTime date) {
    eventDate = date;
    update();
  }

  void selectedProductSelection(List<ShopifyProductModel> selectedProducts) {
    productsSelected = selectedProducts;
    update();
  }

  /// Uploads image and returns Firebase Storage URL
  Future<String> uploadImageToFirebase(Uint8List imageBytes) async {
    final fileName = 'banners/${DateTime.now().millisecondsSinceEpoch}.jpg';
    final ref = FirebaseStorage.instance.ref().child(fileName);
    final uploadTask = await ref.putData(
      imageBytes,
      SettableMetadata(contentType: 'image/jpeg'),
    );
    return await ref.getDownloadURL();
  }

  /// Creates an event in Firestore
  Future<void> createEvent({BuildContext? context}) async {
    try {
      if (eventDate == null || streamLink?.isEmpty != false || bannerUrl?.isEmpty != false) {
        if (context != null) {
          _showSnackBar(context, 'Todos los campos son obligatorios');
        }
        throw Exception('Missing required fields');
      }

      final event = Event(
        id: Uuid().v4(),
        title: _getFormattedEventTitle(),
        eventDateTime: eventDate!,
        streamLink: streamLink!,
        bannerUrl: bannerUrl!,
        selectedProductIds: productsSelected.map((e) => e.id.toString()).toList(),
      );

      await db.collection('events').doc(event.id).set(event.toMap());

      if (context != null) {
        _showSnackBar(context, 'Evento creado exitosamente');
      }

      clearInputs(); // Reset values for next event

    } catch (e) {
      debugPrint('Error creating event: $e');
      if (context != null) {
        _showSnackBar(context, 'Fallo al crear el evento');
      }
      rethrow;
    }
  }

  /// Clear all inputs after submission
  void clearInputs() {
    eventDate = null;
    streamLink = null;
    bannerUrl = null;
    productsSelected = [];
    update();
  }

  /// Event title like "julio 28 - lanzamiento"
  String _getFormattedEventTitle() {
    if (eventDate == null) return 'Evento sin fecha';
    final formatted = DateFormat("MMMM d", "es_ES").format(eventDate!);
    return '$formatted - lanzamiento';
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }
}
