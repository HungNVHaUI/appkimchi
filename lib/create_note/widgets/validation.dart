


class TValidator {
  static String? validateEmptyText(String? fieldName, String? valve){
    if (valve == null || valve.isEmpty){
      return '$fieldName is required';
    }
    return null;
  }

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required.';
    }

    // Regular expression for email validation
    final emailRegExp = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');

    if (!emailRegExp.hasMatch(value)) {
      return 'Invalid email address.';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required.';
    }
    // Check for minimum password length
    if (value.length < 6) {
      return 'Password must be at least 6 characters long.';
    }

    // Check uppercase letters
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain least one uppercase letter';
    }

    // Check for special characters
    if (!value.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'))) {
      return 'Password must contain least one special character';
    }

    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại là bắt buộc.';
    }

    // 1. Loại bỏ các ký tự không phải số (khoảng trắng, dấu gạch ngang, v.v.)
    // và áp dụng chuẩn hóa (ví dụ: đổi 84 thành 0)
    String cleanValue = value.replaceAll(RegExp(r'[^\d]'), '');

    // 2. Tùy chọn: Chuẩn hóa 84 thành 0 cho mục đích validation
    // (Nếu logic formatPhoneNumber trong controller chưa được gọi/áp dụng)
    if (cleanValue.startsWith('84') && cleanValue.length >= 10) {
      cleanValue = '0' + cleanValue.substring(2);
    }

    // 3. Kiểm tra định dạng số điện thoại Việt Nam:
    // Thường là 10 chữ số, bắt đầu bằng 0 (sau khi chuẩn hóa)
    //final vnPhoneRegExp = RegExp(r'^0\d{9}$');

    // Hoặc kiểm tra 10 hoặc 11 chữ số (phổ biến)
    // final vnPhoneRegExp = RegExp(r'^\d{10,11}$');

    // if (!vnPhoneRegExp.hasMatch(cleanValue)) {
    //   return 'Số điện thoại không hợp lệ (cần 10 chữ số, bắt đầu bằng 0).';
    // }

    return null;
  }
}