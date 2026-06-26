import 'package:erp_frontend_project/data/services/firebase_service.dart';
import 'package:erp_frontend_project/presentation/providers/providers.dart';
import 'package:erp_frontend_project/presentation/screens/dashboard/dashboard_screen.dart';
import 'package:erp_frontend_project/presentation/widgets/common/app_shell.dart';
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

class BodyMyApp extends StatelessWidget {
  const BodyMyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: AppShell(child: DashboardScreen()),
    );
  }
}
