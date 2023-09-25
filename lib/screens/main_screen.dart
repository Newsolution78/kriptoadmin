import 'package:crypto_admin/screens/customer_screen_sync.dart';
import 'package:crypto_admin/screens/transaction_screen.dart';
import 'package:flutter/material.dart';

import 'user_screen_sync.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);
  static const routeName = '/main';

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    final deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(title: const Text('Fő képernyő')),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text('Drawer Header'),
            ),
            ListTile(
              title: const Text('Transactions list'),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(TransactionDataSyncScreen.routeName);
              },
            ),
            ListTile(
              title: const Text('Customers sync'),
              onTap: () {
                Navigator.of(context)
                    .pushNamed(CustomersDataSyncScreen.routeName);
              },
            ),
            ListTile(
              title: const Text('Users sync'),
              onTap: () {
                Navigator.of(context).pushNamed(UsersDataSyncScreen.routeName);
              },
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: 100,
              child: SizedBox(
                width: deviceSize.width,
                child: const Center(child: Text('Fő képernyő')),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
