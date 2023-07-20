import 'package:fitbasix_chat/core/constants/app_colors.dart';
import 'package:fitbasix_chat/features/chat_firebase/view/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: GestureDetector(
          onTap: () {
            Get.to(() => const ChatScreen());
          },
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.greenChatColor,
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: const Padding(
              padding: EdgeInsets.all(12.0),
              child: Text('Chat'),
            ),
          ),
        ),
      ),
    );
  }
}
