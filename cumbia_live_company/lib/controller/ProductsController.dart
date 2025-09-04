import 'dart:convert';
import 'dart:developer';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cumbia_live_company/Models/Shopify/shopify_product_model.dart';
import 'package:cumbia_live_company/Models/Structs.dart';
import 'package:cumbia_live_company/controller/CreateLiveStreamUrlController.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class ProductsController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  var isLoading = false.obs;
  var allProducts = GeneralProductData(
    ecommercePlatform: '',
    wooProducts: [],
    shopProducts: [],
  ).obs;

  var companies = <CompanyData>[].obs;
  var userInfo = Users(
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
  ).obs;

  var companyInfo = CompanyData(
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
  ).obs;

  @override
  void onInit() {
    super.onInit();
    getData();
  }

  Future<void> getData() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _db.collection('users').doc(user.uid).snapshots().listen((userEvent) async {
      if (!userEvent.exists) return;

      userInfo.value = Users.fromMap(userEvent.data()!);
      companies.clear();

      if (userInfo.value.companiesID?.isNotEmpty ?? false) {
        for (var companyID in userInfo.value.companiesID!) {
          _db.collection('companies').doc(companyID).snapshots().listen((event) {
            if (!event.exists) return;

            final cInfo = CompanyData.fromMap(event.data()!);
            _updateCompaniesList(cInfo);

            companyInfo.value = companies.first;

            if ((companyInfo.value.consumerKey?.isNotEmpty ?? false) &&
                (companyInfo.value.consumerSecret?.isNotEmpty ?? false)) {
              validateStore();
            }
          });
        }
      }
    });
  }

  void _updateCompaniesList(CompanyData company) {
    final index =
    companies.indexWhere((element) => element.companyID == company.companyID);
    if (index >= 0) {
      companies[index] = company;
    } else {
      companies.add(company);
    }
  }

  Future<void> validateStore() async {
    if (companyInfo.value.storePlatform == 'WooCommerce') {
      await getWooCommerceProducts();
    } else if (companyInfo.value.storePlatform == 'Shopify') {
      await getShopifyProducts();
    }
  }

  Future<void> getWooCommerceProducts() async {
    isLoading.value = true;
    final url =
        "${companyInfo.value.webSite}/wp-json/wc/v3/products?consumer_key=${companyInfo.value.consumerKey}&consumer_secret=${companyInfo.value.consumerSecret}";

    try {
      final Dio dio = Dio()
        ..options.connectTimeout = Duration(milliseconds: 30000)
        ..options.receiveTimeout = Duration(milliseconds: 30000)
        ..options.headers = {'Accept': 'application/json'};

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        List data = response.data;
        for (var productData in data) {
          final product = ShopifyProductModel.fromWooCommerceJson(productData);

          allProducts.update((val) {
            val?.ecommercePlatform = 'WooCommerce';
            final index =
                val?.shopProducts?.indexWhere((e) => e.id == product.id) ?? -1;
            if (index >= 0) {
              val?.shopProducts?[index] = product;
            } else {
              val?.shopProducts?.add(product);
            }
          });
        }
      }
    } catch (e) {
      log("WooCommerce fetch error: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> getShopifyProducts() async {

    String url = "${companyInfo.value.webSite}/admin/api/2023-01/products.json";
    String token = companyInfo.value.accessToken ?? "";

    try {
      final Uri apiUrl = Uri.parse(
        "https://waseem-proxy-api-production.up.railway.app/fetch-store-data",
      );

      print("talha----Calling proxy: $apiUrl");

      final response = await http.post(
        apiUrl,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "url": url,
          "accessToken": token,
        }),
      );

      print("talha----Response: ${response.body}");

      if (response.statusCode == 200 && response.body != 'error') {
        var data = jsonDecode(response.body);
        List shopProducts = data['products'] ?? [];

        if (shopProducts.isNotEmpty) {
          allProducts.value.shopProducts ??= [];

          for (var productData in shopProducts) {
            var product = ShopifyProductModel.fromJson(productData);

            final index = allProducts.value.shopProducts?.indexWhere((element) => element.id == product.id) ?? -1;
            if (index >= 0) {
              allProducts.value.shopProducts![index] = product;
            } else {
              allProducts.value.shopProducts?.add(product);
            }
          }

          allProducts.value.ecommercePlatform = 'Shopify';
          update();
        } else {
          print("talha----No products found in Shopify response");
        }
      } else {
        print("talha----Error: ${response.statusCode}");
      }
    } catch (e) {
      print("talha----Error fetching Shopify products: $e");
    } finally {
    }
  }
}
