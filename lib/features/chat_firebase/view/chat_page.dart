// // ignore_for_file: must_be_immutable

import 'dart:developer';
import 'package:fitbasix_chat/core/constants/app_colors.dart';
import 'package:fitbasix_chat/core/constants/app_text_styles.dart';
import 'package:fitbasix_chat/core/constants/image_path.dart';
import 'package:fitbasix_chat/core/responsive/size_config.dart';
import 'package:fitbasix_chat/features/chat_firebase/controller/firebase_chat_controller.dart';
import 'package:fitbasix_chat/features/chat_firebase/model/chat_model.dart';
import 'package:fitbasix_chat/features/chat_firebase/view/media_message_widget.dart';
import 'package:fitbasix_chat/features/chat_firebase/view/message_data_widget.dart';
import 'package:fitbasix_chat/features/chat_firebase/view/widgets/capitalizeText.dart';
import 'package:fitbasix_chat/features/chat_firebase/view/widgets/image_viewer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

// class ChatPage extends StatefulWidget {
//   const ChatPage({Key? key}) : super(key: key);

//   @override
//   State<ChatPage> createState() => _ChatPageState();
// }

// class _ChatPageState extends State<ChatPage> with WidgetsBindingObserver {
//   final _chatController = Get.find<FirebaseChatController>();
//   var firstLoad = true;
//   final focusNode = FocusNode();

//   chatId() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     var senderId = prefs.getString('userId') ?? "";
//     prefs.setString('chatId', "chat_$senderId");
//     log(prefs.get('chatId').toString());
//   }

//   @override
//   void initState() {
//     focusNode.addListener(() {
//       if (focusNode.hasFocus) {
//         _chatController.setStatusTypingTrue(context);
//       } else {
//         _chatController.setStatusTypingFalse(context);
//       }
//     });
//     WidgetsBinding.instance.addObserver(this);
//     chatId();
//     FirebaseFirestore.instance
//         .collection('chats')
//         .doc(_chatController.firebaseService.getChatRoomId(
//             _chatController.senderId, _chatController.receiverId))
//         .collection('messages')
//         .snapshots()
//         .listen((event) {
//       setState(() {});
//     });
//     _chatController.setStatusOnline(context);
//     super.initState();
//   }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) async {
//     switch (state) {
//       case AppLifecycleState.resumed:
//         _chatController.setStatusOnline(context);
//         break;
//       case AppLifecycleState.inactive:
//         focusNode.unfocus();
//         _chatController.setStatusOffline(context);
//         break;
//       case AppLifecycleState.paused:
//         focusNode.unfocus();
//         _chatController.setStatusOffline(context);
//         break;
//       case AppLifecycleState.detached:
//         focusNode.unfocus();
//         _chatController.setStatusOffline(context);
//         break;
//     }
//   }

//   @override
//   void dispose() async {
//     focusNode.dispose();
//     WidgetsBinding.instance.removeObserver(this);
//     remove();
//     _chatController.setStatusOffline(context);
//     super.dispose();
//   }

