import 'package:flutter/material.dart';

class ventanaAdmin extends StatefulWidget {
  const ventanaAdmin({super.key});

  @override
  State<ventanaAdmin> createState() => _ventanaAdminState();
}

class _ventanaAdminState extends State<ventanaAdmin>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
