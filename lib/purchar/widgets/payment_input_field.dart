import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghi_no/theme/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../purchar/purchar_controller.dart';
import '../../purchar/purchar_model.dart';

class PaymentInputField extends StatelessWidget {
  const PaymentInputField({
    super.key,
    required this.payCtrl,
    required this.onPayChanged,
    required this.onPayConfirm,
    required this.customer, // Để lấy tên khách lọc sản phẩm
    required this.returnQtyCtrl,
    required this.returnPriceCtrl,
    required this.returnUnitCtrl,
    required this.returnTotalCtrl,
    required this.onReturnConfirm,
    required this.onRecalculate,
    required this.onFormatPrice,
  });

  final TextEditingController payCtrl;
  final Function(String) onPayChanged;
  final VoidCallback onPayConfirm;

  final CustomerInfo customer;
  final TextEditingController returnQtyCtrl;
  final TextEditingController returnPriceCtrl;
  final TextEditingController returnUnitCtrl;
  final TextEditingController returnTotalCtrl;
  final VoidCallback onReturnConfirm;
  final VoidCallback onRecalculate;
  final Function(String) onFormatPrice;

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CustomersController>();
    final fmt = NumberFormat('#,###', 'vi_VN');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- KHỐI 1: TẠM ỨNG TIỀN MẶT ---
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: payCtrl,
                keyboardType: TextInputType.number,
                onChanged: onPayChanged,
                decoration: const InputDecoration(
                  labelText: 'Số tiền tạm ứng',
                  prefixIcon: Icon(Icons.payments, size: 18, color: Colors.green),
                ),
              ),
            ),
            const SizedBox(width: TSizes.md),
            ElevatedButton(
              onPressed: onPayConfirm,
              child: const Icon(Icons.check),
            ),
          ],
        ),

        const SizedBox(height: TSizes.sm),
        /// ROW 1: CHỌN MÓN & NÚT XÁC NHẬN
        Row(
          children: [
            Expanded(
              child: Obx(() => DropdownButtonFormField<String>(
                isExpanded: true,
                value: controller.selectedReturnProduct.value,
                decoration: const InputDecoration(
                  labelText: 'Chọn món đã mua',
                  prefixIcon: Icon(Iconsax.box_remove, size: 18, color: Colors.orange),
                ),
                items: controller.getProductsBoughtByCustomer(customer.name).map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (selection) {
                  if (selection != null) {
                    controller.selectedReturnProduct.value = selection;
                    final info = controller.getProductInfoFromHistory(customer.name, selection);
                    if (info['price'] > 0) {
                      returnPriceCtrl.text = fmt.format(info['price']);
                      returnUnitCtrl.text = info['unit'] ?? '';
                      onRecalculate();
                    }
                  }
                },
              )),
            ),
            const SizedBox(width: TSizes.md),
            ElevatedButton(
              onPressed: onReturnConfirm,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(14),
                backgroundColor: Colors.orange,
                side: BorderSide.none,
              ),
              child: const Icon(Icons.check, color: Colors.white),
            ),
          ],
        ),

        const SizedBox(height: TSizes.sm),

        /// ROW 2: GIÁ – SL – ĐƠN VỊ – TỔNG
        Row(
          children: [
            Expanded(
              flex: 3,
              child: TextFormField(
                controller: returnPriceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Giá trả'),
                onChanged: (v) {
                  onFormatPrice(v);
                  onRecalculate();
                },
              ),
            ),
            const SizedBox(width: TSizes.xs),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: returnQtyCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'SL'),
                onChanged: (_) => onRecalculate(),
              ),
            ),
            const SizedBox(width: TSizes.xs),
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: returnUnitCtrl,
                decoration: const InputDecoration(labelText: 'Đơn vị'),
              ),
            ),
            const SizedBox(width: TSizes.xs),
            Expanded(
              flex: 4,
              child: TextFormField(
                controller: returnTotalCtrl,
                readOnly: true,
                style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                decoration: const InputDecoration(labelText: 'Tổng trừ'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}