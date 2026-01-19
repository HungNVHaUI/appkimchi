import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../create_note/model/note_model.dart';
import 'purchar_model.dart';


class CustomersController extends GetxController {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final RxBool isLoading = true.obs;
  final RxString searchText = ''.obs;

  /// 🔹 DANH SÁCH GỐC (Data nguồn)
  final RxList<CustomerInfo> customers = <CustomerInfo>[].obs;

  /// 🔹 DANH SÁCH HIỂN THỊ (Dùng cho ListView)
  final RxList<CustomerInfo> filteredCustomers = <CustomerInfo>[].obs;

  final RxList<String> productNameSuggestions = <String>[].obs;
  final RxnString selectedReturnProduct = RxnString();
  final NumberFormat _fmt = NumberFormat('#,###', 'vi_VN');

  StreamSubscription? _notesSub;
  StreamSubscription? _paymentsSub;

  List<QueryDocumentSnapshot> _notesDocs = [];
  List<QueryDocumentSnapshot> _paymentsDocs = [];

  final returnQty = TextEditingController();
  final returnPrice = TextEditingController();
  final returnTotal = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _listenRealtime();

    /// 🔹 Debounce 300ms: Đợi người dùng ngừng gõ 300ms mới lọc danh sách
    debounce(
      searchText,
          (_) => _applyFilter(),
      time: const Duration(milliseconds: 300),
    );
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

  // ----------------------------------------------------------------------
  // TIỆN ÍCH SEARCH KHÔNG DẤU
  // ----------------------------------------------------------------------
  String _removeDiacritics(String str) {
    const vietnamese = 'àáạảãâầấậẩẫăằắặẳẵèéẹẻẽêềếệểễìíịỉĩòóọỏõôồốộổỗơờớợởỡùúụủũưừứựửữỳýỵỷỹđ'
        'ÀÁẠẢÃÂẦẤẬẨẪĂẰẮẶẲẴÈÉẸẺẼÊỀẾỆỂỄÌÍỊỈĨÒÓỌỎÕÔỒỐỘỔỖƠỜỚỢỞỠÙÚỤỦŨƯỪỨỰỬỮỲÝỴỶỸĐ';
    const latin = 'aaaaaaaaaaaaaaaaaeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyd'
        'AAAAAAAAAAAAAAAAAEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYYD';

    for (int i = 0; i < vietnamese.length; i++) {
      str = str.replaceAll(vietnamese[i], latin[i]);
    }
    return str;
  }

  void _applyFilter() {
    final keyword = _removeDiacritics(searchText.value.toLowerCase().trim());

    if (keyword.isEmpty) {
      filteredCustomers.assignAll(customers);
      return;
    }

    filteredCustomers.assignAll(
      customers.where((c) {
        final nameNormalized = _removeDiacritics(c.name.toLowerCase());
        return nameNormalized.contains(keyword);
      }).toList(),
    );
  }

