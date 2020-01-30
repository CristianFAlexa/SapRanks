import 'package:flutter/material.dart';

class MyClipper extends CustomClipper<Path> {
 @override
 Path getClip(Size size) {
  Path path = Path();
  path.lineTo(0, size.height - 50); // to change later if desired
  path.lineTo(size.width, size.height);
  path.lineTo(size.width, 0);
  path.close();
  return path;
 }

 @override
 bool shouldReclip(CustomClipper<Path> oldClipper) {
  return true;
 }
}