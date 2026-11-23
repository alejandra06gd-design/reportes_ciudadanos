
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const bosque = Color(0xFF183D2C);
  static const verde = Color(0xFF416B4C);
  static const salvia = Color(0xFFDCE8D5);
  static const cafe = Color(0xFF987451);

  final formularioKey = GlobalKey<FormState>();

  bool ocultarPassword = true;
  bool ocultarConfirmacion = true;
  bool cargando = false;

  final nombreController = TextEditingController();
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmacionController = TextEditingController();

  @override
  void dispose() {
    nombreController.dispose();
    correoController.dispose();
    passwordController.dispose();
    confirmacionController.dispose();
    super.dispose();
  }

Future<void> _registrar() async {
  if (!formularioKey.currentState!.validate()) {
    return;
  }

  setState(() {
    cargando = true;
  });

  try {
    final respuesta = await Supabase.instance.client.auth.signUp(
      email: correoController.text.trim(),
      password: passwordController.text,
      data: {
        'nombre_completo': nombreController.text.trim(),
      },
    );

    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          respuesta.session == null
              ? '¡Cuenta creada! Revisa tu correo para confirmar el registro.'
              : '¡Cuenta creada correctamente! Ya puedes iniciar sesión.',
        ),
        backgroundColor: bosque,
      ),
    );

    Navigator.pop(context);
  } on AuthException catch (error) {
    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.redAccent,
      ),
    );
  } catch (error) {
    if (!mounted) return;

    setState(() {
      cargando = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Ocurrió un error. Intenta nuevamente.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  }
}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 18, 24, 28),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [bosque, verde],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Icon(
                      Icons.person_add_alt_1_rounded,
                      color: salvia,
                      size: 42,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      '¡Únete a CIVIC APP!',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 27,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Crea tu cuenta y comienza a participar en el cambio de tu comunidad.',
                      style: TextStyle(
                        color: salvia,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(25, 28, 25, 30),
                child: Form(
                  key: formularioKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Crear una cuenta',
                        style: TextStyle(
                          color: bosque,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 7),
                      const Text(
                        'Completa tus datos para registrarte.',
                        style: TextStyle(
                          color: Color(0xFF758075),
                          fontSize: 14,
                        ),
                      ),

                      const SizedBox(height: 25),

                      _tituloCampo('Nombre completo'),
                      _campo(
                        controller: nombreController,
                        hint: 'Ej. María Fernández',
                        icon: Icons.person_outline_rounded,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Ingresa tu nombre completo';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      _tituloCampo('Correo electrónico'),
                      _campo(
                        controller: correoController,
                        hint: 'nombre@correo.com',
                        icon: Icons.mail_outline_rounded,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null ||
                              !RegExp(r'^[^@]+@[^@]+\.[^@]+$')
                                  .hasMatch(value.trim())) {
                            return 'Ingresa un correo válido';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      _tituloCampo('Contraseña'),
                      _campo(
                        controller: passwordController,
                        hint: 'Mínimo 6 caracteres',
                        icon: Icons.lock_outline_rounded,
                        obscureText: ocultarPassword,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              ocultarPassword = !ocultarPassword;
                            });
                          },
                          icon: Icon(
                            ocultarPassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: verde,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.length < 6) {
                            return 'Usa al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 18),

                      _tituloCampo('Confirmar contraseña'),
                      _campo(
                        controller: confirmacionController,
                        hint: 'Repite tu contraseña',
                        icon: Icons.lock_reset_rounded,
                        obscureText: ocultarConfirmacion,
                        suffix: IconButton(
                          onPressed: () {
                            setState(() {
                              ocultarConfirmacion = !ocultarConfirmacion;
                            });
                          },
                          icon: Icon(
                            ocultarConfirmacion
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: verde,
                          ),
                        ),
                        validator: (value) {
                          if (value != passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 28),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: cargando ? null : _registrar,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: bosque,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: cargando
                              ? const SizedBox(
                                  height: 23,
                                  width: 23,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Crear mi cuenta',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 22),

                      Center(
                        child: Wrap(
                          alignment: WrapAlignment.center,
                          children: [
                            const Text(
                              '¿Ya tienes una cuenta? ',
                              style: TextStyle(
                                color: Color(0xFF758075),
                                fontSize: 13,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: const Text(
                                'Inicia sesión',
                                style: TextStyle(
                                  color: verde,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      const Center(
                        child: Text(
                          'PUERTO SUÁREZ · SANTA CRUZ · BOLIVIA',
                          style: TextStyle(
                            color: cafe,
                            fontSize: 10,
                            letterSpacing: 1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tituloCampo(String texto) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Text(
        texto,
        style: const TextStyle(
          color: bosque,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }

  Widget _campo({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFFA0A99F),
          fontSize: 13,
        ),
        prefixIcon: Icon(icon, color: cafe, size: 21),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE1E6DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: verde, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
