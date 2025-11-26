import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';

const secret = "hungnv.haui@gmail.com";

class LicenseChecker {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  /// Trả về số phút còn lại, false nếu hết hạn hoặc không tồn tại
  Future<bool> isKeyValid() async {
    try {
      final doc = await firestore.collection('key_active').doc('1').get();
      if (!doc.exists) return false;

      final key = doc['keyValue'] as String;

      // Tách key: base64-signature
      final parts = key.split('-');
      if (parts.length != 2) return false;

      final base64Part = parts[0];
      final raw = utf8.decode(
        base64Url.decode(
          base64Part.padRight(base64Part.length + (4 - base64Part.length % 4) % 4, '='),
        ),
      );

      final segments = raw.split('|');
      if (segments.length != 4) return false;

      final mode = segments[0];
      final amount = int.tryParse(segments[1]) ?? 0;
      final createdDateStr = segments[2];
      final nonce = segments[3];

      // Chuyển sang DateTime đầy đủ giờ/phút/giây nếu lưu dạng milliseconds
      final createdDate = DateTime.tryParse(createdDateStr);
      if (createdDate == null) return false;

      final now = DateTime.now();
      final diff = now.difference(createdDate);

      if (mode == "MIN") {
        // Kiểm tra số phút còn lại chính xác
        return diff.inMinutes < amount;
      } else if (mode == "D") {
        return diff.inDays < amount;
      } else if (mode == "M") {
        return diff.inDays < amount * 30; // ước lượng tháng = 30 ngày
      }

      return false;
    } catch (e) {
      print("Lỗi kiểm tra key: $e");
      return false;
    }
  }
}
