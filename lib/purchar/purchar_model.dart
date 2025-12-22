// lib/purchar/purchar_model.dart

class PurchaseInfo {
  final num amount;       // số tiền
  final DateTime date;    // ngày tạo note
  final bool debt;        // true nếu là nợ

  PurchaseInfo({
    required this.amount,
    required this.date,
    required this.debt,
  });
}

class PaymentInfo {
  final num amount;
  final DateTime date;
  final String note; // Thêm dòng này

  PaymentInfo({
    required this.amount,
    required this.date,
    this.note = "Tạm ứng tiền mặt" // Thêm mặc định
  });
}

class CustomerInfo {
  final String name;
  final List<String> phoneNumbers;
  final List<PurchaseInfo> purchases;
  final List<PaymentInfo> payments;
  num totalDebt; // tổng còn nợ (tổng purchases có debt - tổng payments)

  CustomerInfo({
    required this.name,
    required this.phoneNumbers,
    required this.purchases,
    required this.payments,
    required this.totalDebt,
  });
}
