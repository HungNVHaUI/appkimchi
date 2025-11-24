import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../create_note/create_note_controller.dart';
import '../../create_note/debt_checkbox.dart';
import '../../create_note/validation.dart';
import '../../theme/constants/colors.dart';
import '../../theme/helpers/helper_functions.dart';
import '../model/note_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';
import '../../theme/constants/sizes.dart';
import '../../theme/constants/text_strings.dart';
import '../../theme/constants/texts/section_heading.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NoteDetailScreen extends StatelessWidget {
  final NoteModel note;

  const NoteDetailScreen({Key? key, required this.note}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CreateNoteController());

    // Biến tạm để theo dõi trạng thái debt UI
    final RxBool tempDebt = note.debt.obs;

    return Scaffold(
      appBar: AppBar(title: const Text('Chi tiết phiếu')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Khách hàng
            TextFormField(
              initialValue: note.clientName,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: 'Tên khách hàng',
                prefixIcon: Icon(Iconsax.user_edit),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwInputFields),

            /// Phone Number
            TextFormField(
              initialValue: note.phoneNumber,
              readOnly: true,
              decoration: const InputDecoration(
                labelText: TTexts.phoneNumber,
                prefixIcon: Icon(Iconsax.call),
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwSections),

            /// Danh sách sản phẩm
            const TSectionHeading(
              title: "Danh Sách Mua",
              showActionButton: false,
            ),
            Expanded(
              child: ListView.builder(
                itemCount: note.products.length,
                itemBuilder: (context, index) {
                  final product = note.products[index];
                  return Container(
                    padding: const EdgeInsets.all(TSizes.md),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                    ),
                    child: Column(
                      children: [
                        TextFormField(
                          initialValue: product.nameProduct,
                          readOnly: true,
                          decoration: const InputDecoration(
                            labelText: TTexts.createProductName,
                            prefixIcon: Icon(Iconsax.cards),
                          ),
                        ),
                        const SizedBox(height: TSizes.spaceRowItemsSmail),
                        Row(
                          children: [
                            Flexible(
                              flex: 3,
                              child: TextFormField(
                                initialValue: NumberFormat.currency(locale: 'vi_VN', symbol: '')
                                    .format(product.price),
                                readOnly: true,
                                decoration: const InputDecoration(labelText: TTexts.createPrice),
                              ),
                            ),
                            const SizedBox(width: TSizes.spaceRowItems),
                            Flexible(
                              flex: 2,
                              child: TextFormField(
                                initialValue: product.qty.toString(),
                                readOnly: true,
                                decoration: const InputDecoration(labelText: TTexts.createQty),
                              ),
                            ),
                            const SizedBox(width: TSizes.spaceRowItems),
                            Flexible(
                              flex: 5,
                              child: TextFormField(
                                initialValue: NumberFormat.currency(locale: 'vi_VN', symbol: '')
                                    .format(product.total),
                                readOnly: true,
                                decoration: const InputDecoration(labelText: TTexts.createTotal),
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

            const SizedBox(height: TSizes.spaceBtwSections),

            /// Hiển thị trạng thái debt theo biến tạm
            Obx(() => Text(
              tempDebt.value
                  ? 'Khách đang nợ hóa đơn này'
                  : 'Khách đã thanh toán hóa đơn này',
              style: TextStyle(
                fontSize: TSizes.fontSizeMd,
                color: tempDebt.value ? Colors.red : Colors.green,
              ),
            )),
            const SizedBox(height: TSizes.spaceBtwSections),

            Row(
              children: [
                /// Nút Thanh Toán
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Xác nhận'),
                          content: Text(
                            tempDebt.value
                                ? 'Bạn có chắc muốn đánh dấu hóa đơn là đã thanh toán?'
                                : 'Bạn có chắc muốn đánh dấu hóa đơn là đang nợ?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () async {
                                Navigator.pop(context);
                                try {
                                  final newDebt = !tempDebt.value;
                                  await FirebaseFirestore.instance
                                      .collection('notes')
                                      .doc(note.id)
                                      .update({'debt': newDebt});
                                  tempDebt.value = newDebt; // update UI ngay
                                } catch (e) {
                                  Get.snackbar('Lỗi', 'Không thể cập nhật: $e');
                                }
                              },
                              child: const Text('Xác nhận'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: Obx(() => const Text('Thanh toán')),
                  ),
                ),
                const SizedBox(width: TSizes.md),

                /// Nút Xóa
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                    onPressed: () {
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
                              onPressed: () async {
                                Navigator.pop(context);
                                try {
                                  await FirebaseFirestore.instance
                                      .collection('notes')
                                      .doc(note.id)
                                      .delete();
                                  Get.back(); // quay lại màn trước
                                } catch (e) {
                                  Get.snackbar('Lỗi', 'Không thể xóa: $e');
                                }
                              },
                              child: const Text('Xóa'),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text('Xóa'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