//   remove() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     prefs.remove('chatId');
//     log("done");
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         backgroundColor: AppColors.kPureBlack,
//         appBar: AppbarforChat(
//           onHangUpTapped: (value) async {},
//           onMenuTap: () {},
//           parentContext: context,
//           trainertitle:
//               CapitalizeFunction.capitalize(_chatController.senderName),
//           trainerstatus: '',
//           trainerProfilePicUrl: _chatController.senderPhoto,
//           chatId: _chatController.firebaseService.getChatRoomId(
//               _chatController.senderId, _chatController.receiverId),
//           id: _chatController.receiverId,
//           // trainerProfilePicUrl: _chatController.senderPhoto,
//         ),
//         body: GestureDetector(
//           onTap: () {
//             focusNode.unfocus();
//           },
//           child: SafeArea(
//             child: Column(
//               children: [
//                 GetBuilder<FirebaseChatController>(
//                     id: 'message-list',
//                     builder: (_chatController) {
//                       return StreamBuilder<QuerySnapshot>(
//                           stream:
//                               _chatController.firebaseService.getMessageStream(
//                             chatId: _chatController.firebaseService
//                                 .getChatRoomId(_chatController.senderId,
//                                     _chatController.receiverId),
//                           ),
//                           builder: (context, snapshot) {
//                             if (snapshot.connectionState ==
//                                 ConnectionState.waiting) {
//                               if (!firstLoad) {
//                                 return Expanded(
//                                   child: Container(
//                                     color: Colors.transparent,
//                                     child: ListView.builder(
//                                       keyboardDismissBehavior:
//                                           ScrollViewKeyboardDismissBehavior
//                                               .manual,
//                                       physics: const BouncingScrollPhysics(),
//                                       reverse: true,
//                                       // to display loading tile if more items
//                                       itemCount:
//                                           snapshot.data?.docs.length ?? 0,
//                                       itemBuilder:
//                                           (BuildContext context, int index) {
//                                         return MessageData.fromJson(snapshot
//                                                         .data?.docs[index]
//                                                         .data()
//                                                     as Map<String, dynamic>)
//                                                 .isMedia
//                                             ? MediaMessageWidget(
//                                                 passedMessage:
//                                                     MessageData.fromJson(
//                                                         snapshot.data
//                                                                 ?.docs[index]
//                                                                 .data()
//                                                             as Map<String,
//                                                                 dynamic>))
//                                             : MessageTile(
//                                                 index: index,
//                                                 messageList:
//                                                     snapshot.data?.docs ?? [],
//                                               );
//                                       },
//                                     ),
//                                   ),
//                                 );
//                               } else {
//                                 firstLoad = false;
//                                 return Expanded(
//                                   child: Shimmer.fromColors(
//                                     baseColor:
//                                         const Color.fromARGB(0, 255, 255, 255)
//                                             .withOpacity(0.1),
//                                     highlightColor:
//                                         const Color.fromARGB(1, 255, 255, 255)
//                                             .withOpacity(0.46),
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.start,
//                                       children: [
//                                         const Spacer(),
//                                         Container(
//                                           margin: EdgeInsets.only(
//                                               left: 16 *
//                                                   SizeConfig.widthMultiplier!),
//                                           height:
//                                               28 * SizeConfig.heightMultiplier!,
//                                           width:
//                                               176 * SizeConfig.widthMultiplier!,
//                                           color: const Color(0xff3646464),
//                                         ),
//                                         SizedBox(
//                                           height:
//                                               8 * SizeConfig.heightMultiplier!,
//                                         ),
//                                         Container(
//                                           margin: EdgeInsets.only(
//                                               left: 16 *
//                                                   SizeConfig.widthMultiplier!),
//                                           height:
//                                               49 * SizeConfig.heightMultiplier!,
//                                           width:
//                                               215 * SizeConfig.widthMultiplier!,
//                                           color: const Color(0xff3646464),
//                                         ),
//                                         SizedBox(
//                                           height:
//                                               8 * SizeConfig.heightMultiplier!,
//                                         ),
//                                         Container(
//                                           margin: EdgeInsets.only(
//                                               left: 16 *
//                                                   SizeConfig.widthMultiplier!),
//                                           height:
//                                               28 * SizeConfig.heightMultiplier!,
//                                           width:
//                                               176 * SizeConfig.widthMultiplier!,
//                                           color: const Color(0xff3646464),
//                                         ),
//                                         SizedBox(
//                                             height: 16 *
//                                                 SizeConfig.heightMultiplier!),
//                                         Align(
//                                           alignment: Alignment.centerRight,
//                                           child: Container(
//                                             margin: EdgeInsets.only(
//                                                 right: 16 *
//                                                     SizeConfig
//                                                         .widthMultiplier!),
//                                             height: 42 *
//                                                 SizeConfig.heightMultiplier!,
//                                             width: 191 *
//                                                 SizeConfig.widthMultiplier!,
//                                             color: const Color(0xff3646464),
//                                           ),
//                                         ),
//                                         SizedBox(
//                                             height: 16 *
//                                                 SizeConfig.heightMultiplier!),
//                                         Container(
//                                           margin: EdgeInsets.only(
//                                               left: 16 *
//                                                   SizeConfig.widthMultiplier!),
//                                           height:
//                                               28 * SizeConfig.heightMultiplier!,
//                                           width:
//                                               176 * SizeConfig.widthMultiplier!,
//                                           color: const Color(0xff3646464),
//                                         ),
//                                         SizedBox(
//                                             height: 16 *
//                                                 SizeConfig.heightMultiplier!),
//                                         Align(
//                                           alignment: Alignment.centerRight,
//                                           child: Container(
//                                             margin: EdgeInsets.only(
//                                                 right: 16 *
//                                                     SizeConfig
//                                                         .widthMultiplier!),
//                                             height: 78 *
//                                                 SizeConfig.heightMultiplier!,
//                                             width: 232 *
//                                                 SizeConfig.widthMultiplier!,
//                                             color: const Color(0xff3646464),
//                                           ),
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 );
//                               }
//                             } else {
//                               return Expanded(
//                                 child: GetBuilder<FirebaseChatController>(
//                                     id: 'messages',
//                                     builder: (context) {
//                                       return ListView.builder(
//                                         physics: const BouncingScrollPhysics(),
//                                         reverse: true,
//                                         keyboardDismissBehavior:
//                                             ScrollViewKeyboardDismissBehavior
//                                                 .onDrag,
//                                         // to display loading tile if more items
//                                         itemCount: snapshot.data?.docs.length,
//                                         itemBuilder:
//                                             (BuildContext context, int index) {
//                                           if (MessageData.fromJson(snapshot
//                                                               .data?.docs[index]
//                                                               .data()
//                                                           as Map<String,
//                                                               dynamic>)
//                                                       .read ==
//                                                   false &&
//                                               MessageData.fromJson(snapshot
//                                                               .data?.docs[index]
//                                                               .data()
//                                                           as Map<String,
//                                                               dynamic>)
//                                                       .senderId ==
//                                                   _chatController.receiverId) {
//                                             _chatController.setMessageRead(
//                                                 context,
//                                                 snapshot.data?.docChanges
//                                                     .elementAt(index)
//                                                     .doc
//                                                     .id);
//                                           }
//                                           return MessageData.fromJson(snapshot
//                                                           .data?.docs[index]
//                                                           .data()
//                                                       as Map<String, dynamic>)
//                                                   .isMedia
//                                               ? GestureDetector(
//                                                   onTap: () {
//                                                     if (MessageData.fromJson(
//                                                                 snapshot
//                                                                         .data
//                                                                         ?.docs[
//                                                                             index]
//                                                                         .data()
//                                                                     as Map<
//                                                                         String,
//                                                                         dynamic>)
//                                                             .mediaType ==
//                                                         'image') {
//                                                       Navigator.push(
//                                                           context,
//                                                           MaterialPageRoute(
//                                                               builder: (_) => ImageViewer(
//                                                                   label: "",
//                                                                   imgUrl: MessageData.fromJson(snapshot
//                                                                           .data
//                                                                           ?.docs[
//                                                                               index]
//                                                                           .data() as Map<String, dynamic>)
//                                                                       .mediaUrl)));
//                                                     }
//                                                   },
//                                                   child: MediaMessageWidget(
//                                                       passedMessage: MessageData
//                                                           .fromJson(snapshot
//                                                                   .data
//                                                                   ?.docs[index]
//                                                                   .data()
//                                                               as Map<String,
//                                                                   dynamic>)),
//                                                 )
//                                               : MessageTile(
//                                                   index: index,
//                                                   messageList:
//                                                       snapshot.data?.docs ?? [],
//                                                 );
//                                         },
//                                       );
//                                     }),
//                               );
//                             }
//                           });
//                     }),
//                 StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//                   stream: FirebaseFirestore.instance
//                       .collection('chats')
//                       .doc(_chatController.firebaseService.getChatRoomId(
//                           _chatController.senderId, _chatController.receiverId))
//                       .snapshots(),
//                   builder: (context, AsyncSnapshot snapshot) {
//                     if (snapshot.hasData) {
//                       Map<String, dynamic> check = snapshot.data.data() ?? {};
//                       log(check.toString());
//                       if (check.containsKey(
//                               'typing_${_chatController.receiverId}') ==
//                           true) {
//                         return snapshot.data[
//                                     'typing_${_chatController.receiverId}'] ==
//                                 true
//                             ? Padding(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal:
//                                         10 * SizeConfig.widthMultiplier!),
//                                 child: Align(
//                                   alignment: Alignment.centerLeft,
//                                   child: Lottie.asset(ImagePath.typing,
//                                       height:
//                                           55 * SizeConfig.heightMultiplier!),
//                                 ),
//                               )
//                             : Container();
//                       } else {
//                         return Container();
//                       }
//                     } else {
//                       return Container();
//                     }
//                   },
//                 ),
//                 SendMessageWidget(
//                   focusNode: focusNode,
//                 ),
//               ],
//             ),
//           ),
//         ));
//   }
// }

