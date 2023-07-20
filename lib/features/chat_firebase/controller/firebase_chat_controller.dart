import 'dart:developer';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:fitbasix_chat/core/routes/api_routes.dart';
import 'package:fitbasix_chat/features/chat_firebase/model/chat_model.dart';
import 'package:fitbasix_chat/features/chat_firebase/model/live_stream_chat_model.dart';
import 'package:fitbasix_chat/features/chat_firebase/model/message_model.dart';
import 'package:fitbasix_chat/features/chat_firebase/services/firebase_service.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:uuid/uuid.dart';

class FirebaseChatController extends GetxController {
  late IO.Socket socket;
  RxnString senderID = RxnString();
  RxnString receiverID = RxnString();
  RxnString chatId = RxnString();
  RxList<MessageModel> messages = <MessageModel>[].obs;
  RxBool status = false.obs;
  RxBool loader = false.obs;
  RxBool typing = false.obs;
  Rxn<DateTime> lastSeen = Rxn();
  Rxn<XFile> pickedFile = Rxn();
  Rxn<Map<DateTime, List<MessageModel?>>> groupList = Rxn({});
  RxBool sending = false.obs;
  RxDouble downloadProgress = RxDouble(0);
  RxBool loadingChat = false.obs;
  RxBool hasMoreMessages = true.obs;
  RxBool isCallMute = false.obs;
  RxInt _page = 0.obs;
  int get page => _page.value;
  RxBool isChatScreen = false.obs;
  RxBool isVideoCallScreen = false.obs;
  void increasePage(int val) => _page.value = val + 1;

  RxInt trainerUID = 0.obs;
  final assetsAudioPlayer = AssetsAudioPlayer();

  RxList<LiveStreamChatModel> message = <LiveStreamChatModel>[].obs;
  RxList<int> likes = <int>[].obs;

  // AgoraController agoraController = Get.find<AgoraController>();

  liveStreamConnect({required String userId, required String room}) async {
    socket = IO.io('ApiUrl.liveBaseURL', <String, dynamic>{
      'Connection': 'upgrade',
      'Upgrade': 'websocket',
      "transports": ["websocket"],
      "autoConnect": true,
    });
    socket.disconnect();
    socket.connect();
    message.value = [];
    likes.value = [];
    socket.onConnect((val) {});
    socket.emit("joinLiveSession", {"userId": userId, "room": room});
    socket.on("trainerUID", (data) {
      log(data.toString());
      trainerUID.value = data["uid"];
      trainerUID.refresh();
    });
    socket.on("message", (data) {
      message.insert(0, LiveStreamChatModel.fromJson(data));
      // message.value = List<LiveStreamChatModel>.from(message.toSet());
      message.value =
          message.fold<List<LiveStreamChatModel>>([], (list, element) {
        if (!list.any((obj) => obj.uid == element.uid)) {
          list.add(element);
        }
        return list;
      });
      log(message.toString(), name: "ChatMessages");
    });
    socket.on("like", (data) {
      likes.insert(0, data["uid"]);
      likes.value = List<int>.from(likes.toSet());
      likes.refresh();
      update([(room)]);
    });
    socket.onConnectError((data) => print('Error: $data'));
  }

  sendLiveMessage(
      {required String userId,
      required String msg,
      required String room}) async {
    socket.emit("chatMessage", {"userId": userId, "msg": msg, "room": room});
  }

  likeStream({required int uid, required String room}) async {
    socket.emit("like", {"uid": uid, "room": room});
  }

  connect() async {
    loader.value = true;
    _page = 0.obs;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    // var token = prefs.getString('AccessToken');
    socket = IO.io(ApiRoutes.liveBaseURL, <String, dynamic>{
      'Connection': 'upgrade',
      'Upgrade': 'websocket',
      "transports": ["websocket"],
      "autoConnect": true,
      // 'auth': {'token': '$token'}
    });
    messages = RxList([]);
    groupList = Rxn({
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day):
          []
    });
    socket.disconnect();
    socket.connect();

    socket.onConnect((val) {
      log('message onConnect');
      log("chatID -${chatId.value}");
      socket.emit("JOIN_ROOM", {
        "chatId": "${chatId.value}",
        "role": Type.user.name,
      });
    });

