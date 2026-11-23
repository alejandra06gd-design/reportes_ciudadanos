
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'register_screen.dart';
import 'home_screen.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool ocultarPassword = true;

  StreamSubscription<AuthState>? authSubscription;
  
  final correoController = TextEditingController();
  final passwordController = TextEditingController();
  bool cargando = false;
  bool cargandoGoogle = false;

  static const bosque = Color(0xFF183D2C);
  static const verde = Color(0xFF416B4C);
  static const salvia = Color(0xFFDCE8D5);
  static const cafe = Color(0xFF987451);
  static const fondo = Color(0xFFF7F8F4);

  Future<void> _iniciarSesion() async {
  final correo = correoController.text.trim();
  final password = passwordController.text;

  if (correo.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Completa tu correo y contraseña.'),
      ),
    );
    return;
  }

  setState(() {
    cargando = true;
  });

  try {
    await Supabase.instance.client.auth.signInWithPassword(
      email: correo,
      password: password,
    );

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  } on AuthException catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.redAccent,
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo iniciar sesión. Intenta nuevamente.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        cargando = false;
      });
    }
  }
}

Future<void> _iniciarSesionGoogle() async {
  setState(() {
    cargandoGoogle = true;
  });

  try {
    await Supabase.instance.client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: 'civicapp://login-callback',
      authScreenLaunchMode: LaunchMode.externalApplication,
    );
  } on AuthException catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(error.message),
        backgroundColor: Colors.redAccent,
      ),
    );
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('No se pudo iniciar sesión con Google.'),
        backgroundColor: Colors.redAccent,
      ),
    );
  } finally {
    if (mounted) {
      setState(() {
        cargandoGoogle = false;
      });
    }
  }
}

@override
void initState() {
  super.initState();

  authSubscription =
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
    if (data.event == AuthChangeEvent.signedIn && mounted) {
      Navigator.of(context).popUntil((route) => route.isFirst);
    }
  });
}

@override
void dispose() {
  authSubscription?.cancel();
  super.dispose();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ENCABEZADO CON DEGRADADO
              Container(
                width: double.infinity,
                height: 220,
                padding: const EdgeInsets.fromLTRB(25, 22, 25, 25),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF183D2C),
                      Color(0xFF416B4C),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      right: -25,
                      top: 20,
                      child: Icon(
                        Icons.eco_rounded,
                        size: 145,
                        color: Colors.white.withValues(alpha: 0.08),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.spa_rounded,
                              color: salvia,
                              size: 28,
                            ),
                            const SizedBox(width: 10),
                            const Text(
                              'CIVIC APP',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                fontSize: 18,
                              ),
                            ),
                            const Spacer(),
                            const Text(
                              'PUERTO SUÁREZ',
                              style: TextStyle(
                                color: salvia,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const Text(
                          'Qué bueno tenerte',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          'de vuelta.',
                          style: TextStyle(
                            color: salvia,
                            fontSize: 31,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Tu participación hace la diferencia.',
                          style: TextStyle(
                            color: Color(0xFFE3EDE2),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // FORMULARIO
              Padding(
                padding: const EdgeInsets.fromLTRB(25, 30, 25, 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        color: bosque,
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 7),
                    const Text(
                      'Ingresa tus datos para acceder a tu cuenta.',
                      style: TextStyle(
                        color: Color(0xFF758075),
                        fontSize: 14,
                      ),
                    ),

                    const SizedBox(height: 27),

                    const Text(
                      'Correo electrónico',
                      style: TextStyle(
                        color: bosque,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: correoController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: _decoracion(
                        'nombre@correo.com',
                        Icons.mail_outline_rounded,
                      ),
                    ),

                    const SizedBox(height: 21),

                    const Text(
                      'Contraseña',
                      style: TextStyle(
                        color: bosque,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 9),
                    TextField(
                      controller: passwordController,
                      obscureText: ocultarPassword,
                      decoration: _decoracion(
                        'Ingresa tu contraseña',
                        Icons.lock_outline_rounded,
                      ).copyWith(
                        suffixIcon: IconButton(
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
                      ),
                    ),

                    const SizedBox(height: 8),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          '¿Olvidaste tu contraseña?',
                          style: TextStyle(
                            color: verde,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 15),

                    // BOTÓN DE INGRESO
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: cargando ? null : _iniciarSesion,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: bosque,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: cargando
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2.5,
                              )
                            : const Text(
                                'Ingresar a mi cuenta',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                                              ),
                    ),

                    const SizedBox(height: 23),

                    const Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFD8DED5))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'O continúa con',
                            style: TextStyle(
                              color: Color(0xFF758075),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFD8DED5))),
                      ],
                    ),

                    const SizedBox(height: 20),

                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: cargandoGoogle ? null : _iniciarSesionGoogle,
                        icon: const Icon(
                          Icons.g_mobiledata_rounded,
                          size: 30,
                          color: bosque,
                        ),
                        label: Text(
                          cargandoGoogle
                              ? 'Conectando con Google...'
                              : 'Continuar con Google',
                          style: const TextStyle(
                            color: bosque,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: Color(0xFFD8DED5),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 27),

                    Center(
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          const Text(
                            '¿Todavía no tienes una cuenta? ',
                            style: TextStyle(
                              color: Color(0xFF758075),
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => RegisterScreen(),
                                ),
                              );
                            },
                            child: const Text(
                              'Regístrate',
                              style: TextStyle(
                                color: verde,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on_outlined,
                            color: cafe,
                            size: 16,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Puerto Suárez, Santa Cruz - Bolivia',
                            style: TextStyle(
                              color: Colors.brown.shade400,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _decoracion(String hint, IconData icono) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Color(0xFFA0A99F),
        fontSize: 13,
      ),
      prefixIcon: Icon(
        icono,
        color: cafe,
        size: 21,
      ),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 17,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFFE1E6DD),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: verde,
          width: 1.5,
        ),
      ),
    );
  }
}
