import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_contacts/flutter_contacts.dart';

import '../../client/product_history_model.dart';
import '../../navigation_menu.dart';
import '../../theme/constants/image_strings.dart';
import '../../theme/constants/popups/full_screen_loader.dart';
import '../../theme/constants/popups/loaders.dart';
import '../model/product_model.dart';

class CreateNoteController extends GetxController {
  static CreateNoteController get instance => Get.find();

  /// ================= CONTROLLERS =================
  final clientName = TextEditingController();
  final phoneNumber = TextEditingController();
  RxBool isDebt = false.obs;
  final Map<String, Map<String, ProductHistory>> customerProductHistory = {};

  /// ⭐ DÙNG CHO AUTOCOMPLETE KHÁCH HÀNG
  RxList<String> customerNames = <String>[].obs;

  /// ⭐ DÙNG CHO AUTOCOMPLETE SẢN PHẨM
  RxList<String> productNameSuggestions = <String>[].obs;

  /// ================= NHẬP SẢN PHẨM =================
  final createProductName = TextEditingController();
  final createPrice = TextEditingController();
  final createQty = TextEditingController();
  final createUnit = TextEditingController();
  final createTotal = TextEditingController();

  /// ================= DANH SÁCH SP =================
  RxList<ProductModel> productList = <ProductModel>[].obs;

  GlobalKey<FormState> CreateNoteFormKey = GlobalKey<FormState>();
  late final NavigationController nav;
  @override
  void onInit() {
    super.onInit();
    createPrice.addListener(recalculateCreateTotal);
    createQty.addListener(recalculateCreateTotal);
    nav = Get.find<NavigationController>();
    ever(nav.selectedIndex, (index) {
      if (index == 1) { // index tab CreateNote
        reloadSuggestions();
      }
    });
  }

  /// =================================================
  Future<void> reloadSuggestions() async {
    await fetchCustomerNames();
    await fetchProductNames();
  }
  /// ⭐ 1. LẤY TÊN KHÁCH HÀNG (AUTOCOMPLETE)
  Future<void> fetchCustomerNames() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection("notes").get();

      final names = snapshot.docs
          .map((doc) => doc.data()['clientName'])
          .where((e) => e != null && e.toString().trim().isNotEmpty)
          .map((e) => e.toString())
          .toSet()
          .toList()
        ..sort();

