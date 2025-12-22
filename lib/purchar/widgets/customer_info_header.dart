import 'package:flutter/material.dart';
import 'package:ghi_no/theme/constants/colors.dart';
import 'package:ghi_no/theme/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

import '../purchar_model.dart';

class CustomerInfoHeader extends StatelessWidget {
  const CustomerInfoHeader({super.key, required this.customer, required this.onCall, required this.formatDebt});

  final CustomerInfo customer;
  final Function(String) onCall;
  final String formatDebt;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (customer.phoneNumbers.isNotEmpty) ...[
          const Text('Số điện thoại', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: TSizes.sm),
          Wrap(
            spacing: TSizes.sm,
            children: customer.phoneNumbers.map((p) => ActionChip(
              onPressed: () => onCall(p),
              label: Text(p, style: Theme.of(context).textTheme.labelSmall),
              avatar: const Icon(Iconsax.call, size: TSizes.md),
              backgroundColor: isDark ? TColors.darkGrey : TColors.softGrey,
            )).toList(),
          ),
          const SizedBox(height: 16),
        ],
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tổng còn nợ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: TSizes.fontSizeMd)),
            Text(
              formatDebt,
              style: TextStyle(
                fontSize: TSizes.fontSizeLg,
                color: customer.totalDebt > 0 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}