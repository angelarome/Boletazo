import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_helper.dart';
import 'boleta.dart';
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmarPasswordController = TextEditingController();

  bool ocultarPassword = true;
  bool ocultarConfirmarPassword = true;

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
    confirmarPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  const Text(
                    'Iniciar sesión',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 20), // espacio entre título y logo

                  // LOGO
                  Container(
                    width: 190,
                    height: 190,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'img/3.png',
                        width: 80,
                        height: 80,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                const SizedBox(height: 40),
              

                // CAMPO CORREO
                campoCorreo('Correo electrónico', correoController),
                const SizedBox(height: 20),

                // CAMPO CONTRASEÑA
                _campoPassword(
                  'Contraseña',
                  controller: passwordController,
                  ocultar: ocultarPassword,
                  onToggle: () {
                    setState(() {
                      ocultarPassword = !ocultarPassword;
                    });
                  },
                  icono: const Icon(Icons.lock, color: Colors.black),
                ),
                const SizedBox(height: 20),

                // CAMPO CONFIRMAR CONTRASEÑA
                _campoPassword(
                  'Confirmar contraseña',
                  controller: confirmarPasswordController,
                  ocultar: ocultarConfirmarPassword,
                  onToggle: () {
                    setState(() {
                      ocultarConfirmarPassword = !ocultarConfirmarPassword;
                    });
                  },
                  icono: const Icon(Icons.lock, color: Colors.black),
                ),
                const SizedBox(height: 30),

                // BOTÓN REGISTRARSE
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      if (passwordController.text != confirmarPasswordController.text) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Las contraseñas no coinciden"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      final correo = correoController.text.trim();
                      final password = passwordController.text.trim();

                      if (correo.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Por favor completa todos los campos"),
                            backgroundColor: Colors.red,
                          ),
                        );
                        return;
                      }

                      showDialog(
                        context: context,
                        barrierDismissible: false, // que no se pueda cerrar tocando afuera
                        builder: (context) => Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFF48CB8F),
                          ),
                        ),
                      );

                      try {
                        final db = DatabaseHelper();
                        await db.insertarUsuario(correo, password);

                        Navigator.pop(context); // cerrar loading

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: const [
                                Icon(Icons.check_circle, color: Colors.green, size: 22),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    'Usuario registrado exitosamente',
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.white, // fondo blanco
                            behavior: SnackBarBehavior.floating, // flota sobre la UI
                            margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            duration: Duration(seconds: 2),
                          ),
                        );

                        correoController.clear();
                        passwordController.clear();
                        confirmarPasswordController.clear();

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const CrearBoletaScreen()),
                        );
                      } catch (e) {
                        Navigator.pop(context); // cerrar loading si hay error
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.error, color: Colors.red, size: 22),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Error al registrar usuario: $e",
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.white, // fondo blanco
                            behavior: SnackBarBehavior.floating, // flota sobre la UI
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.person_add, // Icono para registrarse
                      color: Colors.white,
                      size: 24,
                    ),
                    label: const Text(
                      'Registrarse',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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

  // MÉTODO CAMPO CORREO
  Widget campoCorreo(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@._\-]')),
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "ej: ejemplo@gmail.com",
            prefixIcon: const Padding(
              padding: EdgeInsets.all(12),
              child: Icon(Icons.email, color: Colors.black, size: 20),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }

  // MÉTODO CAMPO CONTRASEÑA
  Widget _campoPassword(
    String label, {
    required TextEditingController controller,
    required bool ocultar,
    required VoidCallback onToggle,
    required Widget icono,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          obscureText: ocultar,
          controller: controller,
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9@#\$%&*_-]')),
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "ej: familia5577",
            prefixIcon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(width: 24, height: 24, child: icono),
            ),
            suffixIcon: IconButton(
              onPressed: onToggle,
              icon: Icon(
                ocultar ? Icons.visibility_off : Icons.visibility,
                color: Colors.black,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
