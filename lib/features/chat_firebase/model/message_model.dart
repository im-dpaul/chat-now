// To parse this JSON data, do
//
//     messageModel = messageModelFromJson(jsonString);

import 'dart:convert';

MessageModel messageModelFromJson(String str) => MessageModel.fromJson(json.decode(str));

String messageModelToJson(MessageModel data) => json.encode(data.toJson());

class MessageModel {
  MessageModel({
    this.id,
    this.message,
    this.senderType,
    this.receiverType,
    this.isMedia,
    this.mediaUrl,
    this.isRead,
    this.isSent,
    this.createdAt,
    this.updatedAt,
    this.chatId,
    this.role,
    this.mediaType,
    this.isDelivered,
    this.tempId
  });

  String? id;
  String? message;
  Type? senderType;
  Type? receiverType;
  bool? isMedia;
  String? mediaUrl;
  bool? isRead;
  bool? isSent;
  bool? isDelivered;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? chatId;
  Type? role;
  String? mediaType;
  String? tempId;

  factory MessageModel.fromJson(Map<String, dynamic> json) => MessageModel(
        id: json["_id"],
        message: json["message"],
        senderType: json["senderType"] == null
            ? null
            : Type.user.name == json["senderType"]
                ? Type.user
                : Type.trainer,
        receiverType: json["receiverType"] == null
            ? null
            : Type.user.name == json["receiverType"]
                ? Type.user
                : Type.trainer,
        isMedia: json["isMedia"],
        mediaUrl: json["mediaUrl"],
        isRead: json["isRead"],
        isSent: json["isSent"],
        createdAt: json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
        updatedAt: json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
        chatId: json["chatId"],
        mediaType: json['mediaType'],
        role: json["role"] == null
            ? null
            : Type.user.name == json["role"]
                ? Type.user
                : Type.trainer,
        isDelivered: json["isDelivered"],
        tempId: json["tempId"],
      );

  Map<String, dynamic> toJson() => {
        "_id": id,
        "message": message,
        "senderType": senderType,
        "receiverType": receiverType,
        "isMedia": isMedia,
        "mediaUrl": mediaUrl,
        "isRead": isRead,
        "isSent": isSent,
        "createdAt": createdAt?.toIso8601String(),
        "updatedAt": updatedAt?.toIso8601String(),
        "chatId": chatId,
        "role": role?.name,
        "mediaType": mediaType,
        "isDelivered": isDelivered,
        "tempId": tempId
      };
}

enum Type { user, trainer }

extension TypeExtension on Type {
  String? get name {
    switch (this) {
      case Type.user:
        return 'user';
      case Type.trainer:
        return 'trainer';
      default:
        return null;
    }
  }
}
