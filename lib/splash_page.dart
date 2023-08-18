import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quest/home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..forward();

    animation = CurvedAnimation(parent: controller, curve: Curves.linear);
    Timer(
      const Duration(seconds: 3),
      navigateToNextScreen,
    );
  }

  void navigateToNextScreen() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const HomePage()),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ScaleTransition(
            scale: animation,
            child: Center(
              child: Image.asset(
                "assets/images/virtualAssistant.png",
                width: 200,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Image.asset(
              "assets/images/textfx.png",
              width: 300,
            ),
          ),
        ],
      ),
    );
  }
}
