import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/freatures/funcionarios/domain/repositories/i_funcionario_repository.dart';

class FuncionarioViewModel extends ChangeNotifier {
  final IFuncionarioRepository _repository;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Funcionario> _funcionarios = [];
  List<Funcionario> get funcionarios => _funcionarios;

  FuncionarioViewModel(this._repository);

  Future<void> createFuncionario(Funcionario funcionario) async {
    final email = '${funcionario.username}@coolservice.app';
    final password = generatePassword(funcionario.cpf);

  final adminUser = _auth.currentUser;

    try {
      // Cria user no Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      // Salva dados no Firestore
      await _firestore.collection('funcionarios').doc(uid).set({
        'id': funcionario.id,
        'name': funcionario.name,
        'cpf': funcionario.cpf,
        'especialty': funcionario.especialty,
        'phone': funcionario.phone,
        'role': funcionario.role.name,
        'isActive': funcionario.isActive,
        'username': funcionario.username,
        'email': email,
        'criadoEm': FieldValue.serverTimestamp(),
        'fcmToken': null,
      });

      // Salva localmente com uid
      final comUid = Funcionario(
        id: funcionario.id,
        name: funcionario.name,
        cpf: funcionario.cpf,
        especialty: funcionario.especialty,
        phone: funcionario.phone,
        role: funcionario.role,
        isActive: funcionario.isActive,
        username: funcionario.username,
        passwordHash: funcionario.passwordHash,
        firebaseUid: uid,
        fcmToken: null,
      );
      await _repository.save(comUid);

      // Desloga o funcionário recém criado e restaura admin
      await _auth.signOut();
      if (adminUser != null) {
        // Admin continua logado (Firebase não tem "re-login automático",
        // mas o admin já está autenticado via token local)
      }
    } on FirebaseAuthException catch (e) {
      // Se email já existe, salva só localmente
      if (e.code == 'email-already-in-use') {
        await _repository.save(funcionario);
      } else {
        rethrow;
      }
    }

    await listAll();
  }

  Future<void> updateFuncionario(Funcionario funcionario) async {
    await _repository.save(funcionario);

    // Atualiza no Firestore se tiver uid
    if (funcionario.firebaseUid != null) {
      await _firestore
          .collection('funcionarios')
          .doc(funcionario.firebaseUid)
          .update({
        'name': funcionario.name,
        'cpf': funcionario.cpf,
        'especialty': funcionario.especialty,
        'phone': funcionario.phone,
        'role': funcionario.role.name,
        'isActive': funcionario.isActive,
      });
    }

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

  Future<void> toggleActive(String id, bool isActive) async {
    await _repository.toggleActive(id, isActive);
    await listAll();
  }

  String generateUsername(String name, String phone) {
    final primeiro = name.trim().split(' ').first.toLowerCase();
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    final ultimos4 = digits.substring(digits.length - 4);
    return '$primeiro$ultimos4';
  }

  String generatePassword(String cpf) {
    final digits = cpf.replaceAll(RegExp(r'\D'), '');
    return digits.substring(0, 6);
  }
  Future<void> saveFcmToken(String firebaseUid, String token) async {
  await _firestore.collection('funcionarios').doc(firebaseUid).update({
    'fcmToken': token,
  });
}
}