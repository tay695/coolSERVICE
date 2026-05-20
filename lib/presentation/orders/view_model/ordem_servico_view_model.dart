import 'package:coolservice/data/repositories/i_ordem_servico_repository.dart';
import 'package:coolservice/domain/entidades/ordem_servico.dart';
import 'package:flutter/material.dart';

class OrdemServicoViewModel extends ChangeNotifier {
  final IOrdemServicoRepository _repository;

  List<OrdemServico> _ordens = [];
  List<OrdemServico> get ordens => _ordens;

  OrdemServicoViewModel(this._repository);

  Future<void> createOrdem(OrdemServico ordem) async {
    await _repository.save(ordem);
    await listAll();
  }

  Future<void> updateOrdem(OrdemServico ordem) async {
    await _repository.save(ordem);
    await listAll();
  }

  Future<void> deleteOrdem(String id) async {
    await _repository.delete(id);
    await listAll();
  }

  void filterByStatus(OrderStatus status) {
    _ordens = _ordens.where((o) => o.status == status).toList();
    notifyListeners();
  }

  Future<void> listAll() async {
    _ordens = await _repository.listAll();
    notifyListeners();
  }
}