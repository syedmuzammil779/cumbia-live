import 'package:dio/dio.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cumbia_live_company/Models/Shopify/shopify_product_model.dart';
import 'package:intl/intl.dart';

import 'WooCommerce/woo_commerce_product_model.dart';


class AdminUser {
  String? id;
  String? role;
  String? email;
  Timestamp? lastSession;
  Timestamp? createdAt;

  AdminUser({this.id, this.role, this.email, this.lastSession, this.createdAt});

  factory AdminUser.fromMap(Map<String, dynamic> data) {
    return AdminUser(
      id: data['uid'] ?? '',
      role: data['role'] ?? '',
      email: data['email'] ?? '',
      lastSession: data['lastSession'],
      createdAt: data['createdAt'],
    );
  }
}
class Users {
  String? userUID;
  String? name;
  String? lastName;
  String? email;
  String? secundaryEmail;
  String? phoneNumber;
  String? nit;
  String? gender;
  String? profilePhoto;
  Timestamp? createdAt;
  String? stringCreatedAt;
  bool? isCompleteProfile;
  List<dynamic>? companiesID;
  String? role;
  String? status;
  UserBirthday? dateOfBirth;
  String? birthdayString;
  Timestamp? birthday;
  Timestamp? lastSession;
  String? lastSessionString;
  PackageSuscriptionData? plan;
  String? sessionID;
  String? customerStripe;
  String? subscriptionID;

  Users({
    this.userUID,
    this.name,
    this.lastName,
    this.email,
    this.secundaryEmail,
    this.phoneNumber,
    this.nit,
    this.gender,
    this.profilePhoto,
    this.createdAt,
    this.stringCreatedAt,
    this.companiesID,
    this.role,
    this.status,
    this.dateOfBirth,
    this.birthdayString,
    this.birthday,
    this.lastSession,
    this.lastSessionString,
    this.isCompleteProfile,
    this.plan,
    this.sessionID,
    this.customerStripe,
    this.subscriptionID,
  });

