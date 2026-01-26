import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../theme/constants/colors.dart';
import '../../theme/constants/sizes.dart';
import '../../theme/constants/text_strings.dart';
import '../../theme/constants/texts/section_heading.dart';
import '../controller/create_note_controller.dart';
import 'debt_checkbox.dart';
import 'validation.dart';

class CreateNoteForm extends StatelessWidget {
  CreateNoteForm({super.key});
  final FocusNode customerFocus = FocusNode();
  final FocusNode productFocus = FocusNode();
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<CreateNoteController>();
    final vndFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '');

    return Form(
      key: controller.CreateNoteFormKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ================= KHÁCH HÀNG (AUTOCOMPLETE) =================
          RawAutocomplete<String>(
            textEditingController: controller.clientName,
            focusNode: customerFocus,
            optionsBuilder: (value) {
              if (value.text.isEmpty) return const Iterable<String>.empty();
              return controller.customerNames.where(
                    (e) => e.toLowerCase().contains(value.text.toLowerCase()),
              );
            },
            onSelected: (selection) async {
              // Khi chọn từ gợi ý, điền thông tin lịch sử
              await controller.fillInfoFromHistory(selection);
              customerFocus.unfocus();
            },
            fieldViewBuilder: (context, textController, focusNode, _) {
              return TextFormField(
                controller: textController,
                focusNode: focusNode,
                decoration: const InputDecoration(
                  labelText: TTexts.createNameNote,
                  prefixIcon: Icon(Iconsax.user_edit),
                ),
                // 🔹 KHI THAY ĐỔI TÊN -> RESET TẤT CẢ
                onChanged: (value) {
                  controller.resetForm();
                },
              );
            },

            // Phần optionsViewBuilder của bạn cần thêm ConstrainedBox
            // để sửa triệt để lỗi "infinite size" đã gặp ở trên
            optionsViewBuilder: (context, onSelected, options) {
              return Align(
                alignment: Alignment.topLeft,
                child: Material(
                  elevation: 4.0,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 200), // Giới hạn chiều cao
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width - (TSizes.defaultSpace * 2),
                      child: ListView(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        children: options.map((opt) {
                          return ListTile(
                            title: Text(opt),
                            onTap: () => onSelected(opt),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),

          const SizedBox(height: TSizes.spaceBtwInputFields),

          /// ================= PHONE =================
          TextFormField(
            controller: controller.phoneNumber,
            keyboardType: TextInputType.phone,
            decoration: InputDecoration(
              labelText: TTexts.phoneNumber,
              prefixIcon: const Icon(Iconsax.call),
              suffixIcon: IconButton(
                icon: Icon(Iconsax.archive_book, color: TColors.primary),
                onPressed: () => controller.selectContact(),
              ),
            ),
          ),

          const SizedBox(height: TSizes.spaceBtwSections),

          const TSectionHeading(
            title: "Danh Sách Mua",
            showActionButton: false,
          ),

          const SizedBox(height: TSizes.spaceRowItems),

          /// ================= NHẬP SẢN PHẨM =================
          Column(
            children: [

              /// -------- ROW 1: TÊN SP + NÚT THÊM --------
              Row(
                children: [
                  Expanded(
                    child: RawAutocomplete<String>(
                      textEditingController: controller.createProductName,
                      focusNode: productFocus,

                      optionsBuilder: (value) {
                        if (value.text.isEmpty) return const Iterable<String>.empty();
                        return controller.productNameSuggestions.where(
                              (e) => e.toLowerCase().contains(value.text.toLowerCase()),
                        );
                      },

                      onSelected: (selection) {
                        controller.createProductName.text = selection;
                        controller.autoFillProductFromHistory(selection);
                        productFocus.unfocus();
                      },

                      fieldViewBuilder: (context, textController, focusNode, _) {
                        return TextFormField(
                          decoration: const InputDecoration(
                            labelText: TTexts.createProductName,
                          ),
                          controller: textController,
                          focusNode: focusNode,
                        );
                      },

                      optionsViewBuilder: (context, onSelected, options) {
                        return Align(
                          alignment: Alignment.topLeft, // Giữ danh sách nằm đúng vị trí
                          child: Material(
                            elevation: 4.0, // Tạo hiệu ứng nổi khối
                            borderRadius: BorderRadius.circular(8), // Bo góc cho đẹp
                            child: ConstrainedBox(
                              // GIẢI QUYẾT LỖI INFINITE SIZE: Giới hạn chiều cao tối đa
                              constraints: const BoxConstraints(maxHeight: 200),
                              child: SizedBox(
                                // Chiều rộng khớp với ô nhập liệu (trừ padding mặc định)
                                width: MediaQuery.of(context).size.width - (32),
                                child: ListView.builder(
                                  padding: EdgeInsets.zero,
                                  shrinkWrap: true,
                                  itemCount: options.length,
                                  itemBuilder: (BuildContext context, int index) {
                                    final String option = options.elementAt(index);
                                    return ListTile(
                                      title: Text(option),
                                      onTap: () => onSelected(option),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    )
                  ),
                  const SizedBox(width: TSizes.spaceRowItems),
                  ElevatedButton(
                    onPressed: () {
                      FocusScope.of(context).unfocus();
                      controller.addProduct();
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(14),
                    ),
                    child: const Icon(Icons.check),
                  ),
                ],
              ),

              const SizedBox(height: TSizes.spaceRowItemsSmail),

              /// -------- ROW 2: PRICE – QTY – UNIT – TOTAL --------
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextFormField(
                      controller: controller.createPrice,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                          labelText: TTexts.createPrice),
                      onChanged: controller.onPriceChanged,
                    ),
                  ),
                  const SizedBox(width: TSizes.xs),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: controller.createQty,
                      // SỬA TẠI ĐÂY: Cho phép nhập số thập phân
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      // THÊM FORMATTER: Chỉ cho phép nhập số và dấu chấm/phẩy
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                      ],
                      decoration: const InputDecoration(
                          labelText: TTexts.createQty),
                      onChanged: (_) =>
                          controller.recalculateCreateTotal(),
                    ),
                  ),
                  const SizedBox(width: TSizes.xs),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: controller.createUnit,
                      decoration: const InputDecoration(
                          labelText: TTexts.createUnit),
                    ),
                  ),
                  const SizedBox(width: TSizes.xs),
                  Expanded(
                    flex: 4,
                    child: TextFormField(
                      controller: controller.createTotal,
                      readOnly: true,
                      decoration: const InputDecoration(
                          labelText: TTexts.createTotal),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const Divider(),

          /// ================= DANH SÁCH SP ĐÃ THÊM =================
          Obx(() => controller.productList.isEmpty
              ? const SizedBox()
              : Column(
            children: controller.productList
                .asMap()
                .entries
                .map((entry) {
              final index = entry.key;
              final p = entry.value;

              return Padding(
                padding:
                const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            initialValue:
                            p.nameProduct,
                            readOnly: true,
                            decoration:
                            const InputDecoration(
                              labelText:
                              TTexts.createProductName,
                            ),
                          ),
                        ),
                        const SizedBox(width: TSizes.xs),
                        ElevatedButton(
                          onPressed: () => controller
                              .productList
                              .removeAt(index),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child:
                          const Icon(Icons.clear),
                        ),
                      ],
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
                        const SizedBox(width: TSizes.xs),

                        // QTY
                        Flexible(
                          flex: 2,
                          child: TextFormField(
                            // Sử dụng replaceAll để xóa .0 nếu là số nguyên cho đẹp mắt
                            initialValue: p.qty.toString().replaceAll(RegExp(r'\.0$'), ''),
                            readOnly: true,
                            decoration: const InputDecoration(labelText: TTexts.createQty),
                          ),
                        ),
                        const SizedBox(width: TSizes.xs),
                        // UNIT (20%)
                        Flexible(
                          flex: 2,
                          child: TextFormField(
                            initialValue: p.unit.toString(),
                            readOnly: true,
                            decoration: const InputDecoration(labelText: TTexts.createUnit),
                          ),
                        ),
                        const SizedBox(width: TSizes.xs),

                        // TOTAL
                        Flexible(
                          flex: 4,
                          child: TextFormField(
                            initialValue: vndFormatter.format(p.total),
                            readOnly: true,
                            decoration: const InputDecoration(labelText: TTexts.createTotal),
                          ),
                        ),
                        const SizedBox(width: TSizes.xs),


                      ],
                    ),
                    const Divider(),
                  ],
                ),
              );
            }).toList(),
          )),

          const SizedBox(height: TSizes.spaceBtwSections),
          const DebtCheckbox(),
          const SizedBox(height: TSizes.spaceBtwSections),

          /// ================= SAVE =================
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                FocusScope.of(context).unfocus();
                controller.create_note();
              },
              child: const Text(TTexts.createNote),
            ),
          ),
        ],
      ),
    );
  }
}
