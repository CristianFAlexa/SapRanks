import 'package:flutter/material.dart';

class Cutout extends StatelessWidget {
 const Cutout({
  Key key,
  @required this.color,
  @required this.child,
 }) : super(key: key);

 final Color color;
 final Widget child;

 @override
 Widget build(BuildContext context) {
  return ShaderMask(
   blendMode: BlendMode.srcIn,
   shaderCallback: (bounds) =>
     LinearGradient(colors: [color], stops: [0.0]).createShader(bounds),
   child: child,
  );
 }
}