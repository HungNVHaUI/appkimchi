import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../create_note/controller/price_controller.dart';
import '../../create_note/model/note_model.dart';
import '../../create_note/model/product_model.dart';

class NoteDetailController extends GetxController {
  final NoteModel initialNote;

  NoteDetailController(this.initialNote);

  // --- 1. STATE GetX ---
  final RxBool isEditing = false.obs;
  final RxBool debtStatus = false.obs;
  final RxDouble grandTotal = 0.0.obs;

  // Danh sách sản phẩm mutable
  late RxList<Map<String, dynamic>> mutableProducts;

  // Controllers cho TextFormField
  late TextEditingController clientNameController;
  late TextEditingController phoneNumberController;

  // PriceController cho mỗi sản phẩm
  late RxList<PriceController> priceControllers;
  late RxList<TextEditingController> nameControllers;
  late RxList<TextEditingController> unitControllers;
  @override
  @override
  void onInit() {
    super.onInit();

    // KHỞI TẠO THIẾU clientNameController → gây lỗi LateError
    clientNameController = TextEditingController(text: initialNote.clientName);
    phoneNumberController = TextEditingController(text: initialNote.phoneNumber);

    debtStatus.value = initialNote.debt;

    // Khởi tạo mutableProducts
    mutableProducts = _convertProductsToMutableList(initialNote).obs;

    // PriceControllers
    priceControllers = <PriceController>[].obs;
    for (var product in mutableProducts) {
      final c = PriceController();
      c.text = NumberFormat('#,###', 'vi_VN').format(product['price']);
      priceControllers.add(c);
    }

    // Name controllers
    nameControllers = mutableProducts
        .map((p) => TextEditingController(text: p['nameProduct'] as String))
        .toList()
        .obs;

    // Tính tổng ban đầu
    recalculateGrandTotal();
  }


  // --- 2. HÀM CHUYỂN ĐỔI ---
  List<Map<String, dynamic>> _convertProductsToMutableList(NoteModel note) {
    return note.products.map((p) {
      return {
        'nameProduct': p.nameProduct,
        'price': p.price.toDouble(),
        'qty': p.qty,
        'unit': p.unit,
        'total': p.total.toDouble(),
      };
    }).toList();
  }

  List<ProductModel> _convertMutableListToProducts(List<Map<String, dynamic>> list) {
    return list.map((item) {
      final price = item['price'] is int ? (item['price'] as int).toDouble() : item['price'] as double;
      final total = item['total'] is int ? (item['total'] as int).toDouble() : item['total'] as double;

      return ProductModel(
        nameProduct: item['nameProduct'] as String,
        price: price,
        qty: item['qty'] as int,
        total: total,
        unit: item['unit'] as String,
      );
    }).toList();
  }

  int safeParseInt(String text) => int.tryParse(text) ?? 0;

  double safeParsePrice(String text) {
    final cleanText = text.replaceAll(RegExp(r'[^0-9]'), '');
    return double.tryParse(cleanText) ?? 0.0;
  }

  // --- 3. HÀM TÍNH TOÁN ---
  void recalculateGrandTotal() {
    double sum = 0;
    for (var product in mutableProducts) {
      sum += product['total'] as double;
    }
    grandTotal.value = sum;
  }

  void recalculateItemTotal(int index) {
    final product = mutableProducts[index];
    final price = product['price'] as double;
    final qty = product['qty'] as int;
    final newTotal = price * qty;

    mutableProducts[index]['total'] = newTotal;
    recalculateGrandTotal();
    mutableProducts.refresh();
  }

  void updateProductName(int index, String value) {
    mutableProducts[index]['nameProduct'] = value;
    nameControllers[index].text = value; // đảm bảo controller sync
    mutableProducts.refresh();
  }
  void updateProductUnit(int index, String value) {
    mutableProducts[index]['unit'] = value;
  }

  void updateProductPrice(int index, String value) {
    // Lấy giá trị thực từ PriceController
    final price = priceControllers[index].rawValue;
    mutableProducts[index]['price'] = price;
    recalculateItemTotal(index);
  }

  void updateProductQty(int index, String value) {
    final qty = safeParseInt(value);
    mutableProducts[index]['qty'] = qty;
    recalculateItemTotal(index);
  }

  // --- 4. FIRESTORE CRUD ---
  Future<void> updateNoteDetails() async {
    try {
      final newProducts = _convertMutableListToProducts(mutableProducts.toList());

      await FirebaseFirestore.instance
          .collection('notes')
          .doc(initialNote.id)
          .update({
        'clientName': clientNameController.text.trim(),
        'phoneNumber': phoneNumberController.text.trim(),
        'products': newProducts.map((p) => p.toJson()).toList(),
        'totalAll': grandTotal.value.round(),
      });

      Get.snackbar('Thành công', 'Thông tin hóa đơn đã được cập nhật.',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> updateDebtStatus(bool newDebt) async {
    try {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(initialNote.id)
          .update({'debt': newDebt});
      debtStatus.value = newDebt;
      Get.snackbar('Thành công', 'Trạng thái hóa đơn đã được cập nhật.');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật: $e');
    }
  }

  Future<void> deleteNote() async {
    try {
      await FirebaseFirestore.instance
          .collection('notes')
          .doc(initialNote.id)
          .delete();
      Get.back();
      Get.snackbar('Thành công', 'Hóa đơn đã được xóa.');
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể xóa: $e');
    }
  }
}