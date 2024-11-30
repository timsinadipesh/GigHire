import 'package:flutter/material.dart';
import 'package:gighire/Auth/auth_service.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  void logout() {
    //get auth service
    final _auth = AuthService();
    _auth.SignOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        actions: [
          //Logout button

          IconButton(onPressed: logout, icon: Icon(Icons.logout))
        ],
      ),
      drawer: Drawer(),
    );
  }
}