class AppbarforChat extends StatelessWidget implements PreferredSizeWidget {
  String? trainerProfilePicUrl;
  String? trainertitle;
  String? trainerstatus;
  String? id;
  String? chatId;
  BuildContext? parentContext;
  GestureTapCallback? onMenuTap;
  ValueChanged<bool>? onHangUpTapped;
  Function()? onTrainerTap;
  DateTime? lastSeen;
  bool status;

  AppbarforChat(
      {Key? key,
      required this.id,
      required this.chatId,
      this.trainerProfilePicUrl,
      this.trainertitle,
      this.parentContext,
      this.trainerstatus,
      this.onMenuTap,
      this.onHangUpTapped,
      this.onTrainerTap,
      this.status = false,
      this.lastSeen})
      : super(key: key);

  String time({required DateTime time}) {
    if (DateTime.now().difference(time).inDays == 0) {
      return 'Last Seen at ${DateFormat('hh:mm a').format(time)}';
    } else if (DateTime.now().difference(time).inDays > 0 &&
        DateTime.now().difference(time).inDays < 7) {
      return 'Last Seen ${DateTime.now().difference(time).inDays} days ago';
    } else if (DateTime.now().difference(time).inDays > 7 &&
        DateTime.now().difference(time).inDays < 30) {
      return 'Last Seen ${(DateTime.now().difference(time).inDays / 7).floor()} week ago';
    } else if (DateTime.now().difference(time).inDays > 30 &&
        DateTime.now().difference(time).inDays < 365) {
      return 'Last Seen ${(DateTime.now().difference(time).inDays / 30).floor()} month ago';
    } else if (DateTime.now().difference(time).inDays > 365) {
      return 'Last Seen ${(DateTime.now().difference(time).inDays / 365).floor()} year ago';
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      elevation: 0,
      title: GestureDetector(
        onTap: onTrainerTap,
        child: Row(
          children: [
            GestureDetector(
                onTap: () {
                  Navigator.pop(parentContext!);
                },
                child: Container(
                  width: 20 * SizeConfig.widthMultiplier!,
                  color: Colors.transparent,
                  child: Center(
                    child: SvgPicture.asset(
                      ImagePath.backIcon,
                      width: 7.41 * SizeConfig.widthMultiplier!,
                      height: 12 * SizeConfig.heightMultiplier!,
                      fit: BoxFit.contain,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                )),
            SizedBox(
              width: 16.59 * SizeConfig.widthMultiplier!,
            ),
            Stack(
              children: [
                CircleAvatar(
                  radius: 20 * SizeConfig.imageSizeMultiplier!,
                  backgroundImage: const NetworkImage(
                    'https://cdn-icons-png.flaticon.com/512/3135/3135715.png',
                  ),
                ),
                Positioned(
                  bottom: 1 * SizeConfig.imageSizeMultiplier!,
                  right: 0,
                  child: Container(
                    height: 8 * SizeConfig.imageSizeMultiplier!,
                    width: 8 * SizeConfig.imageSizeMultiplier!,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: status
                            ? AppColors.availableColor
                            : AppColors.unavailableColor),
                  ),
                )
              ],
            ),
            SizedBox(
              width: 12 * SizeConfig.widthMultiplier!,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(trainertitle ?? "",
                    style: AppTextStyle.hnormal600BlackText.copyWith(
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                Text(lastSeen == null ? '' : time(time: lastSeen!.toLocal()),
                    style: status
                        ? AppTextStyle.hsmallGreenText
                        : AppTextStyle.smallGreyText)
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// class MessageTile extends StatefulWidget {
//   const MessageTile({
//     Key? key,
//     required this.index,
//     required this.messageList,
//   }) : super(key: key);
//   final int index;
//   final List<QueryDocumentSnapshot<Object?>> messageList;

//   @override
//   State<MessageTile> createState() => _MessageTileState();
// }

// class _MessageTileState extends State<MessageTile> {
//   final _chatController = Get.find<FirebaseChatController>();

//   var message = MessageData(
//     senderName: '',
//     senderId: '',
//     senderAvatar: '',
//     message: '',
//     sentAt: '',
//     read: false,
//     sent: false,
//   );

//   @override
//   void initState() {
//     message = MessageData.fromJson(
//         widget.messageList[widget.index].data() as Map<String, dynamic>);
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisSize: MainAxisSize.min,
//       crossAxisAlignment: (_chatController.senderId == message.senderId)
//           ? CrossAxisAlignment.end
//           : CrossAxisAlignment.start,
//       children: [
//         if (widget.index == widget.messageList.length - 1)
//           Padding(
//             padding: EdgeInsets.symmetric(
//                 vertical: 18 * SizeConfig.heightMultiplier!),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text(
//                     _chatController.getDayString(
//                         DateTime.parse(message.sentAt).toLocal(),
//                         DateTime.now()),
//                     style: AppTextStyle.grey400Text
//                         .copyWith(fontSize: 12 * SizeConfig.textMultiplier!)),
//               ],
//             ),
//           ),
//         if (widget.messageList.length > widget.index + 1)
//           if ((DateTime.parse(message.sentAt).toLocal()).day >
//               DateTime.parse((MessageData.fromJson(
//                           widget.messageList[widget.index + 1].data()
//                               as Map<String, dynamic>)
//                       .sentAt))
//                   .toLocal()
//                   .day)
//             Padding(
//               padding: EdgeInsets.symmetric(
//                   vertical: 18 * SizeConfig.heightMultiplier!),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                       _chatController.getDayString(
//                           DateTime.parse(message.sentAt).toLocal(),
//                           DateTime.now()),
//                       style: AppTextStyle.grey400Text
//                           .copyWith(fontSize: 12 * SizeConfig.textMultiplier!)),
//                 ],
//               ),
//             ),
//         MessageWidget(
//           messageData: message,
//         ),
//       ],
//     );
//   }
// }

// class SendMessageWidget extends StatelessWidget {
//   final FocusNode focusNode;
//   const SendMessageWidget({Key? key, required this.focusNode})
//       : super(key: key);

//   bottomsheet(context, {required FirebaseChatController chatController}) async {
//     return showModalBottomSheet(
//       backgroundColor: AppColors.kBlack,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(
//           top: Radius.circular(50),
//         ),
//       ),
//       context: context,
//       builder: (context) => SizedBox(
//         height: 190 * SizeConfig.heightMultiplier!,
//         child: Container(
//           margin: const EdgeInsets.all(30),
//           child: Column(children: [
//             GestureDetector(
//               onTap: () async {
//                 Navigator.pop(context);
//                 chatController.sendImageFromCamera(context, gallery: false);
//               },
//               child: Row(
//                 children: [
//                   Container(
//                     height: 40 * SizeConfig.heightMultiplier!,
//                     width: 40 * SizeConfig.widthMultiplier!,
//                     decoration:
//                         BoxDecoration(borderRadius: BorderRadius.circular(20)),
//                     child: const Icon(
//                       Icons.camera_alt,
//                       color: AppColors.greenChatColor,
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Text(
//                     "camera".tr,
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                   )
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),
//             GestureDetector(
//               onTap: () async {
//                 Navigator.of(context).pop();
//                 chatController.sendImageFromCamera(context, gallery: true);
//               },
//               child: Row(
//                 children: [
//                   Container(
//                     height: 40 * SizeConfig.heightMultiplier!,
//                     width: 40 * SizeConfig.widthMultiplier!,
//                     decoration:
//                         BoxDecoration(borderRadius: BorderRadius.circular(20)),
//                     child: const Icon(
//                       Icons.photo,
//                       color: AppColors.greenChatColor,
//                     ),
//                   ),
//                   const SizedBox(
//                     width: 10,
//                   ),
//                   Text(
//                     "gallery".tr,
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
//                   )
//                 ],
//               ),
//             ),
//           ]),
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GetBuilder<FirebaseChatController>(
//         id: 'send-message-field',
//         builder: (_chatController) {
//           return Obx(
//             () => _chatController.userWantToSendMedia.value
//                 ? Align(
//                     alignment: Alignment.bottomCenter,
//                     child: Container(
//                       padding: EdgeInsets.all(16 * SizeConfig.widthMultiplier!),
//                       decoration: const BoxDecoration(
//                         color: Colors.transparent,
//                       ),
//                       child: Row(
//                         mainAxisSize: MainAxisSize.min,
//                         children: [
//                           Expanded(
//                             child: Container(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal:
//                                         16 * SizeConfig.widthMultiplier!,
//                                     vertical:
//                                         24 * SizeConfig.heightMultiplier!),
//                                 decoration: BoxDecoration(
//                                   color: AppColors.kBlack,
//                                   borderRadius: BorderRadius.circular(8),
//                                 ),
//                                 child: Container(
//                                   decoration: BoxDecoration(
//                                     color:
//                                         AppColors.kPureWhite.withOpacity(0.1),
//                                     borderRadius: BorderRadius.circular(8),
//                                   ),
//                                   padding: EdgeInsets.symmetric(
//                                       horizontal:
//                                           8 * SizeConfig.widthMultiplier!,
//                                       vertical:
//                                           16 * SizeConfig.heightMultiplier!),
//                                   child: Column(
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Row(
//                                         children: [
//                                           Expanded(
//                                               child: Text(
//                                             _chatController.fileName.value,
//                                             style: AppTextStyle.normalGreenText
//                                                 .copyWith(
//                                                     color:
//                                                         AppColors.kPureWhite),
//                                             overflow: TextOverflow.ellipsis,
//                                           )),
//                                           SizedBox(
//                                             width:
//                                                 7 * SizeConfig.widthMultiplier!,
//                                           ),
//                                         ],
//                                       ),
//                                       Obx(() => _chatController
//                                               .mediaIsUploading.value
//                                           ? SizedBox(
//                                               height: 21 *
//                                                   SizeConfig.heightMultiplier!)
//                                           : Container()),
//                                       Obx(() =>
//                                           _chatController.mediaIsUploading.value
//                                               ? LinearProgressIndicator(
//                                                   value: _chatController
//                                                       .uploadProgress.value,
//                                                   backgroundColor:
//                                                       Color(0xff747474),
//                                                   color: AppColors.kGreenColor)
//                                               : Container())
//                                     ],
//                                   ),
//                                 )),
//                           ),
//                         ],
//                       ),
//                     ),
//                   )
//                 : Column(
//                     children: [
//                       Align(
//                         alignment: Alignment.bottomCenter,
//                         child: Container(
//                           padding:
//                               EdgeInsets.all(16 * SizeConfig.widthMultiplier!),
//                           decoration: const BoxDecoration(
//                             color: Colors.transparent,
//                           ),
//                           child: Row(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Expanded(
//                                 child: Container(
//                                     decoration: BoxDecoration(
//                                       color: AppColors.kBlack,
//                                       borderRadius: BorderRadius.circular(8),
//                                     ),
//                                     child: TextField(
//                                       focusNode: focusNode,
//                                       inputFormatters: [],
//                                       textCapitalization:
//                                           TextCapitalization.sentences,
//                                       keyboardType: TextInputType.multiline,
//                                       onChanged: (value) {
//                                         _chatController
//                                             .update(['send-message-field']);
//                                       },
//                                       maxLines: null,
//                                       cursorColor: AppColors.kPureWhite,
//                                       style: AppTextStyle.black400Text.copyWith(
//                                           color: AppColors.kPureWhite,
//                                           height: 1.3),
//                                       controller:
//                                           _chatController.messageController,
//                                       decoration: InputDecoration(
//                                           contentPadding: EdgeInsets.only(
//                                               left: 16 *
//                                                   SizeConfig.widthMultiplier!,
//                                               top: 12 *
//                                                   SizeConfig.heightMultiplier!,
//                                               bottom: 12 *
//                                                   SizeConfig.heightMultiplier!),
//                                           hintText: "message".tr,
//                                           hintStyle:
//                                               AppTextStyle.hsmallhintText,
//                                           border: InputBorder.none,
//                                           suffixIcon: Row(
//                                             mainAxisSize: MainAxisSize.min,
//                                             children: [
//                                               SizedBox(
//                                                 width: 30 *
//                                                     SizeConfig.widthMultiplier!,
//                                                 child: IconButton(
//                                                     onPressed: _chatController
//                                                         .sendMediaMessage,
//                                                     icon: SvgPicture.asset(
//                                                       ImagePath
//                                                           .attachdocumentIcon,
//                                                       width: 9.17 *
//                                                           SizeConfig
//                                                               .widthMultiplier!,
//                                                       height: 18.34 *
//                                                           SizeConfig
//                                                               .heightMultiplier!,
//                                                     )),
//                                               ),
//                                               SizedBox(
//                                                 width: 30 *
//                                                     SizeConfig.widthMultiplier!,
//                                                 child: IconButton(
//                                                     onPressed: () {
//                                                       bottomsheet(context,
//                                                           chatController:
//                                                               _chatController);
//                                                     },
//                                                     icon: SvgPicture.asset(
//                                                       ImagePath.openCameraIcon,
//                                                       width: 15 *
//                                                           SizeConfig
//                                                               .widthMultiplier!,
//                                                       height: 13.57 *
//                                                           SizeConfig
//                                                               .heightMultiplier!,
//                                                     )),
//                                               ),
//                                               SizedBox(
//                                                 width: 5 *
//                                                     SizeConfig.widthMultiplier!,
//                                               ),
//                                             ],
//                                           )),
//                                       // maxLines: 3,
//                                     )),
//                               ),
//                               if (_chatController
//                                   .messageController.text.isNotEmpty)
//                                 Padding(
//                                   padding: EdgeInsets.only(
//                                       left: 23 * SizeConfig.widthMultiplier!),
//                                   child: GestureDetector(
//                                       onTap: () {
//                                         //focusNode.unfocus();
//                                         _chatController
//                                             .sendTextMessage(context);
//                                         _chatController.messageController
//                                             .clear();
//                                         _chatController.update([
//                                           'send-message-field',
//                                           'message-list'
//                                         ]);
//                                       },
//                                       child: Icon(
//                                         Icons.send,
//                                         size: 21 * SizeConfig.heightMultiplier!,
//                                         color: AppColors.greenChatColor,
//                                       )),
//                                 ),
//                             ],
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//           );
//         });
//   }
// }
