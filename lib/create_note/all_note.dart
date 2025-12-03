import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghi_no/home/widgets/filter_dropdowns.dart';
import '../../fill/fill_controller.dart';
import '../theme/constants/colors.dart';
import '../theme/constants/container/header_container.dart';
import '../theme/constants/container/search_container.dart';
import '../theme/constants/sizes.dart';
import '../theme/constants/text_strings.dart';
import 'package:intl/intl.dart';

import '../theme/helpers/helper_functions.dart';


class AllNoteScreen extends StatelessWidget {
  AllNoteScreen({super.key});

  final controller = Get.put(FillController());

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FillController>();
    // Lấy theme để điều chỉnh màu sắc nếu cần
    final isDarkMode = THelperFunctions.isDarkMode(context);

    return Scaffold(
      body: Column(
        children: [
          THeaderContainer(
            child: Column(
              children: [
                const SizedBox(height: TSizes.spaceBtwSections),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      TTexts.homeAppbarSubTitle,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .apply(color: TColors.white),
                    )
                  ],
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
                TSearchContainer(
                  text: "Tìm khách hàng",
                  showBorder: false,
                  onChanged: (value) => controller.searchClient.value = value,
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
                Padding(
                  padding: EdgeInsets.only(
                      left: TSizes.spaceBtwItems, right: TSizes.spaceBtwItems),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text("Danh Sách Khách",
                            style:
                                Theme.of(context).textTheme.titleSmall!.apply(
                                      color: TColors.white,
                                    )),
                      ),
                      Obx(() => Text(
                            "Tổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: '').format(controller.totalSelected.value)}",
                        style: Theme.of(context).textTheme.titleMedium!.apply(color: TColors.white),
                          )),
                    ],
                  ),
                ),
                const SizedBox(height: TSizes.spaceBtwSections),
              ],
            ),
          ),

          /// 🔹 Filter Dropdown
          Padding(
            // 👈 THÊM PADDING DƯỚI CHO FILTER ĐỂ TẠO KHOẢNG CÁCH VỚI LIST
            padding: const EdgeInsets.only(
                left: TSizes.defaultSpace, right: TSizes.defaultSpace),
            // TSizes.md
            child: FilterDropdowns(controller: controller),
          ),
          const SizedBox(height: TSizes.spaceRowItems),

          /// 🔹 Danh sách ghi chú
          Expanded(
            child: Obx(() {
              /// ========== LOADING STATE ==========
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              /// Lấy danh sách đã lọc
              final notes = controller.filteredNotes;

              /// ========== KHÔNG CÓ DỮ LIỆU ==========
              if (controller.allNotes.isEmpty) {
                return const Center(
                  child: Text(
                    "Hiện tại không có ghi chú nào được lưu.",
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                );
              }

              /// ========== LỌC XONG NHƯNG RỖNG ==========
              if (notes.isEmpty) {
                return const Center(
                  child: Text(
                    "Không tìm thấy ghi chú nào.",
                    style: TextStyle(fontSize: 16.0, color: Colors.grey),
                  ),
                );
              }

              /// ========== HIỂN THỊ DANH SÁCH ==========
              // Giả định NotesListView đã có padding/separator tốt
              return Padding(
                padding: const EdgeInsets.only(
                    left: TSizes.defaultSpace, right: TSizes.defaultSpace),
                child: NotesListView(notes: notes,showCheckBox: true,),
              );
            }),
          ),
        ],
      ),
    );
  }
}
