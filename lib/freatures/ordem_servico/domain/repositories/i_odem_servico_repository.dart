import 'package:coolservice/freatures/ordem_servico/domain/entidades/ordem_servico.dart';

abstract class IOrdemServicoRepository {
  Future<void> save(OrdemServico ordem);
  Future<List<OrdemServico>> listAll();
  Future<void> delete(String id);
  Future<List<OrdemServico>> listByClient(String clientId);
}
