import 'package:coolservice/core/app_config/data/preferences_services.dart';
import 'package:coolservice/freatures/ordem_servico/domain/entidades/ordem_servico.dart';
import 'package:coolservice/freatures/ordem_servico/domain/repositories/i_odem_servico_repository.dart';
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

  Future<void> salvarOrdem(OrdemServico novaOS) async {
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
      );

      await repository.save(osCompletaComValores);

      _ordens.add(osCompletaComValores);
      notifyListeners();
    } catch (e) {
      print("Erro interno ao calcular/salvar OS: $e");
      rethrow;
    }
  }
}
