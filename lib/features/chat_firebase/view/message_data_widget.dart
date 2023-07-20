import 'package:fitbasix_chat/core/constants/app_colors.dart';
import 'package:fitbasix_chat/core/constants/app_text_styles.dart';
import 'package:fitbasix_chat/core/responsive/size_config.dart';
import 'package:fitbasix_chat/features/chat_firebase/controller/firebase_chat_controller.dart';
import 'package:fitbasix_chat/features/chat_firebase/model/chat_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

const String urlPattern =
    r'(https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|www\.[a-zA-Z0-9][a-zA-Z0-9-]+[a-zA-Z0-9]\.[^\s]{2,}|https?:\/\/(?:www\.|(?!www))[a-zA-Z0-9]+\.[^\s]{2,}|www\.[a-zA-Z0-9]+\.[^\s]{2,})';
final RegExp linkRegExp = RegExp('($urlPattern)', caseSensitive: false);

class MessageWidget extends StatefulWidget {
  final MessageData messageData;
  const MessageWidget({Key? key, required this.messageData}) : super(key: key);

  @override
  _MessageWidgetState createState() => _MessageWidgetState();
}

class _MessageWidgetState extends State<MessageWidget> {
  final FirebaseChatController _chatController = Get.find();
  String? text;
  bool sentByMe = false;

  Future<void> openUrl(String url) async {
    String uri = url;
    if (!url.contains('http')) {
      uri = "https://" + url;
    }
    if (await canLaunchUrl(Uri.parse(uri))) {
      await launchUrl(Uri.parse(uri));
    } else {
      throw 'Could not launch $url';
    }
  }

  List<InlineSpan> linkify(String text) {
    final List<InlineSpan> list = <InlineSpan>[];
    final RegExpMatch? match = linkRegExp.firstMatch(text);
    if (match == null) {
      list.add(TextSpan(text: text));
      return list;
    }

    if (match.start > 0) {
      list.add(TextSpan(text: text.substring(0, match.start)));
    }

    final String linkText = match.group(0).toString();
    if (linkText.contains(RegExp(urlPattern, caseSensitive: false))) {
      list.add(buildLinkComponent(linkText, linkText));
    } else {
      throw 'Unexpected match: $linkText';
    }

    list.addAll(linkify(text.substring(match.start + linkText.length)));

    return list;
  }

  buildTextWithLinks(String textToLink) =>
      Text.rich(TextSpan(children: linkify(textToLink)));

  @override
  Widget build(BuildContext context) {
    if (_chatController.senderId == widget.messageData.senderId) {
      sentByMe = true;
    } else {
      sentByMe = false;
    }

    text = widget.messageData.message;
    Color background =
        sentByMe == true ? AppColors.greenChatColor : AppColors.kBlack;

    return Column(
      crossAxisAlignment:
          sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        GestureDetector(
            onTap: () async {
              // Navigator.push(
              //     context,
              //     MaterialPageRoute(
              //         builder: (context) => MessageFunctions(
              //               passedMessage: widget.passedMessage,
              //               sentByMe: sentByMe,
              //               deleteMessage: widget.deleteFunction,
              //               editMessage: widget.editFunction,
              //             )));
            },
            child: Padding(
              padding: EdgeInsets.only(
                  bottom: 8.0 * SizeConfig.heightMultiplier!,
                  right: 16 * SizeConfig.widthMultiplier!,
                  left: 16 * SizeConfig.widthMultiplier!),
              child: Column(
                crossAxisAlignment: sentByMe
                    ? CrossAxisAlignment.end
                    : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: 300 * SizeConfig.widthMultiplier!,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 10.0 * SizeConfig.heightMultiplier!,
                      horizontal: 10.0 * SizeConfig.widthMultiplier!,
                    ),
                    decoration: BoxDecoration(
                      color: background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: RichText(
                      text: TextSpan(children: linkify(text.toString())),
                    ),
                    //   child: SelectableAutoLinkText(
                    //     text ?? "",
                    //     style: sentByMe == true
                    //         ? AppTextStyle.white400Text
                    //         : AppTextStyle.black400Text
                    //             .copyWith(color: kPureWhite),
                    // linkStyle: AppTextStyle.white400Text.copyWith(
                    //   color: Colors.white,
                    //   decoration: TextDecoration.underline,
                    // ),
                    //     highlightedLinkStyle: const TextStyle(
                    //       color: Colors.white,
                    //       backgroundColor: Colors.transparent,
                    //     ),
                    //     onTap: (url) async {
                    //       if (await canLaunchUrl(Uri.parse(url))) {
                    //         launchUrl(Uri.parse(url),mode: LaunchMode.inAppWebView);
                    //       } else {}
                    //     },
                    //     onLongPress: (url) {
                    //       print('🍔LongPress: $url');
                    //     },
                    //     onTapOther: (local, global) {
                    //       print('🍇️onTapOther: $local, $global');
                    //     },
                    //   ),
                    // ),
                  ),
                  SizedBox(
                    height: 5.0 * SizeConfig.heightMultiplier!,
                  ),
                  !sentByMe
                      ? Text(
                          DateFormat.jm().format(
                              DateTime.parse(widget.messageData.sentAt)
                                  .toLocal()),
                          style: sentByMe == true
                              ? AppTextStyle.white400Text.copyWith(
                                  fontSize: 9.0 * SizeConfig.textMultiplier!)
                              : AppTextStyle.black400Text.copyWith(
                                  color: AppColors.kPureWhite,
                                  fontSize: 9.0 * SizeConfig.textMultiplier!))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                                DateFormat.jm().format(
                                    DateTime.parse(widget.messageData.sentAt)
                                        .toLocal()),
                                style: sentByMe == true
                                    ? AppTextStyle.white400Text.copyWith(
                                        fontSize:
                                            9.0 * SizeConfig.textMultiplier!)
                                    : AppTextStyle.black400Text.copyWith(
                                        color: AppColors.kPureWhite,
                                        fontSize:
                                            9.0 * SizeConfig.textMultiplier!)),
                            Padding(
                              padding: EdgeInsets.all(
                                  5 * SizeConfig.widthMultiplier!),
                              child: widget.messageData.read
                                  ? Icon(
                                      Icons.check_box,
                                      color: AppColors.kGreenColor,
                                      size: 12 * SizeConfig.textMultiplier!,
                                    )
                                  : Icon(
                                      Icons.check,
                                      color: AppColors.kGreenColor,
                                      size: 12 * SizeConfig.textMultiplier!,
                                    ),
                            )
                          ],
                        ),
                ],
              ),
            )),
        // if (sentByMe == true)
        //   MessageReceipts(passedMessage: widget.passedMessage)
      ],
    );
  }

  WidgetSpan buildLinkComponent(String text, String linkToOpen) => WidgetSpan(
          child: InkWell(
        child: Text(
          text,
          style: AppTextStyle.white400Text.copyWith(
            color: Colors.white,
            decoration: TextDecoration.underline,
          ),
        ),
        onTap: () => openUrl(linkToOpen),
      ));
}
