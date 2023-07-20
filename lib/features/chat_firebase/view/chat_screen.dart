import 'dart:developer';
import 'dart:io';
import 'package:fitbasix_chat/core/constants/app_colors.dart';
import 'package:fitbasix_chat/core/constants/image_path.dart';
import 'package:fitbasix_chat/core/constants/logs.dart';
import 'package:fitbasix_chat/core/responsive/size_config.dart';
import 'package:fitbasix_chat/features/chat_firebase/controller/firebase_chat_controller.dart';
import 'package:fitbasix_chat/features/chat_firebase/view/chat_page.dart';
import 'package:fitbasix_chat/features/chat_firebase/view/widgets/customized_circular_indicator.dart';
import 'package:fitbasix_chat/features/chat_firebase/view/widgets/message_widget.dart';
import 'package:fitbasix_chat/features/chat_firebase/view/widgets/send_message_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:path/path.dart' as path;
import 'package:fitbasix_chat/features/chat_firebase/model/message_model.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with WidgetsBindingObserver {
  final FirebaseChatController chatController =
      Get.put(FirebaseChatController());
  final TextEditingController controller = TextEditingController();
  final focusNode = FocusNode();
  final ScrollController scrollController = ScrollController();
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => chatController.isChatScreen.value = true);
    chatController.loader.value = true;
    chatController.setChatId();
    chatController.connect();
    WidgetsBinding.instance.addObserver(this);
    scrollController.addListener(_scrollListener);
  }

  _scrollListener() async {
    if (scrollController.position.pixels >=
            (scrollController.position.maxScrollExtent * 0.75) &&
        chatController.loadingChat.value == false) {
      await chatController.getMessages();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        chatController.setChatId();
        chatController.connect();
        break;
      case AppLifecycleState.inactive:
        focusNode.unfocus();
        chatController.removeChatId();
        chatController.disconnect();
        break;
      case AppLifecycleState.paused:
        focusNode.unfocus();
        chatController.removeChatId();
        chatController.disconnect();
        break;
      case AppLifecycleState.detached:
        focusNode.unfocus();
        chatController.removeChatId();
        chatController.disconnect();
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => chatController.isChatScreen.value = false);
    chatController.typingStatus(false);
    chatController.removeChatId();
    chatController.disconnect();
    scrollController.dispose();
    Get.delete<FirebaseChatController>()
        .then((value) => chatController.socket.dispose());
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        log(
            "${(chatController.pickedFile.value?.path ?? '')}" +
                " Extension: ${path.extension(chatController.pickedFile.value?.path ?? '')}",
            name: "Selected File Path");
        return chatController.loader.value
            ? Center(child: CustomizedCircularProgress())
            : Scaffold(
                backgroundColor: AppColors.kPureBlack,
                appBar: AppbarforChat(
                  onTrainerTap: () async {
                    // TrainerController _trainerController = Get.find();
                    // if (true) {
                    //   _trainerController.atrainerDetail.value =
                    //       TrainerModel.Trainer();

                    //   _trainerController.isProfileLoading.value = true;
                    //   _trainerController.isMyTrainerProfileLoading.value = true;
                    //   Navigator.pushNamed(
                    //       context, RouteName.trainerProfileScreen);

                    //   var result = await TrainerServices.getATrainerDetail(
                    //       trainerId: chatController.receiverID.value ?? '');
                    //   if (result.response?.data != null) {
                    //     _trainerController.atrainerDetail.value =
                    //         result.response?.data ?? TrainerModel.Trainer();
                    //   }

                    //   _trainerController.planModel.value =
                    //       await TrainerServices.getPlanByTrainerId(
                    //           chatController.receiverID.value ?? '',
                    //           _trainerController.currentPlanType);
                    //   _trainerController.isPlanLoading.value = true;
                    //   _trainerController.initialPostData.value =
                    //       await TrainerServices.getTrainerPosts(
                    //           chatController.receiverID.value ?? '', 0);
                    //   _trainerController.isMyTrainerProfileLoading.value =
                    //       false;
                    //   _trainerController.loadingIndicator.value = false;
                    //   if ((_trainerController
                    //               .initialPostData.value.response?.data ??
                    //           [])
                    //       .isNotEmpty) {
                    //     _trainerController.trainerPostList.value =
                    //         _trainerController
                    //                 .initialPostData.value.response?.data ??
                    //             [];
                    //   } else {
                    //     _trainerController.trainerPostList.clear();
                    //   }
                    //   _trainerController.isProfileLoading.value = false;
                    //   _trainerController.isMyTrainerProfileLoading.value =
                    //       false;
                    // }
                  },
                  onHangUpTapped: (value) async {},
                  onMenuTap: () {},
                  parentContext: context,
                  trainertitle: chatController.senderName.capitalize ?? '',
                  trainerstatus: '',
                  trainerProfilePicUrl: chatController.senderPhoto,
                  chatId: "",
                  id: "",
                  status: chatController.status.value,
                  lastSeen: chatController.lastSeen.value,
                  // trainerProfilePicUrl: _chatController.senderPhoto,
                ),
                body: imageExtensions.contains(path
                        .extension(chatController.pickedFile.value?.path ?? ''))
                    ? Column(
                        children: [
                          Expanded(
                            child: Container(
                              child: Image.file(File(
                                  chatController.pickedFile.value?.path ?? '')),
                            ),
                          ),
                          SendMessageToolBar(
                            focusNode: focusNode,
                            chatController: chatController,
                            controller: controller,
                          ),
                          SizedBox(
                            height: 15 * SizeConfig.heightMultiplier!,
                          )
                        ],
                      )
                    : Column(
                        children: [
                          GetBuilder<FirebaseChatController>(
                              id: chatController.chatId.value,
                              builder: (_) => Expanded(
                                      child: GestureDetector(
                                    onTap: () {
                                      focusNode.unfocus();
                                    },
                                    child: ListView.separated(
                                      controller: scrollController,
                                      reverse: true,
                                      keyboardDismissBehavior:
                                          ScrollViewKeyboardDismissBehavior
                                              .onDrag,
                                      shrinkWrap: true,
                                      itemCount: chatController
                                              .groupList.value?.keys.length ??
                                          0,
                                      physics: ClampingScrollPhysics(),
                                      itemBuilder: (context, index) {
                                        final data = chatController
                                            .groupList.value?.values
                                            .elementAt(index);
                                        return Column(
                                          children: [
                                            if (data?.isNotEmpty ?? false)
                                              Padding(
                                                padding: EdgeInsets.all(8.0 *
                                                    SizeConfig
                                                        .imageSizeMultiplier!),
                                                child: Text(
                                                    chatController.getDayString(
                                                        chatController.groupList
                                                                .value?.keys
                                                                .elementAt(
                                                                    index) ??
                                                            DateTime.now(),
                                                        DateTime.now())),
                                              ),
                                            ListView.separated(
                                              separatorBuilder:
                                                  (context, index) => SizedBox(
                                                height: 8 *
                                                    SizeConfig
                                                        .heightMultiplier!,
                                              ),
                                              itemBuilder: (context, i) {
                                                final messages =
                                                    data?.elementAt(i);
                                                //Mark as Sent for the user
                                                if (messages?.id != null) {
                                                  if ((messages?.senderType ==
                                                          Type.user) &&
                                                      ((messages?.isSent ??
                                                              false) ==
                                                          false)) {
                                                    chatController.sentMessage(
                                                        messages?.id ?? '');
                                                  }
                                                  //Mark as Read for the user on trainerSide
                                                  if ((messages?.senderType ==
                                                          Type.trainer) &&
                                                      ((messages?.isRead ??
                                                              false) ==
                                                          false)) {
                                                    chatController.readMessage(
                                                        messages?.id ?? '');
                                                  }
                                                }
                                                return MessageTileWidget(
                                                  messageId: messages?.id ?? '',
                                                  senderImage: chatController
                                                      .senderPhoto,
                                                  sender:
                                                      messages?.senderType ==
                                                          Type.user,
                                                  message:
                                                      messages?.message ?? '',
                                                  isRead:
                                                      messages?.isRead ?? false,
                                                  isSent:
                                                      messages?.isSent ?? false,
                                                  isDelivered:
                                                      messages?.isDelivered ??
                                                          false,
                                                  isMedia: messages?.isMedia ??
                                                      false,
                                                  mediaType:
                                                      messages?.mediaType ?? '',
                                                  mediaUrl:
                                                      messages?.mediaUrl ?? '',
                                                  createdAt:
                                                      messages?.createdAt ??
                                                          DateTime.now(),
                                                );
                                              },
                                              physics: ClampingScrollPhysics(),
                                              shrinkWrap: true,
                                              itemCount: data?.length ?? 0,
                                            ),
                                          ],
                                        );
                                      },
                                      separatorBuilder: (context, index) =>
                                          SizedBox(
                                        height:
                                            8 * SizeConfig.heightMultiplier!,
                                      ),
                                    ),
                                  ))),
                          if (chatController.typing.value)
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10 * SizeConfig.widthMultiplier!),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: Lottie.asset(ImagePath.typing,
                                    height: 55 * SizeConfig.heightMultiplier!),
                              ),
                            ),
                          SendMessageToolBar(
                            focusNode: focusNode,
                            chatController: chatController,
                            controller: controller,
                          ),
                          SizedBox(
                            height: 15 * SizeConfig.heightMultiplier!,
                          )
                        ],
                      ),
              );
      },
    );
  }
}
