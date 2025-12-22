import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghi_no/purchar/customers_list_page.dart';
import 'package:ghi_no/theme/constants/colors.dart';
import 'package:ghi_no/theme/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';
import 'create_note/controller/create_note_controller.dart';
import 'create_note/create_note.dart';
import 'home/home.dart';
import 'key/key_screen.dart';
import 'fill/fill_controller.dart'; // import FillController

class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    final controller = Get.put(NavigationController());
    final createNoteController = Get.put(CreateNoteController(), permanent: true);
    return Scaffold(
      bottomNavigationBar: Obx(
            () => NavigationBar(
          height: 80,
          elevation: 0,
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: (index) => controller.selectedIndex.value = index,
          backgroundColor: dark ? TColors.black : TColors.white,
          indicatorColor:
          dark ? TColors.black.withOpacity(0.1) : TColors.white.withOpacity(0.1),
          destinations: const [
            NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
            NavigationDestination(icon: Icon(Iconsax.note), label: 'Save'),
            NavigationDestination(icon: Icon(Iconsax.save_add), label: 'Purchar'),
            NavigationDestination(icon: Icon(Iconsax.key), label: 'Key'),
          ],
        ),
      ),
      body: Obx(
            () => IndexedStack(
          index: controller.selectedIndex.value,
          children: controller.screens,
        ),
      ),
    );
  }
}

class NavigationController extends GetxController {
  final Rx<int> selectedIndex = 0.obs;

  // Gọi FillController (phải được put trước đó)
  final FillController fillController = Get.put(FillController(), permanent: true);

  final screens = [
    const HomeScreen(),
    const CreateNoteScreen(),
    CustomerListScreen(),
    KeyScreen(),
  ];

  @override
  void onInit() {
    super.onInit();

    // Lắng nghe thay đổi tab
    ever(selectedIndex, (index) {
      if (index == 1) {
        // Khi vào tab Save, reset bộ lọc
        fillController.resetFilters();
      }
    });
  }
}
