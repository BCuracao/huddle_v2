import 'package:flutter/material.dart';
import 'dart:math';

class CircularRevealRoute extends PageRouteBuilder {
  final Widget page;
  final Offset? centerAlignment;
  final Duration duration;

  CircularRevealRoute({
    required this.page,
    this.centerAlignment,
    this.duration = const Duration(milliseconds: 1200),
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: duration,
        );

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    final size = MediaQuery.of(context).size;
    final center = centerAlignment ?? Offset(size.width / 2, size.height / 2);
    final maxRadius = sqrt(size.width * size.width + size.height * size.height);
    return AnimatedBuilder(
      animation: animation,
      builder: (context, _) {
        return ClipPath(
          clipper: _CircleRevealClipper(
            fraction: animation.value,
            center: center,
            maxRadius: maxRadius,
          ),
          child: child,
        );
      },
    );
  }
}

class _CircleRevealClipper extends CustomClipper<Path> {
  final double fraction;
  final Offset center;
  final double maxRadius;

  _CircleRevealClipper(
      {required this.fraction, required this.center, required this.maxRadius});

  @override
  Path getClip(Size size) {
    final radius = maxRadius * fraction;
    return Path()..addOval(Rect.fromCircle(center: center, radius: radius));
  }

  @override
  bool shouldReclip(_CircleRevealClipper oldClipper) {
    return oldClipper.fraction != fraction || oldClipper.center != center;
  }
}
