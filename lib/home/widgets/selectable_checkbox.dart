import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../fill/fill_controller.dart';

class SelectableCheckbox extends StatelessWidget {
  final String noteId;
  final bool showCheckBox; // biến truyền vào để quyết định hiển thị
  const SelectableCheckbox({super.key, required this.noteId, this.showCheckBox = false});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<FillController>();

    // Nếu show = false thì trả về SizedBox ẩn
    if (!showCheckBox) return const SizedBox(width: 0);

    return Obx(() {
      return Center(
        child: Transform.scale(
          scale: 1.3, // tăng kích thước checkbox
          child: Checkbox(
            value: controller.checkedMap[noteId] ?? false,
            onChanged: (_) => controller.toggleCheckById(noteId),
          ),
        ),
      );

    });
  }
}
