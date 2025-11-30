import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'reporte_modelo.dart'; 
import 'dart:typed_data';
class HistorialReportes extends StatefulWidget {
  const HistorialReportes({super.key});

  @override
  State<HistorialReportes> createState() => _HistorialReportesState();
}

class _HistorialReportesState extends State<HistorialReportes> {
  List<ReporteModelo> _misReportes = [];
  bool _isLoading = true;

Uint8List? _imageFromBase64(String? b64) {
    if (b64 == null) return null;
    try {
      return base64Decode(b64);
    } catch (e) {
      debugPrint('Error decodificando imagen: $e');
      return null;
    }
  }


  @override
  void initState() {
    super.initState();
    _loadReportData();
  }

  Future<void> _loadReportData() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> rawData = prefs.getStringList('reportes_data_v2') ?? [];

    List<ReporteModelo> temp = [];

    for (String item in rawData) {
      try {
        final reporte = ReporteModelo.fromJson(jsonDecode(item));
        // IMPORTANTE: Solo mostramos lo que el usuario reportó como PERDIDO
        // (Asumimos que "Mis Reportes" son las cosas que yo perdí)
        if (reporte.tipo == 'PERDIDO') {
          temp.add(reporte);
        }
      } catch (e) {
        debugPrint("Error al leer reporte: $e");
      }
    }

    if (mounted) {
      setState(() {
        _misReportes = temp;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(title: const Text('Mis Reportes'), backgroundColor: Colors.blue),
      body: _misReportes.isEmpty
          ? const Center(child: Text('No tienes reportes activos'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _misReportes.length,
              itemBuilder: (context, index) {
                final item = _misReportes[index];
                
                // Determinamos si fue encontrado
                final bool recuperado = item.estado == 'RECUPERADO';

                // decodificamos la imagen (si existe)
               final Uint8List? imageBytes = _imageFromBase64(item.imagenBase64);

                return Card(
                  // CAMBIO VISUAL: Verde si está recuperado, Blanco si no
                  color: recuperado ? Colors.green.shade50 : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: recuperado ? Colors.green : Colors.grey.shade300,
                      width: recuperado ? 2 : 1
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              recuperado ? Icons.check_circle : Icons.warning_amber_rounded,
                              color: recuperado ? Colors.green : Colors.amber,
                              size: 30,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                item.titulo,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                            ),
                            if (imageBytes != null)
                              ClipOval(
                               child: Image.memory(
                                  imageBytes,
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.cover,
                                ),
                              )
                            else
                              Icon(
                                recuperado ? Icons.check_circle : Icons.warning_amber_rounded,
                                color: recuperado ? Colors.green : Colors.amber,
                                size: 30,
                              ),
                            const SizedBox(width: 10),
                            // Etiqueta de estado
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: recuperado ? Colors.green : Colors.amber,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                recuperado ? "¡ENCONTRADO!" : "BUSCANDO...",
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            )
                          ],
                        ),
                        const Divider(),
                        Text("Fecha: ${item.fecha}", style: TextStyle(color: Colors.grey[600])),
                        const SizedBox(height: 8),
                        Text(item.descripcion),
                        
                        // === SECCIÓN DEL MENSAJE DEL ADMIN ===
                        if (recuperado && item.mensajeAdmin != null) ...[
                          const SizedBox(height: 15),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "INSTRUCCIONES:",
                                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.mensajeAdmin!, 
                                  style: TextStyle(color: Colors.green.shade900),
                                ),
                              ],
                            ),
                          )
                        ]
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}