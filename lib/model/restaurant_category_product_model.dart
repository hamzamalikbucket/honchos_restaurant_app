// To parse this JSON data, do
//
//     final categoriesProductsModel = categoriesProductsModelFromJson(jsonString);

import 'dart:convert';

List<CategoriesProductsModel> categoriesProductsModelFromJson(String str) => List<CategoriesProductsModel>.from(json.decode(str).map((x) => CategoriesProductsModel.fromJson(x)));

String categoriesProductsModelToJson(List<CategoriesProductsModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CategoriesProductsModel {
  CategoriesProductsModel({
    this.id,
    this.categoryId,
    this.subCategoryId,
    this.restaurantId,
    this.name,
    this.image,
    this.description,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.price,
    this.category,
    this.subCategory,
    this.restaurant,
  });

  int? id;
  String? categoryId;
  String? subCategoryId;
  String? restaurantId;
  String? name;
  String? image;
  String? description;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? price;
  Category? category;
  Category? subCategory;
  Category? restaurant;

  factory CategoriesProductsModel.fromJson(Map<String, dynamic> json) => CategoriesProductsModel(
    id: json["id"],
    categoryId: json["category_id"],
    subCategoryId: json["sub_category_id"],
    restaurantId: json["restaurant_id"],
    name: json["name"],
    image: json["image"],
    description: json["description"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    price: json["price"],
    category: json["category"] == null ? null : Category.fromJson(json["category"]),
    subCategory: json["sub_category"] == null ? null : Category.fromJson(json["sub_category"]),
    restaurant: json["restaurant"] == null ? null : Category.fromJson(json["restaurant"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "category_id": categoryId,
    "sub_category_id": subCategoryId,
    "restaurant_id": restaurantId,
    "name": name,
    "image": image,
    "description": description,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "price": price,
    "category": category?.toJson(),
    "sub_category": subCategory?.toJson(),
    "restaurant": restaurant?.toJson(),
  };
}

class Category {
  Category({
    this.id,
    this.restaurantId,
    this.name,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.longitude,
    this.latitude,
    this.categoryId,
  });

  int? id;
  String? restaurantId;
  String? name;
  String? image;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? longitude;
  String? latitude;
  String? categoryId;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json["id"],
    restaurantId: json["restaurant_id"],
    name: json["name"],
    image: json["image"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    longitude: json["longitude"],
    latitude: json["latitude"],
    categoryId: json["category_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "restaurant_id": restaurantId,
    "name": name,
    "image": image,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "longitude": longitude,
    "latitude": latitude,
    "category_id": categoryId,
  };
}
