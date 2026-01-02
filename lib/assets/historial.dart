import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'database_helper.dart'; // tu DatabaseHelper
import 'package:intl/intl.dart';

class HistorialBoletasPage extends StatefulWidget {
  const HistorialBoletasPage({super.key});

  @override
  State<HistorialBoletasPage> createState() => _HistorialBoletasPageState();
}

class _HistorialBoletasPageState extends State<HistorialBoletasPage> {
  final db = DatabaseHelper();
  List<Map<String, dynamic>> boletas = [];

  @override
  void initState() {
    super.initState();
    _cargarBoletas();
  }

  // Consulta los números guardados en la tabla 'boleta'
  Future<void> _cargarBoletas() async {
    final database = await db.database;
    final result = await database.query(
      'boleta',
      orderBy: 'id_boleta DESC',
    );

    setState(() {
      boletas = result;
    });
  }

  // Copiar números al portapapeles
  void _copiarNumeros(String numeros) {
    final textoEnLista = numeros
      .split(',')
      .map((n) => n.trim())
      .join('\n');

    Clipboard.setData(ClipboardData(text: textoEnLista));

    // Mostrar SnackBar personalizado
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Números copiados al portapapeles',
                style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating, // flota sobre la UI
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF48CB8F),
        centerTitle: true,
        elevation: 2,
        title: const Text(
          'Boletazo',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {},
          ),
        ],
      ),
      body: boletas.isEmpty
          ? const Center(child: Text('No hay boletas guardadas'))
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: boletas.length,
              itemBuilder: (context, index) {
                final boleta = boletas[index];
                String fechaString = boleta['fecha'];
                DateTime fecha = DateTime.parse(fechaString);

                // Formato bonito, ejemplo: 30/12/2025
                String fechaFormateada = DateFormat('dd/MM/yyyy').format(fecha);

                // Otra opción: 30 dic 2025
                String fechaFormateada2 = DateFormat('d MMM yyyy', 'es_ES').format(fecha);

                double precio = boleta['precio'];

                // Formato con miles y sin decimales
                final formatter = NumberFormat('#,###', 'es_CO'); // 'es_CO' para usar coma o punto según convención
                String precioFormateado = formatter.format(precio);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  color: Colors.white, // fondo blanco
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Fecha con ícono
                        Row(
                          children: [
                            const Icon(Icons.calendar_today, size: 18, color: Colors.grey),
                            const SizedBox(width: 8),
                            Text(
                              'Fecha: $fechaFormateada',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Números con botón copiar
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  boleta['numeros'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: () => _copiarNumeros(boleta['numeros']),
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF48CB8F), // azul bonito
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.copy,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // Precio
                        Row(
                          children: [
                            const Icon(Icons.monetization_on, size: 18, color: Colors.grey),
                            const SizedBox(width: 6),
                            Text(
                              'Precio: \$${precioFormateado}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

              },
            ),
    );
  }
}