  // ----------------------------------------------------------------------
  // LISTEN REALTIME & REBUILD DATA
  // ----------------------------------------------------------------------
  void _listenRealtime() {
    isLoading.value = true;

    _notesSub = _db
        .collection('notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      _notesDocs = snapshot.docs;
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

  void _rebuildCustomerList() {
    final Map<String, CustomerInfo> map = {};

    String getString(dynamic v) => v?.toString() ?? '';
    bool getBool(dynamic v) => v is bool ? v : v?.toString().toLowerCase() == 'true';

    final Set<String> noteClients = {};

    for (final doc in _notesDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final name = getString(data['clientName']).trim();
      if (name.isEmpty) continue;

      noteClients.add(name);
      final phone = getString(data['phoneNumber']).trim();
      final createdAt = _getTimestamp(data['createdAt']) ?? DateTime.now();
      final totalAll = _getNum(data['totalAll']);
      final debt = getBool(data['debt']);

      map.putIfAbsent(name, () => CustomerInfo(name: name, phoneNumbers: [], purchases: [], payments: [], totalDebt: 0));

      if (phone.isNotEmpty && !map[name]!.phoneNumbers.contains(phone)) {
        map[name]!.phoneNumbers.add(phone);
      }

      final noteModel = NoteModel.fromSnapshot(doc as QueryDocumentSnapshot<Map<String, dynamic>>);
      map[name]!.purchases.add(PurchaseInfo(note: noteModel, amount: totalAll, date: createdAt, debt: debt));
    }

    for (final doc in _paymentsDocs) {
      final data = doc.data() as Map<String, dynamic>;
      final name = getString(data['clientName']).trim();

      if (!noteClients.contains(name)) continue;

      final amount = _getNum(data['amount']);
      final createdAt = _getTimestamp(data['createdAt']) ?? DateTime.now();
      final noteText = getString(data['note']);

      map.putIfAbsent(name, () => CustomerInfo(name: name, phoneNumbers: [], purchases: [], payments: [], totalDebt: 0));
      map[name]!.payments.add(PaymentInfo(amount: amount, date: createdAt, note: noteText));
    }

    final list = map.values.toList();
    for (final c in list) {
      final totalPurchases = c.purchases.fold<num>(0.0, (s, p) => s + (p.debt ? p.amount : 0));
      final totalPayments = c.payments.fold<num>(0.0, (s, p) => s + p.amount);
      num realDebt = totalPurchases - totalPayments;
      c.totalDebt = realDebt < 0 ? 0 : realDebt;
    }

    // Sắp xếp: Nợ nhiều lên trước, sau đó đến tên A-Z
    list.sort((a, b) {
      final cmp = b.totalDebt.compareTo(a.totalDebt);
      return cmp != 0 ? cmp : a.name.compareTo(b.name);
    });

    customers.assignAll(list);
    _applyFilter(); // 🔹 Cập nhật danh sách filter ngay khi data nguồn đổi
    isLoading.value = false;
  }

  // ----------------------------------------------------------------------
  // NGHIỆP VỤ HÓA ĐƠN & SẢN PHẨM
  // ----------------------------------------------------------------------
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
            return {'price': _getNum(p['price']), 'unit': (p['unit'] ?? '').toString()};
          }
        }
      }
    } catch (e) {
      debugPrint("Lỗi lấy thông tin lịch sử: $e");
    }
    return {'price': 0, 'unit': ''};
  }

  num getLatestPriceForProduct(String customerName, String productName) {
    final info = getProductInfoFromHistory(customerName, productName);
    return info['price'] as num;
  }

  CustomerInfo getCustomerByName(String name) {
    return customers.firstWhere(
          (c) => c.name.trim().toLowerCase() == name.trim().toLowerCase(),
      orElse: () => CustomerInfo(name: name, phoneNumbers: [], purchases: [], payments: [], totalDebt: 0),
    );
  }

  // ----------------------------------------------------------------------
  // CÁC HÀM THAO TÁC FIREBASE (Giao dịch)
  // ----------------------------------------------------------------------
  void recalculateReturnTotal() {
    final qty = double.tryParse(returnQty.text) ?? 0;
    final price = _getNum(returnPrice.text.replaceAll(RegExp(r'[^0-9]'), ''));
    returnTotal.text = _fmt.format(qty * price);
  }

  Future<void> payTemporary(String clientName, num amount, {String? note}) async {
    if (amount <= 0) return;
    await _db.collection('payments').add({
      'clientName': clientName,
      'amount': amount,
      'note': note ?? "Tạm ứng tiền mặt",
      'createdAt': FieldValue.serverTimestamp(),
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
      debugPrint('Lỗi xoá toàn bộ dữ liệu khách: $e');
    }
  }

  // ----------------------------------------------------------------------
  // HELPERS
  // ----------------------------------------------------------------------
  num _getNum(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v;
    if (v is String) return num.tryParse(v.replaceAll('.', '')) ?? 0;
    return 0;
  }

  DateTime? _getTimestamp(dynamic v) {
    if (v is Timestamp) return v.toDate();
    return null;
  }
}



