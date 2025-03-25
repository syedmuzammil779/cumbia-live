class WooCommerceProductModel {
  int? id;
  String? title;
  var from;
  var to;
  String? slug;
  String? permalink;
  String? type;
  String? status;
  bool? featured;
  String? catalogVisibility;
  String? description;
  String? shortDescription;
  String? sku;
  String? price;
  String? regularPrice;
  String? salePrice;
  String? priceHtml;
  bool? onSale;
  bool? purchasable;
  int? totalSales;
  bool? virtual;
  bool? downloadable;
  List<WooProductDownload>? downloads;
  int? downloadLimit;
  int? downloadExpiry;
  String? externalUrl;
  String? buttonText;
  String? taxStatus;
  String? taxClass;
  bool? manageStock;
  int? stockQuantity;
  String? stockStatus;
  String? backorders;
  bool? backordersAllowed;
  bool? backordered;
  bool? soldIndividually;
  String? weight;
  WooProductDimension? dimensions;
  bool? shippingRequired;
  bool? shippingTaxable;
  String? shippingClass;
  int? shippingClassId;
  bool? reviewsAllowed;
  String? averageRating;
  int? ratingCount;
  List<int>? relatedIds;
  List<int>? upsellIds;
  List<int>? crossSellIds;
  int? parentId;
  String? purchaseNote;
  List<WooProductCategory>? categories;
  List<WooProductItemTag>? tags;
  List<WooProductImage>? images;
  List<WooProductItemAttribute>? attributes;
  List<WooProductDefaultAttribute>? defaultAttributes;
  List<int>? variations;
  List<int>? groupedProducts;
  int? menuOrder;
  List<MetaData>? metaData;

  WooCommerceProductModel({
    this.id,
    this.title,
    this.from,
    this.to,
    this.slug,
    this.permalink,
    this.type,
    this.status,
    this.featured,
    this.catalogVisibility,
    this.description,
    this.shortDescription,
    this.sku,
    this.price,
    this.regularPrice,
    this.salePrice,
    this.priceHtml,
    this.onSale,
    this.purchasable,
    this.totalSales,
    this.virtual,
    this.downloadable,
    this.downloads,
    this.downloadLimit,
    this.downloadExpiry,
    this.externalUrl,
    this.buttonText,
    this.taxStatus,
    this.taxClass,
    this.manageStock,
    this.stockQuantity,
    this.stockStatus,
    this.backorders,
    this.backordersAllowed,
    this.backordered,
    this.soldIndividually,
    this.weight,
    this.dimensions,
    this.shippingRequired,
    this.shippingTaxable,
    this.shippingClass,
    this.shippingClassId,
    this.reviewsAllowed,
    this.averageRating,
    this.ratingCount,
    this.relatedIds,
    this.upsellIds,
    this.crossSellIds,
    this.parentId,
    this.purchaseNote,
    this.categories,
    this.tags,
    this.images,
    this.attributes,
    this.defaultAttributes,
    this.variations,
    this.groupedProducts,
    this.menuOrder,
    this.metaData,
  });

  factory WooCommerceProductModel.fromMap(Map<String, dynamic>? json) {
    if (json == null) return WooCommerceProductModel();

    return WooCommerceProductModel(
      id: json['id'] ?? 0,
      title: json['name'] ?? '',
      slug: json['slug'] ?? '',
      permalink: json['permalink'] ?? '',
      type: json['type'] ?? '',
      status: json['status'] ?? '',
      featured: json['featured'] ?? false,
      catalogVisibility: json['catalog_visibility'] ?? '',
      description: json['description'] ?? '',
      shortDescription: json['short_description'] ?? '',
      sku: json['sku'] ?? '',
      price: json['price'] ?? '',
      regularPrice: json['regular_price'] ?? '',
      salePrice: json['sale_price'] ?? '',
      priceHtml: json['price_html'] ?? '',
      onSale: json['on_sale'] ?? false,
      purchasable: json['purchasable'] ?? false,
      totalSales: int.parse(json['total_sales'].toString()),
      virtual: json['virtual'] ?? false,
      downloadable: json['downloadable'] ?? false,
      downloads: (json['downloads'] as List?)
          ?.map((i) => WooProductDownload.fromJson(i))
          .toList() ?? [],
      downloadLimit: json['download_limit'] ?? 0,
      downloadExpiry: json['download_expiry'] ?? 0,
      externalUrl: json['external_url'] ?? '',
      buttonText: json['button_text'] ?? '',
      taxStatus: json['tax_status'] ?? '',
      taxClass: json['tax_class'] ?? '',
      manageStock: json['manage_stock'] ?? false,
      stockQuantity: json['stock_quantity'] ?? 0,
      stockStatus: json['stock_status'] ?? '',
      backorders: json['backorders'] ?? '',
      backordersAllowed: json['backorders_allowed'] ?? false,
      backordered: json['backordered'] ?? false,
      soldIndividually: json['sold_individually'] ?? false,
      weight: json['weight'] ?? '',
      dimensions: WooProductDimension.fromJson(json['dimensions']),
      shippingRequired: json['shipping_required'] ?? false,
      shippingTaxable: json['shipping_taxable'] ?? false,
      shippingClass: json['shipping_class'] ?? '',
      shippingClassId: json['shipping_class_id'] ?? 0,
      reviewsAllowed: json['reviews_allowed'] ?? false,
      averageRating: json['average_rating'] ?? '',
      ratingCount: json['rating_count'] ?? 0,
      relatedIds: json['related_ids']?.cast<int>() ?? [],
      upsellIds: json['upsell_ids']?.cast<int>() ?? [],
      crossSellIds: json['cross_sell_ids']?.cast<int>() ?? [],
      parentId: json['parent_id'] ?? 0,
      purchaseNote: json['purchase_note'] ?? '',
      categories: (json['categories'] as List?)
          ?.map((i) => WooProductCategory.fromJson(i))
          .toList() ?? [],
      tags: (json['tags'] as List?)
          ?.map((i) => WooProductItemTag.fromJson(i))
          .toList() ?? [],
      images: (json['images'] as List?)
          ?.map((i) => WooProductImage.fromJson(i))
          .toList() ?? [],
      attributes: (json['attributes'] as List?)
          ?.map((i) => WooProductItemAttribute.fromJson(i))
          .toList() ?? [],
      defaultAttributes: (json['default_attributes'] as List?)
          ?.map((i) => WooProductDefaultAttribute.fromJson(i))
          .toList(),
      variations: json['variations']?.cast<int>(),
      groupedProducts: json['grouped_products']?.cast<int>(),
      menuOrder: json['menu_order'],
      metaData: (json['meta_data'] as List?)
          ?.map((i) => MetaData.fromJson(i))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = title;
    data['slug'] = slug;
    data['permalink'] = permalink;
    data['type'] = type;
    data['status'] = status;
    data['featured'] = featured;
    data['catalog_visibility'] = catalogVisibility;
    data['description'] = description;
    data['short_description'] = shortDescription;
    data['sku'] = sku;
    data['price'] = price;
    data['regular_price'] = regularPrice;
    data['sale_price'] = salePrice;
    data['price_html'] = priceHtml;
    data['on_sale'] = onSale;
    data['purchasable'] = purchasable;
    data['total_sales'] = totalSales;
    data['virtual'] = virtual;
    data['downloadable'] = downloadable;
    if (downloads != null) {
      data['downloads'] = downloads?.map((v) => v.toJson()).toList();
    }
    data['download_limit'] = downloadLimit;
    data['download_expiry'] = downloadExpiry;
    data['external_url'] = externalUrl;
    data['button_text'] = buttonText;
    data['tax_status'] = taxStatus;
    data['tax_class'] = taxClass;
    data['manage_stock'] = manageStock;
    data['stock_quantity'] = stockQuantity;
    data['stock_status'] = stockStatus;
    data['backorders'] = backorders;
    data['backorders_allowed'] = backordersAllowed;
    data['sold_individually'] = soldIndividually;
    data['weight'] = weight;
    if (dimensions != null) {
      data['dimensions'] = dimensions?.toJson();
    }
    data['shipping_required'] = shippingRequired;
    data['shipping_taxable'] = shippingTaxable;
    data['shipping_class'] = shippingClass;
    data['shipping_class_id'] = shippingClassId;
    data['reviews_allowed'] = reviewsAllowed;
    data['average_rating'] = averageRating;
    data['rating_count'] = ratingCount;
    data['related_ids'] = relatedIds;
    data['upsell_ids'] = upsellIds;
    data['cross_sell_ids'] = crossSellIds;
    data['parent_id'] = parentId;
    data['purchase_note'] = purchaseNote;
    if (categories != null) {
      data['categories'] = categories?.map((v) => v.toJson()).toList();
    }
    if (tags != null) {
      data['tags'] = tags?.map((v) => v.toJson()).toList();
    }
    if (images != null) {
      data['images'] = images?.map((v) => v.toJson()).toList();
    }
    if (attributes != null) {
      data['attributes'] = attributes?.map((v) => v.toJson()).toList();
    }
    if (defaultAttributes != null) {
      data['default_attributes'] =
          defaultAttributes?.map((v) => v.toJson()).toList();
    }
    data['variations'] = variations;
    data['grouped_products'] = groupedProducts;
    data['menu_order'] = menuOrder;
    if (metaData != null) {
      data['meta_data'] = metaData?.map((v) => v.toJson()).toList();
    }

    return data;
  }
}

class WooProductCategory {
  int? id;
  String? name;
  String? slug;
  int? parent;
  String? description;
  String? display;
  WooProductCategoryImage? image;
  int? menuOrder;
  int? count;
  WooProductCategoryLinks? links;

  WooProductCategory({
    this.id,
    this.name,
    this.slug,
    this.parent,
    this.description,
    this.display,
    this.image,
    this.menuOrder,
    this.count,
    this.links,
  });

  factory WooProductCategory.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WooProductCategory();

    return WooProductCategory(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
      parent: json['parent'],
      description: json['description'],
      display: json['display'],
      image: json['image'] != null
          ? WooProductCategoryImage.fromJson(json['image'])
          : null,
      menuOrder: json['menu_order'],
      count: json['count'],
      links: json['_links'] != null
          ? WooProductCategoryLinks.fromJson(json['_links'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['name'] = name;
    data['slug'] = slug;
    data['parent'] = parent;
    data['description'] = description;
    data['display'] = display;
    if (image != null) {
      data['image'] = image?.toJson();
    }
    data['menu_order'] = menuOrder;
    data['count'] = count;
    if (links != null) {
      data['_links'] = links?.toJson();
    }
    return data;
  }

  @override
  String toString() => toJson().toString();
}

class WooProductCategoryImage {
  int? id;
  String? dateCreated;
  String? dateCreatedGmt;
  String? dateModified;
  String? dateModifiedGmt;
  String? src;
  String? name;
  String? alt;

  WooProductCategoryImage({
    this.id,
    this.dateCreated,
    this.dateCreatedGmt,
    this.dateModified,
    this.dateModifiedGmt,
    this.src,
    this.name,
    this.alt,
  });

  factory WooProductCategoryImage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WooProductCategoryImage();

    return WooProductCategoryImage(
      id: json['id'],
      dateCreated: json['date_created'],
      dateCreatedGmt: json['date_created_gmt'],
      dateModified: json['date_modified'],
      dateModifiedGmt: json['date_modified_gmt'],
      src: (json['src'] != null && json['src'] is String) ? json['src'] : "",
      name: json['name'],
      alt: json['alt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = id;
    data['date_created'] = dateCreated;
    data['date_created_gmt'] = dateCreatedGmt;
    data['date_modified'] = dateModified;
    data['date_modified_gmt'] = dateModifiedGmt;
    data['src'] = src;
    data['name'] = name;
    data['alt'] = alt;
    return data;
  }
}

class WooProductCategoryLinks {
  List<WooProductCategorySelf>? self;
  List<WooProductCategoryCollection>? collection;

  WooProductCategoryLinks({
    this.self,
    this.collection,
  });

  factory WooProductCategoryLinks.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WooProductCategoryLinks();

    List<WooProductCategorySelf>? selfList;
    List<WooProductCategoryCollection>? collectionList;

    if (json['self'] != null) {
      selfList = (json['self'] as List)
          .cast<Map<String, dynamic>>()
          .map((v) => WooProductCategorySelf.fromJson(v))
          .toList();
    }
    if (json['collection'] != null) {
      collectionList = (json['collection'] as List)
          .cast<Map<String, dynamic>>()
          .map((v) => WooProductCategoryCollection.fromJson(v))
          .toList();
    }

    return WooProductCategoryLinks(
      self: selfList,
      collection: collectionList,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (self != null) {
      data['self'] = self!.map((v) => v.toJson()).toList();
    }
    if (collection != null) {
      data['collection'] = collection!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}



class WooProductCategorySelf {
  String? href;

  WooProductCategorySelf({
    this.href,
  });

  factory WooProductCategorySelf.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WooProductCategorySelf();

    return WooProductCategorySelf(
      href: json['href'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['href'] = href;
    return data;
  }
}

class WooProductCategoryCollection {
  String? href;

  WooProductCategoryCollection({
    this.href,
  });

  factory WooProductCategoryCollection.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WooProductCategoryCollection();

    return WooProductCategoryCollection(
      href: json['href'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['href'] = href;
    return data;
  }
}

class WooProductItemTag {
  int? id;
  String? name;
  String? slug;

  WooProductItemTag({
    this.id,
    this.name,
    this.slug,
  });

  factory WooProductItemTag.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WooProductItemTag();

    return WooProductItemTag(
      id: json['id'],
      name: json['name'],
      slug: json['slug'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'slug': slug};
}

class MetaData {
  int? id;
  String? key;
  String? value;

  MetaData({
    this.id,
    this.key,
    this.value,
  });

  factory MetaData.fromJson(Map<String, dynamic>? json) {
    if (json == null) return MetaData();

    return MetaData(
      id: json['id'],
      key: json['key'],
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'key': key, 'value': value};
}


class WooProductDefaultAttribute {
  int? id;
  String? name;
  String? option;

  WooProductDefaultAttribute({this.id, this.name, this.option});

  factory WooProductDefaultAttribute.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WooProductDefaultAttribute();

    return WooProductDefaultAttribute(
      id: json['id'],
      name: json['name'],
      option: json['option'],
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'option': option};
}

class WooProductImage {
  int? id;
  String? src;
  String? name;
  String? alt;
  DateTime? dateCreated;
  DateTime? dateCreatedGMT;
  DateTime? dateModified;
  DateTime? dateModifiedGMT;
  String? date_created;
  String? date_modified_gmt;
  String? date_modified;
  String? date_created_gmt;

  WooProductImage({
    this.id,
    this.src,
    this.name,
    this.alt,
    this.dateCreated,
    this.dateCreatedGMT,
    this.dateModified,
    this.dateModifiedGMT,
    this.date_created,
    this.date_modified_gmt,
    this.date_modified,
    this.date_created_gmt,
  });

  factory WooProductImage.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WooProductImage();

    return WooProductImage(
      id: json['id'],
      src: json['src'],
      name: json['name'],
      alt: json['alt'],
      dateCreated: json['date_created'] != null
          ? DateTime.tryParse(json['date_created'])
          : DateTime.now(),
      dateModifiedGMT: json['date_modified_gmt'] != null
          ? DateTime.tryParse(json['date_modified_gmt'])
          : DateTime.now(),
      dateModified: json['date_modified'] != null
          ? DateTime.tryParse(json['date_modified'])
          : DateTime.now(),
      dateCreatedGMT: json['date_created_gmt'] != null
          ? DateTime.tryParse(json['date_created_gmt'])
          : DateTime.now(),
      date_created: json['date_created'],
      date_modified_gmt: json['date_modified_gmt'],
      date_modified: json['date_modified'],
      date_created_gmt: json['date_created_gmt'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    data['id'] = id;
    data['src'] = src;
    data['name'] = name;
    data['date_created'] = date_created;
    data['date_modified_gmt'] = date_modified_gmt;
    data['date_modified'] = date_modified;
    data['date_created_gmt'] = date_created_gmt;
    return data;
  }
}

///
/// class Category {
///  final int id;
/// final String name;
///   final String slug;

///   Category(this.id, this.name, this.slug);

///   Category.fromJson(Map<String, dynamic> json)
///       : id = json['id'],
///         name = json['name'],
///         slug = json['slug'];

///   Map<String, dynamic> toJson() => {
///         'id': id,
///         'name': name,
///         'slug': slug,
///       };
///   @override toString() => toJson().toString();
/// }
///

class WooProductDimension {
  String? length;
  String? width;
  String? height;

  WooProductDimension({this.length, this.height, this.width});

  factory WooProductDimension.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WooProductDimension();

    return WooProductDimension(
      length: json['length'],
      width: json['width'],
      height: json['height'],
    );
  }

  Map<String, dynamic> toJson() =>
      {'length': length, 'width': width, 'height': height};
}

class WooProductItemAttribute {
  int? id;
  String? name;
  int? position;
  bool? visible;
  bool? variation;
  List<String>? options;

  WooProductItemAttribute({
    this.id,
    this.name,
    this.position,
    this.visible,
    this.variation,
    this.options,
  });

  factory WooProductItemAttribute.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WooProductItemAttribute();

    return WooProductItemAttribute(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      visible: json['visible'],
      variation: json['variation'],
      options: json['options']?.cast<String>(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'position': position,
    'visible': visible,
    'variation': variation,
    'options': options,
  };
}

class WooProductDownload {
  String? id;
  String? name;
  String? file;

  WooProductDownload({this.id, this.name, this.file});

  factory WooProductDownload.fromJson(Map<String, dynamic>? json) {
    if (json == null) return WooProductDownload();

    return WooProductDownload(
      id: json['id'],
      name: json['name'],
      file: json['file'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'file': file,
  };
}

