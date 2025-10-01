import 'package:flutter/material.dart';

// Custom clipper for chat bubbles
class ChatBubbleClipper extends CustomClipper<Path> {
  final bool isReceiver;
  final double radius;

  ChatBubbleClipper({required this.isReceiver, this.radius = 12.0});

  @override
  Path getClip(Size size) {
    final path = Path();
    final tailSize = 8.0;

    if (isReceiver) {
      path.moveTo(tailSize, radius);
      path.quadraticBezierTo(tailSize, 0, tailSize + radius, 0);
      path.lineTo(size.width - radius, 0);
      path.quadraticBezierTo(size.width, 0, size.width, radius);
      path.lineTo(size.width, size.height - radius);
      path.quadraticBezierTo(
        size.width,
        size.height,
        size.width - radius,
        size.height,
      );
      path.lineTo(tailSize + radius, size.height);
      path.quadraticBezierTo(
        tailSize,
        size.height,
        tailSize,
        size.height - radius,
      );
      path.lineTo(tailSize, radius + tailSize);
      path.lineTo(0, radius);
      path.close();
    } else {
      path.moveTo(radius, 0);
      path.lineTo(size.width - tailSize - radius, 0);
      path.quadraticBezierTo(
        size.width - tailSize,
        0,
        size.width - tailSize,
        radius,
      );
      path.lineTo(size.width - tailSize, radius + tailSize);
      path.lineTo(size.width, radius);
      path.lineTo(size.width - tailSize, size.height - radius);
      path.quadraticBezierTo(
        size.width - tailSize,
        size.height,
        size.width - tailSize - radius,
        size.height,
      );
      path.lineTo(radius, size.height);
      path.quadraticBezierTo(0, size.height, 0, size.height - radius);
      path.lineTo(0, radius);
      path.quadraticBezierTo(0, 0, radius, 0);
      path.close();
    }

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
