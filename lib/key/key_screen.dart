import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/constants/colors.dart';
import '../theme/constants/sizes.dart';
import '../theme/helpers/helper_functions.dart';
import 'key_controller.dart';
import 'package:http/http.dart' as http;

class KeyScreen extends StatelessWidget {
  KeyScreen({super.key});

  final KeyController controller = Get.put(KeyController());

  @override
  Widget build(BuildContext context) {
    // Lấy thời gian còn lại khi mở màn hình
    controller.fetchRemainingTime();

    final isDarkMode = THelperFunctions.isDarkMode(context);
    final textColor = isDarkMode ? TColors.white : TColors.dark;
    final hintColor = isDarkMode ? TColors.darkGrey : TColors.grey;
    final borderColor = isDarkMode ? TColors.darkerGrey : TColors.grey;
    const primaryColor = TColors.primary; // Màu chủ đạo của bạn

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          'Quản lý Key bản quyền',
            style: Theme.of(context).textTheme.headlineMedium
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent, // Nền trong suốt
        elevation: 0, // Bỏ đổ bóng
        //iconTheme: IconThemeData(color: textColor), // Màu icon Back
      ),
      body: SingleChildScrollView( // Để tránh overflow khi bàn phím hiện lên
        padding: const EdgeInsets.all(TSizes.defaultSpace), // Sử dụng hằng số padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch, // Kéo dãn các widget con
          children: [
            // 🔹 Icon hoặc Logo (tùy chọn)
            // Thêm một icon hoặc logo nhỏ để làm cho màn hình sinh động hơn
            const Icon(
              Icons.vpn_key_rounded,
              size: TSizes.imageThumbSize,
              color: TColors.primary,
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            // 🔹 Thời gian hết hạn
            Obx(() => Text(
              controller.expireDateText.value,
              textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall
            )),
            const SizedBox(height: TSizes.sm),

            // 🔹 Thời gian còn lại
            /*Obx(() => Text(
              controller.remainingTimeText.value,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium!.copyWith( // Thường dùng titleMedium/titleLarge thay vì headlineMedium
                fontSize: TSizes.fontSizeMd, // Sử dụng font size nhỏ hơn nếu cần
                color: controller.isKeyExpired.value ? TColors.warning : TColors.success,
              ),
            ),
            ),*/
            const SizedBox(height: TSizes.spaceBtwSections),

            // 🔹 Input Field Key
            TextField(
              controller: controller.keyController,
              decoration: InputDecoration(
                labelText: 'Nhập Key bản quyền của bạn',
                hintText: 'VD: ABCDE-FGHIJ-KLMNO',
                labelStyle: Theme.of(context).textTheme.labelSmall,
                hintStyle: TextStyle(color: hintColor.withOpacity(0.6)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusLg), // Bo tròn hơn
                  borderSide: BorderSide(color: borderColor),
                ),
                enabledBorder: OutlineInputBorder( // Viền khi không focus
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
                  borderSide: BorderSide(color: borderColor.withOpacity(0.8), width: 1),
                ),
                focusedBorder: OutlineInputBorder( // Viền khi focus
                  borderRadius: BorderRadius.circular(TSizes.borderRadiusLg),
                  borderSide: BorderSide(color: primaryColor, width: 2), // Màu chủ đạo khi focus
                ),
                prefixIcon: Icon(Icons.key, color: primaryColor), // Icon ở đầu
                contentPadding: const EdgeInsets.symmetric(vertical: TSizes.md, horizontal: TSizes.md), // Padding bên trong
              ),
              style: TextStyle(color: textColor), // Màu chữ nhập vào
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields), // Khoảng cách giữa input và button

            // 🔹 Nút Lưu Key
            Obx(() => SizedBox( // Dùng SizedBox để cố định chiều cao nút
              height: TSizes.buttonElevation,
              child: ElevatedButton(
                onPressed: controller.isLoading.value ? null : controller.saveKey,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: TColors.white)
                    : const Text('Xác nhận và Kích hoạt Key'),
              ),
            )),
            const SizedBox(height: TSizes.spaceBtwSections),

            // 🔹 Hướng dẫn hoặc thông tin thêm (tùy chọn)
            Text(
              'Liên hệ hỗ trợ 0979553398.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleSmall,
            ),


          ],
        ),
      ),
    );
  }
}




