import 'package:flutter/material.dart';
import 'database_helper.dart'; // Asegúrate de tener tu DatabaseHelper con insertarBoleta
import 'package:flutter/services.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'historial.dart';

class MilesFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Quita puntos
    String cleanText = newValue.text.replaceAll('.', '');

    // Solo números
    if (int.tryParse(cleanText) == null) {
      return oldValue;
    }

    // Formatear con puntos
    String formatted = _formatearMiles(cleanText);

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }

  String _formatearMiles(String value) {
    String resultado = '';
    int contador = 0;

    for (int i = value.length - 1; i >= 0; i--) {
      contador++;
      resultado = value[i] + resultado;
      if (contador == 3 && i != 0) {
        resultado = '.$resultado';
        contador = 0;
      }
    }
    return resultado;
  }
}


class CrearBoletaScreen extends StatefulWidget {
  const CrearBoletaScreen({super.key});

  @override
  State<CrearBoletaScreen> createState() => _CrearBoletaScreenState();
}

class _CrearBoletaScreenState extends State<CrearBoletaScreen> {
  DateTime fechaSeleccionada = DateTime.now();
  String? loteriaSeleccionada;
  String tipoNumeroSeleccionado = '2 cifras';
  List<String> numerosPersonalizados = [];
  final TextEditingController precioController = TextEditingController();
  final TextEditingController ganaController = TextEditingController();
  final TextEditingController numeroController = TextEditingController();
  final TextEditingController telefonoController = TextEditingController();
  bool numeroDuplicado = false;


  final List<String> disenosBoleta = [
    'img/1.png',
    'img/2.png',
    'img/5.png',
  ];

  final List<String> dobleBoleta = [
    'img/doble.png',
  ];

  String tipoBoleta = 'Rifa normal';

  
  String? disenoSeleccionado;
  String? disenodobleSeleccionado;

  List<String> loterias = [
    'Boyacá',
    'Medellín',
    'Valle',
    'Cruz Roja',
    'Cundinamarca',
    'Chontico Día',
    'Chontico Noche',
  ];
  List<String> tiposNumeros = ['2 cifras', '3 cifras', '4 cifras', 'Personalizado'];

  String obtenerTipoJugada(String numero) {
    if (numero.length == 2) {
      return 'ÚLTIMAS DOS CIFRAS';
    } else if (numero.length == 3) {
      return 'ÚLTIMAS TRES CIFRAS';
    } else if (numero.length == 4) {
      return 'CUATRO CIFRAS';
    } else {
      return '';
    }
  }


  @override
  void dispose() {
    precioController.dispose();
    numeroController.dispose();
    super.dispose();
  }

  List<String> generarNumeros({
    required String tipo,
    required List<String> personalizados,
  }) {
    List<String> resultado = [];

    if (tipo == '2 cifras') {
      for (int i = 0; i <= 99; i++) {
        resultado.add(i.toString().padLeft(2, '0'));
      }
    }

    if (tipo == '3 cifras') {
      for (int i = 0; i <= 999; i++) {
        resultado.add(i.toString().padLeft(3, '0'));
      }
    }

    if (tipo == '4 cifras') {
      for (int i = 0; i <= 9999; i++) {
        resultado.add(i.toString().padLeft(4, '0'));
      }
    }

    if (tipo == 'Personalizado') {
      resultado = personalizados;
    }

    return resultado;
  }


  List<String> generarNumerosRifaDoble({
    required String tipo,
  }) {
    List<String> resultado = [];

    int limite;
    int cifras;

    if (tipo == '2 cifras') {
      limite = 99;
      cifras = 2;
    } else if (tipo == '3 cifras') {
      limite = 999;
      cifras = 3;
    } else if (tipo == '4 cifras') {
      limite = 9999;
      cifras = 4;
    } else {
      return resultado;
    }

    for (int i = 0; i <= limite; i++) {
      String numero = i.toString().padLeft(cifras, '0');

      // No empieza ni termina con 0
      if (numero.startsWith('0') || numero.endsWith('0')) continue;

      // No todos los dígitos iguales
      if (numero.split('').toSet().length == 1) continue;

      // No permitir dígitos repetidos consecutivos
      bool tieneDoblesConsecutivos = false;
      for (int j = 0; j < numero.length - 1; j++) {
        if (numero[j] == numero[j + 1]) {
          tieneDoblesConsecutivos = true;
          break;
        }
      }
      if (tieneDoblesConsecutivos) continue;

      resultado.add(numero);
    }

    resultado.shuffle();

    return resultado;
  }

