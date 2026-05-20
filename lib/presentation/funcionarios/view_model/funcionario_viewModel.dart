import 'package:coolservice/data/repositories/i_funcionario_repository.dart';
import 'package:coolservice/domain/entidades/funcionarios.dart';
import 'package:flutter/material.dart';

class FuncionarioViewModel extends ChangeNotifier {
  final IFuncionarioRepository _repository;

  List<Funcionario> _funcionarios = [];
  List<Funcionario> get funcionarios => _funcionarios;

  FuncionarioViewModel(this._repository);

  Future<void> createFuncionario(Funcionario funcionario) async {
    await _repository.save(funcionario);
    await listAll();
  }

  Future<void> updateFuncionario(Funcionario funcionario) async {
    await _repository.save(funcionario);
    await listAll();
  }

  void searchFuncionario(String query) {
    if (query.isEmpty) {
      listAll();
    } else {
      _funcionarios = _funcionarios
          .where(
            (f) =>
                f.name.toLowerCase().contains(query.toLowerCase()) ||
                f.cpf.contains(query),
          )
          .toList();
      notifyListeners();
    }
  }

  Future<void> listAll() async {
    _funcionarios = await _repository.listAll();
    notifyListeners();
  }
}
