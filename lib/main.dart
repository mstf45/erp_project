import 'package:erp_frontend_project/core/constants/app_constants.dart';
import 'package:erp_frontend_project/data/services/firebase_service.dart';
import 'package:erp_frontend_project/presentation/providers/providers.dart';
import 'package:erp_frontend_project/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:erp_frontend_project/presentation/screens/orders/new_order_screen.dart';
import 'package:erp_frontend_project/presentation/stock/stock_list_screen.dart';
import 'package:erp_frontend_project/presentation/widgets/common/app_shell.dart';
import 'package:erp_frontend_project/presentation/screens/orders/new_order_screen.dart';
import 'package:firebase_core/firebase_core.dart' hide FirebaseService;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';

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
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: BodyMyApp(),
    );
  }
}

// main.dart içindeki BodyMyApp sınıfını bununla değiştir:
class BodyMyApp extends StatelessWidget {
  const BodyMyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // NavigationProvider'ı dinleyip aktif rotayı alıyoruz
    final rota = context.watch<NavigationProvider>().aktifRota;

    Widget aktifSayfa;
    switch (rota) {
      case AppRoutes.dashboard:
        aktifSayfa = const DashboardScreen();
        break;
      case AppRoutes.newOrder:
        aktifSayfa = const NewOrderScreen(); // Yeni sipariş ekranımız
        break;
      case AppRoutes.stock:
        aktifSayfa = const StockListScreen();

      // Diğer sayfalar yapıldıkça buraya eklenecek
      default:
        aktifSayfa = const DashboardScreen();
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: AppShell(child: aktifSayfa),
    );
  }
}
