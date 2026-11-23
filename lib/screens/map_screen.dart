
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detail_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  static const bosque = Color(0xFF183D2C);
  static const verde = Color(0xFF416B4C);

  late Future<List<Map<String, dynamic>>> futuroReportes;

  @override
  void initState() {
    super.initState();
    futuroReportes = cargarReportes();
  }

  Future<List<Map<String, dynamic>>> cargarReportes() async {
    final datos = await Supabase.instance.client
        .from('reportes')
        .select(
          'id, titulo, descripcion, categoria, estado, created_at, foto_url, latitud, longitud',
        );

    return List<Map<String, dynamic>>.from(datos);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      appBar: AppBar(
        backgroundColor: bosque,
        foregroundColor: Colors.white,
        title: const Text(
          'Mapa de reportes',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: futuroReportes,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: verde),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text('No se pudo cargar el mapa.'),
            );
          }

          final reportes = snapshot.data ?? [];

          final marcadores = reportes.where((reporte) {
            return reporte['latitud'] != null &&
                reporte['longitud'] != null;
          }).map((reporte) {
            final latitud =
                (reporte['latitud'] as num).toDouble();
            final longitud =
                (reporte['longitud'] as num).toDouble();

            return Marker(
              point: LatLng(latitud, longitud),
              width: 55,
              height: 60,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DetailScreen(reporte: reporte),
                    ),
                  );
                },
                child: const Icon(
                  Icons.location_on,
                  color: Color(0xFF416B4C),
                  size: 48,
                ),
              ),
            );
          }).toList();

          return Stack(
            children: [
              FlutterMap(
                options: const MapOptions(
                  initialCenter: LatLng(-18.963765, -57.8042257),
                  initialZoom: 14,
                  minZoom: 5,
                  maxZoom: 18,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.civicapp.reportes_ciudadanos',
                  ),
                  MarkerLayer(markers: marcadores),
                ],
              ),

              Positioned(
                top: 15,
                left: 15,
                right: 15,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.10),
                        blurRadius: 10,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: verde,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${marcadores.length} reportes ubicados en el mapa',
                          style: const TextStyle(
                            color: bosque,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Positioned(
                bottom: 8,
                right: 8,
                child: Text(
                  '© OpenStreetMap contributors',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.black87,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
