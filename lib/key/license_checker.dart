import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

const secret = "hungnv.haui@gmail.com"; // PHẢI GIỐNG TOOL TẠO KEY

class LicenseChecker {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Trả về true nếu key hợp lệ & chưa hết hạn
  Future<bool> isKeyValid() async {
    try {
      // 🔥 Lấy key từ Firestore
      final doc = await firestore.collection('key_active').doc('1').get();
      if (!doc.exists) return false;

      final key = doc['keyValue'] as String;
      if (key.isEmpty) return false;

      return _verifyKey(key);
    } catch (e) {
      print("❌ Lỗi kiểm tra key: $e");
      return false;
    }
  }

  /// ================= VERIFY KEY =================
  bool _verifyKey(String key) {
    try {
      // key format: base64-signature
      final parts = key.split("-");
      if (parts.length != 2) return false;

      final base64Part = parts[0];
      final signature = parts[1];

      // decode base64
      final raw = utf8.decode(
        base64Url.decode(
          base64Part.padRight(
            base64Part.length + (4 - base64Part.length % 4) % 4,
            '=',
          ),
        ),
      );

      // raw format: EXP|YYYY-MM-DD|nonce
      final segments = raw.split("|");
      if (segments.length != 3) return false;

      final mode = segments[0];
      final expireDate = DateTime.tryParse(segments[1]);

      if (mode != "EXP" || expireDate == null) return false;

      // 🔐 verify signature
      final expectedSig = Hmac(sha256, utf8.encode(secret))
          .convert(utf8.encode(raw))
          .toString()
          .substring(0, 8);

      if (signature != expectedSig) return false;

      // ⏳ check expiry
      final now = DateTime.now();

      // Nếu muốn hết hạn CUỐI NGÀY → dùng isAfter(expireDate.add(Duration(days:1)))
      if (now.isAfter(expireDate)) return false;

      return true;
    } catch (e) {
      print("❌ Verify key error: $e");
      return false;
    }
  }
}
