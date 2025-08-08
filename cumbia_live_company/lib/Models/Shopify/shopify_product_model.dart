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

    // Variants
    if (json['variants'] != null && json['variants'] is List && json['variants'].isNotEmpty) {
      final firstVariant = json['variants'][0] as Map<String, dynamic>;
      price = firstVariant['price']?.toString();
      variantId = firstVariant['id']?.toString();
    }

    // Options
    options = (json['options'] != null && json['options'] is List)
        ? (json['options'] as List)
        .map((v) => Options.fromJson(v as Map<String, dynamic>))
        .toList()
        : [];

    // Images
    if (json['images'] != null && json['images'] is List && json['images'].isNotEmpty) {
      images = json['images'][0]['src']?.toString();
    } else {
      images =
      "https://static.vecteezy.com/system/resources/thumbnails/004/141/669/small/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg";
    }

    // Image object
    image = (json['image'] != null && json['image'] is Map)
        ? ShopImage.fromJson(json['image'] as Map<String, dynamic>)
        : null;
  }

  ShopifyProductModel.fromWooCommerceJson(Map<String, dynamic> json) {
    id = json['id'] as int?;
    title = json['name'] as String?;
    price = json['price']?.toString();
    productType = "";
    variantId = json['id']?.toString();

    if (json['images'] != null && json['images'] is List && json['images'].isNotEmpty) {
      images = json['images'][0]['src']?.toString();
    } else {
      images =
      "https://static.vecteezy.com/system/resources/thumbnails/004/141/669/small/no-photo-or-blank-image-icon-loading-images-or-missing-image-mark-image-not-available-or-image-coming-soon-sign-simple-nature-silhouette-in-frame-isolated-illustration-vector.jpg";
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

    if (options != null) {
      map['options'] = options?.map((v) => v.toJson()).toList();
    }

    if (image != null) {
      map['image'] = image?.toJson();
    }

    return map;
  }
}

class ShopImage {
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
    variantIds = (json['variant_ids'] != null && json['variant_ids'] is List)
        ? List<dynamic>.from(json['variant_ids'])
        : [];
    adminGraphqlApiId = json['admin_graphql_api_id'] as String?;
  }

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
    map['variant_ids'] = variantIds;
    map['admin_graphql_api_id'] = adminGraphqlApiId;
    return map;
  }
}

class Images {
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
    variantIds = (json['variant_ids'] != null && json['variant_ids'] is List)
        ? List<dynamic>.from(json['variant_ids'])
        : [];
    adminGraphqlApiId = json['admin_graphql_api_id'] as String?;
  }

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
    map['variant_ids'] = variantIds;
    map['admin_graphql_api_id'] = adminGraphqlApiId;
    return map;
  }
}

class Options {
  int? id;
  int? productId;
  String? name;
  int? position;
  List<String>? values;

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
    values = (json['values'] != null && json['values'] is List)
        ? List<String>.from(json['values'])
        : [];
  }

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
