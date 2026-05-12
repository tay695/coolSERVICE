import 'package:coolservice/domain/entidades/funcionarios.dart';

abstract class IFuncionarioRepository {
  Future<void> save(Funcionario funcionario);
  Future<List<Funcionario>> listAll();
  Future<void> delete(String id);
}