    socket.on("NEW_MESSAGE", (data) {
      log('data $data', name: 'received message');
      try {
        final val = MessageModel.fromJson(data);
        if (val.senderType == Type.user) {
          groupList.value?.forEach((key, value) {
            if (key ==
                DateTime(val.createdAt?.year ?? 0, val.createdAt?.month ?? 0,
                    val.createdAt?.day ?? 0)) {
              final index =
                  value.indexWhere((element) => element?.tempId == val.tempId);
              value[index] = val;
            }
          });

          log(data.toString());

          update([(chatId.value ?? '')]);
        } else {
          final date = DateTime(val.createdAt?.year ?? 0,
              val.createdAt?.month ?? 0, val.createdAt?.day ?? 0);
          if ((groupList.value?.length ?? 0) > 0) {
            groupList.value?.forEach((key, value) {
              if (key == date) {
                if (value.singleWhere(
                      (element) => element?.id == val.id,
                      orElse: () => null,
                    ) ==
                    null) value.add(val);
              }
            });
          } else {
            if (groupList.value?[date] == null) {
              groupList.value?[date] = [];
            }
            if (groupList.value?[date]?.any((t) => t?.id == val.id) != true) {
              groupList.value?[date]?.add(val);
            }
          }
          // messages.value = messages.value.reversed.toList();
          // messages.add(newMessage);
          // messages.value = messages.value.reversed.toList();
          update([(chatId.value ?? '')]);
        }
      } catch (e) {
        log(e.toString());
      }
    });

    socket.on("READ_MESSAGE", (data) {
      log('data $data', name: 'read message');
      try {
        final val = MessageModel.fromJson(data);
        groupList.value?.forEach((key, value) {
          if (key ==
              DateTime(val.createdAt?.year ?? 0, val.createdAt?.month ?? 0,
                  val.createdAt?.day ?? 0)) {
            final index = value.indexWhere((element) => element?.id == val.id);
            value[index] = val;
          }
        });
        log(data.toString());

        update([(chatId.value ?? '')]);
      } catch (e) {
        log(e.toString());
      }
    });

    socket.on("DELIVERED_MESSAGE", (data) {
      log('data $data', name: 'delivered message');
      try {
        final val = MessageModel.fromJson(data);
        groupList.value?.forEach((key, value) {
          if (key ==
              DateTime(val.createdAt?.year ?? 0, val.createdAt?.month ?? 0,
                  val.createdAt?.day ?? 0)) {
            final index = value.indexWhere((element) => element?.id == val.id);
            value[index] = val;
          }
        });
        log(data.toString());

        update([(chatId.value ?? '')]);
      } catch (e) {
        log(e.toString());
      }
    });

    socket.on("SENT_MESSAGE", (data) {
      log('data $data', name: 'sent message');
      try {
        final val = MessageModel.fromJson(data);
        groupList.value?.forEach((key, value) {
          if (key ==
              DateTime(val.createdAt?.year ?? 0, val.createdAt?.month ?? 0,
                  val.createdAt?.day ?? 0)) {
            final index = value.indexWhere((element) => element?.id == val.id);
            value[index] = val;
          }
        });
        update([(chatId.value ?? '')]);
      } catch (e) {
        log(e.toString());
      }
    });

    socket.on("DELETE_MESSAGE", (data) {
      try {
        final val = MessageModel.fromJson(data);
        groupList.value?.forEach((key, value) {
          if (key ==
              DateTime(val.createdAt?.year ?? 0, val.createdAt?.month ?? 0,
                  val.createdAt?.day ?? 0)) {
            value.removeWhere((element) => element?.id == val.id);
            if (value.isEmpty) {
              groupList.value?.remove(key);
            }
          }
        });
        // messages.removeWhere((element) => element.id == val.id);
        // final index = messages.value.indexWhere((element) => element.id == val.id);
        // messages.value[index] = val;
        update([(chatId.value ?? '')]);
      } catch (e) {
        log(e.toString());
      }
    });

    socket.on("TYPING_STATUS", (data) {
      log('data $data', name: 'typing message');
      log(data.toString());
      //userTyping => trainerTyping
      if (data['trainerTyping'] == true) {
        typing.value = true;
      } else if (data['trainerTyping'] == false) {
        typing.value = false;
      }
    });

