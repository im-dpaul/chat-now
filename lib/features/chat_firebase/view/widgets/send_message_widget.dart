import 'dart:developer';

import 'package:fitbasix_chat/core/constants/app_colors.dart';
import 'package:fitbasix_chat/core/constants/app_text_styles.dart';
import 'package:fitbasix_chat/core/responsive/size_config.dart';
import 'package:fitbasix_chat/features/chat_firebase/controller/firebase_chat_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';

class SendMessageToolBar extends StatelessWidget {
  final FirebaseChatController chatController;
  final TextEditingController controller;
  final FocusNode focusNode;
  const SendMessageToolBar(
      {Key? key,
      required this.chatController,
      required this.controller,
      required this.focusNode})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Padding(
        padding: EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            IconButton(
              onPressed: () {
                bottomsheet(context, chatController: chatController);
              },
              icon: Icon(Icons.attachment),
              color: AppColors.chatColor,
            ),
            Expanded(
                child: Column(
              children: [
                if (chatController.pickedFile.value != null)
                  if (!(lookupMimeType(
                              chatController.pickedFile.value?.path ?? '') ??
                          '')
                      .startsWith("image"))
                    Container(
                      padding:
                          EdgeInsets.all(8.0 * SizeConfig.widthMultiplier!),
                      margin: EdgeInsets.only(
                          bottom: 8 * SizeConfig.heightMultiplier!),
                      decoration: BoxDecoration(
                        color: AppColors.kBlack,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Icon(
                                CupertinoIcons.doc,
                                color: AppColors.chatColor,
                              ),
                              SizedBox(
                                width: 8 * SizeConfig.widthMultiplier!,
                              ),
                              Expanded(
                                  child: Text(
                                      (chatController.pickedFile.value?.name ??
                                          ''))),
                              SizedBox(
                                width: 8 * SizeConfig.widthMultiplier!,
                              ),
                              GestureDetector(
                                child: Icon(
                                  Icons.close,
                                  color: AppColors.redErrorColor,
                                ),
                                onTap: () {
                                  chatController.pickedFile.value = null;
                                },
                              )
                            ],
                          ),
                          SizedBox(
                            height: 8 * SizeConfig.heightMultiplier!,
                          ),
                          if (chatController.mediaIsUploading.value)
                            LinearProgressIndicator(
                              value: chatController.uploadProgress.value,
                              backgroundColor: Color(0xff747474),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.chatColor),
                              color: AppColors.kBlack.withOpacity(0.7),
                            )
                        ],
                      ),
                    ),
                Container(
                    decoration: BoxDecoration(
                      color: AppColors.kBlack,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: EdgeInsets.zero,
                    child: TextField(
                      focusNode: focusNode,
                      controller: controller,
                      textCapitalization: TextCapitalization.sentences,
                      onChanged: (val) {
                        if (val.length != 0) {
                          chatController.typingStatus(true);
                        } else {
                          chatController.typingStatus(false);
                        }
                      },
                      keyboardType: TextInputType.multiline,
                      style: AppTextStyle.white400Text,
                      minLines: 1,
                      maxLines: 5,
                      magnifierConfiguration: TextMagnifierConfiguration(
                          magnifierBuilder:
                              (context, controller, magnifierInfo) => null,
                          shouldDisplayHandlesInMagnifier: false),
                      decoration: InputDecoration(
                          hintText: "Type a message",
                          hintStyle: AppTextStyle.grey400Text,
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 20 * SizeConfig.widthMultiplier!,
                              vertical: 10 * SizeConfig.heightMultiplier!),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none),
                          errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none),
                          disabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none),
                          focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide.none)),
                    )),
              ],
            )),
            IconButton(
              onPressed: () {
                if (chatController.sending.value == false) {
                  if (controller.text.trim().isNotEmpty ||
                      chatController.pickedFile.value != null) {
                    chatController.sendMessage(controller.text);
                    chatController.typingStatus(false);
                    controller.clear();
                  }
                }
              },
              icon: Icon(Icons.send),
              color: AppColors.chatColor,
            )
          ],
        ),
      ),
    );
  }

  bottomsheet(context, {required FirebaseChatController chatController}) async {
    return showModalBottomSheet(
      backgroundColor: AppColors.kBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16 * SizeConfig.widthMultiplier!),
        ),
      ),
      context: context,
      builder: (context) => SizedBox(
        // height: 190 * SizeConfig.heightMultiplier!,
        child: Container(
          margin: const EdgeInsets.all(30),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            GestureDetector(
              onTap: () async {
                Navigator.pop(context);
                chatController.pickedFile.value =
                    await chatController.pickFromCamera(gallery: false);
                // chatController.sendImageFromCamera(context, gallery: false);
              },
              child: Row(
                children: [
                  Container(
                    height: 40 * SizeConfig.heightMultiplier!,
                    width: 40 * SizeConfig.widthMultiplier!,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: const Icon(
                      Icons.camera_alt,
                      color: AppColors.chatColor,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "camera".tr,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                Navigator.of(context).pop();
                final image =
                    await chatController.pickFromCamera(gallery: true);
                if (image != null) {
                  log(image.path, name: "Image Path");
                  chatController.pickedFile.value = image;
                  log(chatController.pickedFile.value!.path,
                      name: "Saved Path");
                  chatController.pickedFile.refresh();
                }
                // chatController.sendImageFromCamera(context, gallery: true);
              },
              child: Row(
                children: [
                  Container(
                    height: 40 * SizeConfig.heightMultiplier!,
                    width: 40 * SizeConfig.widthMultiplier!,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: const Icon(
                      Icons.photo,
                      color: AppColors.chatColor,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "gallery".tr,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  )
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () async {
                Navigator.of(context).pop();
                chatController.pickedFile.value =
                    await chatController.sendFileMedia();
              },
              child: Row(
                children: [
                  Container(
                    height: 40 * SizeConfig.heightMultiplier!,
                    width: 40 * SizeConfig.widthMultiplier!,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(20)),
                    child: const Icon(
                      Icons.attachment,
                      color: AppColors.chatColor,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    "File",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  )
                ],
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
