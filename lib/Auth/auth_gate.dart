import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gighire/Auth/Login_and_Register.dart';
import 'package:gighire/ui/HomeScreen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //User is logged in
          if (snapshot.hasData) {
            return const HomeScreen();
          }

          //User is Not logged in
          else {
            return const LoginOrRegister();
          }
        },
      ),
    );
  }
}
