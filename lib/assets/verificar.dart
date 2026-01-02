import 'package:flutter/material.dart';
import 'login.dart';
import 'boleta.dart';
import 'auth_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    await Future.delayed(const Duration(seconds: 2)); // efecto cargando

    final logueado = await AuthService.estaLogueado();

    if (!mounted) return;

    if (logueado) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const CrearBoletaScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // ÍCONO DE LA APP
            Image.asset(
              'img/3.png',
              width: 120,
            ),

            const SizedBox(height: 20),

            const CircularProgressIndicator(),

            const SizedBox(height: 12),

            const Text(
              'Cargando...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
