import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // thêm Firestore
import '../home/home.dart';
import '../theme/constants/image_strings.dart';
import '../theme/constants/popups/full_screen_loader.dart';
import '../theme/constants/popups/loaders.dart';
import 'model/product_model.dart';

class CreateNoteController extends GetxController {
  static CreateNoteController get instance => Get.find();


  final clientName = TextEditingController();
  final phoneNumber = TextEditingController();
  RxList<ProductModel> productList = <ProductModel>[].obs;
  RxBool showProductRow = false.obs;

  // Thêm RxBool cho debt
  RxBool isDebt = false.obs;

  final createProductName = TextEditingController();
  final createPrice = TextEditingController();
  final createQty = TextEditingController();
  final createTotal = TextEditingController();

  final _formatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');

  GlobalKey<FormState> CreateNoteFormKey = GlobalKey<FormState>();

  @override
  void onInit() {
    super.onInit();

    /// Lắng nghe khi người dùng nhập Giá hoặc Số lượng
    createPrice.addListener(_calculateTotal);
    createQty.addListener(_calculateTotal);
  }

  /// Tự động tính tổng = giá x số lượng
  void _calculateTotal() {
    final price = _parseNumber(createPrice.text);
    final qty = _parseNumber(createQty.text);

    final result = price * qty;

    // Format kết quả và hiển thị vào ô Tổng
    createTotal.text = _formatter.format(result);
  }

  /// Convert text có dấu phẩy → số (VD: "1,200" → 1200)
  double _parseNumber(String value) {
    if (value.isEmpty) return 0;
    return double.tryParse(value.replaceAll(',', '')) ?? 0;
  }

  /// Thêm sản phẩm vào list
  void addProduct() {
    final price = _parseNumber(createPrice.text);
    final qty = _parseNumber(createQty.text);

    if (price > 0 && qty > 0) {
      final total = price * qty;
      productList.add(ProductModel(
          nameProduct: createProductName.text,
          price: price,
          qty: qty.toInt(),
          total: total));

      // Reset input sau khi thêm
      createPrice.clear();
      createQty.clear();
      createTotal.clear();
      createProductName.clear();
    }
  }

  /// Lưu phiếu lên Firestore
  Future<void> create_note() async {
    try {
      if (!CreateNoteFormKey.currentState!.validate()) return;
      if (productList.isEmpty) {
        Get.snackbar("Lỗi", "Vui lòng thêm ít nhất 1 sản phẩm!");
        return;
      }

      /// Start Loading
      TFullScreenLoader.openLoadingDialog(
          'We are processing your information....', TImages.checkcreate_note);

      // Convert productList sang Map
      final products = productList
          .map((p) => {
            "name": p.nameProduct,
            "price": p.price,
            "qty": p.qty,
            "total": p.total,
            "debt": isDebt.value,
          })
            .toList();

      // Tổng tiền tất cả sản phẩm
      final totalAll = products.fold<double>(
        0,
            (sum, p) => sum + (p['total'] != null ? (p['total'] as num).toDouble() : 0),
      );

      // Tạo dữ liệu document
      final now = DateTime.now();
      final docData = {
        "clientName": clientName.text.trim(),
        "phoneNumber": phoneNumber.text.trim(),
        "debt": isDebt.value,
        "createdAt": DateTime.now(),
        "totalAll": totalAll,
        "products": products,
        "createdAt": now.toIso8601String(),
      };

      // Ghi lên Firestore
      await FirebaseFirestore.instance.collection("notes").add(docData);


      /// Stop loading
      TFullScreenLoader.stopLoading();

      /// Success message
      TLoaders.successSnackBar(
          title: 'Thành công', message: 'Phiếu đã được tạo');

      // Reset form
      clientName.clear();
      phoneNumber.clear();
      productList.clear();
      isDebt.value = false;
      // Quay về màn hình Home

      Get.to(() => const HomeScreen());
    } catch (e) {
      TFullScreenLoader.stopLoading();
      TLoaders.errorSnackBar(title: 'Lỗi', message: e.toString());
      //print("Error: $e");
    }
  }

  @override
  void onClose() {
    clientName.dispose();
    phoneNumber.dispose();
    createPrice.dispose();
    createQty.dispose();
    createTotal.dispose();
    createProductName.dispose();
    super.onClose();
  }
}
