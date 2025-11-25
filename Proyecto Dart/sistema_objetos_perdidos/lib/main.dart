import 'package:flutter/material.dart';
import 'package:sistema_objetos_perdidos/login/pantalla_login.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Prototype',
      home: Scaffold(
        body: PantallaLogin(),
      ),
    );
  }
}
