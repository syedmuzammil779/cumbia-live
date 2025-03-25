import 'dart:developer';

class ShopifyProductModel {


  int? id;
  String? title;
  String? bodyHtml;
  String? vendor;
  String? productType;
  String? createdAt;
  String? handle;
  String? updatedAt;
  String? publishedAt;
  dynamic templateSuffix;
  String? status;
  String? publishedScope;
  String? tags;
  String? price;
  String? adminGraphqlApiId;
 // List<Variants>? variants;
  String? variantId;
  List<Options>? options;
  String? images;
  ShopImage? image;
  var from;
  var to;

  ShopifyProductModel({
    this.id,
    this.title,
    this.bodyHtml,
    this.vendor,
    this.productType,
    this.createdAt,
    this.handle,
    this.updatedAt,
    this.publishedAt,
    this.templateSuffix,
    this.status,
    this.publishedScope,
    this.tags,
    this.price,
    this.adminGraphqlApiId,
    // this.variants,
    this.options,
    this.images,
    this.image,
    this.from,
    this.to,
  });

  ShopifyProductModel.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    title = json['title'] as String?;
    bodyHtml = json['body_html'] as String?;
    vendor = json['vendor'] as String?;
    productType = json['product_type'] as String?;
    createdAt = json['created_at'] as String?;
    handle = json['handle'] as String?;
    updatedAt = json['updated_at'] as String?;
    publishedAt = json['published_at'] as String?;
    templateSuffix = json['template_suffix'];

    status = json['status'] as String?;
    publishedScope = json['published_scope'] as String?;
    tags = json['tags'] as String?;
    adminGraphqlApiId = json['admin_graphql_api_id'] as String?;

    if(json['variants'].length!=0){
      price = json['variants'][0]['price'];
      variantId = json['variants'][0]['id'].toString();
    }
    // variants = (json['variants'] as List<dynamic>?)
    //     ?.map((v) => Variants.fromJson(v as Map<String, dynamic>))
    //     .toList();
    options = (json['options'] as List<dynamic>?)
        ?.map((v) => Options.fromJson(v as Map<String, dynamic>))
        .toList();
    images =  json['images'][0]['src'];
        // (json['images'] as List<dynamic>?)
        // ?.map((v) => Images.fromJson(v as Map<String, dynamic>))
        // .toList();
    image = json['image'] != null
        ? ShopImage.fromJson(json['image'] as Map<String, dynamic>)
        : null;
  }
  ShopifyProductModel.fromWooCommerceJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    title = json['name'] as String?;
    price = json['price'].toString();
    productType="";
    variantId=json['id'].toString();
    if(json['images'].length!=0){
      images= json['images'][0]['src'].toString();
    }else{
      images= "https://static.vecteezy.com/system/resources/thumbnails/004/141/669/small/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg";
    }


  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['body_html'] = bodyHtml;
    map['vendor'] = vendor;
    map['product_type'] = productType;
    map['created_at'] = createdAt;
    map['handle'] = handle;
    map['updated_at'] = updatedAt;
    map['published_at'] = publishedAt;
    map['template_suffix'] = templateSuffix;
    map['status'] = status;
    map['published_scope'] = publishedScope;
    map['tags'] = tags;
    map['admin_graphql_api_id'] = adminGraphqlApiId;
    // if (variants != null) {
    //   map['variants'] = variants?.map((v) => v.toJson()).toList();
    // }
    if (options != null) {
      map['options'] = options?.map((v) => v.toJson()).toList();
    }
    // if (images != null) {
    //   map['images'] = images?.map((v) => v.toJson()).toList();
    // }
    if (image != null) {
      map['image'] = image?.toJson();
    }
    return map;
  }
}

class ShopImage {
  ShopImage({
    this.id,
    this.productId,
    this.position,
    this.createdAt,
    this.updatedAt,
    this.alt,
    this.width,
    this.height,
    this.src,
    this.variantIds,
    this.adminGraphqlApiId,
    this.from,
    this.to,
  });

  ShopImage.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    productId = json['product_id'] as int?;
    position = json['position'] as int?;
    createdAt = json['created_at'] as String?;
    updatedAt = json['updated_at'] as String?;
    alt = json['alt'];
    width = json['width'] as int?;
    height = json['height'] as int?;
    src = json['src'] as String?;
    variantIds = json['variant_ids'] != null
        ? List<dynamic>.from(json['variant_ids'] as List<dynamic>)
        : <dynamic>[];
    adminGraphqlApiId = json['admin_graphql_api_id'] as String?;
  }

  int? id;
  int? productId;
  int? position;
  String? createdAt;
  String? updatedAt;
  dynamic alt;
  int? width;
  int? height;
  String? src;
  List<dynamic>? variantIds;
  String? adminGraphqlApiId;
  var from;
  var to;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['product_id'] = productId;
    map['position'] = position;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['alt'] = alt;
    map['width'] = width;
    map['height'] = height;
    map['src'] = src;
    if (variantIds != null) {
      map['variant_ids'] = variantIds?.map((v) => v.toJson()).toList();
    }
    map['admin_graphql_api_id'] = adminGraphqlApiId;
    return map;
  }
}

class Images {
  Images({
    this.id,
    this.productId,
    this.position,
    this.createdAt,
    this.updatedAt,
    this.alt,
    this.width,
    this.height,
    this.src,
    this.variantIds,
    this.adminGraphqlApiId,
  });

