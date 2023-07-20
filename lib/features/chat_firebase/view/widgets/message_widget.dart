// ignore_for_file: deprecated_member_use

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:fitbasix_chat/core/constants/app_colors.dart';
import 'package:fitbasix_chat/core/constants/app_text_styles.dart';
import 'package:fitbasix_chat/core/constants/image_path.dart';
import 'package:fitbasix_chat/core/responsive/size_config.dart';
import 'package:fitbasix_chat/features/chat_firebase/controller/firebase_chat_controller.dart';
import 'package:fitbasix_chat/features/chat_firebase/view/widgets/customized_circular_indicator.dart';
import 'package:fitbasix_chat/features/chat_firebase/view/widgets/image_viewer.dart';
import 'package:dio/dio.dart';
import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

class MessageTileWidget extends StatelessWidget {
  final String senderImage;
  final bool sender;
  final String message;
  final bool isRead;
  final bool isSent;
  final bool isDelivered;
  final bool isMedia;
  final String mediaType;
  final String mediaUrl;
  final String messageId;
  final DateTime createdAt;
  MessageTileWidget(
      {Key? key,
      required this.message,
      required this.sender,
      required this.senderImage,
      required this.isRead,
      required this.isSent,
      required this.isMedia,
      required this.mediaType,
      required this.mediaUrl,
      required this.messageId,
      required this.isDelivered,
      required this.createdAt})
      : super(key: key);

