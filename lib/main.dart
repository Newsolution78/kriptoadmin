import 'package:crypto_admin/providers/customer.dart';
import 'package:crypto_admin/providers/transaction.dart';

import 'package:crypto_admin/screens/customer_screen_sync.dart';

import 'package:crypto_admin/screens/main_screen.dart';
import 'package:crypto_admin/screens/transaction_screen.dart';
import 'package:crypto_admin/screens/user_screen_sync.dart';
import 'package:flutter/material.dart';
import './providers/auth.dart';

import './screens/auth_screen.dart';
import 'package:provider/provider.dart';
import 'package:dargon2_flutter/dargon2_flutter.dart';

import 'providers/user.dart';

Future<void> main() async {
  DArgon2Flutter.init();
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Auth(),
        ),
        ChangeNotifierProvider(
          create: (context) => Customer(0, '', '', [], 0),
        ),
        ChangeNotifierProvider(
          create: (context) => Transaction('', 0, '', 0, '', 0, 0,
              DateTime.now(), 0, 0, '', '', 0, '', 0, 0, [], 0),
        ),
        ChangeNotifierProvider(
          create: (context) => User(0, '', '', [], 0, '', '', ''),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Kriptonit admin',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: const AuthScreen(),
        routes: {
          AuthScreen.routeName: (context) => const AuthScreen(),
          MainScreen.routeName: (context) => const MainScreen(),
          CustomersDataSyncScreen.routeName: (context) =>
              const CustomersDataSyncScreen(),
          TransactionDataSyncScreen.routeName: (context) =>
              const TransactionDataSyncScreen(),
          UsersDataSyncScreen.routeName: (context) =>
              const UsersDataSyncScreen(),
        },
      ),
    );
  }
}
