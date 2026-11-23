
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const bosque = Color(0xFF183D2C);
  static const verde = Color(0xFF416B4C);
  static const salvia = Color(0xFFDCE8D5);
  static const fondo = Color(0xFFF7F8F4);

  final supabase = Supabase.instance.client;

  List<Map<String, dynamic>> notificaciones = [];
  bool cargando = true;
  String? error;

  @override
  void initState() {
    super.initState();
    cargarNotificaciones();
  }

  Future<void> cargarNotificaciones() async {
    try {
      final usuario = supabase.auth.currentUser;

      if (usuario == null) return;

      final respuesta = await supabase
          .from('notificaciones')
          .select()
          .eq('user_id', usuario.id)
          .order('created_at', ascending: false);

      if (!mounted) return;

      setState(() {
        notificaciones = List<Map<String, dynamic>>.from(respuesta);
        cargando = false;
        error = null;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        cargando = false;
        error = 'No se pudieron cargar las notificaciones.';
      });
    }
  }

  Future<void> abrirNotificacion(Map<String, dynamic> notificacion) async {
    try {
      await supabase
          .from('notificaciones')
          .update({'leida': true})
          .eq('id', notificacion['id']);

      final reporte = await supabase
          .from('reportes')
          .select()
          .eq('id', notificacion['reporte_id'])
          .maybeSingle();

      if (!mounted) return;

      if (reporte == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este reporte ya no está disponible.')),
        );
        await cargarNotificaciones();
        return;
      }

      await cargarNotificaciones();

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DetailScreen(reporte: reporte),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir la notificación.'),
        ),
      );
    }
  }

  String fechaBonita(dynamic valor) {
    final fecha = DateTime.tryParse(valor.toString())?.toLocal();

    if (fecha == null) return '';

    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');

    return '$dia/$mes/${fecha.year} • $hora:$minuto';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: fondo,
        foregroundColor: bosque,
        elevation: 0,
        centerTitle: false,
        title: const Text(
          'Notificaciones',
          style: TextStyle(
            color: bosque,
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
      ),
      body: cargando
          ? const Center(
              child: CircularProgressIndicator(color: verde),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(error!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => cargando = true);
                          cargarNotificaciones();
                        },
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  color: verde,
                  onRefresh: cargarNotificaciones,
                  child: notificaciones.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            const SizedBox(height: 120),
                            Icon(
                              Icons.notifications_none_rounded,
                              size: 75,
                              color: verde.withValues(alpha: 0.45),
                            ),
                            const SizedBox(height: 18),
                            const Center(
                              child: Text(
                                '¡Todo al día!',
                                style: TextStyle(
                                  color: bosque,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Center(
                              child: Text(
                                'Aquí aparecerán las actualizaciones\nde tus reportes.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(18),
                          itemCount: notificaciones.length,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final n = notificaciones[index];
                            final leida = n['leida'] == true;
                            final atendido = n['estado'] == 'atendido';

                            return Material(
                              color: leida ? Colors.white : salvia,
                              borderRadius: BorderRadius.circular(18),
                              child: InkWell(
                                borderRadius: BorderRadius.circular(18),
                                onTap: () => abrirNotificacion(n),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: atendido
                                              ? verde.withValues(alpha: 0.13)
                                              : const Color(0xFFECE5D8),
                                          borderRadius:
                                              BorderRadius.circular(15),
                                        ),
                                        child: Icon(
                                          atendido
                                              ? Icons.check_circle_outline
                                              : Icons.visibility_outlined,
                                          color: atendido ? verde : const Color(0xFF987451),
                                          size: 25,
                                        ),
                                      ),
                                      const SizedBox(width: 13),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              n['titulo'] ?? 'Actualización',
                                              style: const TextStyle(
                                                color: bosque,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              n['mensaje'] ?? '',
                                              style: const TextStyle(
                                                color: Colors.black87,
                                                fontSize: 13,
                                                height: 1.4,
                                              ),
                                            ),
                                            const SizedBox(height: 9),
                                            Text(
                                              fechaBonita(n['created_at']),
                                              style: const TextStyle(
                                                color: Colors.black54,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!leida)
                                        Container(
                                          width: 9,
                                          height: 9,
                                          margin: const EdgeInsets.only(top: 5),
                                          decoration: const BoxDecoration(
                                            color: verde,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                ),
    );
  }
}
