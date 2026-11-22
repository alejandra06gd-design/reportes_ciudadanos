
import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const CivicApp());
}

class CivicApp extends StatelessWidget {
  const CivicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CIVIC APP',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8F4),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF244D38),
        ),
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
    );
  }
}


class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const bosque = Color(0xFF183D2C);
    const verde = Color(0xFF416B4C);
    const salvia = Color(0xFFDCE8D5);
    const cafe = Color(0xFF987451);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF183D2C),
              Color(0xFF315C3E),
              Color(0xFF52764E),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -65,
                right: -65,
                child: Container(
                  width: 210,
                  height: 210,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.10),
                      width: 30,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 150,
                left: -90,
                child: Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.04),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 25,
                  vertical: 18,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CIVIC APP',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                            Text(
                              'PARTICIPACIÓN CIUDADANA',
                              style: TextStyle(
                                color: Color(0xFFDCE8D5),
                                fontSize: 9,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const Spacer(),
                    const Text(
                      'PUERTO SUAREZ',
                      style: TextStyle(
                        color: Color(0xFFD8C3A5),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2.5,
                      ),
                    ),
                    const SizedBox(height: 17),
                    const Text(
                      'Tu barrio.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 39,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                    const Text(
                      'Tu voz.',
                      style: TextStyle(
                        color: Color(0xFFDCE8D5),
                        fontSize: 39,
                        fontWeight: FontWeight.w800,
                        height: 1.2,
                      ),
                    ),
                    const Text(
                      'Tu impacto.',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 39,
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const SizedBox(height: 18),
                    const Text(
                      'Identifiquemos juntos lo que necesita mejorar en nuestra comunidad.',
                      style: TextStyle(
                        color: Color(0xFFE2EADF),
                        fontSize: 15,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: salvia,
                        borderRadius: BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Una comunidad conectada',
                                style: TextStyle(
                                  color: bosque,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Icon(
                                Icons.explore_rounded,
                                color: cafe,
                                size: 27,
                              ),
                            ],
                          ),
                          const SizedBox(height: 19),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _feature(
                                Icons.camera_alt_rounded,
                                'Reporta',
                                bosque,
                              ),
                              _feature(
                                Icons.location_on_rounded,
                                'Ubica',
                                bosque,
                              ),
                              _feature(
                                Icons.nature_people_rounded,
                                'Mejora',
                                bosque,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LoginScreen(),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: salvia,
                          foregroundColor: bosque,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Ingresar a CIVIC APP',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 17),
                    const Center(
                      child: Text(
                        'Una iniciativa para transformar nuestro entorno',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFDCE8D5),
                          fontSize: 11,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _feature(IconData icon, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 29),
        const SizedBox(height: 7),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
