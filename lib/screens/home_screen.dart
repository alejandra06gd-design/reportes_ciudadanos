import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_report_screen.dart';
import 'detail_screen.dart';
import 'my_reports_screen.dart';
import 'map_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static const bosque = Color(0xFF183D2C);
  static const verde = Color(0xFF416B4C);
  static const salvia = Color(0xFFDCE8D5);
  static const cafe = Color(0xFF987451);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 25),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: salvia,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Icon(
                      Icons.eco_rounded,
                      color: bosque,
                      size: 27,
                    ),
                  ),
                  const SizedBox(width: 11),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CIVIC APP',
                        style: TextStyle(
                          color: bosque,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.5,
                        ),
                      ),
                      Text(
                        'PUERTO SUÁREZ',
                        style: TextStyle(
                          color: cafe,
                          fontSize: 10,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.notifications_none_rounded,
                      color: bosque,
                      size: 27,
                    ),
                  ),
                  PopupMenuButton<String>(
                      tooltip: 'Opciones de cuenta',
                      onSelected: (valor) async {
                        if (valor == 'salir') {
                          try {
                            await Supabase.instance.client.auth.signOut();
                          } catch (error) {
                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('No se pudo cerrar la sesión.'),
                              ),
                            );
                          }
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem<String>(
                          value: 'salir',
                          child: Row(
                            children: [
                              Icon(Icons.logout_rounded, color: Colors.redAccent),
                              SizedBox(width: 10),
                              Text('Cerrar sesión'),
                            ],
                          ),
                        ),
  ],
  child: const CircleAvatar(
    backgroundColor: salvia,
    child: Icon(
      Icons.person_outline_rounded,
      color: bosque,
    ),
  ),
),
                ],
              ),

              const SizedBox(height: 30),

              const Text(
                '¡Hola, ciudadano!',
                style: TextStyle(
                  color: bosque,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Tu participación puede transformar nuestra ciudad.',
                style: TextStyle(
                  color: Color(0xFF758075),
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 25),

              // TARJETA PRINCIPAL
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [bosque, verde],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(23),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.campaign_rounded,
                      color: salvia,
                      size: 35,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      '¿Qué necesita mejorar en tu barrio?',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 9),
                    const Text(
                      'Reporta un problema y ayúdanos a hacerlo visible.',
                      style: TextStyle(
                        color: salvia,
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 47,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CreateReportScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('Crear un reporte'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: salvia,
                          foregroundColor: bosque,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(13),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 29),

              // CATEGORÍAS
              const Text(
                '¿Qué deseas reportar?',
                style: TextStyle(
                  color: bosque,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 15),

              Row(
                children: [
                  _categoria(Icons.construction_rounded, 'Baches', cafe),
                  _categoria(Icons.delete_outline_rounded, 'Basura', verde),
                  _categoria(Icons.lightbulb_outline_rounded, 'Alumbrado', cafe),
                  _categoria(Icons.more_horiz_rounded, 'Otros', verde),
                ],
              ),

              const SizedBox(height: 30),

              // REPORTES RECIENTES
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Reportes recientes',
                    style: TextStyle(
                      color: bosque,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'Ver todos',
                      style: TextStyle(color: verde),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 5),

              FutureBuilder<List<Map<String, dynamic>>>(
                future: Supabase.instance.client
                    .from('reportes')
                    .select(
                      'id, titulo, descripcion, categoria, estado, created_at, foto_url, latitud, longitud',
                    )
                    .order('created_at', ascending: false)
                    .limit(3)
                    .then(
                      (datos) => List<Map<String, dynamic>>.from(datos),
                    ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: verde),
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Text(
                      'No se pudieron cargar los reportes.',
                      style: TextStyle(color: Colors.redAccent),
                    );
                  }

                  final reportes = snapshot.data ?? [];

                  if (reportes.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: Center(
                        child: Text(
                          'Todavía no hay reportes registrados.',
                          style: TextStyle(color: Colors.blueGrey),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: reportes.map((reporte) {
                      final categoria =
                          reporte['categoria']?.toString() ?? 'Otro';

                      final estado =
                          reporte['estado']?.toString() ?? 'pendiente';

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(17),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailScreen(reporte: reporte),
                              ),
                            );
                          },
                          child: _reporte(
                            _iconoCategoria(categoria),
                            _colorCategoria(categoria),
                            reporte['titulo']?.toString() ?? 'Sin título',
                            reporte['descripcion']?.toString() ?? '',
                            _nombreEstado(estado),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: 20),

              Center(
                child: Text(
                  'Juntos construimos una mejor comunidad.',
                  style: TextStyle(
                    color: Colors.brown.shade400,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MyReportsScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const MapScreen(),
              ),
            );
          }
        },
        selectedItemColor: bosque,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.assignment_outlined),
            label: 'Reportes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Mapa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }


  IconData _iconoCategoria(String categoria) {
    switch (categoria) {
      case 'Bache':
        return Icons.construction_rounded;
      case 'Basura':
        return Icons.delete_outline_rounded;
      case 'Alumbrado público':
        return Icons.lightbulb_outline_rounded;
      default:
        return Icons.more_horiz_rounded;
    }
  }

  Color _colorCategoria(String categoria) {
    switch (categoria) {
      case 'Bache':
        return cafe;
      case 'Basura':
        return verde;
      case 'Alumbrado público':
        return cafe;
      default:
        return verde;
    }
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


  Widget _categoria(IconData icono, String nombre, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 55,
            height: 55,
            decoration: BoxDecoration(
              color: salvia,
              borderRadius: BorderRadius.circular(17),
            ),
            child: Icon(icono, color: color, size: 27),
          ),
          const SizedBox(height: 8),
          Text(
            nombre,
            style: const TextStyle(
              color: bosque,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _reporte(
    IconData icono,
    Color color,
    String titulo,
    String descripcion,
    String estado,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        border: Border.all(color: const Color(0xFFE8EDE5)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: salvia,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(icono, color: color, size: 25),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: bosque,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  descripcion,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 7),
                Text(
                  estado,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.black38,
            size: 15,
          ),
        ],
      ),
    );
  }
}
