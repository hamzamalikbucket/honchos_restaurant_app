// To parse this JSON data, do
//
//     final restaurantCategoriesModel = restaurantCategoriesModelFromJson(jsonString);

import 'dart:convert';

List<RestaurantCategoriesModel> restaurantCategoriesModelFromJson(String str) => List<RestaurantCategoriesModel>.from(json.decode(str).map((x) => RestaurantCategoriesModel.fromJson(x)));

String restaurantCategoriesModelToJson(List<RestaurantCategoriesModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RestaurantCategoriesModel {
  RestaurantCategoriesModel({
    this.id,
    this.restaurantId,
    this.name,
    this.image,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.restaurant,
    this.longitude,
    this.latitude,
  });

  int? id;
  String? restaurantId;
  String? name;
  String? image;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  RestaurantCategoriesModel? restaurant;
  String? longitude;
  String? latitude;

  factory RestaurantCategoriesModel.fromJson(Map<String, dynamic> json) => RestaurantCategoriesModel(
    id: json["id"],
    restaurantId: json["restaurant_id"],
    name: json["name"],
    image: json["image"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    restaurant: json["restaurant"] == null ? null : RestaurantCategoriesModel.fromJson(json["restaurant"]),
    longitude: json["longitude"],
    latitude: json["latitude"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "restaurant_id": restaurantId,
    "name": name,
    "image": image,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "restaurant": restaurant?.toJson(),
    "longitude": longitude,
    "latitude": latitude,
  };
}
