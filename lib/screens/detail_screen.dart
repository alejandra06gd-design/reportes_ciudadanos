
import 'package:flutter/material.dart';


class DetailScreen extends StatelessWidget {
  final Map<String, dynamic> reporte;

  const DetailScreen({
    super.key,
    required this.reporte,
  });

  static const bosque = Color(0xFF183D2C);
  static const verde = Color(0xFF416B4C);
  static const salvia = Color(0xFFDCE8D5);
  static const cafe = Color(0xFF987451);

  @override
  Widget build(BuildContext context) {
    final categoria = reporte['categoria']?.toString() ?? 'Otro';
    final estado = reporte['estado']?.toString() ?? 'pendiente';
    final fotoUrl = reporte['foto_url']?.toString() ?? '';
    final fecha = reporte['created_at'] != null
        ? DateTime.parse(reporte['created_at']).toLocal()
        : null;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      appBar: AppBar(
        backgroundColor: bosque,
        foregroundColor: Colors.white,
        title: const Text(
          'Detalle del reporte',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: fotoUrl.isNotEmpty
                  ? Image.network(
                      fotoUrl,
                      width: double.infinity,
                      height: 230,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imagenVacia();
                      },
                    )
                  : _imagenVacia(),
            ),

            const SizedBox(height: 22),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: salvia,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                categoria,
                style: const TextStyle(
                  color: bosque,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 15),

            Text(
              reporte['titulo']?.toString() ?? 'Sin título',
              style: const TextStyle(
                color: bosque,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'Descripción del problema',
              style: TextStyle(
                color: bosque,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 7),

            Text(
              reporte['descripcion']?.toString() ?? '',
              style: const TextStyle(
                color: Colors.blueGrey,
                fontSize: 15,
                height: 1.5,
              ),
            ),

            const SizedBox(height: 25),

            _dato(
              Icons.flag_outlined,
              'Estado del reporte',
              _nombreEstado(estado),
            ),

            const SizedBox(height: 15),

            _dato(
              Icons.location_on_outlined,
              'Ubicación GPS',
              '${reporte['latitud']}, ${reporte['longitud']}',
            ),

            const SizedBox(height: 15),

            _dato(
              Icons.calendar_today_outlined,
              'Fecha de publicación',
              fecha != null
                  ? '${fecha.day}/${fecha.month}/${fecha.year} - ${fecha.hour}:${fecha.minute.toString().padLeft(2, '0')}'
                  : 'No disponible',
            ),

            const SizedBox(height: 30),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: salvia,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Text(
                'Gracias por contribuir a mejorar Puerto Suárez. '
                'Tu participación hace la diferencia.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: bosque,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _imagenVacia() {
    return Container(
      width: double.infinity,
      height: 230,
      color: salvia,
      child: const Icon(
        Icons.image_not_supported_outlined,
        color: verde,
        size: 55,
      ),
    );
  }

  Widget _dato(IconData icono, String titulo, String valor) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE8EDE5)),
      ),
      child: Row(
        children: [
          Icon(icono, color: cafe, size: 25),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  valor,
                  style: const TextStyle(
                    color: bosque,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _nombreEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'en revisión':
        return 'En revisión';
      case 'atendido':
        return 'Atendido';
      default:
        return estado;
    }
  }
}
