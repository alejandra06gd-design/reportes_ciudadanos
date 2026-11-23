
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'create_report_screen.dart';

class DetailScreen extends StatefulWidget {
  final Map<String, dynamic> reporte;

  const DetailScreen({
    super.key,
    required this.reporte,
  });

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  static const bosque = Color(0xFF183D2C);
  static const verde = Color(0xFF416B4C);
  static const salvia = Color(0xFFDCE8D5);
  static const cafe = Color(0xFF987451);

  static const correoAdmin = 'alejandra.06.gd@gmail.com';

  final supabase = Supabase.instance.client;

  late Map<String, dynamic> reporteActual;
  late String estadoActual;
  late String estadoSeleccionado;

  bool esAdmin = false;
  bool guardando = false;
  bool eliminando = false;
  bool editando = false;

  bool get esPropietario {
    final usuario = supabase.auth.currentUser;

    return usuario != null &&
        usuario.id == reporteActual['user_id']?.toString();
  }

  bool get puedeEliminar {
    return esPropietario && estadoActual == 'pendiente';
  }

  bool get puedeEditar {
    return esPropietario && estadoActual == 'pendiente';
  }

  @override
  void initState() {
    super.initState();

    reporteActual = Map<String, dynamic>.from(widget.reporte);

    estadoActual = reporteActual['estado']?.toString() ?? 'pendiente';
    estadoSeleccionado = estadoActual;

    final usuario = supabase.auth.currentUser;

    esAdmin = usuario?.email?.toLowerCase() ==
        correoAdmin.toLowerCase();
  }

  Future<void> actualizarEstado() async {
    if (estadoSeleccionado == estadoActual) return;

    setState(() => guardando = true);

    try {
      await supabase
          .from('reportes')
          .update({'estado': estadoSeleccionado})
          .eq('id', reporteActual['id']);

      if (!mounted) return;

      setState(() {
        estadoActual = estadoSeleccionado;
        reporteActual['estado'] = estadoSeleccionado;
        guardando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Estado actualizado correctamente'),
          backgroundColor: verde,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => guardando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo actualizar el estado: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> editarReporte() async {
    if (!puedeEditar || editando || guardando || eliminando) return;

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => CreateReportScreen(
          reporte: reporteActual,
        ),
      ),
    );

    if (resultado != true || !mounted) return;

    setState(() => editando = true);

    try {
      final actualizado = await supabase
          .from('reportes')
          .select()
          .eq('id', reporteActual['id'])
          .maybeSingle();

      if (!mounted) return;

      if (actualizado == null) {
        setState(() => editando = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se pudo cargar el reporte actualizado.'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        reporteActual = Map<String, dynamic>.from(actualizado);
        estadoActual =
            reporteActual['estado']?.toString() ?? 'pendiente';
        estadoSeleccionado = estadoActual;
        editando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte actualizado correctamente'),
          backgroundColor: verde,
        ),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() => editando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo actualizar la vista: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> confirmarEliminacion() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        title: const Text(
          '¿Eliminar reporte?',
          style: TextStyle(
            color: bosque,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Esta acción eliminará tu reporte y su fotografía. '
          'No podrás recuperarlo después.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.blueGrey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
            ),
            child: const Text('Sí, eliminar'),
          ),
        ],
      ),
    );

    if (confirmar == true && mounted) {
      await eliminarReporte();
    }
  }

  Future<void> eliminarReporte() async {
    if (!puedeEliminar || eliminando) return;

    setState(() => eliminando = true);

    try {
      final id = reporteActual['id'].toString();
      final fotoUrl = reporteActual['foto_url']?.toString() ?? '';

      await supabase
          .from('reportes')
          .delete()
          .eq('id', id);

      if (fotoUrl.isNotEmpty) {
        try {
          final uri = Uri.parse(fotoUrl);
          final segmentos = uri.pathSegments;

          final indice = segmentos.indexOf('reportes-fotos');

          if (indice != -1 && indice + 1 < segmentos.length) {
            final rutaFoto = segmentos.skip(indice + 1).join('/');

            await supabase.storage
                .from('reportes-fotos')
                .remove([Uri.decodeComponent(rutaFoto)]);
          }
        } catch (error) {
          debugPrint('No se pudo eliminar la fotografía: $error');
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte eliminado correctamente'),
          backgroundColor: verde,
        ),
      );

      Navigator.pop(context, true);
    } catch (error) {
      if (!mounted) return;

      setState(() => eliminando = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo eliminar el reporte: $error'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoria =
        reporteActual['categoria']?.toString() ?? 'Otro';
    final fotoUrl =
        reporteActual['foto_url']?.toString() ?? '';

    final fecha = reporteActual['created_at'] != null
        ? DateTime.parse(reporteActual['created_at']).toLocal()
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
              reporteActual['titulo']?.toString() ?? 'Sin título',
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
              reporteActual['descripcion']?.toString() ?? '',
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
              _nombreEstado(estadoActual),
            ),

            if (puedeEditar) ...[
              const SizedBox(height: 18),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: editando || guardando || eliminando
                      ? null
                      : editarReporte,
                  icon: editando
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: verde,
                          ),
                        )
                      : const Icon(Icons.edit_outlined),
                  label: Text(
                    editando ? 'Actualizando...' : 'Editar mi reporte',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: bosque,
                    side: const BorderSide(color: verde),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Puedes editar tu reporte mientras esté pendiente.',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],

            if (esAdmin) ...[
              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(17),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: salvia),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.admin_panel_settings, color: verde),
                        SizedBox(width: 9),
                        Text(
                          'Administración del reporte',
                          style: TextStyle(
                            color: bosque,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    DropdownButtonFormField<String>(
                      initialValue: estadoSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Cambiar estado',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'pendiente',
                          child: Text('Pendiente'),
                        ),
                        DropdownMenuItem(
                          value: 'en revisión',
                          child: Text('En revisión'),
                        ),
                        DropdownMenuItem(
                          value: 'atendido',
                          child: Text('Atendido'),
                        ),
                      ],
                      onChanged: guardando || eliminando
                          ? null
                          : (valor) {
                              if (valor != null) {
                                setState(() {
                                  estadoSeleccionado = valor;
                                });
                              }
                            },
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: guardando ||
                                eliminando ||
                                estadoSeleccionado == estadoActual
                            ? null
                            : actualizarEstado,
                        icon: guardando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(
                          guardando ? 'Guardando...' : 'Guardar cambios',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bosque,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (puedeEliminar) ...[
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: eliminando || guardando || editando
                      ? null
                      : confirmarEliminacion,
                  icon: eliminando
                      ? const SizedBox(
                          width: 19,
                          height: 19,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.red,
                          ),
                        )
                      : const Icon(Icons.delete_outline_rounded),
                  label: Text(
                    eliminando ? 'Eliminando...' : 'Eliminar mi reporte',
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                    side: BorderSide(color: Colors.red.shade300),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              const Center(
                child: Text(
                  'Solo puedes eliminar reportes pendientes.',
                  style: TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 12,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 15),

            _dato(
              Icons.location_on_outlined,
              'Ubicación GPS',
              '${reporteActual['latitud']}, ${reporteActual['longitud']}',
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
