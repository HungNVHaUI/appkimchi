import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../theme/constants/popups/full_screen_loader.dart';
import 'purchar_model.dart';

class CustomersController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = true.obs;
  final RxList<CustomerInfo> customers = <CustomerInfo>[].obs;

  // 1. Thêm danh sách gợi ý sản phẩm
  final RxList<String> productNameSuggestions = <String>[].obs;
  final RxnString selectedReturnProduct = RxnString();
  final NumberFormat _fmt = NumberFormat('#,###', 'vi_VN');

  StreamSubscription? _notesSub;
  StreamSubscription? _paymentsSub;

  List<QueryDocumentSnapshot> _notesDocs = [];
  List<QueryDocumentSnapshot> _paymentsDocs = [];

  // Controllers cho UI Trả hàng (Đã có trong code của bạn)
  final returnQty = TextEditingController();
  final returnPrice = TextEditingController();
  final returnTotal = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _listenRealtime();
  }

  @override
  void onClose() {
    _notesSub?.cancel();
    _paymentsSub?.cancel();
    returnQty.dispose();
    returnPrice.dispose();
    returnTotal.dispose();
    super.onClose();
  }

  String formatNumber(num v) => _fmt.format(v);

  // 2. Hàm tìm giá cũ dựa trên cấu trúc: products -> nameProduct -> price
  num getLatestPriceForProduct(String customerName, String productName) {
    try {
      for (var doc in _notesDocs) {
        final data = doc.data() as Map<String, dynamic>;
        final nameInDoc = (data['clientName'] ?? '').toString().trim().toLowerCase();

        if (nameInDoc == customerName.trim().toLowerCase()) {
          final List products = data['products'] as List? ?? [];
          final product = products.firstWhereOrNull((p) =>
          (p['nameProduct'] ?? '').toString().trim().toLowerCase() == productName.trim().toLowerCase()
          );

          if (product != null) {
            return _getNum(product['price']);
          }
        }
      }
    } catch (e) {
      debugPrint("Lỗi tìm giá cũ: $e");
    }
    return 0;
  }

  // Helper lấy số (Đưa ra ngoài để dùng chung)
  num _getNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    if (v is String) return num.tryParse(v) ?? 0;
    return 0;
  }

  CustomerInfo getCustomerByName(String name) {
    try {
      return customers.firstWhere(
            (c) => c.name.trim().toLowerCase() == name.trim().toLowerCase(),
      );
    } catch (_) {
      return CustomerInfo(
        name: name,
        phoneNumbers: [],
        purchases: [],
        payments: [],
        totalDebt: 0,
      );
    }
  }

  // ----------------------------------------------------------------------
  // LISTEN REALTIME
  // ----------------------------------------------------------------------
  void _listenRealtime() {
    isLoading.value = true;

    _notesSub = _db
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) async {
      _notesDocs = snapshot.docs;

      final Set<String> noteClients = {};
      for (final doc in _notesDocs) {
        final data = doc.data() as Map<String, dynamic>;
        final name = (data['clientName'] ?? '').toString().trim();
        if (name.isNotEmpty) noteClients.add(name);
      }

      // Xây dựng lại danh sách gợi ý sản phẩm từ tất cả hóa đơn
      _updateProductSuggestions();

      _rebuildCustomerList();
    });

    _paymentsSub = _db
        .collection('payments')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _paymentsDocs = snapshot.docs;
      _rebuildCustomerList();
    });
  }

  // 3. Hàm cập nhật danh sách tên sản phẩm duy nhất
  void _updateProductSuggestions() {
    final Set<String> allProductNames = {};
    for (final doc in _notesDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final List products = data['products'] as List? ?? [];
      for (var p in products) {
        final name = (p['nameProduct'] ?? '').toString().trim();
        if (name.isNotEmpty) allProductNames.add(name);
      }
    }
    productNameSuggestions.assignAll(allProductNames.toList()..sort());
  }

