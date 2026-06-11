import 'package:coolservice/core/app_config/data/preferences_services.dart';
import 'package:coolservice/freatures/ordem_servico/domain/entidades/ordem_servico.dart';
import 'package:coolservice/freatures/ordem_servico/domain/repositories/i_odem_servico_repository.dart';
import 'package:coolservice/freatures/ordem_servico/domain/usecases/calc_km_fee_usecase.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coolservice/core/services/notification_service.dart';

class OrdemServicoViewModel extends ChangeNotifier {
  final IOrdemServicoRepository repository;
  final PreferencesService preferencesService;
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  Future<void> _ensureFirebaseAuth() async {}

  Future<void> carregarOrdens() async {
    try {
      // carrega local primeiro
      final listaDoBanco = await repository.listAll();
      _ordens.clear();
      _ordens.addAll(listaDoBanco);
      notifyListeners();

      //sincroniza com Firestore
      await _ensureFirebaseAuth();
      final snapshot = await FirebaseFirestore.instance
          .collection('ordens_servico')
          .orderBy('criadoEm', descending: true)
          .get();
      print('Firestore retornou: ${snapshot.docs.length} ordens'); // ← AQUI

      if (snapshot.docs.isEmpty) return;

      if (snapshot.docs.isEmpty) return;

      final ordensFirestore = snapshot.docs.map((doc) {
        final d = doc.data();
        return OrdemServico(
          id: d['id'],
          clientId: d['clientId'],
          employeeId: d['employeeId'],
          technicianId: d['technicianId'],
          status: _parseStatus(d['status']),
          tipoAtendimento: TipoAtendimento.values.firstWhere(
            (t) => t.name == d['tipoAtendimento'],
            orElse: () => TipoAtendimento.manutencao,
          ),
          isExternal: d['isExternal'] ?? false,
          kmDistance: (d['kmDistance'] ?? 0).toDouble(),
          serviceBasePrice: (d['serviceBasePrice'] ?? 0).toDouble(),
          kmFee: (d['kmFee'] ?? 0).toDouble(),
          totalValue: (d['totalValue'] ?? 0).toDouble(),
          observations: d['observations'],
          isPaid: d['isPaid'] ?? false,
        );
      }).toList();
      print('OS carregada: ${ordensFirestore.length}');

      for (final os in ordensFirestore) {
        await repository.save(os);
      }

      _ordens.clear();
      _ordens.addAll(ordensFirestore);
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar ordens: $e');
    }
  }

  OrderStatus _parseStatus(String? value) {
    switch (value) {
      case 'completed':
        return OrderStatus.completo;
      case 'completo':
        return OrderStatus.completo;
      case 'encaminhada':
        return OrderStatus.encaminhada;
      case 'inProgress':
        return OrderStatus.encaminhada;
      case 'pedentes':
        return OrderStatus.pedentes;
      case 'paymentPending':
        return OrderStatus.pedentes;
      case 'cancelados':
        return OrderStatus.cancelados;
      case 'cancelled':
        return OrderStatus.cancelados;
      case 'open':
        return OrderStatus.aberto;
      case 'aberto':
        return OrderStatus.aberto;
      default:
        return OrderStatus.aberto;
    }
  }

  Future<void> carregarOrdensPorFuncionario(
    String funcionarioId, {
    bool isAdmin = false,
  }) async {
    try {
      _ordens.clear();
      notifyListeners();
      await _ensureFirebaseAuth();

      Query query = FirebaseFirestore.instance
          .collection('ordens_servico')
          .orderBy('criadoEm', descending: true);

      if (!isAdmin) {
        query = query.where('employeeId', isEqualTo: funcionarioId);
      }

      final snapshot = await query.get();
      print('funcionarioId buscado: $funcionarioId');
      print('docs encontrados: ${snapshot.docs.length}');
      if (snapshot.docs.isEmpty) return;

      final ordensFirestore = snapshot.docs.map((doc) {
        final d = doc.data() as Map<String, dynamic>;
        return OrdemServico(
          id: d['id'],
          clientId: d['clientId'],
          employeeId: d['employeeId'],
          technicianId: d['technicianId'],
          status: _parseStatus(d['status']),
          tipoAtendimento: TipoAtendimento.values.firstWhere(
            (t) => t.name == d['tipoAtendimento'],
            orElse: () => TipoAtendimento.manutencao,
          ),
          isExternal: d['isExternal'] ?? false,
          kmDistance: (d['kmDistance'] ?? 0).toDouble(),
          serviceBasePrice: (d['serviceBasePrice'] ?? 0).toDouble(),
          kmFee: (d['kmFee'] ?? 0).toDouble(),
          totalValue: (d['totalValue'] ?? 0).toDouble(),
          observations: d['observations'],
          isPaid: d['isPaid'] ?? false,
        );
      }).toList();

      _ordens.clear();
      _ordens.addAll(ordensFirestore);
      notifyListeners();
    } catch (e) {
      print('Erro ao carregar ordens por funcionário: $e');
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
        inData: novaOS.inData,
        outData: novaOS.outData,
        isPaid: novaOS.isPaid,
      );

      await repository.save(osCompletaComValores);
      // Salva no Firestore
      try {
        await FirebaseFirestore.instance
            .collection('ordens_servico')
            .doc(osCompletaComValores.id)
            .set({
              'id': osCompletaComValores.id,
              'clientId': osCompletaComValores.clientId,
              'employeeId': osCompletaComValores.employeeId,
              'technicianId': osCompletaComValores.technicianId,
              'status': osCompletaComValores.status.name,
              'tipoAtendimento': osCompletaComValores.tipoAtendimento.name,
              'isExternal': osCompletaComValores.isExternal,
              'kmDistance': osCompletaComValores.kmDistance,
              'serviceBasePrice': osCompletaComValores.serviceBasePrice,
              'kmFee': osCompletaComValores.kmFee,
              'totalValue': osCompletaComValores.totalValue,
              'observations': osCompletaComValores.observations,
              'inData': osCompletaComValores.inData,
              'outData': osCompletaComValores.outData,
              'criadoEm': FieldValue.serverTimestamp(),
            });
      } catch (e) {
        print('Erro ao salvar OS no Firestore: $e');
      }
      try {
        final funcionarioDoc = await FirebaseFirestore.instance
            .collection('funcionarios')
            .where('id', isEqualTo: osCompletaComValores.employeeId)
            .limit(1)
            .get();

        if (funcionarioDoc.docs.isNotEmpty) {
          final fcmToken = funcionarioDoc.docs.first.data()['fcmToken'];
          if (fcmToken != null) {
            await NotificationService.sendNotification(
              token: fcmToken,
              title: 'Nova Ordem de Serviço',
              body: 'Você foi alocado em uma nova OS.',
            );
          }
        }
      } catch (e) {
        print('Erro ao enviar notificação: $e');
      }

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
        inData: osOriginal.inData,
        outData: osOriginal.outData,
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
