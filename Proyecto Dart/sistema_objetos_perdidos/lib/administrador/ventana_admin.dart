import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sistema_objetos_perdidos/login/pantalla_login.dart';
import 'package:sistema_objetos_perdidos/objetos_perdidos/reporte_modelo.dart';
import 'dart:convert';
import 'dart:typed_data';

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

  Uint8List? _imageFromBase64(String? b64) {
    if (b64 == null) return null;
    try {
      return base64Decode(b64);
    } catch (e) {
      debugPrint('Error al decodificar imagen base64: $e');
      return null;
    }
  }

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
    final Uint8List? imageBytes = _imageFromBase64(report.imagenBase64);
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
        leading: imageBytes != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  imageBytes,
                  width: 56,
                  height: 56,
                  fit: BoxFit.cover,
                ),
              )
            : CircleAvatar(
                backgroundColor: color.withOpacity(0.15),
                child: Icon(Icons.image_outlined, color: color),
              ),
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
        trailing: Row(
          mainAxisSize: MainAxisSize.min, 
          children: [
            //Boton de Información
            IconButton(
              icon: const Icon(Icons.visibility, color: Colors.grey),
              tooltip: "Ver detalles completos",
              onPressed: () => _mostrarDetalle(report),
            ),
            if (isSelected) 
              Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }

  void _mostrarDetalle(ReporteModelo reporte) {
    final Uint8List? imageBytes = _imageFromBase64(reporte.imagenBase64);

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(reporte.titulo),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (imageBytes != null)
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 15),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.memory(
                          imageBytes,
                          fit: BoxFit.contain, //muestra la foto entera
                          height: 250, 
                        ),
                      ),
                    ),
                  )
                else
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(20.0),
                      child: Icon(Icons.image_not_supported, size: 60, color: Colors.grey),
                    ),
                  ),

                const Divider(),
                _detalleTexto("Categoría:", reporte.categoria),
                _detalleTexto("Lugar:", reporte.lugar),
                _detalleTexto("Fecha/Hora:", reporte.fecha),
                const SizedBox(height: 10),
                const Text("Descripción:", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(reporte.descripcion, style: const TextStyle(fontStyle: FontStyle.italic)),
                const SizedBox(height: 10),
                const Divider(),
                //El Correo del Autor
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.indigo),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Reportado por:\n${reporte.autor ?? 'Anónimo'}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text("Cerrar"),
            )
          ],
        );
      },
    );
  }

  Widget _detalleTexto(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black87),
          children: [
            TextSpan(text: "$label ", style: const TextStyle(fontWeight: FontWeight.bold)),
            TextSpan(text: value),
          ],
        ),
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
        automaticallyImplyLeading: false,
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