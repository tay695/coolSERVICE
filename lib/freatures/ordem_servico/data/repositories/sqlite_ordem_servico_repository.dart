import 'package:coolservice/core/database/database_helper.dart';
import 'package:coolservice/freatures/ordem_servico/data/models/ordem_servico_model.dart';
import 'package:coolservice/freatures/ordem_servico/domain/entidades/ordem_servico.dart';
import 'package:coolservice/freatures/ordem_servico/domain/repositories/i_odem_servico_repository.dart';
import 'package:sqflite/sqflite.dart';

class SQLiteOrdemServicoRepository implements IOrdemServicoRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  @override
  Future<void> save(OrdemServico ordem) async {
    final db = await _dbHelper.database;

    // Converte a Entidade em Model para usar o toMap()
    final model = OrdemServicoModel(
      id: ordem.id,
      clientId: ordem.clientId,
      employeeId: ordem.employeeId,
      technicianId: ordem.technicianId,
      status: ordem.status,
      tipoAtendimento: ordem.tipoAtendimento,
      isExternal: ordem.isExternal,
      kmDistance: ordem.kmDistance,
      serviceBasePrice: ordem.serviceBasePrice,
      kmFee: ordem.kmFee,
      totalValue: ordem.totalValue,
      observations: ordem.observations,
      equipamento: ordem.equipamento,
      tipoDefeito: ordem.tipoDefeito,
      modeloEquipamento: ordem.modeloEquipamento,
      metragemAmbiente: ordem.metragemAmbiente,
      tensaoEletrica: ordem.tensaoEletrica,
      equipamentoAvaliado: ordem.equipamentoAvaliado,
      diagnostico: ordem.diagnostico,
      solucaoRecomendada: ordem.solucaoRecomendada,
    );

    // Se o ID já existir, atualiza. Se não, insere novo.
    await db.insert(
      'service_orders',
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<OrdemServico>> listAll() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('service_orders');

    // Transforma cada linha do banco em um objeto OrdemServico
    return List.generate(maps.length, (i) {
      return OrdemServicoModel.fromMap(maps[i]);
    });
  }

  @override
  Future<void> delete(String id) async {
    final db = await _dbHelper.database;
    await db.delete('service_orders', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<List<OrdemServico>> listByClient(String clientId) async {
    final db = await _dbHelper.database;

    // Busca só as ordens daquele cliente específico
    final List<Map<String, dynamic>> maps = await db.query(
      'service_orders',
      where: 'clientId = ?',
      whereArgs: [clientId],
    );

    return List.generate(maps.length, (i) {
      return OrdemServicoModel.fromMap(maps[i]);
    });
  }
}
