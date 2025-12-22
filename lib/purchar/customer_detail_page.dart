import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghi_no/purchar/widgets/purchase_history_list.dart';
import 'package:ghi_no/theme/constants/sizes.dart';
import 'package:ghi_no/theme/constants/colors.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../purchar/purchar_controller.dart';
import '../purchar/purchar_model.dart';
import './widgets/customer_info_header.dart';
import './widgets/payment_input_field.dart';
import './widgets/payment_history_list.dart';

class CustomerDetailPage extends StatelessWidget {
  final CustomerInfo customer;
  CustomerDetailPage({super.key, required this.customer});

  final _payCtrl = TextEditingController();
  final _fmt = NumberFormat('#,###', 'vi_VN');

  // Controllers cho phần Trả đồ
  final _returnQtyCtrl = TextEditingController();
  final _returnPriceCtrl = TextEditingController();
  final _returnUnitCtrl = TextEditingController(); // Thêm trường Đơn vị
  final _returnTotalCtrl = TextEditingController();
  final _returnNoteCtrl = TextEditingController();

  // FocusNode cho Autocomplete
  final FocusNode _returnFocusNode = FocusNode();

  num _rawNumber(String s) {
    final raw = s.replaceAll(RegExp(r'[^0-9]'), '');
    return num.tryParse(raw) ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomersController>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        iconTheme: IconThemeData(color: isDark ? TColors.light : TColors.dark),
        actions: [
          IconButton(
            icon: Icon(Iconsax.trash, color: isDark ? TColors.light : TColors.dark),
            onPressed: () => _confirmDeleteCustomer(context, controller),
          ),
        ],
      ),
      body: Obx(() {
        final c = controller.getCustomerByName(customer.name);
        return SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomerInfoHeader(
                customer: c,
                onCall: _callPhone,
                formatDebt: controller.formatNumber(c.totalDebt),
              ),
              const SizedBox(height: TSizes.defaultSpace),

              // --- PHẦN 1: TẠM ỨNG TIỀN MẶT ---
              const Text('Tạm ứng & Trả đồ', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: TSizes.sm),
              PaymentInputField(
                payCtrl: _payCtrl,
                onPayChanged: _onPayChanged,
                onPayConfirm: () => _handlePayment(controller, c.name),
                customer: c,
                returnQtyCtrl: _returnQtyCtrl,
                returnPriceCtrl: _returnPriceCtrl,
                returnUnitCtrl: _returnUnitCtrl,
                returnTotalCtrl: _returnTotalCtrl,
                onReturnConfirm: () => _handleReturnGoods(controller, c.name),
                onRecalculate: _recalculateReturnTotal,
                onFormatPrice: _onFormatReturnPrice,
              ),


              const SizedBox(height: TSizes.spaceBtwSections),

              const Text('Lịch sử mua hàng', style: TextStyle(fontWeight: FontWeight.bold, fontSize: TSizes.fontSizeLg)),
              PurchaseHistoryList(purchases: c.purchases),
              const Divider(),
              const SizedBox(height: TSizes.md),
              const Text('Lịch sử tạm ứng & Trả đồ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: TSizes.fontSizeLg)),
              PaymentHistoryList(
                payments: c.payments,
                onDelete: (pay) => controller.deletePayment(c.name, pay),
              ),
            ],
          ),
        );
      }),
    );
  }

  // --- LOGIC XỬ LÝ ---

  void _recalculateReturnTotal() {
    final qty = double.tryParse(_returnQtyCtrl.text) ?? 0;
    final price = _rawNumber(_returnPriceCtrl.text);
    final total = qty * price;
    _returnTotalCtrl.text = total > 0 ? _fmt.format(total) : '';
  }

  void _onFormatReturnPrice(String v) {
    final raw = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) return;
    _returnPriceCtrl.value = TextEditingValue(
      text: _fmt.format(num.parse(raw)),
      selection: TextSelection.collapsed(offset: _fmt.format(num.parse(raw)).length),
    );
  }

  Future<void> _handleReturnGoods(CustomersController controller, String name) async {
    final amount = _rawNumber(_returnTotalCtrl.text);

    // SỬA TẠI ĐÂY: Lấy note từ biến Rx của controller thay vì controller text
    final note = controller.selectedReturnProduct.value ?? '';

    final qtyStr = _returnQtyCtrl.text.trim();
    final unit = _returnUnitCtrl.text.trim();

    // Kiểm tra tên món (Dropdown)
    if (note.isEmpty) {
      Get.snackbar('Thông báo', 'Vui lòng chọn món hàng trả',
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    // Kiểm tra SL bắt buộc nhập
    if (qtyStr.isEmpty || double.tryParse(qtyStr) == null || double.parse(qtyStr) <= 0) {
      Get.snackbar('Lỗi', 'Vui lòng nhập số lượng trả hàng',
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    if (amount <= 0) return;

    String finalNote = "Trả đồ: $note (SL: $qtyStr $unit)";
    await controller.payTemporary(name, amount, note: finalNote);

    // --- XÓA SẠCH DỮ LIỆU SAU KHI LƯU ---
    _returnQtyCtrl.clear();
    _returnPriceCtrl.clear();
    _returnUnitCtrl.clear();
    _returnTotalCtrl.clear();
    _returnNoteCtrl.clear();

    // Reset giá trị Dropdown về trạng thái chưa chọn
    controller.selectedReturnProduct.value = null;

    FocusScope.of(Get.context!).unfocus();
  }

  void _onPayChanged(String v) {
    final raw = v.replaceAll(RegExp(r'[^0-9]'), '');
    if (raw.isEmpty) { _payCtrl.text = ''; return; }
    _payCtrl.value = TextEditingValue(
      text: _fmt.format(num.parse(raw)),
      selection: TextSelection.collapsed(offset: _fmt.format(num.parse(raw)).length),
    );
  }

  Future<void> _handlePayment(CustomersController controller, String name) async {
    final amount = _rawNumber(_payCtrl.text);
    if (amount <= 0) return;
    await controller.payTemporary(name, amount);
    _payCtrl.clear();
  }

  /*void _confirmDeletePayment(BuildContext context, CustomersController controller, String name, PaymentInfo pay) {
    Get.defaultDialog(
      title: 'Xoá tạm ứng',
      middleText: 'Bạn muốn xoá khoản ${_fmt.format(pay.amount)} này?',
      textConfirm: 'Xóa',
      confirmTextColor: Colors.white,
      onConfirm: () { controller.deletePayment(name, pay); Get.back(); },
      onCancel: () {},
    );
  }*/

  void _confirmDeleteCustomer(BuildContext context, CustomersController controller) {
    Get.defaultDialog(
      title: 'Xác Nhận Xóa',
      middleText: 'Xoá tất cả dữ liệu của khách này?',
      textConfirm: 'Xóa',
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        await controller.deleteAllByClientName(customer.name);
        Get.back();
      },
    );
  }

  Future<void> _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) await launchUrl(uri);
  }
}