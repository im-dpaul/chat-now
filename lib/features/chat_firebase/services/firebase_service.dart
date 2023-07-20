import 'dart:developer';

import 'package:fitbasix_chat/features/chat_firebase/model/chat_model.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

class FirebaseServices {
  // static final FirebaseServices firebaseServices = FirebaseServices._private();

  // factory FirebaseServices() => firebaseServices;

  // FirebaseServices._private();

  // // final firestoreDatabase = FirebaseFirestore.instance;
  // // final firebaseStorage = FirebaseStorage.instance;

  // String getChatRoomId(String senderId, String receiverId) {
  //   if (!(senderId.compareTo(receiverId) > 0)) {
  //     return "$receiverId\_$senderId";
  //   } else {
  //     return "$senderId\_$receiverId";
  //   }
  // }

  // Future<void> setStatusOnline(
  //     {required BuildContext context,
  //     required String receiverId,
  //     required String senderId,
  //     required}) async {
  //   try {
  //     var a = await FirebaseFirestore.instance
  //         .collection("chats")
  //         .doc(getChatRoomId(receiverId, senderId))
  //         .get();
  //     if (a.exists) {
  //       await firestoreDatabase
  //           .collection('chats')
  //           .doc(getChatRoomId(receiverId, senderId))
  //           .update({'online_$senderId': true, 'lastSeen_$senderId': ""});
  //     } else {
  //       await firestoreDatabase
  //           .collection('chats')
  //           .doc(getChatRoomId(receiverId, senderId))
  //           .set({'online_$senderId': true, 'lastSeen_$senderId': ""});
  //     }
  //   } on FirebaseException catch (e) {
  //     log(e.toString());
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           (e.message.toString()),
  //         ),
  //       ),
  //     );
  //   }
  // }

  // Future<void> setMessageRead(
  //     {required BuildContext context,
  //     required String receiverId,
  //     required String senderId,
  //     required String documentId}) async {
  //   try {
  //     await firestoreDatabase
  //         .collection('chats')
  //         .doc(getChatRoomId(receiverId, senderId))
  //         .collection('messages')
  //         .doc(documentId)
  //         .update({'read': true, 'sent': true});
  //   } on FirebaseException catch (e) {
  //     log(e.toString());
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           (e.message.toString()),
  //         ),
  //       ),
  //     );
  //   }
  // }

  // Future<void> setStatusOffline(
  //     {required BuildContext context,
  //     required String receiverId,
  //     required String senderId,
  //     required}) async {
  //   try {
  //     await firestoreDatabase
  //         .collection('chats')
  //         .doc(getChatRoomId(receiverId, senderId))
  //         .update({
  //       'online_$senderId': false,
  //       'lastSeen_$senderId': DateTime.now().toUtc().toString()
  //     });
  //   } on FirebaseException catch (e) {
  //     log(e.toString());
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           (e.message.toString()),
  //         ),
  //       ),
  //     );
  //   }
  // }

  // Future<void> setStatusTypingTrue(
  //     {required BuildContext context,
  //     required String receiverId,
  //     required String senderId,
  //     required}) async {
  //   try {
  //     await firestoreDatabase
  //         .collection('chats')
  //         .doc(getChatRoomId(receiverId, senderId))
  //         .update({
  //       'typing_$senderId': true,
  //     });
  //   } on FirebaseException catch (e) {
  //     log(e.toString());
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           (e.message.toString()),
  //         ),
  //       ),
  //     );
  //   }
  // }

  // Future<void> setStatusTypingFalse(
  //     {required BuildContext context,
  //     required String receiverId,
  //     required String senderId,
  //     required}) async {
  //   try {
  //     await firestoreDatabase
  //         .collection('chats')
  //         .doc(getChatRoomId(receiverId, senderId))
  //         .update({
  //       'typing_$senderId': false,
  //     });
  //   } on FirebaseException catch (e) {
  //     log(e.toString());
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           (e.message.toString()),
  //         ),
  //       ),
  //     );
  //   }
  // }

  // Future<void> sendMessage(
  //     {required BuildContext context,
  //     required String receiverId,
  //     required MessageData messageData,
  //     required String senderId,
  //     required}) async {
  //   try {
  //     await firestoreDatabase
  //         .collection('chats')
  //         .doc(getChatRoomId(receiverId, senderId))
  //         .collection('messages')
  //         .add(messageData.toJson())
  //         .then((value) {
  //       // MessageService.sendMessageNotification(
  //       //     receiverId: receiverId,
  //       //     senderId: senderId,
  //       //     message: messageData.message);
  //     });
  //   } on FirebaseException catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(
  //         content: Text(
  //           (e.message.toString()),
  //         ),
  //       ),
  //     );
  //   }
  // }

  // Future<MessageData?> getLastMessage({
  //   required String receiverId,
  //   required String senderId,
  // }) async {
  //   try {
  //     var data = await firestoreDatabase
  //         .collection('chats')
  //         .doc(getChatRoomId(senderId, receiverId))
  //         .collection('messages')
  //         .orderBy('sentAt', descending: true)
  //         .get();
  //     if (data.docs.isNotEmpty) {
  //       var message = MessageData.fromJson(data.docs[0].data());
  //       return message;
  //     }
  //     return null;
  //   } catch (e) {
  //     log(e.toString());
  //     return null;
  //   }
  // }

  // Stream<QuerySnapshot> getMessageStream({
  //   required String chatId,
  // }) {
  //   return firestoreDatabase
  //       .collection('chats')
  //       .doc(chatId)
  //       .collection('messages')
  //       .orderBy('sentAt', descending: true)
  //       .snapshots();
  // }

  // Future<String> uploadFile(File file, String fileName) async {
  //   final dio = Dio();
  //   var formData = FormData();
  //   formData.files.addAll([
  //     MapEntry(
  //         'file',
  //         await MultipartFile.fromFile(file.path,
  //             filename: file.path.split('/').last)),
  //   ]);
  //   dio.options.headers["language"] = "1";
  //   dio.options.headers['Authorization'] = await LogInService.getAccessToken();
  //   var result = await dio.post(
  //     ApiUrl.uploadChatMedia,
  //     data: formData,
  //     onSendProgress: (sent, total) {
  //       Get.Get.find<FirebaseChatController>().uploadProgress.value =
  //           ((sent / total) * 100).toPrecision(0);
  //     },
  //   );
  //   Get.Get.find<FirebaseChatController>().uploadProgress.value = 0;
  //   return imageModelFromJson(result.toString()).response.location;
  // }
}
