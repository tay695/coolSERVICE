import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';

abstract class IFuncionarioRepository {
  Future<void> save(Funcionario funcionario);
  Future<List<Funcionario>> listAll();
  Future<void> delete(String id);

  Future<void> toggleActive(String id, bool isActive) async {}
}