  factory Users.fromMap(Map<String, dynamic> data) {
    var birthDay = UserBirthday();
    var stringBirthday = '';
    Timestamp? timestampBirthday;

    if (data['dateOfBirth'] == null) {
      birthDay = UserBirthday(year: 1997, month: 9, day: 17);
    } else {
      birthDay = UserBirthday.fromMap(data['dateOfBirth']);
    }

    int ag = 10;
    if (data['birthday'] == null) {
      DateTime date = DateTime(1997, 9, 17, 10, 0);
      timestampBirthday = Timestamp.fromDate(date);

      stringBirthday = '';
      ag = 0;
    } else {
      var actualDate = DateTime.now();
      timestampBirthday = data['birthday'];
      DateTime date = timestampBirthday?.toDate()??DateTime.now();
      var month = DateFormat.MMMM('es_MX').format(date);
      var stringday = date.day < 10 ? '0${date.day}' : '${date.day}';
      var stringmonth = date.month < 10 ? '0${date.month}' : '${date.month}';
      stringBirthday = '$stringday/$stringmonth/${date.year}';
      ag = actualDate.year - date.year;
    }

    var cretionDate = '';
    DateTime dateCreation = DateTime.now();
    Timestamp? actualDate;
    if (data['createdAt'] == null) {
      cretionDate = '';
      actualDate = Timestamp.fromDate(dateCreation);
    } else {
      var timestamp = data['createdAt'];
      actualDate = timestamp;
      DateTime date = timestamp.toDate();
      var stringday = date.day < 10 ? '0${date.day}' : '${date.day}';
      var stringmonth = date.month < 10 ? '0${date.month}' : '${date.month}';
      cretionDate = '$stringday/$stringmonth/${date.year}';
    }

    String lastAct = '';
    if (data['lastSession'] == null) {
      lastAct = '';
    } else {
      var timseStmp = data['lastSession'];
      DateTime date = timseStmp.toDate();
      lastAct = '${date.day}/${date.month}/${date.year}';
    }

    List<dynamic>? list = [];
    if (data['companiesID'] == null) {
      list = [];
    } else {
      list = data['companiesID'];
    }

    PackageSuscriptionData? pl;
    if (data['planData'] == null) {
      pl = PackageSuscriptionData(
        id: '3tveve3v',
        title: 'Plan básico',
        description: 'Este es el plan básico',
        position: 0,
        price: 50.0,
        currency: 'USD',
      );
    } else {
      pl = PackageSuscriptionData.fromMap(data['planData']);
    }

    return Users(
      userUID: data['uid'] ?? '',
      name: data['name'] ?? '',
      lastName: data['lastName'] ?? '',
      email: data['email'] ?? '',
      secundaryEmail: data['secundaryEmail'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      nit: data['nit'] ?? '',
      gender: data['gender'] ?? '',
      profilePhoto: data['photoURL'] ?? '',
      createdAt: actualDate,
      stringCreatedAt: cretionDate,
      companiesID: list,
      role: data['role'] ?? '',
      status: data['status'] ?? '',
      isCompleteProfile: data['isCompleteProfile'] ?? false,
      dateOfBirth: birthDay,
      birthdayString: stringBirthday,
      birthday: timestampBirthday,
      lastSession: data['lastSession'],
      lastSessionString: lastAct,
      plan: pl,
      sessionID: data['sessionID'] ?? '',
      customerStripe: data['customerStripe'] ?? '',
      subscriptionID: data['subscriptionID'] ?? '',
    );
  }

  Map<String, dynamic> toCreate(String companyID) {
    return {
      'uid': userUID,
      'name': name == null ? '' : name,
      'lastName': lastName == null ? '' : lastName,
      'email': email == null ? '' : email,
      'secundaryEmail': secundaryEmail == null ? '' : secundaryEmail,
      'phoneNumber': phoneNumber == null ? '' : phoneNumber,
      'nit': nit == null ? '' : nit,
      'gender': '',
      'photoURL': profilePhoto == null ? '' : profilePhoto,
      'createdAt': createdAt == null ? FieldValue.serverTimestamp() : createdAt,
      'companiesID': [companyID],
      'role': role == null ? 'seller' : role,
      'isCompleteProfile': isCompleteProfile == null ? false : isCompleteProfile,
      'status': 'Aprobado',
      'dateOfBirth': dateOfBirth == null
          ? {'year': 1997, 'month': 9, 'day': 17}
          : dateOfBirth!.toMapBirthDay(),
      'lastSession': lastSession == null ? FieldValue.serverTimestamp() : lastSession,
    };
  }

  Map<String, dynamic> toRegister() {
    return {
      'name': name == null ? '' : name,
      'lastName': lastName == null ? '' : lastName,
      'secundaryEmail': secundaryEmail == null ? '' : secundaryEmail,
      'phoneNumber': phoneNumber == null ? '' : phoneNumber,
      'nit': nit == null ? '' : nit,
      'isCompleteProfile': true,
      'status': 'Aprobado',
    };
  }
}


class CompanyData {
  String? createdBy;
  String? companyID;
  String? ecommerceID;
  String? streamPlatformID;
  String? name;
  String? alias;
  String? category;
  String? storePlatform;
  String? webSite;
  String? phoneNumber;
  String? email;
  String? status;
  bool? isAvailable;
  String? photo;
  List<dynamic>? members;
  bool? acceptTermsAndConditions;
  String? consumerKey;
  String? consumerSecret;
  String? accessToken;
  PackageSuscriptionData? suscription;
  Timestamp? createdAt;

  CompanyData({
    this.createdBy,
    this.companyID,
    this.ecommerceID,
    this.streamPlatformID,
    this.name,
    this.alias,
    this.category,
    this.storePlatform,
    this.webSite,
    this.phoneNumber,
    this.email,
    this.status,
    this.isAvailable,
    this.photo,
    this.members,
    this.acceptTermsAndConditions,
    this.consumerKey,
    this.consumerSecret,
    this.accessToken,
    this.suscription,
    this.createdAt,
  });

