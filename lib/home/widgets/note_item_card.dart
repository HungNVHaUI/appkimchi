// File: ghi_no/home/widgets/note_item_card.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../theme/constants/colors.dart';
import '../../theme/constants/sizes.dart';
import '../../theme/helpers/helper_functions.dart';
import '../model/note_model.dart';
import 'detail_screen.dart'; // Đảm bảo đường dẫn này đúng

class NoteItemCard extends StatelessWidget {
  final NoteModel note;
  const NoteItemCard({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: '₫');
    final dateFormatter = DateFormat('dd/MM/yyyy');
    final isDarkMode = THelperFunctions.isDarkMode(context);
    final borderColor = isDarkMode ? TColors.light : TColors.dark;
    final statusColor = note.debt ? TColors.warning : TColors.primary;

    return InkWell(
      onTap: () => Get.to(() => NoteDetailScreen(note: note)),
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
          border: Border.all(
            width: 1,
            color: borderColor,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Tên Khách hàng và Ngày
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      note.clientName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: TSizes.fontSizeLg,),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: TSizes.sm),
                  Text(
                    "Ngày: ${dateFormatter.format(note.createdAt)}",
                    style: const TextStyle(fontSize: TSizes.fontSizeSm, color: TColors.darkGrey),
                  ),
                ]
            ),

            const SizedBox(height: TSizes.md),

            // 2. Tổng Tiền và Trạng thái
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Tổng: ${currencyFormatter.format(note.totalAll)}",
                    style: const TextStyle(fontSize: TSizes.fontSizeSm, fontWeight: FontWeight.w600),
                  ),

                  // Icon Trạng thái
                  Row(
                    children: [
                      if (note.debt)
                        const Text(
                          "Đã Ghi Nợ ",
                          style: TextStyle(fontSize: TSizes.fontSizeSm, color: TColors.warning, fontWeight: FontWeight.bold),
                        ),
                      Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: statusColor,
                        ),
                      ),
                    ],
                  ),
                ]
            )

          ],
        ),
      ),
    );
  }
}