  final chatController = Get.find<FirebaseChatController>();
  final DefaultCacheManager cacheManager = DefaultCacheManager();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (sender) const Spacer(),
        GestureDetector(
          onLongPressStart: (details) => _showPopupMenu(details, context),
          child: Container(
            margin: EdgeInsets.only(
                left: !sender ? 16 * SizeConfig.widthMultiplier! : 0,
                right: sender ? 16 * SizeConfig.widthMultiplier! : 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!sender)
                  Padding(
                    padding:
                        EdgeInsets.only(right: 8 * SizeConfig.widthMultiplier!),
                    child: CircleAvatar(
                      radius: 12 * SizeConfig.imageSizeMultiplier!,
                      backgroundImage: NetworkImage(
                          'https://cdn-icons-png.flaticon.com/512/3135/3135715.png'),
                    ),
                  ),
                Container(
                  constraints: BoxConstraints(
                    minHeight:
                        (isMedia ? 56 : 53) * SizeConfig.heightMultiplier!,
                    minWidth: 124 * SizeConfig.heightMultiplier!,
                    maxWidth: (isMedia
                            ? 264
                            : sender
                                ? 264
                                : 248) *
                        SizeConfig.widthMultiplier!,
                  ),
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      color: isMedia
                          ? Colors.transparent
                          : sender
                              ? AppColors.chatColor
                              : AppColors.receiverChatColor,
                      borderRadius: BorderRadius.circular(
                          8 * SizeConfig.widthMultiplier!)),
                  padding: isMedia
                      ? EdgeInsets.zero
                      : EdgeInsets.fromLTRB(
                          16 * SizeConfig.widthMultiplier!,
                          12 * SizeConfig.heightMultiplier!,
                          4 * SizeConfig.widthMultiplier!,
                          4 * SizeConfig.heightMultiplier!),
                  child: Stack(
                    children: [
                      isMedia
                          ? MediaMessageWidget(
                              message: message,
                              mediaType: mediaType,
                              mediaUrl: mediaUrl,
                              sender: sender,
                              cacheManager: cacheManager,
                            )
                          : Padding(
                              padding: EdgeInsets.only(
                                right: 12.0 * SizeConfig.widthMultiplier!,
                                bottom: 15 * SizeConfig.heightMultiplier!,
                              ),
                              child: TextMessageWidget(
                                message: message,
                              ),
                            ),
                      Positioned(
                        bottom: (isMedia ? 4 : 0) * SizeConfig.widthMultiplier!,
                        right: (isMedia ? 4 : 0) * SizeConfig.widthMultiplier!,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              DateFormat('hh:mm a').format(createdAt.toLocal()),
                              style: AppTextStyle.smallBlackText.copyWith(
                                color: AppColors.greyDF,
                                shadows: <Shadow>[
                                  const Shadow(
                                    offset: Offset(2.0, 2.0),
                                    blurRadius: 5.0,
                                    color: Color.fromARGB(255, 0, 0, 0),
                                  ),
                                ],
                              ),
                            ),
                            if (sender)
                              Padding(
                                padding: EdgeInsets.only(
                                    left: 4 * SizeConfig.widthMultiplier!),
                                child: Container(
                                  height: 12 * SizeConfig.heightMultiplier!,
                                  width: 12 * SizeConfig.widthMultiplier!,
                                  child: isRead
                                      ? SvgPicture.asset(
                                          ImagePath.readIcon,
                                          color: AppColors.kPureWhite,
                                          height: 12 *
                                              SizeConfig.imageSizeMultiplier!,
                                          width: 12 *
                                              SizeConfig.imageSizeMultiplier!,
                                        )
                                      : isDelivered
                                          ? SvgPicture.asset(
                                              ImagePath.deliveredIcon,
                                              color: AppColors.kPureWhite,
                                              height: 12 *
                                                  SizeConfig
                                                      .imageSizeMultiplier!,
                                              width: 12 *
                                                  SizeConfig
                                                      .imageSizeMultiplier!,
                                            )
                                          : isSent
                                              ? SvgPicture.asset(
                                                  ImagePath.sentIcon,
                                                  color: AppColors.kPureWhite,
                                                  height: 12 *
                                                      SizeConfig
                                                          .imageSizeMultiplier!,
                                                  width: 12 *
                                                      SizeConfig
                                                          .imageSizeMultiplier!,
                                                )
                                              : SvgPicture.asset(
                                                  ImagePath.sendingIcon,
                                                  color: AppColors.kPureWhite,
                                                  height: 12 *
                                                      SizeConfig
                                                          .imageSizeMultiplier!,
                                                  width: 12 *
                                                      SizeConfig
                                                          .imageSizeMultiplier!,
                                                ),
                                ),
                              ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!sender) const Spacer(),
      ],
    );
  }

  void _showPopupMenu(
      LongPressStartDetails details, BuildContext context) async {
    Vibrate.feedback(FeedbackType.medium);
    late RelativeRect position;
    if (!sender) {
      position = RelativeRect.fromLTRB(
        48 * SizeConfig.widthMultiplier!,
        EdgeInsets.fromWindowPadding(WidgetsBinding.instance.window.viewInsets,
                    WidgetsBinding.instance.window.devicePixelRatio)
                .bottom +
            details.globalPosition.dy -
            details.localPosition.dy -
            (45 * SizeConfig.heightMultiplier!),
        details.globalPosition.dx,
        0,
      );
    } else {
      position = RelativeRect.fromLTRB(
        details.globalPosition.dx - details.localPosition.dx,
        EdgeInsets.fromWindowPadding(WidgetsBinding.instance.window.viewInsets,
                    WidgetsBinding.instance.window.devicePixelRatio)
                .bottom +
            details.globalPosition.dy -
            details.localPosition.dy -
            (80 * SizeConfig.heightMultiplier!),
        16 * SizeConfig.widthMultiplier!,
        0,
      );
    }
    final result = await showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(8 * SizeConfig.imageSizeMultiplier!),
      ),
      color: AppColors.greyBorder,
      items: [
        PopupMenuItem(
          height: 30 * SizeConfig.heightMultiplier!,
          value: "Copy",
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                Icons.file_copy_outlined,
                size: 16 * SizeConfig.imageSizeMultiplier!,
                color: AppColors.greyDF,
              ),
              SizedBox(
                width: 16 * SizeConfig.widthMultiplier!,
              ),
              Text(
                'Copy',
                style: AppTextStyle.hmediumBlackText
                    .copyWith(color: AppColors.greyDF),
              ),
            ],
          ),
        ),
        if (sender)
          PopupMenuItem(
            height: 30 * SizeConfig.heightMultiplier!,
            value: "Delete",
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Icon(
                  Icons.delete_outline_outlined,
                  size: 16 * SizeConfig.imageSizeMultiplier!,
                  color: AppColors.greyDF,
                ),
                SizedBox(
                  width: 16 * SizeConfig.widthMultiplier!,
                ),
                Text(
                  'Delete',
                  style: AppTextStyle.hmediumBlackText
                      .copyWith(color: AppColors.greyDF),
                ),
              ],
            ),
          ),
      ],
    );
    if (result == "Copy") {
      await Clipboard.setData(ClipboardData(text: message));
    } else if (result == "Delete") {
      Get.dialog(
        Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(
                horizontal: 16 * SizeConfig.widthMultiplier!,
                vertical: 16 * SizeConfig.heightMultiplier!),
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(8 * SizeConfig.imageSizeMultiplier!),
              color: const Color(0xff4D4D4D),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: 8 * SizeConfig.widthMultiplier!,
                      vertical: 8 * SizeConfig.heightMultiplier!),
                  child: const Text('Do you want to delete this message?'),
                ),
                SizedBox(
                  height: 8 * SizeConfig.heightMultiplier!,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.greyDF),
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () {
                        chatController.deleteMessage(messageId);
                        Get.back();
                      },
                      style: TextButton.styleFrom(
                          foregroundColor: const Color(0xff4AA3FF)),
                      child: const Text('Yes'),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      );
    }
  }
}

