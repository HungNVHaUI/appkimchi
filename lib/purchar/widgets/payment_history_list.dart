import 'package:flutter/material.dart';
import 'package:get/get.dart'; // Thêm Get để dùng Dialog
import 'package:ghi_no/theme/constants/colors.dart';
import 'package:ghi_no/theme/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';
import 'package:intl/intl.dart';

import '../purchar_model.dart';

class PaymentHistoryList extends StatelessWidget {
  const PaymentHistoryList({super.key, required this.payments, required this.onDelete});

  final List<PaymentInfo> payments;
  final Function(PaymentInfo) onDelete;

  // Hàm hiển thị Dialog xác nhận xóa đồng bộ với app

// Hàm hiển thị Dialog xác nhận xóa theo đúng mẫu bạn gửi
  void _showConfirmDelete(BuildContext context, PaymentInfo pay) {
    final fmt = NumberFormat('#,###', 'vi_VN');
    final isReturnGoods = pay.note.contains('Trả đồ');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text(
          isReturnGoods
              ? 'Bạn có chắc muốn xóa lịch sử trả đồ trị giá ${fmt.format(pay.amount)}?'
              : 'Bạn có chắc muốn xóa khoản tạm ứng ${fmt.format(pay.amount)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete(pay); // Thực hiện xóa
            },
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: payments.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final pay = payments[i];

        final isReturnGoods = pay.note.contains('Trả đồ');
        final mainColor = isReturnGoods ? Colors.orange : Colors.green;
        final leadingIcon = isReturnGoods ? Iconsax.box_remove : Icons.payments;

        return ListTile(

          //onLongPress: () => _showConfirmDelete(context, pay),
          leading: Icon(leadingIcon, color: mainColor),

          title: Text(
            '- ${fmt.format(pay.amount)}',
            style: TextStyle(
              color: mainColor,
              fontSize: TSizes.fontSizeLg,
              fontWeight: FontWeight.bold,
            ),
          ),

          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(DateFormat('dd/MM/yyyy HH:mm').format(pay.date)),
              if (pay.note.isNotEmpty)
                Text(
                  pay.note,
                  style: const TextStyle(fontStyle: FontStyle.italic, color: TColors.darkGrey),
                ),
            ],
          ),

          trailing: IconButton(
            icon: const Icon(Iconsax.trash, size: 18, color: TColors.grey),
            onPressed: () => _showConfirmDelete(context, pay), // Gọi Dialog xác nhận
          ),
        );
      },
    );
  }
}