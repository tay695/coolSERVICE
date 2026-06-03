import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:flutter/material.dart';

class SessionViewModel extends ChangeNotifier {
  Funcionario? _funcionario;

  Funcionario? get funcionario => _funcionario;
  bool get isLoggedIn => _funcionario != null;

  void login(Funcionario funcionario) {
    _funcionario = funcionario;
    notifyListeners();
  }

  void logout() {
    _funcionario = null;
    notifyListeners();
  }
}