    socket.on("ONLINE_STATUS", (data) {
      log(data.toString());

      ///
      ///Switch for trainer and User apps
      ///
      if (data != null) {
        status.value = data['isTrainerOnline'] ?? false;
        lastSeen.value =
            DateTime.tryParse((data['lastSeenTrainer'] ?? '').toString());
      }
      if (status == false) {
        typing.value = false;
      }
    });

    socket.on("ALL_MESSAGES", (chat) {
      log('data $chat', name: 'all message');
      final data = chat['chats'];
      messages.value = [];
      final history = List<MessageModel>.from(
          data.map((msg) => MessageModel.fromJson(msg)));
      if (history.isNotEmpty) {
        increasePage(chat['currentPage']);
      }
      messages.addAll(history);
      for (int i = 0; i < messages.length; i++) {
        final item = messages.elementAt(i);
        DateTime date = DateTime(item.createdAt?.year ?? 0,
            item.createdAt?.month ?? 0, item.createdAt?.day ?? 0);
        if (groupList.value?[date] == null) {
          groupList.value?[date] = [];
        }
        if (groupList.value?[date]?.any((t) => t?.id == item.id) != true) {
          groupList.value?[date]?.add(item);
        }
        groupList.value?[date]?.sort((a, b) => (a?.createdAt ?? DateTime.now())
            .compareTo(b?.createdAt ?? DateTime.now()));
      }
      update([(chatId.value ?? '')]);
      loader.value = false;
      loadingChat.value = false;
    });

    // socket.on("GET_CALL", (newMessage) {
    //   log("$newMessage", name: "newMessage");

    //   if (newMessage != [] &&
    //       newMessage[0]['userIds'] != null &&
    //       newMessage[0]['userIds'].isNotEmpty) {
    //     agoraController.isCallActive.value = true;
    //     isVideoCallScreen.value = true;
    //     agoraController.channelName.value = newMessage[0]['channelName'];
    //     agoraController.uid.value = newMessage[0]['uid'].toString();
    //   }
    // });

    // socket.on("CANCEL_CALL", (newMessage) {
    //   agoraController.isCallActive.value = false;
    //   isVideoCallScreen.value = false;
    //   agoraController.channelName.value = "";
    //   agoraController.uid.value = "";
    //   agoraController.isCallActive.refresh();
    //   isVideoCallScreen.refresh();
    // });

    // socket.emit("GET_CALL", {"chatId": "$chatId", "userId": senderId});

