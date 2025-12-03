import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/home.dart';
import '../home/note_list_page.dart';
import '../navigation_menu.dart';
import '../theme/constants/colors.dart'; // import HomeScreen

class KeyController extends GetxController with WidgetsBindingObserver {
  // 1. Thêm thuộc tính Reactive cho ngày hết hạn thực tế
  final expireDate = Rxn<DateTime>();

  var isLoading = false.obs;
  var remainingTimeText = '---'.obs; // để hiển thị thời gian còn lại
  var expireDateText = 'Chưa kích hoạt'.obs; // để hiển thị ngày hết hạn

  final TextEditingController keyController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 2. Bổ sung Reactive Getter (Sửa lỗi isKeyExpired)
  /// Kiểm tra xem Key đã hết hạn chưa. Trả về true nếu ngày hết hạn đã qua.
  RxBool get isKeyExpired {
    if (expireDate.value == null) {
      return false.obs;
    }
    return expireDate.value!.isBefore(DateTime.now()).obs;
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this); // Đăng ký observer
    fetchRemainingTime(); // check key khi khởi tạo
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this); // bỏ observer khi đóng
    super.onClose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Khi app trở lại foreground
      fetchRemainingTime();
    }
  }

  /// Lưu key vào document id "1"
  void saveKey() async {
    if (keyController.text.isEmpty) {
      Get.snackbar('Lỗi', 'Vui lòng nhập key', snackPosition: SnackPosition.BOTTOM);
      return;
    }

    try {
      isLoading.value = true;

      // 1. Lưu key vào Firestore
      await firestore.collection('key_active').doc('1').set({
        'keyValue': keyController.text,
        'createdAt': DateTime.now(),
      });

      keyController.clear();

      // 2. Cập nhật hiển thị thời gian còn lại (và cập nhật expireDate)
      await fetchRemainingTime();

      // 3. Kiểm tra trạng thái Key sau khi lưu
      if (!isKeyExpired.value) {
        Get.snackbar('Thành công', 'Key đã được kích hoạt thành công!',
            snackPosition: SnackPosition.BOTTOM,
            colorText: TColors.white,
            backgroundColor: TColors.success);
        // Chuyển sang HomeScreen
        Get.offAll(() => const NavigationMenu());
      } else {
        Get.snackbar('Lỗi', 'Key không hợp lệ hoặc đã hết hạn',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể lưu key: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  /// Lấy key và tính thời gian còn lại
  Future<void> fetchRemainingTime() async {
    try {
      final doc = await firestore.collection('key_active').doc('1').get();
      if (!doc.exists) {
        remainingTimeText.value = "Chưa có key";
        expireDateText.value = "Chưa kích hoạt";
        expireDate.value = null;
        return;
      }

      final key = doc['keyValue'] as String;
      final createdAt = (doc['createdAt'] as Timestamp).toDate();

      final parts = key.split('-');
      if (parts.length != 2) throw Exception("Format Key không hợp lệ.");

      final base64Part = parts[0];
      String raw;
      try {
        final paddedBase64 =
        base64Part.padRight(base64Part.length + (4 - base64Part.length % 4) % 4, '=');
        raw = String.fromCharCodes(base64Url.decode(paddedBase64));
      } catch (e) {
        throw Exception("Lỗi giải mã Base64.");
      }

      final segments = raw.split('|');
      if (segments.length != 4) throw Exception("Dữ liệu Key không đầy đủ.");

      final mode = segments[0];
      final amount = int.tryParse(segments[1]) ?? 0;

      // Khởi tạo ngày hết hạn
      DateTime calculatedExpireDate;
      if (mode == "MIN") {
        calculatedExpireDate = createdAt.add(Duration(minutes: amount));
      } else if (mode == "D") {
        calculatedExpireDate = createdAt.add(Duration(days: amount));
      } else if (mode == "M") {
        calculatedExpireDate = createdAt.add(Duration(days: amount * 30));
      } else {
        calculatedExpireDate = createdAt;
      }

      expireDate.value = calculatedExpireDate;

      final now = DateTime.now();
      final diff = calculatedExpireDate.difference(now);

      final formatter = DateFormat('dd/MM/yyyy');
      expireDateText.value = "Hết hạn: ${formatter.format(calculatedExpireDate)}";

      if (diff.isNegative) {
        remainingTimeText.value = "Key đã hết hạn";
      } else {
        final days = diff.inDays;
        final hours = diff.inHours % 24;
        remainingTimeText.value = "$days ngày, $hours giờ còn lại";
      }

      // Nếu key còn hạn và đang ở màn hình nhập key, tự động chuyển Home
      if (!diff.isNegative && Get.currentRoute == '/key_screen') {
        Get.offAll(() => const NavigationMenu());
      }
    } catch (e) {
      expireDate.value = null;
      remainingTimeText.value = "Lỗi tính thời gian";
      expireDateText.value = "Key lỗi hoặc không hợp lệ";
    }
  }
}
