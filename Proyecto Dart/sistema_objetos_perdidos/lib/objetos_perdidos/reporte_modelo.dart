// reporte_modelo.dart
class ReporteModelo {
  String id;
  String tipo; // "PERDIDO" o "ENCONTRADO"
  String titulo;
  String descripcion;
  String categoria;
  String fecha;
  String lugar;
  String estado; // "PENDIENTE" o "RECUPERADO"
  String? mensajeAdmin; 

  ReporteModelo({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.descripcion,
    required this.categoria,
    required this.fecha,
    required this.lugar,
    this.estado = 'PENDIENTE',
    this.mensajeAdmin,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'tipo': tipo,
        'titulo': titulo,
        'descripcion': descripcion,
        'categoria': categoria,
        'fecha': fecha,
        'lugar': lugar,
        'estado': estado,
        'mensajeAdmin': mensajeAdmin,
      };

  factory ReporteModelo.fromJson(Map<String, dynamic> json) {
    return ReporteModelo(
      id: json['id'],
      tipo: json['tipo'],
      titulo: json['titulo'],
      descripcion: json['descripcion'],
      categoria: json['categoria'],
      fecha: json['fecha'],
      lugar: json['lugar'],
      estado: json['estado'] ?? 'PENDIENTE',
      mensajeAdmin: json['mensajeAdmin'],
    );
  }
}