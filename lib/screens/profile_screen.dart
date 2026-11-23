import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'my_reports_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  static const bosque = Color(0xFF183D2C);
  static const verde = Color(0xFF416B4C);
  static const salvia = Color(0xFFDCE8D5);
  static const cafe = Color(0xFF987451);

  Future<void> _cerrarSesion(BuildContext context) async {
    try {
      await Supabase.instance.client.auth.signOut();

      if (!context.mounted) return;

      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo cerrar la sesión. Intenta nuevamente.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = Supabase.instance.client.auth.currentUser;

    final metadata = usuario?.userMetadata ?? {};
    final nombre = metadata['nombre_completo'] ??
        metadata['full_name'] ??
        metadata['name'] ??
        usuario?.email?.split('@').first ??
        'Ciudadano';

    final correo = usuario?.email ?? 'Sin correo registrado';

    final proveedor =
        usuario?.appMetadata['provider']?.toString() ?? 'email';

    final metodo = proveedor == 'google'
        ? 'Cuenta de Google'
        : 'Correo electrónico';

    final foto = metadata['avatar_url'] ?? metadata['picture'];

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F4),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F8F4),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Mi perfil',
          style: TextStyle(
            color: bosque,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: bosque),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 30),
        child: Column(
          children: [
            // TARJETA DEL USUARIO
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                vertical: 28,
                horizontal: 20,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [bosque, verde],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: salvia,
                    backgroundImage:
                        foto is String && foto.isNotEmpty
                            ? NetworkImage(foto)
                            : null,
                    child: foto is String && foto.isNotEmpty
                        ? null
                        : const Icon(
                            Icons.person_rounded,
                            color: bosque,
                            size: 53,
                          ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    nombre.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    correo,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: salvia,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 13,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      metodo,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // INFORMACIÓN DE LA CUENTA
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Información de la cuenta',
                style: TextStyle(
                  color: bosque,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 13),

            _opcion(
              icono: Icons.person_outline_rounded,
              titulo: 'Nombre completo',
              subtitulo: nombre.toString(),
            ),

            const SizedBox(height: 10),

            _opcion(
              icono: Icons.email_outlined,
              titulo: 'Correo electrónico',
              subtitulo: correo,
            ),

            const SizedBox(height: 10),

            _opcion(
              icono: Icons.login_rounded,
              titulo: 'Método de acceso',
              subtitulo: metodo,
            ),

            const SizedBox(height: 28),

            // OPCIONES
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Mi actividad',
                style: TextStyle(
                  color: bosque,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 13),

            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MyReportsScreen(),
                  ),
                );
              },
              child: _opcion(
                icono: Icons.assignment_outlined,
                titulo: 'Mis reportes',
                subtitulo: 'Consulta los reportes que has realizado',
                mostrarFlecha: true,
              ),
            ),

            const SizedBox(height: 28),

            // CERRAR SESIÓN
            SizedBox(
              width: double.infinity,
              height: 53,
              child: OutlinedButton.icon(
                onPressed: () => _cerrarSesion(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.redAccent,
                  side: const BorderSide(color: Color(0xFFE9C9C5)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 25),

            const Text(
              'CIVIC APP · PUERTO SUÁREZ',
              style: TextStyle(
                color: cafe,
                fontSize: 10,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              'Tu barrio. Tu voz. Tu impacto.',
              style: TextStyle(
                color: Colors.blueGrey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _opcion({
    required IconData icono,
    required String titulo,
    required String subtitulo,
    bool mostrarFlecha = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDE5)),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            decoration: BoxDecoration(
              color: salvia,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icono,
              color: verde,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    color: bosque,
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    color: Colors.blueGrey,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (mostrarFlecha)
            const Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.black38,
              size: 15,
            ),
        ],
      ),
    );
  }
}