class MediaMessageWidget extends StatefulWidget {
  final bool sender;
  final String message;
  final String mediaUrl;
  final String mediaType;
  final DefaultCacheManager cacheManager;
  MediaMessageWidget(
      {Key? key,
      required this.message,
      required this.mediaUrl,
      required this.mediaType,
      required this.sender,
      required this.cacheManager})
      : super(key: key);

  @override
  State<MediaMessageWidget> createState() => _MediaMessageWidgetState();
}

class _MediaMessageWidgetState extends State<MediaMessageWidget> {
  final chatController = Get.find<FirebaseChatController>();
  Rxn<CachedVideoPlayerController> _controller = Rxn();
  RxnString fileStorage = RxnString();

  @override
  void initState() {
    downloadMedia().then((value) {
      if (widget.mediaType == "video") {
        _controller.value = null;
        if (fileStorage.value == null) {
          _controller.value =
              CachedVideoPlayerController.network(widget.mediaUrl)
                ..initialize().then((value) {
                  setState(() {});
                });
        } else {
          _controller.value =
              CachedVideoPlayerController.file(File(fileStorage.value ?? ''))
                ..initialize().then((value) {
                  setState(() {});
                });
        }
      }
    });
    super.initState();
  }

  Future<void> downloadMedia() async {
    // fileStorage.value = await chatController.checkFileExistence(widget.mediaUrl.split('/').last);
    // if (fileStorage.value == null) {
    //   final downloaded = await chatController.saveFile(widget.mediaUrl, widget.mediaUrl.split('/').last);
    //   print(downloaded);
    // }
  }

