import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'registrarse.dart';
import 'boleta.dart';
import 'database_helper.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController correoController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool ocultarPassword = true;


  void ocultarLoading(BuildContext context) {
    Navigator.of(context).pop(); // cierra el diálogo
  }

  void mostrarLoading(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // No se puede cerrar tocando afuera
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  @override
  void dispose() {
    correoController.dispose();
    passwordController.dispose();
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

                _campoPassword(
                  'Contraseña',
                  ocultar: ocultarPassword,
                  onToggle: () {
                    setState(() {
                      ocultarPassword = !ocultarPassword;
                    });
                  },
                  controller: passwordController,
                  icono: Icon(
                    Icons.lock,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 30),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final correo = correoController.text.trim();
                      final password = passwordController.text.trim();

                      if (correo.isEmpty || password.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: const [
                              Icon(Icons.error, color: Colors.red, size: 22),
                              SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  "Por favor completa todos los campos",
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
                          duration: Duration(seconds: 3),
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

                      final db = DatabaseHelper();
                      final existe = await db.usuarioExiste(correo, password);

                      Navigator.pop(context);
                      if (existe) {
                        // Usuario existe → navegar a pantalla de boletas
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const CrearBoletaScreen()),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: const [
                                Icon(Icons.error, color: Colors.red, size: 22),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    "Usuario o contraseña incorrectos",
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
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    icon: const Icon(
                      Icons.login,
                      color: Colors.white,
                      size: 24,
                    ),
                    label: const Text(
                      'Iniciar sesión',
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
                const SizedBox(height: 16),

                // OLVIDASTE CONTRASEÑA
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('¿No tienes cuenta? '),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: const Text(
                        'Registrarse',
                        style: TextStyle(
                          color: Color(0xFF1E88E5),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // MÉTODO PARA EL CAMPO CORREO
  Widget campoCorreo(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Etiqueta
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 6),

        // Campo de texto
        TextFormField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          inputFormatters: [
            // Solo permite letras, números, punto, guion, guion bajo y @
            FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-Z0-9@._\-]'),
            ),
          ],
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            hintText: "ej: ejemplo@gmail.com",
            prefixIcon: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(
                Icons.email, // Icono de correo
                color: Colors.black,
                size: 20,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey),
            ),
          ),
          validator: (valor) {
            if (valor == null || valor.isEmpty) {
              return 'Por favor ingresa $label';
            }

            // Validación completa: debe contener al menos un @ y formato simple de correo
            final regexCorreo = RegExp(r'^[\w\.\-]+@[\w\-]+\.[a-zA-Z]{2,}$');
            if (!regexCorreo.hasMatch(valor)) {
              return 'Ingrese un correo válido con @';
            }

            return null; // válido
          },
        ),
      ],
    );
  }

  // MÉTODO PARA EL CAMPO CONTRASEÑA
  Widget _campoPassword(
    String label, {
    required bool ocultar,
    required VoidCallback onToggle,
    required TextEditingController controller,
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
            FilteringTextInputFormatter.allow(
              RegExp(r'[a-zA-Z0-9@#\$%&*_-]'),
            ),
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
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey), // gris por defecto
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return "La contraseña es obligatoria";
            }
            final regex = RegExp(r'^[a-zA-Z0-9@#\$%&*_-]{6,20}$');
            if (!regex.hasMatch(value)) {
              return "Contraseña inválida. Solo letras, números y @#\$%&*_-";
            }
            return null;
          },
        ),
      ],
    );
  }

}
