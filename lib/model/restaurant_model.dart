// To parse this JSON data, do
//
//     final restaurantModel = restaurantModelFromJson(jsonString);

import 'dart:convert';

List<RestaurantModel> restaurantModelFromJson(String str) => List<RestaurantModel>.from(json.decode(str).map((x) => RestaurantModel.fromJson(x)));

String restaurantModelToJson(List<RestaurantModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class RestaurantModel {
  int? id;
  String? name;
  String? image;
  String? longitude;
  String? latitude;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? address;
  dynamic weekId;
  String? phoneNo;
  List<WeekId>? weekIds;

  RestaurantModel({
    this.id,
    this.name,
    this.image,
    this.longitude,
    this.latitude,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.address,
    this.weekId,
    this.phoneNo,
    this.weekIds,
  });

  factory RestaurantModel.fromJson(Map<String, dynamic> json) => RestaurantModel(
    id: json["id"],
    name: json["name"],
    image: json["image"],
    longitude: json["longitude"],
    latitude: json["latitude"],
    status: json["status"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    address: json["address"],
    weekId: json["week_id"],
    phoneNo: json["phone_no"],
    weekIds: json["week_ids"] == null ? [] : List<WeekId>.from(json["week_ids"]!.map((x) => WeekId.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "image": image,
    "longitude": longitude,
    "latitude": latitude,
    "status": status,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "address": address,
    "week_id": weekId,
    "phone_no": phoneNo,
    "week_ids": weekIds == null ? [] : List<dynamic>.from(weekIds!.map((x) => x.toJson())),
  };
}


class WeekId {
  int? id;
  String? restaurantId;
  String? restaurantTimingsId;
  DateTime? createdAt;
  DateTime? updatedAt;
  RestaurantTimings? restaurantTimings;

  WeekId({
    this.id,
    this.restaurantId,
    this.restaurantTimingsId,
    this.createdAt,
    this.updatedAt,
    this.restaurantTimings,
  });

  factory WeekId.fromJson(Map<String, dynamic> json) => WeekId(
    id: json["id"],
    restaurantId: json["restaurant_id"],
    restaurantTimingsId: json["restaurant_timings_id"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    restaurantTimings: json["restaurant_timings"] == null ? null : RestaurantTimings.fromJson(json["restaurant_timings"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "restaurant_id": restaurantId,
    "restaurant_timings_id": restaurantTimingsId,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "restaurant_timings": restaurantTimings?.toJson(),
  };
}

class RestaurantTimings {
  int? id;
  String? name;
  String? openingTime;
  String? closingTime;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? restaurantId;

  RestaurantTimings({
    this.id,
    this.name,
    this.openingTime,
    this.closingTime,
    this.createdAt,
    this.updatedAt,
    this.restaurantId,
  });

  factory RestaurantTimings.fromJson(Map<String, dynamic> json) => RestaurantTimings(
    id: json["id"],
    name: json["name"],
    openingTime: json["opening_time"],
    closingTime: json["closing_time"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    restaurantId: json["restaurant_id"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "opening_time": openingTime,
    "closing_time": closingTime,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
    "restaurant_id": restaurantId,
  };


  // Map<String, dynamic> toJson() => {
  //   "idRestaurant": id,
  //   "nameRestaurant": name,
  //   "opening_time_Restaurant": openingTime,
  //   "closing_time_Restaurant": closingTime,
  //   "created_at_Restaurant": createdAt?.toIso8601String(),
  //   "updated_at_Restaurant": updatedAt?.toIso8601String(),
  //   "restaurant_id_Restaurant": restaurantId,
  // };



}