  factory CompanyData.fromMap(Map<String, dynamic> data) {
    String creationDate = '';
    Timestamp? created;

    if (data['createdAt'] == null) {
      DateTime date = DateTime.now();
      creationDate = '';
      created = Timestamp.fromDate(date);
    } else {
      created = data['createdAt'];
      var timestampFoundationDay = data['createdAt'];
      DateTime date = timestampFoundationDay.toDate();
      var month = DateFormat.MMMM('es_MX').format(date);
      creationDate = '${date.day} de $month de ${date.year}';
    }

    List<dynamic>? list = [];
    if (data['members'] == null) {
      list = [];
    } else {
      list = data['members'];
    }

    PackageSuscriptionData? suscrip;

    if (data['suscription'] == null) {
      suscrip = null;
    } else {
      suscrip = PackageSuscriptionData.fromMap(data['suscription']);
    }

    return CompanyData(
      createdBy: data['createdBy'] ?? '',
      companyID: data['companyID'] ?? '',
      ecommerceID: data['ecommerceID'] ?? '',
      streamPlatformID: data['streamPlatformID'] ?? '',
      name: data['name'] ?? '',
      alias: data['alias'] ?? '',
      category: data['category'] ?? '',
      storePlatform: data['storePlatform'] ?? '',
      webSite: data['webSite'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      email: data['email'] ?? '',
      status: data['status'] ?? 'Aprobado',
      isAvailable: data['isAvailable'] ?? false,
      photo: data['photo'] ?? '',
      members: list,
      acceptTermsAndConditions: data['acceptTermsAndConditions'] ?? false,
      consumerKey: data['consumerKey'] ?? '',
      consumerSecret: data['consumerSecret'] ?? '',
      accessToken: data['accessToken'] ?? '',
      suscription: suscrip,
      createdAt: created,
    );
  }

  Map<String, dynamic> toCreateData(String ownerID) {
    return {
      'createdBy': createdBy == null ? '' : createdBy,
      'companyID': companyID == null ? '' : companyID,
      'ecommerceID': ecommerceID == null ? '' : ecommerceID,
      'streamPlatformID': streamPlatformID == null ? '' : streamPlatformID,
      'name': name == null ? '' : name,
      'alias': alias == null ? '' : alias,
      'category': category == null ? '' : category,
      'storePlatform': storePlatform == null ? '' : storePlatform,
      'webSite': webSite == null ? '' : webSite,
      'phoneNumber': phoneNumber == null ? '' : phoneNumber,
      'email': email == null ? '' : email,
      'status': status == null ? 'Aprobado' : status,
      'isAvailable': isAvailable == null ? true : isAvailable,
      'photo': photo == null ? '' : photo,
      'members': [ownerID],
      'createdAt': createdAt == null ? FieldValue.serverTimestamp() : createdAt,
    };
  }

  Map<String, dynamic> toRegister() {
    return {
      'name': name == null ? '' : name,
      'alias': alias == null ? '' : alias,
      'category': category == null ? '' : category,
      'storePlatform': storePlatform == null ? '' : storePlatform,
      'webSite': webSite == null ? '' : webSite,
      'phoneNumber': phoneNumber == null ? '' : phoneNumber,
      'acceptTermsAndConditions': acceptTermsAndConditions == null ? true : acceptTermsAndConditions,
      'email': email == null ? '' : email,
    };
  }

  Map<String, dynamic> toCreateContactInfo() {
    return {
      'phoneNumber': phoneNumber == null ? '' : phoneNumber,
      'email': email == null ? '' : email,
      'status': 'Aprobado',
      'isAvailable': true,
    };
  }

  Map<String, dynamic> toUpdateStore() {
    return {
      'storePlatform': storePlatform == null ? '' : storePlatform,
      'consumerKey': consumerKey == null ? '' : consumerKey,
      'consumerSecret': consumerSecret == null ? '' : consumerSecret,
      'webSite': webSite == null ? '' : webSite,
    };
  }

  Map<String, dynamic> toUpdateShopifyStore() {
    return {
      'storePlatform': storePlatform == null ? '' : storePlatform,
      'accessToken': accessToken == null ? '' : accessToken,
      'webSite': webSite == null ? '' : webSite,
    };
  }
}


class Member {
  final String id;
  final String email;
  final String role;
  final String uid;
  final Users? userInfo; // nullable type for Users
  final Timestamp? createdAt;

  Member({
    required this.id,
    required this.email,
    required this.role,
    required this.uid,
    this.userInfo,
    this.createdAt,
  });

  factory Member.fromMap(Map<String, dynamic> data) {
    return Member(
      id: data['id'] as String, // explicit type casting for safety
      email: data['email'] as String,
      role: data['role'] as String ?? 'Miembro', // nullish coalescing for default
      uid: data['uid'] as String,
      userInfo: data['userInfo'] as Users?, // handle nullable Users
      createdAt: data['createdAt'] as Timestamp,
    );
  }

  Map<String, dynamic> createMember() {
    return {
      'id': id,
      'email': email,
      'role': role,
      'uid': uid,
      'createdAt': createdAt,
    };
  }
}


class UserBirthday {
  int? year;
  int? month;
  int? day;

  UserBirthday({this.year, this.month, this.day});

  factory UserBirthday.fromMap(Map<String, dynamic> data) {
    return UserBirthday(
      year: data['year'] ?? 1997,
      month: data['month'] ?? 9,
      day: data['day'] ?? 17,
    );
  }

