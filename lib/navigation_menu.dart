import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghi_no/theme/constants/colors.dart';
import 'package:ghi_no/theme/helpers/helper_functions.dart';
import 'package:iconsax/iconsax.dart';

import 'home/home.dart';


class NavigationMenu extends StatelessWidget {
  const NavigationMenu({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = THelperFunctions.isDarkMode(context);

    final controller = Get.put(NavigationController());
    return Scaffold(
      bottomNavigationBar: Obx(
          () => NavigationBar(
            height: 80,
            elevation: 0,
            selectedIndex: controller.selectedIndex.value,
            onDestinationSelected: (index) => controller.selectedIndex.value = index,
            backgroundColor: dark ? TColors.black : TColors.white,
            indicatorColor: dark ? TColors.black.withOpacity(0.1) : TColors.white.withOpacity(0.1),
            destinations: const [
              NavigationDestination(icon: Icon(Iconsax.home), label: 'Home'),
              NavigationDestination(icon: Icon(Iconsax.shop), label: 'Store'),
              NavigationDestination(icon: Icon(Iconsax.heart), label: 'Wishlist'),
              NavigationDestination(icon: Icon(Iconsax.user), label: 'Profile'),
            ],
          ),
      ),

      body:Obx(() =>  controller.screens[controller.selectedIndex.value]),
    );
  }
}

class NavigationController extends GetxController{
  final Rx<int> selectedIndex = 0.obs;
  final screens = [
    const HomeScreen(),
    // const StoreScreen(),
    // const FavouriteScreen(),
    // const SettingScreen()
  ];
}
