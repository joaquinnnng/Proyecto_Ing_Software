import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HistorialReportes extends StatefulWidget {
  const HistorialReportes({super.key});

  @override
  State<HistorialReportes> createState() => _HistorialReportesState();
}

// Se elimina 'with SingleTickerProviderStateMixin' ya que no se usa el AnimationController
class _HistorialReportesState extends State<HistorialReportes> {
  // Estado para guardar los datos cargados y el estado de carga
  List<String> _reportData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Llama a la función asíncrona para cargar los datos
    _loadReportData();
  }

  // Función asíncrona para cargar los datos de SharedPreferences
  Future<void> _loadReportData() async {
    try {
      final SharedPreferences database = await SharedPreferences.getInstance();

      // Intentamos obtener la lista de strings bajo la clave 'reportes_guardados'
      // Si es null, usamos una lista vacía
      final List<String>? data = database.getStringList('reportes_guardados');

      // Solo actualiza el estado si el widget sigue montado
      if (mounted) {
        setState(() {
          _reportData = data ?? [];
          _isLoading = false;
        });
      }
    } catch (e) {
      // Manejo de errores simple en caso de fallo al acceder a SharedPreferences
      debugPrint('Error al cargar SharedPreferences: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. Mostrar un indicador de carga mientras se obtienen los datos
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Reportes'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: _reportData.isEmpty
                ? const Center(
                    child: Text(
                      'No hay reportes guardados.',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                // 2. GridView.builder con los datos cargados
                : GridView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount:
                        _reportData.length, // Usar la longitud de los datos
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          crossAxisSpacing: 8.0,
                          mainAxisSpacing: 8.0,
                          childAspectRatio: 5,
                        ),
                    itemBuilder: (context, index) {
                      final String reportSummary = _reportData[index];

                      return Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: InkWell(
                          onTap: () {
                            // Acción al tocar la tarjeta (e.g., ver detalles)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Reporte #$index Seleccionado'),
                              ),
                            );
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.assignment_turned_in,
                                  color: Colors.red,
                                  size: 30,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Reporte ${index + 1}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.black87,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      // Muestra el dato del reporte (resumen)
                                      Text(
                                        reportSummary,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 16,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
