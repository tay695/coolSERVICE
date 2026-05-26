import 'package:coolservice/freatures/servico/domain/entidades/service.dart';
import 'package:coolservice/freatures/servico/domain/repositories/i_servico_repository.dart';
import 'package:flutter/material.dart';

class ServiceViewModel extends ChangeNotifier {
  final IServiceRepository _repository;

  ServiceViewModel(this._repository);

  List<Service> _services = [];
  List<Service> get services => _services;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _services = await _repository.getServices();
    } catch (e) {
      debugPrint('Erro ao carregar serviços: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createService(Service service) async {
    await _repository.insertService(service);
    await loadServices();
  }

  Future<void> updateService(Service service) async {
    await _repository.updateService(service);
    await loadServices();
  }

  Future<void> deleteService(String id) async {
    await _repository.deleteService(id);
    await loadServices();
  }
}
