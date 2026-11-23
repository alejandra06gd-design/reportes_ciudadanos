
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

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

  String? categoria;

  final ImagePicker picker = ImagePicker();
  XFile? imagenSeleccionada;

  Position? ubicacionActual;
  bool obteniendoUbicacion = false;

  final categorias = [
    'Bache',
    'Basura',
    'Alumbrado público',
    'Otro',
  ];

  @override
  void dispose() {
    tituloController.dispose();
    descripcionController.dispose();
    super.dispose();
  }

  // Seleccionar o tomar fotografía.
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

  // Obtener ubicación GPS.
  Future<void> obtenerUbicacion() async {
    setState(() {
      obteniendoUbicacion = true;
    });

    try {
      bool servicioActivo =
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

      Position posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      if (!mounted) return;

      setState(() {
        ubicacionActual = posicion;
      });

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
        setState(() {
          obteniendoUbicacion = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F4),
        foregroundColor: bosque,
        elevation: 0,
        title: const Text(
          'Nuevo reporte',
          style: TextStyle(fontWeight: FontWeight.bold),
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
                const Text(
                  'Tu voz puede generar un cambio.',
                  style: TextStyle(
                    color: bosque,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Cuéntanos qué problema encontraste en tu barrio.',
                  style: TextStyle(
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
                    setState(() {
                      categoria = value;
                    });
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

                // Fotografía del reporte.
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
                    else
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          vertical: 27,
                        ),
                        decoration: BoxDecoration(
                          color: salvia.withValues(alpha: 0.55),
                          borderRadius: BorderRadius.circular(17),
                          border: Border.all(
                            color: verde.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Column(
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
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.blueGrey,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                seleccionarImagen(ImageSource.camera),
                            icon: const Icon(Icons.camera_alt_outlined),
                            label: const Text('Cámara'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () =>
                                seleccionarImagen(ImageSource.gallery),
                            icon: const Icon(
                              Icons.photo_library_outlined,
                            ),
                            label: const Text('Galería'),
                          ),
                        ),
                      ],
                    ),

                    if (imagenSeleccionada != null)
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            imagenSeleccionada = null;
                          });
                        },
                        icon: const Icon(Icons.delete_outline),
                        label: const Text('Eliminar fotografía'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.redAccent,
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 28),

                // Ubicación GPS.
                const Text(
                  'Ubicación del problema',
                  style: TextStyle(
                    color: bosque,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),

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
                            const Icon(
                              Icons.check_circle,
                              color: verde,
                            ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      if (ubicacionActual != null) ...[
                        Text(
                          'Latitud: ${ubicacionActual!.latitude}',
                          style: const TextStyle(
                            color: bosque,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Longitud: ${ubicacionActual!.longitude}',
                          style: const TextStyle(
                            color: bosque,
                            fontSize: 13,
                          ),
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
                          onPressed: obteniendoUbicacion
                              ? null
                              : obtenerUbicacion,
                          icon: obteniendoUbicacion
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(
                                  Icons.my_location,
                                ),
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
                            padding: const EdgeInsets.symmetric(
                              vertical: 13,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Formulario validado. Próximo paso: guardar el reporte.',
                            ),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.send_rounded),
                    label: const Text(
                      'Continuar con el reporte',
                      style: TextStyle(
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
