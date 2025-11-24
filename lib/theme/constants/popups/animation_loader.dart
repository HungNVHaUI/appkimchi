import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../colors.dart';
import '../sizes.dart';



class TAnimationLoaderWidget extends StatelessWidget {
    const TAnimationLoaderWidget({
      Key? key,
      required this.text,
      required this.animation,
      this.showAction = false,
      this.actionText,
      this.onActionPressed,
    }): super(key: key);
    final String text;
    final String animation;
    final bool showAction;
    final String? actionText;
    final VoidCallback? onActionPressed;
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
        Lottie.asset(animation, width: MediaQuery.of(context).size.width * 0.8),
        const SizedBox(height: TSizes.defaultSpace),

        Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: TSizes.defaultSpace),
          showAction ? SizedBox(
            width: 200,
            child: OutlinedButton(
              onPressed: onActionPressed,
              style: OutlinedButton.styleFrom(backgroundColor: TColors.black),
              child: Text(
                actionText!,
                style: Theme.of(context).textTheme.bodyMedium!.apply(color: TColors.light),
              ),
            ),
          ) : const SizedBox(),
       ]
      )
    );
  }
}




