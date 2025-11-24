import 'package:flutter/material.dart';
import 'package:sistema_objetos_perdidos/objetos_perdidos/formulario_perdido.dart';
import 'package:sistema_objetos_perdidos/objetos_perdidos/formulario_encontrado.dart';
import 'package:sistema_objetos_perdidos/objetos_perdidos/historial_reportes.dart';

class MainButtons extends StatelessWidget {
  const MainButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegistroPage()),
              ); // redirecciona
            },
            child: const Text('Registrar Objeto Perdido'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EncontradoPage()),
              );
            },
            child: const Text('Registrar Objeto Encontrado'),
          ),
          const SizedBox(height: 16),

          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HistorialReportes(),
                ),
              );
            },
            child: const Text('Mis Reportes'),
          ),
        ],
      ),
    );
  }
}
