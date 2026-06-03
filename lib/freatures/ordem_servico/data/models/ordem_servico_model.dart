import 'package:coolservice/freatures/ordem_servico/domain/entidades/ordem_servico.dart';

class OrdemServicoModel extends OrdemServico {
  OrdemServicoModel({
    required super.id,
    required super.clientId,
    required super.employeeId,
    super.technicianId,
    required super.status,
    required super.tipoAtendimento,
    required super.isExternal,
    super.kmDistance,
    super.serviceBasePrice,
    super.kmFee,
    super.totalValue,
    super.observations,
    super.equipamento,
    super.tipoDefeito,
    super.modeloEquipamento,
    super.metragemAmbiente,
    super.tensaoEletrica,
    super.equipamentoAvaliado,
    super.diagnostico,
    super.solucaoRecomendada,
    required super.isPaid,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'employeeId': employeeId,
      'technicianId': technicianId,
      'status': status.name,
      'tipoAtendimento': tipoAtendimento.name,
      'isExternal': isExternal ? 1 : 0,
      'kmDistance': kmDistance,
      'serviceBasePrice': serviceBasePrice,
      'kmFee': kmFee,
      'totalValue': totalValue,
      'observations': observations,
      'equipamento': equipamento,
      'tipoDefeito': tipoDefeito,
      'modeloEquipamento': modeloEquipamento,
      'metragemAmbiente': metragemAmbiente,
      'tensaoEletrica': tensaoEletrica,
      'equipamentoAvaliado': equipamentoAvaliado,
      'diagnostico': diagnostico,
      'solucaoRecomendada': solucaoRecomendada,
      'isPaid': isPaid ? 1 : 0,
    };
  }

  factory OrdemServicoModel.fromMap(Map<String, dynamic> map) {
    return OrdemServicoModel(
      id: map['id'] ?? '',
      clientId: map['clientId'] ?? '',
      employeeId: map['employeeId'] ?? '',
      technicianId: map['technicianId'],
      status: OrderStatus.values.byName(map['status'] ?? 'open'),
      tipoAtendimento: TipoAtendimento.values.byName(
        map['tipoAtendimento'] ?? 'manutencao',
      ),
      isExternal: map['isExternal'] == 1,
      kmDistance: map['kmDistance'] ?? 0.0,
      serviceBasePrice: map['serviceBasePrice'] ?? 0.0,
      kmFee: map['kmFee'] ?? 0.0,
      totalValue: map['totalValue'] ?? 0.0,
      observations: map['observations'],
      equipamento: map['equipamento'],
      tipoDefeito: map['tipoDefeito'],
      modeloEquipamento: map['modeloEquipamento'],
      metragemAmbiente: map['metragemAmbiente'],
      tensaoEletrica: map['tensaoEletrica'],
      equipamentoAvaliado: map['equipamentoAvaliado'],
      diagnostico: map['diagnostico'],
      solucaoRecomendada: map['solucaoRecomendada'],
      isPaid: map['isPaid'] == 1,
    );
  }
}
