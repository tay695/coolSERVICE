import 'package:coolservice/data/database_helper.dart';
import 'package:coolservice/data/models/cliente_model.dart';
import 'package:coolservice/domain/entidades/cliente.dart';
import 'package:coolservice/data/repositories/i_client_repository.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteClientRepository implements IClientRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> saveClient(Client client) async {
    final db = await _dbHelper.database;

    final clientModel = ClientModel(
      id: client.id,
      name: client.name,
      cpfCnpj: client.cpfCnpj,
      address: client.address,
      phone: client.phone,
      email: client.email,
    );

    await db.insert(
      'clients',
      clientModel.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Client>> getAllClients() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('clients');

    return List.generate(maps.length, (i) {
      return ClientModel.fromMap(maps[i]);
    });
  }
}
