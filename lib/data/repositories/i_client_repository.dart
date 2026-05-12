import 'package:coolservice/domain/entidades/cliente.dart';

abstract class IClientRepository {
  Future<void> saveClient(Client client);
  Future<List<Client>> getAllClients();
}
