import 'package:fitbasix_chat/core/constants/app_colors.dart';
import 'package:fitbasix_chat/core/responsive/size_config.dart';
import 'package:flutter/material.dart';

class CustomizedCircularProgress extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 20 * SizeConfig.heightMultiplier!,
      width: 20 * SizeConfig.heightMultiplier!,
      child: FittedBox(
        fit: BoxFit.contain,
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            AppColors.kGreenColor,
          ),
          strokeWidth: 4 * SizeConfig.heightMultiplier!,
        ),
      ),
    );
  }
}
