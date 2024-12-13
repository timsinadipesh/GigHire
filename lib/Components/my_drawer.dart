import 'package:flutter/material.dart';
import 'package:gighire/chat/chat.dart';
import 'package:gighire/Services/Auth/auth_service.dart';
import 'package:gighire/chat/chat_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout() {
    //get auth service
    final auth = AuthService();
    auth.SignOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.background,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              //logo
              DrawerHeader(
                child: Center(
                  child: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary,
                    size: 50,
                  ),
                ),
              ),

              //home list tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  title: const Text("H O M E"),
                  leading: const Icon(Icons.home),
                  onTap: () {
                    //Pop the drawer
                    Navigator.pop(context);
                  },
                ),
              ),

              // //chat list tile
              // Padding(
              //   padding: const EdgeInsets.only(left: 25.0),
              //   child: ListTile(
              //     title: const Text("C H A T"),
              //     leading: const Icon(Icons.chat),
              //     onTap: () {
              //       //Pop the drawer
              //       Navigator.pop(context);
              //       Navigator.push(
              //           context,
              //           MaterialPageRoute(
              //             builder: (context) => Chat_(),
              //           ));
              //     },
              //   ),
              // ),
            ],
          ),

          //logout list tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              title: const Text("L O G O U T"),
              leading: const Icon(Icons.logout),
              onTap: logout,
            ),
          ),
        ],
      ),
    );
  }
}
