import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detail_screen.dart';

class MyReportsScreen extends StatefulWidget {
  final bool mostrarTodos;

  const MyReportsScreen({
    super.key,
    this.mostrarTodos = false,
  });

  @override
  State<MyReportsScreen> createState() => _MyReportsScreenState();
}

class _MyReportsScreenState extends State<MyReportsScreen> {
  static const bosque = Color(0xFF183D2C);
  static const verde = Color(0xFF416B4C);
  static const salvia = Color(0xFFDCE8D5);
  static const cafe = Color(0xFF987451);

  late Future<List<Map<String, dynamic>>> futuroReportes;

  @override
  void initState() {
    super.initState();
    cargarReportes();
  }

  void cargarReportes() {
    final supabase = Supabase.instance.client;
    final usuario = supabase.auth.currentUser;

    if (!widget.mostrarTodos && usuario == null) {
      futuroReportes = Future.value([]);
      return;
    }

    var consulta = supabase
        .from('reportes')
        .select(
          'id, user_id, titulo, descripcion, categoria, estado, created_at, foto_url, latitud, longitud',
        );

    if (!widget.mostrarTodos) {
      consulta = consulta.eq('user_id', usuario!.id);
    }

    futuroReportes = consulta
        .order('created_at', ascending: false)
        .then((datos) => List<Map<String, dynamic>>.from(datos));
  }

  Future<void> actualizarReportes() async {
    setState(() {
      cargarReportes();
    });

    await futuroReportes;
  }

  IconData iconoCategoria(String categoria) {
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

  Color colorCategoria(String categoria) {
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

  String nombreEstado(String estado) {
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

  Color colorEstado(String estado) {
    switch (estado) {
      case 'atendido':
        return verde;
      case 'en revisión':
        return cafe;
      default:
        return Colors.orange.shade800;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tituloPantalla =
        widget.mostrarTodos ? 'Reportes de la comunidad' : 'Mis reportes';

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      appBar: AppBar(
        backgroundColor: bosque,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(
          tituloPantalla,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: RefreshIndicator(
        color: verde,
        onRefresh: actualizarReportes,
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: futuroReportes,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: verde),
              );
            }

            if (snapshot.hasError) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 150),
                  Icon(Icons.error_outline, size: 45, color: Colors.redAccent),
                  SizedBox(height: 12),
                  Center(
                    child: Text('No se pudieron cargar los reportes.'),
                  ),
                ],
              );
            }

            final reportes = snapshot.data ?? [];

            if (reportes.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const SizedBox(height: 120),
                  const Icon(
                    Icons.assignment_outlined,
                    size: 75,
                    color: verde,
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: Text(
                      widget.mostrarTodos
                          ? 'Todavía no hay reportes registrados'
                          : 'Todavía no tienes reportes',
                      style: const TextStyle(
                        color: bosque,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      widget.mostrarTodos
                          ? 'Cuando la comunidad registre problemas, aparecerán aquí.'
                          : 'Cuando registres un problema, aparecerá aquí.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.blueGrey),
                    ),
                  ),
                ],
              );
            }

            return ListView(
              padding: const EdgeInsets.all(20),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Text(
                  widget.mostrarTodos
                      ? 'Contribuciones de nuestra comunidad'
                      : 'Tus contribuciones a Puerto Suárez',
                  style: TextStyle(
                    color: Colors.brown.shade400,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${reportes.length} ${reportes.length == 1 ? 'reporte registrado' : 'reportes registrados'}',
                  style: const TextStyle(
                    color: bosque,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),

                ...reportes.map((reporte) {
                  final categoria =
                      reporte['categoria']?.toString() ?? 'Otro';
                  final estado =
                      reporte['estado']?.toString() ?? 'pendiente';
                  final fotoUrl = reporte['foto_url']?.toString() ?? '';

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(18),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DetailScreen(reporte: reporte),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(
                            color: const Color(0xFFE8EDE5),
                          ),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(13),
                              child: fotoUrl.isNotEmpty
                                  ? Image.network(
                                      fotoUrl,
                                      width: 75,
                                      height: 75,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          _imagenVacia(),
                                    )
                                  : _imagenVacia(),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    categoria,
                                    style: TextStyle(
                                      color: colorCategoria(categoria),
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    reporte['titulo']?.toString() ??
                                        'Sin título',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: bosque,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 7),
                                  Text(
                                    nombreEstado(estado),
                                    style: TextStyle(
                                      color: colorEstado(estado),
                                      fontSize: 11,
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
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _imagenVacia() {
    return Container(
      width: 75,
      height: 75,
      color: salvia,
      child: const Icon(
        Icons.image_outlined,
        color: verde,
        size: 30,
      ),
    );
  }
}
