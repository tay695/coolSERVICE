import 'package:coolservice/domain/entidades/service.dart';

abstract class IServiceRepository {
  Future<void> insertService(Service service);
  Future<List<Service>> getServices();
  Future<void> updateService(Service service);
  Future<void> deleteService(String id);
}