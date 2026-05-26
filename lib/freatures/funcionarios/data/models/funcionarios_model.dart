import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';

class FuncionarioModel extends Funcionario {
  FuncionarioModel({
    required super.id,
    required super.name,
    required super.cpf,
    required super.especialty,
    required super.phone,
    required super.role,
    required super.isActive,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cpf': cpf,
      'especialty': especialty,
      'phone': phone,
      'role': role.name,
      'isActive': isActive ? 1 : 0,
    };
  }

  factory FuncionarioModel.fromMap(Map<String, dynamic> map) {
    return FuncionarioModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      cpf: map['cpf'] ?? '',
      especialty: map['especialty'] ?? '',
      phone: map['phone'] ?? '',
      isActive: map['isActive'] == 1,
      role: UserRole.values.byName(map['role'] ?? 'employee'),
    );
  }
}
