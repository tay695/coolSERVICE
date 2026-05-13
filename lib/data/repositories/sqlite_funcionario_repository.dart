import 'package:coolservice/data/database_helper.dart';
import 'package:coolservice/data/models/funcionarios_model.dart';
import 'package:coolservice/data/repositories/i_funcionario_repository.dart';
import 'package:coolservice/domain/entidades/funcionarios.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteFuncionarioRepository implements IFuncionarioRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> save(Funcionario funcionario) async {
    final db = await _dbHelper.database;

    // converte  Entidade recebida em Model para usar o toMap
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
      'employees', // Nome da tabela  definido no DatabaseHelper
      model.toMap(),
      conflictAlgorithm:
          ConflictAlgorithm.replace, // Se o ID existir, ele atualiza
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
}