      customerNames.assignAll(names);
    } catch (e) {
      debugPrint("Lỗi load khách hàng: $e");
    }
  }

  /// ⭐ 2. LẤY TÊN SẢN PHẨM (AUTOCOMPLETE)
  Future<void> fetchProductNames() async {
    try {
      final snapshot =
      await FirebaseFirestore.instance.collection("notes").get();

      final Set<String> names = {};

      for (final doc in snapshot.docs) {
        final products = doc.data()['products'];
        if (products is List) {
          for (final p in products) {
            final name = p['nameProduct'];
            if (name != null && name.toString().trim().isNotEmpty) {
              names.add(name.toString());
            }
          }
        }
      }

      productNameSuggestions.assignAll(names.toList()..sort());
    } catch (e) {
      debugPrint("Lỗi load sản phẩm: $e");
    }
  }

  void resetForm() {
    // Reset thông tin khách
    // clientName không reset ở đây vì người dùng đang gõ tên mới
    phoneNumber.clear();

    // Reset thông tin sản phẩm đang nhập
    createProductName.clear();
    createPrice.clear();
    createQty.clear();
    createUnit.clear();
    createTotal.clear();

    // Xóa danh sách sản phẩm đã thêm
    productList.clear();
  }

  void autoFillProductFromHistory(String productName) {
    final client = clientName.text.trim();
    if (client.isEmpty) return;

    final history = customerProductHistory[client]?[productName];
    if (history == null) return;

    createPrice.text =
        NumberFormat('#,###', 'vi_VN').format(history.price);
    createUnit.text = history.unit;

    recalculateCreateTotal();
  }

  /// =================================================
  /// ⭐ 3. TỰ ĐIỀN SĐT KHI CHỌN KHÁCH
  Future<void> fillInfoFromHistory(String client) async {
    print('👉 load history for $client');

    clientName.text = client;

    final snap = await FirebaseFirestore.instance
        .collection('notes')
        .where('clientName', isEqualTo: client)
        .get();

    if (snap.docs.isEmpty) {
      print('❌ no history found');
      return;
    }

    /// ✅ SĐT
    final phone = snap.docs.first.data()['phoneNumber'];
    phoneNumber.text = phone ?? '';
    print('✅ phone = $phone');

    final Map<String, ProductHistory> map = {};

    for (final doc in snap.docs) {
      final products = List<Map<String, dynamic>>.from(
        doc.data()['products'] ?? [],
      );

      for (final p in products) {
        final name = p['nameProduct'];
        if (name == null) continue;

        map[name] = ProductHistory(
          price: (p['price'] ?? 0).toInt(),
          unit: p['unit'] ?? '',
        );
      }
    }

    customerProductHistory[client] = map;
    productNameSuggestions.assignAll(map.keys.toList());

    print('✅ products = ${map.keys}');
  }


  /// =================================================
  /// 4. CHỌN SĐT TỪ DANH BẠ
  void selectContact() async {
    final status = await Permission.contacts.request();

    if (!status.isGranted) {
      TLoaders.warningSnackBar(
          title: 'Quyền truy cập',
          message: 'Vui lòng cấp quyền danh bạ');
      return;
    }

    try {
      final Contact? contact = await FlutterContacts.openExternalPick();
      if (contact != null && contact.phones.isNotEmpty) {
        String num =
        contact.phones.first.number.replaceAll(RegExp(r'[^\d]'), '');
        if (num.startsWith('84')) {
          num = '0${num.substring(2)}';
        }
        phoneNumber.text = num;
      }
    } catch (_) {
      TLoaders.errorSnackBar(
          title: 'Lỗi', message: 'Không thể mở danh bạ');
    }
  }

  /// =================================================
  /// 5. GIÁ – QTY – TOTAL
  void onPriceChanged(String value) {
    final onlyNum = value.replaceAll(RegExp(r'[^0-9]'), '');
    if (onlyNum.isEmpty) {
      createPrice.text = '';
      recalculateCreateTotal();
      return;
    }

    final n = int.parse(onlyNum);
    final formatted = NumberFormat('#,###', 'vi_VN').format(n);

    createPrice.value = TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );

    recalculateCreateTotal();
  }

  void recalculateCreateTotal() {
    final p =
        int.tryParse(createPrice.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0;
    final q = int.tryParse(createQty.text) ?? 0;
    createTotal.text =
        NumberFormat('#,###', 'vi_VN').format(p * q);
  }

  /// =================================================
  /// 6. THÊM SẢN PHẨM
  void addProduct() {
    final price =
        double.tryParse(createPrice.text.replaceAll(RegExp(r'[^0-9]'), '')) ??
            0;
    final qty = int.tryParse(createQty.text) ?? 0;

    if (qty <= 0) {
      TLoaders.warningSnackBar(
          title: 'Lỗi', message: 'Vui lòng nhập số lượng');
      return;
    }

    productList.add(ProductModel(
      nameProduct:
      createProductName.text.isEmpty ? 'Sản phẩm' : createProductName.text,
      price: price,
      qty: qty,
      unit: createUnit.text,
      total: price * qty,
    ));

    createProductName.clear();
    createPrice.clear();
    createQty.clear();
    createUnit.clear();
    createTotal.clear();
  }

  /// =================================================
  /// 7. LƯU FIREBASE
  Future<void> create_note() async {
    if (!CreateNoteFormKey.currentState!.validate()) return;
    if (productList.isEmpty) {
      TLoaders.warningSnackBar(
          title: 'Trống', message: 'Vui lòng thêm sản phẩm');
      return;
    }

    try {
      TFullScreenLoader.openLoadingDialog(
          'Đang tạo phiếu...', TImages.checkcreate_note);

      final products = productList.map((p) => {
        "nameProduct": p.nameProduct,
        "price": p.price,
        "qty": p.qty,
        "unit": p.unit,
        "total": p.total,
      }).toList();

      final totalAll =
      products.fold<double>(0, (s, e) => s + (e['total'] as double));

      await FirebaseFirestore.instance.collection("notes").add({
        "clientName": clientName.text.trim(),
        "phoneNumber": phoneNumber.text.trim(),
        "debt": isDebt.value,
        "totalAll": totalAll,
        "products": products,
        "createdAt": DateTime.now(),
      });

      TFullScreenLoader.stopLoading();
      TLoaders.successSnackBar(
          title: 'Thành công', message: 'Đã tạo phiếu');

      _resetForm();
      Get.find<NavigationController>().selectedIndex.value = 0;
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Lỗi', message: e.toString());
    }
  }

  void _resetForm() {
    clientName.clear();
    phoneNumber.clear();
    productList.clear();
    isDebt.value = false;
    FocusScope.of(Get.context!).unfocus();
  }

  @override
  void onClose() {
    clientName.dispose();
    phoneNumber.dispose();
    createProductName.dispose();
    createPrice.dispose();
    createQty.dispose();
    createUnit.dispose();
    createTotal.dispose();
    super.onClose();
  }
}
