class MessageData {
  String senderId;
  String senderName;
  String senderAvatar;
  String message;
  String sentAt;
  bool isMedia;
  String mediaUrl;
  String mediaName;
  String mediaType;
  bool sent;
  bool read;

  MessageData({
    required this.senderName,
    required this.senderId,
    required this.senderAvatar,
    required this.message,
    required this.sentAt,
    required this.read,
    required this.sent,
    this.isMedia = false,
    this.mediaUrl = '',
    this.mediaType = '',
    this.mediaName = '',
  });

  static MessageData fromJson(Map<String, dynamic> json) => MessageData(
        message: json['message'],
        sentAt: json['sentAt'],
        senderName: json['senderName'],
        senderId: json['senderId'],
        senderAvatar: json['senderAvatar'],
        isMedia: json['isMedia'],
        mediaUrl: json['mediaUrl'],
        mediaType: json['mediaType'],
        mediaName: json['mediaName'], 
        read: json['read'] ?? false, 
        sent: json['sent'] ?? false, 
      );

  Map<String, dynamic> toJson() => {
        'senderId': senderId,
        'senderName': senderName,
        'sentAt': sentAt,
        'message': message,
        'senderAvatar': senderAvatar,
        'isMedia': isMedia,
        'mediaUrl': mediaUrl,
        'mediaType': mediaType,
        'mediaName': mediaName,
        'sent': sent,
        'read': read
      };
}