  @override
  void dispose() {
    _controller.value?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.mediaType == "image")
          GestureDetector(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) =>
                        ImageViewer(label: "", imgUrl: widget.mediaUrl))),
            child: Obx(
              () => (fileStorage.value == null)
                  ? CachedNetworkImage(
                      imageUrl: widget.mediaUrl,
                      filterQuality: FilterQuality.high,
                      memCacheWidth:
                          (264 * SizeConfig.widthMultiplier!).toInt(),
                      // memCacheHeight: (264 * SizeConfig.widthMultiplier! * (4 / 3)).toInt(),
                      placeholder: (context, url) => AspectRatio(
                        aspectRatio: 3 / 4,
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: AppColors.kBlack,
                          child: Center(
                            child: CustomizedCircularProgress(),
                          ),
                        ),
                      ),
                    )
                  : Image.file(
                      File(fileStorage.value ?? ''),
                    ),
            ),
          ),
        // Container(),
        if (widget.mediaType == "video")
          GestureDetector(
            onTap: () async {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //       builder: (context) => FileVideoPlayer(
              //           file: File(widget.mediaUrl), isUrl: true),
              //     ));
            },
            child: SizedBox(
              width: double.infinity,
              child: Obx(
                () => _controller.value?.value.isInitialized == false &&
                        _controller.value != null
                    ? AspectRatio(
                        aspectRatio: _controller.value!.value.aspectRatio,
                        child: Container(
                          height: double.infinity,
                          width: double.infinity,
                          color: AppColors.kBlack,
                          child: Center(
                            child: CustomizedCircularProgress(),
                          ),
                        ),
                      )
                    : AspectRatio(
                        aspectRatio: _controller.value!.value.aspectRatio,
                        child: Stack(
                          children: [
                            Container(
                              height: double.infinity,
                              width: double.infinity,
                              color: AppColors.kBlack,
                              child: Center(
                                child: CustomizedCircularProgress(),
                              ),
                            ),
                            CachedVideoPlayer(_controller.value!),
                            Container(
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.play_arrow,
                                size: 30 * SizeConfig.imageSizeMultiplier!,
                                color: AppColors.kPureWhite,
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ),
          ),
        if (widget.mediaType == "audio" || widget.mediaType == "file")
          FileCard(
            backgroundColor: AppColors.kBlack.withOpacity(0.8),
            mediaName: widget.mediaUrl.split('/').last,
            mediaUrl: widget.mediaUrl,
            sendByMe: widget.sender,
          ),
        if (widget.message.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              // borderRadius: BorderRadius.circular(8 * SizeConfig.widthMultiplier!),
              color: widget.sender
                  ? AppColors.chatColor
                  : AppColors.receiverChatColor,
            ),
            width: double.infinity,
            // padding: EdgeInsets.symmetric(vertical: 12 * SizeConfig.heightMultiplier!, horizontal: 8 * SizeConfig.widthMultiplier!),
            padding: EdgeInsets.only(
                right: 8.0 * SizeConfig.widthMultiplier!,
                left: 8.0 * SizeConfig.widthMultiplier!,
                bottom: 15 * SizeConfig.heightMultiplier!,
                top: 12 * SizeConfig.heightMultiplier!),
            child: TextMessageWidget(message: widget.message),
          )
      ],
    );
  }
}

class TextMessageWidget extends StatelessWidget {
  final String message;
  TextMessageWidget({Key? key, required this.message}) : super(key: key);

  final RegExp linkRegex = RegExp(
      r"^((ftp|http|https):\/\/)?(www.)?(?!.*(ftp|http|https|www.))[a-zA-Z0-9_-]+(\.[a-zA-Z]+)+((\/)[\w#]+)*(\/\w+\?[a-zA-Z0-9_]+=\w+(&[a-zA-Z0-9_]+=\w+)*)?\/?");

  @override
  Widget build(BuildContext context) {
    final messages =
        message.split(' ').expand((element) => element.split('\n')).toList();
    return RichText(
      text: TextSpan(
          children: List.generate(
              messages.length,
              (index) => TextSpan(
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      if ((linkRegex.hasMatch(messages.elementAt(index)))) {
                        try {
                          if (await canLaunch(messages.elementAt(index))) {
                            await launch(messages.elementAt(index));
                          } else {
                            Get.rawSnackbar(message: "Invalid Url");
                          }
                        } catch (e) {
                          log("error $e");
                        }
                      }
                    },
                  text: ((index == 0 ||
                              (linkRegex.hasMatch(messages.elementAt(index))))
                          ? ""
                          : ' ') +
                      messages.elementAt(index),
                  style: (linkRegex.hasMatch(messages.elementAt(index)))
                      ? AppTextStyle.link400Text
                      : AppTextStyle.white400Text)),
          style: AppTextStyle.white400Text),
    );
  }
}