// 1. Hàm lấy danh sách tên sản phẩm duy nhất mà khách này đã mua
  List<String> getProductsBoughtByCustomer(String customerName) {
    final Set<String> boughtProducts = {};
    for (var doc in _notesDocs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data['clientName']?.toString().trim() == customerName.trim()) {
        final List products = data['products'] as List? ?? [];
        for (var p in products) {
          final name = (p['nameProduct'] ?? '').toString().trim();
          if (name.isNotEmpty) boughtProducts.add(name);
        }
      }
    }
    return boughtProducts.toList()..sort();
  }

  // 2. Hàm lấy thông tin Giá và Đơn vị từ lịch sử mua của khách
  Map<String, dynamic> getProductInfoFromHistory(String customerName, String productName) {
    try {
      for (var doc in _notesDocs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data['clientName']?.toString().trim() == customerName.trim()) {
          final List products = data['products'] as List? ?? [];
          final p = products.firstWhereOrNull((item) =>
          (item['nameProduct'] ?? '').toString().trim() == productName.trim()
          );
          if (p != null) {
            return {
              'price': _getNum(p['price']),
              'unit': (p['unit'] ?? '').toString(),
            };
          }
        }
      }
    } catch (e) {
      debugPrint("Lỗi lấy thông tin lịch sử: $e");
    }
    return {'price': 0, 'unit': ''};
  }

  void _rebuildCustomerList() {
    final Map<String, CustomerInfo> map = {};

    String _getString(dynamic v) => v?.toString() ?? '';

    DateTime? _getTimestamp(dynamic v) {
      if (v == null) return null;
      if (v is Timestamp) return v.toDate();
      return null;
    }

    bool _getBool(dynamic v) {
      if (v is bool) return v;
      return v?.toString().toLowerCase() == 'true';
    }

    final Set<String> noteClients = {};

    for (final doc in _notesDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final name = _getString(data['clientName']).trim();
      if (name.isEmpty) continue;

      noteClients.add(name);
      final phone = _getString(data['phoneNumber']).trim();
      final createdAt = _getTimestamp(data['createdAt']) ?? DateTime.now();
      final totalAll = _getNum(data['totalAll']);
      final debt = _getBool(data['debt']);

      map.putIfAbsent(name, () => CustomerInfo(name: name, phoneNumbers: [], purchases: [], payments: [], totalDebt: 0));
      if (phone.isNotEmpty && !map[name]!.phoneNumbers.contains(phone)) {
        map[name]!.phoneNumbers.add(phone);
      }

      map[name]!.purchases.add(PurchaseInfo(amount: totalAll, date: createdAt, debt: debt));
    }

    for (final doc in _paymentsDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final name = _getString(data['clientName']).trim();

      if (!noteClients.contains(name)) continue;

      final amount = _getNum(data['amount']);
      final createdAt = _getTimestamp(data['createdAt']) ?? DateTime.now();
      final note = _getString(data['note']); // Lấy thêm trường note

      map.putIfAbsent(name, () => CustomerInfo(name: name, phoneNumbers: [], purchases: [], payments: [], totalDebt: 0));

      map[name]!.payments.add(PaymentInfo(
        amount: amount,
        date: createdAt,
        note: note, // Gán note vào PaymentInfo
      ));
    }

    final list = map.values.toList();
    for (final c in list) {
      final totalPurchases = c.purchases.fold<num>(0.0, (s, p) => s + (p.debt ? p.amount : 0));
      final totalPayments = c.payments.fold<num>(0.0, (s, p) => s + p.amount);
      num realDebt = totalPurchases - totalPayments;
      c.totalDebt = realDebt < 0 ? 0 : realDebt;
    }

    list.sort((a, b) {
      final cmp = b.totalDebt.compareTo(a.totalDebt);
      return cmp != 0 ? cmp : a.name.compareTo(b.name);
    });

    customers.assignAll(list);
    isLoading.value = false;
  }

  // Các hàm nghiệp vụ khác
  void recalculateReturnTotal() {
    final qty = double.tryParse(returnQty.text) ?? 0;
    final price = num.tryParse(returnPrice.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    returnTotal.text = _fmt.format(qty * price);
  }

  Future<void> payTemporary(String clientName, num amount, {String? note}) async {
    if (amount <= 0) return;
    await _db.collection('payments').add({
      'clientName': clientName,
      'amount': amount,
      'note': note ?? "Tạm ứng tiền mặt",
      'createdAt': Timestamp.now(),
    });
  }

  Future<void> deletePayment(String clientName, PaymentInfo payment) async {
    try {
      final snapshot = await _db.collection('payments')
          .where('clientName', isEqualTo: clientName)
          .where('amount', isEqualTo: payment.amount)
          .get();

      for (var doc in snapshot.docs) {
        final DateTime? docDate = _getTimestamp(doc.data()['createdAt']);
        if (docDate != null && docDate.millisecondsSinceEpoch == payment.date.millisecondsSinceEpoch) {
          await doc.reference.delete();
          break;
        }
      }
    } catch (e) {
      debugPrint('Lỗi khi xóa: $e');
    }
  }

  Future<void> deleteAllByClientName(String name) async {
    try {
      final notesQuery = await _db.collection('notes').where('clientName', isEqualTo: name).get();
      final paymentsQuery = await _db.collection('payments').where('clientName', isEqualTo: name).get();
      WriteBatch batch = _db.batch();
      for (var doc in notesQuery.docs) batch.delete(doc.reference);
      for (var doc in paymentsQuery.docs) batch.delete(doc.reference);
      await batch.commit();
    } catch (e) {
      debugPrint('Lỗi xoá: $e');
    }
  }

  DateTime? _getTimestamp(dynamic v) {
    if (v is Timestamp) return v.toDate();
    return null;
  }
}