  Map<String, dynamic> toMapBirthDay() {
    return {
      'year': year == null ? 1997 : year,
      'month': month == null ? 9 : month,
      'day': day == null ? 17 : day,
    };
  }
}


class Sessions {
  String? id;
  String? uid;
  Timestamp? createdAt;
  String? stringCreatedAt;

  Sessions({this.id, this.uid, this.createdAt, this.stringCreatedAt});

  factory Sessions.fromMap(Map<String, dynamic> data) {
    var creationDate = '';
    String horaNotif = '';
    Timestamp? createdDate;

    if (data['createdAt'] == null) {
      creationDate = '';
      createdDate = Timestamp.fromDate(DateTime.now());
    } else {
      var timestamp = data['createdAt'];
      createdDate = data['createdAt'];
      DateTime date = timestamp.toDate();

      String mon = date.month <= 9 ? '0${date.month}' : '${date.month}';
      String d = date.day <= 9 ? '0${date.day}' : '${date.day}';
      String h = date.hour <= 9 ? '0${date.hour}' : '${date.hour}';
      String m = date.minute <= 9 ? '0${date.minute}' : '${date.minute}';

      horaNotif = '$h:$m';
      creationDate = '$mon/$d/${date.year} • $horaNotif';
    }

    return Sessions(
      id: data['id'] ?? '',
      uid: data['uid'] ?? '',
      createdAt: createdDate,
      stringCreatedAt: creationDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id == null ? '' : id,
      'uid': uid == null ? '' : uid,
      'createdAt': createdAt == null ? FieldValue.serverTimestamp() : createdAt,
    };
  }
}


class FileData {
  String? id;
  String? url;
  String? typeFile; // image/pdf/docx
  int? typeHistory;
  String? createdBy; // Usuario que la generó
  String? patientUser; // Paciente/Usuario
  Timestamp? createdAt;

  FileData({this.id, this.url, this.typeFile, this.typeHistory, this.createdBy, this.patientUser, this.createdAt});

