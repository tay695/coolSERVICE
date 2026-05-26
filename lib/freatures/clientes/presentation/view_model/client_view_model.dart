import 'package:coolservice/freatures/clientes/domain/entidades/cliente.dart';
import 'package:coolservice/freatures/clientes/domain/repositories/i_client_repository.dart';
import 'package:flutter/material.dart';

class ClientViewModel extends ChangeNotifier {
  // regra aplicada antes da interface
  final IClientRepository _repository;

  List<Client> _clients = [];
  List<Client> get clients => _clients;

  ClientViewModel(this._repository);
  Future<void> createClient(Client client) async {
    try {
      await _repository.saveClient(client);
      await listAll();
    } catch (e) {
      debugPrint("Erro ao criar cliente: $e");
    }
  }

  Future<void> updateClient(Client client) async {
    try {
      await _repository.saveClient(client);
      await listAll();
    } catch (e) {
      debugPrint("Erro ao atualizar cliente: $e");
    }
  }

  void searchClient(String query) {
    if (query.isEmpty) {
      listAll();
    } else {
      _clients = _clients
          .where(
            (c) =>
                c.name.toLowerCase().contains(query.toLowerCase()) ||
                c.cpfCnpj.contains(query) ||
                c.phone.contains(query),
          )
          .toList();
      notifyListeners();
    }
  }

  Future<void> listAll() async {
    _clients = await _repository.getAllClients();
    notifyListeners();
  }
}
