import 'package:flutter/material.dart';
import 'screens/NotiAndNewsScreens/noti_news_main_screen.dart';

void main() {
  runApp(const NotiNewsApp());
}

class NotiNewsApp extends StatelessWidget {
  const NotiNewsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: NotiNewsMainScreen(),
    );
  }
}