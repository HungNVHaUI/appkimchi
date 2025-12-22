import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghi_no/home/note_home/note_detail_screen.dart'; //
import 'package:ghi_no/home/widgets/selectable_checkbox.dart';
import 'package:intl/intl.dart';
import '../../create_note/model/note_model.dart';
import '../../fill/fill_controller.dart';
import '../../theme/constants/colors.dart';
import '../../theme/constants/sizes.dart';
import '../../theme/helpers/helper_functions.dart';

class ListNotesWidget extends StatelessWidget {
  const ListNotesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Khởi tạo/Tìm Controller
    final controller = Get.put(FillController());


    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0), // Thêm padding ngoài
      child: Column(
        children: [
          // 🔹 FILTER UI
          FilterDropdowns(controller: controller),

          // 🔹 LIST DATA
          // Sử dụng Obx để lắng nghe thay đổi của allNotes, selectedMonth, selectedYear và filteredNotes
          // Trong ListNotesWidget.build()
          Expanded(
            child: Obx(() {
              // 1. Kiểm tra trạng thái tải
              if (controller.allNotes.isEmpty && controller.selectedMonth.value == null && controller.selectedYear.value == null) {
                // Đây là lúc đang tải, hoặc đã tải xong và không có bất kỳ dữ liệu nào trong Firestore
                // Tạm thời coi là đang tải cho đến khi chắc chắn
                return const Center(child: CircularProgressIndicator());
              }

              final notes = controller.filteredNotes;

              if (notes.isEmpty) {
                // Nếu không có bất kỳ dữ liệu nào được tải, thông báo khác:
                if (controller.allNotes.isEmpty) {
                  return const Center(child: Text("Hiện tại không có ghi chú nào được lưu."));
                }
                // Nếu allNotes có dữ liệu, nhưng kết quả lọc rỗng:
                return const Center(child: Text("Không tìm thấy."));
              }

              return NotesListView(notes: notes, showCheckBox: false,);
            }),
          ),
        ],
      ),
    );
  }
}

// Tách widget Bộ lọc
class FilterDropdowns extends StatelessWidget {
  final FillController controller;
  const FilterDropdowns({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: TSizes.xs),
      child: Row(
        children: [
          // 3. Dropdown Tháng
          Expanded(
            child: Obx(
                  () => DropdownButtonFormField<int?>(
                value: controller.selectedMonth.value,
                decoration: const InputDecoration(labelText: 'Tháng'), // Thêm label
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text("Tất cả")),
                  ...controller.availableMonths.map(
                        (m) => DropdownMenuItem<int?>(value: m, child: Text("Tháng $m")),
                  ),
                ],
                onChanged: (v) => controller.selectedMonth.value = v,// Gán trực tiếp Rxn<int>
              ),
            ),
          ),
          const SizedBox(width: TSizes.md),
          // 4. Dropdown Năm
          Expanded(
            child: Obx(
                  () => DropdownButtonFormField<int?>(
                value: controller.selectedYear.value,
                decoration: const InputDecoration(labelText: 'Năm'), // Thêm label
                items: [
                  const DropdownMenuItem<int?>(value: null, child: Text("Tất cả")),
                  ...controller.availableYears.map(
                        (y) => DropdownMenuItem<int?>(value: y, child: Text("Năm $y")),
                  ),
                ],
                onChanged: (v) => controller.selectedYear.value = v,// Gán trực tiếp Rxn<int>
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Tách widget Danh sách
class NotesListView extends StatelessWidget {
  final List<NoteModel> notes;
  final bool showCheckBox;

  const NotesListView({super.key, required this.notes, required this.showCheckBox});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: notes.length,
      separatorBuilder: (_, __) => const SizedBox(height: TSizes.defaultSpace),
      itemBuilder: (context, index) {
        final note = notes[index];
        final controller = Get.find<FillController>();

        return Obx(() {
          final isChecked = controller.checkedMap[note.id] ?? false;

          return InkWell(
            onTap: () => Get.to(() => NoteDetailScreen(note: note)),
            child: Container(
              padding: const EdgeInsets.only(
                left: TSizes.md,
                right: TSizes.md,
                bottom: 5,
                top: 5,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(TSizes.borderRadiusMd),
                border: Border.all(
                  width: 1,
                  color: THelperFunctions.isDarkMode(context)
                      ? TColors.light
                      : TColors.dark,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          note.clientName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: TSizes.fontSizeLg,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: TSizes.xs),
                        Text(
                          "Ngày: ${DateFormat('dd/MM/yyyy').format(note.createdAt)}",
                          style: const TextStyle(fontSize: TSizes.fontSizeSm),
                        ),
                        const SizedBox(height: TSizes.xs),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Tổng: ${NumberFormat.currency(locale: 'vi_VN', symbol: '₫').format(note.totalAll)}",
                                style: const TextStyle(fontSize: TSizes.fontSizeSm),
                              ),

                            ]),
                      ],
                    ),
                  ),
                  /// 🔹 THÊM CHECKBOX
                  Column(
                    children: [
                      Container(
                        //padding: const EdgeInsets.only(top: 13,),
                        alignment: Alignment.center,       // canh giữa widget con
                        child: SelectableCheckbox(
                          noteId: note.id,
                          showCheckBox: showCheckBox,
                        ),
                      ),
                      Container(
                        width: 15,
                        height: 15,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: note.debt ? TColors.warning : TColors.primary,
                        ),
                      ),
                    ],
                  ),


                ],
              ),
            ),
          );
        });
      },
    );
  }
}
