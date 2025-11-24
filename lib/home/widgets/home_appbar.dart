import 'package:flutter/material.dart';
import '../../theme/appbar/appbar.dart';
import '../../theme/constants/colors.dart';
import '../../theme/constants/text_strings.dart';

class THomeAppBar extends StatelessWidget {
  const THomeAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return TAppBar(title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(TTexts.homeAppbarTitle, style: Theme.of(context).textTheme.labelMedium!.apply(color: TColors.grey),),
        Text(TTexts.homeAppbarSubTitle, style: Theme.of(context).textTheme.headlineMedium!.apply(color: TColors.white),)
      ],
    ),
      /*actions: [
        TCartCounterIcon(onPressed: () {}, iconColor: TColors.white,),

      ],*/
    );
  }
}