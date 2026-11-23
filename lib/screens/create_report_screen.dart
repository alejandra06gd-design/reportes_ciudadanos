
import 'package:flutter/material.dart';

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
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 27),
                  decoration: BoxDecoration(
                    color: salvia.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(color: verde.withValues(alpha: 0.3)),
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
                        'Próximamente podrás tomar o seleccionar una foto',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: verde,
                        size: 27,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Ubicación GPS\nSe obtendrá al enviar el reporte',
                          style: TextStyle(
                            color: bosque,
                            fontSize: 12,
                            height: 1.5,
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
        borderSide: const BorderSide(color: Color(0xFFE8EDE5)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: verde, width: 1.5),
      ),
    );
  }
}
