enum OrderStatus { aberto, encaminhada, completo, pedentes, cancelados }

enum TipoAtendimento { manutencao, instalacao, visitaTecnica }

class OrdemServico {
  final String id;
  final String clientId;
  final String employeeId;
  final String? technicianId;
  final OrderStatus status;
  final TipoAtendimento tipoAtendimento;
  final bool isExternal;
  final double kmDistance;
  final double serviceBasePrice;
  final double kmFee;
  final double totalValue;
  final String? observations;
  final bool isPaid;
  final DateTime? dataCriacao;
  final DateTime? dataConclusao;
  //campos de Manutenção
  final String? equipamento;
  final String? tipoDefeito;
  //campos de Instalação
  final String? modeloEquipamento;
  final String? metragemAmbiente;
  final String? tensaoEletrica;
  // campos de Visita Técnica
  final String? equipamentoAvaliado;
  final String? diagnostico;
  final String? solucaoRecomendada;

  OrdemServico({
    required this.status,
    this.isPaid = false,
    required this.id,
    required this.clientId,
    required this.employeeId,
    this.technicianId,
    required this.tipoAtendimento,
    required this.isExternal,
    this.kmDistance = 0.0,
    this.serviceBasePrice = 0.0,
    this.kmFee = 0.0,
    this.totalValue = 0.0,
    this.observations,
    this.equipamento,
    this.tipoDefeito,
    this.modeloEquipamento,
    this.metragemAmbiente,
    this.tensaoEletrica,
    this.equipamentoAvaliado,
    this.diagnostico,
    this.solucaoRecomendada,
    this.dataConclusao,
    this.dataCriacao,
  });

  double calculateTotal() {
    return serviceBasePrice + kmFee;
  }
}
