import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:ghi_no/home/widgets/filter_dropdowns.dart';
import '../../../fill/fill_controller.dart';

class ListNotesPage extends StatelessWidget {
  const ListNotesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Khởi tạo/Tìm Controller
    final controller = Get.put(FillController());

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0),
      child: Column(
        children: [
          // 🔹 FILTER UI
          FilterDropdowns(controller: controller),

          // 🔹 LIST DATA
          Expanded(
            child: Obx(() {
              if (controller.allNotes.isEmpty &&
                  controller.selectedMonth.value == null &&
                  controller.selectedYear.value == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final notes = controller.filteredNotes;

              if (notes.isEmpty) {
                // Nếu allNotes rỗng, hiển thị thông báo "chưa có"
                if (controller.allNotes.isEmpty) {
                  return const Center(child: Text("Hiện tại không có ghi chú nào được lưu."));
                }
                // Nếu allNotes có dữ liệu, nhưng kết quả lọc rỗng
                return const Center(child: Text("Không tìm thấy ghi chú nào."));
              }

              return NotesListView(notes: notes,showCheckBox: true,);
            }),
          ),
        ],
      ),
    );
  }
}