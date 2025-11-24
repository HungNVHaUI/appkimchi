import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../theme/constants/colors.dart';
import '../theme/constants/sizes.dart';
import '../theme/constants/text_strings.dart';
import '../theme/helpers/helper_functions.dart';
import 'create_note_controller.dart';


class DebtCheckbox extends StatelessWidget {
  const DebtCheckbox({
    super.key,
  });


  @override
  Widget build(BuildContext context) {
    final controller = CreateNoteController.instance;
    final dark = THelperFunctions.isDarkMode(context);
    const sizeFactor = 0.88;
    return Row(
      children: [
        SizedBox(
            width: 20 * sizeFactor,
            height: 20 * sizeFactor,
            child: Obx(() => Checkbox(
                value: controller.isDebt.value,
                onChanged: (valve) => controller.isDebt.value =! controller.isDebt.value)
            )
        ),
        const SizedBox(width: TSizes.spaceBtwItems),
        Text.rich(
            TextSpan(
              children: [
                TextSpan(text: '${TTexts.debt} ', style: Theme.of(context).textTheme.bodySmall!.apply(fontSizeFactor: sizeFactor)),
              ],
            )),
      ],
    );
  }
}