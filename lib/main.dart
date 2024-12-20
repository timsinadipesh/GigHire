import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gighire/chat/chat_list.dart';
import 'package:gighire/base_user/signup.dart';
import 'package:gighire/chat/messaging.dart';
import 'package:gighire/client/client_home.dart';
import 'package:gighire/client/job_posting.dart';
import 'package:gighire/worker/job_details.dart';
import 'package:gighire/worker/worker_home.dart';
import 'package:gighire/worker/worker_profile.dart';
import 'package:gighire/base_user/login.dart';
import 'package:gighire/client/client_profile.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/client_home': (context) => const ClientHomeScreen(),
        '/client_profile': (context) => const ClientProfileScreen(),
        '/post_job': (context) => const JobPostingScreen(),
        '/worker_home': (context) => const WorkerHomeScreen(),
        '/worker_profile': (context) => const WorkerProfileScreen(),
        '/job_details': (context) => const JobDetailsScreen(),
        '/chat_list': (context) => const ChatListScreen(),
        '/message': (context) => const MessagingScreen(),
      },
    );
  }
}
