import 'dart:convert';

import 'package:coolservice/freatures/servico/data/models/service_model.dart';
import 'package:coolservice/freatures/servico/domain/entidades/service.dart';
import 'package:coolservice/freatures/servico/domain/repositories/i_servico_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesServiceRepository implements IServiceRepository {
  static const _servicesKey = 'services';

  @override
  Future<void> insertService(Service service) async {
    final services = await getServices();
    final index = services.indexWhere((item) => item.id == service.id);

    if (index >= 0) {
      services[index] = service;
    } else {
      services.add(service);
    }

    await _saveServices(services);
  }

  @override
  Future<List<Service>> getServices() async {
    final prefs = await SharedPreferences.getInstance();
    final encodedServices = prefs.getString(_servicesKey);

    if (encodedServices == null || encodedServices.isEmpty) {
      return [];
    }

    final decodedServices = jsonDecode(encodedServices) as List<dynamic>;
    final services = decodedServices
        .map(
          (item) => ServiceModel.fromMap(
            Map<String, dynamic>.from(item as Map),
          ),
        )
        .toList();

    services.sort((a, b) => a.name.compareTo(b.name));
    return services;
  }

  @override
  Future<void> updateService(Service service) async {
    await insertService(service);
  }

  @override
  Future<void> deleteService(String id) async {
    final services = await getServices();
    services.removeWhere((service) => service.id == id);
    await _saveServices(services);
  }

  Future<void> _saveServices(List<Service> services) async {
    final prefs = await SharedPreferences.getInstance();
    final encodedServices = services
        .map(
          (service) => ServiceModel(
            id: service.id,
            name: service.name,
            description: service.description,
            basePrice: service.basePrice,
            tipoAtendimento: service.tipoAtendimento,
            isExternal: service.isExternal,
          ).toMap(),
        )
        .toList();

    await prefs.setString(_servicesKey, jsonEncode(encodedServices));
  }
}