  Future<void> _seleccionarFecha(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: fechaSeleccionada,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('es', 'ES'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF48CB8F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF48CB8F),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        fechaSeleccionada = picked;
      });
    }
  }

  Future<void> _guardarBoleta() async {
    if (loteriaSeleccionada == null || precioController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: const [
              Icon(Icons.error, color: Colors.red, size: 22),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Por favor completa todos los campos',
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

    String numeros = tipoNumeroSeleccionado == 'Personalizado'
        ? numerosPersonalizados.join(',')
        : tipoNumeroSeleccionado; // si no es personalizado guardamos solo el tipo

    final db = DatabaseHelper();
    await db.insertarBoleta(
      fechaSeleccionada.toIso8601String(), // guardamos fecha como string
      numeros,
      double.tryParse(precioController.text) ?? 0,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.check_circle, color: Colors.green, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Boleta registrada exitosamente',
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
    // Limpiar campos
    setState(() {
      numerosPersonalizados.clear();
      precioController.clear();
      loteriaSeleccionada = null;
      tipoNumeroSeleccionado = '2 cifras';
      fechaSeleccionada = DateTime.now();
    });
  }

  Future<void> generarBoletaPDF() async {
    List<String> camposFaltantes = [];

  if (loteriaSeleccionada == null || loteriaSeleccionada!.isEmpty) {
    camposFaltantes.add('Lotería');
  }
  if (precioController.text.trim().isEmpty) {
    camposFaltantes.add('Precio');
  }
  if (ganaController.text.trim().isEmpty) {
    camposFaltantes.add('Gana');
  }
  if (telefonoController.text.trim().isEmpty) {
    camposFaltantes.add('Teléfono');
  }

  if (camposFaltantes.isNotEmpty) {
    // Mostrar SnackBar con los campos faltantes
    final mensaje = 'Por favor completa los siguientes campos:\n' +
        camposFaltantes.join(', ');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                mensaje,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: const Duration(seconds: 4),
      ),
    );

    return; // Salir de la función si falta algún campo
  }
  final pdf = pw.Document();

  // 🔴 VALIDACIONES
  if (tipoBoleta == 'Rifa normal' && disenoSeleccionado == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.error, color: Colors.red, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Por favor, elija un diseño de rifa normal',
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

  if (tipoBoleta == 'Rifa doble' && disenodobleSeleccionado == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: const [
            Icon(Icons.error, color: Colors.red, size: 22),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'Por favor, elija un diseño de rifa doble',
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

  // 🖼️ PLANTILLA
  final plantilla = tipoBoleta == 'Rifa normal'
      ? await imageFromAssetBundle(disenoSeleccionado!)
      : await imageFromAssetBundle(disenodobleSeleccionado!);

  // 🔢 NÚMEROS
  final List<String> numerosGenerados;

  if (tipoBoleta == 'Rifa doble') {
    numerosGenerados = generarNumerosRifaDoble(
      tipo: tipoNumeroSeleccionado,
    );
  } else {
    numerosGenerados = generarNumeros(
      tipo: tipoNumeroSeleccionado,
      personalizados: numerosPersonalizados,
    );
  }

  // 📐 CONFIGURACIÓN
  final double boletaWidth = 75.4 * PdfPageFormat.mm;
  final double boletaHeight = 47.2 * PdfPageFormat.mm;
  final int filas = 5;
  final int columnas = 2;

  final double marginLeft = 50;
  final double marginTop = 50;
  final double spacingX = 5;
  final double spacingY = 5;

  final double pageWidth =
      marginLeft * 2 + (boletaWidth * columnas) + (spacingX * (columnas - 1));
  final double pageHeight =
      marginTop * 2 + (boletaHeight * filas) + (spacingY * (filas - 1));

  // 📄 PÁGINAS
  final int boletasPorPagina = 10;
  final int numerosPorBoleta = tipoBoleta == 'Rifa doble' ? 2 : 1;
  final int numerosPorPagina = boletasPorPagina * numerosPorBoleta;

  for (int pagina = 0;
      pagina * numerosPorPagina < numerosGenerados.length;
      pagina++) {

    final int start = pagina * numerosPorPagina;
    final int end = (start + numerosPorPagina)
        .clamp(0, numerosGenerados.length);

    final List<String> boletasPagina =
        numerosGenerados.sublist(start, end);

    final int totalBoletas =
        boletasPagina.length ~/ numerosPorBoleta;
    String textoArriba(String numero) {
      if (numero.length == 2) return 'DOS CIFRAS';
      if (numero.length == 3) return 'TRES CIFRAS';
      if (numero.length == 4) return 'CIFRAS';
      return '';
    }

    String textoAbajo(String numero) {
      if (numero.length == 2) return 'ÚLTIMAS';
      if (numero.length == 3) return 'ÚLTIMAS';
      if (numero.length == 4) return 'CUATRO';
      return '';
    }

    final bool esPersonalizada =
    tipoBoleta == 'Rifa normal' && numerosPersonalizados.isNotEmpty;
    
    if (tipoBoleta == 'Rifa normal' && numerosPersonalizados.isNotEmpty) {
      const int columnasTabla = 7;

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(30),
          build: (context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'NÚMEROS JUGADOS',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),

                pw.SizedBox(height: 20),

                pw.Table(
                  border: pw.TableBorder.all(),
                  children: List.generate(
                    (numerosPersonalizados.length / columnasTabla).ceil(),
                    (fila) {
                      return pw.TableRow(
                        children: List.generate(columnasTabla, (col) {
                          final index = fila * columnasTabla + col;

                          return pw.Padding(
                            padding: const pw.EdgeInsets.all(8),
                            child: pw.Text(
                              index < numerosPersonalizados.length
                                  ? numerosPersonalizados[index]
                                  : '',
                              textAlign: pw.TextAlign.center,
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                              ),
                            ),
                          );
                        }),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(pageWidth, pageHeight),
        build: (context) {
          return pw.Stack(
            children: [
              for (int i = 0; i < totalBoletas; i++)
                
                pw.Positioned(
                  top: marginTop + (boletaHeight + spacingY) * (i % filas),
                  left: marginLeft + (boletaWidth + spacingX) * (i ~/ filas),
                  child: pw.Stack(
                    children: [
                      // 🖼️ FONDO
                      pw.Image(
                        plantilla,
                        width: boletaWidth,
                        height: boletaHeight,
                        fit: pw.BoxFit.cover,
                      ),

                      // ===============================
                      // 🎯 CONTENIDO
                      // ===============================
                      if (tipoBoleta == 'Rifa normal') ...[
                        // 📅 FECHA
                        // ===== RIFA NORMAL =====
                        pw.Positioned(
                          top: 50,
                          left: 90,
                          child: pw.Text(
                            '${fechaSeleccionada.day.toString().padLeft(2, '0')}/'
                            '${fechaSeleccionada.month.toString().padLeft(2, '0')}/'
                            '${fechaSeleccionada.year}',
                            style: pw.TextStyle(
                              fontSize: 12,
                              color: PdfColor.fromHex('#1800ad'),
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),

                        pw.Positioned(
                          top: 112,
                          left: 112,
                          child: pw.Text(
                            telefonoController.text,
                            style: pw.TextStyle(
                              fontSize: 8,
                              color: PdfColor.fromHex('#1800ad'),
                            ),
                          ),
                        ),

                        pw.Positioned(
                          top: 75,
                          left: 100,
                          child: pw.Text(
                            loteriaSeleccionada ?? '',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#1800ad'),
                            ),
                          ),
                        ),

                        pw.Positioned(
                          top: 88,
                          left: 140,
                          child: pw.Text(
                            boletasPagina[i],
                            style: pw.TextStyle(
                              fontSize: 20,
                              color: PdfColors.black,
                            ),
                          ),
                        ),

                        pw.Positioned(
                          top: 65,
                          left: 12,
                          child: pw.Text(
                            obtenerTipoJugada(boletasPagina[i]),
                            style: pw.TextStyle(
                              fontSize: 9,
                              color: PdfColor.fromHex('#1800ad'),
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),

                        pw.Positioned(
                          top: 90,
                          left: 30,
                          child: pw.Text(
                            precioController.text,
                            style: pw.TextStyle(
                              fontSize: 17,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#e60606'),
                            ),
                          ),
                        ),

                        pw.Positioned(
                          top: 30,
                          left: 108,
                          child: pw.Text(
                            ganaController.text,
                            style: pw.TextStyle(
                              fontSize: 17,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#e60606'),
                            ),
                          ),
                        ),
                      ] else ...[
                        // ===== RIFA DOBLE =====

                        // 📅 FECHA
                        pw.Positioned(
                          top: 41,
                          left: 85,
                          child: pw.Text(
                            '${fechaSeleccionada.day.toString().padLeft(2, '0')}/'
                            '${fechaSeleccionada.month.toString().padLeft(2, '0')}/'
                            '${fechaSeleccionada.year}',
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColor.fromHex('#1800ad'),
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),

                        // ☎️ TELÉFONO
                        pw.Positioned(
                          top: 112,
                          left: 112,
                          child: pw.Text(
                            telefonoController.text,
                            style: pw.TextStyle(
                              fontSize: 7,
                              color: PdfColor.fromHex('#1800ad'),
                            ),
                          ),
                        ),

                        // 🏛️ LOTERÍA
                        pw.Positioned(
                          top: 75,
                          left: 90,
                          child: pw.Text(
                            loteriaSeleccionada ?? '',
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#e60606'),
                            ),
                          ),
                        ),

                        // 🔢 NÚMERO 1
                        pw.Positioned(
                          top: 88,
                          left: 107,
                          child: pw.Text(
                            boletasPagina[i * 2],
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                        ),

                        // 🔢 NÚMERO 2
                        pw.Positioned(
                          top: 88,
                          left: 162,
                          child: pw.Text(
                            boletasPagina[i * 2 + 1],
                            style: pw.TextStyle(
                              fontSize: 18,
                              fontWeight: pw.FontWeight.normal,
                            ),
                          ),
                        ),

                        // 💰 PRECIO
                        pw.Positioned(
                          top: 88,
                          left: 32,
                          child: pw.Text(
                            precioController.text,
                            style: pw.TextStyle(fontSize: 15,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#e60606'),),
                            
                          ),
                        ),

                        // 🏆 GANA
                        pw.Positioned(
                          top: 17,
                          left: 80,
                          child: pw.Text(
                            ganaController.text,
                            style: pw.TextStyle(
                              fontSize: 20,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColor.fromHex('#e60606'),
                            ),
                          ),
                        ),

                        pw.Positioned(
                          top: 63,
                          left: 35,
                          child: pw.Text(
                            textoArriba(boletasPagina[i]),
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColor.fromHex('#1800ad'),
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),

                        pw.Positioned(
                          top: 50,
                          left: 157,
                          child: pw.Text(
                            textoAbajo(boletasPagina[i]),
                            style: pw.TextStyle(
                              fontSize: 10,
                              color: PdfColor.fromHex('#1800ad'),
                              fontWeight: pw.FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // 🖨️ IMPRIMIR
  await Printing.layoutPdf(
    onLayout: (format) async => pdf.save(),
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
          onPressed: () {
            // Navegar a la pantalla de historial
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const HistorialBoletasPage(),
              ),
            );
          },
        ),
      ],
    ),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// ===== FECHA =====
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // FECHA
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fecha',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: () => _seleccionarFecha(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: Colors.black54),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_month, color: Colors.black),
                            const SizedBox(width: 10),
                            Text(
                              '${fechaSeleccionada.year}-${fechaSeleccionada.month.toString().padLeft(2, '0')}-${fechaSeleccionada.day.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 16), // espacio entre ambos

              // TELÉFONO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Teléfono',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: telefonoController,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        hintText: 'Ej: 3001234567',
                        prefixIcon: const Icon(Icons.phone, color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),


          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tipo de boleta',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),

              DropdownButtonFormField<String>(
                value: tipoBoleta,
                items: const [
                  DropdownMenuItem(
                    value: 'Rifa normal',
                    child: Text('Rifa normal'),
                  ),
                  DropdownMenuItem(
                    value: 'Rifa doble',
                    child: Text('Rifa doble'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    tipoBoleta = value!;
                    disenoSeleccionado = null;
                    disenodobleSeleccionado = null;
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: const Icon(
                    Icons.confirmation_number_outlined,
                    color: Colors.black,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.black54),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.black),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dropdown Lotería
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Lotería',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: loteriaSeleccionada,
                    hint: const Text('Selecciona la lotería'),
                    items: loterias.map((l) {
                      return DropdownMenuItem(
                        value: l,
                        child: Row(
                          children: [
                            const Icon(Icons.casino, size: 18, color: Colors.black),
                            const SizedBox(width: 8),
                            Text(l),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => loteriaSeleccionada = val),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.black54),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16), // espacio entre los dropdowns
              // Dropdown Tipo de números
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tipo de números',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    value: tipoNumeroSeleccionado,
                    items: tiposNumeros.map((t) {
                      return DropdownMenuItem(
                        value: t,
                        child: Row(
                          children: [
                            const Icon(Icons.confirmation_number, size: 18, color: Colors.black),
                            const SizedBox(width: 8),
                            Text(t),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (val) {
                      setState(() {
                        tipoNumeroSeleccionado = val!;
                        numerosPersonalizados.clear();
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.black54),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: const BorderSide(color: Colors.black54),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          /// ===== NÚMEROS PERSONALIZADOS =====
          if (tipoNumeroSeleccionado == 'Personalizado') ...[
            const Text(
              'Números personalizados',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: numeroController,
                    keyboardType: TextInputType.multiline,
                    textInputAction: TextInputAction.newline,
                    maxLines: 4,
                    inputFormatters: [CuatroDigitosPorLineaFormatter()],
                    onChanged: (_) {
                      if (numeroDuplicado) {
                        setState(() {
                          numeroDuplicado = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Ej:\n1234\n5678\n9012',
                      prefixIcon: const Icon(Icons.grid_view, color: Colors.black),
                      filled: true,
                      fillColor: Colors.white,
                      errorText: numeroDuplicado ? 'Número repetido' : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  )

                ),

                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed: () {
                  final texto = numeroController.text.trim();
                  if (texto.isEmpty) return;

                  final nuevos = texto
                      .split('\n')
                      .map((e) => e.trim())
                      .where((e) => e.isNotEmpty)
                      .toList();

                  bool hayDuplicado = false;

                  for (final n in nuevos) {
                    if (numerosPersonalizados.contains(n)) {
                      hayDuplicado = true;
                      break;
                    }
                  }

                  setState(() {
                    if (hayDuplicado) {
                      numeroDuplicado = true;
                    } else {
                      numeroDuplicado = false;
                      for (final n in nuevos) {
                        numerosPersonalizados.add(n);
                      }
                      numeroController.clear();
                    }
                  });
                },
                  icon: const Icon(Icons.add, color: Colors.white),
                  label: const Text(
                    'Agregar',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF48CB8F),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: numerosPersonalizados.map((n) {
                return Chip(
                  label: Text(
                    n,
                    style: const TextStyle(color: Colors.black),
                  ),
                  avatar: const Icon(Icons.confirmation_number,
                      size: 16, color: Colors.black),
                  backgroundColor: Colors.white,
                  shape: const StadiumBorder(
                    side: BorderSide(color: Colors.black54),
                  ),
                  deleteIcon:
                      const Icon(Icons.close, color: Colors.black),
                  onDeleted: () {
                    setState(() {
                      numerosPersonalizados.remove(n);
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
          ],

          /// ===== PRECIO =====
          Row(
            children: [
              // Campo Precio
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Precio',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: precioController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        MilesFormatter(), // tu formatter
                      ],
                      decoration: InputDecoration(
                        hintText: 'ej: 2.000',
                        prefixIcon: const Icon(Icons.attach_money, color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16), // espacio entre campos
              // Campo Gana
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Gana',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 6),
                    TextField(
                      controller: ganaController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        MilesFormatter(), // aplica puntos de miles
                      ],
                      decoration: InputDecoration(
                        hintText: 'ej: 1.500',
                        prefixIcon: const Icon(Icons.attach_money, color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(color: Colors.black54),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Text(
            'Elige tu diseño',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),

          const SizedBox(height: 10),

          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: tipoBoleta == 'Rifa normal'
                ? disenosBoleta.length
                : dobleBoleta.length,
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 220,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.4,
            ),
            itemBuilder: (context, index) {
              if (tipoBoleta == 'Rifa normal') {
                final diseno = disenosBoleta[index];
                final seleccionado = disenoSeleccionado == diseno;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      disenoSeleccionado = diseno;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: seleccionado
                            ? const Color(0xFF48CB8F)
                            : Colors.black26,
                        width: seleccionado ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        diseno,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              } else {
                // RIFA DOBLE
                final diseno = dobleBoleta[index];
                final seleccionado = disenodobleSeleccionado == diseno;

                return GestureDetector(
                  onTap: () {
                    setState(() {
                      disenodobleSeleccionado = diseno;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: seleccionado
                            ? const Color(0xFF48CB8F)
                            : Colors.black26,
                        width: seleccionado ? 2 : 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        diseno,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              }
            },
          ),
          const SizedBox(height: 10),

          /// ===== BOTÓN GUARDAR =====
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () async {
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
                  
                  await generarBoletaPDF();

                  // 2️⃣ Verificar si hay números personalizados para guardar en la DB
                  if (numerosPersonalizados.isNotEmpty) {
                    final db = DatabaseHelper();

                    // Fecha de hoy
                    String fechaHoy = DateTime.now().toIso8601String();

                    // Precio (puedes calcularlo o definirlo)
                    String texto = precioController.text.replaceAll('.', '').replaceAll(',', '');
                    double precio = double.tryParse(texto) ?? 0;

                    // Guardar en la base de datos
                    await db.insertarBoleta(
                      fechaHoy,
                      numerosPersonalizados.join(', '),
                      precio,
                    );

                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.green, size: 22),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Boleta guardada y PDF generado',
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

                    // Limpiar lista si quieres
                    numerosPersonalizados.clear();
                    setState(() {});
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: const [
                            Icon(Icons.check_circle, color: Colors.green, size: 22),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'PDF generado',
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
                  }
                } catch (e) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Row(
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 22),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Error: $e',
                              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
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
                Icons.picture_as_pdf, // ícono más representativo de PDF
                color: Colors.white,
                size: 24,
              ),
              label: const Text(
                'Generar PDF',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF48CB8F), // azul más moderno
                elevation: 5, // sombra
                shadowColor: Colors.black45,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20), // más redondeado
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    ),
  );
}

}

class CuatroDigitosPorLineaFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Quitar todo lo que no sea número
    final soloNumeros = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    final buffer = StringBuffer();
    for (int i = 0; i < soloNumeros.length; i++) {
      buffer.write(soloNumeros[i]);
      if ((i + 1) % 4 == 0 && i + 1 != soloNumeros.length) {
        buffer.write('\n');
      }
    }

    final textoFinal = buffer.toString();

    return TextEditingValue(
      text: textoFinal,
      selection: TextSelection.collapsed(offset: textoFinal.length),
    );
  }
}