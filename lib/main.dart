import 'package:flutter/material.dart';

void main() => runApp(MyApp());

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
      appBar: AppBar(title: Text('Material App Bar')),
      body: Center(child: Container(child: Text('Hello World'))),
    );
  }
}
