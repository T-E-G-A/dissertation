import 'package:flutter/material.dart';

class SplashClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path();
    path.moveTo(size.width * 0.5, 0);
    path.quadraticBezierTo(size.width * 0.8, size.height * 0.1,
        size.width * 0.95, size.height * 0.3);
    path.quadraticBezierTo(
        size.width, size.height * 0.5, size.width * 0.8, size.height * 0.7);
    path.quadraticBezierTo(
        size.width * 0.6, size.height, size.width * 0.3, size.height * 0.9);
    path.quadraticBezierTo(
        0, size.height * 0.8, size.width * 0.1, size.height * 0.5);
    path.quadraticBezierTo(
        size.width * 0.2, size.height * 0.2, size.width * 0.5, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
