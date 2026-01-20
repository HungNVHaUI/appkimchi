import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../note_detail_controller.dart';
import 'package:intl/intl.dart';


class ExportHeader extends StatelessWidget {
  final NoteDetailController controller;

  const ExportHeader({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'PHIẾU BÁN HÀNG',
          style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black // Đảm bảo màu đen
          ),
        ),
        const SizedBox(height: 8),

        // Dùng Obx để lắng nghe thay đổi từ controller
        Text(
          'Khách hàng: ${controller.clientNameController.text.isEmpty ? "N/A" : controller.clientNameController.text}',
          style: const TextStyle(color: Colors.black87),
        ),
        Text(
          'SĐT: ${controller.phoneNumberController.text.isEmpty ? "N/A" : controller.phoneNumberController.text}',
          style: const TextStyle(color: Colors.black87),
        ),

        const SizedBox(height: 6),

        Text(
          'Ngày: ${DateFormat('dd/MM/yyyy – HH:mm').format(DateTime.now())}',
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),

        const Divider(thickness: 1, color: Colors.black26),
      ],
    );
  }
}
