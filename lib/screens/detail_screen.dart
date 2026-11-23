
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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

  late String estadoActual;
  late String estadoSeleccionado;

  bool esAdmin = false;
  bool guardando = false;

  @override
  void initState() {
    super.initState();

    estadoActual = widget.reporte['estado']?.toString() ?? 'pendiente';
    estadoSeleccionado = estadoActual;

    final usuario = Supabase.instance.client.auth.currentUser;

    esAdmin = usuario?.email?.toLowerCase() ==
        correoAdmin.toLowerCase();
  }

  Future<void> actualizarEstado() async {
    if (estadoSeleccionado == estadoActual) return;

    setState(() => guardando = true);

    try {
      await Supabase.instance.client
          .from('reportes')
          .update({'estado': estadoSeleccionado})
          .eq('id', widget.reporte['id']);

      if (!mounted) return;

      setState(() {
        estadoActual = estadoSeleccionado;
        widget.reporte['estado'] = estadoSeleccionado;
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

  @override
  Widget build(BuildContext context) {
    final categoria = widget.reporte['categoria']?.toString() ?? 'Otro';
    final fotoUrl = widget.reporte['foto_url']?.toString() ?? '';

    final fecha = widget.reporte['created_at'] != null
        ? DateTime.parse(widget.reporte['created_at']).toLocal()
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
              widget.reporte['titulo']?.toString() ?? 'Sin título',
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
              widget.reporte['descripcion']?.toString() ?? '',
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
                        Icon(Icons.admin_panel_settings,
                            color: verde),
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
                      onChanged: guardando
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

            const SizedBox(height: 15),

            _dato(
              Icons.location_on_outlined,
              'Ubicación GPS',
              '${widget.reporte['latitud']}, ${widget.reporte['longitud']}',
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
