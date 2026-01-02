import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseHelper {
  // Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  // Obtener la base de datos
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  // Inicializar base de datos
  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'app_local.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  // Crear tablas
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE usuario(
        id_usuario INTEGER PRIMARY KEY AUTOINCREMENT,
        correo TEXT NOT NULL,
        contrasena TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE boleta(
        id_boleta INTEGER PRIMARY KEY AUTOINCREMENT,
        fecha TEXT NOT NULL,
        numeros VARCHAR(500),
        precio REAL
      )
    ''');
  }

  // Insertar usuario
  Future<bool> insertarUsuario(String correo, String contrasena) async {
    final db = await database;
    try {
      await db.insert(
        'usuario',
        {'correo': correo, 'contrasena': contrasena},
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Guardar sesión
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('logueado', true);
      await prefs.setString('correo', correo);

      return true;
    } catch (e) {
      return false;
    }
  }

  // Insertar boleta
  Future<int> insertarBoleta(String fecha, String numeros, double precio) async {
    final db = await database;
    return await db.insert(
      'boleta',
      {
        'fecha': fecha,
        'numeros': numeros,
        'precio': precio,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> cerrarSesion() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
  // Verificar si el usuario existe
  Future<bool> usuarioExiste(String correo, String contrasena) async {
    final db = await database;
    final result = await db.query(
      'usuario',
      where: 'correo = ? AND contrasena = ?',
      whereArgs: [correo, contrasena],
    );
    return result.isNotEmpty;
  }
}
