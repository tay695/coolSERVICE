import 'package:coolservice/core/app_config/data/preferences_services.dart';
import 'package:coolservice/freatures/ordem_servico/domain/entidades/ordem_servico.dart';
import 'package:coolservice/freatures/ordem_servico/domain/repositories/i_odem_servico_repository.dart';
import 'package:coolservice/freatures/ordem_servico/domain/usecases/calc_km_fee_usecase.dart';
import 'package:flutter/material.dart';

class OrdemServicoViewModel extends ChangeNotifier {
  final IOrdemServicoRepository repository;
  final PreferencesService preferencesService;

  final List<OrdemServico> _ordens = [];
  List<OrdemServico> get ordens => _ordens;

  double _taxaKm = 2.50;
  double get taxaKm => _taxaKm;

  OrdemServicoViewModel({
    required this.repository,
    required this.preferencesService,
  });

  Future<void> updateTaxaKm(double novaTaxa) async {
    _taxaKm = novaTaxa;
    await preferencesService.saveKmFee(novaTaxa);
    notifyListeners();
  }

  Future<void> carregarOrdens() async {
    try {
      final listaDoBanco = await repository.listAll();
      _ordens.clear();
      _ordens.addAll(listaDoBanco);
      notifyListeners();
    } catch (e) {
      print("Erro ao carregar ordens do banco: $e");
    }
  }

  Future<void> salvarOrdem(OrdemServico novaOS, {required bool isPaid}) async {
    try {
      final taxaPorKmDoSharedPreferences = await preferencesService.getKmFee();

      double taxaKmCalculada = 0.0;
      if (novaOS.isExternal) {
        taxaKmCalculada = novaOS.kmDistance * taxaPorKmDoSharedPreferences;
      }

      double valorTotalCalculado = novaOS.serviceBasePrice + taxaKmCalculada;

      final osCompletaComValores = OrdemServico(
        id: novaOS.id,
        clientId: novaOS.clientId,
        employeeId: novaOS.employeeId,
        technicianId: novaOS.technicianId,
        status: novaOS.status,
        tipoAtendimento: novaOS.tipoAtendimento,
        isExternal: novaOS.isExternal,
        kmDistance: novaOS.kmDistance,
        serviceBasePrice: novaOS.serviceBasePrice,
        kmFee: taxaKmCalculada,
        totalValue: valorTotalCalculado,
        observations: novaOS.observations,
        equipamento: novaOS.equipamento,
        tipoDefeito: novaOS.tipoDefeito,
        modeloEquipamento: novaOS.modeloEquipamento,
        metragemAmbiente: novaOS.metragemAmbiente,
        tensaoEletrica: novaOS.tensaoEletrica,
        equipamentoAvaliado: novaOS.equipamentoAvaliado,
        diagnostico: novaOS.diagnostico,
        solucaoRecomendada: novaOS.solucaoRecomendada,
        isPaid: novaOS.isPaid,
      );

      await repository.save(osCompletaComValores);

      _ordens.removeWhere((os) => os.id == osCompletaComValores.id);
      _ordens.add(osCompletaComValores);

      _ordens.sort((a, b) => b.id.compareTo(a.id));

      notifyListeners();
    } catch (e) {
      print("Erro interno ao calcular/salvar OS: $e");
      rethrow;
    }
  }

  Future<void> alternarStatusPagamento(
    OrdemServico osOriginal,
    bool novoStatusPagamento,
  ) async {
    try {
      final osAtualizada = OrdemServico(
        id: osOriginal.id,
        clientId: osOriginal.clientId,
        employeeId: osOriginal.employeeId,
        technicianId: osOriginal.technicianId,
        status: osOriginal.status,
        tipoAtendimento: osOriginal.tipoAtendimento,
        isExternal: osOriginal.isExternal,
        kmDistance: osOriginal.kmDistance,
        serviceBasePrice: osOriginal.serviceBasePrice,
        kmFee: osOriginal.kmFee,
        totalValue: osOriginal.totalValue,
        observations: osOriginal.observations,
        equipamento: osOriginal.equipamento,
        tipoDefeito: osOriginal.tipoDefeito,
        modeloEquipamento: osOriginal.modeloEquipamento,
        metragemAmbiente: osOriginal.metragemAmbiente,
        tensaoEletrica: osOriginal.tensaoEletrica,
        equipamentoAvaliado: osOriginal.equipamentoAvaliado,
        diagnostico: osOriginal.diagnostico,
        solucaoRecomendada: osOriginal.solucaoRecomendada,
        isPaid: novoStatusPagamento,
      );

      await repository.save(osAtualizada);

      _ordens.removeWhere((os) => os.id == osAtualizada.id);
      _ordens.add(osAtualizada);

      _ordens.sort((a, b) => b.id.compareTo(a.id));

      notifyListeners();
    } catch (e) {
      print("Erro ao atualizar pagamento: $e");
      rethrow;
    }
  }

  List<OrdemServico> buscarOrdensDoCliente(String clientId) {
    return _ordens.where((os) => os.clientId == clientId).toList();
  }

  bool clientePossuiPendencia(String clientId) {
    return _ordens.any((os) => os.clientId == clientId && os.isPaid == false);
  }

  double calcularDividaTotalDoCliente(String clientId) {
    final ordensPendentes = _ordens.where(
      (os) => os.clientId == clientId && os.isPaid == false,
    );
    return ordensPendentes.fold(0.0, (total, os) => total + os.totalValue);
  }

  Future<({double distanciaKm, double taxa})> calcularKmParaCliente(
    String enderecoCliente,
    String city,
    String state,
  ) async {
    final useCase = CalcKmFeeUseCase(taxaPorKm: _taxaKm);
    return await useCase.executar(enderecoCliente, city, state);
  }
}
