import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

const secret = "hungnv.haui@gmail.com";

class KeyController extends GetxController {
  final keyController = TextEditingController();

  final isLoading = false.obs;
  final expireDateText = "Chưa kích hoạt key".obs;
  final isKeyExpired = true.obs;

  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Lưu key lên Firestore
  Future<void> saveKey() async {
    final key = keyController.text.trim();
    if (key.isEmpty) return;

    isLoading.value = true;

    final valid = _verifyKey(key);

    if (!valid) {
      Get.snackbar("Lỗi", "Key không hợp lệ hoặc đã hết hạn");
      isLoading.value = false;
      return;
    }

    // 🔥 LƯU KEY
    await firestore.collection('key_active').doc('1').set({
      'keyValue': key,
    });

    fetchRemainingTime();
    Get.snackbar("Thành công", "Kích hoạt key thành công");

    isLoading.value = false;
  }

  /// Hiển thị ngày hết hạn
  Future<void> fetchRemainingTime() async {
    try {
      final doc = await firestore.collection('key_active').doc('1').get();
      if (!doc.exists) return;

      final key = doc['keyValue'];
      final expireDate = _getExpireDate(key);

      if (expireDate == null) return;

      final now = DateTime.now();

      if (now.isAfter(expireDate)) {
        isKeyExpired.value = true;
        expireDateText.value = "Key đã hết hạn";
      } else {
        isKeyExpired.value = false;
        expireDateText.value =
        "Hết hạn ngày ${expireDate.day}/${expireDate.month}/${expireDate.year}";
      }
    } catch (_) {}
  }

  /// ================= VERIFY =================
  bool _verifyKey(String key) {
    try {
      final parts = key.split("-");
      if (parts.length != 2) return false;

      final raw = utf8.decode(base64Url.decode(parts[0]));
      final sig = parts[1];

      final segments = raw.split("|");
      if (segments.length != 3) return false;

      if (segments[0] != "EXP") return false;

      final expireDate = DateTime.tryParse(segments[1]);
      if (expireDate == null) return false;

      final expectedSig = Hmac(sha256, utf8.encode(secret))
          .convert(utf8.encode(raw))
          .toString()
          .substring(0, 8);

      if (sig != expectedSig) return false;

      if (DateTime.now().isAfter(expireDate)) return false;

      return true;
    } catch (_) {
      return false;
    }
  }

  DateTime? _getExpireDate(String key) {
    try {
      final raw = utf8.decode(base64Url.decode(key.split("-")[0]));
      return DateTime.tryParse(raw.split("|")[1]);
    } catch (_) {
      return null;
    }
  }
}
