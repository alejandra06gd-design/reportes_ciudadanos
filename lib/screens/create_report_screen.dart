
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CreateReportScreen extends StatefulWidget {
  final String? categoriaInicial;
  final Map<String, dynamic>? reporte;

  const CreateReportScreen({
    super.key,
    this.categoriaInicial,
    this.reporte,
  });

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  static const bosque = Color(0xFF183D2C);
  static const verde = Color(0xFF416B4C);
  static const salvia = Color(0xFFDCE8D5);

  final _formKey = GlobalKey<FormState>();
  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();

  final ImagePicker picker = ImagePicker();

  String? categoria;
  String? fotoUrlExistente;
  XFile? imagenSeleccionada;
  Position? ubicacionActual;

  bool obteniendoUbicacion = false;
  bool guardandoReporte = false;

  bool get modoEdicion => widget.reporte != null;

  final categorias = [
    'Bache',
    'Basura',
    'Alumbrado público',
    'Otro',
  ];

  @override
  void initState() {
    super.initState();

    if (modoEdicion) {
      final reporte = widget.reporte!;

      tituloController.text = reporte['titulo']?.toString() ?? '';
      descripcionController.text =
          reporte['descripcion']?.toString() ?? '';

      final categoriaReporte = reporte['categoria']?.toString();

      if (categorias.contains(categoriaReporte)) {
        categoria = categoriaReporte;
      }

      fotoUrlExistente = reporte['foto_url']?.toString();
    } else if (categorias.contains(widget.categoriaInicial)) {
      categoria = widget.categoriaInicial;
    }
  }

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  Future<void> seleccionarImagen(ImageSource origen) async {
    try {
      final XFile? imagen = await picker.pickImage(
        source: origen,
        imageQuality: 80,
      );

      if (imagen != null && mounted) {
        setState(() {
          imagenSeleccionada = imagen;
        });
      }
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo seleccionar la fotografía.'),
        ),
      );
    }
  }

  Future<void> obtenerUbicacion() async {
    setState(() => obteniendoUbicacion = true);

    try {
      final servicioActivo =
          await Geolocator.isLocationServiceEnabled();

      if (!servicioActivo) {
        throw Exception('Activa el GPS de tu teléfono.');
      }

      LocationPermission permiso =
          await Geolocator.checkPermission();

      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }

      if (permiso == LocationPermission.denied) {
        throw Exception(
          'Necesitamos permiso para acceder a tu ubicación.',
        );
      }

      if (permiso == LocationPermission.deniedForever) {
        throw Exception(
          'El permiso está bloqueado. Actívalo desde los ajustes.',
        );
      }

      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() => ubicacionActual = posicion);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Ubicación obtenida correctamente!'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            error.toString().replaceFirst('Exception: ', ''),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => obteniendoUbicacion = false);
      }
    }
  }

  String? obtenerRutaFoto(String url) {
    try {
      final uri = Uri.parse(url);
      final segmentos = uri.pathSegments;
      final indice = segmentos.indexOf('reportes-fotos');

      if (indice == -1 || indice + 1 >= segmentos.length) {
        return null;
      }

      return Uri.decodeComponent(
        segmentos.skip(indice + 1).join('/'),
      );
    } catch (_) {
      return null;
    }
  }

  Future<String?> subirNuevaFotografia(
    SupabaseClient supabase,
    String usuarioId,
  ) async {
    if (imagenSeleccionada == null) return null;

    final archivo = File(imagenSeleccionada!.path);
    final extension =
        imagenSeleccionada!.path.split('.').last.toLowerCase();

    final contentType =
        extension == 'png' ? 'image/png' : 'image/jpeg';

    final nombreArchivo =
        '${DateTime.now().millisecondsSinceEpoch}.$extension';

    final rutaArchivo = '$usuarioId/$nombreArchivo';

    await supabase.storage.from('reportes-fotos').upload(
      rutaArchivo,
      archivo,
      fileOptions: FileOptions(contentType: contentType),
    );

    return supabase.storage
        .from('reportes-fotos')
        .getPublicUrl(rutaArchivo);
  }

  Future<void> guardarReporte() async {
    if (!_formKey.currentState!.validate()) return;

    if (!modoEdicion && imagenSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes agregar una fotografía del problema.'),
        ),
      );
      return;
    }

    if (!modoEdicion && ubicacionActual == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Primero debes obtener la ubicación GPS.'),
        ),
      );
      return;
    }

    final supabase = Supabase.instance.client;
    final usuario = supabase.auth.currentUser;

    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tu sesión ha terminado. Inicia sesión nuevamente.'),
        ),
      );
      return;
    }

    setState(() => guardandoReporte = true);

    String? nuevaFotoUrl;

    try {
      nuevaFotoUrl = await subirNuevaFotografia(
        supabase,
        usuario.id,
      );

      if (modoEdicion) {
        final fotoAnterior = fotoUrlExistente;

        final resultado = await supabase
            .from('reportes')
            .update({
                'titulo': tituloController.text.trim(),
                'descripcion': descripcionController.text.trim(),
                'categoria': categoria,
                'foto_url': ?nuevaFotoUrl,
              })
            .eq('id', widget.reporte!['id'])
            .eq('user_id', usuario.id)
            .eq('estado', 'pendiente')
            .select('id')
            .maybeSingle();

        if (resultado == null) {
          throw Exception(
            'No se pudo editar el reporte. Puede que ya no esté pendiente.',
          );
        }

        // Eliminar la fotografía anterior solo después de guardar
        // correctamente la nueva información.
        if (nuevaFotoUrl != null &&
            fotoAnterior != null &&
            fotoAnterior.isNotEmpty) {
          final rutaAnterior = obtenerRutaFoto(fotoAnterior);

          if (rutaAnterior != null) {
            try {
              await supabase.storage
                  .from('reportes-fotos')
                  .remove([rutaAnterior]);
            } catch (error) {
              debugPrint(
                'No se pudo eliminar la fotografía anterior: $error',
              );
            }
          }
        }

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reporte actualizado correctamente!'),
            backgroundColor: verde,
          ),
        );

        Navigator.pop(context, true);
      } else {
        final fotoUrl = nuevaFotoUrl;

        if (fotoUrl == null) {
          throw Exception('No se pudo preparar la fotografía.');
        }

        await supabase.from('reportes').insert({
          'user_id': usuario.id,
          'titulo': tituloController.text.trim(),
          'descripcion': descripcionController.text.trim(),
          'categoria': categoria,
          'foto_url': fotoUrl,
          'latitud': ubicacionActual!.latitude,
          'longitud': ubicacionActual!.longitude,
        });

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('¡Reporte enviado correctamente!'),
            backgroundColor: verde,
          ),
        );

        Navigator.pop(context, true);
      }
    } on StorageException catch (error) {
      // Si se subió una foto nueva pero falló el guardado,
      // intentar limpiar ese archivo.
      if (nuevaFotoUrl != null) {
        final ruta = obtenerRutaFoto(nuevaFotoUrl);
        if (ruta != null) {
          try {
            await supabase.storage
                .from('reportes-fotos')
                .remove([ruta]);
          } catch (_) {}
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error con la fotografía: ${error.message}'),
        ),
      );
    } on PostgrestException catch (error) {
      if (nuevaFotoUrl != null) {
        final ruta = obtenerRutaFoto(nuevaFotoUrl);
        if (ruta != null) {
          try {
            await supabase.storage
                .from('reportes-fotos')
                .remove([ruta]);
          } catch (_) {}
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar el reporte: ${error.message}'),
        ),
      );
    } catch (error) {
      if (nuevaFotoUrl != null) {
        final ruta = obtenerRutaFoto(nuevaFotoUrl);
        if (ruta != null) {
          try {
            await supabase.storage
                .from('reportes-fotos')
                .remove([ruta]);
          } catch (_) {}
        }
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo ${modoEdicion ? 'actualizar' : 'enviar'} el reporte: $error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => guardandoReporte = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final reporte = widget.reporte;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F4),
        foregroundColor: bosque,
        elevation: 0,
        title: Text(
          modoEdicion ? 'Editar reporte' : 'Nuevo reporte',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  modoEdicion
                      ? 'Corrige la información de tu reporte.'
                      : 'Tu voz puede generar un cambio.',
                  style: const TextStyle(
                    color: bosque,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  modoEdicion
                      ? 'Actualiza los datos que necesites.'
                      : 'Cuéntanos qué problema encontraste en tu barrio.',
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Título del reporte',
                  style: TextStyle(
                    color: bosque,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                TextFormField(
                  controller: tituloController,
                  decoration: _decoracion(
                    'Ej. Bache en la calle principal',
                    Icons.edit_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Ingresa el título del reporte.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 22),

                const Text(
                  'Categoría',
                  style: TextStyle(
                    color: bosque,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                DropdownButtonFormField<String>(
                  initialValue: categoria,
                  decoration: _decoracion(
                    'Selecciona una categoría',
                    Icons.category_outlined,
                  ),
                  items: categorias.map((item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => categoria = value);
                  },
                  validator: (value) {
                    if (value == null) {
                      return 'Selecciona una categoría.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 22),

                const Text(
                  'Descripción del problema',
                  style: TextStyle(
                    color: bosque,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 9),
                TextFormField(
                  controller: descripcionController,
                  maxLines: 5,
                  decoration: _decoracion(
                    'Describe dónde ocurre y qué está pasando...',
                    Icons.description_outlined,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Describe el problema.';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 24),

                const Text(
                  'Fotografía del problema',
                  style: TextStyle(
                    color: bosque,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                Column(
                  children: [
                    if (imagenSeleccionada != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: Image.file(
                          File(imagenSeleccionada!.path),
                          width: double.infinity,
                          height: 190,
                          fit: BoxFit.cover,
                        ),
                      )
                    else if (modoEdicion &&
                        fotoUrlExistente != null &&
                        fotoUrlExistente!.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(17),
                        child: Image.network(
                          fotoUrlExistente!,
                          width: double.infinity,
                          height: 190,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _imagenVacia(),
                        ),
                      )
                    else
                      _imagenVacia(),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: guardandoReporte
                                ? null
                                : () => seleccionarImagen(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Cámara'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: guardandoReporte
                                ? null
                                : () => seleccionarImagen(ImageSource.gallery),
                            icon: const Icon(Icons.photo_library_outlined),
                            label: const Text('Galería'),
                          ),
                        ),
                      ],
                    ),

                    if (imagenSeleccionada != null)
                      TextButton.icon(
                        onPressed: () {
                          setState(() => imagenSeleccionada = null);
                        },
                        icon: const Icon(Icons.undo_rounded),
                        label: const Text('Conservar fotografía anterior'),
                        style: TextButton.styleFrom(
                          foregroundColor: verde,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 28),

                const Text(
                  'Ubicación del problema',
                  style: TextStyle(
                    color: bosque,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

                if (modoEdicion)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: salvia.withValues(alpha: 0.45),
                      borderRadius: BorderRadius.circular(17),
                      border: Border.all(
                        color: verde.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: verde,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Latitud: ${reporte!['latitud']}\n'
                            'Longitud: ${reporte['longitud']}\n'
                            'La ubicación original se conservará.',
                            style: const TextStyle(
                              color: bosque,
                              fontSize: 12,
                              height: 1.6,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  _ubicacionNueva(),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed:
                        guardandoReporte ? null : guardarReporte,
                    icon: guardandoReporte
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Icon(
                            modoEdicion
                                ? Icons.save_outlined
                                : Icons.send_rounded,
                          ),
                    label: Text(
                      guardandoReporte
                          ? 'Guardando...'
                          : modoEdicion
                              ? 'Guardar cambios'
                              : 'Continuar con el reporte',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: bosque,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _imagenVacia() {
    return Container(
      width: double.infinity,
      height: 190,
      decoration: BoxDecoration(
        color: salvia.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(17),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_a_photo_outlined,
            color: verde,
            size: 35,
          ),
          SizedBox(height: 9),
          Text(
            'Agregar fotografía',
            style: TextStyle(
              color: bosque,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4),
          Text(
            'Toma una foto o selecciónala de tu galería',
            style: TextStyle(
              color: Colors.blueGrey,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _ubicacionNueva() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: salvia.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(17),
        border: Border.all(
          color: verde.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.location_on_outlined,
                color: verde,
                size: 28,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  ubicacionActual != null
                      ? 'Ubicación obtenida'
                      : 'Ubicación pendiente',
                  style: const TextStyle(
                    color: bosque,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (ubicacionActual != null)
                const Icon(Icons.check_circle, color: verde),
            ],
          ),
          const SizedBox(height: 10),
          if (ubicacionActual != null) ...[
            Text(
              'Latitud: ${ubicacionActual!.latitude}',
              style: const TextStyle(color: bosque, fontSize: 13),
            ),
            const SizedBox(height: 5),
            Text(
              'Longitud: ${ubicacionActual!.longitude}',
              style: const TextStyle(color: bosque, fontSize: 13),
            ),
          ] else
            const Text(
              'Obtén las coordenadas GPS del lugar donde ocurre el problema.',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 12,
              ),
            ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed:
                  obteniendoUbicacion ? null : obtenerUbicacion,
              icon: obteniendoUbicacion
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.my_location),
              label: Text(
                obteniendoUbicacion
                    ? 'Obteniendo ubicación...'
                    : ubicacionActual != null
                        ? 'Actualizar ubicación'
                        : 'Obtener mi ubicación',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: bosque,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _decoracion(String texto, IconData icono) {
    return InputDecoration(
      hintText: texto,
      prefixIcon: Icon(icono, color: verde),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.all(16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: Color(0xFFE8EDE5),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: verde,
          width: 1.5,
        ),
      ),
    );
  }
}
