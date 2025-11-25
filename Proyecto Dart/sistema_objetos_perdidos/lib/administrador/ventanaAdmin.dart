import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistema_objetos_perdidos/login/pantalla_login.dart';
import 'package:sistema_objetos_perdidos/objetos_perdidos/reporte_modelo.dart';
import 'dart:convert';
import 'package:sistema_objetos_perdidos/objetos_perdidos/reporte_modelo.dart';

class ventanaAdmin extends StatefulWidget {
  const ventanaAdmin({super.key});

  @override
  State<ventanaAdmin> createState() => _ventanaAdminState();
}

class _ventanaAdminState extends State<ventanaAdmin> {
  // Listas dinámicas
  List<ReporteModelo> _reportesPerdidos = [];
  List<ReporteModelo> _reportesEncontrados = [];

  ReporteModelo? _selectedPerdido;
  ReporteModelo? _selectedEncontrado;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatosDelSistema();
  }

  // --- LÓGICA DE CARGA DE DATOS ---
  Future<void> _cargarDatosDelSistema() async {
    final prefs = await SharedPreferences.getInstance();
    // Leemos la misma Key que usamos en el formulario
    final List<String> rawData = prefs.getStringList('reportes_data_v2') ?? [];
    
    List<ReporteModelo> perdidosTemp = [];
    List<ReporteModelo> encontradosTemp = [];

    for (String item in rawData) {
      try {
        final reporte = ReporteModelo.fromJson(jsonDecode(item));
        
        if (reporte.tipo == 'PERDIDO') {
          perdidosTemp.add(reporte);
        } else if (reporte.tipo == 'ENCONTRADO') {
          encontradosTemp.add(reporte);
        }
      } catch (e) {
        debugPrint("Error leyendo un reporte: $e");
      }
    }

    if (mounted) {
      setState(() {
        _reportesPerdidos = perdidosTemp;
        _reportesEncontrados = encontradosTemp;
        _isLoading = false;
      });
    }
  }

 // En ventanaAdmin.dart, reemplaza la función _matchReports por esta:

  Future<void> _matchReports() async {
    if (_selectedPerdido != null && _selectedEncontrado != null) {
      
      //Preparamos el mensaje automático
      String instruccion = "Encontrado en ${_selectedEncontrado!.lugar}. Puedes retirarlo en Sistemas";

     
      _selectedPerdido!.estado = "RECUPERADO";
      _selectedPerdido!.mensajeAdmin = instruccion;
      _selectedEncontrado!.estado = "PROCESADO"; 

      final prefs = await SharedPreferences.getInstance();
      List<String> nuevaListaGuardada = [];
      List<String> rawData = prefs.getStringList('reportes_data_v2') ?? [];
      
      for (String item in rawData) {
        try {
          var reporteTemp = ReporteModelo.fromJson(jsonDecode(item));
          
          if (reporteTemp.id == _selectedPerdido!.id) {
            // Guardamos la versión actualizada 
            nuevaListaGuardada.add(jsonEncode(_selectedPerdido!.toJson()));
          } else if (reporteTemp.id == _selectedEncontrado!.id) {
             // Guardamos la versión actualizada 
            nuevaListaGuardada.add(jsonEncode(_selectedEncontrado!.toJson()));
          } else {
            // Mantenemos los otros reportes intactos
            nuevaListaGuardada.add(item);
          }
        } catch (e) {
          // Ignorar errores
        }
      }

      await prefs.setStringList('reportes_data_v2', nuevaListaGuardada);

      // 4. Actualizamos la vista del Admin (quitamos los que ya no son pendientes)
      _cargarDatosDelSistema(); // Esta función ya filtra por 'PENDIENTE', así que desaparecerán de la vista

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('✅ Match exitoso. Se ha notificado al usuario.')),
      );

      setState(() {
        _selectedPerdido = null;
        _selectedEncontrado = null;
      });
    }
  }

  // Widget auxiliar para dibujar las tarjetas
  Widget _buildReportItem({
    required ReporteModelo report,
    required bool isSelected,
    required ValueChanged<ReporteModelo> onTap,
    required Color color,
  }) {
    return Card(
      elevation: isSelected ? 8 : 2,
      color: isSelected ? color.withOpacity(0.1) : null,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? color : Colors.grey.shade300,
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: ListTile(
        onTap: () => onTap(report),
        title: Text(
          report.titulo,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        subtitle: Text(
          '${report.fecha}\n${report.descripcion}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        isThreeLine: true,
        trailing: isSelected ? Icon(Icons.check_circle, color: color) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canMatch = _selectedPerdido != null && _selectedEncontrado != null;

    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin: Gestión de Match'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _cargarDatosDelSistema, // Botón para recargar si alguien subió algo nuevo
          ),
          IconButton(
      icon: const Icon(Icons.logout), // Icono de puerta/salida
      tooltip: 'Cerrar Sesión',
      onPressed: () {
        // Misma lógica: Ir al Login y borrar historial
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const PantallaLogin()),
          (Route<dynamic> route) => false,
        );
      },
    ),
        ],
      ),
      body: Column(
        children: [
          // Botón de acción principal
          Container(
            padding: const EdgeInsets.all(8),
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: canMatch ? _matchReports : null,
              icon: const Icon(Icons.link),
              label: const Text("VINCULAR Y RESOLVER CASOS"),
              style: ElevatedButton.styleFrom(
                backgroundColor: canMatch ? Colors.green : Colors.grey[300],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                // COLUMNA PERDIDOS
                Expanded(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("AVISOS (PERDIDOS)", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _reportesPerdidos.length,
                          itemBuilder: (ctx, i) => _buildReportItem(
                            report: _reportesPerdidos[i],
                            isSelected: _reportesPerdidos[i] == _selectedPerdido,
                            onTap: (val) => setState(() => _selectedPerdido = (_selectedPerdido == val) ? null : val),
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const VerticalDivider(width: 1),
                // COLUMNA ENCONTRADOS
                Expanded(
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text("REPORTES (ENCONTRADOS)", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(
                        child: ListView.builder(
                          itemCount: _reportesEncontrados.length,
                          itemBuilder: (ctx, i) => _buildReportItem(
                            report: _reportesEncontrados[i],
                            isSelected: _reportesEncontrados[i] == _selectedEncontrado,
                            onTap: (val) => setState(() => _selectedEncontrado = (_selectedEncontrado == val) ? null : val),
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}