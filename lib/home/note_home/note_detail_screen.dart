import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:ghi_no/theme/constants/colors.dart';
import 'package:intl/intl.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../create_note/model/note_model.dart';
import '../../purchar/purchar_controller.dart';
import '../../theme/constants/sizes.dart';
import '../../theme/constants/text_strings.dart';
import '../../theme/constants/texts/section_heading.dart';
import '../../theme/helpers/helper_functions.dart';
import 'export/note_export_view.dart';
import 'note_detail_controller.dart';

class NoteDetailScreen extends StatelessWidget {
  final NoteModel note;

  NoteDetailScreen({Key? key, required this.note}) : super(key: key);


  final GlobalKey _exportKey = GlobalKey();
  final customersController = Get.find<CustomersController>();



  @override
  Widget build(BuildContext context) {
    // 1. KHỞI TẠO/ĐẶT CONTROLLER
    // Sử dụng Get.put() để khởi tạo Controller và truyền data
    final controller = Get.put(NoteDetailController(note));

    return Scaffold(
      // Tự động đẩy nội dung lên khi bàn phím hiện
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Chi tiết phiếu'),
        automaticallyImplyLeading: true,
        iconTheme: IconThemeData(
          color: THelperFunctions.isDarkMode(context) ? TColors.light : TColors.dark,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera),
            onPressed: () => shareInvoice(context, controller),
          )
        ],
      ),
      body: GestureDetector(
        // Ẩn bàn phím khi chạm vào vùng trống
        onTap: () => FocusScope.of(context).unfocus(),
        child: Padding(
          padding: const EdgeInsets.all(TSizes.defaultSpace),

          child: Column(
            children: [
              // Phần nội dung có thể cuộn
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: TSizes.xs),
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

                      Obx(
                            () => ListView.builder(
                          shrinkWrap: true, // Quan trọng để nằm trong SingleChildScrollView
                          physics: const NeverScrollableScrollPhysics(), // Tắt cuộn riêng của ListView
                          itemCount: controller.mutableProducts.length,
                          itemBuilder: (context, index) {
                            final product = controller.mutableProducts[index];
                            final totalValue = product['total'] as double;
                            final totalString = NumberFormat.currency(locale: 'vi_VN', symbol: '')
                                .format(totalValue)
                                .replaceAll(',00', '');

                            return Container(
                              padding: const EdgeInsets.only(bottom: TSizes.md),
                              child: Column(
                                children: [
                                  Obx(() => TextFormField(
                                    controller: controller.nameControllers[index],
                                    readOnly: !controller.isEditing.value,
                                    decoration: const InputDecoration(labelText: 'Tên sản phẩm'),
                                    onChanged: (v) => controller.updateProductName(index, v),
                                  )),
                                  const SizedBox(height: TSizes.spaceRowItemsSmail),
                                  Row(
                                    children: [
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
                                              priceController.formatInput();
                                              final rawPrice = priceController.rawValue;
                                              controller.mutableProducts[index]['price'] = rawPrice;
                                              controller.recalculateItemTotal(index);
                                            },
                                          );
                                        }),
                                      ),
                                      const SizedBox(width: TSizes.xs),
                                      Flexible(
                                        flex: 2,
                                        child: Obx(
                                              () => TextFormField(
                                            initialValue: (product['qty'] as int).toString(),
                                            readOnly: !controller.isEditing.value,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                            onChanged: (value) => controller.updateProductQty(index, value),
                                            decoration: const InputDecoration(labelText: TTexts.createQty),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: TSizes.xs),
                                      Flexible(
                                        flex: 2,
                                        child: Obx(
                                              () => TextFormField(
                                            initialValue: product['unit'],
                                            readOnly: !controller.isEditing.value,
                                            onChanged: (value) => controller.updateProductUnit(index, value),
                                            decoration: const InputDecoration(labelText: TTexts.createUnit),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: TSizes.xs),
                                      Flexible(
                                        flex: 5,
                                        child: TextFormField(
                                          key: ValueKey('total_${index}_$totalValue'),
                                          initialValue: totalString,
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

                      const Divider(),

                      /// TỔNG TIỀN & TỔNG NỢ
                      Obx(() {
                        final customer = customersController.getCustomerByName(
                          controller.clientNameController.text.trim(),
                        );

                        final totalDebt = customer.totalDebt;

                        return Column(
                          children: [
                            // 🔹 TỔNG HÓA ĐƠN
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TỔNG HÓA ĐƠN',
                                  style: TextStyle(
                                    fontSize: TSizes.fontSizeMd,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  NumberFormat.currency(locale: 'vi_VN', symbol: '')
                                      .format(controller.grandTotal.value)
                                      .replaceAll(',00', ''),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: TSizes.fontSizeLg,
                                    color: TColors.primary,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: TSizes.sm),

                            // 🔹 TỔNG NỢ KHÁCH
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'TỔNG KHÁCH NỢ',
                                  style: TextStyle(
                                    fontSize: TSizes.fontSizeMd,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  NumberFormat.currency(locale: 'vi_VN', symbol: '')
                                      .format(totalDebt)
                                      .replaceAll(',00', ''),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: TSizes.fontSizeLg,
                                    color: TColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        );
                      }),
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
                    ],
                  ),
                ),
              ),

              /// PHẦN NÚT BẤM (Cố định ở dưới cùng hoặc trên bàn phím)
              const SizedBox(height: TSizes.md),
              Row(
                children: [
                  Expanded(
                    child: Obx(
                          () => ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: controller.isEditing.value ? TColors.primary : TColors.warning),
                        onPressed: () async {
                          if (controller.isEditing.value) {
                            await controller.updateNoteDetails();
                            controller.isEditing.value = false;
                            FocusScope.of(context).unfocus(); // Ẩn bàn phím sau khi lưu
                          } else {
                            controller.isEditing.value = true;
                          }
                        },
                        child: Text(controller.isEditing.value ? 'LƯU' : 'CHỈNH SỬA'),
                      ),
                    ),
                  ),
                  const SizedBox(width: TSizes.sm),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                      onPressed: () => _showDeleteConfirmationDialog(context, controller),
                      child: const Text('XÓA'),
                    ),
                  ),
                ],
              ),
            ],
          ),
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

  Future<void> shareInvoice(
      BuildContext context,
      NoteDetailController controller,
      ) async {
    // ✅ SYNC DATA
    controller.clientNameController.text =
        controller.clientNameController.text.trim();
    controller.phoneNumberController.text =
        controller.phoneNumberController.text.trim();

    final overlay = Navigator.of(context).overlay;
    if (overlay == null) return;

    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: 0,
        top: 0,
        child: Material(
          color: Colors.transparent,
          child: RepaintBoundary(
            key: _exportKey,
            child: SizedBox(
              width: MediaQuery.of(context).size.width,
              child: NoteExportView(controller: controller),
            ),
          ),
        ),
      ),
    );

    overlay.insert(entry);

    // 🔑 ĐỢI FRAME RENDER XONG THẬT
    await WidgetsBinding.instance.endOfFrame;
    await Future.delayed(const Duration(milliseconds: 16));

    final boundary =
    _exportKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    final image = await boundary.toImage(pixelRatio: 3);
    final byteData = await image.toByteData(format: ImageByteFormat.png);
    final bytes = byteData!.buffer.asUint8List();

    entry.remove();

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/invoice.png');
    await file.writeAsBytes(bytes);

    await Share.shareXFiles([XFile(file.path)]);
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