    socket.onConnectError((data) {
      print('Error: $data');
    });
  }

  disconnect() async {
    socket.emit("LEAVE_ROOM", {"chatId": "$chatId", "role": Type.user.name});
    update([]);
  }

  Future<void> getMessages() async {
    loadingChat.value = true;
    socket.emit(
        'ALL_MESSAGES', {"chatId": "$chatId", "skip": page * 25, "limit": 25});
  }

  Future<void> deleteMessage(String messageId) async {
    socket.emit("DELETE_MESSAGE", {
      "chatId": chatId.value,
      "role": Type.user.name,
      "messageId": messageId
    });
  }

  Future<void> sendMessage(String message) async {
    sending.value = true;
    String messageType = "";
    String filePath = "";
    // String? url;
    try {
      if (pickedFile.value != null) {
        userWantToSendMedia.value = true;
        mediaIsUploading.value = true;
        fileName.value = pickedFile.value?.name ?? '';
        filePath = pickedFile.value?.path ?? '';

        String? fileExtension = lookupMimeType(filePath);
        if (fileExtension != null) {
          if (fileExtension.startsWith("audio")) {
            messageType = "audio";
          } else if (fileExtension.startsWith("image")) {
            messageType = "image";
          } else if (fileExtension.startsWith("video")) {
            messageType = "video";
          } else {
            messageType = "file";
          }
        } else {
          messageType = "file";
        }
        // url = await firebaseService.uploadFile(
        //     File(pickedFile.value?.path ?? ''), fileName.value);
      }
      final messageData = MessageModel(
              chatId: chatId.value,
              message: message,
              role: Type.user,
              isMedia: pickedFile.value == null ? null : true,
              //mediaUrl: url,
              mediaType: messageType,
              tempId: Uuid().v4())
          .toJson();
      messageData.removeWhere((key, value) => value == null);
      socket.emit("NEW_MESSAGE", messageData);
      MessageModel val = MessageModel.fromJson(messageData);
      val.senderType = Type.user;
      final day = DateTime(
          DateTime.now().year, DateTime.now().month, DateTime.now().day);
      if (groupList.value?.containsKey(day) ?? false) {
        groupList.value?[day]?.add(val);
      } else {
        groupList.value?.putIfAbsent(day, () => [val]);
      }
      refresh();
      update([(chatId.value ?? '')]);
    } catch (e) {
      log(e.toString());
    } finally {
      mediaIsUploading.value = false;
      userWantToSendMedia.value = false;
      pickedFile.value = null;
      sending.value = false;
    }
  }

  void typingStatus(bool status) {
    //userTyping => trainerTyping
    socket.emit("TYPING_STATUS", {
      "chatId": chatId.value,
      "userTyping": status,
    });
  }

  void readMessage(String messageId) {
    //userTyping => trainerTyping
    socket
        .emit("READ_MESSAGE", {"chatId": chatId.value, "messageId": messageId});
  }

  void sentMessage(String messageId) {
    //userTyping => trainerTyping
    socket
        .emit("SENT_MESSAGE", {"chatId": chatId.value, "messageId": messageId});
  }

  setChatId() async {
    _page = 0.obs;
    chatId.value = '64b4d69f174b60cfaa902a8a-63240e511d21b33dac2e9592';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('chatId',
        chatId.value ?? '64b4d69f174b60cfaa902a8a-63240e511d21b33dac2e9592');
    log(prefs.get('chatId').toString());
  }

  removeChatId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.remove('chatId');
    log("done");
  }

  Future<bool> saveFile(String url, String fileName) async {
    try {
      //FlutterDownloader.registerCallback(downloadCallback);
      try {
        if (Platform.isAndroid) {
          await Permission.storage.request();

          String? path;
          final Directory appDir = await getApplicationDocumentsDirectory();
          final _appDocDirFolder = Directory(appDir.path);
          if (await _appDocDirFolder.exists()) {
            //if folder already exists return path
            path = _appDocDirFolder.path;
          } else {
            //if folder not exists create folder and then return its path
            final Directory _appDocDirNewFolder =
                await _appDocDirFolder.create(recursive: true);
            path = _appDocDirNewFolder.path;
          }
          Dio dio = Dio();
          dio.download(url, path + "/" + fileName,
              onReceiveProgress: (received, total) {
            downloadProgress.value = ((received / total));
            if (((received / total) * 100).floor() == 100) {
              checkFileExistence(fileName);
            }
          });
        } else {
          String? path;
          final Directory _appDocDir = Directory(
              (await getTemporaryDirectory()).path + '/fitbasix/media');

          //App Document Directory + folder name
          if ((await _appDocDir.exists())) {
            path = _appDocDir.path;
          } else {
            _appDocDir.create();
            path = _appDocDir.path;
          }
          Dio dio = Dio();
          dio.download(url, path + "/" + fileName,
              onReceiveProgress: (received, total) {
            downloadProgress.value = ((received / total));
            if (((received / total) * 100).floor() == 100) {
              checkFileExistence(fileName);
            }
          });
        }
      } catch (e) {}

      return false;
    } on PlatformException catch (e) {
      log('$e');
      return false;
      // Some error occurred, look at the exception message for more details
    }
  }

  Future<String?> checkFileExistence(String? fileName) async {
    if (Platform.isAndroid) {
      PermissionStatus status = await Permission.storage.request();

      if (status == PermissionStatus.granted) {
        String? path;
        final downloadsPath = Directory('/storage/emulated/0/Download');
        final Directory appDir = await getApplicationDocumentsDirectory();
        final _appDocDirFolder = Directory(appDir.path);

        if (await _appDocDirFolder.exists()) {
          path = _appDocDirFolder.path;
        } else {
          //if folder not exists create folder and then return its path
          final Directory _appDocDirNewFolder =
              await _appDocDirFolder.create(recursive: true);
          path = _appDocDirNewFolder.path;
        }
        //if(File(message?.attachments![0]?.data!).existsSync())
        if (File(path + "/" + fileName!).existsSync()) {
          return path + "/$fileName";
        } else if (File(downloadsPath.path + "/" + fileName).existsSync()) {
          return downloadsPath.path + "/" + fileName;
        } else {
          return null;
        }
      }
    } else {
      String? path;
      final Directory _appDocDir =
          Directory((await getTemporaryDirectory()).path + '/fitbasix/media');
      //App Document Directory + folder name
      if ((await _appDocDir.exists())) {
        path = _appDocDir.path;
      } else {
        _appDocDir.create();
        path = _appDocDir.path;
      }
      if (File(path + "/" + fileName!).existsSync()) {
        return path + "/$fileName";
      } else {
        return null;
      }
    }
    return null;
  }

  String senderId = '';
  String userName = '';
  String senderPhoto = '';

  final firebaseService = FirebaseServices();

  String senderName = '';
  String receiverId = '';

  var fileName = ''.obs;

  var userWantToSendMedia = false.obs;
  var mediaIsUploading = false.obs;
  RxDouble uploadProgress = RxDouble(0);

  @override
  void onInit() async {
    getValues();
    chatId.listen((p0) {
      log(p0.toString());
    });
    super.onInit();
  }

  getValues() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    senderId = prefs.getString('userId') ?? "";
  }

  var messageController = TextEditingController();

  String getDayString(DateTime dateTime1, DateTime dateTime2) {
    if (dateTime2.day - dateTime1.day == 0) {
      return 'Today';
    } else if (dateTime2.day - dateTime1.day == 1) {
      return 'Yesterday';
    } else {
      return DateFormat('d MMM').format(dateTime1);
    }
  }

  // setStatusTypingTrue(BuildContext context) async {
  //   await firebaseService.setStatusTypingTrue(
  //       context: context, receiverId: receiverId, senderId: senderId);
  // }

  // setStatusTypingFalse(BuildContext context) async {
  //   await firebaseService.setStatusTypingFalse(
  //       context: context, receiverId: receiverId, senderId: senderId);
  // }

  // setStatusOnline(BuildContext context) async {
  //   await firebaseService.setStatusOnline(
  //       context: context, receiverId: receiverId, senderId: senderId);
  // }

  // setStatusOffline(BuildContext context) async {
  //   await firebaseService.setStatusOffline(
  //       context: context, receiverId: receiverId, senderId: senderId);
  // }

  // setMessageRead(BuildContext context, documentId) async {
  //   await firebaseService.setMessageRead(
  //       context: context,
  //       receiverId: receiverId,
  //       senderId: senderId,
  //       documentId: documentId);
  // }

  // sendTextMessage(BuildContext context) async {
  //   await firebaseService.sendMessage(
  //     senderId: senderId,
  //     context: context,
  //     receiverId: receiverId,
  //     messageData: MessageData(
  //       senderName: userName,
  //       senderId: senderId,
  //       senderAvatar: senderPhoto,
  //       message: messageController.text,
  //       sentAt: DateTime.now().toUtc().toString(),
  //       read: false,
  //       sent: true,
  //     ),
  //   );
  // }

  Future<void> _getStoragePermission() async {
    DeviceInfoPlugin plugin = DeviceInfoPlugin();
    AndroidDeviceInfo android = await plugin.androidInfo;
    if (android.version.sdkInt < 33) {
      if (await Permission.storage.request().isGranted) {
      } else if (await Permission.storage.request().isPermanentlyDenied) {
        await openAppSettings();
      } else if (await Permission.audio.request().isDenied) {}
    } else {
      if (await Permission.photos.request().isGranted) {
      } else if (await Permission.photos.request().isPermanentlyDenied) {
        await openAppSettings();
      } else if (await Permission.photos.request().isDenied) {}
    }
    final status = await Permission.manageExternalStorage.request();
    if (status.isDenied || status.isPermanentlyDenied || status.isRestricted) {
      throw "Please allow storage permission to upload files";
    }
  }

  Future<XFile?> sendFileMedia() async {
    _getStoragePermission();
    final data = await FilePicker.platform
        .pickFiles(type: FileType.any, allowMultiple: false);
    if (data != null) {
      return XFile(data.files.first.path ?? '', name: data.files.first.name);
    } else {
      return null;
    }
  }

  // sendMediaMessage() async {
  //   late String messageType;
  //   FilePickerResult? result =
  //       await FilePicker.platform.pickFiles(type: FileType.any);

  //   if (result != null && result.files.single.path != null) {
  //     userWantToSendMedia.value = true;
  //     mediaIsUploading.value = true;
  //     fileName.value = result.files[0].name;

  //     String? fileExtension = lookupMimeType(result.files.single.path!);
  //     if (fileExtension != null) {
  //       if (fileExtension.startsWith("audio")) {
  //         messageType = "audio";
  //       } else if (fileExtension.startsWith("image")) {
  //         messageType = "image";
  //       } else if (fileExtension.startsWith("video")) {
  //         messageType = "video";
  //       } else {
  //         messageType = "file";
  //       }
  //     }

  //     try {
  //       // var url = await firebaseService.uploadFile(
  //       //     File(result.files[0].path!), fileName.value);
  //       await firebaseService
  //           .sendMessage(
  //               context: Get.context!,
  //               receiverId: receiverId,
  //               messageData: MessageData(
  //                   senderName: userName,
  //                   senderId: senderId,
  //                   senderAvatar: senderPhoto,
  //                   message: '',
  //                   isMedia: true,
  //                   // mediaUrl: url,
  //                   mediaName: fileName.value,
  //                   mediaType: messageType,
  //                   sentAt: DateTime.now().toUtc().toString(),
  //                   read: false,
  //                   sent: true),
  //               senderId: senderId)
  //           .then((value) {
  //         mediaIsUploading.value = false;
  //         userWantToSendMedia.value = false;
  //       });
  //     } on Exception catch (e) {
  //       log('$e');
  //       mediaIsUploading.value = false;
  //       userWantToSendMedia.value = false;
  //     } on Error catch (e) {
  //       log('$e');
  //       mediaIsUploading.value = false;
  //       userWantToSendMedia.value = false;
  //     }
  //   } else {
  //     mediaIsUploading.value = false;
  //     userWantToSendMedia.value = false;
  //   }
  // }

  Future<XFile?> pickFromCamera({required bool gallery}) async {
    try {
      final ImagePicker picker = ImagePicker();
      XFile? file = await picker.pickImage(
          source: gallery ? ImageSource.gallery : ImageSource.camera);
      if (file != null) {
        return file;
      } else {
        return null;
      }
    } on PlatformException catch (e) {
      Get.rawSnackbar(message: e.message);
      return null;
    }
  }

  void sendImageFromCamera(context, {required bool gallery}) async {
    late String messageType;
    String filePath = "";
    // if (widget.conversation.value.conversationType == "user") {
    //   receiverID = (widget.conversation.value.conversationWith as User).uid;
    // } else {
    //   receiverID = (widget.conversation.value.conversationWith as Group).guid;
    // }
    // XFile? pickedFile = await pickFromCamera(gallery: gallery);
    if (pickedFile.value != null) {
      userWantToSendMedia.value = true;
      mediaIsUploading.value = true;
      fileName.value = pickedFile.value?.name ?? '';
      filePath = pickedFile.value?.path ?? '';

      String? fileExtension = lookupMimeType(filePath);
      if (fileExtension != null) {
        if (fileExtension.startsWith("audio")) {
          messageType = "audio";
        } else if (fileExtension.startsWith("image")) {
          messageType = "image";
        } else if (fileExtension.startsWith("video")) {
          messageType = "video";
        } else {
          messageType = "file";
        }
      }

      try {
        // var url =
        //     await firebaseService.uploadFile(File(filePath), fileName.value);
        // firebaseService.sendMessage(
        //     context: Get.context!,
        //     receiverId: receiverId,
        //     messageData: MessageData(
        //         senderName: userName,
        //         senderId: senderId,
        //         senderAvatar: senderPhoto,
        //         message: '',
        //         isMedia: true,
        //         // mediaUrl: url,
        //         mediaType: messageType,
        //         sentAt: DateTime.now().toUtc().toString(),
        //         read: false,
        //         sent: true),
        //     senderId: senderId);
        mediaIsUploading.value = false;
        userWantToSendMedia.value = false;
      } on Exception catch (_) {
        mediaIsUploading.value = false;
        userWantToSendMedia.value = false;
      } on Error catch (_) {
        mediaIsUploading.value = false;
        userWantToSendMedia.value = false;
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Pick a image first")));
    }
  }
}

const String dateFormatter = 'MMMM dd, y';

extension DateHelper on DateTime {
  String formatDate() {
    final formatter = DateFormat(dateFormatter);
    return formatter.format(this);
  }

  bool isSameDate(DateTime other) {
    return this.year == other.year &&
        this.month == other.month &&
        this.day == other.day;
  }

  int getDifferenceInDaysWithNow() {
    final now = DateTime.now();
    return now.difference(this).inDays;
  }
}
