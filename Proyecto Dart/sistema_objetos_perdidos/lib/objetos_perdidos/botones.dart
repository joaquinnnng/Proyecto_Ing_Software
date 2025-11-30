import 'package:flutter/material.dart';
import 'package:sistema_objetos_perdidos/login/pantalla_login.dart';
import 'package:sistema_objetos_perdidos/objetos_perdidos/formulario_perdido.dart';
import 'package:sistema_objetos_perdidos/objetos_perdidos/formulario_encontrado.dart';
import 'package:sistema_objetos_perdidos/objetos_perdidos/historial_reportes.dart';
import 'dart:math';

class MainButtons extends StatelessWidget {
  
  final String usuarioLogueado; 
  const MainButtons({super.key, required this.usuarioLogueado});

  @override
  Widget build(BuildContext context) {

      return LayoutBuilder(
    builder: (context, constraints) {
      final w = constraints.maxWidth;
      final h = constraints.maxHeight;

      //Escalado para mantener proporciones 1335x1000
      final double escaladoW = w / 1600;
      final double escaladoH = h / 900;
      final double escaladoUsado = min(escaladoW, escaladoH);

      final double wReal = 1600 * escaladoUsado;
      final double hReal = 900 * escaladoUsado;

      final double offsetX = (w - wReal) / 2.0;
      final double offsetY = (h - hReal) / 2.0;

      Rect escaladoRectPx({
        required double left,
        required double top,
        required double width,
        required double height,
      }) {
        return Rect.fromLTWH(
          offsetX + left * escaladoUsado,
          offsetY + top * escaladoUsado,
          width * escaladoUsado,
          height * escaladoUsado,
        );
      }

      final Rect perdidosPx = escaladoRectPx(left: 310, top: 240, width: 980, height: 126);
      final Rect encontradosPx = escaladoRectPx(left: 310, top: 412, width: 980, height: 126);
      final Rect reportesPx = escaladoRectPx(left: 310, top: 582, width: 980, height: 126);
      final Rect salirPx = escaladoRectPx(left: 310, top: 745, width: 980, height: 126);

    return Scaffold(
      body: Stack(
        children: [

          Positioned.fill(
            child: Container(
              color: Colors.black,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Image.asset(
                  'images/fondo2.png',
                  filterQuality: FilterQuality.none,
                  isAntiAlias: false,
                ),
              ),
            ),
          ),

          Positioned(
            top: 40, 
            left: 20,
            child: Text(
              "Hola: $usuarioLogueado", 
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
    
          //boton para reportar objeto perdido
          Positioned.fromRect(
            rect: perdidosPx,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RegistroPage(usuarioEmail: usuarioLogueado)
                  ),
                );
              },
              splashColor: Colors.white24,
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox.expand(),
            ),
          ),

          //boton para reportar objeto encontrado
          Positioned.fromRect(
            rect: encontradosPx,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EncontradoPage(usuarioEmail: usuarioLogueado)
                  ),
                );
              },
              splashColor: Colors.white24,
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox.expand(),
            ),
          ),
          
          //boton para ver los reportes
          Positioned.fromRect(
            rect: reportesPx,
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HistorialReportes()),
                );
              },
              splashColor: Colors.white24,
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox.expand(),
            ),
          ),

          //boton para cerrar sesion
          Positioned.fromRect(
            rect: salirPx,
            child: InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil( // Usamos pushAndRemoveUntil mejor
                  context,
                  MaterialPageRoute(builder: (context) => const PantallaLogin()),
                  (Route<dynamic> route) => false,
                );
              },
              splashColor: Colors.white24,
              borderRadius: BorderRadius.circular(8),
              child: const SizedBox.expand(),
                  ),
                ),
              ],
            ),
          );
       },
     );
  }  
}


