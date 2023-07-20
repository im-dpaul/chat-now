import 'package:fitbasix_chat/core/responsive/size_config.dart';
import 'package:fitbasix_chat/home.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // await Firebase.initializeApp();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      designSize: const Size(360, 800),
      minTextAdapt: true,
      builder: (BuildContext context, Widget? child) {
        return LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return OrientationBuilder(
              builder: (BuildContext context, Orientation orientation) {
                SizeConfig().init(constraints, orientation);
                return const GetMaterialApp(
                  debugShowCheckedModeBanner: false,
                  home: Home(),
                );
              },
            );
          },
        );
      },
    );
  }
}
