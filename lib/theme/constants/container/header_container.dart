import 'package:flutter/material.dart';
import '../colors.dart';
import 'circular_container.dart';
import 'curved_edges_widget.dart';

class THeaderContainer extends StatelessWidget {
  const THeaderContainer({
    super.key, required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TCurvedEdgesWidget(
      child: Container(
        color: TColors.primary,
        padding: const EdgeInsets.all(0),

          child: Stack(
            children: [
              Positioned( top: -150, right: -250, child: TCircularContainer(backgroundColor: TColors.white.withOpacity(0.1),)),
              Positioned( top: 100, right: -300, child: TCircularContainer(backgroundColor: TColors.white.withOpacity(0.1),)),
              child,
            ],
          ),
        ),
    );
  }
}