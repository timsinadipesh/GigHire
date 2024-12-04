import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gighire/ui/worker_profile_screen.dart';
import 'ui/login_screen.dart';
import 'payment/payment_service.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Set system overlay style for status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return MaterialApp(
      title: 'Service Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
        fontFamily: 'Arial',
      ),
      home: const WorkerDetailScreen(),
    );
  }
}
