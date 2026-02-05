import 'package:flutter/material.dart';
import 'package:frontend/video_splash_screen.dart';

void main() {
  runApp(const TinyStepsApp());
}

class TinyStepsApp extends StatelessWidget {
  const TinyStepsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: VideoSplashScreen(),
    );
  }
}
