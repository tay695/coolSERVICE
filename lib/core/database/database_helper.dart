import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('coolservice.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 3,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onOpen: _ensureDB,
    );
    //se houver alguma mudança no banco é só aumentar o número da version no openDatabase.
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE clients (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        cpf_cnpj TEXT NOT NULL,
        address TEXT NOT NULL,
        city TEXT NOT NULL,
        state TEXT NOT NULL,
        phone TEXT NOT NULL,
        email TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE employees (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        cpf TEXT NOT NULL,
        especialty TEXT NOT NULL,
        phone TEXT NOT NULL,
        role TEXT NOT NULL,
        isActive INTEGER DEFAULT 1,
        username TEXT UNIQUE NOT NULL,
        password_hash TEXT NOT NULL
      )
    ''');

    await db.execute('''
    CREATE TABLE service_orders (
      id TEXT PRIMARY KEY,
      clientId TEXT NOT NULL,
      employeeId TEXT NOT NULL,
      technicianId TEXT,
      status TEXT NOT NULL, 
      tipoAtendimento TEXT NOT NULL,
      isExternal INTEGER NOT NULL DEFAULT 0,
      kmDistance REAL DEFAULT 0.0,
      serviceBasePrice REAL DEFAULT 0.0,
      kmFee REAL DEFAULT 0.0,
      totalValue REAL DEFAULT 0.0,
      observations TEXT,
      equipamento TEXT,
      tipoDefeito TEXT,
      modeloEquipamento TEXT,
      metragemAmbiente TEXT,
      tensaoEletrica TEXT,
      equipamentoAvaliado TEXT,
      diagnostico TEXT,
      isPaid BOOLEAN ,
      solucaoRecomendada TEXT,
      FOREIGN KEY (clientId) REFERENCES clients (id) ON DELETE CASCADE,
      FOREIGN KEY (employeeId) REFERENCES employees (id) ON DELETE SET NULL
    )
  ''');

    await _createServicesTable(db);
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createServicesTable(db);
    }
  }

  Future<void> _ensureDB(Database db) async {
    await _createServicesTable(db);
  }

  Future<void> _createServicesTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS services (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT NOT NULL,
        basePrice REAL NOT NULL,
        tipoAtendimento TEXT NOT NULL,
        isExternal INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }
}
