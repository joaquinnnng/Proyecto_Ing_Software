import 'package:flutter/material.dart';
import 'package:sistema_objetos_perdidos/login/pantalla_login.dart';
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

          const SizedBox(height: 40),

          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
             backgroundColor: Colors.red.shade100, // Un rojo suave
             foregroundColor: Colors.red.shade900, // Texto rojo oscuro
           ),
           icon: const Icon(Icons.logout),
           label: const Text('Cerrar Sesión'),
          onPressed: () {
    
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const PantallaLogin()),
            (Route<dynamic> route) => false,
    );
  },
),
        ],
      ),
    );
  }
}
