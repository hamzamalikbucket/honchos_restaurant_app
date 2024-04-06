// To parse this JSON data, do
//
//     final sessionModel = sessionModelFromJson(jsonString);

import 'dart:convert';

SessionModel sessionModelFromJson(String str) => SessionModel.fromJson(json.decode(str));

String sessionModelToJson(SessionModel data) => json.encode(data.toJson());

class SessionModel {
  Session? session;

  SessionModel({
    this.session,
  });

  factory SessionModel.fromJson(Map<String, dynamic> json) => SessionModel(
    session: json["session"] == null ? null : Session.fromJson(json["session"]),
  );

  Map<String, dynamic> toJson() => {
    "session": session?.toJson(),
  };
}

class Session {
  String? token;
  Flash? flash;
  Previous? previous;
  int? driverId;
  String? driverName;
  int? id;
  String? name;
  String? restaurantId;
  String? email;

  Session({
    this.token,
    this.flash,
    this.previous,
    this.driverId,
    this.driverName,
    this.id,
    this.name,
    this.restaurantId,
    this.email,
  });

  factory Session.fromJson(Map<String, dynamic> json) => Session(
    token: json["_token"],
    flash: json["_flash"] == null ? null : Flash.fromJson(json["_flash"]),
    previous: json["_previous"] == null ? null : Previous.fromJson(json["_previous"]),
    driverId: json["driver_id"],
    driverName: json["driver_name"],
    id: json["id"],
    name: json["name"],
    restaurantId: json["restaurant_id"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "_token": token,
    "_flash": flash?.toJson(),
    "_previous": previous?.toJson(),
    "driver_id": driverId,
    "driver_name": driverName,
    "id": id,
    "name": name,
    "restaurant_id": restaurantId,
    "email": email,
  };
}

class Flash {
  List<dynamic>? old;
  List<dynamic>? flashNew;

  Flash({
    this.old,
    this.flashNew,
  });

  factory Flash.fromJson(Map<String, dynamic> json) => Flash(
    old: json["old"] == null ? [] : List<dynamic>.from(json["old"]!.map((x) => x)),
    flashNew: json["new"] == null ? [] : List<dynamic>.from(json["new"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "old": old == null ? [] : List<dynamic>.from(old!.map((x) => x)),
    "new": flashNew == null ? [] : List<dynamic>.from(flashNew!.map((x) => x)),
  };
}

class Previous {
  String? url;

  Previous({
    this.url,
  });

  factory Previous.fromJson(Map<String, dynamic> json) => Previous(
    url: json["url"],
  );

  Map<String, dynamic> toJson() => {
    "url": url,
  };
}