class FileCard extends StatefulWidget {
  final String mediaUrl;
  final String mediaName;
  final Color backgroundColor;
  final bool sendByMe;
  const FileCard(
      {Key? key,
      required this.backgroundColor,
      required this.sendByMe,
      required this.mediaUrl,
      required this.mediaName})
      : super(key: key);

  @override
  _FileCardState createState() => _FileCardState();
}

class _FileCardState extends State<FileCard> {
  var isDownloaded = false.obs;
  var isDownloadingStarted = false.obs;
  var filePath = "".obs;
  var downloadProgress = 0.0.obs;
  var fileSize = "".obs;
  String? fileExtension;

  @override
  Widget build(BuildContext context) {
    // Color backgroundColor = widget.sendByMe ? greenChatColor : kBlack;
    checkFileExistence(widget.mediaUrl.split('/').last);
    fileExtension =
        widget.mediaUrl.split(".").last.toUpperCase().split('?').first;
    return GestureDetector(
      onTap: () {
        if (filePath.value.isEmpty == false) {
          OpenFilex.open(filePath.value);
        }
      },
      child: Container(
          constraints: BoxConstraints(
              maxWidth: 300 * SizeConfig.widthMultiplier!,
              maxHeight: 250 * SizeConfig.heightMultiplier!),
          // padding: EdgeInsets.symmetric(
          //   vertical: 14.0 * SizeConfig.heightMultiplier!,
          //   horizontal: 8.0 * SizeConfig.widthMultiplier!,
          // ),
          decoration: BoxDecoration(
            color: widget.sendByMe
                ? AppColors.chatColor
                : AppColors.receiverChatColor,
            borderRadius:
                BorderRadius.circular(8 * SizeConfig.imageSizeMultiplier!),
          ),
          child: Obx(() => filePath.value.isEmpty
              ? Container(
                  height: 56 * SizeConfig.heightMultiplier!,
                  child: GestureDetector(
                      onTap: () async {},
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 8 * SizeConfig.widthMultiplier!,
                                  vertical: 12 * SizeConfig.heightMultiplier!),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    8 * SizeConfig.imageSizeMultiplier!),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    widget.mediaName,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTextStyle.whiteTextWithWeight600,
                                  )),
                                  SizedBox(
                                    width: 10 * SizeConfig.widthMultiplier!,
                                  ),
                                  (!isDownloadingStarted.value)
                                      ? GestureDetector(
                                          onTap: () async {
                                            isDownloadingStarted.value = true;
                                            isDownloaded.value =
                                                await _getImageUrl(
                                                    widget.mediaUrl,
                                                    widget.mediaUrl
                                                        .split('/')
                                                        .last);
                                          },
                                          child: Image.asset(
                                            ImagePath.downloadDocIcon,
                                            width: 16.79 *
                                                SizeConfig.widthMultiplier!,
                                            height: 22.4 *
                                                SizeConfig.heightMultiplier!,
                                          ))
                                      : SizedBox(
                                          height:
                                              22 * SizeConfig.heightMultiplier!,
                                          width:
                                              22 * SizeConfig.heightMultiplier!,
                                          child: CircularProgressIndicator(
                                            color: AppColors.kPureWhite,
                                            value: downloadProgress.value,
                                            backgroundColor:
                                                Colors.grey.withOpacity(0.2),
                                            strokeWidth: 2.5 *
                                                SizeConfig.imageSizeMultiplier!,
                                          )),
                                  SizedBox(
                                    width: 12 * SizeConfig.widthMultiplier!,
                                  ),
                                ],
                              ),
                            ),
                            // Text(
                            //   "${NumberFormat("#0.00").format(widget.attachment?.fileSize! / (1024 * 1024))} MB • ${widget.attachment?.fileName.split(".").last.toUpperCase()}",
                            //   style: AppTextStyle.hmediumBlackText
                            //       .copyWith(color: kPureWhite, height: 1),
                            // )
                          ],
                        ),
                      )),
                )
              : Container(
                  height: 56 * SizeConfig.heightMultiplier!,
                  child: GestureDetector(
                      onTap: () {
                        OpenFilex.open(filePath.value);
                      },
                      child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8 * SizeConfig.widthMultiplier!,
                              vertical: 12 * SizeConfig.heightMultiplier!),
                          child: Row(
                            children: [
                              Image.asset(
                                (fileExtension == "JPEG" ||
                                        fileExtension == "JPG")
                                    ? ImagePath.jpgFileIcon
                                    : (fileExtension == "PNG")
                                        ? ImagePath.pngIcon
                                        : ((fileExtension ?? '')
                                                .contains("PPT"))
                                            ? ImagePath.pptIcon
                                            : ((fileExtension ?? '')
                                                    .contains("MP4"))
                                                ? ImagePath.mp4Icon
                                                : ((fileExtension ?? '')
                                                        .contains("XLX"))
                                                    ? ImagePath.xlxIcon
                                                    : (fileExtension == "PDF")
                                                        ? ImagePath.pdfFileIcon
                                                        : ImagePath.docFileIcon,
                                width: 32 * SizeConfig.imageSizeMultiplier!,
                                height: 32 * SizeConfig.imageSizeMultiplier!,
                              ),
                              SizedBox(
                                width: 7 * SizeConfig.widthMultiplier!,
                              ),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Container(
                                        padding: new EdgeInsets.only(
                                            right: 10 *
                                                SizeConfig.widthMultiplier!),
                                        child: Text(
                                          widget.mediaUrl.split('/').last,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTextStyle
                                              .whiteTextWithWeight600,
                                        )),
                                    const Spacer(),
                                    FutureBuilder(
                                        future: getFileSizeFromLocal(),
                                        builder: (context,
                                            AsyncSnapshot<String> snapshot) {
                                          return Text(
                                            "${snapshot.hasData ? snapshot.data : 0.0} MB",
                                            style: AppTextStyle.hmediumBlackText
                                                .copyWith(
                                                    color: AppColors.kPureWhite,
                                                    height: 1),
                                          );
                                        })
                                  ],
                                ),
                              )
                            ],
                          ))),
                ))),
    );

    // Card(
    //   color: widget.backgroundColor,
    //   child: Column(
    //     children: [
    //       SizedBox(
    //         height: 100,
    //         width: 150,
    //         child: Padding(
    //           padding: const EdgeInsets.all(8.0),
    //           child: Center(
    //             child: Text(widget.attachment?.fileName),
    //           ),
    //         ),
    //       ),
    //       GestureDetector(
    //         onTap: () async {
    //           setState(() {
    //             _isDownloading = true;
    //           });
    //           File ab = await _downloadFile(
    //               widget.attachment?.fileUrl,
    //               widget.attachment?.fileName);
    //           print(ab.path);
    //           setState(() {
    //             _isDownloading = false;
    //           });
    //
    //           OpenFilex.open(ab.path);
    //         },
    //         child: Row(
    //           mainAxisSize: MainAxisSize.min,
    //           children: [
    //             if (_isDownloading)
    //               const Padding(
    //                 padding: EdgeInsets.all(8.0),
    //                 child: LoadingIndicator(
    //                   height: 10,
    //                   width: 10,
    //                 ),
    //               ),
    //             const Text("Download")
    //           ],
    //         ),
    //       )
    //     ],
    //   ),
    // );
  }

  Future<bool> _getImageUrl(String url, String fileName) async {
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

  void checkFileExistence(String? fileName) async {
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
          filePath.value = path + "/$fileName";
        }

        if (File(downloadsPath.path + "/" + fileName).existsSync()) {
          filePath.value = downloadsPath.path + "/" + fileName;
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
        filePath.value = path + "/$fileName";
      }
    }
  }

  Future<String> getFileSizeFromLocal() async {
    File file = File(filePath.value);
    int sizeInBytes = (await file.length());
    var size = ((sizeInBytes / (1024))).toStringAsFixed(2);
    return size;
  }

  int byteCount = 0;
}