  Images.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    productId = json['product_id'] as int?;
    position = json['position'] as int?;
    createdAt = json['created_at'] as String?;
    updatedAt = json['updated_at'] as String?;
    alt = json['alt'];
    width = json['width'] as int?;
    height = json['height'] as int?;
    src = json['src'] as String?;
    variantIds = json['variant_ids'] != null
        ? List<dynamic>.from(json['variant_ids'] as List<dynamic>)
        : <dynamic>[];
    adminGraphqlApiId = json['admin_graphql_api_id'] as String?;
  }

  int? id;
  int? productId;
  int? position;
  String? createdAt;
  String? updatedAt;
  dynamic alt;
  int? width;
  int? height;
  String? src;
  List<dynamic>? variantIds;
  String? adminGraphqlApiId;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['product_id'] = productId;
    map['position'] = position;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    map['alt'] = alt;
    map['width'] = width;
    map['height'] = height;
    map['src'] = src;
    if (variantIds != null) {
      map['variant_ids'] = variantIds?.map((v) => v.toJson()).toList();
    }
    map['admin_graphql_api_id'] = adminGraphqlApiId;
    return map;
  }
}

class Options {
  Options({
    this.id,
    this.productId,
    this.name,
    this.position,
    this.values,
  });

  Options.fromJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    productId = json['product_id'] as int?;
    name = json['name'] as String?;
    position = json['position'] as int?;
    values = json['values'] != null
        ? List<String>.from(json['values'] as List<dynamic>)
        : <String>[];
  }

  int? id;
  int? productId;
  String? name;
  int? position;
  List<String>? values;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['product_id'] = productId;
    map['name'] = name;
    map['position'] = position;
    map['values'] = values;
    return map;
  }
}

// class Variants {
//   Variants({
//     this.id,
//     this.productId,
//     this.title,
//     this.price,
//     this.sku,
//     this.position,
//     this.inventoryPolicy,
//     this.compareAtPrice,
//     this.fulfillmentService,
//     this.inventoryManagement,
//     this.option1,
//     this.option2,
//     this.option3,
//     this.createdAt,
//     this.updatedAt,
//     this.taxable,
//     this.barcode,
//     this.grams,
//     this.imageId,
//     this.weight,
//     this.weightUnit,
//     this.inventoryItemId,
//     this.inventoryQuantity,
//     this.oldInventoryQuantity,
//     this.requiresShipping,
//     this.adminGraphqlApiId,
//   });
//
//   Variants.fromJson(Map<String, dynamic> json) {
//     id = json['id'] as int?;
//     productId = json['product_id'] as int?;
//     title = json['title'] as String?;
//     price = json['price'] as String?;
//     sku = json['sku'] as String?;
//     position = json['position'] as int?;
//     inventoryPolicy = json['inventory_policy'] as String?;
//     compareAtPrice = json['compare_at_price'];
//     fulfillmentService = json['fulfillment_service'] as String?;
//     inventoryManagement = json['inventory_management'] as String?;
//     option1 = json['option1'] as String?;
//     option2 = json['option2'];
//     option3 = json['option3'];
//     createdAt = json['created_at'] as String?;
//     updatedAt = json['updated_at'] as String?;
//     taxable = json['taxable'] as bool?;
//     barcode = json['barcode'];
//     grams = json['grams'] as int?;
//     imageId = json['image_id'];
//     weight = json['weight'] as double?;
//     weightUnit = json['weight_unit'] as String?;
//     inventoryItemId = json['inventory_item_id'] as int?;
//     inventoryQuantity = json['inventory_quantity'] as int?;
//     oldInventoryQuantity = json['old_inventory_quantity'] as int?;
//     requiresShipping = json['requires_shipping'] as bool?;
//     adminGraphqlApiId = json['admin_graphql_api_id'] as String?;
//   }
//
//   int? id;
//   int? productId;
//   String? title;
//   String? price;
//   String? sku;
//   int? position;
//   String? inventoryPolicy;
//   dynamic compareAtPrice;
//   String? fulfillmentService;
//   String? inventoryManagement;
//   String? option1;
//   dynamic option2;
//   dynamic option3;
//   String? createdAt;
//   String? updatedAt;
//   bool? taxable;
//   dynamic barcode;
//   int? grams;
//   dynamic imageId;
//   double? weight;
//   String? weightUnit;
//   int? inventoryItemId;
//   int? inventoryQuantity;
//   int? oldInventoryQuantity;
//   bool? requiresShipping;
//   String? adminGraphqlApiId;
//
//   Map<String, dynamic> toJson() {
//     final map = <String, dynamic>{};
//     map['id'] = id;
//     map['product_id'] = productId;
//     map['title'] = title;
//     map['price'] = price;
//     map['sku'] = sku;
//     map['position'] = position;
//     map['inventory_policy'] = inventoryPolicy;
//     map['compare_at_price'] = compareAtPrice;
//     map['fulfillment_service'] = fulfillmentService;
//     map['inventory_management'] = inventoryManagement;
//     map['option1'] = option1;
//     map['option2'] = option2;
//     map['option3'] = option3;
//     map['created_at'] = createdAt;
//     map['updated_at'] = updatedAt;
//     map['taxable'] = taxable;
//     map['barcode'] = barcode;
//     map['grams'] = grams;
//     map['image_id'] = imageId;
//     map['weight'] = weight;
//     map['weight_unit'] = weightUnit;
//     map['inventory_item_id'] = inventoryItemId;
//     map['inventory_quantity'] = inventoryQuantity;
//     map['old_inventory_quantity'] = oldInventoryQuantity;
//     map['requires_shipping'] = requiresShipping;
//     map['admin_graphql_api_id'] = adminGraphqlApiId;
//     return map;
//   }
// }
