import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../home/home.dart';
import '../key/key_screen.dart';
import '../home/list_note_page.dart';
import '../key/license_checker.dart';
import '../navigation_menu.dart';
import '../theme/constants/image_strings.dart';
import '../theme/constants/popups/full_screen_loader.dart';

class KeyCheckScreen extends StatefulWidget {
  const KeyCheckScreen({super.key});

  @override
  State<KeyCheckScreen> createState() => _KeyCheckScreenState();
}

class _KeyCheckScreenState extends State<KeyCheckScreen> {
  final LicenseChecker licenseChecker = LicenseChecker();

  @override
  void initState() {
    super.initState();
    _checkKey();
  }

  Future<void> _checkKey() async {
    bool valid = await licenseChecker.isKeyValid();

    if (valid) {
      Get.off(() => const NavigationMenu()); // key còn hạn → HomeScreen
    } else {
      Get.off(() => KeyScreen()); // hết hạn → KeyScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    // Hiển thị dialog khi build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      TFullScreenLoader.openLoadingDialog(
        'We are processing your information....',
        TImages.checkcreate_note,
      );
    });

    // Scaffold trống hoặc hiển thị màn hình nền
    return const Scaffold(
      body: Center(
        child: Text(''), // hoặc để trống
      ),
    );
  }


}
