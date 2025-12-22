import 'package:flutter/material.dart';
import 'package:ghi_no/theme/constants/colors.dart';
import 'package:ghi_no/theme/constants/sizes.dart';
import 'package:intl/intl.dart';

import '../purchar_model.dart';

class PurchaseHistoryList extends StatelessWidget {
  const PurchaseHistoryList({super.key, required this.purchases});

  final List<PurchaseInfo> purchases;

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat('#,###', 'vi_VN');

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: purchases.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, i) {
        final p = purchases[i];
        return ListTile(
          leading: const Icon(Icons.shopping_bag_outlined),
          title: Text(
            fmt.format(p.amount),
            style: const TextStyle(
              fontSize: TSizes.fontSizeLg,
              fontWeight: FontWeight.w600,
            ),
          ),
          subtitle: Text(
            DateFormat('dd/MM/yyyy HH:mm').format(p.date),
           // style: Theme.of(context).textTheme.bodySmall,
          ),
          trailing: p.debt
              ? const Icon(
            Icons.circle,
            color: TColors.warning, // Màu cam cho hóa đơn NỢ
            size: TSizes.iconSm,
          )
              : const Icon(
            Icons.circle,
            color: TColors.primary, // Màu xanh cho hóa đơn ĐÃ TRẢ
            size: TSizes.iconSm,
          ),
        );
      },
    );
  }
}