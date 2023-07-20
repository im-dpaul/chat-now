import 'package:fitbasix_chat/core/constants/app_colors.dart';
import 'package:fitbasix_chat/core/responsive/size_config.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTextStyle {
  static TextStyle link400Text = GoogleFonts.openSans(
    fontSize: (14) * SizeConfig.textMultiplier!,
    fontWeight: FontWeight.w600,
    color: AppColors.kPureWhite,
    decoration: TextDecoration.underline,
  );

  static TextStyle smallBlackText = GoogleFonts.openSans(
    fontSize: (10) * SizeConfig.textMultiplier!,
    fontWeight: FontWeight.w400,
    color: AppColors.lightBlack,
  );

  static TextStyle white400Text = GoogleFonts.openSans(
    fontSize: (14) * SizeConfig.textMultiplier!,
    fontWeight: FontWeight.w400,
    color: AppColors.kPureWhite,
  );

  static TextStyle black400Text = GoogleFonts.openSans(
    fontSize: (14) * SizeConfig.textMultiplier!,
    fontWeight: FontWeight.w400,
    color: AppColors.kPureBlack,
  );

  static TextStyle grey400Text = GoogleFonts.openSans(
    fontSize: (14) * SizeConfig.textMultiplier!,
    fontWeight: FontWeight.w400,
    color: AppColors.hintGrey,
  );

  static TextStyle hmediumBlackText = GoogleFonts.openSans(
    fontSize: (12) * SizeConfig.textMultiplier!,
    fontWeight: FontWeight.w400,
    color: AppColors.kBlack,
  );

  static TextStyle whiteTextWithWeight600 = GoogleFonts.openSans(
    fontSize: (14) * SizeConfig.textMultiplier!,
    fontWeight: FontWeight.w600,
    color: AppColors.kPureWhite,
  );

  static TextStyle hsmallhintText = GoogleFonts.openSans(
    fontSize: (12) * SizeConfig.textMultiplier!,
    fontWeight: FontWeight.w400,
    color: AppColors.hintGrey,
  );

  static TextStyle normalGreenText = GoogleFonts.openSans(
    fontSize: (14) * SizeConfig.textMultiplier!,
    fontWeight: FontWeight.w400,
    color: AppColors.kGreenColor,
  );

  static TextStyle hsmallGreenText = GoogleFonts.openSans(
    fontSize: (12) * SizeConfig.textMultiplier!,
    fontWeight: FontWeight.w600,
    color: AppColors.kGreenColor,
  );

  static TextStyle smallGreyText = GoogleFonts.openSans(
    fontSize: (12) * SizeConfig.textMultiplier!,
    fontWeight: FontWeight.w400,
    color: AppColors.darkGreyColor,
  );

  static TextStyle hnormal600BlackText = GoogleFonts.openSans(
    fontSize: (14) * SizeConfig.textMultiplier!,
    fontWeight: FontWeight.w600,
    color: AppColors.kPureBlack,
  );

  // white400Text
// black400Text
// grey400Text
// hmediumBlackText
// whiteTextWithWeight600
// hsmallhintText
// normalGreenText
// hsmallGreenText
// smallGreyText
// hnormal600BlackText
// link400Text
}
