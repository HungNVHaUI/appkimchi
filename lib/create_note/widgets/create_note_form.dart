import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../theme/constants/sizes.dart';
import '../../theme/constants/text_strings.dart';
import '../../theme/constants/texts/section_heading.dart';
import '../create_note_controller.dart';
import '../debt_checkbox.dart';
import '../validation.dart';

class CreateNoteForm extends StatelessWidget {
  const CreateNoteForm({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateNoteController());
    final vndFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '');

    return Form(
      key: controller.CreateNoteFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Khách hàng
          TextFormField(
            controller: controller.clientName,
            validator: (val) => TValidator.validateEmptyText('Khách Hàng', val),
            decoration: const InputDecoration(
              labelText: TTexts.createNameNote,
              prefixIcon: Icon(Iconsax.user_edit),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// Phone Number
          TextFormField(
            controller: controller.phoneNumber,
            //validator: (val) => TValidator.validatePhoneNumber(val),
            decoration: const InputDecoration(
              labelText: TTexts.phoneNumber,
              prefixIcon: Icon(Iconsax.call),
            ),
          ),
          const SizedBox(height: TSizes.spaceBtwSections),

          /// Section heading (hiển thị/ẩn Row thêm sản phẩm)
          TSectionHeading(
            title: "Danh Sách Mua",
            showActionButton: true,
            onPressed: () => controller.showProductRow.value = !controller.showProductRow.value,
          ),

          /// Row nhập sản phẩm
          Obx(() => controller.showProductRow.value
              ? Column(
                  children: [
                    TextFormField(
                      controller: controller.createProductName,
                      //validator: (val) => TValidator.validatePhoneNumber(val),
                      decoration: const InputDecoration(
                        labelText: TTexts.createProductName,
                        prefixIcon: Icon(Iconsax.cards),
                      ),
                    ),
                    const SizedBox(height: TSizes.spaceRowItemsSmail),
                    Row(
                      children: [
                        // GIÁ (30%)
                        Flexible(
                          flex: 3,
                          child: TextFormField(
                            controller: controller.createPrice,
                            //validator: (valve) => TValidator.validateEmptyText('Giá', valve),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: TTexts.createPrice),
                            onChanged: (value) {
                              // Format tiền khi gõ (1,000 – 12,000 – 1,200,000)
                              final number = value.replaceAll(',', '');
                              if (number.isNotEmpty) {
                                final formatted = NumberFormat('#,###')
                                    .format(int.parse(number));
                                controller.createPrice.value = TextEditingValue(
                                  text: formatted,
                                  selection: TextSelection.collapsed(
                                      offset: formatted.length),
                                );
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: TSizes.spaceRowItems),
                        // SỐ LƯỢNG (20%)
                        Flexible(
                          flex: 2,
                          child: TextFormField(
                            controller: controller.createQty,
                            //validator: (valve) => TValidator.validateEmptyText('Qty', valve),
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                                labelText: TTexts.createQty),
                          ),
                        ),
                        const SizedBox(width: TSizes.spaceRowItems),
                        // TỔNG (40%) – TỰ TÍNH, KHÔNG CHO NHẬP
                        Flexible(
                          flex: 4,
                          child: TextFormField(
                            controller: controller.createTotal,
                            readOnly: true, // Quan trọng!
                            decoration: const InputDecoration(
                                labelText: TTexts.createTotal),
                          ),
                        ),
                        const SizedBox(width: TSizes.spaceRowItemsSmail),
                        // Nút thêm sản phẩm
                        Flexible(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () => controller.addProduct(),
                            child: const Icon(Icons.check),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
              : Container()),


          // Hiển thị danh sách sản phẩm đã thêm
          Obx(() => controller.productList.isNotEmpty ?
          Column(
            children: controller.productList.asMap().entries.map((entry) {
              final index = entry.key;
              final p = entry.value;

              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      initialValue: p.nameProduct,
                      readOnly: true,
                      decoration: const InputDecoration(prefixIcon: Icon(Iconsax.cards)),
                    ),
                    const SizedBox(height: TSizes.spaceRowItemsSmail),

                    Row(
                      children: [
                        // GIÁ
                        Flexible(
                          flex: 3,
                          child: TextFormField(
                            initialValue: vndFormatter.format(p.price),
                            readOnly: true,
                            decoration: const InputDecoration(labelText: TTexts.createPrice),
                          ),
                        ),
                        const SizedBox(width: TSizes.spaceRowItems),

                        // QTY
                        Flexible(
                          flex: 2,
                          child: TextFormField(
                            initialValue: p.qty.toString(),
                            readOnly: true,
                            decoration: const InputDecoration(labelText: TTexts.createQty),
                          ),
                        ),
                        const SizedBox(width: TSizes.spaceRowItems),

                        // TOTAL
                        Flexible(
                          flex: 4,
                          child: TextFormField(
                            initialValue: vndFormatter.format(p.total),
                            readOnly: true,
                            decoration: const InputDecoration(labelText: TTexts.createTotal),
                          ),
                        ),
                        const SizedBox(width: TSizes.spaceRowItemsSmail),

                        // ❌ Nút xóa
                        Flexible(
                          flex: 1,
                          child: ElevatedButton(
                            onPressed: () => controller.productList.removeAt(index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                            child: const Icon(Icons.clear),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
          )
              : Container()),

          const SizedBox(height: TSizes.spaceBtwSections),
          const DebtCheckbox(),

          const SizedBox(height: TSizes.spaceBtwSections),

          // Nút lưu Firebase
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.create_note(),
              child: const Text(TTexts.createNote),
            ),
          ),
        ],
      ),
    );
  }
}
