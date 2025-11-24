import 'package:flutter/material.dart';


class TCustomCurvedEdges extends CustomClipper<Path>{

  @override
  Path getClip(Size size){
    var path = Path();
    path.lineTo(0, size.height);

    final fistCurved = Offset(0, size.height - 20);
    final lastCurved = Offset(30, size.height - 20);
    path.quadraticBezierTo(fistCurved.dx, fistCurved.dy, lastCurved.dx, lastCurved.dy);

    final secondFistCurved = Offset(0, size.height - 20);
    final secondLastCurved = Offset(size.width - 30, size.height - 20);
    path.quadraticBezierTo(secondFistCurved.dx, secondFistCurved.dy, secondLastCurved.dx, secondLastCurved.dy);

    final thirdFistCurved = Offset(size.width, size.height - 20);
    final thirdLastCurved = Offset(size.width, size.height);
    path.quadraticBezierTo(thirdFistCurved.dx, thirdFistCurved.dy, thirdLastCurved.dx, thirdLastCurved.dy);
    
    path.lineTo(size.width, 0);
    // path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return true;
  }

}