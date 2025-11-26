// File: key_controller.dart (Phiên bản đã tối ưu và sửa lỗi)

import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home/home.dart';
import '../home/list_note_page.dart';
import '../theme/constants/colors.dart'; // import HomeScreen

class KeyController extends GetxController {
  // 1. Thêm thuộc tính Reactive cho ngày hết hạn thực tế
  final expireDate = Rxn<DateTime>();

  var isLoading = false.obs;
  // var keyInput = ''.obs; // Không cần thiết nếu dùng TextEditingController
  var remainingTimeText = '---'.obs; // để hiển thị thời gian còn lại
  var expireDateText = 'Chưa kích hoạt'.obs; // để hiển thị ngày hết hạn

  final TextEditingController keyController = TextEditingController();
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  // 2. Bổ sung Reactive Getter (Sửa lỗi isKeyExpired)
  /// Kiểm tra xem Key đã hết hạn chưa. Trả về true nếu ngày hết hạn đã qua.
  RxBool get isKeyExpired {
    if (expireDate.value == null) {
      // Nếu chưa có ngày hết hạn (chưa kích hoạt/key lỗi), coi như chưa hết hạn
      return false.obs;
    }
    // Trả về true nếu ngày hết hạn đã qua DateTime.now()
    return expireDate.value!.isBefore(DateTime.now()).obs;
  }

  @override
  void onInit() {
    super.onInit();
    // Gọi hàm tính toán thời gian khi Controller được khởi tạo
    fetchRemainingTime();
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
        'createdAt': DateTime.now(), // lưu cả giờ/phút/giây
      });

      keyController.clear();

      // 2. Cập nhật hiển thị thời gian còn lại (và cập nhật expireDate)
      await fetchRemainingTime();

      // 3. Kiểm tra trạng thái Key sau khi lưu
      if (!isKeyExpired.value) {
        Get.snackbar('Thành công', 'Key đã được kích hoạt thành công!', snackPosition: SnackPosition.BOTTOM, colorText: TColors.white, backgroundColor: TColors.success);
        // Chuyển sang HomeScreen
        Get.offAll(() => const HomeScreen());
      } else {
        // Nếu isKeyExpired là true ngay sau khi lưu (Key có thời hạn ngắn hơn thời gian tính toán/key hết hạn)
        Get.snackbar('Lỗi', 'Key không hợp lệ hoặc đã hết hạn', snackPosition: SnackPosition.BOTTOM);
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
        expireDate.value = null; // Cập nhật ngày hết hạn là null
        return;
      }

      final key = doc['keyValue'] as String;
      final createdAt = (doc['createdAt'] as Timestamp).toDate();

      final parts = key.split('-');
      if (parts.length != 2) throw Exception("Format Key không hợp lệ.");

      final base64Part = parts[0];
      // Xử lý base64 an toàn hơn
      String raw;
      try {
        final paddedBase64 = base64Part.padRight(base64Part.length + (4 - base64Part.length % 4) % 4, '=');
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
        // Ước tính 1 tháng = 30 ngày. Cần xem xét nếu muốn chính xác hơn
        calculatedExpireDate = createdAt.add(Duration(days: amount * 30));
      } else {
        calculatedExpireDate = createdAt; // Key không có thời hạn
      }

      // 3. Cập nhật Rxn<DateTime>
      expireDate.value = calculatedExpireDate;

      final now = DateTime.now();
      final diff = calculatedExpireDate.difference(now);

      // 4. Cập nhật hiển thị UI
      final formatter = DateFormat('dd/MM/yyyy'); // Định dạng ngày/tháng/năm

      expireDateText.value = "Hết hạn: ${formatter.format(calculatedExpireDate)}"; // Định dạng gọn hơn

      if (diff.isNegative) {
        remainingTimeText.value = "Key đã hết hạn";
      } else {
        final days = diff.inDays;
        final hours = diff.inHours % 24;
        remainingTimeText.value = "$days ngày, $hours giờ còn lại";
      }

    } catch (e) {
      expireDate.value = null;
      remainingTimeText.value = "Lỗi tính thời gian";
      expireDateText.value = "Key lỗi hoặc không hợp lệ";
    }
  }
}