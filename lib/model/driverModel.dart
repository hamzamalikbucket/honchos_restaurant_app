// // To parse this JSON data, do
// //
// //     final driversModel = driversModelFromJson(jsonString);
//
// import 'dart:convert';
//
// List<DriversModel> driversModelFromJson(String str) => List<DriversModel>.from(json.decode(str).map((x) => DriversModel.fromJson(x)));
//
// String driversModelToJson(List<DriversModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));
//
// class DriversModel {
//   int? id;
//   String? restaurantId;
//   String? name;
//   String? email;
//   String? phoneNo;
//   String? password;
//   String? status;
//   String? image;
//   dynamic longitude;
//   dynamic latitude;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//
//   DriversModel({
//     this.id,
//     this.restaurantId,
//     this.name,
//     this.email,
//     this.phoneNo,
//     this.password,
//     this.status,
//     this.image,
//     this.longitude,
//     this.latitude,
//     this.createdAt,
//     this.updatedAt,
//   });
//
//   factory DriversModel.fromJson(Map<String, dynamic> json) => DriversModel(
//     id: json["id"],
//     restaurantId: json["restaurant_id"],
//     name: json["name"],
//     email: json["email"],
//     phoneNo: json["phone_no"],
//     password: json["password"],
//     status: json["status"],
//     image: json["image"],
//     longitude: json["longitude"],
//     latitude: json["latitude"],
//     createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
//     updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
//   );
//
//   Map<String, dynamic> toJson() => {
//     "id": id,
//     "restaurant_id": restaurantId,
//     "name": name,
//     "email": email,
//     "phone_no": phoneNo,
//     "password": password,
//     "status": status,
//     "image": image,
//     "longitude": longitude,
//     "latitude": latitude,
//     "created_at": createdAt?.toIso8601String(),
//     "updated_at": updatedAt?.toIso8601String(),
//   };
// }




// To parse this JSON data, do
//
//     final driversModel = driversModelFromJson(jsonString);

import 'dart:convert';

List<DriversModel> driversModelFromJson(String str) => List<DriversModel>.from(json.decode(str).map((x) => DriversModel.fromJson(x)));

String driversModelToJson(List<DriversModel> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class DriversModel {
  int? id;
  String? restaurantId;
  String? name;
  String? email;
  String? phoneNo;
  String? password;
  String? status;
  String? image;
  dynamic longitude;
  dynamic latitude;
  DateTime? createdAt;
  DateTime? updatedAt;

  DriversModel({
    this.id,
    this.restaurantId,
    this.name,
    this.email,
    this.phoneNo,
    this.password,
    this.status,
    this.image,
    this.longitude,
    this.latitude,
    this.createdAt,
    this.updatedAt,
  });

  factory DriversModel.fromJson(Map<String, dynamic> json) => DriversModel(
    id: json["id"],
    restaurantId: json["restaurant_id"],
    name: json["name"],
    email: json["email"],
    phoneNo: json["phone_no"],
    password: json["password"],
    status: json["status"],
    image: json["image"],
    longitude: json["longitude"],
    latitude: json["latitude"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "restaurant_id": restaurantId,
    "name": name,
    "email": email,
    "phone_no": phoneNo,
    "password": password,
    "status": status,
    "image": image,
    "longitude": longitude,
    "latitude": latitude,
    "created_at": createdAt?.toIso8601String(),
    "updated_at": updatedAt?.toIso8601String(),
  };
}
