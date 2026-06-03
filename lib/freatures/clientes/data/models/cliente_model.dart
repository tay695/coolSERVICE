import 'package:coolservice/freatures/clientes/domain/entidades/cliente.dart';

class ClientModel extends Client {
  ClientModel({
    required super.id,
    required super.name,
    required super.cpfCnpj,
    required super.address,
    required super.city,
    required super.state,
    required super.phone,
    required super.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cpf_cnpj': cpfCnpj,
      'address': address,
      'city': city,
      'state': state,
      'phone': phone,
      'email': email,
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      cpfCnpj: map['cpf_cnpj'] ?? '',
      address: map['address'] ?? '',
      city: map['city'] ?? '',
      state: map['state'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
