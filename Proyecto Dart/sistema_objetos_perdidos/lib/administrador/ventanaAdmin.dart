import 'package:flutter/material.dart';

class Reporte {
  final String id;
  final String titulo;
  final String descripcion;
  final String categoria;

  Reporte(this.id, this.titulo, this.descripcion, this.categoria);
}

class ReportePerdido extends Reporte {
  ReportePerdido(super.id, super.titulo, super.descripcion, super.categoria);
}

class ReporteEncontrado extends Reporte {
  ReporteEncontrado(super.id, super.titulo, super.descripcion, super.categoria);
}

class ventanaAdmin extends StatefulWidget {
  const ventanaAdmin({super.key});

  @override
  State<ventanaAdmin> createState() => _ventanaAdminState();
}

class _ventanaAdminState extends State<ventanaAdmin> {
  // Datos de ejemplo para simular reportes
  final List<ReportePerdido> _reportesPerdidos = [
    ReportePerdido(
      'P001',
      'Billetera Roja',
      'Perdida en el casino central.',
      'Billetera',
    ),
    ReportePerdido(
      'P002',
      'Llaves de Auto',
      'Perdidas cerca de la biblioteca.',
      'Llaves',
    ),
    ReportePerdido(
      'P003',
      'Documento UDEC',
      'Cédula de identidad y pase UDEC.',
      'Documentos',
    ),
    ReportePerdido(
      'P004',
      'Mochila Azul',
      'Perdida en la Facultad de Ingeniería.',
      'Mochila/Bolso',
    ),
    ReportePerdido(
      'P005',
      'Celular Samsung',
      'Perdido en el bus de acercamiento.',
      'Celular',
    ),
    ReportePerdido('P006', 'Pendiente de Oro', 'Perdido en un baño.', 'Joyas'),
    ReportePerdido(
      'P007',
      'Bufanda Negra',
      'Perdida en el auditorio.',
      'Prenda de Vestir',
    ),
  ];

  final List<ReporteEncontrado> _reportesEncontrados = [
    ReporteEncontrado(
      'E001',
      'Celular iPhone 11',
      'Encontrado cerca de la facultad.',
      'Celular',
    ),
    ReporteEncontrado(
      'E002',
      'Mochila Negra',
      'Encontrada en sala de clases, sin nombre.',
      'Mochila/Bolso',
    ),
    ReporteEncontrado(
      'E003',
      'Estuche con llaves',
      'Un manojo de 4 llaves.',
      'Llaves',
    ),
    ReporteEncontrado(
      'E004',
      'Billetera Cuero',
      'Contiene tarjetas, pero no documentos.',
      'Billetera',
    ),
    ReporteEncontrado(
      'E005',
      'Carnet de Estudiante',
      'Encontrado en pasillo central.',
      'Documentos',
    ),
    ReporteEncontrado(
      'E006',
      'Anillo Plateado',
      'Encontrado en un mesón.',
      'Joyas',
    ),
    ReporteEncontrado(
      'E007',
      'Chaqueta Deportiva',
      'Encontrada en la cafetería.',
      'Prenda de Vestir',
    ),
  ];

  // Variables de estado para la selección
  ReportePerdido? _selectedPerdido;
  ReporteEncontrado? _selectedEncontrado;

  // Función para seleccionar un Reporte Perdido (Aviso)
  void _selectPerdido(ReportePerdido report) {
    setState(() {
      // Si se selecciona el mismo, lo deselecciona (toggle)
      _selectedPerdido = (report == _selectedPerdido) ? null : report;
    });
  }

  // Función para seleccionar un Reporte Encontrado (Reporte)
  void _selectEncontrado(ReporteEncontrado report) {
    setState(() {
      // Si se selecciona el mismo, lo deselecciona (toggle)
      _selectedEncontrado = (report == _selectedEncontrado) ? null : report;
    });
  }

  // Función para hacer el "Match"
  void _matchReports() {
    if (_selectedPerdido != null && _selectedEncontrado != null) {
      final String msg =
          '✅ MATCH exitoso: Objeto Perdido [${_selectedPerdido!.titulo}] se ha enlazado con Objeto Encontrado [${_selectedEncontrado!.titulo}].';

      // Aquí llamada a la base de datos para marcar
      // ambos reportes como "resueltos" y/o crear el registro de "objeto encontrado".

      setState(() {
        _reportesPerdidos.removeWhere((r) => r.id == _selectedPerdido!.id);
        _reportesEncontrados.removeWhere(
          (r) => r.id == _selectedEncontrado!.id,
        );

        _selectedPerdido = null;
        _selectedEncontrado = null;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }

  Widget _buildReportItem<T extends Reporte>({
    required T report,
    required bool isSelected,
    required ValueChanged<T> onTap,
    required Color color,
  }) {
    return Card(
      elevation: isSelected ? 8 : 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: isSelected ? color : Colors.grey.shade300,
          width: isSelected ? 3.0 : 1.0,
        ),
      ),
      child: ListTile(
        onTap: () => onTap(report),
        title: Text(
          report.titulo,
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
        subtitle: Text(
          'Categoría: ${report.categoria}\nDescripción: ${report.descripcion}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 13),
        ),
        trailing: isSelected ? Icon(Icons.check_circle, color: color) : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    bool canMatch = _selectedPerdido != null && _selectedEncontrado != null;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Administración de Objetos Perdidos/Encontrados'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              onPressed: canMatch ? _matchReports : null,
              icon: const Icon(Icons.link_outlined),
              label: const Text('Hacer Match y Resolver'),
              style: ElevatedButton.styleFrom(
                backgroundColor: canMatch ? Colors.green : Colors.grey,
                foregroundColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    'Objetos Perdidos (Avisos)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _reportesPerdidos.length,
                    itemBuilder: (context, index) {
                      final report = _reportesPerdidos[index];
                      return _buildReportItem<ReportePerdido>(
                        report: report,
                        isSelected: report == _selectedPerdido,
                        onTap: _selectPerdido,
                        color: Colors.red.shade700,
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const VerticalDivider(
            width: 1,
            thickness: 1,
            indent: 20,
            endIndent: 20,
          ),

          Expanded(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: const Text(
                    'Objetos Encontrados (Reportes)',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _reportesEncontrados.length,
                    itemBuilder: (context, index) {
                      final report = _reportesEncontrados[index];
                      return _buildReportItem<ReporteEncontrado>(
                        report: report,
                        isSelected: report == _selectedEncontrado,
                        onTap: _selectEncontrado,
                        color: Colors.blue.shade700,
                      );
                    },
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
