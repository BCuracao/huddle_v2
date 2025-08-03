import 'package:flutter/material.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:huddle/features/app/presentation/widgets/circular_reveal_route.dart';

class SplashScreen extends StatefulWidget {
  final Widget? child;
  const SplashScreen({super.key, this.child});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 4), () {
      Navigator.pushAndRemoveUntil(
        context,
        CircularRevealRoute(
          page: widget.child!,
          centerAlignment: null, // Center of the screen
          duration: const Duration(milliseconds: 1200),
        ),
        (route) => false,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.tealAccent[400]!,
              const Color.fromARGB(255, 122, 255, 222),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      "Huddle",
                      textStyle: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Montserrat"),
                      speed: const Duration(milliseconds: 250),
                    ),
                  ],
                  totalRepeatCount: 1,
                  pause: const Duration(milliseconds: 0),
                  displayFullTextOnTap: true,
                  stopPauseOnTap: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
