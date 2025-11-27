import 'package:flutter/material.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:ghi_no/theme/theme.dart';
import 'home/home.dart';
import 'key/key_check_screen.dart';
import 'navigation_menu.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      // home: const NavigationMenu(),
       home: const KeyCheckScreen(), // mở KeyCheckScreen đầu tiên
    );
  }
}