  factory FileData.fromMap(Map<String, dynamic> data) {
    return FileData(
      id: data['id'] ?? '',
      url: data['url'] ?? '',
      typeFile: data['typeFile'] ?? '',
      typeHistory: data['typeHistory'] ?? 0,
      createdBy: data['createdBy'] ?? '',
      patientUser: data['patientUser'] ?? '',
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMapFile() {
    return {
      'id': id == null ? '' : id,
      'url': url == null ? '' : url,
      'typeFile': typeFile == null ? '' : typeFile,
      'typeHistory': typeHistory == null ? 0 : typeHistory,
      'createdBy': createdBy == null ? '' : createdBy,
      'patientUser': patientUser == null ? '' : patientUser,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }
}


class PackageSuscriptionData {
  String? id;
  String? title;
  String? description; // image/pdf/docx
  String? priceIDStripe;
  String? currency;
  double? price;
  int? position;
  String? status;
  Timestamp? createdAt;

  PackageSuscriptionData({
    this.id,
    this.title,
    this.description,
    this.priceIDStripe,
    this.currency,
    this.price,
    this.position,
    this.createdAt,
    this.status,
  });

  factory PackageSuscriptionData.fromMap(Map<String, dynamic> data) {
    return PackageSuscriptionData(
      id: data['id'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      priceIDStripe: data['priceIDStripe'] ?? '',
      currency: data['currency'] ?? '',
      price: data['price'] ?? 0.0,
      position: data['position'] ?? 0,
      status: data['status'] ?? '',
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> toMap(String status) {
    return {
      'id': id == null ? '' : id,
      'title': title == null ? '' : title,
      'description': description == null ? '' : description,
      'price': price == null ? 0.0 : price,
      'currency': currency == null ? '' : currency,
      'priceIDStripe': priceIDStripe == null ? '' : priceIDStripe,
      'status': status,
    };
  }
}


class Notifications {
  String? id;
  String? title;
  String? content;
  String? idImage;
  String? url;
  String? type;
  Timestamp? createdAt;
  String? stringCreatedAt;

  Notifications({
    this.id,
    this.type,
    this.idImage,
    this.url,
    this.title,
    this.content,
    this.createdAt,
    this.stringCreatedAt,
  });

  factory Notifications.fromMap(Map<String, dynamic> data) {
    var cretionDate = '';
    String horaNotif = '';
    Timestamp createdDate;

    if (data['createdAt'] == null) {
      cretionDate = '';
      createdDate = Timestamp.fromDate(DateTime.now());
    } else {
      var timestamp = data['createdAt'];
      createdDate = data['createdAt'];
      DateTime date = timestamp.toDate();
      String mon = '';
      String d = '';
      String h = '';
      String m = '';

      if (date.month <= 9) {
        mon = '0${date.month}';
      } else {
        mon = '${date.month}';
      }

      if (date.day <= 9) {
        d = '0${date.day}';
      } else {
        d = '${date.day}';
      }

      if (date.hour <= 9) {
        h = '0${date.hour}';
      } else {
        h = '${date.hour}';
      }

      if (date.minute <= 9) {
        m = '0${date.minute}';
      } else {
        m = '${date.minute}';
      }

      horaNotif = '$h:$m';

      cretionDate = '$mon/$d/${date.year} • $horaNotif';
    }

    return Notifications(
      id: data['id'] ?? '',
      type: data['type'] ?? '',
      title: data['title'] ?? '',
      idImage: data['idImage'] ?? '',
      url: data['url'] ?? '',
      content: data['content'] ?? '',
      createdAt: createdDate,
      stringCreatedAt: cretionDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id == null ? '' : id,
      'type': type == null ? '' : type,
      'title': title == null ? '' : title,
      'idImage': idImage == null ? '' : idImage,
      'url': url == null ? '' : url,
      'content': content == null ? '' : content,
      'createdAt': createdAt == null ? FieldValue.serverTimestamp() : createdAt,
    };
  }
}


class StreamsData {
  String? streamID;
  String? roomID;
  String? createdBy;
  String? businessID;
  String? status;
  String? ecommercePlatform; // WooCommerce, Shopify
  List<WooCommerceProductModel> wooProducts;
  List<ShopifyProductModel> shopProducts;
  Timestamp? createdAt;

  StreamsData({
    this.streamID,
    this.roomID,
    this.createdBy,
    this.businessID,
    this.status,
    this.ecommercePlatform,
    List<WooCommerceProductModel>? wooProducts,
    List<ShopifyProductModel>? shopProducts,
    this.createdAt,
  })  : wooProducts = wooProducts ?? [],
        shopProducts = shopProducts ?? [];

  factory StreamsData.fromMap(Map<String, dynamic> data) {
    Map<String, dynamic>? productsData = data['products'];
    List<WooCommerceProductModel> woop = [];
    List<ShopifyProductModel> shopP = [];
    String? ecomm = data['ecommercePlatform'];

    if (productsData != null) {
      productsData.forEach((key, value) {
        var id = key;
        if (ecomm == 'WooCommerce') {
          var prodInfo = WooCommerceProductModel.fromMap(value);
          woop.add(prodInfo);
        } else if (ecomm == 'Shopify') {
          var prodInfo = ShopifyProductModel.fromJson(value);
          shopP.add(prodInfo);
        }
      });
    }

    return StreamsData(
      streamID: data['streamID'],
      roomID: data['roomID'],
      createdBy: data['createdBy'],
      businessID: data['businessID'],
      status: data['status'],
      ecommercePlatform: data['ecommercePlatform'],
      wooProducts: woop,
      shopProducts: shopP,
      createdAt: data['createdAt'],
    );
  }

  Map<String, dynamic> createStream(List products) {
    Map<String, dynamic> map = {};

    if (products.isNotEmpty) {
      products.forEach((prod) {
        map.putIfAbsent(prod.id.toString(), () => prod.toJson());
      });
    }

    return {
      'streamID': streamID ?? '',
      'roomID': roomID ?? '',
      'createdBy': createdBy ?? '',
      'businessID': businessID ?? '',
      'status': status ?? 'En espera',
      'ecommercePlatform': ecommercePlatform ?? '',
      'products': map,
      'createdAt': createdAt ?? FieldValue.serverTimestamp(),
    };
  }
}



class GeneralProductData {

  String? ecommercePlatform; //WooCommerce, Shopify
  List<ShopifyProductModel>? wooProducts;
  List<ShopifyProductModel>? shopProducts;


  GeneralProductData({this.ecommercePlatform,this.wooProducts,this.shopProducts});

  factory GeneralProductData.fromMap(Map<String, dynamic> data) {

    return new GeneralProductData(
      ecommercePlatform: data['ecommercePlatform'] ?? '',
      wooProducts: data['wooProducts'] ?? [],
      shopProducts: data['shopProducts'] ?? [],
    );
  }

  Map<String, dynamic> createStream() {
    return {
      'ecommercePlatform': ecommercePlatform == null ? '' : ecommercePlatform,
    };
  }

}




