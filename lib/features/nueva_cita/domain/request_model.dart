class RequestModel {
  final String id;
  final String userId;
  final String servicio;
  final String servicioIcon;
  final String nombreCliente;
  final String fecha;
  final String? hora;
  final String? descripcion;
  final String? telefono;
  final String estado;
  final DateTime createdAt;

  const RequestModel({
    required this.id,
    required this.userId,
    required this.servicio,
    required this.servicioIcon,
    required this.nombreCliente,
    required this.fecha,
    this.hora,
    this.descripcion,
    this.telefono,
    required this.estado,
    required this.createdAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) => RequestModel(
        id: json['id'] as String,
        userId: json['user_id'] as String,
        servicio: json['servicio'] as String,
        servicioIcon: json['servicio_icon'] as String,
        nombreCliente: json['nombre_cliente'] as String,
        fecha: json['fecha'] as String,
        hora: json['hora'] as String?,
        descripcion: json['descripcion'] as String?,
        telefono: json['telefono'] as String?,
        estado: json['estado'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'servicio': servicio,
        'servicio_icon': servicioIcon,
        'nombre_cliente': nombreCliente,
        'fecha': fecha,
        'hora': hora,
        'descripcion': descripcion,
        'telefono': telefono,
        'estado': estado,
      };
}
