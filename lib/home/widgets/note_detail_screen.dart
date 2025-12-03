import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ghi_no/theme/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import '../../create_note/controller/note_detail_controller.dart';
import '../../create_note/model/note_model.dart';
import '../../theme/constants/sizes.dart';
import '../../theme/constants/text_strings.dart';
import '../../theme/constants/texts/section_heading.dart';
import '../../theme/helpers/helper_functions.dart';

class NoteDetailScreen extends StatelessWidget {
  final NoteModel note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 1. KHỞI TẠO/ĐẶT CONTROLLER
    // Sử dụng Get.put() để khởi tạo Controller và truyền data
    final controller = Get.put(NoteDetailController(note));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chi tiết phiếu'),
        automaticallyImplyLeading: true, // Hiện nút Back
        iconTheme: IconThemeData(
          color: THelperFunctions.isDarkMode(context) ? TColors.light : TColors.dark, // Màu của mũi tên Back
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Khách hàng & SĐT
            Obx(
                  () => TextFormField(
                controller: controller.clientNameController,
                readOnly: !controller.isEditing.value,
                decoration: const InputDecoration(
                  labelText: 'Tên khách hàng',
                  prefixIcon: Icon(Iconsax.user_edit),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),
            Obx(
                  () => TextFormField(
                controller: controller.phoneNumberController,
                readOnly: !controller.isEditing.value,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: TTexts.phoneNumber,
                  prefixIcon: Icon(Iconsax.call),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Danh sách sản phẩm
            const TSectionHeading(
              title: "Danh Sách Mua",
              showActionButton: false,
            ),
            const SizedBox(height: TSizes.md),
            Expanded(
              child: Obx(
                    () => ListView.builder(
                  itemCount: controller.mutableProducts.length,
                  itemBuilder: (context, index) {
                    final product = controller.mutableProducts[index];
                    final totalValue = product['total'] as double;

                    // Định dạng tiền tệ cho trường chỉ đọc (Total)
                    final totalString = NumberFormat.currency(
                        locale: 'vi_VN', symbol: '')
                        .format(totalValue)
                        .replaceAll(',00', '');

                    return Container(
                      padding: const EdgeInsets.only(bottom: TSizes.sm),
                      child: Column(
                        children: [
                          // Tên sản phẩm (Không chỉnh sửa)
                          TextFormField(
                            controller: controller.nameControllers[index],
                            readOnly: !controller.isEditing.value,
                            keyboardType: TextInputType.number,
                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                            onChanged: (value) {
                              controller.updateProductPrice(index, value);
                            },
                            decoration: const InputDecoration(
                              labelText: 'Tên Sản Phẩm',
                            ),
                          ),
                          const SizedBox(height: TSizes.spaceRowItemsSmail),

                          // Giá, Số lượng, Tổng
                          Row(
                            children: [
                              /// Giá
                              /// Trong ListView.builder
                              Flexible(
                                flex: 3,
                                child: Obx(() {
                                  final priceController = controller.priceControllers[index];

                                  return TextFormField(
                                    controller: priceController,
                                    keyboardType: TextInputType.number,
                                    readOnly: !controller.isEditing.value,
                                    decoration: const InputDecoration(labelText: TTexts.createPrice),
                                    onChanged: (value) {
                                      priceController.formatInput(); // Format realtime

                                      // Cập nhật mutableProducts
                                      final rawPrice = priceController.rawValue;
                                      controller.mutableProducts[index]['price'] = rawPrice;
                                      controller.recalculateItemTotal(index);
                                    },
                                  );
                                }),
                              ),

                              const SizedBox(width: TSizes.spaceRowItems),

                              /// Số lượng
                              Flexible(
                                flex: 2,
                                child: Obx(
                                      () => TextFormField(
                                    initialValue:
                                    (product['qty'] as int).toString(),
                                    readOnly: !controller.isEditing.value,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly
                                    ],
                                    onChanged: (value) {
                                      // Gọi hàm Controller để xử lý logic
                                      controller.updateProductQty(index, value);
                                    },
                                    decoration: const InputDecoration(
                                        labelText: TTexts.createQty),
                                  ),
                                ),
                              ),
                              const SizedBox(width: TSizes.spaceRowItems),

                              /// Tổng (Tự động tính)
                              Flexible(
                                flex: 5,
                                child: TextFormField(
                                  key: ValueKey('total_${index}_${totalValue}'),
                                  initialValue: totalString,
                                  readOnly: true,
                                  decoration: const InputDecoration(
                                      labelText: TTexts.createTotal),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),

            const Divider(),

            /// TỔNG TIỀN HÓA ĐƠN
            Obx(
                  () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TỔNG HÓA ĐƠN',
                    style: const TextStyle(fontSize: TSizes.fontSizeMd, fontWeight: FontWeight.bold,),),
                  Text(
                    NumberFormat.currency(locale: 'vi_VN', symbol: '')
                        .format(controller.grandTotal.value)
                        .replaceAll(',00', ''),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: TSizes.fontSizeLg,
                        color: TColors.primary),
                  ),
                ],
              ),
            ),

            const SizedBox(height: TSizes.spaceBtwSections),

            /// HIỂN THỊ TRẠNG THÁI NỢ/THANH TOÁN
            InkWell(
              onTap: () => _showDebtUpdateDialog(context, controller),
              child: Obx(
                    () => Text(
                  controller.debtStatus.value
                      ? 'Khách đang nợ hóa đơn này'
                      : 'Khách đã thanh toán hóa đơn này',
                  style: TextStyle(
                    fontSize: TSizes.fontSizeMd,
                    color: controller.debtStatus.value ? Colors.red : Colors.green,
                  ),
                ),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// 3 NÚT Ở DƯỚI CÙNG
            Row(
              children: [
                // 1. NÚT EDIT/SAVE MỚI
                Expanded(
                  child: Obx(
                        () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: controller.isEditing.value
                              ? TColors.primary
                              : TColors.warning),
                      onPressed: () async {
                        if (controller.isEditing.value) {
                          // Đang ở chế độ chỉnh sửa -> Nhấn để LƯU
                          await controller.updateNoteDetails();
                          controller.isEditing.value = false;
                        } else {
                          // Đang ở chế độ chỉ đọc -> Nhấn để CHỈNH SỬA
                          controller.isEditing.value = true;
                        }
                      },
                      child: Text(controller.isEditing.value
                          ? 'LƯU'
                          : 'CHỈNH SỬA'),
                    ),
                  ),
                ),
                /*Expanded(
                  child: Obx(
                        () => ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: TColors.primary),
                      onPressed: () async {
                        if (controller.isEditing.value) {
                          // Đang ở chế độ chỉnh sửa -> Nhấn để LƯU
                          await controller.updateNoteDetails();
                          controller.isEditing.value = false;
                        } else {
                          // Đang ở chế độ chỉ đọc -> Nhấn để CHỈNH SỬA
                          controller.isEditing.value = true;
                        }
                      },
                      child: Text(controller.isEditing.value
                          ? 'LƯU'
                          : 'CHỈNH SỬA'),
                    ),
                  ),
                ),*/
                const SizedBox(width: TSizes.sm),

                // 2. NÚT XÓA
                Expanded(
                  child: ElevatedButton(
                    style:
                    ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () => _showDeleteConfirmationDialog(context, controller),
                    child: const Text('XÓA'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  // Helper function để hiển thị Dialog xác nhận thay đổi trạng thái nợ
  void _showDebtUpdateDialog(
      BuildContext context, NoteDetailController controller) {
    showDialog(
      context: context,
      builder: (context) => Obx(
            () => AlertDialog(
          title: const Text('Xác nhận'),
          content: Text(
            controller.debtStatus.value
                ? 'Bạn có chắc muốn đánh dấu hóa đơn là đã thanh toán?'
                : 'Bạn có chắc muốn đánh dấu hóa đơn là đang nợ?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                controller.updateDebtStatus(!controller.debtStatus.value);
              },
              child: const Text('Xác nhận'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function để hiển thị Dialog xác nhận xóa
  void _showDeleteConfirmationDialog(
      BuildContext context, NoteDetailController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: const Text('Bạn có chắc muốn xóa hóa đơn này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              controller.deleteNote();
            },
            child: const Text('Xóa'),
          ),
        ],
      ),
    );
  }
}