import 'package:coolservice/core/theme/app_theme.dart';
import 'package:coolservice/freatures/funcionarios/domain/entidades/funcionarios.dart';
import 'package:coolservice/freatures/funcionarios/data/repositories/sqlite_funcionario_repository.dart';
import 'package:flutter/material.dart';
import 'package:coolservice/core/presentation/view/dashboard_page.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:coolservice/core/services/notification_service.dart';
import 'package:coolservice/freatures/funcionarios/presentation/view_model/funcionario_viewModel.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;
  String hashSenha(String texto) {
    final bytes = utf8.encode(texto);
    return sha256.convert(bytes).toString();
  }

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final email = '$username@coolservice.app';
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final repo = SQLiteFuncionarioRepository();
      final todos = await repo.listAll();

      Funcionario? funcionario = todos.cast<Funcionario?>().firstWhere(
        (f) => f!.username == username,
        orElse: () => null,
      );

      // Se não achou no SQLite, busca no Firestore e salva localmente
      if (funcionario == null) {
        try {
          final uid = FirebaseAuth.instance.currentUser?.uid;
          if (uid != null) {
            final doc = await FirebaseFirestore.instance
                .collection('funcionarios')
                .doc(uid)
                .get();
            if (doc.exists) {
              final d = doc.data()!;
              funcionario = Funcionario(
                id: d['id'] ?? uid,
                name: d['name'] ?? '',
                cpf: d['cpf'] ?? '',
                especialty: d['especialty'] ?? '',
                phone: d['phone'] ?? '',
                role: UserRole.values.firstWhere(
                  (r) => r.name == d['role'],
                  orElse: () => UserRole.funcionario,
                ),
                isActive: d['isActive'] ?? true,
                username: d['username'] ?? username,
                passwordHash: '',
                firebaseUid: uid,
                fcmToken: d['fcmToken'],
              );
              await repo.save(funcionario);
            }
          }
        } catch (_) {}
      }

      setState(() => _isLoading = false);

      if (funcionario == null) {
        setState(() => _error = 'Usuário não encontrado.');
        return;
      }

      if (!funcionario.isActive) {
        await FirebaseAuth.instance.signOut();
        setState(() => _error = 'Usuário inativo. Contate o administrador.');
        return;
      }
      if (funcionario.firebaseUid != null) {
        final token = await NotificationService.getToken();
        if (token != null) {
          await context.read<FuncionarioViewModel>().saveFcmToken(
            funcionario.firebaseUid!,
            token,
          );
        }
      }

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardPage(funcionario: funcionario!),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);

      if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
        await _loginLocal(username, password);
      } else if (e.code == 'wrong-password') {
        setState(() => _error = 'Senha incorreta.');
      } else {
        setState(() => _error = 'Erro ao autenticar. Tente novamente.');
      }
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error = 'Erro inesperado. Tente novamente.';
      });
    }
  }

  Future<void> _loginLocal(String username, String password) async {
    final repo = SQLiteFuncionarioRepository();
    final todos = await repo.listAll();

    final funcionario = todos.cast<Funcionario?>().firstWhere(
      (f) => f!.username == username && f.passwordHash == hashSenha(password),
      orElse: () => null,
    );

    if (funcionario == null) {
      setState(() => _error = 'Usuário ou senha incorretos.');
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => DashboardPage(funcionario: funcionario),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.noiteArtica,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Semantics(
                label: 'Logo do CoolService',
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.azulProfundo,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.cianoFrio.withOpacity(0.4),
                        blurRadius: 24,
                        spreadRadius: 4,
                      ),
                    ],
                  ),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 120,
                    height: 120,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                      Icons.build_circle_outlined,
                      size: 64,
                      color: AppColors.cianoFrio,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'CollSERVICE',
                style: TextStyle(
                  color: AppColors.brancoPuro,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Faça login para continuar',
                style: TextStyle(color: AppColors.cinzaNeve, fontSize: 14),
              ),

              const SizedBox(height: 40),
Semantics(
                label: 'Campo de usuário',
                textField: true,
              child:TextField(
                controller: _usernameController,
                style: const TextStyle(color: AppColors.brancoPuro),
                decoration: InputDecoration(
                  labelText: 'Usuário',
                  labelStyle: const TextStyle(color: AppColors.azulGelo),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.azulGelo,
                  ),
                  filled: true,
                  fillColor: AppColors.azulProfundo,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.cianoFrio,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
),

              const SizedBox(height: 16),

            Semantics(
                label: 'Campo de senha',
                textField: true,
                obscured: true,
                child: TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                style: const TextStyle(color: AppColors.brancoPuro),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  labelStyle: const TextStyle(color: AppColors.azulGelo),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.azulGelo,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.cinzaNeve,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  filled: true,
                  fillColor: AppColors.azulProfundo,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                      color: AppColors.cianoFrio,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),

              // erro
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: const TextStyle(
                    color: AppColors.inactive,
                    fontSize: 13,
                  ),
                ),
              ],

              const SizedBox(height: 32),

              Semantics(
                label: _isLoading ? 'Carregando, aguarde' : 'Botão Entrar',
                button: true,
                child: SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.cianoFrio,
                    foregroundColor: AppColors.noiteArtica,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: AppColors.noiteArtica,
                          ),
                        )
                      : const Text(
                          'Entrar',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
