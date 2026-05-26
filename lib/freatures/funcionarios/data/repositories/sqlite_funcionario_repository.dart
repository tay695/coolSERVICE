import 'package:coolservice/core/database/database_helper.dart';
import 'package:coolservice/freatures/funcionarios/data/models/funcionarios_model.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/freatures/funcionarios/domain/repositories/i_funcionario_repository.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteFuncionarioRepository implements IFuncionarioRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> save(Funcionario funcionario) async {
    final db = await _dbHelper.database;

    final model = FuncionarioModel(
      id: funcionario.id,
      name: funcionario.name,
      cpf: funcionario.cpf,
      especialty: funcionario.especialty,
      phone: funcionario.phone,
      role: funcionario.role,
      isActive: funcionario.isActive,
    );

    await db.insert(
      'employees',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<Funcionario>> listAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('employees');

    return List.generate(maps.length, (i) {
      return FuncionarioModel.fromMap(maps[i]);
    });
  }

  @override
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('employees', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> toggleActive(String id, bool isActive) async {
    final db = await _dbHelper.database;
    await db.update(
      'employees',
      {'isActive': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
