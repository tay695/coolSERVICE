import 'package:coolservice/freatures/clientes/domain/entidades/cliente.dart';

abstract class IClientRepository {
  Future<void> saveClient(Client client);
  Future<List<Client>> getAllClients();
}
