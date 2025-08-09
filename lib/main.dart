import 'package:flutter/material.dart';
import 'screens/editor_home.dart';

void main() {
  runApp(const MonporaApp());
}

class MonporaApp extends StatelessWidget {
  const MonporaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Monpora Editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const EditorHome(),
    );
  }
}
