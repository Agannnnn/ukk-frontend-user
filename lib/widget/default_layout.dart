import 'package:flutter/material.dart';
import 'package:flutter_session_manager/flutter_session_manager.dart';
import 'package:frontend_user/pages/auctions.dart';
import 'package:frontend_user/pages/login.dart';
import 'package:frontend_user/pages/profile.dart';

class DefaultLayout extends StatelessWidget {
  const DefaultLayout({
    super.key,
    required this.body,
    this.floatingActionButton,
  });

  final Widget body;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("LELANG.ID")),
      drawer: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ListTile(
              title: Text("LELANG.ID"),
              tileColor: Color.fromRGBO(103, 148, 142, 1),
              textColor: Colors.white,
            ),
            ListTile(
              title: const Text("PELELANGAN"),
              textColor: Colors.grey[700],
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Auctions()),
                );
              },
            ),
            ListTile(
              title: const Text("PELELANGAN DIIKUTI"),
              textColor: Colors.grey[700],
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const Auctions(onlyFollowed: true)),
                );
              },
            ),
            ListTile(
              title: const Text("PROFIL"),
              textColor: Colors.grey[700],
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const Profile()),
                );
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton.icon(
                  onPressed: () async {
                    await SessionManager().destroy();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const Login()),
                    );
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text("Logout")),
            )
          ],
        ),
      ),
      body: body,
      floatingActionButton: floatingActionButton,
    );
  }
}
