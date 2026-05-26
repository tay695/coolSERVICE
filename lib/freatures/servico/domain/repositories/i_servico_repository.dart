import 'dart:developer';

abstract class IServiceRepository {
  Future<void> insertService(Service service);
  Future<List<Service>> getServices();
  Future<void> updateService(Service service);
  Future<void> deleteService(String id);
}
