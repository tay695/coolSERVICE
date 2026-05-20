import 'package:coolservice/domain/entidades/cliente.dart';

class ClientModel extends Client {
  ClientModel({
    required super.id,
    required super.name,
    required super.cpfCnpj,
    required super.address,
    required super.phone,
    required super.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cpfCnpj': cpfCnpj,
      'address': address,
      'phone': phone,
      'email': email,
    };
  }

  factory ClientModel.fromMap(Map<String, dynamic> map) {
    return ClientModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      cpfCnpj: map['cpfCnpj'] ?? '',
      address: map['address'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
    );
  }
}
