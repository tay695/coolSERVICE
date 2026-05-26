import 'package:coolservice/core/database/database_helper.dart';
import 'package:coolservice/freatures/servico/data/models/service_model.dart';
import 'package:coolservice/freatures/servico/domain/entidades/service.dart';
import 'package:coolservice/freatures/servico/domain/repositories/i_servico_repository.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteServiceRepository implements IServiceRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> insertService(Service service) async {
    final db = await _dbHelper.database;
    final model = ServiceModel(
      id: service.id,
      name: service.name,
      description: service.description,
      basePrice: service.basePrice,
      tipoAtendimento: service.tipoAtendimento,
      isExternal: service.isExternal,
    );
    await db.insert(
      'services',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Service>> getServices() async {
    final db = await _dbHelper.database;
    final maps = await db.query('services', orderBy: 'name ASC');
    return maps.map((m) => ServiceModel.fromMap(m)).toList();
  }

  @override
  Future<void> updateService(Service service) async {
    final db = await _dbHelper.database;
    final model = ServiceModel(
      id: service.id,
      name: service.name,
      description: service.description,
      basePrice: service.basePrice,
      tipoAtendimento: service.tipoAtendimento,
      isExternal: service.isExternal,
    );
    await db.update(
      'services',
      model.toMap(),
      where: 'id = ?',
      whereArgs: [service.id],
    );
  }

  @override
  Future<void> deleteService(String id) async {
    final db = await _dbHelper.database;
    await db.delete('services', where: 'id = ?', whereArgs: [id]);
  }
}
