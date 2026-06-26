// lib/main.dart
import 'package:erp_frontend_project/presentation/stock/stock_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart' hide FirebaseService;
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'data/services/firebase_service.dart';
import 'presentation/providers/providers.dart';
import 'presentation/widgets/common/app_shell.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/orders/new_order_screen.dart';
import 'presentation/screens/stock/stock_list_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final service = FirebaseService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthProvider(service)),
        ChangeNotifierProvider(create: (context) => SiparisProvider(service)),
        ChangeNotifierProvider(create: (context) => StokProvider(service)),
        ChangeNotifierProvider(create: (context) => NavigationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Düzgün Panjur ERP',
      home: BodyMyApp(),
    );
  }
}

class BodyMyApp extends StatelessWidget {
  const BodyMyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final rota = context.watch<NavigationProvider>().aktifRota;

    Widget aktifSayfa;
    switch (rota) {
      case AppRoutes.dashboard:
        aktifSayfa = const DashboardScreen();
        break;
      case AppRoutes.newOrder:
        aktifSayfa = const NewOrderScreen();
        break;
      case AppRoutes.stock:
        aktifSayfa = const StockListScreen();
        break;
      default:
        aktifSayfa = const DashboardScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: AppShell(child: aktifSayfa),
    );
  }
}