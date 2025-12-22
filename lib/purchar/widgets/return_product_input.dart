import 'package:flutter/material.dart';
import 'package:ghi_no/theme/constants/sizes.dart';
import 'package:iconsax/iconsax.dart';

class ReturnProductInput extends StatelessWidget {
  const ReturnProductInput({
    super.key,
    required this.controller,
    required this.onConfirm,
  });

  final TextEditingController controller;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextFormField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Tiền trả hàng (trả đồ)',
              prefixIcon: Icon(Iconsax.box_remove, color: Colors.orange),
            ),
          ),
        ),
        const SizedBox(width: TSizes.md),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
          onPressed: onConfirm,
          child: const Icon(Icons.assignment_return),
        )
      ],
    );
  }
}