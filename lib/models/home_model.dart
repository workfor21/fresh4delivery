// To parse this JSON data, do
//
//     final homeModel = homeModelFromJson(jsonString?);

import 'dart:convert';

HomeModel homeModelFromJson(String? str) =>
    HomeModel.fromJson(json.decode(str!));

String? homeModelToJson(HomeModel data) => json.encode(data.toJson());

class HomeModel {
  HomeModel({
    this.sts,
    this.msg,
    this.cartcount,
    this.categories,
    this.fbanners,
    this.sbanners,
    this.restaurants,
    this.nrestaurants,
    this.supermarkets,
    this.nsupermarkets,
    this.restproducts,
    this.nrestproducts,
  });

  String? sts;
  String? msg;
  int? cartcount;
  List<CategoryModel>? categories;
  List<BannerModel>? fbanners;
  List<BannerModel>? sbanners;
  List<dynamic>? restaurants;
  List<dynamic>? nrestaurants;
  List<dynamic>? supermarkets;
  List<dynamic>? nsupermarkets;
  List<dynamic>? restproducts;
  List<Nrestproduct>? nrestproducts;

  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
        sts: json["sts"],
        msg: json["msg"],
        cartcount: json["cartcount"],
        categories: List<CategoryModel>.from(
            json["categories"].map((x) => CategoryModel.fromJson(x))),
        fbanners: List<BannerModel>.from(
            json["fbanners"].map((x) => BannerModel.fromJson(x))),
        sbanners: List<BannerModel>.from(
            json["sbanners"].map((x) => BannerModel.fromJson(x))),
        restaurants: List<dynamic>.from(json["restaurants"].map((x) => x)),
        nrestaurants: List<dynamic>.from(json["nrestaurants"].map((x) => x)),
        supermarkets: List<dynamic>.from(json["supermarkets"].map((x) => x)),
        nsupermarkets: List<dynamic>.from(json["nsupermarkets"].map((x) => x)),
        restproducts: List<dynamic>.from(json["restproducts"].map((x) => x)),
        nrestproducts: List<Nrestproduct>.from(
            json["nrestproducts"].map((x) => Nrestproduct.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "sts": sts,
        "msg": msg,
        "cartcount": cartcount,
        "categories": List<dynamic>.from(categories!.map((x) => x.toJson())),
        "fbanners": List<dynamic>.from(fbanners!.map((x) => x.toJson())),
        "sbanners": List<dynamic>.from(sbanners!.map((x) => x.toJson())),
        "restaurants": List<dynamic>.from(restaurants!.map((x) => x)),
        "nrestaurants": List<dynamic>.from(nrestaurants!.map((x) => x)),
        "supermarkets": List<dynamic>.from(supermarkets!.map((x) => x)),
        "nsupermarkets": List<dynamic>.from(nsupermarkets!.map((x) => x)),
        "restproducts": List<dynamic>.from(restproducts!.map((x) => x)),
        "nrestproducts":
            List<dynamic>.from(nrestproducts!.map((x) => x.toJson())),
      };
}

class CategoryModel {
  CategoryModel({
    this.id,
    this.type,
    this.name,
    this.dispOrder,
    this.image,
  });

  int? id;
  String? type;
  String? name;
  int? dispOrder;
  String? image;

  factory CategoryModel.fromJson(Map<String, dynamic> json) => CategoryModel(
        id: json["id"],
        type: json["type"],
        name: json["name"],
        dispOrder: json["disp_order"],
        image: json["image"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "name": name,
        "disp_order": dispOrder,
        "image": image,
      };
}

class BannerModel {
  BannerModel({
    this.id,
    this.type,
    this.name,
    this.image,
    this.url,
    this.disporder,
  });

  int? id;
  String? type;
  String? name;
  String? image;
  String? url;
  int? disporder;

  factory BannerModel.fromJson(Map<String, dynamic> json) => BannerModel(
        id: json["id"],
        type: json["type"],
        name: json["name"],
        image: json["image"],
        url: json["url"],
        disporder: json["disporder"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "name": name,
        "image": image,
        "url": url,
        "disporder": disporder,
      };
}

class Nrestaurant {
  Nrestaurant({
    this.id,
    this.name,
    this.logo,
    this.deliveryTime,
    this.promoted,
  });

  int? id;
  String? name;
  String? logo;
  DeliveryTime? deliveryTime;
  String? promoted;

  factory Nrestaurant.fromJson(Map<String, dynamic> json) => Nrestaurant(
        id: json["id"],
        name: json["name"],
        logo: json["logo"],
        deliveryTime: deliveryTimeValues.map![json["delivery_time"]],
        promoted: json["promoted"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "logo": logo,
        "delivery_time": deliveryTimeValues.reverse![deliveryTime],
        "promoted": promoted,
      };
}

enum DeliveryTime {
  THE_20_MINUTES,
  THE_25_MINUTES,
  THE_45_MINUTES,
  THE_30_MINUTES
}

final deliveryTimeValues = EnumValues({
  "20 Minutes": DeliveryTime.THE_20_MINUTES,
  "25 Minutes": DeliveryTime.THE_25_MINUTES,
  "30 Minutes": DeliveryTime.THE_30_MINUTES,
  "45 Minutes": DeliveryTime.THE_45_MINUTES
});

class Nrestproduct {
  Nrestproduct({
    this.id,
    this.name,
    this.type,
    this.catId,
    this.hasUnits,
    this.price,
    this.offerprice,
    this.image,
    this.restname,
  });

  int? id;
  String? name;
  Type? type;
  int? catId;
  String? hasUnits;
  int? price;
  int? offerprice;
  String? image;
  String? restname;

  factory Nrestproduct.fromJson(Map<String, dynamic> json) => Nrestproduct(
        id: json["id"],
        name: json["name"],
        type: typeValues.map![json["type"]],
        catId: json["cat_id"],
        hasUnits: json["has_units"],
        price: json["price"],
        offerprice: json["offerprice"],
        image: json["image"],
        restname: json["restname"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "type": typeValues.reverse![type],
        "cat_id": catId,
        "has_units": hasUnits,
        "price": price,
        "offerprice": offerprice,
        "image": image,
        "restname": restname,
      };
}

enum Type { NON_VEG, VEG }

final typeValues = EnumValues({"Non-Veg": Type.NON_VEG, "Veg": Type.VEG});

class EnumValues<T> {
  Map<String, T>? map;
  Map<T, String?>? reverseMap;

  EnumValues(this.map);

  Map<T, String?>? get reverse {
    if (reverseMap == null) {
      reverseMap = map!.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
