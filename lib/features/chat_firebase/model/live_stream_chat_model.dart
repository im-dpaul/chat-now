// To parse this JSON data, do
//
//     final liveStreamChatModel = liveStreamChatModelFromJson(jsonString);

import 'dart:convert';

LiveStreamChatModel liveStreamChatModelFromJson(String str) => LiveStreamChatModel.fromJson(json.decode(str));

String liveStreamChatModelToJson(LiveStreamChatModel data) => json.encode(data.toJson());

class LiveStreamChatModel {
  final String? name;
  final String? photo;
  final DateTime? date;
  final String? message;
  final String? uid;

  LiveStreamChatModel({
    this.name,
    this.photo,
    this.date,
    this.message,
    this.uid
  });

  factory LiveStreamChatModel.fromJson(Map<String, dynamic> json) => LiveStreamChatModel(
        name: json["name"],
        photo: json["photo"],
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        message: json["msg"],
        uid: json["uuid"]
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "photo": photo,
        "date": date?.toIso8601String(),
        "msg": message,
        "uuid": uid
      };
}
