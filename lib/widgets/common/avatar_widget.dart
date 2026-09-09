import 'package:flutter/material.dart';
import '../../core/avatar_palette.dart';

class CustomAvatar extends StatelessWidget {
  final String type;
  final Color hairColor;
  final Color bgColor;
  final double radius;
  final Color skinColor;

  const CustomAvatar({
    super.key,
    required this.type,
    required this.hairColor,
    required this.bgColor,
    this.radius = 26,
    this.skinColor = AvatarPalette.defaultSkinColor,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: bgColor,
      child: Icon(
        type == 'boy' ? Icons.face : Icons.face_3,
        size: radius * 1.1,
        color: hairColor,
      ),
    );
  }
}
