enum UserRole { admin,  funcionario}

class Funcionario {
  final String id;
  final String name;
  final String cpf;
  final String especialty;
  final String phone;
  final UserRole role;
  final bool isActive;
  final String username;   
  final String passwordHash;
  final String? firebaseUid;
  Funcionario({
    required this.id,
    required this.name,
    required this.cpf,
    required this.especialty,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.username, 
    required this.passwordHash,
    this.firebaseUid,
  });
}
