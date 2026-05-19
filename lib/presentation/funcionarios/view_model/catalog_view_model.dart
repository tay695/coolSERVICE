import 'package:coolservice/data/repositories/i_service_repository.dart';
import 'package:coolservice/domain/entidades/service.dart';
import 'package:flutter/material.dart';

class CatalogViewModel extends ChangeNotifier {
  final IServiceRepository _repository;

  CatalogViewModel(this._repository);

  List<Service> _services = [];
  List<Service> get services => _services;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadServices() async {
    _isLoading = true;
    notifyListeners();
    _services = await _repository.getServices();
    _isLoading = false;
    notifyListeners();
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